import AppKit
import HarnessCore

struct RepoGitMetadata: Sendable, Equatable {
    let prNumber: Int?
    let prURL: String?
    let aheadCount: Int?
    let behindCount: Int?
}

/// Left session rail — workspace pill, sessions list, and a quiet footer.
@MainActor
final class HarnessSidebarPanelViewController: NSViewController {
    enum SidebarSessionRow {
        case groupHeader(name: String, rootPath: String, count: Int, isCollapsed: Bool, status: BoardColumnKind)
        case session(SessionGroup)
        case worktreeHeader(rootPath: String, count: Int, isCollapsed: Bool)
        case worktree(SidebarWorktreeEntry, rootPath: String)
        case divider
    }

    private let chromeHeader = SidebarTitlebarHeaderView()
    private let workspaceBar = NSView()
    let workspacePill = WorkspacePillButton()
    /// Collapses the sidebar (⌘\). Lives at the sidebar's top-trailing edge, against
    /// the divider; when the sidebar is collapsed it's gone with it (re-open via ⌘\).
    /// Flat `.plain` style + 30×30 so it matches the neighbouring notification bell.
    private let sidebarToggleButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 30, height: 30))
    private let sidebarTabs = NSSegmentedControl(labels: ["Sessions", "Files"], trackingMode: .selectOne, target: nil, action: nil)
#if HARNESS_ACP
    private let agentChatPanel = AgentChatPanelView()
#endif
    private let sectionHeader = NSView()
    private let sectionLabel = NSTextField(labelWithString: "Sessions")
    let sessionTable = NSTableView()
    let fileTreeView = WorkspaceFileTreeView()
    private let fileViewerVC = FileViewerViewController()
    let gitPanelView = GitPanelView()
    private let footer = NSView()
    /// Opens the Agent Inbox popover (every running agent, waiting first). Stored so
    /// the popover can anchor to it. Created in `setupFooter`.
    private let agentsButton = HarnessDesign.softIconButton(symbol: "sparkles", tooltip: "Agents")
    private var sessionScroll: NSScrollView?
    var workspaces: [Workspace] = []
    var sessions: [SessionGroup] = []
    var activeWorkspaceID: WorkspaceID?
    private var activeSessionID: SessionID?
    private var isProgrammaticSelection = false
    var workspaceDropdown: WorkspaceSwitcherPanelView?
    var workspaceDropdownMonitor: Any?
    private var collapsedGroups = Set<String>()
    var cachedSidebarRows: [SidebarSessionRow] = []
    /// Last session ID sent to fileTreeView so we can detect session changes even
    /// when the CWD is the same (e.g. two sessions sharing the same repo root).
    var lastFileTreeSessionID: SessionID?
    var lastFileTreeGitBranch: String?
    /// Last sessions array passed to refreshMetadata — used to skip rebuild when nothing changed.
    private var lastRefreshedSessions: [SessionGroup] = []
    private var lastRefreshedActiveID: SessionID?
    private var projectWorktrees: [String: [SidebarWorktreeEntry]] = [:]
    private var collapsedWorktreeGroups = Set<String>()
    private var lastWorktreeFetchTime: [String: Date] = [:]

    var pinnedRepos: Set<String> = {
        let array = UserDefaults.standard.stringArray(forKey: "harness.sidebar.pinnedRepos") ?? []
        return Set(array)
    }()
    private var repoRootCache: [String: (repoRoot: String?, fetchedAt: Date)] = [:]
    private var repoRootUpdatesInProgress: Set<String> = []
    private var gitMetadataCache: [String: (metadata: RepoGitMetadata, fetchedAt: Date)] = [:]
    private var gitMetadataUpdatesInProgress: Set<String> = []

    /// Sessions after applying the search filter. Drag-reorder is disabled while a
    /// filter is active (see the data source), so callers that reorder still use the
    /// unfiltered `sessions`.
    private var displayedSessions: [SessionGroup] {
        return sessions
    }

    private func columnKind(for tab: Tab) -> BoardColumnKind {
        if tab.agent?.activity == .awaiting {
            return .needsAttention
        }
        if let exitStatus = tab.exitStatus {
            return exitStatus == 0 ? .done : .error
        }
        let shellNames: Set<String> = ["zsh", "bash", "sh", "fish", "csh", "tcsh", "login"]
        if let cmd = tab.currentCommand, !cmd.isEmpty, !shellNames.contains(cmd.lowercased()) {
            return .running
        }
        return .idle
    }

    private func highestBoardStatus(for sessions: [SessionGroup]) -> BoardColumnKind {
        var highest = BoardColumnKind.idle
        func priority(_ status: BoardColumnKind) -> Int {
            switch status {
            case .needsAttention: return 4
            case .running:        return 3
            case .done:           return 2
            case .error:          return 1
            case .idle:           return 0
            }
        }
        for session in sessions {
            for tab in session.tabs {
                let status = columnKind(for: tab)
                if priority(status) > priority(highest) {
                    highest = status
                }
            }
        }
        return highest
    }

    /// Rebuild `cachedSidebarRows` from the current `displayedSessions` and
    /// `collapsedGroups`. O(N×G) but only called from explicit invalidation
    /// sites, not from every NSTableViewDelegate callback.
    // Cache for repo roots
    private func gitRepoRoot(for path: String) -> String? {
        let now = Date()
        if let cached = repoRootCache[path], now.timeIntervalSince(cached.fetchedAt) < 60.0 {
            return cached.repoRoot
        }
        
        if repoRootUpdatesInProgress.insert(path).inserted {
            Task {
                let root = await resolveGitRepoRoot(for: path)
                await MainActor.run {
                    self.repoRootCache[path] = (repoRoot: root, fetchedAt: Date())
                    self.repoRootUpdatesInProgress.remove(path)
                    self.rebuildSidebarRows()
                    self.sessionTable.reloadData()
                }
            }
        }
        
        return repoRootCache[path]?.repoRoot
    }

    private func resolveGitRepoRoot(for path: String) async -> String? {
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return nil }
        // Use --git-common-dir to get the shared .git dir — this is the same for all
        // worktrees of the same repo, making it a reliable group key.
        // Then derive the repo name from the main worktree's toplevel.
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "rev-parse", "--path-format=absolute", "--git-common-dir"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            if process.terminationStatus == 0,
               let repoRoot = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !repoRoot.isEmpty {
                return repoRoot
            }
        } catch {
            // ignore
        }
        return nil
    }

    private func repoRootForSession(_ session: SessionGroup) -> String {
        guard let tab = session.activeTab ?? session.tabs.first else { return "Other" }
        if let parentRepoPath = tab.parentRepoPath?.trimmingCharacters(in: .whitespacesAndNewlines),
           !parentRepoPath.isEmpty {
            return parentRepoPath
        }
        let path = tab.cwd
        if let gitRoot = gitRepoRoot(for: path) {
            return gitRoot
        }
        return "Other"
    }

    private func groupName(forRootPath rootPath: String) -> String {
        HarnessDesign.projectGroupDisplayName(forRootPath: rootPath)
    }

    private static var cachedGhPath: String? = {
        let paths = [
            "/opt/homebrew/bin/gh",
            "/usr/local/bin/gh",
            "/usr/bin/gh"
        ]
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["gh"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            if process.terminationStatus == 0,
               let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !path.isEmpty,
               FileManager.default.fileExists(atPath: path) {
                return path
            }
        } catch {}
        
        return nil
    }()

    func gitMetadata(forPath path: String, branch: String) -> RepoGitMetadata? {
        guard !branch.isEmpty else { return nil }
        let key = "\(path)|\(branch)"
        let now = Date()
        if let cached = gitMetadataCache[key], now.timeIntervalSince(cached.fetchedAt) < 60.0 {
            return cached.metadata
        }
        
        if gitMetadataUpdatesInProgress.insert(key).inserted {
            Task {
                let metadata = await fetchGitMetadata(for: path, branch: branch)
                await MainActor.run {
                    self.gitMetadataCache[key] = (metadata: metadata, fetchedAt: Date())
                    self.gitMetadataUpdatesInProgress.remove(key)
                    self.rebuildSidebarRows()
                    self.sessionTable.reloadData()
                }
            }
        }
        
        return gitMetadataCache[key]?.metadata
    }

    private func fetchHasRemote(for path: String) async -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["remote"]
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return !output.isEmpty
            }
        } catch {}
        return false
    }

    private func fetchGitMetadata(for path: String, branch: String) async -> RepoGitMetadata {
        guard let ghPath = Self.cachedGhPath else {
            return RepoGitMetadata(prNumber: nil, prURL: nil, aheadCount: nil, behindCount: nil)
        }
        
        let hasRemote = await fetchHasRemote(for: path)
        guard hasRemote else {
            return RepoGitMetadata(prNumber: nil, prURL: nil, aheadCount: nil, behindCount: nil)
        }
        
        // Fetch PR number
        var prNumber: Int? = nil
        let prProcess = Process()
        prProcess.executableURL = URL(fileURLWithPath: ghPath)
        prProcess.arguments = ["pr", "view", "--json", "number,url"]
        prProcess.currentDirectoryURL = URL(fileURLWithPath: path)
        let prPipe = Pipe()
        prProcess.standardOutput = prPipe
        prProcess.standardError = Pipe()
        var prURL: String? = nil
        do {
            try prProcess.run()
            let data = prPipe.fileHandleForReading.readDataToEndOfFile()
            prProcess.waitUntilExit()
            if prProcess.terminationStatus == 0,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let number = json["number"] as? Int {
                prNumber = number
                prURL = json["url"] as? String
            }
        } catch {}
        
        // Fetch Ahead/Behind count
        var aheadCount: Int? = nil
        var behindCount: Int? = nil
        let revProcess = Process()
        revProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        revProcess.arguments = ["rev-list", "--left-right", "--count", "HEAD...origin/\(branch)"]
        revProcess.currentDirectoryURL = URL(fileURLWithPath: path)
        let revPipe = Pipe()
        revProcess.standardOutput = revPipe
        revProcess.standardError = Pipe()
        do {
            try revProcess.run()
            let data = revPipe.fileHandleForReading.readDataToEndOfFile()
            revProcess.waitUntilExit()
            if revProcess.terminationStatus == 0,
               let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !output.isEmpty {
                let parts = output.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }
                if parts.count == 2,
                   let ahead = Int(parts[0]),
                   let behind = Int(parts[1]) {
                    aheadCount = ahead
                    behindCount = behind
                }
            }
        } catch {}
        
        return RepoGitMetadata(prNumber: prNumber, prURL: prURL, aheadCount: aheadCount, behindCount: behindCount)
    }

    private func rebuildSidebarRows() {
        var groupMap: [String: Int] = [:]   // rootPath → index in `groups`
        var groups: [(name: String, rootPath: String, firstIndex: Int, sessions: [SessionGroup])] = []
        for (index, session) in displayedSessions.enumerated() {
            let rootPath = repoRootForSession(session)
            let name = groupName(forRootPath: rootPath)
            if let groupIndex = groupMap[rootPath] {
                groups[groupIndex].sessions.append(session)
            } else {
                groupMap[rootPath] = groups.count
                groups.append((name: name, rootPath: rootPath, firstIndex: index, sessions: [session]))
            }
        }

        let sortedGroups = groups.sorted { g1, g2 in
            let pin1 = pinnedRepos.contains(g1.rootPath)
            let pin2 = pinnedRepos.contains(g2.rootPath)
            if pin1 != pin2 {
                return pin1
            }
            return g1.firstIndex < g2.firstIndex
        }

        var rows: [SidebarSessionRow] = []
        let pinnedGroups = sortedGroups.filter { pinnedRepos.contains($0.rootPath) }
        let unpinnedGroups = sortedGroups.filter { !pinnedRepos.contains($0.rootPath) }

        func appendGroupRows(for group: (name: String, rootPath: String, firstIndex: Int, sessions: [SessionGroup])) {
            let isCollapsed = collapsedGroups.contains(group.rootPath)
            let status = highestBoardStatus(for: group.sessions)
            let header = SidebarSessionRow.groupHeader(name: group.name, rootPath: group.rootPath, count: group.sessions.count, isCollapsed: isCollapsed, status: status)
            rows.append(header)

            if !isCollapsed {
                for session in group.sessions {
                    rows.append(.session(session))
                }
            }
        }

        for group in pinnedGroups {
            appendGroupRows(for: group)
        }

        if !pinnedGroups.isEmpty && !unpinnedGroups.isEmpty {
            rows.append(.divider)
        }

        for group in unpinnedGroups {
            appendGroupRows(for: group)
        }

        cachedSidebarRows = rows
    }

    private func sessionMatches(_ session: SessionGroup, query: String) -> Bool {
        if session.name.lowercased().contains(query) { return true }
        for tab in session.tabs {
            if tab.title.lowercased().contains(query) { return true }
            if tab.cwd.lowercased().contains(query) { return true }
            if HarnessDesign.pathDisplayName(tab.cwd).lowercased().contains(query) { return true }
        }
        return false
    }

    func projectGroupName(for session: SessionGroup) -> String {
        return repoRootForSession(session)
    }

    private func projectGroupRootPath(for session: SessionGroup) -> String {
        return repoRootForSession(session)
    }

    func sessionRow(at tableRow: Int) -> SessionGroup? {
        let rows = cachedSidebarRows
        guard tableRow >= 0, tableRow < rows.count else { return nil }
        if case let .session(session) = rows[tableRow] { return session }
        return nil
    }

    private func rowIndex(for sessionID: SessionID) -> Int? {
        cachedSidebarRows.firstIndex {
            if case let .session(session) = $0 { return session.id == sessionID }
            return false
        }
    }

    func sessionIndex(for sessionID: SessionID) -> Int? {
        sessions.firstIndex { $0.id == sessionID }
    }

    func sessionGroupName(for sessionID: SessionID) -> String? {
        guard let session = sessions.first(where: { $0.id == sessionID }) else { return nil }
        return repoRootForSession(session)
    }

    private func groupActionsMenu(for rootPath: String, name: String) -> NSMenu {
        let menu = NSMenu()
        let isPinned = pinnedRepos.contains(rootPath)
        let pinItem = NSMenuItem(
            title: isPinned ? "Unpin Repo" : "Pin Repo",
            action: #selector(togglePinRepo(_:)),
            keyEquivalent: ""
        )
        pinItem.target = self
        pinItem.representedObject = rootPath
        menu.addItem(pinItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let closeGroup = NSMenuItem(
            title: "Close all sessions in \(name)",
            action: #selector(closeGroupSessionsFromMenu(_:)),
            keyEquivalent: ""
        )
        closeGroup.target = self
        closeGroup.representedObject = rootPath
        menu.addItem(closeGroup)
        
        return menu
    }

    @objc private func togglePinRepo(_ sender: NSMenuItem) {
        guard let rootPath = sender.representedObject as? String else { return }
        if pinnedRepos.contains(rootPath) {
            pinnedRepos.remove(rootPath)
        } else {
            pinnedRepos.insert(rootPath)
        }
        UserDefaults.standard.set(Array(pinnedRepos), forKey: "harness.sidebar.pinnedRepos")
        rebuildSidebarRows()
        sessionTable.reloadData()
    }

    private func selectActiveSessionRowIfVisible(scroll: Bool) {
        guard let activeSessionID,
              let row = rowIndex(for: activeSessionID)
        else {
            isProgrammaticSelection = true
            sessionTable.deselectAll(nil)
            isProgrammaticSelection = false
            return
        }
        isProgrammaticSelection = true
        sessionTable.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        isProgrammaticSelection = false
        if scroll { sessionTable.scrollRowToVisible(row) }
    }

    override func loadView() {
        let root = NSView()
        HarnessDesign.applySidebarChrome(to: root)
        view = root
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChromeHeader()
        setupWorkspaceBar()
        setupSidebarTabs()
        setupSectionHeader()
        setupFooter()
        setupSessionList()
        setupFileTree()
        setupFileViewer()
        setupGitPlaceholder()
#if HARNESS_ACP
        setupAgentPanel()
#endif
        selectSidebarTab(index: 0)
        reload()
        applyChromeColors()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshMetadata),
            name: Notification.Name("HarnessActiveTabGitBranchDidChange"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viViewFileCommand(_:)),
            name: .viViewFileCommand,
            object: nil
        )
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        syncSessionColumnWidth()
    }

    func applyChromeColors() {
        HarnessDesign.applySidebarChrome(to: view)
        HarnessDesign.makeClear(chromeHeader)
        HarnessDesign.makeClear(workspaceBar)
        HarnessDesign.makeClear(gitPanelView)
        HarnessDesign.makeClear(sectionHeader)
        HarnessDesign.makeClear(footer)
        sectionLabel.textColor = HarnessDesign.chrome.textTertiary
        workspacePill.applyChrome()
        
        let sidebarOnRight = SessionCoordinator.shared.settings.sidebarOnRight
        let symbol = sidebarOnRight ? "sidebar.right" : "sidebar.left"
        sidebarToggleButton.setSymbol(symbol, accessibilityDescription: "Toggle sidebar", pointSize: 13, weight: .medium)
        sidebarToggleButton.applyChrome()
        
        dismissWorkspaceDropdown()
        for case let button as SoftIconButton in footer.subviews {
            button.applyChrome()
        }
        sessionTable.reloadData()
    }

    private func setupChromeHeader() {
        chromeHeader.translatesAutoresizingMaskIntoConstraints = false
        HarnessDesign.makeClear(chromeHeader)
        view.addSubview(chromeHeader)
        NSLayoutConstraint.activate([
            chromeHeader.topAnchor.constraint(equalTo: view.topAnchor),
            chromeHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chromeHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chromeHeader.heightAnchor.constraint(equalToConstant: HarnessDesign.titlebarChromeHeight),
        ])
    }

    /// The sidebar header row: the sidebar toggle button on the trailing edge.
    /// Workspaces are deliberately not surfaced here (single active workspace);
    /// the switcher machinery stays dormant so it can be re-enabled later.
    private func setupWorkspaceBar() {
        workspaceBar.translatesAutoresizingMaskIntoConstraints = false
        HarnessDesign.makeClear(workspaceBar)

        sidebarToggleButton.toolTip = "Hide sidebar (⌘\\)"
        sidebarToggleButton.target = self
        sidebarToggleButton.action = #selector(sidebarToggleClicked)
        sidebarToggleButton.translatesAutoresizingMaskIntoConstraints = false
        updateSidebarToggleMenu()

        workspaceBar.addSubview(sidebarToggleButton)
        view.addSubview(workspaceBar)

        NSLayoutConstraint.activate([
            workspaceBar.topAnchor.constraint(equalTo: chromeHeader.bottomAnchor),
            workspaceBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            workspaceBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            workspaceBar.heightAnchor.constraint(equalToConstant: HarnessDesign.workspaceBarHeight),
            // Toggle pinned to the trailing edge (against the divider); 30×30.
            sidebarToggleButton.trailingAnchor.constraint(equalTo: workspaceBar.trailingAnchor, constant: -HarnessDesign.horizontalInset),
            sidebarToggleButton.centerYAnchor.constraint(equalTo: workspaceBar.centerYAnchor),
            sidebarToggleButton.widthAnchor.constraint(equalToConstant: 30),
            sidebarToggleButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    @objc private func sidebarToggleClicked() {
        (view.window?.contentViewController as? MainSplitViewController)?.toggleSidebar()
    }

    private func updateSidebarToggleMenu() {
        let menu = NSMenu()
        let right = SessionCoordinator.shared.settings.sidebarOnRight
        let item = NSMenuItem(title: right ? "Move Sidebar to Left" : "Move Sidebar to Right", action: #selector(toggleSidebarPositionFromMenu), keyEquivalent: "")
        item.target = self
        menu.addItem(item)
        sidebarToggleButton.menu = menu
    }

    @objc func toggleSidebarPositionFromMenu() {
        (view.window?.contentViewController as? MainSplitViewController)?.toggleSidebarPosition()
        updateSidebarToggleMenu()
    }

    private var notificationsDropdown: NotificationDropdownPanelView?
    private var notificationsDropdownMonitor: Any?
    private weak var notificationsDropdownPreviousResponder: NSResponder?

    func showNotificationsDropdown() {
        if notificationsDropdown != nil {
            dismissNotificationsDropdown()
            return
        }
        let coordinator = SessionCoordinator.shared
        let snapshot = coordinator.snapshot
        // Agent notifications first, then board error/needs-attention sessions
        var entries = coordinator.notificationsList()
        let agentTabIDs = Set(entries.map(\.tabID))
        for ws in snapshot.workspaces {
            for session in ws.sessions {
                for tab in session.tabs {
                    guard !agentTabIDs.contains(tab.id) else { continue }
                    let kind = BoardModel.columnKind(for: tab)
                    guard kind == .needsAttention || kind == .error else { continue }
                    let body = kind == .error ? "Exit error" : "Needs attention"
                    let entry = NotificationEntry(
                        workspaceID: ws.id,
                        workspaceName: ws.name,
                        sessionID: session.id,
                        tabID: tab.id,
                        tabTitle: tab.title.isEmpty ? tab.cwd : tab.title,
                        surfaceID: tab.id,
                        agentKind: tab.effectiveAgentKind,
                        body: body
                    )
                    entries.append(entry)
                }
            }
        }
        let dropdown = NotificationDropdownPanelView(
            entries: entries,
            onSelect: { [weak self] entry in
                self?.dismissNotificationsDropdown()
                coordinator.openNotification(entry)
            },
            onClearAll: { [weak self] in
                self?.dismissNotificationsDropdown()
                coordinator.clearAllNotifications()
            },
            onDismiss: { [weak self] in
                self?.dismissNotificationsDropdown()
            }
        )
        dropdown.alphaValue = 0
        dropdown.translatesAutoresizingMaskIntoConstraints = true
        dropdown.layer?.zPosition = 100

        // Float the panel over the window's content view rather than inside the narrow
        // sidebar: anchored to the content view it can use a comfortable fixed width and
        // overhang the terminal, fully visible. It dismisses on any outside click so it
        // needn't track resizes.
        let host = view.window?.contentView ?? view
        let width: CGFloat = 300
        let height = dropdown.preferredHeight
        let originX: CGFloat = 8
        let originY: CGFloat = host.bounds.maxY - 52 - height
        dropdown.frame = NSRect(x: originX, y: originY, width: width, height: height)
        host.addSubview(dropdown)
        notificationsDropdown = dropdown
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            dropdown.animator().alphaValue = 1
        }
        installNotificationsDropdownMonitor()
        // Take first responder so arrow keys / Enter / Escape reach the dropdown.
        // Deferred to the next run-loop turn so the view is fully inserted before
        // makeFirstResponder fires — same pattern used by picker panels elsewhere.
        notificationsDropdownPreviousResponder = view.window?.firstResponder
        DispatchQueue.main.async { [weak self, weak dropdown] in
            guard let self, let dropdown, dropdown.superview != nil else { return }
            self.view.window?.makeFirstResponder(dropdown)
        }
    }

    private func dismissNotificationsDropdown() {
        notificationsDropdown?.removeFromSuperview()
        notificationsDropdown = nil
        if let monitor = notificationsDropdownMonitor {
            NSEvent.removeMonitor(monitor)
            notificationsDropdownMonitor = nil
        }
        if let previous = notificationsDropdownPreviousResponder {
            view.window?.makeFirstResponder(previous)
            notificationsDropdownPreviousResponder = nil
        }
    }

    private func installNotificationsDropdownMonitor() {
        notificationsDropdownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let dropdown = self.notificationsDropdown else { return event }
            let point = dropdown.convert(event.locationInWindow, from: nil)
            if !dropdown.bounds.contains(point) {
                self.dismissNotificationsDropdown()
            }
            return event
        }
    }

    @objc private func agentsButtonClicked() {
        showAgentsInbox()
    }

    private var agentsInbox: AgentInboxPanelView?
    private var agentsInboxMonitor: Any?

    /// Float the Agent Inbox over the window's content view, anchored just above the
    /// footer's agents button. Mirrors `showNotificationsDropdown`'s presentation so the
    /// two panels feel identical; dismisses on any outside click.
    private func showAgentsInbox() {
        if agentsInbox != nil {
            dismissAgentsInbox()
            return
        }
        let coordinator = SessionCoordinator.shared
        let inbox = AgentInboxPanelView(
            agents: coordinator.agentsList(),
            onSelect: { [weak self] agent in
                self?.dismissAgentsInbox()
                coordinator.openAgent(agent)
            }
        )
        inbox.alphaValue = 0
        inbox.translatesAutoresizingMaskIntoConstraints = true
        inbox.layer?.zPosition = 100

        let host = view.window?.contentView ?? view
        let width: CGFloat = 300
        let height = inbox.preferredHeight
        let button = host.convert(agentsButton.bounds, from: agentsButton)
        var originX = button.minX
        originX = min(originX, host.bounds.maxX - width - 8)
        originX = max(8, originX)
        // Footer sits at the bottom; the content view is not flipped (y grows upward), so
        // the panel sits *above* the button when its bottom edge is just above the button.
        let originY = button.maxY + 6
        inbox.frame = NSRect(x: originX, y: originY, width: width, height: height)
        host.addSubview(inbox)
        agentsInbox = inbox
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            inbox.animator().alphaValue = 1
        }
        installAgentsInboxMonitor()
    }

    private func dismissAgentsInbox() {
        agentsInbox?.removeFromSuperview()
        agentsInbox = nil
        if let monitor = agentsInboxMonitor {
            NSEvent.removeMonitor(monitor)
            agentsInboxMonitor = nil
        }
    }

    private func installAgentsInboxMonitor() {
        agentsInboxMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let inbox = self.agentsInbox else { return event }
            let point = inbox.convert(event.locationInWindow, from: nil)
            if !inbox.bounds.contains(point) {
                let buttonPoint = self.agentsButton.convert(event.locationInWindow, from: nil)
                if !self.agentsButton.bounds.contains(buttonPoint) {
                    self.dismissAgentsInbox()
                }
            }
            return event
        }
    }

    private func setupSectionHeader() {
        sectionHeader.translatesAutoresizingMaskIntoConstraints = false
        HarnessDesign.makeClear(sectionHeader)

        sectionLabel.font = HarnessDesign.Typography.sectionLabel
        sectionLabel.stringValue = "SESSIONS"
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false

        sectionHeader.addSubview(sectionLabel)
        view.addSubview(sectionHeader)

        NSLayoutConstraint.activate([
            sectionHeader.topAnchor.constraint(equalTo: sidebarTabs.bottomAnchor),
            sectionHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sectionHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sectionHeader.heightAnchor.constraint(equalToConstant: 24),
            sectionLabel.leadingAnchor.constraint(equalTo: sectionHeader.leadingAnchor, constant: HarnessDesign.horizontalInset),
            sectionLabel.bottomAnchor.constraint(equalTo: sectionHeader.bottomAnchor, constant: -4),
        ])
    }

    private func setupSidebarTabs() {
        sidebarTabs.translatesAutoresizingMaskIntoConstraints = false
        sidebarTabs.selectedSegment = 0
        sidebarTabs.target = self
        sidebarTabs.action = #selector(sidebarTabChanged)
        sidebarTabs.segmentStyle = .rounded
        view.addSubview(sidebarTabs)
        NSLayoutConstraint.activate([
            sidebarTabs.topAnchor.constraint(equalTo: workspaceBar.bottomAnchor, constant: 6),
            sidebarTabs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: HarnessDesign.horizontalInset),
            sidebarTabs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -HarnessDesign.horizontalInset),
            sidebarTabs.heightAnchor.constraint(equalToConstant: 26),
        ])
    }

    private func setupSessionList() {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("session"))
        column.width = HarnessDesign.sidebarWidth
        column.resizingMask = .autoresizingMask
        sessionTable.addTableColumn(column)
        sessionTable.headerView = nil
        sessionTable.backgroundColor = .clear
        sessionTable.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        sessionTable.rowHeight = HarnessDesign.sessionRowHeight
        sessionTable.intercellSpacing = NSSize(width: 0, height: HarnessDesign.rowSpacing)
        sessionTable.selectionHighlightStyle = .none
        sessionTable.focusRingType = .none
        sessionTable.style = .plain
        sessionTable.dataSource = self
        sessionTable.delegate = self
        sessionTable.doubleAction = #selector(sessionDoubleClick)
        sessionTable.target = self
        sessionTable.registerForDraggedTypes([Self.sessionRowPasteboardType])
        sessionTable.draggingDestinationFeedbackStyle = .gap

        let scroll = NSScrollView()
        scroll.documentView = sessionTable
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.scrollerStyle = .overlay
        scroll.autohidesScrollers = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.contentInsets = NSEdgeInsets(top: 2, left: 0, bottom: 6, right: 0)

        sessionScroll = scroll
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: sectionHeader.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: footer.topAnchor),
        ])
    }

    private func setupFileTree() {
        fileTreeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fileTreeView)
        NSLayoutConstraint.activate([
            fileTreeView.topAnchor.constraint(equalTo: sectionHeader.bottomAnchor),
            fileTreeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fileTreeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fileTreeView.bottomAnchor.constraint(equalTo: footer.topAnchor),
        ])
        fileTreeView.onFilePreview = { [weak self] node in
            guard let self, let split = self.view.window?.contentViewController as? MainSplitViewController else { return }
            let coordinator = SessionCoordinator.shared
            let action = coordinator.settings.fileClickAction
            if action == "preview" {
                self.previewFile(path: node.path)
            } else if action == "editor" {
                split.contentVC.openFileTab(path: node.path)
            } else if action == "cat" || action == "vi" || action == "terminalOnly" {
                guard let surfaceID = coordinator.activeSurfaceID else { return }
                let cmd: String
                if action == "cat" {
                    cmd = "cat \(node.path)\r"
                } else if action == "vi" {
                    cmd = "vi \(node.path)\r"
                } else {
                    // terminalOnly does nothing on single click to prevent navigation command spam
                    return
                }
                coordinator.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(cmd.utf8)))
            } else {
                split.contentVC.openFileTab(path: node.path)
            }
        }
    }

    /// Hosted in the same area as the file tree; shown in its place when the
    /// user clicks a file (back button restores the tree).
    private func setupFileViewer() {
        addChild(fileViewerVC)
        let viewerView = fileViewerVC.view
        viewerView.translatesAutoresizingMaskIntoConstraints = false
        viewerView.isHidden = true
        view.addSubview(viewerView)
        NSLayoutConstraint.activate([
            viewerView.topAnchor.constraint(equalTo: sectionHeader.bottomAnchor),
            viewerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewerView.bottomAnchor.constraint(equalTo: footer.topAnchor),
        ])
        fileViewerVC.onBack = { [weak self] in
            guard let self else { return }
            self.fileViewerVC.view.isHidden = true
            self.fileTreeView.isHidden = false
        }
    }

    private func setupGitPlaceholder() {
        view.addSubview(gitPanelView)
        NSLayoutConstraint.activate([
            gitPanelView.topAnchor.constraint(equalTo: sectionHeader.bottomAnchor),
            gitPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gitPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gitPanelView.bottomAnchor.constraint(equalTo: footer.topAnchor),
        ])
    }



#if HARNESS_ACP
    private func setupAgentPanel() {
        agentChatPanel.translatesAutoresizingMaskIntoConstraints = false
        agentChatPanel.isHidden = true
        view.addSubview(agentChatPanel)
        NSLayoutConstraint.activate([
            agentChatPanel.topAnchor.constraint(equalTo: sectionHeader.bottomAnchor),
            agentChatPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            agentChatPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            agentChatPanel.bottomAnchor.constraint(equalTo: footer.topAnchor),
        ])
    }

    private func connectAgentIfNeeded() {
        guard agentSession == nil else { return }
        let registryStore = AgentRegistryStore()
        let configs = registryStore.load()
        guard let config = configs.first(where: { $0.isEnabled }) else {
            agentChatPanel.showEmptyState()
            return
        }
        let client = ACPClient()
        let session = ACPSession(client: client)
        agentSession = session
        agentChatPanel.bind(session: session)
        let cwd = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? FileManager.default.currentDirectoryPath
        Task {
            await session.connect(config: config, cwd: cwd)
        }
    }

    private var agentSession: ACPSession?
#endif

    @objc private func sidebarTabChanged() {
        selectSidebarTab(index: sidebarTabs.selectedSegment)
    }

    /// Switches the sidebar to the Git tab (used by the "Show Git Panel" ⌘G shortcut).
    func selectGitTab() {
        sidebarTabs.selectedSegment = -1
        selectSidebarTab(index: 2)
    }

    /// Switches the sidebar to the Files tab and reveals `path` in the file tree
    /// (expands ancestors, highlights the row, and scrolls to it).
    func selectFilesTab(revealPath path: String) {
        sidebarTabs.selectedSegment = 1
        selectSidebarTab(index: 1)
        // Ensure the tree is shown, not the inline file viewer.
        fileViewerVC.view.isHidden = true
        fileTreeView.isHidden = false
        fileTreeView.revealFileInTree(path: path)
    }

    func previewFile(path: String) {
        sidebarTabs.selectedSegment = 1
        selectSidebarTab(index: 1)
        fileTreeView.isHidden = true
        fileViewerVC.view.isHidden = false
        fileViewerVC.load(path: path)
    }

    @objc private func viViewFileCommand(_ note: Notification) {
        guard let path = note.userInfo?["path"] as? String else { return }
        var expanded = (path as NSString).expandingTildeInPath
        if !expanded.hasPrefix("/"), let cwd = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd {
            expanded = (cwd as NSString).appendingPathComponent(expanded)
        }
        if !FileManager.default.fileExists(atPath: expanded) {
            let root = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? FileManager.default.currentDirectoryPath
            switch FuzzyPathResolver.resolve(query: path, root: root, limit: 5) {
            case .none:
                DisplayMessage.show("view: no match")
                return
            case .unique(let match):
                expanded = match
            case .ambiguous(let matches):
                DisplayMessage.show(matches.enumerated().map { "\($0.offset + 1): \($0.element)" }.joined(separator: "\n"))
                return
            }
        }
        previewFile(path: expanded)
    }

    private func selectSidebarTab(index: Int) {
        sessionScroll?.isHidden = index != 0
        if index != 1 {
            // Leaving the Files tab: collapse any open preview back to the tree
            // so returning to Files always starts from the file list.
            fileViewerVC.view.isHidden = true
            fileTreeView.isHidden = true
        } else {
            fileTreeView.isHidden = fileViewerVC.view.isHidden == false
        }
        gitPanelView.isHidden = index != 2
#if HARNESS_ACP
        agentChatPanel.isHidden = index != 3
#endif
        switch index {
        case 1:
            sectionLabel.stringValue = "FILES"
            sectionLabel.font = HarnessDesign.Typography.sectionLabel
            if let cwd = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd {
                let activeSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
                fileTreeView.updateRoot(path: cwd, sessionID: activeSessionID)
            }
        case 2:
            sectionLabel.stringValue = "GIT"
            sectionLabel.font = HarnessDesign.Typography.sectionLabel
            if let cwd = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd {
                gitPanelView.updateRoot(path: cwd)
            } else {
                gitPanelView.clearRoot()
            }
        case 3:
            sectionLabel.stringValue = "AGENT"
            sectionLabel.font = HarnessDesign.Typography.sectionLabel
            // [ACP SHELVED] connectAgentIfNeeded()
        default:
            // Switching back to Sessions tab: rebuild cache so heightOfRow/viewFor
            // read O(1) cachedSidebarRows if sessions changed while tab was hidden.
            rebuildSidebarRows()
            sectionLabel.font = .systemFont(ofSize: 11.5, weight: .bold)
            updateRepoSectionHeader()
        }
    }

    private func syncSessionColumnWidth() {
        guard let column = sessionTable.tableColumns.first else { return }
        let width = sessionScroll?.contentView.bounds.width ?? view.bounds.width
        let clamped = max(1, width)
        guard abs(column.width - clamped) > 0.5 else { return }
        column.width = clamped
    }

    /// One footer row: "⚙ Settings" (text + icon) on the left, a trimmed set of quick
    /// icons on the right — all on the same baseline. The redundant settings slider and
    /// the help icon were removed (Settings is now the labeled button).
    private func setupFooter() {
        footer.translatesAutoresizingMaskIntoConstraints = false
        HarnessDesign.makeClear(footer)

        // Settings is now just a gear icon button, identical in style to the +/⌘ buttons.
        let settings = HarnessDesign.softIconButton(symbol: "gearshape", tooltip: "Settings (⌘,)")
        settings.target = self
        settings.action = #selector(openSettings)

        let newSession = HarnessDesign.softIconButton(symbol: "plus", tooltip: "New session")
        newSession.target = self
        newSession.action = #selector(addSession)

        let recentProjects = HarnessDesign.softIconButton(symbol: "clock.arrow.circlepath", tooltip: "Recent projects")
        recentProjects.target = self
        recentProjects.action = #selector(showRecentProjects(_:))

        // No "new workspace" control: the app runs a single workspace for now, and without a
        // switcher a second workspace would strand the user with no way back.
        let palette = HarnessDesign.softIconButton(symbol: "command", tooltip: "Command palette (⌘K)")
        palette.target = self
        palette.action = #selector(openPalette)

        agentsButton.target = self
        agentsButton.action = #selector(agentsButtonClicked)

        footer.addSubview(settings)
        footer.addSubview(agentsButton)
        footer.addSubview(recentProjects)
        footer.addSubview(newSession)
        footer.addSubview(palette)
        view.addSubview(footer)

        NSLayoutConstraint.activate([
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footer.heightAnchor.constraint(equalToConstant: HarnessDesign.footerHeight + 6),

            // Settings on the leading edge; the agents/new-session/palette actions on the trailing.
            settings.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: HarnessDesign.horizontalInset),
            settings.centerYAnchor.constraint(equalTo: footer.centerYAnchor),

            palette.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -(HarnessDesign.horizontalInset - 4)),
            palette.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            newSession.trailingAnchor.constraint(equalTo: palette.leadingAnchor, constant: -2),
            newSession.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            recentProjects.trailingAnchor.constraint(equalTo: newSession.leadingAnchor, constant: -2),
            recentProjects.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            agentsButton.trailingAnchor.constraint(equalTo: recentProjects.leadingAnchor, constant: -2),
            agentsButton.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
        ])
    }

    @objc func reload() {
        let snap = SessionCoordinator.shared.snapshot
        workspaces = snap.workspaces
        activeWorkspaceID = snap.activeWorkspaceID
        let newActiveSessionID = snap.activeWorkspace?.activeSessionID
        activeSessionID = newActiveSessionID
        sessions = snap.activeWorkspace?.sessions ?? []
        let name = snap.activeWorkspace?.name ?? "Workspace"
        workspacePill.configure(name: name, count: sessions.count)
        // Rebuild once before reloadData() so all NSTableViewDelegate callbacks
        // read the O(1) cache instead of recomputing sidebarRows N times.
        rebuildSidebarRows()
        sessionTable.reloadData()

        selectActiveSessionRowIfVisible(scroll: true)

        if let cwd = snap.activeWorkspace?.activeTab?.cwd {
            let activeSessionID = snap.activeWorkspace?.activeSessionID
            let gitBranch = snap.activeWorkspace?.activeTab?.gitBranch
            let sessionChanged = activeSessionID != lastFileTreeSessionID
            if sessionChanged {
                lastFileTreeGitBranch = nil
            }
            let branchChanged = gitBranch != lastFileTreeGitBranch
            fileTreeView.updateRoot(path: cwd, sessionID: activeSessionID)
            if branchChanged {
                fileTreeView.updateRoot(path: cwd, sessionID: activeSessionID)
            }
            gitPanelView.updateRoot(path: cwd)
            lastFileTreeSessionID = activeSessionID
            lastFileTreeGitBranch = gitBranch
            let home = NSHomeDirectory()
            if cwd != home, cwd != "/" {
                Self.recordRecentProject(cwd)
            }
        } else {
            gitPanelView.clearRoot()
        }
        updateRepoSectionHeader()
        updateWorktrees()
    }

    /// Updates session card labels in place (title/cwd/branch/agent) without
    /// rebuilding the table — preserves selection + scroll position.
    @objc func refreshMetadata() {
        let snap = SessionCoordinator.shared.snapshot
        let newSessions = snap.activeWorkspace?.sessions ?? []
        let activeID = snap.activeWorkspace?.activeSessionID
        // Structural changes still take the full reload path.
        if newSessions.map(\.id) != sessions.map(\.id) {
            reload()
            return
        }
        sessions = newSessions
        activeWorkspaceID = snap.activeWorkspaceID
        activeSessionID = activeID
        workspaces = snap.workspaces
        let name = snap.activeWorkspace?.name ?? "Workspace"
        workspacePill.configure(name: name, count: sessions.count)
        if let cwd = snap.activeWorkspace?.activeTab?.cwd {
            let activeSessionID = snap.activeWorkspace?.activeSessionID
            let gitBranch = snap.activeWorkspace?.activeTab?.gitBranch
            let sessionChanged = activeSessionID != lastFileTreeSessionID
            if sessionChanged {
                lastFileTreeGitBranch = nil
            }
            let branchChanged = gitBranch != lastFileTreeGitBranch
            if sessionChanged || branchChanged {
                fileTreeView.updateRoot(path: cwd, sessionID: activeSessionID)
            }
            gitPanelView.updateRoot(path: cwd)
            lastFileTreeSessionID = activeSessionID
            lastFileTreeGitBranch = gitBranch
        } else {
            gitPanelView.clearRoot()
        }
        // Rebuild cache once; iterate the stored result — no redundant recomputation.
        // Skip entirely when session data hasn't changed (common on metadata-only ticks).
        let sessionsChanged = !newSessions.isStableEqual(to: lastRefreshedSessions) || activeID != lastRefreshedActiveID
        if sessionsChanged {
            lastRefreshedSessions = newSessions
            lastRefreshedActiveID = activeID
            rebuildSidebarRows()
            selectActiveSessionRowIfVisible(scroll: false)
            let rows = cachedSidebarRows
            for row in 0 ..< rows.count {
                if let cell = sessionTable.view(atColumn: 0, row: row, makeIfNecessary: false) as? WorktreeRowView {
                    guard case let .session(session) = rows[row] else { continue }
                    let tab = session.activeTab ?? session.tabs.first ?? Tab()
                    let branch = tab.gitBranch ?? ""
                    let metadata = self.gitMetadata(forPath: tab.cwd, branch: branch)
                    cell.configure(session: session, isSelected: session.id == activeID, metadata: metadata)
                }
            }
        }
        updateRepoSectionHeader()
        updateWorktrees()
    }

    @objc func addWorkspace() {
        let count = SessionCoordinator.shared.snapshot.workspaces.count + 1
        SessionCoordinator.shared.addWorkspace(name: "Workspace \(count)")
    }

    /// Quick-actions menu opened from a row's ellipsis (inside the workspace
    /// dropdown). Just "Delete workspace…" — rename lives on the pill itself.
    func confirmDeleteWorkspace(_ workspace: Workspace, anchor: NSView) {
        let menu = NSMenu()
        let delete = NSMenuItem(title: "Delete workspace…", action: #selector(deleteWorkspaceFromMenu(_:)), keyEquivalent: "")
        delete.target = self
        delete.representedObject = workspace.id
        menu.addItem(delete)
        let point = NSPoint(x: 0, y: anchor.bounds.height + 4)
        menu.popUp(positioning: nil, at: point, in: anchor)
    }

    /// Quick-actions menu opened from the workspace pill's ellipsis (top-level).
    /// Rename and Delete for the active workspace. Delete is disabled when this
    /// is the only workspace (you can't remove the last one).
    private func showActiveWorkspaceActions(from anchor: NSView) {
        guard let active = workspaces.first(where: { $0.id == activeWorkspaceID }) else { return }
        let menu = NSMenu()
        let rename = NSMenuItem(title: "Rename workspace…", action: #selector(renameActiveWorkspace(_:)), keyEquivalent: "")
        rename.target = self
        rename.representedObject = active.id
        menu.addItem(rename)

        menu.addItem(.separator())

        let delete = NSMenuItem(title: "Delete workspace…", action: #selector(deleteWorkspaceFromMenu(_:)), keyEquivalent: "")
        delete.target = self
        delete.representedObject = active.id
        delete.isEnabled = workspaces.count > 1
        menu.addItem(delete)

        let point = NSPoint(x: 0, y: anchor.bounds.height + 4)
        menu.popUp(positioning: nil, at: point, in: anchor)
    }

    @objc private func renameActiveWorkspace(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? WorkspaceID,
              let workspace = workspaces.first(where: { $0.id == id })
        else { return }
        let alert = NSAlert()
        alert.messageText = "Rename workspace"
        alert.informativeText = "Enter a new name for \"\(workspace.name)\"."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 22))
        input.stringValue = workspace.name
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let trimmed = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != workspace.name else { return }
        SessionCoordinator.shared.renameWorkspace(id: id, name: trimmed)
    }

    @objc private func deleteWorkspaceFromMenu(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? WorkspaceID,
              let workspace = workspaces.first(where: { $0.id == id })
        else { return }
        dismissWorkspaceDropdown()
        let alert = NSAlert()
        alert.messageText = "Delete \"\(workspace.name)\"?"
        alert.informativeText = "All sessions and tabs in this workspace will be closed. This can't be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = ""
        if alert.runModal() == .alertFirstButtonReturn {
            SessionCoordinator.shared.closeWorkspace(id: id)
        }
    }

    @objc private func addSession() {
        guard let activeWorkspaceID else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        panel.message = "Choose a project folder"
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            DispatchQueue.main.async {
                guard let self, let id = self.activeWorkspaceID ?? activeWorkspaceID as WorkspaceID? else { return }
                Self.recordRecentProject(url.path)
                SessionCoordinator.shared.addSession(to: id, cwd: url.path, name: url.lastPathComponent)
            }
        }
    }

    private func addSessionInGroup(rootPath: String) {
        guard let activeWorkspaceID else { return }
        let name = HarnessDesign.pathDisplayName(rootPath)
        Self.recordRecentProject(rootPath)
        SessionCoordinator.shared.addSession(to: activeWorkspaceID, cwd: rootPath, name: name)
    }

    private func showGroupActionsMenu(for rootPath: String, name: String, anchor: NSView) {
        let menu = NSMenu()
        let closeGroup = NSMenuItem(title: "Close all sessions in \(name)", action: #selector(closeGroupSessionsFromMenu(_:)), keyEquivalent: "")
        closeGroup.target = self
        closeGroup.representedObject = rootPath
        menu.addItem(closeGroup)
        
        let point = NSPoint(x: anchor.bounds.width / 2, y: anchor.bounds.height + 4)
        menu.popUp(positioning: nil, at: point, in: anchor)
    }

    @objc private func closeGroupSessionsFromMenu(_ sender: NSMenuItem) {
        guard let rootPath = sender.representedObject as? String else { return }
        let groupSessions = sessions.filter { projectGroupRootPath(for: $0) == rootPath }
        guard !groupSessions.isEmpty else { return }
        
        let alert = NSAlert()
        alert.messageText = "Close all sessions in this group?"
        alert.informativeText = "This will close \(groupSessions.count) session\(groupSessions.count == 1 ? "" : "s") and all their tabs. This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Close All")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = ""
        
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        
        for session in groupSessions {
            SessionCoordinator.shared.closeSession(session)
        }
        SessionCoordinator.shared.syncFromDaemon()
    }

    // MARK: - Git & Worktrees Helpers

    private func fetchRepoName(for path: String) async -> String {
        let folderName = HarnessDesign.projectGroupName(for: path)
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return folderName }
        // Run git off the main actor — readDataToEndOfFile + waitUntilExit block the
        // calling thread, causing a 1s+ hang report when executed on main.
        let repoName: String? = await Task.detached(priority: .utility) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = ["config", "--get", "remote.origin.url"]
            process.currentDirectoryURL = URL(fileURLWithPath: path)
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                if process.terminationStatus == 0,
                   let urlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !urlString.isEmpty {
                    let lastPathComponent = (urlString as NSString).lastPathComponent
                    var repo = lastPathComponent
                    if repo.hasSuffix(".git") {
                        repo = String(repo.dropLast(4))
                    }
                    if !repo.isEmpty { return repo }
                }
            } catch {}
            return nil
        }.value
        return repoName ?? folderName
    }

    private func fetchWorktrees(for rootPath: String) async -> [SidebarWorktreeEntry] {
        guard !rootPath.isEmpty, FileManager.default.fileExists(atPath: rootPath) else { return [] }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["worktree", "list", "--porcelain"]
        process.currentDirectoryURL = URL(fileURLWithPath: rootPath)
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return [] }
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return output.components(separatedBy: "\n\n").enumerated().compactMap { index, block -> SidebarWorktreeEntry? in
                let lines = block.components(separatedBy: "\n").filter { !$0.isEmpty }
                guard let worktreeLine = lines.first(where: { $0.hasPrefix("worktree ") }),
                      let headLine = lines.first(where: { $0.hasPrefix("HEAD ") }) else { return nil }
                let worktreePath = String(worktreeLine.dropFirst("worktree ".count))
                let head = String(headLine.dropFirst("HEAD ".count))
                let branchLine = lines.first(where: { $0.hasPrefix("branch ") })
                let branch = branchLine.map { line in
                    let ref = String(line.dropFirst("branch ".count))
                    return ref.hasPrefix("refs/heads/") ? String(ref.dropFirst("refs/heads/".count)) : ref
                } ?? "detached"
                let isLocked = lines.contains { line in
                    line == "locked" || line.hasPrefix("locked ")
                }
                return SidebarWorktreeEntry(path: worktreePath, head: head, branch: branch, isMain: index == 0, isLocked: isLocked)
            }
        } catch {
            return []
        }
    }

    private func updateRepoSectionHeader() {
        guard sidebarTabs.selectedSegment == 0 else { return }
        let path = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? ""
        if path.isEmpty {
            self.sectionLabel.stringValue = "SESSIONS"
            return
        }
        Task {
            let repoName = await fetchRepoName(for: path)
            await MainActor.run {
                if self.sidebarTabs.selectedSegment == 0 {
                    self.sectionLabel.stringValue = repoName.hasSuffix("/") ? repoName : "\(repoName)/"
                }
            }
        }
    }

    private func updateWorktrees(force: Bool = false) {
        let rootPaths = Set(sessions.map { projectGroupRootPath(for: $0) })
        let now = Date()
        for rootPath in rootPaths {
            if !force, let lastFetch = lastWorktreeFetchTime[rootPath], now.timeIntervalSince(lastFetch) < 3.0 {
                continue
            }
            lastWorktreeFetchTime[rootPath] = now
            Task {
                let worktrees = await fetchWorktrees(for: rootPath)
                await MainActor.run {
                    if self.projectWorktrees[rootPath] != worktrees {
                        self.projectWorktrees[rootPath] = worktrees
                        self.rebuildSidebarRows()
                        self.sessionTable.reloadData()
                    }
                }
            }
        }
    }
}

extension HarnessSidebarPanelViewController: NSTableViewDataSource, NSTableViewDelegate {
    static let sessionRowPasteboardType = NSPasteboard.PasteboardType("com.robert.harness.session-row")

    func numberOfRows(in tableView: NSTableView) -> Int {
        cachedSidebarRows.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard row < cachedSidebarRows.count else { return 28 }
        switch cachedSidebarRows[row] {
        case .groupHeader:
            return 28
        case .worktreeHeader:
            return 24
        case .session, .worktree:
            return 40
        case .divider:
            return 10
        }
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return sessionRow(at: row) != nil
    }

    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return false
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < cachedSidebarRows.count else { return nil }
        switch cachedSidebarRows[row] {
        case let .groupHeader(name, rootPath, count, isCollapsed, status):
            let header = SessionGroupHeaderRowView()
            header.configure(name: name, count: count, isCollapsed: isCollapsed, status: status)
            header.onAdd = { [weak self] in
                self?.addSessionInGroup(rootPath: rootPath)
            }
            header.onToggleCollapse = { [weak self] in
                guard let self else { return }
                let wasCollapsed = self.collapsedGroups.contains(rootPath)
                let oldRows = self.cachedSidebarRows
                
                if wasCollapsed {
                    self.collapsedGroups.remove(rootPath)
                } else {
                    self.collapsedGroups.insert(rootPath)
                }
                
                self.rebuildSidebarRows()
                let newRows = self.cachedSidebarRows
                
                // Find the index of the group header in oldRows
                guard let headerIndex = oldRows.firstIndex(where: {
                    if case .groupHeader(_, let path, _, _, _) = $0 { return path == rootPath }
                    return false
                }) else {
                    self.sessionTable.reloadData()
                    return
                }
                
                self.sessionTable.beginUpdates()
                
                if wasCollapsed {
                    // We expanded.
                    guard let newHeaderIndex = newRows.firstIndex(where: {
                        if case .groupHeader(_, let path, _, _, _) = $0 { return path == rootPath }
                        return false
                    }) else {
                        self.sessionTable.endUpdates()
                        self.sessionTable.reloadData()
                        return
                    }
                    
                    var insertedCount = 0
                    for i in (newHeaderIndex + 1)..<newRows.count {
                        if case .groupHeader = newRows[i] {
                            break
                        }
                        if case .divider = newRows[i] {
                            break
                        }
                        insertedCount += 1
                    }
                    
                    if insertedCount > 0 {
                        let indexSet = IndexSet((headerIndex + 1)...(headerIndex + insertedCount))
                        self.sessionTable.insertRows(at: indexSet, withAnimation: .slideDown)
                    }
                } else {
                    // We collapsed.
                    var removedCount = 0
                    for i in (headerIndex + 1)..<oldRows.count {
                        if case .groupHeader = oldRows[i] {
                            break
                        }
                        if case .divider = oldRows[i] {
                            break
                        }
                        removedCount += 1
                    }
                    
                    if removedCount > 0 {
                        let indexSet = IndexSet((headerIndex + 1)...(headerIndex + removedCount))
                        self.sessionTable.removeRows(at: indexSet, withAnimation: .slideUp)
                    }
                }
                
                self.sessionTable.endUpdates()
                
                // Update the header view's collapsed state without recreating it
                if let headerView = self.sessionTable.view(atColumn: 0, row: headerIndex, makeIfNecessary: false) as? SessionGroupHeaderRowView {
                    if case let .groupHeader(_, _, freshCount, freshIsCollapsed, freshStatus) = newRows[headerIndex] {
                        headerView.configure(name: name, count: freshCount, isCollapsed: freshIsCollapsed, status: freshStatus)
                    } else {
                        headerView.configure(name: name, count: count, isCollapsed: !wasCollapsed, status: status)
                    }
                }
            }
            header.onContextMenu = { [weak self] in
                self?.groupActionsMenu(for: rootPath, name: name)
            }
            header.onOptions = { [weak self] anchor in
                guard let self else { return }
                let menu = self.groupActionsMenu(for: rootPath, name: name)
                let point = NSPoint(x: anchor.bounds.width / 2, y: anchor.bounds.height + 4)
                menu.popUp(positioning: nil, at: point, in: anchor)
            }
            return header
        case let .session(session):
            let cell = WorktreeRowView()
            let tab = session.activeTab ?? session.tabs.first ?? Tab()
            let branch = tab.gitBranch ?? ""
            let metadata = self.gitMetadata(forPath: tab.cwd, branch: branch)
            cell.configure(
                session: session,
                isSelected: session.id == SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID,
                metadata: metadata
            )
            cell.onClose = { [weak self] in
                guard self != nil else { return }
                SessionCoordinator.shared.closeSession(session)
            }
            cell.onPRClick = {
                guard let url = metadata?.prURL.flatMap({ URL(string: $0) }) else { return }
                SessionCoordinator.shared.splitPaneCoordinator.openBrowserPane(
                    url: url, direction: .horizontal
                )
            }
            cell.onContextMenu = { [weak self] in
                self?.sessionActionsMenu(for: session)
            }
            return cell
        case let .worktreeHeader(rootPath, count, isCollapsed):
            let header = SessionWorktreeHeaderRowView()
            header.configure(count: count, isCollapsed: isCollapsed)
            header.onToggleCollapse = { [weak self] in
                guard let self else { return }
                if self.collapsedWorktreeGroups.contains(rootPath) {
                    self.collapsedWorktreeGroups.remove(rootPath)
                } else {
                    self.collapsedWorktreeGroups.insert(rootPath)
                }
                self.rebuildSidebarRows()
                self.sessionTable.reloadData()
            }
            return header
        case let .worktree(entry, _):
            let cell = SessionWorktreeRowView()
            let metadata = self.gitMetadata(forPath: entry.path, branch: entry.branch)
            cell.configure(path: entry.path, branch: entry.branch, metadata: metadata)
            cell.onSelect = { [weak self] in
                guard let self else { return }
                if let workspaceID = self.activeWorkspaceID {
                    Self.recordRecentProject(entry.path)
                    SessionCoordinator.shared.addSession(to: workspaceID, cwd: entry.path, name: (entry.path as NSString).lastPathComponent)
                    self.updateWorktrees(force: true)
                }
            }
            return cell
        case .divider:
            return SessionDividerRowView()
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard !isProgrammaticSelection else { return }
        selectSessionRow()
    }
}

struct SidebarWorktreeEntry: Sendable, Equatable, Hashable {
    let path: String
    let head: String
    let branch: String
    let isMain: Bool
    let isLocked: Bool
}
