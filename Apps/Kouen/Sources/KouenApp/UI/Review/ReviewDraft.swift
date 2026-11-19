import Foundation
import Observation

struct ReviewNote: Identifiable, Equatable {
    let id = UUID()
    var path: String
    var kind: ReviewDiff.Kind
    var line: Int
    var text: String
    var body: String
    var resolved = false

    func match(in files: [ReviewDiff.File]) -> ReviewDiff.Line? {
        let lines = files.first { $0.path == path && $0.kind == kind }?.lines ?? []
        let anchor = text.components(separatedBy: "\n")
        let matches = lines.indices.compactMap { index -> ReviewDiff.Line? in
            let end = index + anchor.count
            guard end <= lines.count,
                  lines[index].hunk == lines[end - 1].hunk,
                  lines[index..<end].map(\.text) == anchor else { return nil }
            return lines[index]
        }
        if let exact = matches.first(where: { $0.line == line }) { return exact }
        return matches.count == 1 ? matches.first : nil
    }
}

@MainActor @Observable
final class ReviewDraft {
    enum SendResult: Equatable {
        case sent
        case needsReattachment([ReviewNote])
        case unavailable
        case deliveryFailed
    }

    let prFeedback = PRFeedbackModel()
    var notes: [ReviewNote] = []

    func send(
        to target: UUID, allowed: Set<UUID>, files: [ReviewDiff.File],
        deliver: (UUID, String) async -> Bool
    ) async -> SendResult {
        let open = notes.filter { !$0.resolved }
        guard !open.isEmpty else { return .unavailable }
        var feedback: [String] = []
        var unmatched: [ReviewNote] = []
        for note in open {
            guard let match = note.match(in: files) else {
                unmatched.append(note)
                continue
            }
            feedback.append("\(note.path):\(match.line) [\(note.kind.rawValue)]\n\(note.text)\n\(note.body)")
        }
        guard unmatched.isEmpty else { return .needsReattachment(unmatched) }
        guard allowed.contains(target) else { return .unavailable }
        let delivered = await deliver(target, "Please address these review comments in the current worktree:\n\n"
            + feedback.joined(separator: "\n\n"))
        return delivered ? .sent : .deliveryFailed
    }
}
