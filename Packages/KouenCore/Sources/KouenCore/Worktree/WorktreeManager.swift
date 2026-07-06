import Foundation

/// Manages git worktree lifecycle for session isolation.
/// Each isolated session gets its own worktree so it can have an independent HEAD/branch.
public struct WorktreeManager: Sendable {
    /// Directory name inside the repo root where Kouen-managed worktrees live.
    public static let worktreeDir = ".kouen-worktrees"

    /// Info about an existing worktree.
    public struct WorktreeInfo: Sendable, Equatable {
        public let path: String
        public let branch: String?
        public let head: String  // commit SHA
        public let bare: Bool
    }

    public init() {}

    // MARK: - Create

    /// Creates an isolated worktree for a session.
    /// - Parameters:
    ///   - repoPath: The parent repository root (contains `.git`).
    ///   - sessionID: Short identifier used as the worktree folder name.
    ///   - branch: Branch name to create/checkout. If nil, creates detached HEAD.
    ///   - baseRef: The ref to branch from (e.g. "origin/main"). Defaults to HEAD.
    /// - Returns: The absolute path to the new worktree, or nil on failure.
    public func create(
        repoPath: String,
        sessionID: String,
        branch: String? = nil,
        baseRef: String? = nil
    ) -> String? {
        let worktreePath = (repoPath as NSString)
            .appendingPathComponent(Self.worktreeDir)
            .appending("/\(sessionID)")

        var args = ["worktree", "add"]
        if let branch {
            args += ["-b", branch, worktreePath]
        } else {
            args += ["--detach", worktreePath]
        }
        if let baseRef {
            args.append(baseRef)
        }

        guard runGit(args, in: repoPath) else { return nil }
        return worktreePath
    }

    // MARK: - Remove

    /// Removes a worktree. Uses `--force` if `force` is true (discards uncommitted changes).
    @discardableResult
    public func remove(repoPath: String, worktreePath: String, force: Bool = false) -> Bool {
        var args = ["worktree", "remove", worktreePath]
        if force { args.append("--force") }
        return runGit(args, in: repoPath)
    }

    // MARK: - Archive hook (P32 F3)

    /// Runs a project's `archiveScript` (from `kouen.json`) in `cwd`, blocking the caller
    /// until it exits or `timeout` elapses (whichever first — the caller is the daemon's
    /// synchronous IPC handler, so an unbounded arbitrary script would hang all other clients).
    /// Returns false on spawn failure, non-zero exit, or timeout.
    @discardableResult
    public func runArchiveScript(_ script: String, cwd: String, env: [String: String]? = nil, timeout: TimeInterval = 30) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script]
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        if let env {
            var environment = ProcessInfo.processInfo.environment
            for (key, value) in env { environment[key] = value }
            process.environment = environment
        }
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return false
        }
        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.schedule(deadline: .now() + timeout)
        timer.setEventHandler { [process] in
            if process.isRunning { process.terminate() }
        }
        timer.resume()
        process.waitUntilExit()
        timer.cancel()
        return process.terminationStatus == 0
    }

    // MARK: - List

    /// Lists all worktrees for a repository.
    public func list(repoPath: String) -> [WorktreeInfo] {
        guard let output = runGitOutput(["worktree", "list", "--porcelain"], in: repoPath) else {
            return []
        }
        return parseWorktreeList(output)
    }

    // MARK: - Query

    /// Returns true if the worktree has uncommitted changes (dirty).
    public func isDirty(worktreePath: String) -> Bool {
        guard let output = runGitOutput(["status", "--porcelain"], in: worktreePath) else {
            return false
        }
        return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Finds the git repo root for a given path (works for both repos and worktrees).
    public func repoRoot(for path: String) -> String? {
        runGitOutput(["rev-parse", "--show-toplevel"], in: path)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Prunes stale worktree entries (e.g. after manual directory deletion).
    @discardableResult
    public func prune(repoPath: String) -> Bool {
        runGit(["worktree", "prune"], in: repoPath)
    }

    // MARK: - Private

    @discardableResult
    private func runGit(_ args: [String], in directory: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch { return false }
    }

    private func runGitOutput(_ args: [String], in directory: String) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch { return nil }
    }

    private func parseWorktreeList(_ output: String) -> [WorktreeInfo] {
        var results: [WorktreeInfo] = []
        var path: String?
        var head: String?
        var branch: String?
        var bare = false

        for line in output.components(separatedBy: "\n") {
            if line.hasPrefix("worktree ") {
                // Flush previous entry
                if let p = path, let h = head {
                    results.append(WorktreeInfo(path: p, branch: branch, head: h, bare: bare))
                }
                path = String(line.dropFirst("worktree ".count))
                head = nil; branch = nil; bare = false
            } else if line.hasPrefix("HEAD ") {
                head = String(line.dropFirst("HEAD ".count))
            } else if line.hasPrefix("branch ") {
                let ref = String(line.dropFirst("branch ".count))
                branch = ref.hasPrefix("refs/heads/") ? String(ref.dropFirst("refs/heads/".count)) : ref
            } else if line == "bare" {
                bare = true
            }
        }
        // Flush last entry
        if let p = path, let h = head {
            results.append(WorktreeInfo(path: p, branch: branch, head: h, bare: bare))
        }
        return results
    }
}
