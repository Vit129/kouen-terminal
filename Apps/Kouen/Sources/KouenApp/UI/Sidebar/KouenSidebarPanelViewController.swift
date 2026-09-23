import AppKit
import KouenCore
import SwiftUI
import os

/// Left session rail — workspace pill, sessions list, and a quiet footer.
@MainActor
final class KouenSidebarPanelViewController: NSViewController {
    private let chromeHeader = SidebarTitlebarHeaderView()
    let workspacePillModel = WorkspacePillModel()
    lazy var workspacePill: NSView = NSHostingView(
        rootView: WorkspacePillView(
            model: workspacePillModel,
            onClick: { [weak self] in self?.showWorkspaceMenu() },
            onMoreClick: { [weak self] in
                guard let self else { return }
                self.showActiveWorkspaceActions(from: self.workspacePill)
            }
        )
    )
    // Traffic-light clearance for the icon tab bar row: only needed when this sidebar sits at
    // the window's physical left edge (`!sidebarOnRight`) — the right edge never has traffic
    // lights over it. See `updateTrafficLightClearance()`.
    private var chromeHeaderHeightConstraint: NSLayoutConstraint?
    private var tabBarTopConstraint: NSLayoutConstraint?
    private var tabBarLeadingConstraint: NSLayoutConstraint?
    private var tabBarHostingView: NSView!
    let sidebarSectionModel = SidebarSectionModel()
    private var sectionLabelHostingView: NSView!
    let fileTreeView = WorkspaceFileTreeView()
    private let fileViewerVC = FileViewerViewController()
    let sidebarFooterModel = SidebarFooterModel()
    private var footerHostingView: NSView!
    let sidebarListModel = SidebarListModel()
    private var sessionHostingView: NSView?
    private var jobsHostingView: NSView?
    private let jobsModel = AutomationsFleetModel()
    private var sessionHistoryHostingView: NSView?
    let sessionHistoryModel = AgentSessionHistoryModel()
    // private var issueTrackerHostingView: NSView?  // Issues tab disabled across the system
    private var fleetHostingView: NSView?
    let fleetModel = FleetViewModel()
    // Project & Workspace Storage (Orca Session == Project)
    let projectStore = ProjectStore()
    private var projectDropTarget: ProjectDropTarget?
    var workspaces: [Workspace] = []
    var sessions: [SessionGroup] = []
    var activeWorkspaceID: WorkspaceID?
    private var activeSessionID: SessionID?
    var workspaceDropdown: WorkspaceSwitcherPanelView?
    nonisolated(unsafe) var workspaceDropdownMonitor: Any?
    /// Last session ID sent to fileTreeView so we can detect session changes even
    /// when the CWD is the same (e.g. two sessions sharing the same repo root).
    var lastFileTreeSessionID: SessionID?
    var lastFileTreeGitBranch: String?
    var lastFileTreeCWD: String?
    private var lastRepoHeaderPath = ""
    private var lastRepoHeaderFetch = Date.distantPast

    deinit {
        if let monitor = workspaceDropdownMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = notificationsDropdownMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = agentsInboxMonitor { NSEvent.removeMonitor(monitor) }
    }

    override func loadView() {
        let root = NSView()
        KouenDesign.applySidebarChrome(to: root)
        view = root
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarListModel.projectStore = projectStore
        setupChromeHeader()
        setupWorkspaceBar()
        setupSidebarTabs()
        setupSectionLabel()
        setupFooterView()
        setupDropTarget()
        setupSessionList()
        setupFileTree()
        setupFileViewer()
        setupJobsView()
        setupSessionHistoryView()
        setupFleetView()
        // TODO: Issues tab disabled — re-enable with setupIssuesView() once Jira domain config UI + Azure impl are complete
        // setupIssuesView()
        selectSidebarTab(index: 0)
        reload()
        applyChromeColors()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshMetadata),
            name: Notification.Name("KouenActiveTabGitBranchDidChange"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viViewFileCommand(_:)),
            name: .viViewFileCommand,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenGitPanel(_:)),
            name: .kouenOpenGitPanel,
            object: nil
        )
    }

    func applyChromeColors() {
        KouenDesign.applySidebarChrome(to: view)
        KouenDesign.makeClear(chromeHeader)
        workspacePillModel.chromeEpoch += 1
        sidebarSectionModel.chromeEpoch += 1
        sidebarFooterModel.chromeEpoch += 1

        updateTrafficLightClearance()

        dismissWorkspaceDropdown()
    }

    private func setupChromeHeader() {
        chromeHeader.translatesAutoresizingMaskIntoConstraints = false
        KouenDesign.makeClear(chromeHeader)
        view.addSubview(chromeHeader)
        let height = chromeHeader.heightAnchor.constraint(equalToConstant: KouenDesign.tabBarHeight)
        chromeHeaderHeightConstraint = height
        NSLayoutConstraint.activate([
            chromeHeader.topAnchor.constraint(equalTo: view.topAnchor),
            chromeHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chromeHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            height,
        ])
    }

    /// Provides top bar clearance so sidebar items sit cleanly underneath the window top bar / traffic lights.
    func updateTrafficLightClearance() {
        chromeHeaderHeightConstraint?.constant = KouenDesign.tabBarHeight
    }

    /// Sidebar collapse/expand is handled by a single always-visible toggle living in
    /// `ContentAreaViewController` now (Orca-reference behavior: one button, fixed corner,
    /// regardless of open/closed state) — this sidebar no longer carries its own internal
    /// toggle button, which used to duplicate it and only appear while the sidebar itself was
    /// visible. "Move Sidebar to Left/Right" is still reachable via the session context menu
    /// (`KouenSidebarPanelViewController+SessionMenu.swift`), which also calls
    /// `toggleSidebarPositionFromMenu()` below.
    private func setupWorkspaceBar() {}

    @objc func toggleSidebarPositionFromMenu() {
        let split = view.window?.contentViewController as? MainSplitViewController
        Logger(subsystem: "com.vit129.kouen", category: "sidebar")
            .debug("toggleSidebarPositionFromMenu() fired — contentViewController is MainSplitViewController: \(split != nil)")
        split?.toggleSidebarPosition()
    }

    private var notificationsDropdown: NotificationDropdownPanelView?
    private nonisolated(unsafe) var notificationsDropdownMonitor: Any?
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
    private nonisolated(unsafe) var agentsInboxMonitor: Any?

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
        // Anchor above the footer — mirrors showNotificationsDropdown positioning.
        let footerInHost = host.convert(footerHostingView.bounds, from: footerHostingView)
        let originX: CGFloat = 8
        let originY = footerInHost.maxY + 6
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
            let inboxPoint = inbox.convert(event.locationInWindow, from: nil)
            if inbox.bounds.contains(inboxPoint) { return event }
            // Clicks in the footer let the SwiftUI button action handle toggle.
            let footerPoint = self.footerHostingView.convert(event.locationInWindow, from: nil)
            if self.footerHostingView.bounds.contains(footerPoint) { return event }
            self.dismissAgentsInbox()
            return event
        }
    }

    private var taskDashboard: TaskDashboardView?
    private nonisolated(unsafe) var taskDashboardMonitor: Any?
    private var swarmFleetDashboard: SwarmFleetView?
    private nonisolated(unsafe) var swarmFleetDashboardMonitor: Any?

    /// P40 F1-H: float the Task Dashboard over the window's content view, same
    /// anchor-above-footer presentation as `showAgentsInbox`.
    private func showTaskDashboard() {
        if taskDashboard != nil {
            dismissTaskDashboard()
            return
        }
        let coordinator = SessionCoordinator.shared
        let dashboard = TaskDashboardView(onJumpToSession: { [weak self] sessionID in
            self?.dismissTaskDashboard()
            guard let workspaceID = coordinator.snapshot.workspaces.first(where: { workspace in
                workspace.sessions.contains { $0.id == sessionID }
            })?.id else { return }
            coordinator.selectSession(workspaceID: workspaceID, sessionID: sessionID)
        })
        dashboard.alphaValue = 0
        dashboard.translatesAutoresizingMaskIntoConstraints = true
        dashboard.layer?.zPosition = 100

        let host = view.window?.contentView ?? view
        let width: CGFloat = 320
        let height = dashboard.preferredHeight
        let footerInHost = host.convert(footerHostingView.bounds, from: footerHostingView)
        let originX: CGFloat = 8
        let originY = footerInHost.maxY + 6
        dashboard.frame = NSRect(x: originX, y: originY, width: width, height: height)
        host.addSubview(dashboard)
        taskDashboard = dashboard
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            dashboard.animator().alphaValue = 1
        }
        installTaskDashboardMonitor()
    }

    private func dismissTaskDashboard() {
        taskDashboard?.removeFromSuperview()
        taskDashboard = nil
        if let monitor = taskDashboardMonitor {
            NSEvent.removeMonitor(monitor)
            taskDashboardMonitor = nil
        }
    }

    /// Agent Swarm Core Slice 5: same anchor-above-footer float as `showTaskDashboard`.
    private func showSwarmFleet() {
        if swarmFleetDashboard != nil {
            dismissSwarmFleet()
            return
        }
        let dashboard = SwarmFleetView()
        dashboard.alphaValue = 0
        dashboard.translatesAutoresizingMaskIntoConstraints = true
        dashboard.layer?.zPosition = 100

        let host = view.window?.contentView ?? view
        let width: CGFloat = 320
        let height = dashboard.preferredHeight
        let footerInHost = host.convert(footerHostingView.bounds, from: footerHostingView)
        let originX: CGFloat = 8
        let originY = footerInHost.maxY + 6
        dashboard.frame = NSRect(x: originX, y: originY, width: width, height: height)
        host.addSubview(dashboard)
        swarmFleetDashboard = dashboard
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            dashboard.animator().alphaValue = 1
        }
        installSwarmFleetMonitor()
    }

    private func dismissSwarmFleet() {
        swarmFleetDashboard?.removeFromSuperview()
        swarmFleetDashboard = nil
        if let monitor = swarmFleetDashboardMonitor {
            NSEvent.removeMonitor(monitor)
            swarmFleetDashboardMonitor = nil
        }
    }

    private func installSwarmFleetMonitor() {
        swarmFleetDashboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let dashboard = self.swarmFleetDashboard else { return event }
            let dashboardPoint = dashboard.convert(event.locationInWindow, from: nil)
            if dashboard.bounds.contains(dashboardPoint) { return event }
            let footerPoint = self.footerHostingView.convert(event.locationInWindow, from: nil)
            if self.footerHostingView.bounds.contains(footerPoint) { return event }
            self.dismissSwarmFleet()
            return event
        }
    }

    private func installTaskDashboardMonitor() {
        taskDashboardMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let dashboard = self.taskDashboard else { return event }
            let dashboardPoint = dashboard.convert(event.locationInWindow, from: nil)
            if dashboard.bounds.contains(dashboardPoint) { return event }
            let footerPoint = self.footerHostingView.convert(event.locationInWindow, from: nil)
            if self.footerHostingView.bounds.contains(footerPoint) { return event }
            self.dismissTaskDashboard()
            return event
        }
    }

    private func setupSidebarTabs() {
        let hosting = NSHostingView(rootView: SidebarTabBarView(
            model: sidebarSectionModel,
            onTabChange: { [weak self] index in self?.selectSidebarTab(index: index) }
        ))
        hosting.translatesAutoresizingMaskIntoConstraints = false
        tabBarHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: chromeHeader.bottomAnchor, constant: 4),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KouenDesign.horizontalInset),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KouenDesign.horizontalInset),
            hosting.heightAnchor.constraint(equalToConstant: 26),
        ])
    }

    private func setupSectionLabel() {
        sidebarSectionModel.onAddProject = { [weak self] in
            self?.addSession()
        }
        sidebarSectionModel.onAddJob = { [weak self] in
            self?.promptNewAutomation()
        }
        let hosting = NSHostingView(rootView: SidebarSectionLabelView(model: sidebarSectionModel))
        hosting.translatesAutoresizingMaskIntoConstraints = false
        sectionLabelHostingView = hosting
        view.addSubview(hosting)
        let top = tabBarHostingView?.bottomAnchor ?? chromeHeader.bottomAnchor
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: top, constant: 6),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    func setTrafficLightHorizontalInset(_ inset: CGFloat) {
        // Tab bar sits directly below the top bar now with clean leading alignment.
    }

    private func setupSessionList() {
        let listView = SidebarSessionListView(
            model: sidebarListModel,
            onSelect: { [weak self] id in
                guard let self, let wsID = self.activeWorkspaceID else { return }
                SessionCoordinator.shared.selectSession(workspaceID: wsID, sessionID: id)
            },
            onOpenProject: { [weak self] path in
                self?.openRecentPath(path)
            },
            onAddInGroup: { [weak self] name, catID in
                self?.addProjectToGroup(name: name, categoryID: catID)
            },
            onCloseSession: { [weak self] id in
                guard let self, let session = self.sessions.first(where: { $0.id == id }) else { return }
                SessionCoordinator.shared.closeSession(session)
            },
            onRemoveProject: { [weak self] path in
                guard let self else { return }
                self.projectStore.removeProject(path)
                self.sidebarListModel.update(from: SessionCoordinator.shared.snapshot)
            },
            onPRClick: { urlString in
                guard let url = URL(string: urlString) else { return }
                SessionCoordinator.shared.splitPaneCoordinator.openBrowserPane(url: url, direction: .horizontal)
            },
            onWorktreeActivate: { [weak self] entry, wsID in
                guard let wsID else { return }
                Self.recordRecentProject(entry.path)
                SessionCoordinator.shared.addSession(
                    to: wsID, cwd: entry.path,
                    name: (entry.path as NSString).lastPathComponent
                )
                self?.sidebarListModel.updateWorktrees(force: true)
            }
        )
        let hosting = NSHostingView(rootView: listView)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        sessionHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
        ])
    }

    private func setupFileTree() {
        fileTreeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fileTreeView)
        NSLayoutConstraint.activate([
            fileTreeView.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            fileTreeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fileTreeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fileTreeView.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
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
                coordinator.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(cmd.utf8), origin: .human))
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
            viewerView.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            viewerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewerView.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
        ])
        fileViewerVC.onBack = { [weak self] in
            guard let self else { return }
            self.fileViewerVC.view.isHidden = true
            self.fileTreeView.isHidden = false
        }
    }

    private func setupJobsView() {
        let jobsView = AutomationsFleetView(
            model: jobsModel,
            isSidebar: true,
            onAddJob: { [weak self] in self?.promptNewAutomation() }
        )
        let hosting = NSHostingView(rootView: jobsView)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        hosting.isHidden = true
        jobsHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
        ])
    }

    private func setupSessionHistoryView() {
        let historyView = AgentSessionHistoryView(
            model: sessionHistoryModel,
            onResume: { [weak self] record in
                self?.resumeAgentSession(record)
            },
            onResumeInWorktree: { [weak self] record in
                self?.resumeAgentSessionInWorktree(record)
            },
            onContinueInNewSession: { [weak self] record in
                self?.continueAgentSessionInNewSession(record)
            }
        )
        let hosting = NSHostingView(rootView: historyView)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        hosting.isHidden = true
        sessionHistoryHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
        ])
    }

    private func setupFleetView() {
        let fleetView = FleetView(
            model: fleetModel,
            onSelect: { [weak self] item in
                self?.focusFleetSession(item)
            }
        )
        let hosting = NSHostingView(rootView: fleetView)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        hosting.isHidden = true
        fleetHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
        ])
    }

    /// Same jump sequence `NotificationCoordinator.jumpToLatestNotification()` uses for the
    /// Attention Beacon's own 1-click jump — reused here for a fleet row click.
    private func focusFleetSession(_ item: FleetSessionItem) {
        guard let tabID = UUID(uuidString: item.tabID) else { return }
        let coord = SessionCoordinator.shared
        coord.selectWorkspace(item.workspaceID)
        coord.selectTab(workspaceID: item.workspaceID, tabID: tabID)
        if let surfaceID = coord.splitPaneCoordinator.firstSurfaceID(forTab: tabID) {
            coord.setActiveSurface(surfaceID)
            coord.terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    /// Resumes in a new tab inside the current session — the original one-button behavior.
    /// Fastest option, but shares the current session's worktree/branch (if any).
    private func resumeAgentSession(_ record: AgentSessionRecord) {
        let cmd = record.agentKind.resumeCommand(sessionID: record.id)
        let req = DefaultTerminalLaunchRequest(
            command: cmd,
            cwd: record.projectPath,
            title: "\(record.agentKind.displayName): \(record.projectName)"
        )
        SessionCoordinator.shared.sessionLifecycleService.openDefaultTerminalLaunch(req)
    }

    /// Resumes inside a fresh, isolated git worktree — same idea as P32's explicit
    /// task-worktree creation (`addAgentTask`), just seeded with a resume command instead of
    /// a blank shell. Requires the session's original project to be a git repo.
    private func resumeAgentSessionInWorktree(_ record: AgentSessionRecord) {
        guard let workspaceID = SessionCoordinator.shared.snapshot.activeWorkspace?.id else { return }
        let manager = WorktreeManager()
        guard let repoPath = manager.repoRoot(for: record.projectPath) else {
            let alert = NSAlert()
            alert.messageText = "Can't resume in worktree"
            alert.informativeText = "\(record.projectPath) isn't inside a git repository."
            alert.runModal()
            return
        }

        let sanitizedBranch = "resume-\(record.id)"
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9-]+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        guard let worktreePath = manager.create(repoPath: repoPath, sessionID: sanitizedBranch, branch: sanitizedBranch) else {
            let alert = NSAlert()
            alert.messageText = "Can't resume in worktree"
            alert.informativeText = "Failed to create a worktree for this session (it may already exist)."
            alert.runModal()
            return
        }

        SessionCoordinator.shared.addSession(
            to: workspaceID,
            cwd: worktreePath,
            name: "Resume: \(record.title)",
            worktreePath: worktreePath,
            parentRepoPath: repoPath,
            initialCommand: record.agentKind.resumeCommand(sessionID: record.id)
        )
    }

    /// Resumes as a brand-new session (own tab-group in the sidebar) at the session's original
    /// path, without touching git — for keeping the resumed conversation separate from
    /// whatever's already open, without the isolation overhead of a worktree.
    private func continueAgentSessionInNewSession(_ record: AgentSessionRecord) {
        guard let workspaceID = SessionCoordinator.shared.snapshot.activeWorkspace?.id else { return }
        SessionCoordinator.shared.addSession(
            to: workspaceID,
            cwd: record.projectPath,
            name: "Resume: \(record.title)",
            initialCommand: record.agentKind.resumeCommand(sessionID: record.id)
        )
    }

    // Issues tab disabled across the system
    /*
    private func setupIssuesView() {
        let hosting = NSHostingView(rootView: IssueTrackerPanelView())
        hosting.translatesAutoresizingMaskIntoConstraints = false
        hosting.isHidden = true
        issueTrackerHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: sectionLabelHostingView.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: footerHostingView.topAnchor),
        ])
    }
    */

    @objc private func handleOpenGitPanel(_ note: Notification) {
        SessionCoordinator.shared.openLazygit(direction: .horizontal)
    }

    /// Opens Lazygit in a split pane.
    func selectGitTab() {
        SessionCoordinator.shared.openLazygit(direction: .horizontal)
    }

    /// Scrolls/highlights `path` in the file tree in the background — unlike
    /// `selectFilesTab(revealPath:)`, does not switch sidebar sections or force it visible.
    /// Mirrors the passive cwd-follow in `reload()`, for callers (e.g. `kouen cat`/`view`) that
    /// want the tree ready without yanking focus off whatever section is currently showing.
    func revealFileInTreeQuietly(path: String) {
        let parentDir = (path as NSString).deletingLastPathComponent
        let root = WorktreeManager().repoRoot(for: parentDir) ?? parentDir
        let activeSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
        fileTreeView.updateRoot(path: root, sessionID: activeSessionID)
        fileTreeView.revealFileInTree(path: path)
    }

    /// Switches the sidebar to the Files tab and reveals `path` in the file tree
    /// (expands ancestors, highlights the row, and scrolls to it).
    func selectFilesTab(revealPath path: String) {
        sidebarSectionModel.selectedTab = 1
        selectSidebarTab(index: 1)
        // Ensure the tree is shown, not the inline file viewer.
        fileViewerVC.view.isHidden = true
        fileTreeView.isHidden = false
        fileTreeView.revealFileInTree(path: path)
    }

    func previewFile(path: String) {
        sidebarSectionModel.selectedTab = 1
        selectSidebarTab(index: 1)
        fileTreeView.isHidden = true
        fileViewerVC.view.isHidden = false
        fileViewerVC.load(path: path)
    }

    /// Full "Open With" entry point: shows file in viewer AND routes the terminal to the
    /// project root (git root if found, else file's parent). The snapshot update that follows
    /// addSession/selectSession wires the file tree root automatically.
    func openExternalFile(path: String) {
        let expanded = (path as NSString).expandingTildeInPath
        let cwd = Self.gitRoot(for: expanded) ?? (expanded as NSString).deletingLastPathComponent
        previewFile(path: expanded)
        guard let wsID = activeWorkspaceID else { return }
        if let existing = sessions.first(where: { $0.tabs.contains(where: { $0.cwd == cwd }) }) {
            SessionCoordinator.shared.selectSession(workspaceID: wsID, sessionID: existing.id)
        } else {
            Self.recordRecentProject(cwd)
            SessionCoordinator.shared.addSession(to: wsID, cwd: cwd, name: (cwd as NSString).lastPathComponent)
        }
    }

    private static func gitRoot(for path: String) -> String? {
        var dir = (path as NSString).deletingLastPathComponent
        while dir != "/" {
            if FileManager.default.fileExists(atPath: dir + "/.git") { return dir }
            let parent = (dir as NSString).deletingLastPathComponent
            if parent == dir { break }
            dir = parent
        }
        return nil
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
        sessionHostingView?.isHidden = index != 0
        if index != 1 {
            // Leaving the Files tab: collapse any open preview back to the tree
            // so returning to Files always starts from the file list.
            fileViewerVC.view.isHidden = true
            fileTreeView.isHidden = true
        } else {
            fileTreeView.isHidden = fileViewerVC.view.isHidden == false
        }
        jobsHostingView?.isHidden = index != 2
        sessionHistoryHostingView?.isHidden = index != 3
        // issueTrackerHostingView?.isHidden = index != 4  // Issues tab disabled — see TODO in viewDidLoad
        fleetHostingView?.isHidden = index != 5
        switch index {
        case 1:
            sidebarSectionModel.text = "FILES"
            sidebarSectionModel.isRepoHeader = false
            if let cwd = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd {
                let activeSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
                let root = WorktreeManager().repoRoot(for: cwd) ?? cwd
                fileTreeView.updateRoot(path: root, sessionID: activeSessionID)
                fileTreeView.revealFileInTree(path: cwd)
            }
        case 2:
            sidebarSectionModel.text = "JOBS"
            sidebarSectionModel.isRepoHeader = false
            Task { @MainActor in
                await self.jobsModel.load()
            }
        case 3:
            sidebarSectionModel.text = "SESSION HISTORY"
            sidebarSectionModel.isRepoHeader = false
            sessionHistoryModel.refresh(force: false)
        // case 4:
        //     sidebarSectionModel.text = "ISSUES"
        //     sidebarSectionModel.isRepoHeader = false
        case 5:
            sidebarSectionModel.text = "FLEET"
            sidebarSectionModel.isRepoHeader = false
            fleetModel.refresh(from: SessionCoordinator.shared.snapshot, activeSurfaceID: SessionCoordinator.shared.activeSurfaceID)
        default:
            sidebarSectionModel.isRepoHeader = true
            updateRepoSectionHeader()
        }
    }

    func promptNewAutomation() {
        let alert = NSAlert()
        alert.messageText = "New Scheduled Job"
        alert.informativeText = "Run background agent tasks periodically or on demand."
        alert.addButton(withTitle: "Create Job")
        alert.addButton(withTitle: "Cancel")

        let container = NSStackView()
        container.orientation = .vertical
        container.alignment = .leading
        container.spacing = 8
        container.frame = NSRect(x: 0, y: 0, width: 280, height: 115)

        let promptLabel = NSTextField(labelWithString: "Task / Prompt:")
        promptLabel.font = .systemFont(ofSize: 11, weight: .medium)
        let promptInput = NSTextField(frame: NSRect(x: 0, y: 0, width: 280, height: 22))
        promptInput.placeholderString = "e.g. Run test suite & report failures"

        let agentHStack = NSStackView()
        agentHStack.orientation = .horizontal
        agentHStack.spacing = 8
        let agentLabel = NSTextField(labelWithString: "AI Agent:")
        agentLabel.font = .systemFont(ofSize: 11, weight: .medium)
        let agentPopup = NSPopUpButton()
        agentPopup.addItems(withTitles: ["Claude (claude)", "Codex (codex)", "Gemini (gemini)", "Auto-Routed (auto)"])

        let intervalHStack = NSStackView()
        intervalHStack.orientation = .horizontal
        intervalHStack.spacing = 8
        let intervalLabel = NSTextField(labelWithString: "Schedule:")
        intervalLabel.font = .systemFont(ofSize: 11, weight: .medium)
        let intervalPopup = NSPopUpButton()
        intervalPopup.addItems(withTitles: [
            "Manual (On-demand only)",
            "Every 15 minutes",
            "Every 30 minutes",
            "Every 1 hour",
            "Every 2 hours",
            "Every 24 hours"
        ])

        agentHStack.addArrangedSubview(agentLabel)
        agentHStack.addArrangedSubview(agentPopup)
        intervalHStack.addArrangedSubview(intervalLabel)
        intervalHStack.addArrangedSubview(intervalPopup)

        container.addArrangedSubview(promptLabel)
        container.addArrangedSubview(promptInput)
        container.addArrangedSubview(agentHStack)
        container.addArrangedSubview(intervalHStack)

        alert.accessoryView = container
        alert.window.initialFirstResponder = promptInput

        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let prompt = promptInput.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        let agentKinds = ["claude", "codex", "gemini", "auto"]
        let chosenAgent = agentKinds[max(0, min(agentPopup.indexOfSelectedItem, agentKinds.count - 1))]

        let intervals = [0, 15, 30, 60, 120, 1440]
        let chosenInterval = intervals[max(0, min(intervalPopup.indexOfSelectedItem, intervals.count - 1))]

        let coordinator = SessionCoordinator.shared
        let cwd = coordinator.snapshot.activeWorkspace?.activeTab?.cwd ?? FileManager.default.currentDirectoryPath
        let repo = WorktreeManager().repoRoot(for: cwd) ?? cwd
        let wsID = coordinator.snapshot.activeWorkspaceID

        Task { @MainActor in
            await coordinator.requestDaemon(.automationCreate(
                repoPath: repo,
                workspaceID: wsID,
                agent: chosenAgent,
                prompt: prompt,
                intervalMinutes: chosenInterval
            ))
            await self.jobsModel.load()
        }
    }

    private func setupFooterView() {
        let hosting = NSHostingView(rootView: SidebarFooterView(
            model: sidebarFooterModel,
            onTasks: { [weak self] in self?.showTaskDashboard() },
            onAddAPIKey: {
                SettingsModelsFocus.request(.anthropic)
                SettingsWindowController.show(page: SettingsRootView.Page.models.rawValue)
            },
            onNewSession: { [weak self] in self?.addSession() },
            onPalette: { [weak self] in self?.openPalette() }
        ))
        hosting.translatesAutoresizingMaskIntoConstraints = false
        footerHostingView = hosting
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.heightAnchor.constraint(equalToConstant: KouenDesign.footerHeight + 6),
        ])
    }

    // MARK: - Drop Target & Project Management (Orca Session == Project)

    private func setupDropTarget() {
        let dropTarget = ProjectDropTarget(frame: .zero)
        dropTarget.translatesAutoresizingMaskIntoConstraints = false
        dropTarget.layer?.zPosition = 1   // behind all interactive subviews
        dropTarget.onDrop = { [weak self] path in
            guard let self else { return }
            let scan = FolderScanner.inspect(path: path)
            if scan.isMultiRepo {
                self.presentCategorySheet(for: path)
            } else {
                self.finalizeAddProject(paths: [path], categoryID: nil)
            }
        }
        projectDropTarget = dropTarget
        view.addSubview(dropTarget, positioned: .below, relativeTo: nil)
        NSLayoutConstraint.activate([
            dropTarget.topAnchor.constraint(equalTo: view.topAnchor),
            dropTarget.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dropTarget.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dropTarget.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func addProjectToGroup(name: String, categoryID: String?) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Add to \(name)"
        panel.message = "Choose a project folder to add to \(name)"
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            DispatchQueue.main.async {
                guard let self else { return }
                let scan = FolderScanner.inspect(path: url.path)
                if scan.isMultiRepo {
                    self.presentCategorySheet(for: url.path)
                } else {
                    self.projectStore.addProject(url.path, categoryID: categoryID)
                    self.sidebarListModel.update(from: SessionCoordinator.shared.snapshot)
                }
            }
        }
    }

    private func openRecentPath(_ path: String) {
        guard let id = activeWorkspaceID else { return }
        if let existing = sessions.first(where: { $0.tabs.contains(where: { $0.cwd == path }) }) {
            SessionCoordinator.shared.selectSession(workspaceID: id, sessionID: existing.id)
            return
        }
        Self.recordRecentProject(path)
        SessionCoordinator.shared.addSession(to: id, cwd: path, name: (path as NSString).lastPathComponent)
    }

    @objc func reload() {
        let snap = SessionCoordinator.shared.snapshot
        workspaces = snap.workspaces
        activeWorkspaceID = snap.activeWorkspaceID
        let newActiveSessionID = snap.activeWorkspace?.activeSessionID
        activeSessionID = newActiveSessionID
        sessions = snap.activeWorkspace?.sessions ?? []
        let name = snap.activeWorkspace?.name ?? "Workspace"
        workspacePillModel.name = name
        sidebarListModel.update(from: snap)
        sidebarListModel.updateWorktrees()

        if let cwd = snap.activeWorkspace?.activeTab?.cwd {
            let activeSessionID = snap.activeWorkspace?.activeSessionID
            let gitBranch = snap.activeWorkspace?.activeTab?.gitBranch
            let sessionChanged = activeSessionID != lastFileTreeSessionID
            if sessionChanged {
                lastFileTreeGitBranch = nil
                lastFileTreeCWD = nil
            }

            NSLog("[DBG-activestate] reload() cwd=\(cwd) activeSessionID=\(activeSessionID?.uuidString ?? "nil") sessionChanged=\(sessionChanged)")
            let root = WorktreeManager().repoRoot(for: cwd) ?? cwd
            fileTreeView.updateRoot(path: root, sessionID: activeSessionID)
            if cwd != lastFileTreeCWD {
                fileTreeView.revealFileInTree(path: cwd)
                lastFileTreeCWD = cwd
            }
            lastFileTreeSessionID = activeSessionID
            lastFileTreeGitBranch = gitBranch
            let home = NSHomeDirectory()
            if cwd != home, cwd != "/" {
                Self.recordRecentProject(cwd)
            }
        } else {
            NSLog("[DBG-activestate] reload() no activeTab.cwd — clearing root")
        }
        updateRepoSectionHeader()

        // Fleet tab has no other refresh trigger — sessionHistory/jobs only refresh on
        // tab-select, but a new/closed tab while Fleet is the visible tab should show up
        // immediately, the same way the Sessions list itself does via this same reload().
        if sidebarSectionModel.selectedTab == 5 {
            fleetModel.refresh(from: snap, activeSurfaceID: SessionCoordinator.shared.activeSurfaceID)
        }
    }

    /// Updates session card labels in place (title/cwd/branch/agent) without
    /// rebuilding the table — preserves selection + scroll position.
    @objc func refreshMetadata() {
        let snap = SessionCoordinator.shared.snapshot
        let newSessions = snap.activeWorkspace?.sessions ?? []
        let activeID = snap.activeWorkspace?.activeSessionID
        NSLog("[DBG-activestate] refreshMetadata() cwd=\(snap.activeWorkspace?.activeTab?.cwd ?? "nil") activeSessionID=\(activeID?.uuidString ?? "nil")")
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
        workspacePillModel.name = name
        if let cwd = snap.activeWorkspace?.activeTab?.cwd {
            let activeSessionID = snap.activeWorkspace?.activeSessionID
            let gitBranch = snap.activeWorkspace?.activeTab?.gitBranch
            let sessionChanged = activeSessionID != lastFileTreeSessionID
            if sessionChanged {
                lastFileTreeGitBranch = nil
                lastFileTreeCWD = nil
            }
            let branchChanged = gitBranch != lastFileTreeGitBranch
            if sessionChanged || branchChanged {
                let root = WorktreeManager().repoRoot(for: cwd) ?? cwd
                fileTreeView.updateRoot(path: root, sessionID: activeSessionID)
            }
            if cwd != lastFileTreeCWD {
                fileTreeView.revealFileInTree(path: cwd)
                lastFileTreeCWD = cwd
            }
            lastFileTreeSessionID = activeSessionID
            lastFileTreeGitBranch = gitBranch
        }
        // Rebuild cache once; iterate the stored result — no redundant recomputation.
        // Skip entirely when session data hasn't changed (common on metadata-only ticks).
        // SwiftUI model sync — always update so badges/agent status stay fresh
        sidebarListModel.update(from: snap)

        updateRepoSectionHeader()
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
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        panel.message = "Choose a project folder"
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            DispatchQueue.main.async {
                guard let self else { return }
                let scan = FolderScanner.inspect(path: url.path)
                if scan.isMultiRepo {
                    self.presentCategorySheet(for: url.path)
                } else {
                    self.finalizeAddProject(paths: [url.path], categoryID: nil)
                }
            }
        }
    }

    /// Shows the unified AddToWorkspaceSheet (auto-detecting group folder vs single project)
    /// and adds all chosen projects to the tree and active workspace.
    func presentCategorySheet(for path: String) {
        let scan = FolderScanner.inspect(path: path)
        guard scan.isMultiRepo else {
            finalizeAddProject(paths: [path], categoryID: nil)
            return
        }
        guard let window = view.window else {
            finalizeAddProject(paths: [path], categoryID: nil)
            return
        }
        let sheet = AddToWorkspaceSheet(
            folderPath: path,
            store: projectStore,
            onConfirm: { [weak self] chosenPaths, categoryID in
                window.endSheet(window.attachedSheet ?? window)
                self?.finalizeAddProject(paths: chosenPaths, categoryID: categoryID)
            },
            onCancel: {
                window.endSheet(window.attachedSheet ?? window)
            }
        )
        let controller = NSHostingController(rootView: sheet)
        let sheetWindow = NSWindow(contentViewController: controller)
        sheetWindow.styleMask = [.titled, .closable]
        window.beginSheet(sheetWindow) { _ in }
    }

    private func finalizeAddProject(paths: [String], categoryID: String?) {
        guard let id = activeWorkspaceID else { return }
        for (index, p) in paths.enumerated() {
            projectStore.addProject(p, categoryID: categoryID)
            if index == 0 && sessions.isEmpty {
                SessionCoordinator.shared.addSession(to: id, cwd: p, name: (p as NSString).lastPathComponent)
            }
        }
        sidebarListModel.update(from: SessionCoordinator.shared.snapshot)
    }

    private func addSessionInGroup(rootPath: String) {
        guard let activeWorkspaceID else { return }
        let name = KouenDesign.pathDisplayName(rootPath)
        Self.recordRecentProject(rootPath)
        SessionCoordinator.shared.addSession(to: activeWorkspaceID, cwd: rootPath, name: name)
    }

    // MARK: - Git & Worktrees Helpers

    private func fetchRepoName(for path: String) async -> String {
        let folderName = KouenDesign.projectGroupName(for: path)
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
            process.standardError = FileHandle.nullDevice
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

    private func updateRepoSectionHeader() {
        guard sidebarSectionModel.selectedTab == 0 else { return }
        let path = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? ""
        if path.isEmpty {
            self.sidebarSectionModel.text = "SESSIONS"
            return
        }
        // Skip the git subprocess when the active path hasn't changed and we fetched recently.
        let now = Date()
        guard path != lastRepoHeaderPath || now.timeIntervalSince(lastRepoHeaderFetch) > 5 else { return }
        lastRepoHeaderPath = path
        lastRepoHeaderFetch = now
        Task {
            let repoName = await fetchRepoName(for: path)
            await MainActor.run {
                if self.sidebarSectionModel.selectedTab == 0 {
                    self.sidebarSectionModel.text = repoName.hasSuffix("/") ? repoName : "\(repoName)/"
                }
            }
        }
    }

}

extension Notification.Name {
    static let kouenOpenGitPanel = Notification.Name("KouenOpenGitPanel")
}

