import Foundation
import KouenCore

/// Which backend runs a swarm worker: `.structured` uses `ClaudeCodeHarness`
/// (no PTY, no Tab/Pane, structured stdout); `.pty` uses a headless `RealPty`
/// surface for opaque CLI agents with no structured/headless mode.
public enum SwarmLane: String, Codable, Sendable, CaseIterable {
    case structured, pty
}

public enum SwarmTaskStatus: String, Codable, Sendable, CaseIterable {
    case queued, spawning, working, waitingInput, succeeded, failed, cancelled
}

/// One node in the fleet DAG — a spawned worker or subagent. See
/// `agent-memory/plans/agent-swarm-core/design.md` for the full data model.
public struct SwarmTaskNode: Codable, Sendable, Identifiable {
    public let id: UUID
    public var parentID: UUID?
    public var lane: SwarmLane
    public var agentKind: AgentKind
    public var role: String?
    public var status: SwarmTaskStatus
    public var summary: String?
    public var tokens: Int?
    public var totalCostUSD: Double?
    public var worktreePath: String?
    public var surfaceID: String?
    public var startedAt: Date
    public var lastActivityAt: Date

    public init(
        id: UUID,
        parentID: UUID? = nil,
        lane: SwarmLane,
        agentKind: AgentKind,
        role: String? = nil,
        status: SwarmTaskStatus = .queued,
        summary: String? = nil,
        tokens: Int? = nil,
        totalCostUSD: Double? = nil,
        worktreePath: String? = nil,
        surfaceID: String? = nil,
        startedAt: Date = Date(),
        lastActivityAt: Date = Date()
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

/// Wire shape for the fleet dashboard. `generation` lets a client cheaply detect
/// "nothing new for me" instead of diffing the full node list every push.
public struct SwarmFleetSnapshot: Codable, Sendable {
    public var nodes: [SwarmTaskNode]
    public var generation: Int

    public init(nodes: [SwarmTaskNode], generation: Int) {
        self.nodes = nodes
        self.generation = generation
    }
}
