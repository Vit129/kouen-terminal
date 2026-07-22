import Foundation

/// Resolves a `wake` target — either an existing local path or a GitHub `org/repo` spec — to a
/// local repo directory, cloning via `GitHubCLIClient` (ghq-style layout) if it isn't there yet.
public struct RepoResolver: Sendable {
    /// Default clone root, ghq's own convention — respected so a later real `ghq install`
    /// finds repos cloned by `wake` in the same place.
    public static let defaultRoot = ("~/ghq" as NSString).expandingTildeInPath

    private let github: GitHubCLIClient
    private let root: String

    public init(github: GitHubCLIClient = GitHubCLIClient(), root: String? = nil) {
        self.github = github
        self.root = root ?? ProcessInfo.processInfo.environment["GHQ_ROOT"] ?? Self.defaultRoot
    }

    /// `true` for `org/repo` (exactly one `/`, no leading `/`, not an existing local path) —
    /// anything else is treated as a local path.
    public static func looksLikeRepoSpec(_ target: String) -> Bool {
        guard !target.hasPrefix("/"), !target.hasPrefix("."), !target.hasPrefix("~") else { return false }
        let parts = target.split(separator: "/", omittingEmptySubsequences: false)
        return parts.count == 2 && !parts[0].isEmpty && !parts[1].isEmpty
    }

    /// Resolves `target` to a local repo directory. If `target` is already a directory on disk,
    /// returns it as-is. If it looks like `org/repo`, resolves to `<root>/github.com/org/repo`,
    /// cloning there first if missing. Returns `nil` if resolution/clone fails.
    public func resolve(_ target: String) -> String? {
        let expanded = (target as NSString).expandingTildeInPath
        if FileManager.default.fileExists(atPath: expanded) {
            return expanded
        }
        guard Self.looksLikeRepoSpec(target) else { return nil }

        let destination = (root as NSString).appendingPathComponent("github.com/\(target)")
        if FileManager.default.fileExists(atPath: destination) {
            return destination
        }
        let parent = (destination as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: parent, withIntermediateDirectories: true)
        guard github.cloneRepo(repoSpec: target, to: destination) else { return nil }
        return destination
    }
}
