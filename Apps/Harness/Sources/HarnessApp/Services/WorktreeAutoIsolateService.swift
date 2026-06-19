import Foundation
import HarnessCore

/// Observes branch changes and auto-creates a worktree for isolation when:
/// 1. The session's `harness.json` has `isolateAgents: true`, AND
/// 2. The branch changed to something other than the default branch, AND
/// 3. The session isn't already in a worktree.
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
        // Check harness.json config
        guard let config = ProjectConfig.load(from: cwd), config.isolateAgents == true else { return }

        // Create worktree
        let sessionID = branch.replacingOccurrences(of: "/", with: "-")
        let baseRef = config.baseRef ?? "HEAD"
        guard let wtPath = manager.create(repoPath: cwd, sessionID: sessionID, branch: branch, baseRef: baseRef) else { return }

        // Move session CWD to the new worktree
        if let surfaceID = tab.rootPane.allSurfaceIDs().first {
            coord.requestDaemon(.sendData(
                surfaceID: surfaceID.uuidString,
                data: Data(("cd \(wtPath)\r").utf8)
            ))
        }
    }
}
