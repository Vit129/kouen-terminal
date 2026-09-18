import AppKit
import KouenCore
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
    case sessionItem(SidebarSessionCardItem)
    case divider

    var id: String {
        switch self {
        case let .groupHeader(id, _, _, _, _, _): "group-\(id)"
        case let .projectHeader(p): "proj-\(p.path)"
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
    var collapsedWorktreeGroups = Set<String>() // tracks EXPANDED groups (inverted: default = collapsed)
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
    @ObservationIgnored private var pendingRebuild: Task<Void, Never>?

    // MARK: - Main update

    func update(from snapshot: SessionSnapshot) {
        sessions = snapshot.activeWorkspace?.sessions ?? []
        activeSessionID = snapshot.activeWorkspace?.activeSessionID
        activeWorkspaceID = snapshot.activeWorkspaceID

        if let store = projectStore {
            for session in sessions {
                let root = repoRootForSession(session)
                if !root.isEmpty && root != "Other" {
                    store.addProject(root)
                }
            }
        }
        rebuildRows()
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
        if collapsedWorktreeGroups.contains(rootPath) {
            collapsedWorktreeGroups.remove(rootPath)
        } else {
            collapsedWorktreeGroups.insert(rootPath)
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
        let rootPaths = Set(sessions.map { repoRootForSession($0) })
        let now = Date()
        for rootPath in rootPaths {
            if !force, let lastFetch = lastWorktreeFetchTime[rootPath],
               now.timeIntervalSince(lastFetch) < 3.0 { continue }
            lastWorktreeFetchTime[rootPath] = now
            Task {
                let worktrees = await self.fetchWorktrees(for: rootPath)
                if self.projectWorktrees[rootPath] != worktrees {
                    self.projectWorktrees[rootPath] = worktrees
                    self.scheduleRebuild()
                }
            }
        }
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

    private func rebuildRows() {
        guard !isRebuilding else { return }
        isRebuilding = true
        defer { isRebuilding = false }

        if let store = projectStore {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            for session in sessions {
                let root = repoRootForSession(session)
                if !root.isEmpty && root != "Other" && root != home && !root.hasSuffix("/.git") && (root as NSString).lastPathComponent != ".git" {
                    store.addProject(root)
                }
            }
        }

        var newRows: [SidebarSessionRow] = []

        if let store = projectStore, (!store.projects.isEmpty || !store.categories.isEmpty) {
            // Grouped by user-defined categories (e.g. "Personal")
            for category in store.categories {
                let catProjects = store.projects(inCategory: category.id)
                let isCollapsed = collapsedGroups.contains(category.id)
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
            let uncategorized = store.projects(inCategory: nil)
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
                let rootPath = repoRootForSession(session)
                guard !rootPath.isEmpty, rootPath != "Other", !seenProjects.contains(rootPath) else { continue }
                seenProjects.insert(rootPath)
                let entry = ProjectEntry(path: rootPath, categoryID: nil)
                appendProjectAndSessions(entry, into: &newRows)
            }
        }

        rows = newRows
    }

    private func appendProjectAndSessions(_ project: ProjectEntry, into result: inout [SidebarSessionRow], preferredSession: SessionGroup? = nil) {
        let folderName = (project.path as NSString).lastPathComponent
        let displayName = folderName.isEmpty ? KouenDesign.pathDisplayName(project.path) : folderName

        // 1. Gather all active sessions belonging to this project
        let matchingSessions: [SessionGroup]
        if let preferred = preferredSession {
            matchingSessions = [preferred]
        } else {
            matchingSessions = sessions.filter { sess in
                if repoRootForSession(sess) == project.path { return true }
                return sess.tabs.contains { tab in
                    tab.cwd == project.path || tab.parentRepoPath == project.path || tab.cwd.hasPrefix(project.path + "/")
                }
            }
        }

        // 2. Gather non-main worktrees for this project
        let rawWorktrees = projectWorktrees[project.path] ?? []
        let extraWorktrees = rawWorktrees.filter { wt in
            guard !wt.isMain else { return false }
            return !matchingSessions.contains { sess in
                sess.tabs.contains { $0.cwd == wt.path }
            }
        }

        let hasWorktrees = !rawWorktrees.isEmpty
        let isCollapsed = collapsedProjects.contains(project.path)
        let headerItem = SidebarProjectHeaderItem(
            path: project.path,
            name: displayName,
            categoryID: project.categoryID,
            hasWorktrees: hasWorktrees,
            sessionsCount: matchingSessions.count + extraWorktrees.count,
            isCollapsed: isCollapsed
        )
        result.append(.projectHeader(headerItem))

        guard !isCollapsed else { return }

        // 3. Append active sessions
        for sess in matchingSessions {
            let tab = sess.activeTab ?? sess.tabs.first
            let branch = tab?.gitBranch?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "main"
            let taskName = tab?.taskName
            let title = taskName ?? (branch.isEmpty ? "main" : branch)
            let isDirty = gitStatuses[sess.id.uuidString]?.isDirty ?? false
            let port = tab?.listeningPorts.first ?? sess.tabs.compactMap({ $0.listeningPorts.min() }).min()
            let isSelected = sess.id == activeSessionID

            var uniqueAgents: [AgentSnapshot] = []
            for t in sess.tabs {
                for agent in t.allDetectedAgents {
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
                branch: branch.isEmpty ? "main" : branch,
                subtitle: tab?.cwd == nil ? nil : KouenDesign.shortenPath(tab!.cwd),
                isRunning: true,
                isSelected: isSelected,
                isDirty: isDirty,
                sessionID: sess.id,
                worktreePath: nil,
                agentKind: tab?.effectiveAgentKind,
                detectedAgents: uniqueAgents,
                subagentsCount: tab?.subagents?.count ?? 0,
                localhostPort: port
            )
            result.append(.sessionItem(cardItem))
        }

        // 4. Append idle worktrees (other tasks/worktrees)
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

        // 5. If no active sessions and no extra worktrees, emit an idle session row "⚪ main"
        // exactly matching pasted-1789655422-D1DABBD7.png!
        if matchingSessions.isEmpty && extraWorktrees.isEmpty {
            let branch = gitStatuses[project.path]?.branch ?? "main"
            let cardItem = SidebarSessionCardItem(
                id: "idle-\(project.path)",
                projectPath: project.path,
                categoryID: project.categoryID,
                title: branch.isEmpty ? "main" : branch,
                branch: branch.isEmpty ? "main" : branch,
                subtitle: nil,
                isRunning: false,
                isSelected: false,
                isDirty: false,
                sessionID: nil,
                worktreePath: nil,
                agentKind: nil,
                subagentsCount: 0,
                localhostPort: nil
            )
            result.append(.sessionItem(cardItem))
            fetchGitStatusForProject(project.path)
        }
    }

    private func fetchGitStatusForProject(_ path: String) {
        guard gitStatuses[path] == nil else { return }
        Task { [weak self] in
            guard let status = await fetchGitStatus(for: path) else { return }
            await MainActor.run {
                guard let self else { return }
                self.gitStatuses[path] = status
                self.scheduleRebuild()
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
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return nil }
        return await Task.detached(priority: .utility) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = ["-C", path, "rev-parse", "--path-format=absolute", "--git-common-dir"]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                if process.terminationStatus == 0,
                   var root = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !root.isEmpty {
                    if root.hasSuffix("/.git") {
                        root = (root as NSString).deletingLastPathComponent
                    }
                    return root
                }
            } catch {}
            return nil
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

    private static var cachedGhPath: String? = {
        let paths = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/usr/bin/gh"]
        for path in paths where FileManager.default.fileExists(atPath: path) { return path }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        p.arguments = ["gh"]
        let pipe = Pipe()
        p.standardOutput = pipe
        do {
            try p.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            p.waitUntilExit()
            if p.terminationStatus == 0,
               let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !path.isEmpty, FileManager.default.fileExists(atPath: path) { return path }
        } catch {}
        return nil
    }()

    private func fetchHasRemote(for path: String) async -> Bool {
        await Task.detached(priority: .utility) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = ["remote"]
            process.currentDirectoryURL = URL(fileURLWithPath: path)
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                if process.terminationStatus == 0 {
                    return !(String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty
                }
            } catch {}
            return false
        }.value
    }

    private func fetchGitMetadata(for path: String, branch: String) async -> RepoGitMetadata {
        let empty = RepoGitMetadata(prNumber: nil, prURL: nil, prTitle: nil, prBaseBranch: nil, prChecksStatus: nil, prMergeable: nil, prReviewDecision: nil, aheadCount: nil, behindCount: nil)
        guard Self.cachedGhPath != nil, await fetchHasRemote(for: path) else { return empty }

        return await Task.detached(priority: .utility) {
            let pr = GitHubCLIClient().prForCurrentBranch(repoPath: path)
            let prNumber = pr?.number
            let prURL = pr?.url
            let prTitle = pr?.title
            let prBaseBranch = pr?.baseRefName
            let prChecksStatus = pr?.checksStatus
            let prMergeable = pr.map { $0.mergeable }
            let prReviewDecision = pr?.reviewDecision

            var aheadCount: Int? = nil
            var behindCount: Int? = nil
            let revProcess = Process()
            revProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            revProcess.arguments = ["rev-list", "--left-right", "--count", "HEAD...origin/\(branch)"]
            revProcess.currentDirectoryURL = URL(fileURLWithPath: path)
            let revPipe = Pipe()
            revProcess.standardOutput = revPipe
            revProcess.standardError = FileHandle.nullDevice
            do {
                try revProcess.run()
                let data = revPipe.fileHandleForReading.readDataToEndOfFile()
                revProcess.waitUntilExit()
                if revProcess.terminationStatus == 0,
                   let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    let parts = output.components(separatedBy: "\t")
                    if parts.count == 2 { aheadCount = Int(parts[0]); behindCount = Int(parts[1]) }
                }
            } catch {}

            return RepoGitMetadata(prNumber: prNumber, prURL: prURL, prTitle: prTitle, prBaseBranch: prBaseBranch, prChecksStatus: prChecksStatus, prMergeable: prMergeable, prReviewDecision: prReviewDecision, aheadCount: aheadCount, behindCount: behindCount)
        }.value
    }

    private func fetchWorktrees(for rootPath: String) async -> [SidebarWorktreeEntry] {
        guard !rootPath.isEmpty, FileManager.default.fileExists(atPath: rootPath) else { return [] }
        return await Task.detached(priority: .utility) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = ["worktree", "list", "--porcelain"]
            process.currentDirectoryURL = URL(fileURLWithPath: rootPath)
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                guard process.terminationStatus == 0 else { return [] }
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let manager = WorktreeManager()
                return output.components(separatedBy: "\n\n").enumerated().compactMap { index, block in
                    let lines = block.components(separatedBy: "\n").filter { !$0.isEmpty }
                    guard let wtLine = lines.first(where: { $0.hasPrefix("worktree ") }),
                          let headLine = lines.first(where: { $0.hasPrefix("HEAD ") }) else { return nil }
                    let worktreePath = String(wtLine.dropFirst("worktree ".count))
                    let head = String(headLine.dropFirst("HEAD ".count))
                    let branchLine = lines.first(where: { $0.hasPrefix("branch ") })
                    let branch = branchLine.map { line -> String in
                        let ref = String(line.dropFirst("branch ".count))
                        return ref.hasPrefix("refs/heads/") ? String(ref.dropFirst("refs/heads/".count)) : ref
                    } ?? "detached"
                    let isLocked = lines.contains { $0 == "locked" || $0.hasPrefix("locked ") }
                    let isMain = index == 0
                    let base = isMain ? "main" : (manager.baseBranch(for: branch, in: rootPath) ?? "main")
                    let div = isMain ? nil : manager.divergence(repoPath: rootPath, branch: branch, base: base)
                    let isMerged = isMain ? false : manager.isMergedOrSquashed(repoPath: rootPath, branch: branch, base: base)
                    return SidebarWorktreeEntry(
                        path: worktreePath,
                        head: head,
                        branch: branch,
                        isMain: isMain,
                        isLocked: isLocked,
                        baseBranch: base,
                        aheadCount: div?.ahead,
                        behindCount: div?.behind,
                        isMerged: isMerged
                    )
                }
            } catch { return [] }
        }.value
    }
}
