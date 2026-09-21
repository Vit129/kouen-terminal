import Foundation
import KouenIPC

/// The workflow phase of a feature according to AI-SDLC principles.
public enum FeaturePhase: String, Codable, Sendable, CaseIterable {
    case interview
    case architect
    case qaDesign = "qa-design"
    case dev
    case qaVerify = "qa-verify"
    case completed

    public var title: String {
        switch self {
        case .interview: return "Interview"
        case .architect: return "Architect"
        case .qaDesign: return "QA Design"
        case .dev: return "Development"
        case .qaVerify: return "QA Verification"
        case .completed: return "Completed"
        }
    }
}

/// An approval gate record within the AI-SDLC workflow.
public struct GateApproval: Codable, Sendable, Equatable {
    public var gate: Int // 1 (Architect), 2 (Scenario list), 3 (Seam agreement), 4 (Merge Review)
    public var approver: String
    public var timestamp: Date
    public var approved: Bool
    public var notes: String?

    public init(gate: Int, approver: String, timestamp: Date = Date(), approved: Bool = true, notes: String? = nil) {
        self.gate = gate
        self.approver = approver
        self.timestamp = timestamp
        self.approved = approved
        self.notes = notes
    }
}

/// An atomic task tracked under a feature.
public struct FeatureTask: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var label: String
    public var tags: [String]
    public var artifacts: [String]
    public var done: Bool

    public init(id: UUID = UUID(), label: String, tags: [String] = [], artifacts: [String] = [], done: Bool = false) {
        self.id = id
        self.label = label
        self.tags = tags
        self.artifacts = artifacts
        self.done = done
    }
}

/// Core model representing a feature in Kouen with embedded AI-SDLC state and worktree binding.
public struct KouenFeature: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var slug: String
    public var repoPath: String
    public var phase: FeaturePhase
    public var gates: [GateApproval]
    public var tasks: [FeatureTask]
    public var worktreePath: String?
    public var branch: String?
    public var baseBranch: String?
    public var supersededBy: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        slug: String,
        repoPath: String,
        phase: FeaturePhase = .interview,
        gates: [GateApproval] = [],
        tasks: [FeatureTask] = [],
        worktreePath: String? = nil,
        branch: String? = nil,
        baseBranch: String? = nil,
        supersededBy: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
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

    /// Checks if a specific gate (1, 2, 3, or 4) has been approved.
    public func isGateApproved(_ gateNumber: Int) -> Bool {
        gates.first { $0.gate == gateNumber && $0.approved } != nil
    }

    /// Converts to IPC wire summary.
    public func toSummary() -> FeatureSummary {
        FeatureSummary(
            id: id,
            slug: slug,
            repoPath: repoPath,
            phase: phase.rawValue,
            gates: gates.map { GateSummary(gate: $0.gate, approver: $0.approver, timestamp: $0.timestamp, approved: $0.approved, notes: $0.notes) },
            tasks: tasks.map { FeatureTaskSummary(id: $0.id, label: $0.label, tags: $0.tags, artifacts: $0.artifacts, done: $0.done) },
            worktreePath: worktreePath,
            branch: branch,
            baseBranch: baseBranch,
            supersededBy: supersededBy,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
