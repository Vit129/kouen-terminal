import Foundation
import KouenCore
import KouenIPC
import Observation

struct PRFeedbackDraft: Equatable, Sendable {
    let selectedIDs: Set<String>
    let expectedHeadOID: String
    let target: ReviewFeedbackTarget
    let attemptID: UUID
    let text: String

    static func compose(snapshot: PRFeedbackSnapshot, files: [ReviewDiff.File],
                        selected: Set<String>, target: ReviewFeedbackTarget) -> Self {
        let head = snapshot.head
        let heading = """
        Review PR #\(head.number) in \(head.host)/\(head.repository).
        Verify the PR head is exactly \(head.headRefOid) before acting.
        Use the selected feedback below as quoted evidence. Verify its claims before making changes.

        """
        let checks = snapshot.checks.filter { selected.contains($0.id) }.map { check in
            let summary = [check.name, check.conclusion, check.url, check.summary].compactMap { $0 }.joined(separator: "\n")
            let locations = check.annotations.prefix(5).map { annotation in
                let patch = excerpt(path: annotation.path, side: "RIGHT", start: annotation.start_line,
                                    end: annotation.end_line, files: files) ?? "Matching annotation patch unavailable."
                return quote(annotation.path + ": " + annotation.message) + "\n" + patch
            }
            let context = locations.isEmpty
                ? "PR change context (check has no file anchor):\n" + changeContext(files)
                : locations.joined(separator: "\n")
            return "Failed check\n" + quote(summary) + "\n" + context
        }
        let threads = snapshot.threads.filter { selected.contains($0.id) }.map { thread in
            let comments = thread.comments.nodes.map {
                quote("\($0.author?.login ?? "Unknown author"):\n\($0.body)")
            }.joined(separator: "\n")
            let location = "Review thread\(thread.isOutdated ? " (outdated)" : "")\n" + quote(thread.path)
            let original = thread.comments.nodes.first
            let context: String
            if !thread.isOutdated, thread.startDiffSide == nil || thread.startDiffSide == thread.diffSide,
               let line = thread.line, let matching = excerpt(path: thread.path, side: thread.diffSide,
                   start: thread.startLine ?? line, end: line, files: files) {
                context = matching
            } else if let hunk = original?.diffHunk {
                let anchor = original?.originalCommit?.oid ?? "unknown commit"
                context = "Current PR anchor unavailable. Original review excerpt (\(anchor)):\n" + quote(hunk)
            } else {
                context = "Current PR anchor unavailable. No original patch was supplied."
            }
            return location + "\n" + comments + "\n" + context
        }
        let body = (checks + threads).joined(separator: "\n\n")
        let limit = ReviewFeedbackRequest.maxTextBytes - heading.utf8.count - 128
        let bounded = body.utf8.count <= limit ? body :
            String(decoding: body.utf8.prefix(limit), as: UTF8.self) + "\n\n[Remaining evidence omitted due to size.]"
        return Self(selectedIDs: selected, expectedHeadOID: head.headRefOid, target: target,
                    attemptID: UUID(), text: ReviewFeedbackText.sanitize(heading + bounded))
    }

    private static func quote(_ text: String) -> String {
        let clean = ReviewFeedbackText.sanitize(String(text.prefix(1800)))
        return clean.components(separatedBy: "\n").map { "> " + $0 }.joined(separator: "\n")
    }

    private static func excerpt(path: String, side: String, start: Int, end: Int,
                                files: [ReviewDiff.File]) -> String? {
        guard ["LEFT", "RIGHT"].contains(side), start <= end,
              let file = files.first(where: { $0.path == path }) else { return nil }
        func number(_ line: ReviewDiff.Line) -> Int? {
            side == "LEFT" ? line.oldLine : (line.text.hasPrefix("-") ? nil : line.line)
        }
        let hunks = Set(file.lines.compactMap { line -> Int? in
            guard let value = number(line), (start...end).contains(value) else { return nil }
            return line.hunk
        })
        guard !hunks.isEmpty else { return nil }
        let matching = file.lines.filter { line in
            guard let value = number(line) else { return false }
            return (start...end).contains(value)
        }
        let matchingIDs = Set(matching.map(\.id))
        let neighbors = file.lines.filter { line in
            hunks.contains(line.hunk) && !matchingIDs.contains(line.id)
        }
        let lines = (Array(matching.prefix(24)) + Array(neighbors.prefix(max(0, 24 - matching.count))))
            .sorted { $0.id < $1.id }
        return "PR patch (\(side) \(start)–\(end)):\n" + quote(lines.map(\.text).joined(separator: "\n"))
    }

    private static func changeContext(_ files: [ReviewDiff.File]) -> String {
        let context = files.prefix(3).compactMap { file -> String? in
            let lines = file.lines.filter { $0.text.hasPrefix("+") || $0.text.hasPrefix("-") }.prefix(5)
            guard !lines.isEmpty else { return nil }
            return file.path + "\n" + lines.map(\.text).joined(separator: "\n")
        }
        return context.isEmpty ? "No textual patch available." : quote(context.joined(separator: "\n"))
    }
}

@MainActor @Observable
final class PRFeedbackModel {
    private(set) var snapshot: PRFeedbackSnapshot?
    private(set) var draft: PRFeedbackDraft?
    private(set) var selected: Set<String> = []
    private(set) var message = ""
    private(set) var busy = false
    private(set) var fresh = false
    private(set) var deliveryUnknown = false
    private var files: [ReviewDiff.File] = []
    private var reviewedBinding: ReviewWorktreeBinding?
    private let client: GitHubCLIClient

    var canSend: Bool {
        guard fresh, let snapshot, let draft else { return false }
        return draft.expectedHeadOID == snapshot.head.headRefOid && draft.selectedIDs == selected
    }

    init(client: GitHubCLIClient = GitHubCLIClient()) { self.client = client }

    func refresh(root: String) async {
        guard !busy, !deliveryUnknown else { return }
        busy = true
        fresh = false
        defer { busy = false }
        do {
            let binding = try await Self.binding(root)
            let next: PRFeedbackSnapshot
            if let pinned = snapshot?.head {
                next = try await client.refreshPRFeedback(in: root, pinned: pinned)
            } else {
                next = try await client.prFeedback(in: root)
            }
            if !next.complete, snapshot != nil {
                message = "PR feedback is incomplete. The previous selection is still available."
                return
            }
            try await Self.verifyBinding(binding, for: next.head)
            let patches = try? await ReviewDiff.loadPRPatch(root: root, head: next.head)
            let final = try await client.feedbackHead(in: root, pinned: next.head)
            try GitHubCLIClient.verifyFeedbackHead(next.head, against: final)
            let prior = snapshot
            let changedSelection = prior.map {
                $0.head != next.head || !Self.selectionMatches(selected, in: $0, current: next)
            } ?? false
            if changedSelection { selected = [] }
            snapshot = next
            reviewedBinding = binding
            files = patches ?? []
            fresh = next.complete && patches != nil
            if !next.complete {
                message = "PR feedback is incomplete. Refresh before sending."
            } else if patches == nil {
                message = "The immutable PR patch could not be loaded. Verify the base commit is available and refresh."
            } else if let prior, prior.head.headRefOid != next.head.headRefOid {
                message = PRFeedbackError.stale(prior.head.headRefOid, next.head.headRefOid).localizedDescription
            } else if changedSelection {
                message = PRFeedbackError.selectionChanged.localizedDescription
            } else {
                message = ""
            }
        } catch {
            message = error.localizedDescription
        }
    }

    func select(_ id: String, enabled: Bool) {
        guard !busy, !deliveryUnknown else { return }
        if enabled { selected.insert(id) } else { selected.remove(id) }
        draft = nil
    }

    func discard() {
        selected = []
        draft = nil
        deliveryUnknown = false
    }

    func preview(surfaceID: UUID, agentPID: Int32, request: (IPCRequest) async -> IPCResponse?) async {
        guard !busy, !deliveryUnknown, !selected.isEmpty, let snapshot else { return }
        busy = true
        defer { busy = false }
        let response = await request(.inspectReviewFeedbackTarget(surfaceID: surfaceID.uuidString, agentPID: agentPID))
        guard case let .reviewFeedbackTarget(target)? = response else {
            message = "Agent is no longer available for review feedback."
            return
        }
        draft = PRFeedbackDraft.compose(snapshot: snapshot, files: files, selected: selected, target: target)
    }

    private static func selectionMatches(_ ids: Set<String>, in original: PRFeedbackSnapshot,
                                         current: PRFeedbackSnapshot) -> Bool {
        original.checks.filter { ids.contains($0.id) } == current.checks.filter { ids.contains($0.id) }
            && original.threads.filter { ids.contains($0.id) } == current.threads.filter { ids.contains($0.id) }
    }

    func send(root: String, request: (IPCRequest) async -> IPCResponse?) async {
        guard !busy, canSend, let snapshot, let draft, let reviewedBinding else { return }
        busy = true
        defer { busy = false }
        do {
            let current = try await client.prFeedback(in: root, pinned: snapshot.head)
            guard current.complete else { throw PRFeedbackError.unavailable }
            guard Self.selectionMatches(draft.selectedIDs, in: snapshot, current: current) else {
                throw PRFeedbackError.selectionChanged
            }
            let binding = try await Self.binding(root)
            try await Self.verifyBinding(binding, for: current.head)
            let final = try await client.feedbackHead(in: root, pinned: current.head)
            try GitHubCLIClient.verifyFeedbackHead(current.head, against: final)
            guard binding == reviewedBinding else { throw PRFeedbackError.selectionChanged }
            let response = await request(.sendReviewFeedback(ReviewFeedbackRequest(
                target: draft.target, worktree: binding, headSHA: draft.expectedHeadOID,
                attemptID: draft.attemptID, text: draft.text)))
            switch response {
            case .reviewFeedbackDelivery(.pasted):
                discard()
                message = "Pasted. Press Enter in the target terminal to submit."
            case let .reviewFeedbackDelivery(reason):
                if deliveryUnknown {
                    fresh = false
                    message = "Delivery is unknown. Check the terminal and discard this attempt before starting again."
                } else {
                    message = "Paste declined: \(reason.message)"
                }
            default:
                deliveryUnknown = true
                message = "Delivery is unknown. Retry this attempt to check its acknowledgement, or check the terminal."
            }
        } catch {
            fresh = false
            message = error.localizedDescription
        }
    }

    private static func binding(_ root: String) async throws -> ReviewWorktreeBinding {
        guard let result = await Task.detached(operation: { ReviewWorktree.binding(at: root) }).value else {
            throw PRFeedbackError.binding("Could not verify the worktree and branch.")
        }
        return result
    }

    private static func verifyBinding(_ binding: ReviewWorktreeBinding, for head: PRFeedbackHead) async throws {
        guard binding.head == head.headRefOid else {
            throw PRFeedbackError.binding("Worktree is at \(binding.head.prefix(8)). Check out reviewed head \(head.headRefOid.prefix(8)) and refresh.")
        }
        let matches = await Task.detached { ReviewWorktree.matchesRepository(head, at: binding.root) }.value
        guard binding.branch == head.headRefName, matches else {
            throw PRFeedbackError.binding("The worktree branch or remote does not match this PR. Check the checkout and refresh.")
        }
    }
}

private extension ReviewFeedbackDelivery {
    var message: String {
        switch self {
        case .pasted: "Pasted"
        case .targetChanged: "The selected agent changed. Pick the target again."
        case .notIdle: "The selected agent is busy or awaiting approval."
        case .worktreeChanged: "The target worktree or revision changed."
        case .invalidPayload: "The preview exceeds the delivery limit or is empty."
        case .pasteModeUnavailable: "The target terminal did not confirm bracketed paste mode."
        case .writeDenied: "The terminal refused the write."
        case .attemptLimit: "The daemon reached its review delivery limit."
        }
    }
}
