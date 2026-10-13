import Foundation
import KouenCore
import KouenSettings

/// A tab sitting on a feature branch in a folder other tabs share — the situation that used to
/// be "fixed" by silently moving the tab. Now it is only surfaced; the user decides.
struct WorktreeIsolationNotice: Equatable, Sendable {
    let tabID: TabID
    let branch: String
    /// Other un-isolated tabs in the same project folder (always >= 1).
    let sharingTabCount: Int

    var message: String {
        let others = sharingTabCount == 1 ? "1 other tab" : "\(sharingTabCount) other tabs"
        return "This tab is on `\(branch)` and shares the folder with \(others)"
    }
}

/// Observes branch changes and OFFERS a worktree for isolation — it never acts on its own.
///
/// Tabs that share one folder share one branch; that is how git works, not a bug. The previous
/// version "fixed" the per-tab branch display by running `git checkout <base>` in the shared
/// primary tree and `cd`-ing the tab into a new worktree, unprompted. That moved the folder under
/// every other tab, agent and dev server using it (agent commits landed on `main`; a dev server
/// ended up serving a stale merged branch). Now a branch change only publishes a notice; the
/// isolate path below runs solely from `isolate(tabID:completion:)`, i.e. an explicit click.
@MainActor
final class WorktreeAutoIsolateService {
    static let shared = WorktreeAutoIsolateService()
    /// Posted whenever the set of pending notices changes; views re-read `notice(for:)`.
    static let noticesDidChange = Notification.Name("KouenWorktreeIsolationNoticesDidChange")

    private let manager = WorktreeManager()
    private var observation: NSObjectProtocol?
    private var inFlightRepos: Set<String> = []
    private(set) var notices: [TabID: WorktreeIsolationNotice] = [:]
    /// "<tabID>|<branch>" the user dismissed — a poll must not resurrect it for the same branch.
    private var dismissed: Set<String> = []

    private init() {}

    func start() {
        observation = NotificationCenter.default.addObserver(
            forName: Notification.Name("KouenActiveTabGitBranchDidChange"),
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refreshNotices() }
        }
    }

    func notice(for tabID: TabID) -> WorktreeIsolationNotice? { notices[tabID] }

    func dismiss(tabID: TabID) {
        guard let notice = notices[tabID] else { return }
        dismissed.insert(Self.dismissKey(notice))
        refreshNotices()
    }

    // MARK: - Decision (pure, no git, no IPC)

    /// The notice a tab should show, or nil. `tabs` is every tab in the snapshot; sharing is
    /// decided by project folder, not exact cwd, so a tab in `src/` still counts as sharing.
    /// Never touches git or the daemon — the whole point is that a branch change is observed only.
    nonisolated static func notice(
        for tab: Tab, among tabs: [Tab], projectRoot: (String) -> String
    ) -> WorktreeIsolationNotice? {
        guard let branch = tab.gitBranch, !branch.isEmpty,
              !WorktreeManager.protectedBranches.contains(branch),
              tab.worktreePath == nil,
              !tab.cwd.contains("/\(WorktreeManager.worktreeDir)/")
        else { return nil }
        let root = projectRoot(tab.cwd)
        let sharing = tabs.filter {
            $0.id != tab.id && $0.worktreePath == nil
                && !$0.cwd.contains("/\(WorktreeManager.worktreeDir)/")
                && projectRoot($0.cwd) == root
        }.count
        guard sharing >= 1 else { return nil }
        return WorktreeIsolationNotice(tabID: tab.id, branch: branch, sharingTabCount: sharing)
    }

    private static func dismissKey(_ notice: WorktreeIsolationNotice) -> String {
        "\(notice.tabID.uuidString)|\(notice.branch)"
    }

    /// Recomputes every tab's notice from the snapshot. Doing the whole set (not just the tabs
    /// that changed) is what clears stale notices: branch back to main, tab closed, tab isolated,
    /// or the other sharers gone.
    private func refreshNotices() {
        let tabs = SessionCoordinator.shared.snapshot.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }
        var next: [TabID: WorktreeIsolationNotice] = [:]
        for tab in tabs {
            guard let notice = Self.notice(for: tab, among: tabs, projectRoot: KouenDesign.projectGroupRootPath(for:)),
                  !dismissed.contains(Self.dismissKey(notice))
            else { continue }
            next[tab.id] = notice
        }
        guard next != notices else { return }
        notices = next
        NotificationCenter.default.post(name: Self.noticesDidChange, object: nil)
    }

    // MARK: - Explicit isolate (user clicked the notice action)

    /// Isolates `tabID` into its own worktree: frees the branch in the shared tree, creates
    /// `.kouen-worktrees/<slug>`, `cd`s that tab into it. Reached only from the notice button.
    /// `completion(false)` means nothing was changed (dirty tree, not at repo root, git failed).
    func isolate(tabID: TabID, completion: @escaping @MainActor (Bool) -> Void) {
        let coord = SessionCoordinator.shared
        guard let tab = coord.snapshot.workspaces.flatMap({ $0.sessions.flatMap(\.tabs) }).first(where: { $0.id == tabID }),
              let branch = tab.gitBranch, !branch.isEmpty,
              !WorktreeManager.protectedBranches.contains(branch),
              tab.worktreePath == nil
        else { return completion(false) }

        let cwd = tab.cwd
        let surfaceID = tab.rootPane.allSurfaceIDs().first

        // Git work runs off-main; one in flight per repo so a double click can't race two
        // `git worktree add` calls for the same branch.
        guard inFlightRepos.insert(cwd).inserted else { return completion(false) }
        let manager = manager

        Task.detached(priority: .utility) { [weak self] in
            let prepared = Self.prepareWorktree(cwd: cwd, branch: branch, manager: manager)
            await MainActor.run {
                guard let self else { return }
                self.inFlightRepos.remove(cwd)
                guard let prepared else { return completion(false) }
                if let surfaceID {
                    coord.requestDaemon(.sendData(
                        surfaceID: surfaceID.uuidString,
                        data: Data(("cd \(prepared.path)\r").utf8),
                        origin: .automation
                    ))
                }
                coord.requestDaemon(.setTabWorktree(tabID: tabID, worktreePath: prepared.path, parentRepoPath: cwd, taskName: prepared.featureSlug))
                // A worktree created here needs its own deps, same as an explicit one.
                if prepared.isNew {
                    ProjectConfig.launchSetupScript(parentRepoPath: cwd, worktreePath: prepared.path)
                }
                completion(true)
            }
        }
    }

    struct PreparedWorktree: Sendable {
        let path: String
        let featureSlug: String?
        /// False when a feature's canonical worktree already existed and was reused.
        let isNew: Bool
    }

    /// Blocking git half of `isolate`: returns the worktree to move the tab into, or nil when the
    /// tab must stay where it is.
    nonisolated private static func prepareWorktree(cwd: String, branch: String, manager: WorktreeManager) -> PreparedWorktree? {
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
            return PreparedWorktree(path: canonicalPath, featureSlug: matchingFeature?.slug, isNew: false)
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
        return PreparedWorktree(path: created, featureSlug: matchingFeature?.slug, isNew: true)
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
