import Foundation

/// Result of executing a git command.
public struct GitResult: Sendable, Equatable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String

    public var isSuccess: Bool { exitCode == 0 }

    public init(exitCode: Int32, stdout: String, stderr: String = "") {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

/// Information about a Git worktree parsed from porcelain output.
public struct GitWorktreeInfo: Sendable, Equatable {
    public let path: String
    public let head: String
    public let branch: String?
    public let isBare: Bool
    public let isDetached: Bool
    public let isLocked: Bool

    public init(
        path: String,
        head: String = "",
        branch: String? = nil,
        isBare: Bool = false,
        isDetached: Bool = false,
        isLocked: Bool = false
    ) {
        self.path = path
        self.head = head
        self.branch = branch
        self.isBare = isBare
        self.isDetached = isDetached
        self.isLocked = isLocked
    }
}

/// Ahead and behind commit counts relative to an upstream branch.
public struct GitAheadBehind: Sendable, Equatable {
    public let ahead: Int
    public let behind: Int

    public init(ahead: Int, behind: Int) {
        self.ahead = ahead
        self.behind = behind
    }
}
