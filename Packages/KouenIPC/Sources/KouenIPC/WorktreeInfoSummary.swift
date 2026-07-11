import Foundation

/// The wire shape for `WorktreeManager.WorktreeInfo` (P40 F2: `kouenWorktree*` MCP
/// tools). Same separation `TaskSummary`/`BlockSummary` use — `KouenIPC` can't import
/// `KouenCore`, so the daemon converts at the call site.
public struct WorktreeInfoSummary: Codable, Sendable, Equatable {
    public let path: String
    public let branch: String?
    public let head: String
    public let bare: Bool

    public init(path: String, branch: String?, head: String, bare: Bool) {
        self.path = path
        self.branch = branch
        self.head = head
        self.bare = bare
    }
}
