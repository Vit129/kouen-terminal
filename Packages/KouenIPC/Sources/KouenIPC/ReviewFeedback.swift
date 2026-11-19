import Foundation

public struct ReviewWorktreeBinding: Codable, Sendable, Equatable {
    public let root: String
    public let gitDirectory: String
    public let branch: String
    public let head: String

    public init(root: String, gitDirectory: String, branch: String, head: String) {
        self.root = root
        self.gitDirectory = gitDirectory
        self.branch = branch
        self.head = head
    }
}

public struct ReviewFeedbackTarget: Codable, Sendable, Equatable {
    public let surfaceID: String
    public let ptyInstance: UUID
    public let generation: UInt64
    public let agentPID: Int32
    public let agentBirth: String
    public let agentKind: AgentKind

    public init(surfaceID: String, ptyInstance: UUID, generation: UInt64, agentPID: Int32,
                agentBirth: String, agentKind: AgentKind) {
        self.surfaceID = surfaceID
        self.ptyInstance = ptyInstance
        self.generation = generation
        self.agentPID = agentPID
        self.agentBirth = agentBirth
        self.agentKind = agentKind
    }
}

public struct ReviewFeedbackRequest: Codable, Sendable, Equatable {
    public static let maxTextBytes = 48 * 1024
    public let target: ReviewFeedbackTarget
    public let worktree: ReviewWorktreeBinding
    public let headSHA: String
    public let attemptID: UUID
    public let text: String

    public init(target: ReviewFeedbackTarget, worktree: ReviewWorktreeBinding, headSHA: String,
                attemptID: UUID, text: String) {
        self.target = target
        self.worktree = worktree
        self.headSHA = headSHA
        self.attemptID = attemptID
        self.text = text
    }
}

public enum ReviewFeedbackDelivery: String, Codable, Sendable, Equatable {
    case pasted
    case targetChanged
    case notIdle
    case worktreeChanged
    case invalidPayload
    case pasteModeUnavailable
    case writeDenied
    case attemptLimit
}
