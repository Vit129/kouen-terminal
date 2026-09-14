import Foundation

/// The wire shape for one Agent Swarm Core fleet node (`kouenSwarm*` MCP tools). Mirrors
/// `KouenDaemon`'s `SwarmTaskNode` — kept as a separate type for the same reason
/// `ClaudeRunSummary` is: `KouenIPC` cannot import `KouenDaemon`. `lane`/`status` cross the
/// wire as raw strings (matching `ClaudeRunSummary.state`'s precedent) rather than
/// duplicating `SwarmLane`/`SwarmTaskStatus` as parallel enums here.
public struct SwarmTaskNodeWire: Codable, Sendable, Identifiable {
    public let id: UUID
    public let parentID: UUID?
    public let lane: String
    public let agentKind: AgentKind
    public let role: String?
    public let status: String
    public let summary: String?
    public let tokens: Int?
    public let totalCostUSD: Double?
    public let worktreePath: String?
    public let surfaceID: String?
    public let startedAt: Date
    public let lastActivityAt: Date

    public init(
        id: UUID, parentID: UUID?, lane: String, agentKind: AgentKind, role: String?,
        status: String, summary: String?, tokens: Int?, totalCostUSD: Double?,
        worktreePath: String?, surfaceID: String?, startedAt: Date, lastActivityAt: Date
    ) {
        self.id = id
        self.parentID = parentID
        self.lane = lane
        self.agentKind = agentKind
        self.role = role
        self.status = status
        self.summary = summary
        self.tokens = tokens
        self.totalCostUSD = totalCostUSD
        self.worktreePath = worktreePath
        self.surfaceID = surfaceID
        self.startedAt = startedAt
        self.lastActivityAt = lastActivityAt
    }
}

/// Wire shape for the fleet dashboard snapshot. Mirrors `KouenDaemon`'s `SwarmFleetSnapshot`.
public struct SwarmFleetSnapshotWire: Codable, Sendable {
    public let nodes: [SwarmTaskNodeWire]
    public let generation: Int

    public init(nodes: [SwarmTaskNodeWire], generation: Int) {
        self.nodes = nodes
        self.generation = generation
    }
}
