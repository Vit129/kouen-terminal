import Foundation

/// High-level headless Git operations used across Core, Daemon, and App.
public final class GitService: Sendable {
    public static let shared = GitService()

    private let runner: GitRunner

    public init(runner: GitRunner = .shared) {
        self.runner = runner
    }

    /// Resolves the Git common directory or root for a given path.
    public func resolveRepoRoot(for path: String) -> String? {
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return nil }
        guard let output = runner.executeOutput(["rev-parse", "--path-format=absolute", "--git-common-dir"], in: path) else {
            return nil
        }
        return GitParsers.parseRepoRoot(output: output)
    }

    /// Checks if a repository at `path` has any configured remotes.
    public func hasRemote(for path: String) -> Bool {
        guard let output = runner.executeOutput(["remote"], in: path) else { return false }
        return !output.isEmpty
    }

    /// Fetches ahead/behind commit counts between HEAD and an upstream branch.
    public func aheadBehindCount(for path: String, upstreamBranch: String) -> GitAheadBehind? {
        let args = ["rev-list", "--left-right", "--count", "HEAD...origin/\(upstreamBranch)"]
        guard let output = runner.executeOutput(args, in: path) else { return nil }
        return GitParsers.parseAheadBehind(output: output)
    }

    /// Fetches worktrees for a git root path via `git worktree list --porcelain`.
    public func listWorktrees(for rootPath: String) -> [GitWorktreeInfo] {
        guard !rootPath.isEmpty, FileManager.default.fileExists(atPath: rootPath) else { return [] }
        guard let output = runner.executeOutput(["worktree", "list", "--porcelain"], in: rootPath) else {
            return []
        }
        return GitParsers.parseWorktreeList(porcelain: output)
    }

    /// Runs arbitrary git command returning a GitResult.
    public func run(_ args: [String], in directory: String? = nil, timeout: TimeInterval = 30) -> GitResult {
        runner.execute(args, in: directory, timeout: timeout)
    }
}
