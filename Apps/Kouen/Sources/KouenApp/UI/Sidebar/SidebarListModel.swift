import AppKit
import KouenCore
import KouenGit
import Observation

// MARK: - Shared types

struct RepoGitMetadata: Sendable, Equatable {
    let prNumber: Int?
    let prURL: String?
    let prTitle: String?
    let prBaseBranch: String?
    let prChecksStatus: GitHubCLIClient.ChecksStatus?
    /// `nil` when there's no PR at all; `false` covers both real conflicts and GitHub still
    /// computing merge state — P39 G3's merge action treats both the same (don't offer to merge).
    let prMergeable: Bool?
    /// M8: `"APPROVED"` lets `mergePR` offer a checks-waiver — `prMergeable` (no conflicts)
    /// is still always required, never waived.
    let prReviewDecision: String?
    let aheadCount: Int?
    let behindCount: Int?
}

enum SidebarSessionRow: Identifiable {
    case groupHeader(id: String, name: String, rootPath: String?, count: Int, isCollapsed: Bool, status: BoardColumnKind)
    case projectHeader(SidebarProjectHeaderItem)
    case worktreeDisclosure(projectPath: String, count: Int, isExpanded: Bool)
    case sessionItem(SidebarSessionCardItem)
    case divider

    var id: String {
        switch self {
        case let .groupHeader(id, _, _, _, _, _): "group-\(id)"
        case let .projectHeader(p): "proj-\(p.path)"
        case let .worktreeDisclosure(path, _, _): "worktrees-\(path)"
        case let .sessionItem(s): "sess-\(s.id)"
        case .divider: "divider"
        }
    }
}

struct SidebarProjectHeaderItem: Identifiable, Sendable {
    let path: String
    let name: String
    let categoryID: String?
    let hasWorktrees: Bool
    let sessionsCount: Int
    let isCollapsed: Bool
    /// The project's folder no longer exists (moved/renamed/deleted) — offer Relocate/Remove.
    var isMissing: Bool = false

    var id: String { path }
}

struct SidebarSessionCardItem: Identifiable, Sendable {
    let id: String
    let projectPath: String
    let categoryID: String?
    let title: String
    let branch: String
    let subtitle: String?
    let isRunning: Bool
    let isSelected: Bool
    let isDirty: Bool
    let sessionID: SessionID?
    let worktreePath: String?
    let agentKind: AgentKind?
    var detectedAgents: [AgentSnapshot] = []
    let subagentsCount: Int
    let localhostPort: Int?
    var isPrimaryCheckout = false
    var lastActivityAt: Date? = nil
}

struct SidebarWorktreeEntry: Sendable, Equatable, Hashable {
    let path: String
    let head: String
    let branch: String
    let isMain: Bool
    let isLocked: Bool
    var baseBranch: String = "main"
    var aheadCount: Int? = nil
    var behindCount: Int? = nil
    var isMerged: Bool = false
    var lastActivityAt: Date? = nil
}

// MARK: - Observable model

@Observable @MainActor
final class SidebarListModel {
    var rows: [SidebarSessionRow] = []
    var activeSessionID: SessionID?
    var activeWorkspaceID: WorkspaceID?
    private(set) var sessions: [SessionGroup] = []
    private var isRebuilding = false

    var projectStore: ProjectStore?
    var gitStatuses: [String: ProjectGitStatus] = [:]

    var collapsedGroups = Set<String>()
    var collapsedProjects = Set<String>()
    private var isProjectSearchActive = false
    private(set) var projectReveal: (id: UUID, path: String)?
    private var repositoryRootsByFolder: [String: String] = [:]
    private var expandedWorktreeGroups = Set<String>()
    private(set) var projectWorktrees: [String: [SidebarWorktreeEntry]] = [:]
    var pinnedRepos: Set<String> = {
        let array = UserDefaults.standard.stringArray(forKey: "kouen.sidebar.pinnedRepos") ?? []
        return Set(array)
    }()
    private var repoRootCache: [String: (repoRoot: String?, fetchedAt: Date)] = [:]
    private var repoRootUpdatesInProgress: Set<String> = []
    // Stored as var so @Observable tracks mutations for badge re-renders
    @ObservationIgnored private var gitMetadataCache: [String: (metadata: RepoGitMetadata, fetchedAt: Date)] = [:]
    @ObservationIgnored private var gitMetadataUpdatesInProgress: Set<String> = []
    private var lastWorktreeFetchTime: [String: Date] = [:]
    /// Reflog/worktree-dir mtimes seen at the last `git worktree list` per repo; unchanged → skip.
    private var lastWorktreeSignature: [String: [Date]] = [:]
    @ObservationIgnored private var pendingRebuild: Task<Void, Never>?

    private var gitStatusFetchedAt: [String: Date] = [:]
    private var gitStatusFetchInProgress: Set<String> = []
    private static let gitStatusTTL: TimeInterval = 60.0

    // MARK: - Main update

    func update(from snapshot: SessionSnapshot) {
        let newSessions = snapshot.activeWorkspace?.sessions ?? []
        let newActiveSessionID = snapshot.activeWorkspace?.activeSessionID
        let newActiveWorkspaceID = snapshot.activeWorkspaceID

        if newSessions == sessions,
           newActiveSessionID == activeSessionID,
           newActiveWorkspaceID == activeWorkspaceID {
            return
        }

        sessions = newSessions
        activeSessionID = newActiveSessionID
        activeWorkspaceID = newActiveWorkspaceID

        registerSessionProjects()
        pruneCachesIfNeeded()
        rebuildRows()
    }

    private func pruneCachesIfNeeded() {
        let now = Date()
        if repoRootCache.count > 100 {
            repoRootCache = repoRootCache.filter { now.timeIntervalSince($0.value.fetchedAt) < 300 }
        }
        if gitMetadataCache.count > 100 {
            gitMetadataCache = gitMetadataCache.filter { now.timeIntervalSince($0.value.fetchedAt) < 300 }
        }
        if gitStatusFetchedAt.count > 100 {
            gitStatusFetchedAt = gitStatusFetchedAt.filter { now.timeIntervalSince($0.value) < 300 }
        }
        if lastWorktreeFetchTime.count > 100 {
            lastWorktreeFetchTime = lastWorktreeFetchTime.filter { now.timeIntervalSince($0.value) < 300 }
        }
    }

    // MARK: - Collapse toggles

    func toggleCollapse(id: String) {
        if collapsedGroups.contains(id) {
            collapsedGroups.remove(id)
        } else {
            collapsedGroups.insert(id)
        }
        rebuildRows()
    }

    func toggleCollapse(rootPath: String) {
        toggleCollapse(id: rootPath)
    }

    func toggleProjectCollapse(path: String) {
        if collapsedProjects.contains(path) {
            collapsedProjects.remove(path)
        } else {
            collapsedProjects.insert(path)
        }
        rebuildRows()
    }

    func revealProject(_ entry: ProjectEntry) {
        if let categoryID = entry.categoryID {
            collapsedGroups.remove(categoryID)
        }
        projectReveal = (UUID(), entry.path)
        rebuildRows()
    }

    /// Returns the path to add, or reveals the existing row in its original category.
    func projectPathForAdd(_ path: String) async -> String? {
        let projectPath = await Task.detached(priority: .utility) {
            ProjectStore.repositoryProjectPath(path)
        }.value
        if let entry = projectStore?.project(at: projectPath) {
            revealProject(entry)
            return nil
        }
        return projectPath
    }

    func setProjectSearchActive(_ active: Bool) {
        guard isProjectSearchActive != active else { return }
        isProjectSearchActive = active
        rebuildRows()
    }

    func togglePinRepo(rootPath: String) {
        if pinnedRepos.contains(rootPath) {
            pinnedRepos.remove(rootPath)
        } else {
            pinnedRepos.insert(rootPath)
        }
        UserDefaults.standard.set(Array(pinnedRepos), forKey: "kouen.sidebar.pinnedRepos")
        rebuildRows()
    }

    func toggleWorktreeCollapse(rootPath: String) {
        if expandedWorktreeGroups.contains(rootPath) {
            expandedWorktreeGroups.remove(rootPath)
        } else {
            expandedWorktreeGroups.insert(rootPath)
        }
        rebuildRows()
    }

    // MARK: - Git metadata (badge data for session rows)

    func gitMetadata(forPath path: String, branch: String) -> RepoGitMetadata? {
        guard !branch.isEmpty else { return nil }
        let key = "\(path)|\(branch)"
        let now = Date()
        if let cached = gitMetadataCache[key], now.timeIntervalSince(cached.fetchedAt) < 60.0 {
            return cached.metadata
        }
        if gitMetadataUpdatesInProgress.insert(key).inserted {
            Task {
                let metadata = await self.fetchGitMetadata(for: path, branch: branch)
                self.gitMetadataCache[key] = (metadata: metadata, fetchedAt: Date())
                self.gitMetadataUpdatesInProgress.remove(key)
                self.scheduleRebuild()
            }
        }
        return gitMetadataCache[key]?.metadata
    }

    // MARK: - Worktrees

    func updateWorktrees(force: Bool = false) {
        let paths = Set(sessions.map { repoRootForSession($0) })
            .union(projectStore?.projects.map(\.path) ?? [])
        let rootPaths = paths.union(paths.compactMap { path in
            repositoryRootsByFolder[path].map { projectStore?.project(at: $0)?.path ?? $0 }
        })
        let now = Date()
        for rootPath in rootPaths {
            if !force, let lastFetch = lastWorktreeFetchTime[rootPath],
               now.timeIntervalSince(lastFetch) < 3.0 { continue }
            lastWorktreeFetchTime[rootPath] = now
            // Snapshots arrive constantly while a pane prints; only spawn git when a worktree's
            // HEAD moved, registrations changed, or a known checkout disappeared from disk.
            let signature = Self.worktreeSignature(rootPath: rootPath)
            let hasMissingWorktree = projectWorktrees[rootPath]?.contains {
                !FileManager.default.fileExists(atPath: $0.path)
            } ?? false
            if !force, !hasMissingWorktree, let signature, signature == lastWorktreeSignature[rootPath] { continue }
            lastWorktreeSignature[rootPath] = signature
            Task {
                let (resolvedPath, worktrees) = await self.fetchWorktrees(for: rootPath)
                let containingRoot = resolvedPath == rootPath ? nil : resolvedPath
                let previousRoot = self.repositoryRootsByFolder[rootPath]
                self.repositoryRootsByFolder[rootPath] = containingRoot
                if previousRoot != containingRoot {
                    self.updateWorktrees()
                    self.scheduleRebuild()
                }
                if let worktrees, self.projectWorktrees[rootPath] != worktrees {
                    self.projectWorktrees[rootPath] = worktrees
                    self.scheduleRebuild()
                }
            }
        }
    }

    /// Refreshes the visible project catalog and forces Git to re-read linked worktrees.
    /// Missing worktree directories are omitted by `fetchWorktrees`; registered primary
    /// projects remain in the catalog so moved repositories can still be reconciled.
    func refreshProjects() async {
        await projectStore?.syncAllWatchedCategories()
        rebuildRows()
        updateWorktrees(force: true)
    }

    // MARK: - Row rebuild

    // Batch concurrent async completions (git metadata, repo root, worktrees) into a
    // single rebuild 80 ms after the last one fires instead of one rebuild per result.
    func scheduleRebuild() {
        pendingRebuild?.cancel()
        pendingRebuild = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 80_000_000)
            guard !Task.isCancelled, let self else { return }
            self.rebuildRows()
        }
    }

    /// Auto-registers each session's repo as a project — only a real repo root (a `.git`
    /// *directory*). `repoRootForSession` falls back to the raw cwd while git is still resolving,
    /// which used to persist worktrees and non-repo folders as phantom projects.
    private func registerSessionProjects() {
        guard let store = projectStore else { return }
        for session in sessions {
            let root = repoRootForSession(session)
            if !root.isEmpty, root != "Other", WorkspaceRepositoryScanner.isPrimaryRepository(root) {
                store.addProject(root)
            }
        }
    }

    private func rebuildRows() {
        guard !isRebuilding else { return }
        isRebuilding = true
        defer { isRebuilding = false }

        registerSessionProjects()

        var newRows: [SidebarSessionRow] = []

        if let store = projectStore, (!store.projects.isEmpty || !store.categories.isEmpty) {
            // Explicit repo entries keep their category even when a stored subfolder comes first.
            let catalog = store.projects.filter { repositoryRootsByFolder[$0.path] == nil }
            var seen = Set(catalog.map { ProjectStore.directoryIdentity($0.path) })
            let inferred = store.projects.compactMap { entry -> ProjectEntry? in
                guard let root = repositoryRootsByFolder[entry.path],
                      !store.pendingReconciliationPaths.contains(entry.path),
                      seen.insert(ProjectStore.directoryIdentity(root)).inserted else { return nil }
                var projected = entry
                projected.path = root
                return projected
            }
            // Grouped by user-defined categories (e.g. "Personal")
            for category in store.categories {
                let catProjects = store.projects(inCategory: category.id, revealing: projectReveal?.path)
                    .filter { repositoryRootsByFolder[$0.path] == nil }
                    + inferred.filter { $0.categoryID == category.id }
                let isCollapsed = collapsedGroups.contains(category.id) && !isProjectSearchActive
                newRows.append(.groupHeader(
                    id: category.id,
                    name: category.name,
                    rootPath: nil,
                    count: catProjects.count,
                    isCollapsed: isCollapsed,
                    status: .idle
                ))
                if !isCollapsed {
                    for project in catProjects.sorted(by: { $0.path.lowercased() < $1.path.lowercased() }) {
                        appendProjectAndSessions(project, into: &newRows)
                    }
                }
            }

            // Standalone / Uncategorized projects
            let uncategorized = store.projects(inCategory: nil, revealing: projectReveal?.path)
                .filter { repositoryRootsByFolder[$0.path] == nil }
                + inferred.filter { $0.categoryID == nil }
            if !store.categories.isEmpty && !uncategorized.isEmpty {
                newRows.append(.divider)
            }
            for project in uncategorized.sorted(by: { $0.path.lowercased() < $1.path.lowercased() }) {
                appendProjectAndSessions(project, into: &newRows)
            }
        } else {
            // Standalone repos without groups: render directly as project headers
            var seenProjects = Set<String>()
            for session in sessions {
                let sessionPath = repoRootForSession(session)
                let rootPath = repositoryRootsByFolder[sessionPath] ?? sessionPath
                guard !rootPath.isEmpty, rootPath != "Other",
                      seenProjects.insert(ProjectStore.directoryIdentity(rootPath)).inserted else { continue }
                let entry = ProjectEntry(path: rootPath, categoryID: nil)
                appendProjectAndSessions(entry, into: &newRows)
            }
        }

        rows = newRows
    }

    private func appendProjectAndSessions(_ project: ProjectEntry, into result: inout [SidebarSessionRow], preferredSession: SessionGroup? = nil) {

        // 1. Gather all active sessions belonging to this project
        let matchingSessions: [SessionGroup]
        if let preferred = preferredSession {
            matchingSessions = [preferred]
        } else {
            matchingSessions = sessions.filter { sess in
                if repoRootForSession(sess) == project.path { return true }
                return sess.tabs.contains { tab in
                    tab.cwd == project.path || tab.cwd.hasPrefix(project.path + "/")
                        || tab.parentRepoPath == project.path
                }
            }
        }

        // 2. Gather non-main worktrees for this project
        let discoveredWorktrees = projectWorktrees[project.path]
        let rawWorktrees = discoveredWorktrees ?? []
        let extraWorktrees = rawWorktrees.filter { wt in
            guard !wt.isMain else { return false }
            return !matchingSessions.contains { sess in
                sess.tabs.contains { $0.cwd == wt.path || $0.cwd.hasPrefix(wt.path + "/") }
            }
        }

        let hasWorktrees = rawWorktrees.contains { !$0.isMain }
        let isCollapsed = collapsedProjects.contains(project.path) && !isProjectSearchActive
        let headerItem = SidebarProjectHeaderItem(
            path: project.path,
            name: ProjectGroupResolver.pathDisplayName(project.path),
            categoryID: project.categoryID,
            hasWorktrees: hasWorktrees,
            sessionsCount: matchingSessions.count,
            isCollapsed: isCollapsed,
            isMissing: !FileManager.default.fileExists(atPath: project.path)
        )
        result.append(.projectHeader(headerItem))

        guard !isCollapsed else { return }

        let primary = rawWorktrees.first(where: \.isMain)
        let primaryPath = primary?.path ?? project.path
        let primarySessions = matchingSessions.filter { session in
            guard let tab = session.activeTab else { return false }
            if let worktreePath = tab.worktreePath { return worktreePath == primaryPath }
            return (tab.cwd == primaryPath || tab.cwd.hasPrefix(primaryPath + "/"))
                && !rawWorktrees.contains { worktree in
                    !worktree.isMain && (tab.cwd == worktree.path || tab.cwd.hasPrefix(worktree.path + "/"))
                }
        }
        // Wait for discovery before claiming this path is a primary checkout.
        let showsPrimaryCheckout = discoveredWorktrees != nil || headerItem.isMissing
        let primarySession = showsPrimaryCheckout
            ? primarySessions.first { $0.id == activeSessionID } ?? primarySessions.first : nil
        let primaryBranch = [primary?.branch, primarySession?.activeTab?.gitBranch, gitStatuses[project.path]?.branch]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? "main"

        if primarySession == nil, showsPrimaryCheckout {
            result.append(.sessionItem(SidebarSessionCardItem(
                id: "idle-\(project.path)",
                projectPath: project.path,
                categoryID: project.categoryID,
                title: primaryBranch,
                branch: primaryBranch,
                subtitle: nil,
                isRunning: false,
                isSelected: false,
                isDirty: false,
                sessionID: nil,
                worktreePath: nil,
                agentKind: nil,
                subagentsCount: 0,
                localhostPort: nil,
                isPrimaryCheckout: true,
                lastActivityAt: primary?.lastActivityAt
            )))
            if primary == nil, !headerItem.isMissing { fetchGitStatusForProject(project.path) }
        }

        // Put the primary checkout first and keep every other session selectable.
        let orderedSessions = [primarySession].compactMap { $0 }
            + matchingSessions.filter { $0.id != primarySession?.id }
        for sess in orderedSessions {
            let tab = sess.activeTab ?? sess.tabs.first
            let isPrimary = sess.id == primarySession?.id
            let tabBranch = tab?.gitBranch?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let branch = isPrimary ? primaryBranch : (tabBranch.isEmpty ? "main" : tabBranch)
            let title = isPrimary ? branch : (tab?.taskName ?? branch)
            let isDirty = gitStatuses[sess.id.uuidString]?.isDirty ?? false
            let port = tab?.listeningPorts.first ?? sess.tabs.compactMap({ $0.listeningPorts.min() }).min()
            let isSelected = sess.id == activeSessionID

            var lastActivityAt = isPrimary ? primary?.lastActivityAt : nil
            var uniqueAgents: [AgentSnapshot] = []
            for t in sess.tabs {
                for agent in t.allDetectedAgents {
                    if isPrimary, agent.lastActivityAt > (lastActivityAt ?? .distantPast) {
                        lastActivityAt = agent.lastActivityAt
                    }
                    if !uniqueAgents.contains(where: { $0.kind == agent.kind }) {
                        uniqueAgents.append(agent)
                    }
                }
            }

            let cardItem = SidebarSessionCardItem(
                id: sess.id.uuidString,
                projectPath: project.path,
                categoryID: project.categoryID,
                title: title,
                branch: branch,
                subtitle: tab?.cwd == nil ? nil : KouenDesign.shortenPath(tab!.cwd),
                isRunning: true,
                isSelected: isSelected,
                isDirty: isDirty,
                sessionID: sess.id,
                worktreePath: nil,
                agentKind: tab?.effectiveAgentKind,
                detectedAgents: uniqueAgents,
                subagentsCount: tab?.subagents?.count ?? 0,
                localhostPort: port,
                isPrimaryCheckout: isPrimary,
                lastActivityAt: lastActivityAt
            )
            result.append(.sessionItem(cardItem))
        }

        guard !extraWorktrees.isEmpty else { return }
        let isExpanded = expandedWorktreeGroups.contains(project.path) || isProjectSearchActive
        result.append(.worktreeDisclosure(projectPath: project.path, count: extraWorktrees.count, isExpanded: isExpanded))
        guard isExpanded else { return }

        for wt in extraWorktrees {
            let cardItem = SidebarSessionCardItem(
                id: "wt-\(wt.path)",
                projectPath: project.path,
                categoryID: project.categoryID,
                title: wt.branch,
                branch: wt.branch,
                subtitle: KouenDesign.shortenPath(wt.path),
                isRunning: false,
                isSelected: false,
                isDirty: false,
                sessionID: nil,
                worktreePath: wt.path,
                agentKind: nil,
                subagentsCount: 0,
                localhostPort: nil
            )
            result.append(.sessionItem(cardItem))
        }
    }

    private func fetchGitStatusForProject(_ path: String) {
        let now = Date()
        if let lastFetch = gitStatusFetchedAt[path], now.timeIntervalSince(lastFetch) < Self.gitStatusTTL {
            return
        }
        guard gitStatusFetchInProgress.insert(path).inserted else { return }
        Task { [weak self] in
            let status = await fetchGitStatus(for: path)
            await MainActor.run {
                guard let self else { return }
                self.gitStatusFetchInProgress.remove(path)
                self.gitStatusFetchedAt[path] = Date()
                if let status {
                    self.gitStatuses[path] = status
                    self.scheduleRebuild()
                }
            }
        }
    }

    // MARK: - Helpers

    func repoRootForSession(_ session: SessionGroup) -> String {
        guard let tab = session.activeTab ?? session.tabs.first else { return "Other" }
        if let parentRepoPath = tab.parentRepoPath?.trimmingCharacters(in: .whitespacesAndNewlines),
           !parentRepoPath.isEmpty {
            // Normalize through the same --git-common-dir key as non-worktree tabs of this repo,
            // so a task worktree's session groups with the main repo instead of splitting off.
            return gitRepoRoot(for: parentRepoPath) ?? parentRepoPath
        }
        if let gitRoot = gitRepoRoot(for: tab.cwd) { return gitRoot }
        return tab.cwd.isEmpty ? "Other" : tab.cwd
    }

    private func groupName(forRootPath rootPath: String) -> String {
        KouenDesign.projectGroupDisplayName(forRootPath: rootPath)
    }

    private func gitRepoRoot(for path: String) -> String? {
        let now = Date()
        if let cached = repoRootCache[path], now.timeIntervalSince(cached.fetchedAt) < 60.0 {
            return cached.repoRoot
        }
        if repoRootUpdatesInProgress.insert(path).inserted {
            Task {
                let root = await self.resolveGitRepoRoot(for: path)
                self.repoRootCache[path] = (repoRoot: root, fetchedAt: Date())
                self.repoRootUpdatesInProgress.remove(path)
                self.scheduleRebuild()
            }
        }
        return repoRootCache[path]?.repoRoot
    }

    private func resolveGitRepoRoot(for path: String) async -> String? {
        await Task.detached(priority: .utility) {
            GitService.shared.resolveRepoRoot(for: path)
        }.value
    }

    private func highestBoardStatus(for sessions: [SessionGroup]) -> BoardColumnKind {
        func priority(_ s: BoardColumnKind) -> Int {
            switch s {
            case .needsAttention: 4
            case .running: 3
            case .done: 2
            case .error: 1
            case .idle: 0
            }
        }
        var highest = BoardColumnKind.idle
        for session in sessions {
            for tab in session.tabs {
                let status = BoardModel.columnKind(for: tab)
                if priority(status) > priority(highest) { highest = status }
            }
        }
        return highest
    }

    // MARK: - Async git fetches

    private static let knownGhPaths = [
        "/opt/homebrew/bin/gh",
        "/usr/local/bin/gh",
        "/usr/bin/gh",
        ("~/.local/bin/gh" as NSString).expandingTildeInPath
    ]
    private static var resolvedGhPath: String?
    private static var hasAttemptedGhResolve = false

    private static func resolveGhPath() async -> String? {
        if hasAttemptedGhResolve { return resolvedGhPath }
        hasAttemptedGhResolve = true
        let path = GitHubCLIClient.cachedGhPath ?? knownGhPaths.first(where: { FileManager.default.fileExists(atPath: $0) }) ?? ProcessRunner.resolveBinary("gh")
        resolvedGhPath = path
        return path
    }

    private func fetchHasRemote(for path: String) async -> Bool {
        await Task.detached(priority: .utility) {
            GitService.shared.hasRemote(for: path)
        }.value
    }

    private func fetchGitMetadata(for path: String, branch: String) async -> RepoGitMetadata {
        let empty = RepoGitMetadata(prNumber: nil, prURL: nil, prTitle: nil, prBaseBranch: nil, prChecksStatus: nil, prMergeable: nil, prReviewDecision: nil, aheadCount: nil, behindCount: nil)
        guard await Self.resolveGhPath() != nil, await fetchHasRemote(for: path) else { return empty }

        return await Task.detached(priority: .utility) {
            let pr = GitHubCLIClient().prForCurrentBranch(repoPath: path)
            let prNumber = pr?.number
            let prURL = pr?.url
            let prTitle = pr?.title
            let prBaseBranch = pr?.baseRefName
            let prChecksStatus = pr?.checksStatus
            let prMergeable = pr.map { $0.mergeable }
            let prReviewDecision = pr?.reviewDecision

            let aheadBehind = GitService.shared.aheadBehindCount(for: path, upstreamBranch: branch)
            let aheadCount = aheadBehind?.ahead
            let behindCount = aheadBehind?.behind

            return RepoGitMetadata(prNumber: prNumber, prURL: prURL, prTitle: prTitle, prBaseBranch: prBaseBranch, prChecksStatus: prChecksStatus, prMergeable: prMergeable, prReviewDecision: prReviewDecision, aheadCount: aheadCount, behindCount: behindCount)
        }.value
    }

    /// Modification dates of everything `git worktree list --porcelain` output depends on:
    /// `.git/worktrees` (add/remove) and each HEAD reflog (commit, checkout, reset), in a stable
    /// order. Nil when `.git` is not a directory (a linked worktree), so callers fall back to time.
    nonisolated static func worktreeSignature(rootPath: String, fileManager: FileManager = .default) -> [Date]? {
        let git = URL(fileURLWithPath: rootPath).appendingPathComponent(".git")
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: git.path, isDirectory: &isDir), isDir.boolValue else { return nil }
        func mtime(_ url: URL) -> Date {
            (try? fileManager.attributesOfItem(atPath: url.path)[.modificationDate] as? Date) ?? .distantPast
        }
        let worktreesDir = git.appendingPathComponent("worktrees")
        let names = ((try? fileManager.contentsOfDirectory(atPath: worktreesDir.path)) ?? []).sorted()
        return [mtime(worktreesDir), mtime(git.appendingPathComponent("logs/HEAD"))]
            + names.map { mtime(worktreesDir.appendingPathComponent($0).appendingPathComponent("logs/HEAD")) }
    }

    private func fetchWorktrees(for path: String) async -> (String, [SidebarWorktreeEntry]?) {
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return (path, []) }
        return await Task.detached(priority: .utility) {
            let rootPath = ProjectStore.repositoryProjectPath(path)
            guard rootPath == path else { return (rootPath, nil) }
            let infos = GitService.shared.listWorktrees(for: rootPath)
            guard !infos.isEmpty else { return (rootPath, []) }
            let manager = WorktreeManager()
            let worktrees = infos.enumerated().compactMap { index, wt -> SidebarWorktreeEntry? in
                var isDirectory: ObjCBool = false
                guard FileManager.default.fileExists(atPath: wt.path, isDirectory: &isDirectory),
                      isDirectory.boolValue else { return nil }
                let isMain = index == 0
                let branch = wt.branch ?? "detached"
                // HEAD's reflog records local activity including checkout, reset and commit.
                let lastActivityAt = isMain ? ["logs/HEAD", "HEAD"].lazy.compactMap { relativePath in
                    try? FileManager.default.attributesOfItem(atPath: wt.path + "/.git/" + relativePath)[.modificationDate] as? Date
                }.first : nil
                let base = isMain ? "main" : (manager.baseBranch(for: branch, in: rootPath) ?? "main")
                let div = isMain ? nil : manager.divergence(repoPath: rootPath, branch: branch, base: base)
                let isMerged = isMain ? false : manager.isMergedOrSquashed(repoPath: rootPath, branch: branch, base: base)
                return SidebarWorktreeEntry(
                    path: wt.path,
                    head: wt.head,
                    branch: branch,
                    isMain: isMain,
                    isLocked: wt.isLocked,
                    baseBranch: base,
                    aheadCount: div?.ahead,
                    behindCount: div?.behind,
                    isMerged: isMerged,
                    lastActivityAt: lastActivityAt
                )
            }
            return (rootPath, worktrees)
        }.value
    }
}
