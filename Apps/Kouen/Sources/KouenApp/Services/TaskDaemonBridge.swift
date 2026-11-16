import Foundation
import KouenCore

/// Thin async wrapper over the Task IPC cases (P40 F1), for `TaskDashboardView`.
/// `DaemonClient.request()` is synchronous under the hood despite its `async` callers —
/// every call here goes through `Task.detached(priority: .utility)` so it never blocks
/// the calling actor (RL-052, same fix `GitPanelView.runGitWithStatus` applies).
enum TaskDaemonBridge {
    actor SessionTaskRequests {
        private var requests: [UUID: (refresh: UUID, task: Task<[TaskSummary], Never>)] = [:]

        func list(sessionID: UUID, refresh: UUID, load: @Sendable @escaping () async -> [TaskSummary]) async -> [TaskSummary] {
            if let entry = requests[sessionID], entry.refresh == refresh { return await entry.task.value }
            let task = Task { await load() }
            requests[sessionID] = (refresh, task)
            return await task.value
        }
    }

    static func list(sessionID: UUID?) async -> [TaskSummary] {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(.taskList(sessionID: sessionID)),
                  case let .tasks(tasks) = response
            else { return [] }
            return tasks
        }.value
    }

    @discardableResult
    static func create(sessionID: UUID, title: String) async -> TaskSummary? {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(.taskCreate(sessionID: sessionID, title: title)),
                  case let .taskInfo(task) = response
            else { return nil }
            return task
        }.value
    }

    @discardableResult
    static func update(id: UUID, title: String? = nil, done: Bool? = nil) async -> TaskSummary? {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(
                .taskUpdate(id: id, title: title, done: done, status: nil)
            ),
                  case let .taskInfo(task) = response
            else { return nil }
            return task
        }.value
    }

    @discardableResult
    static func delete(id: UUID) async -> Bool {
        await Task.detached(priority: .utility) {
            guard let response = try? DaemonClient().request(.taskDelete(id: id)) else { return false }
            if case .ok = response { return true }
            return false
        }.value
    }
}
