import Foundation

/// Wire model for a gate approval record.
public struct GateSummary: Codable, Sendable, Equatable {
    public let gate: Int
    public let approver: String
    public let timestamp: Date
    public let approved: Bool
    public let notes: String?

    public init(gate: Int, approver: String, timestamp: Date, approved: Bool, notes: String?) {
        self.gate = gate
        self.approver = approver
        self.timestamp = timestamp
        self.approved = approved
        self.notes = notes
    }
}

/// Wire model for a task item within a feature.
public struct FeatureTaskSummary: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let label: String
    public let tags: [String]
    public let artifacts: [String]
    public let done: Bool

    public init(id: UUID, label: String, tags: [String], artifacts: [String], done: Bool) {
        self.id = id
        self.label = label
        self.tags = tags
        self.artifacts = artifacts
        self.done = done
    }
}

/// The wire shape for a Feature (P46 AI-SDLC workflow engine). Mirrors
/// `KouenCore`'s `KouenFeature` — same separation `AutomationSummary` uses for `KouenAutomation`.
public struct FeatureSummary: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let slug: String
    public let repoPath: String
    public let phase: String
    public let gates: [GateSummary]
    public let tasks: [FeatureTaskSummary]
    public let worktreePath: String?
    public let branch: String?
    public let baseBranch: String?
    public let supersededBy: String?
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        slug: String,
        repoPath: String,
        phase: String,
        gates: [GateSummary],
        tasks: [FeatureTaskSummary],
        worktreePath: String?,
        branch: String?,
        baseBranch: String?,
        supersededBy: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.slug = slug
        self.repoPath = repoPath
        self.phase = phase
        self.gates = gates
        self.tasks = tasks
        self.worktreePath = worktreePath
        self.branch = branch
        self.baseBranch = baseBranch
        self.supersededBy = supersededBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Checks if a specific gate (1, 2, 3, or 4) has been approved — mirrors
    /// `KouenFeature.isGateApproved(_:)` for the wire DTO, so CLI/MCP code reading a
    /// `FeatureSummary` doesn't re-derive the same `gates.first { ... }` check inline.
    public func isGateApproved(_ gateNumber: Int) -> Bool {
        gates.first { $0.gate == gateNumber && $0.approved } != nil
    }
}
