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

    /// Splits diff output for a single file into the shared file header and individual hunks.
    public static func parseDiffHunks(_ text: String) -> (header: [String], hunks: [[String]]) {
        let lines = text.components(separatedBy: "\n")
        guard let firstHunkIndex = lines.firstIndex(where: { $0.hasPrefix("@@") }) else {
            return (lines, [])
        }
        let header = Array(lines[0..<firstHunkIndex])
        var hunks: [[String]] = []
        var current: [String] = []
        for line in lines[firstHunkIndex...] {
            if line.hasPrefix("@@") {
                if !current.isEmpty { hunks.append(current) }
                current = [line]
            } else {
                current.append(line)
            }
        }
        if !current.isEmpty { hunks.append(current) }
        if hunks.last?.last == "" { hunks[hunks.count - 1].removeLast() }
        return (header, hunks)
    }

    /// A single hunk's patch text, valid on its own for `git apply --cached [-R]`.
    public static func patchText(header: [String], hunk: [String]) -> String {
        (header + hunk).joined(separator: "\n") + "\n"
    }

    /// Summarizes git stderr into a single-line toast message.
    public static func errorSummary(from stderr: String) -> String {
        let lines = stderr.split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.hasPrefix("hint:") }
        let errorLines = lines.filter { $0.hasPrefix("error:") || $0.hasPrefix("fatal:") }
        let summary = (errorLines.isEmpty ? lines : errorLines).joined(separator: " ")
        let fallback = summary.isEmpty ? stderr.trimmingCharacters(in: .whitespacesAndNewlines) : summary
        guard fallback.count > 120 else { return fallback }
        return String(fallback.prefix(120)) + "…"
    }
}
