import Foundation

/// The wire shape for an Automation (P41: `kouenAutomation*` MCP tools). Mirrors
/// `KouenCore`'s `KouenAutomation` — same separation `TaskSummary` uses for `KouenTask`.
public struct AutomationSummary: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let repoPath: String
    public let workspaceID: UUID?
    public let agent: String
    public let prompt: String
    public let intervalMinutes: Int
    public let enabled: Bool
    public let lastRunAt: Date?
    public let lastRunStatus: String?
    public let nextRunAt: Date?
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID, repoPath: String, workspaceID: UUID?, agent: String, prompt: String,
        intervalMinutes: Int, enabled: Bool, lastRunAt: Date?, lastRunStatus: String?,
        nextRunAt: Date?, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.repoPath = repoPath
        self.workspaceID = workspaceID
        self.agent = agent
        self.prompt = prompt
        self.intervalMinutes = intervalMinutes
        self.enabled = enabled
        self.lastRunAt = lastRunAt
        self.lastRunStatus = lastRunStatus
        self.nextRunAt = nextRunAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
