import Foundation

/// Turn-based shadow checkpoints for `kouen undo` (P46 Phase 3). Each checkpoint is a git commit
/// object snapshotting the FULL working tree (tracked + untracked, respecting `.gitignore`),
/// built through a TEMPORARY index (`GIT_INDEX_FILE` override) so it never touches the real
/// staging area or the `git stash` list — an agent turn can be checkpointed without disturbing
/// whatever the human has staged. Checkpoints live under `refs/kouen/checkpoints/<session>/<n>`,
/// parented on HEAD, and are pure shadow refs: nothing about them changes the branch, HEAD, or
/// what `git log`/`git status` show unless you explicitly ask (`kouen undo list`).
public struct CheckpointManager: Sendable {
    public struct CheckpointInfo: Sendable, Equatable {
        public let ref: String
        public let turn: Int
        public let commit: String
        public let createdAt: Date
        /// `git diff --stat HEAD..commit` — what this checkpoint actually captured.
        public let diffStat: String
    }

    public static let refNamespace = "refs/kouen/checkpoints"

    public init() {}

    /// Snapshot the current working tree as a new checkpoint, parented on HEAD. Returns nil when
    /// `cwd` isn't a git repo, has no commits yet, or the tree is identical to the most recent
    /// checkpoint (or to HEAD if there isn't one yet) — an unchanged turn creates no noise.
    @discardableResult
    public func create(cwd: String, session: String) -> CheckpointInfo? {
        guard let head = runGitOutput(["rev-parse", "HEAD"], in: cwd)?.trimmed, !head.isEmpty else {
            return nil
        }
        guard let tree = snapshotTree(cwd: cwd) else { return nil }

        let existing = list(cwd: cwd, session: session)
        let baselineCommit = existing.last?.commit ?? head
        guard let baselineTree = runGitOutput(["rev-parse", "\(baselineCommit)^{tree}"], in: cwd)?.trimmed,
              tree != baselineTree
        else { return nil }

        guard let commit = runGitOutput(["commit-tree", tree, "-p", head, "-m", "kouen checkpoint"], in: cwd)?.trimmed,
              !commit.isEmpty
        else { return nil }

        let turn = (existing.last?.turn ?? 0) + 1
        let ref = "\(Self.refNamespace)/\(session)/\(turn)"
        guard runGit(["update-ref", ref, commit], in: cwd) else { return nil }

        let diffStat = runGitOutput(["diff", "--stat", "\(commit)^..\(commit)"], in: cwd) ?? ""
        return CheckpointInfo(ref: ref, turn: turn, commit: commit, createdAt: Date(), diffStat: diffStat)
    }

    /// Every checkpoint for `session`, oldest (turn 1) first.
    public func list(cwd: String, session: String) -> [CheckpointInfo] {
        let pattern = "\(Self.refNamespace)/\(session)"
        guard let output = runGitOutput(
            ["for-each-ref", "--sort=creatordate", "--format=%(refname) %(objectname) %(creatordate:iso-strict)", pattern],
            in: cwd
        ) else { return [] }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFormatterNoFraction = ISO8601DateFormatter()

        return output.split(separator: "\n").compactMap { line -> CheckpointInfo? in
            let parts = line.split(separator: " ", maxSplits: 2).map(String.init)
            guard parts.count == 3,
                  let turn = Int(parts[0].split(separator: "/").last ?? "")
            else { return nil }
            let ref = parts[0], commit = parts[1]
            let createdAt = isoFormatter.date(from: parts[2]) ?? isoFormatterNoFraction.date(from: parts[2]) ?? Date()
            let diffStat = runGitOutput(["diff", "--stat", "\(commit)^..\(commit)"], in: cwd) ?? ""
            return CheckpointInfo(ref: ref, turn: turn, commit: commit, createdAt: createdAt, diffStat: diffStat)
        }
        .sorted { $0.turn < $1.turn }
    }

    /// Full unified diff a checkpoint captured (`commit^..commit`) — what `⌘⌥D`'s Turn Diff
    /// Reviewer shows, as opposed to `CheckpointInfo.diffStat`'s one-line-per-file summary.
    public func fullDiff(_ checkpoint: CheckpointInfo, cwd: String) -> String {
        runGitOutput(["diff", "\(checkpoint.commit)^..\(checkpoint.commit)"], in: cwd) ?? ""
    }

    /// Restore the working tree (tracked files only — matches `git checkout <ref> -- .`
    /// semantics) to `checkpoint`, or the most recent checkpoint when nil. Never moves HEAD or
    /// the current branch; a plain working-tree restore, reversible by checking out HEAD again.
    /// Returns false when there's nothing to restore to, or the restore itself fails (e.g. a
    /// path deleted outside git that `checkout` can't recreate cleanly).
    @discardableResult
    public func restore(cwd: String, session: String, checkpoint: CheckpointInfo? = nil) -> Bool {
        let target = checkpoint ?? list(cwd: cwd, session: session).last
        guard let target else { return false }
        // `git checkout <commit> -- .` restores tracked-file contents from the checkpoint without
        // touching HEAD/branch. Untracked files the checkpoint captured are NOT restored this way
        // (checkout only ever touches tracked paths) — acceptable: undo is a safety net for
        // "agent edited files badly," not a full filesystem snapshot restore.
        return runGit(["checkout", target.commit, "--", "."], in: cwd)
    }

    // MARK: - Private

    /// Build a tree object for the current working tree via a temporary index, never touching
    /// the real one. Seeds from HEAD (so unmodified files aren't rehashed and deletions are
    /// captured) then layers the working tree on top with `add -A`.
    private func snapshotTree(cwd: String) -> String? {
        let tempIndex = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-checkpoint-\(UUID().uuidString).idx").path
        defer { try? FileManager.default.removeItem(atPath: tempIndex) }

        var env = ProcessInfo.processInfo.environment
        env["GIT_INDEX_FILE"] = tempIndex

        guard runGit(["read-tree", "HEAD"], in: cwd, env: env),
              runGit(["add", "-A"], in: cwd, env: env),
              let tree = runGitOutput(["write-tree"], in: cwd, env: env)?.trimmed,
              !tree.isEmpty
        else { return nil }
        return tree
    }

    @discardableResult
    private func runGit(_ args: [String], in directory: String, env: [String: String]? = nil) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        if let env { process.environment = env }
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch { return false }
    }

    private func runGitOutput(_ args: [String], in directory: String, env: [String: String]? = nil) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        if let env { process.environment = env }
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            return String(data: data, encoding: .utf8)
        } catch { return nil }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
