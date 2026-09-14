import Foundation
import KouenCore

/// Thin async wrapper over the Agent Swarm Core IPC cases (`.swarm*`), for `SwarmFleetView`.
/// Same `Task.detached(priority: .utility)` shape as `TaskDaemonBridge` — `DaemonClient.request()`
/// is synchronous under the hood despite its `async` callers, so every call here hops off the
/// caller's actor (RL-052).
enum SwarmDaemonBridge {
    static func list() async -> SwarmFleetSnapshotWire {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(.swarmList),
                  case let .swarmFleetSnapshot(snapshot) = response
            else { return SwarmFleetSnapshotWire(nodes: [], generation: 0) }
            return snapshot
        }.value
    }

    @discardableResult
    static func send(taskID: UUID, text: String) async -> Bool {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(.swarmSend(taskID: taskID, text: text)),
                  case let .swarmActionResult(ok) = response
            else { return false }
            return ok
        }.value
    }

    @discardableResult
    static func terminate(taskID: UUID) async -> Bool {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(.swarmTerminate(taskID: taskID)),
                  case let .swarmActionResult(ok) = response
            else { return false }
            return ok
        }.value
    }
}
