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
    /// The creating session's cwd at creation time, if known — see `KouenTask.cwd`'s doc
    /// comment for why this is captured once up front rather than re-derived later.
    public let cwd: String?

    public init(
        id: UUID, sessionID: UUID, title: String, done: Bool, createdAt: Date, updatedAt: Date,
        cwd: String? = nil
    ) {
        self.id = id
        self.sessionID = sessionID
        self.title = title
        self.done = done
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cwd = cwd
    }
}
