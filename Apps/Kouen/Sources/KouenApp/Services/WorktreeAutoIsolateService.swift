import Foundation
import KouenCore
import KouenSettings

/// Observes branch changes and auto-creates a worktree for isolation.
/// Every tab that switches to a non-default branch gets its own worktree
/// so that git probe always returns the correct branch per tab.
@MainActor
final class WorktreeAutoIsolateService {
    static let shared = WorktreeAutoIsolateService()
    private let manager = WorktreeManager()
    private var observation: NSObjectProtocol?
    private var inFlightRepos: Set<String> = []

    private init() {}

    func start() {
        observation = NotificationCenter.default.addObserver(
            forName: Notification.Name("KouenActiveTabGitBranchDidChange"),
            object: nil, queue: .main
        ) { [weak self] note in
            let tabIDs = note.userInfo?["tabIDs"] as? [TabID] ?? []
            Task { @MainActor in self?.handleBranchChange(tabIDs: tabIDs) }
        }
    }

    /// Isolates every tab whose branch changed this poll, not just the focused one — a
    /// background tab (an agent session not currently in view) that switches branch must still
    /// get its own worktree, or its cwd/worktreePath stay pinned to the repo root forever.
    private func handleBranchChange(tabIDs: [TabID]) {
        let coord = SessionCoordinator.shared
        for workspace in coord.snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs where tabIDs.contains(tab.id) {
                    isolate(tab: tab, workspace: workspace)
                }
            }
        }
    }

    private func isolate(tab: Tab, workspace: Workspace) {
        guard let branch = tab.gitBranch, !branch.isEmpty else { return }
        guard !WorktreeManager.protectedBranches.contains(branch) else { return }

        // Already in a worktree? Skip.
        if tab.worktreePath != nil { return }

        let cwd = tab.cwd
        let tabID = tab.id
        let surfaceID = tab.rootPane.allSurfaceIDs().first

        // Git work runs off-main now, so two quick branch-change polls could both pass the
        // "not isolated yet" check and race to create the same worktree — one in flight per repo.
        guard inFlightRepos.insert(cwd).inserted else { return }
        let manager = manager

        Task.detached(priority: .utility) { [weak self] in
            let prepared = Self.prepareWorktree(cwd: cwd, branch: branch, manager: manager)
            await MainActor.run {
                guard let self else { return }
                self.inFlightRepos.remove(cwd)
                guard let (wtPath, featureSlug) = prepared else { return }
                let coord = SessionCoordinator.shared
                if let surfaceID {
                    coord.requestDaemon(.sendData(
                        surfaceID: surfaceID.uuidString,
                        data: Data(("cd \(wtPath)\r").utf8),
                        origin: .automation
                    ))
                }
                coord.requestDaemon(.setTabWorktree(tabID: tabID, worktreePath: wtPath, parentRepoPath: cwd, taskName: featureSlug))
            }
        }
    }

    /// Blocking git half of `isolate`: returns the worktree path (and bound feature slug), or nil
    /// when the tab must stay unisolated.
    nonisolated private static func prepareWorktree(cwd: String, branch: String, manager: WorktreeManager) -> (String, String?)? {
        // Check if cwd is the PARENT repo root (not already inside a worktree).
        guard manager.repoRoot(for: cwd) == cwd else { return nil }
        guard !isInsideWorktree(cwd) else { return nil }

        // Dirty primary tree guard
        guard !manager.isDirty(worktreePath: cwd) else { return nil }

        // P46: Check FeatureStore first to bind to canonical worktree and avoid duplicates!
        let featureStore = FeatureStore()
        let matchingFeature = featureStore.find(branch: branch, repoPath: cwd)

        if let canonicalPath = matchingFeature?.worktreePath,
           FileManager.default.fileExists(atPath: canonicalPath) {
            // Reuse the feature's ONE canonical worktree path
            return (canonicalPath, matchingFeature?.slug)
        }
        let config = ProjectConfig.load(from: cwd)
        let resolvedBaseRef = config?.baseRef ?? manager.defaultBaseBranch(repoPath: cwd) ?? branch
        guard checkoutLocked(ref: resolvedBaseRef, in: cwd) else { return nil }

        let sessionID = matchingFeature?.slug ?? branch.replacingOccurrences(of: "/", with: "-")
        guard let created = manager.create(repoPath: cwd, sessionID: sessionID, branch: branch, baseRef: resolvedBaseRef, checkoutExisting: true) else { return nil }

        // Register/bind the canonical worktree to the feature if present
        if let matchingFeature {
            featureStore.setWorktree(slug: matchingFeature.slug, worktreePath: created)
        }
        return (created, matchingFeature?.slug)
    }

    /// Checks out `ref` (a branch name) in the primary tree at `path` — frees that branch name so
    /// the isolated worktree below can claim it for a real (non-detached) checkout instead of a
    /// `--detach`ed snapshot. Returns false (caller bails, nothing else is touched) on any failure.
    nonisolated private static func checkoutLocked(ref: String, in path: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["checkout", ref]
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch { return false }
    }

    /// Returns true if the path is inside a git linked worktree (not the main working tree).
    /// Uses `git rev-parse --git-common-dir` vs `--git-dir` — if they differ, it's a worktree.
    nonisolated private static func isInsideWorktree(_ path: String) -> Bool {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "--git-dir", "--git-common-dir"]
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return false }
            let output = String(data: data, encoding: .utf8) ?? ""
            let lines = output.split(separator: "\n")
            guard lines.count == 2 else { return false }
            // In a linked worktree, git-dir != git-common-dir
            // e.g. git-dir = /repo/.git/worktrees/xyz, git-common-dir = /repo/.git
            return lines[0] != lines[1]
        } catch { return false }
    }
}
