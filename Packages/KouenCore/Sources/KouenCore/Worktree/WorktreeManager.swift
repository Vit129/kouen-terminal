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
        public let baseBranch: String?

        public init(path: String, branch: String?, head: String, bare: Bool, baseBranch: String? = nil) {
            self.path = path
            self.branch = branch
            self.head = head
            self.bare = bare
            self.baseBranch = baseBranch
        }
    }

    /// Divergence between a branch and its base branch.
    public struct Divergence: Sendable, Equatable {
        public let ahead: Int
        public let behind: Int

        public init(ahead: Int, behind: Int) {
            self.ahead = ahead
            self.behind = behind
        }
    }

    nonisolated(unsafe) private static var _scanGeneration: Int = 0
    private static let generationLock = NSLock()

    /// Monotonic generation counter bumped whenever worktrees are created or removed.
    public static var scanGeneration: Int {
        generationLock.lock()
        defer { generationLock.unlock() }
        return _scanGeneration
    }

    public static func bumpScanGeneration() {
        generationLock.lock()
        defer { generationLock.unlock() }
        _scanGeneration += 1
    }

    public init() {}

    // MARK: - Create

    /// Creates an isolated git worktree for a session — the single primitive behind every
    /// worktree Kouen creates. All worktrees land in `<repoPath>/.kouen-worktrees/<sessionID>/`.
    ///
    /// ## Why Kouen creates worktrees
    /// Each isolated session needs an independent HEAD/branch so that concurrent agent sessions
    /// (or a session working on a feature branch) don't fight over the main working tree's
    /// checkout. A git worktree gives each session its own checked-out directory sharing the
    /// same `.git` object store — cheap isolation without a full clone.
    ///
    /// ## Three callers trigger this (search for `.create(`):
    /// 1. `WorktreeAutoIsolateService.isolate(...)` — REACTIVE. Fires when a tab's git branch
    ///    changes to a non-default branch (not main/master/develop). Passes `branch: nil` →
    ///    a `--detach` worktree pinned to `baseRef` (the branch tip), then `cd`s the tab's
    ///    shell into it. This is what silently moves an agent into `.kouen-worktrees/<branch>-N`
    ///    mid-session; the `-N` suffix is appended when a worktree for that branch already exists.
    /// 2. `SessionLifecycleService.addAgentTask(...)` — EXPLICIT. User creates a named task;
    ///    passes `branch: <sanitized-task-name>` → a `-b <branch>` worktree (creates the branch).
    /// 3. `SurfaceRegistry` `.worktreeCreate` IPC — passthrough for daemon clients, forwarding
    ///    whatever `branch`/`baseRef` the caller supplied.
    ///
    /// ## Branch vs detached
    /// - `branch != nil` → `git worktree add -b <branch> <path> [baseRef]` — creates & checks out
    ///   a NEW branch. Fails if the branch already exists (caller surfaces that as an error).
    /// - `branch == nil` → `git worktree add --detach <path> [baseRef]` — detached HEAD at
    ///   `baseRef`. Used by auto-isolate so it never collides with an existing branch name.
    ///
    /// - Parameters:
    ///   - repoPath: The parent repository root (contains `.git`). Worktree is nested under it.
    ///   - sessionID: Short identifier used verbatim as the worktree folder name.
    ///   - branch: Branch to create+checkout. If nil, detached HEAD (no new branch).
    ///   - baseRef: The ref to branch/detach from (e.g. "origin/main"). Defaults to current HEAD.
    /// - Returns: The absolute path to the new worktree, or nil if `git worktree add` failed.
    public func create(
        repoPath: String,
        sessionID: String,
        branch: String? = nil,
        baseRef: String? = nil
    ) -> String? {
        // Worktree dir is always <repoPath>/.kouen-worktrees/<sessionID> — kept inside the repo
        // (gitignored) so it's discoverable via `worktree list` and cleaned up with the repo.
        let worktreePath = (repoPath as NSString)
            .appendingPathComponent(Self.worktreeDir)
            .appending("/\(sessionID)")

        // Build `git worktree add ...`. Order matters: [-b branch | --detach] <path> [baseRef].
        var args = ["worktree", "add"]
        if let branch {
            // New branch mode: `git worktree add -b <branch> <path>` — errors if branch exists.
            args += ["-b", branch, worktreePath]
        } else {
            // Detached mode: `git worktree add --detach <path>` — no branch, HEAD floats at baseRef.
            args += ["--detach", worktreePath]
        }
        if let baseRef {
            // Trailing positional commit-ish the new worktree starts from (branch tip / origin/main).
            args.append(baseRef)
        }

        guard runGit(args, in: repoPath) else { return nil }

        // Lineage tracking (Orca pattern): record base branch in git config
        if let branch {
            let resolvedBase = baseRef ?? defaultBaseBranch(repoPath: repoPath)
            if let resolvedBase {
                _ = runGit(["config", "branch.\(branch).base", resolvedBase], in: repoPath)
            }
        }
        Self.bumpScanGeneration()
        return worktreePath
    }

    // MARK: - Remove

    /// Removes a worktree. Uses `--force` if `force` is true (discards uncommitted changes).
    /// Enforces home-directory and dirty-worktree guards for safety.
    @discardableResult
    public func remove(repoPath: String, worktreePath: String, force: Bool = false) -> Bool {
        // Home directory & path traversal guard: never touch $HOME, root, or path outside worktree dir
        let home = NSHomeDirectory()
        let standardPath = (worktreePath as NSString).standardizingPath
        if standardPath == home || standardPath == "/" || !standardPath.contains("/\(Self.worktreeDir)/") {
            return false
        }

        // Dirty guard: refuse to delete uncommitted changes unless explicitly forced
        if !force && isDirty(worktreePath: worktreePath) {
            return false
        }

        var args = ["worktree", "remove", worktreePath]
        if force { args.append("--force") }
        let ok = runGit(args, in: repoPath)
        if ok {
            Self.bumpScanGeneration()
        }
        return ok
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
        return parseWorktreeList(output, in: repoPath)
    }

    // MARK: - Lineage & Divergence

    /// Resolves the base branch for a given branch in repoPath.
    /// Reads `branch.<branch>.base` git config if present, falling back to `defaultBaseBranch`.
    public func baseBranch(for branch: String, in repoPath: String) -> String? {
        if let configBase = runGitOutput(["config", "--get", "branch.\(branch).base"], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !configBase.isEmpty {
            return configBase
        }
        return defaultBaseBranch(repoPath: repoPath)
    }

    /// Resolves the repository default branch (e.g. "main", "master", "develop").
    public func defaultBaseBranch(repoPath: String) -> String? {
        if let remoteHead = runGitOutput(["symbolic-ref", "--short", "refs/remotes/origin/HEAD"], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !remoteHead.isEmpty {
            return remoteHead.hasPrefix("origin/") ? String(remoteHead.dropFirst("origin/".count)) : remoteHead
        }
        for candidate in ["main", "master", "develop"] {
            if runGit(["rev-parse", "--verify", "refs/heads/\(candidate)"], in: repoPath) {
                return candidate
            }
        }
        return runGitOutput(["branch", "--show-current"], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Measures divergence between `branch` and its `base` branch.
    /// `ahead`: commits on `branch` that `base` does not have.
    /// `behind`: commits on `base` that `branch` does not have.
    public func divergence(repoPath: String, branch: String, base: String) -> Divergence? {
        guard let output = runGitOutput(["rev-list", "--left-right", "--count", "\(base)...\(branch)"], in: repoPath) else {
            return nil
        }
        let parts = output.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.whitespaces)
            .filter { !$0.isEmpty }
        guard parts.count >= 2, let behind = Int(parts[0]), let ahead = Int(parts[1]) else {
            return nil
        }
        return Divergence(ahead: ahead, behind: behind)
    }

    /// Checks whether `branch` has already been merged or squash-merged into `base`.
    public func isMergedOrSquashed(repoPath: String, branch: String, base: String) -> Bool {
        // 1. Ancestor check: normal merge (fast-forward or merge commit)
        if runGit(["merge-base", "--is-ancestor", branch, base], in: repoPath) {
            return true
        }

        // 2. Squash-merge detection via git merge-tree --write-tree
        guard let mergeBase = runGitOutput(["merge-base", base, branch], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !mergeBase.isEmpty else {
            return false
        }

        guard let branchHead = runGitOutput(["rev-parse", "--verify", branch], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), branchHead != mergeBase else {
            return false
        }

        // Branch must have introduced tree changes relative to mergeBase
        guard let branchTree = runGitOutput(["rev-parse", "\(branch)^{tree}"], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !branchTree.isEmpty else {
            return false
        }
        guard let mergeBaseTree = runGitOutput(["rev-parse", "\(mergeBase)^{tree}"], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !mergeBaseTree.isEmpty else {
            return false
        }
        guard branchTree != mergeBaseTree else {
            return false
        }

        guard let baseTree = runGitOutput(["rev-parse", "\(base)^{tree}"], in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !baseTree.isEmpty else {
            return false
        }

        guard let mergeOutput = runGitOutput(["merge-tree", "--write-tree", base, branch], in: repoPath) else {
            return false
        }

        let mergedTree = mergeOutput.components(separatedBy: .newlines).first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return mergedTree == baseTree
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
        let ok = runGit(["worktree", "prune"], in: repoPath)
        if ok {
            Self.bumpScanGeneration()
        }
        return ok
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

    private func parseWorktreeList(_ output: String, in repoPath: String? = nil) -> [WorktreeInfo] {
        var results: [WorktreeInfo] = []
        var path: String?
        var head: String?
        var branch: String?
        var bare = false

        for line in output.components(separatedBy: "\n") {
            if line.hasPrefix("worktree ") {
                // Flush previous entry
                if let p = path, let h = head {
                    let base = (branch != nil && repoPath != nil) ? baseBranch(for: branch!, in: repoPath!) : nil
                    results.append(WorktreeInfo(path: p, branch: branch, head: h, bare: bare, baseBranch: base))
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
            let base = (branch != nil && repoPath != nil) ? baseBranch(for: branch!, in: repoPath!) : nil
            results.append(WorktreeInfo(path: p, branch: branch, head: h, bare: bare, baseBranch: base))
        }
        return results
    }
}
