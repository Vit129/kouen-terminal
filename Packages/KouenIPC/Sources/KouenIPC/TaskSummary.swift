import Foundation

/// The wire shape for a Task (P40 F1: `kouenTask*` MCP tools). Mirrors `KouenCore`'s
/// `KouenTask` — kept as a separate type rather than reused directly, same separation
/// `BlockSummary` uses for `TerminalBlock` (`KouenIPC` cannot import `KouenCore`; `KouenCore`
/// depends on `KouenIPC`, not the other way).
public struct TaskSummary: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let sessionID: UUID
    public let title: String
    public let done: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(id: UUID, sessionID: UUID, title: String, done: Bool, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.sessionID = sessionID
        self.title = title
        self.done = done
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
