import Foundation
import KouenCore
import KouenIPC
import XCTest
@testable import KouenApp

@MainActor
final class PRFeedbackTests: XCTestCase {
    func test_TC8302_BE_UT_UsesExactSideAndLabelsOriginalAnchors() async throws {
        let fixture = ReviewGitHubFixture(head: String(repeating: "a", count: 40), base: String(repeating: "b", count: 40))
        let client = GitHubCLIClient { args, _ in await fixture.run(args) }
        let snapshot = try await client.prFeedback(in: "/fixture")
        let file = ReviewDiff.File(path: "file", kind: .unstaged, patch: """
        @@ -4,2 +8,2 @@
         context
        -original
        +updated
        """)
        let draft = PRFeedbackDraft.compose(snapshot: snapshot, files: [file],
                                           selected: ["current", "outdated", "missing"], target: target())
        XCTAssertTrue(draft.text.contains("LEFT 4–5"))
        XCTAssertTrue(draft.text.contains("> -original"))
        XCTAssertTrue(draft.text.contains("Original review excerpt"))
        XCTAssertTrue(draft.text.contains("> original anchor"))
        XCTAssertTrue(draft.text.contains("No original patch was supplied"))
        XCTAssertTrue(draft.text.contains(snapshot.head.headRefOid))
        XCTAssertLessThanOrEqual(draft.text.utf8.count, ReviewFeedbackRequest.maxTextBytes)
    }

    func test_TC8303_FE_IT_BlocksOldPreviewWhenHeadMovesOnSend() async throws {
        try await withRepo { root, head, base in
            let fixture = ReviewGitHubFixture(head: head, base: base)
            let model = PRFeedbackModel(client: GitHubCLIClient { args, _ in await fixture.run(args) })
            await model.refresh(root: root)
            XCTAssertTrue(model.fresh, model.message)
            model.select("current", enabled: true)
            await preview(model, target: target())
            await fixture.moveHead()
            await model.send(root: root) { _ in XCTFail("Must not reach daemon"); return nil }
            XCTAssertFalse(model.fresh)
            XCTAssertTrue(model.message.contains("PR head changed"))
            XCTAssertNotNil(model.draft)
        }
    }

    func test_TC8303_FE_IT_StopsWhenASelectedThreadResolvesOnTheSameHead() async throws {
        try await withRepo { root, head, base in
            let fixture = ReviewGitHubFixture(head: head, base: base)
            let model = PRFeedbackModel(client: GitHubCLIClient { args, _ in await fixture.run(args) })
            await model.refresh(root: root)
            model.select("current", enabled: true)
            await preview(model, target: target())
            XCTAssertTrue(model.canSend)
            await fixture.resolveThread()
            await model.send(root: root) { _ in XCTFail("Resolved feedback must not reach daemon"); return nil }
            XCTAssertFalse(model.canSend)
            XCTAssertTrue(model.message.contains("Selected PR feedback changed"))
            let previous = try XCTUnwrap(model.draft)
            await model.refresh(root: root)
            XCTAssertTrue(model.selected.isEmpty)
            XCTAssertFalse(model.canSend)
            XCTAssertEqual(model.draft, previous)
        }
    }

    func test_TC8306_FE_IT_PreviewsSendsAndRetainsDraftIfAcknowledgementIsLost() async throws {
        try await withRepo { root, head, base in
            let fixture = ReviewGitHubFixture(head: head, base: base)
            let model = PRFeedbackModel(client: GitHubCLIClient { args, _ in await fixture.run(args) })
            await model.refresh(root: root)
            XCTAssertTrue(model.fresh, model.message)
            model.select("current", enabled: true)
            let agent = target()
            await preview(model, target: agent)
            let draft = try XCTUnwrap(model.draft)
            XCTAssertTrue(draft.text.contains("committed line"))
            XCTAssertFalse(draft.text.contains("dirty working copy"))
            await fixture.setOffline(true)
            await model.send(root: root) { _ in XCTFail("Offline delivery must stop"); return nil }
            XCTAssertEqual(model.draft, draft)
            XCTAssertFalse(model.fresh)
            await fixture.setOffline(false)
            await model.refresh(root: root)
            XCTAssertEqual(model.draft, draft)
            await model.send(root: root) { message in
                guard case let .sendReviewFeedback(request) = message else { return XCTFailResponse() }
                XCTAssertEqual(request.text, draft.text)
                XCTAssertEqual(request.target, agent)
                XCTAssertEqual(request.attemptID, draft.attemptID)
                return nil
            }
            XCTAssertEqual(model.draft, draft)
            XCTAssertTrue(model.deliveryUnknown)
            await model.send(root: root) { message in
                guard case let .sendReviewFeedback(request) = message else { return XCTFailResponse() }
                XCTAssertEqual(request.attemptID, draft.attemptID)
                return .reviewFeedbackDelivery(.pasted)
            }
            XCTAssertNil(model.draft)
            XCTAssertTrue(model.message.contains("Press Enter"))
        }
    }

    func test_TC8307_FE_IT_PreservesLocalLineHandoffAlongsidePRFeedback() async {
        let draft = ReviewDraft()
        draft.prFeedback.select("thread", enabled: true)
        let patch = ReviewDiff.File(path: "file", kind: .unstaged, patch: "@@ -1 +1 @@\n-old\n+new\n")
        draft.notes = [ReviewNote(path: "file", kind: .unstaged, line: 1, text: "+new", body: "Local note")]
        let pane = UUID()
        let result = await draft.send(to: pane, allowed: [pane], files: [patch]) { id, text in
            XCTAssertEqual(id, pane)
            XCTAssertTrue(text.contains("Local note"))
            XCTAssertFalse(text.contains("thread"))
            return true
        }
        XCTAssertEqual(result, .sent)
        XCTAssertEqual(draft.prFeedback.selected, ["thread"])
    }

    private func target() -> ReviewFeedbackTarget {
        ReviewFeedbackTarget(surfaceID: UUID().uuidString, ptyInstance: UUID(), generation: 1, agentPID: 10,
                             agentBirth: "birth", agentKind: .codex)
    }

    private func preview(_ model: PRFeedbackModel, target: ReviewFeedbackTarget) async {
        await model.preview(surfaceID: UUID(uuidString: target.surfaceID)!, agentPID: target.agentPID) { request in
            guard case let .inspectReviewFeedbackTarget(id, pid) = request else { return XCTFailResponse() }
            XCTAssertEqual(id, target.surfaceID)
            XCTAssertEqual(pid, target.agentPID)
            return .reviewFeedbackTarget(target)
        }
    }

    private func XCTFailResponse() -> IPCResponse? {
        XCTFail("Unexpected IPC request")
        return nil
    }

    private func withRepo(_ body: (String, String, String) async throws -> Void) async throws {
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".tmp/review-fixture-\(UUID())", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        func git(_ args: String...) async throws -> String {
            let result = await ProcessRunner.runAsync(executable: "git", arguments: args, in: directory.path, timeout: 5)
            guard result.isSuccess else { throw ReviewDiff.LoadError(errorDescription: result.stderr) }
            return result.stdout.trimmingCharacters(in: .newlines)
        }
        _ = try await git("init", "-b", "feature")
        _ = try await git("remote", "add", "origin", "https://github.example/team/project.git")
        let file = directory.appendingPathComponent("file")
        try "a\nb\nc\ncontext\nbase\n".write(to: file, atomically: true, encoding: .utf8)
        _ = try await git("add", "file")
        _ = try await git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-m", "base")
        let base = try await git("rev-parse", "HEAD")
        try "a\nb\nc\ncontext\ncommitted line\n".write(to: file, atomically: true, encoding: .utf8)
        _ = try await git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-am", "review")
        let head = try await git("rev-parse", "HEAD")
        try "dirty working copy\n".write(to: file, atomically: true, encoding: .utf8)
        try await body(directory.path, head, base)
    }
}

private actor ReviewGitHubFixture {
    var head: String
    let base: String
    var offline = false
    var resolved = false
    init(head: String, base: String) { self.head = head; self.base = base }
    func setOffline(_ value: Bool) { offline = value }
    func resolveThread() { resolved = true }
    func moveHead() { head = String(repeating: "f", count: 40) }

    func run(_ args: [String]) -> ProcessResult {
        if offline { return ProcessResult(exitCode: 1, stdout: "") }
        let text: String
        if args.first == "pr" {
            text = """
            {"number":7,"url":"https://github.example/team/project/pull/7","headRefName":"feature",
            "headRefOid":"\(head)","baseRefOid":"\(base)","headRepository":{"nameWithOwner":"team/project"}}
            """
        } else if args.contains("graphql") {
            text = """
            {"data":{"repository":{"pullRequest":{"reviewThreads":{"pageInfo":{"hasNextPage":false},"nodes":[
            {"id":"current","isResolved":\(resolved),"isOutdated":false,"path":"file","diffSide":"LEFT","line":5,"startLine":4,
            "comments":{"nodes":[{"body":"Fix this","author":{"login":"reviewer"}}],"pageInfo":{"hasNextPage":false}}},
            {"id":"outdated","isResolved":false,"isOutdated":true,"path":"file","diffSide":"RIGHT",
            "comments":{"nodes":[{"body":"Previous feedback","diffHunk":"original anchor"}],"pageInfo":{"hasNextPage":false}}},
            {"id":"missing","isResolved":false,"isOutdated":false,"path":"binary","diffSide":"LEFT","line":1,
            "comments":{"nodes":[],"pageInfo":{"hasNextPage":false}}}
            ]}}}}}
            """
        } else if args.last?.contains("/check-runs") == true {
            text = #"{"total_count":0,"check_runs":[]}"#
        } else {
            text = "[]"
        }
        return ProcessResult(exitCode: 0, stdout: text)
    }
}
