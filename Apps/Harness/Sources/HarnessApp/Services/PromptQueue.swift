import Foundation
import HarnessCore
import HarnessTerminalKit

/// Queues shell commands per surface and sends the next one as soon as the previous
/// shell prompt appears (OSC 133 A/B). One queue per surface; independent queues
/// don't interfere across panes.
@MainActor
final class PromptQueue {
    static let shared = PromptQueue()
    private var queues: [SurfaceID: [String]] = [:]
    /// Called on the main actor whenever a surface's queue count changes.
    var onQueueChanged: ((SurfaceID) -> Void)?

    private init() {}

    func enqueue(_ command: String, for surfaceID: SurfaceID) {
        queues[surfaceID, default: []].append(command)
        onQueueChanged?(surfaceID)
    }

    func dequeueAndRun(for surfaceID: SurfaceID, via host: TerminalHostView) {
        guard var q = queues[surfaceID], !q.isEmpty else { return }
        let cmd = q.removeFirst()
        queues[surfaceID] = q
        host.sendInput((cmd + "\n").data(using: .utf8) ?? Data())
        onQueueChanged?(surfaceID)
    }

    func cancel(for surfaceID: SurfaceID) {
        queues[surfaceID] = []
        onQueueChanged?(surfaceID)
    }

    func count(for surfaceID: SurfaceID) -> Int {
        queues[surfaceID]?.count ?? 0
    }
}
