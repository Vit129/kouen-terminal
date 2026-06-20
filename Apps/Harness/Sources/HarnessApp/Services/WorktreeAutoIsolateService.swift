import Foundation
import HarnessCore

/// Observes branch changes and auto-creates a worktree for isolation.
/// Every tab that switches to a non-default branch gets its own worktree
/// so that git probe always returns the correct branch per tab.
@MainActor
final class WorktreeAutoIsolateService {
    static let shared = WorktreeAutoIsolateService()
    private let manager = WorktreeManager()
    private var observation: NSObjectProtocol?
    private static let defaultBranches: Set<String> = ["main", "master", "develop"]

    private init() {}

    func start() {
        observation = NotificationCenter.default.addObserver(
            forName: Notification.Name("HarnessActiveTabGitBranchDidChange"),
            object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.handleBranchChange() }
        }
    }

    private func handleBranchChange() {
        let coord = SessionCoordinator.shared
        guard let tab = coord.snapshot.activeWorkspace?.activeTab else { return }
        guard let branch = tab.gitBranch, !branch.isEmpty else { return }
        guard !Self.defaultBranches.contains(branch) else { return }

        // Already in a worktree? Skip.
        if tab.worktreePath != nil { return }

        let cwd = tab.cwd
        // Check if cwd is a git repo root (not already a worktree subdir)
        guard manager.repoRoot(for: cwd) == cwd else { return }

        // Create worktree for this branch
        let sessionID = branch.replacingOccurrences(of: "/", with: "-")
        let config = ProjectConfig.load(from: cwd)
        let baseRef = config?.baseRef ?? "HEAD"

        // Try to create — if branch already exists in another worktree, just cd to it
        let existingWorktree = manager.list(repoPath: cwd).first { $0.branch == branch }
        let wtPath: String
        if let existing = existingWorktree {
            wtPath = existing.path
        } else {
            guard let created = manager.create(repoPath: cwd, sessionID: sessionID, branch: branch, baseRef: baseRef) else { return }
            wtPath = created
        }

        // Move shell to the worktree path
        if let surfaceID = tab.rootPane.allSurfaceIDs().first {
            coord.requestDaemon(.sendData(
                surfaceID: surfaceID.uuidString,
                data: Data(("cd \(wtPath)\r").utf8)
            ))
        }
    }
}
