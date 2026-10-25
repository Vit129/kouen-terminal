import Foundation

/// Pure parsers for git command outputs.
public enum GitParsers {
    /// Parses output from `git worktree list --porcelain`.
    public static func parseWorktreeList(porcelain: String) -> [GitWorktreeInfo] {
        var entries: [GitWorktreeInfo] = []
        var currentPath: String?
        var currentHead = ""
        var currentBranch: String?
        var isBare = false
        var isDetached = false

        func commitCurrent() {
            guard let path = currentPath, !path.isEmpty else { return }
            entries.append(GitWorktreeInfo(
                path: path,
                head: currentHead,
                branch: currentBranch,
                isBare: isBare,
                isDetached: isDetached
            ))
            currentPath = nil
            currentHead = ""
            currentBranch = nil
            isBare = false
            isDetached = false
        }

        let lines = porcelain.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                commitCurrent()
                continue
            }
            if trimmed.hasPrefix("worktree ") {
                if currentPath != nil { commitCurrent() }
                currentPath = String(trimmed.dropFirst("worktree ".count))
            } else if trimmed.hasPrefix("HEAD ") {
                currentHead = String(trimmed.dropFirst("HEAD ".count))
            } else if trimmed.hasPrefix("branch ") {
                let fullRef = String(trimmed.dropFirst("branch ".count))
                if fullRef.hasPrefix("refs/heads/") {
                    currentBranch = String(fullRef.dropFirst("refs/heads/".count))
                } else {
                    currentBranch = fullRef
                }
            } else if trimmed == "bare" {
                isBare = true
            } else if trimmed == "detached" {
                isDetached = true
            }
        }
        commitCurrent()
        return entries
    }

    /// Parses output from `git rev-list --left-right --count A...B`.
    public static func parseAheadBehind(output: String) -> GitAheadBehind? {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.components(separatedBy: "\t")
        guard parts.count == 2,
              let ahead = Int(parts[0].trimmingCharacters(in: .whitespaces)),
              let behind = Int(parts[1].trimmingCharacters(in: .whitespaces))
        else { return nil }
        return GitAheadBehind(ahead: ahead, behind: behind)
    }

    /// Parses output from `git rev-parse --path-format=absolute --git-common-dir`
    /// or `git rev-parse --show-toplevel`.
    public static func parseRepoRoot(output: String) -> String? {
        var root = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !root.isEmpty else { return nil }
        if root.hasSuffix("/.git") {
            root = (root as NSString).deletingLastPathComponent
        }
        return root
    }
}
