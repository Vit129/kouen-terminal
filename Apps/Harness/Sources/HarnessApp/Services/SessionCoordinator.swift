import AppKit
import Foundation
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit
import HarnessTheme
import UserNotifications

@MainActor
final class SessionCoordinator: NSObject {
    static let shared = SessionCoordinator()

    // MARK: - Services

    private(set) lazy var daemonSyncService: DaemonSyncService = DaemonSyncService(coordinator: self)
    private(set) lazy var splitPaneCoordinator: SplitPaneCoordinator = SplitPaneCoordinator(coordinator: self)
    private(set) lazy var sessionLifecycleService: SessionLifecycleService = SessionLifecycleService(coordinator: self)
    private(set) lazy var notificationCoordinator: NotificationCoordinator = NotificationCoordinator(coordinator: self)
    private(set) lazy var themeService: ThemeService = ThemeService(coordinator: self)
    private(set) lazy var activePaneService: ActivePaneService = ActivePaneService(coordinator: self)

    // MARK: - State

    var snapshot: SessionSnapshot { daemonSyncService.snapshot }
    var settings = HarnessSettings.load()
    private(set) var activeEndpoint: Endpoint = .localControlSocket
    var activeSurfaceID: SurfaceID?
    var lastActiveSurfaceID: SurfaceID?
    var suppressActivePaneSync = false
    var structureRevision = 0
    var appliedThemeKey = ""
    var surfaceIndex: [SurfaceID: (tab: Tab, tabID: TabID)] = [:]
    var lastClosedTab: (cwd: String, title: String)?
    let terminalHosts = TerminalPaneRegistry()
    private var lastDaemonErrorNotice: Date?

    var activeTabCWD: String? {
        guard let cwd = snapshot.activeWorkspace?.activeTab?.cwd, !cwd.isEmpty else { return nil }
        return cwd
    }

    private override init() {
        super.init()
        observeNotifications()
        _ = daemonSyncService; _ = notificationCoordinator
        _ = splitPaneCoordinator; _ = sessionLifecycleService
        _ = themeService; _ = activePaneService
        daemonSyncService.startMetadataRefresh()
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(snapshotChangedNotification(_:)),
            name: NotificationBus.shared.snapshotChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationPosted(_:)),
            name: NotificationBus.shared.notificationPosted, object: nil)
    }

    @objc private func snapshotChangedNotification(_ note: Notification) {
        let revision = note.userInfo?["revision"] as? Int ?? -1
        guard revision != daemonSyncService.lastRevision,
              revision != daemonSyncService.pendingSnapshotRevision else { return }
        daemonSyncService.pendingSnapshotRevision = revision
        daemonSyncService.scheduleSnapshotRefresh()
    }

    @objc private func notificationPosted(_ note: Notification) {
        guard note.userInfo?["notification"] is AgentNotification else { return }
        NotificationCenter.default.post(name: NotificationBus.shared.tabStatusChanged, object: nil)
    }

    // MARK: - Remote daemon

    func connectToRemote(named name: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var resolved: Endpoint?; var failureMessage: String?
            do { resolved = try RemoteHostsService.shared.connect(named: name) }
            catch { failureMessage = "\(error)" }
            let endpoint = resolved; let message = failureMessage
            Task { @MainActor in
                guard let self else { return }
                if let endpoint { self.applyEndpointSwitch(endpoint) }
                else { self.noteDaemonError(DaemonSessionError.daemonError(message ?? "connection failed")) }
            }
        }
    }

    func disconnectRemote() {
        RemoteHostsService.shared.disconnect()
        applyEndpointSwitch(.localControlSocket)
    }

    private func applyEndpointSwitch(_ endpoint: Endpoint) {
        activeEndpoint = endpoint
        daemonSyncService.switchEndpoint(endpoint)
        terminalHosts.prune(keeping: [])
        _ = syncFromDaemon()
    }

    // MARK: - Sync (facade → DaemonSyncService)

    @discardableResult func syncFromDaemon(metadataOnly: Bool = false) -> Bool {
        daemonSyncService.sync(metadataOnly: metadataOnly)
    }
    @discardableResult func syncFromDaemon(metadataOnly: Bool = false) async -> Bool {
        await daemonSyncService.sync(metadataOnly: metadataOnly)
    }
    func closeEphemeralSessionsBeforeQuit() { daemonSyncService.closeEphemeralSessionsBeforeQuit() }
    func saveImmediately() { syncFromDaemon() }

    @discardableResult func requestDaemon(_ request: IPCRequest) -> IPCResponse? {
        daemonSyncService.request(request)
    }
    @discardableResult func requestDaemon(_ request: IPCRequest) async -> IPCResponse? {
        await daemonSyncService.request(request)
    }

    func noteDaemonError(_ error: Error) {
        let now = Date()
        if let last = lastDaemonErrorNotice, now.timeIntervalSince(last) < 8 { return }
        lastDaemonErrorNotice = now
        guard let host = (NSApp.keyWindow ?? NSApp.mainWindow)?.contentView else { return }
        Toast.show("Reconnecting to HarnessDaemon…", in: host)
    }

    // MARK: - Session lifecycle (facade → SessionLifecycleService)

    func addWorkspace(name: String) { sessionLifecycleService.addWorkspace(name: name) }
    func addSession(to workspaceID: WorkspaceID, cwd: String? = nil, name: String? = nil) {
        sessionLifecycleService.addSession(to: workspaceID, cwd: cwd, name: name)
    }
    func addTab(to workspaceID: WorkspaceID, cwd: String? = nil) { sessionLifecycleService.addTab(to: workspaceID, cwd: cwd) }
    func openDefaultTerminalLaunch(_ launch: DefaultTerminalLaunchRequest) { sessionLifecycleService.openDefaultTerminalLaunch(launch) }
    func selectWorkspace(_ id: WorkspaceID) { sessionLifecycleService.selectWorkspace(id) }
    func selectSession(workspaceID: WorkspaceID, sessionID: SessionID) { sessionLifecycleService.selectSession(workspaceID: workspaceID, sessionID: sessionID) }
    func selectTab(workspaceID: WorkspaceID, tabID: TabID) { sessionLifecycleService.selectTab(workspaceID: workspaceID, tabID: tabID) }
    func selectAdjacentSession(offset: Int) { sessionLifecycleService.selectAdjacentSession(offset: offset) }
    func moveActiveSession(offset: Int) { sessionLifecycleService.moveActiveSession(offset: offset) }
    func closeActiveTab() { sessionLifecycleService.closeActiveTab() }
    func closeActiveTabWithConfirmation() { sessionLifecycleService.closeActiveTabWithConfirmation() }
    func closeActiveSession() { sessionLifecycleService.closeActiveSession() }
    func closeSession(_ session: SessionGroup) { sessionLifecycleService.closeSession(session) }
    func openTabInActiveWorkspace() { sessionLifecycleService.openTabInActiveWorkspace() }
    func closeOtherTabs(keeping keepID: TabID) { sessionLifecycleService.closeOtherTabs(keeping: keepID) }
    func closeTabs(under path: String) async { await sessionLifecycleService.closeTabs(under: path) }
    func reopenLastClosedTab() { sessionLifecycleService.reopenLastClosedTab() }
    var canReopenClosedTab: Bool { lastClosedTab != nil }
    func closeActiveWorkspace() { sessionLifecycleService.closeActiveWorkspace() }
    func closeWorkspace(id: WorkspaceID) { sessionLifecycleService.closeWorkspace(id: id) }

    // MARK: - Split pane (facade → SplitPaneCoordinator)

    func splitActivePane(direction: SplitDirection) { splitPaneCoordinator.splitActivePane(direction: direction) }
    func splitActivePaneAndRun(direction: SplitDirection, command: String) { splitPaneCoordinator.splitActivePaneAndRun(direction: direction, command: command) }
    func focusPaneDirectional(_ direction: DirectionalAxis) { splitPaneCoordinator.focusPaneDirectional(direction) }
    func splitPaneSurface(tabID: TabID, sourcePaneID: PaneID, surfaceID: SurfaceID, targetPaneID: PaneID, direction: SplitDirection, beforeTarget: Bool) {
        splitPaneCoordinator.splitPaneSurface(tabID: tabID, sourcePaneID: sourcePaneID, surfaceID: surfaceID, targetPaneID: targetPaneID, direction: direction, beforeTarget: beforeTarget)
    }
    func splitTab(workspaceID: WorkspaceID, tabID: TabID, direction: SplitDirection) { splitPaneCoordinator.splitTab(workspaceID: workspaceID, tabID: tabID, direction: direction) }
    func splitSession(workspaceID: WorkspaceID, sessionID: SessionID, direction: SplitDirection) { splitPaneCoordinator.splitSession(workspaceID: workspaceID, sessionID: sessionID, direction: direction) }
    func killActivePane() { splitPaneCoordinator.killActivePane() }

    /// Close active pane (⌘W behavior): if single pane → close tab; otherwise kill pane.
    func closeActivePane() {
        if case .leaf = snapshot.activeWorkspace?.activeTab?.rootPane {
            closeActiveTab()
        } else {
            killActivePane()
        }
    }
    func killPane(paneID: PaneID) { splitPaneCoordinator.killPane(paneID: paneID) }
    func paneID(for surfaceID: SurfaceID, in node: PaneNode) -> PaneID? { splitPaneCoordinator.paneID(for: surfaceID, in: node) }
    func firstSurfaceID(forTab tabID: TabID) -> SurfaceID? { splitPaneCoordinator.firstSurfaceID(forTab: tabID) }

    // MARK: - Notifications (facade → NotificationCoordinator)

    func jumpToLatestNotification() { notificationCoordinator.jumpToLatestNotification() }
    func isSurfaceWaiting(_ surfaceID: UUID) -> Bool { notificationCoordinator.isSurfaceWaiting(surfaceID) }
    func notificationsList() -> [NotificationEntry] { notificationCoordinator.notificationsList() }
    func agentsList() -> [AgentSessionSummary] { notificationCoordinator.agentsList() }
    func openAgent(_ agent: AgentSessionSummary) { notificationCoordinator.openAgent(agent) }
    func openNotification(_ entry: NotificationEntry) { notificationCoordinator.openNotification(entry) }
    func clearNotification(surfaceID: SurfaceID) { notificationCoordinator.clearNotification(surfaceID: surfaceID) }
    func clearAllNotifications() { notificationCoordinator.clearAllNotifications() }
    func handleNotification(for surfaceID: SurfaceID, event: NotificationEvent, title: String, body: String) { notificationCoordinator.handleNotification(for: surfaceID, event: event, title: title, body: body) }
    func syncWaitingRings() { notificationCoordinator.syncWaitingRings() }

    // MARK: - Theme (facade → ThemeService)

    func applySettingsToHosts() { themeService.applySettingsToHosts() }
    func applyThemeToAllHosts() { themeService.applyThemeToAllHosts() }
    func setTheme(_ name: String, seedColors: Bool = true) { themeService.setTheme(name, seedColors: seedColors) }
    func applyImportedTheme(_ document: ThemeDocument) { themeService.applyImportedTheme(document) }
    func applyAutoThemeForCurrentAppearance() { themeService.applyAutoThemeForCurrentAppearance() }
    func reimportTerminalConfig() { themeService.reimportTerminalConfig() }

    static var isSystemAppearanceDark: Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }

    // MARK: - Active pane (facade → ActivePaneService)

    func setActiveSurface(_ surfaceID: SurfaceID?) { activePaneService.setActiveSurface(surfaceID) }
    func reflectRemoteActivePane() { activePaneService.reflectRemoteActivePane() }
    func refreshPaneStyles() { activePaneService.refreshPaneStyles() }
    func refreshPaneBorders() { activePaneService.refreshPaneBorders() }
    func setMarkedPane(_ set: Bool) { activePaneService.setMarkedPane(set) }
    var markedSurfaceID: SurfaceID? { activePaneService.markedSurfaceID }
    func reassertMarkedPane() { activePaneService.reassertMarkedPane() }
    func setSynchronizePanes(_ on: Bool?) { activePaneService.setSynchronizePanes(on) }
    func adoptSynchronizeOptions() { activePaneService.adoptSynchronizeOptions() }
    func refreshSyncSiblings() { activePaneService.refreshSyncSiblings() }
    func zoomActivePane() { activePaneService.zoomActivePane() }
    func cycleActivePane(forward: Bool) { activePaneService.cycleActivePane(forward: forward) }
    func ensureActivePane(for tab: Tab) { activePaneService.ensureActivePane(for: tab) }
    func selectLastPane() { activePaneService.selectLastPane() }

    // MARK: - Pane operations (kept here — use coordinator state directly)

    func joinMarkedPane(direction: SplitDirection) {
        guard let markedSurface = activePaneService.markedSurfaceID,
              let tab = snapshot.activeWorkspace?.activeTab,
              let activeSurface = activeSurfaceID,
              let destPane = paneID(for: activeSurface, in: tab.rootPane)
        else { DisplayMessage.show("join-pane: no marked pane"); return }
        let sourcePane = snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs)
            .compactMap { paneID(for: markedSurface, in: $0.rootPane) }.first
        guard let sourcePane, sourcePane != destPane else { DisplayMessage.show("join-pane: invalid mark"); return }
        _ = requestDaemon(.joinPane(sourcePaneID: sourcePane, destPaneID: destPane, direction: direction))
        setMarkedPane(false)
        syncFromDaemon()
    }

    func setSplitRatio(tabID: TabID, firstPaneID: PaneID, secondPaneID: PaneID, ratio: Double) {
        requestDaemon(.resizePaneRatio(tabID: tabID, firstPaneID: firstPaneID, secondPaneID: secondPaneID, ratio: ratio))
        syncFromDaemon(metadataOnly: true)
    }

    func showDisplayPanes() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let panes = tab.rootPane.allSurfaceIDs().enumerated().compactMap { index, sid -> (number: Int, host: TerminalHostView)? in
            guard let host = terminalHosts.host(for: sid) else { return nil }
            return (number: index, host: host)
        }
        DisplayPanesOverlay.shared.show(panes: panes) { [weak self] surfaceID in
            self?.setActiveSurface(surfaceID)
            self?.terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    func reorderSession(workspaceID: WorkspaceID, sessionID: SessionID, toIndex: Int) {
        requestDaemon(.reorderSession(workspaceID: workspaceID, sessionID: sessionID, toIndex: toIndex))
        syncFromDaemon()
    }

    func renameWorkspace(id: WorkspaceID, name: String) {
        requestDaemon(.renameWorkspace(workspaceID: id, name: name))
        syncFromDaemon()
    }

    func reorderTab(workspaceID: WorkspaceID, tabID: TabID, toIndex: Int) {
        requestDaemon(.reorderTab(workspaceID: workspaceID, tabID: tabID, toIndex: toIndex))
        syncFromDaemon()
    }

    func newSurface(tabID: TabID, paneID: PaneID) {
        Task {
            guard case let .surfaceID(raw)? = await requestDaemon(.newSurface(tabID: tabID, paneID: paneID, shell: settings.defaultShell)),
                  let surfaceID = UUID(uuidString: raw)
            else { await syncFromDaemon(); return }
            await syncFromDaemon()
            setActiveSurface(surfaceID)
            terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    func selectPaneSurface(tabID: TabID, paneID: PaneID, surfaceID: SurfaceID) {
        Task {
            await requestDaemon(.selectPaneSurface(tabID: tabID, paneID: paneID, surfaceID: surfaceID))
            await syncFromDaemon()
            setActiveSurface(surfaceID)
            terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    // MARK: - Terminal host management

    func terminalHostIfExists(for surfaceID: SurfaceID) -> TerminalHostView? { terminalHosts.host(for: surfaceID) }

    func terminalHost(for surfaceID: SurfaceID, cwd: String) -> TerminalHostView {
        if let existing = terminalHosts.host(for: surfaceID) { return existing }
        let host = TerminalHostView(
            surfaceID: surfaceID, workingDirectory: cwd,
            harnessSurfaceEnv: surfaceID.uuidString, settings: settings,
            themeName: snapshot.themeName, endpoint: activeEndpoint
        )
        host.hostDelegate = self
        host.applyTheme(named: snapshot.themeName)
        host.applySettings(settings)
        themeService.applyTerminalIdentity(to: host)
        themeService.pushBorderColors(to: host)
        terminalHosts.register(host)
        return host
    }

    // MARK: - Find bar / Copy mode / Detach / Prompts

    func toggleFindBar() {
        guard let surfaceID = activeSurfaceID, let host = terminalHosts.host(for: surfaceID) else { return }
        host.toggleFind()
    }

    func toggleCopyMode() {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        if host.isInCopyMode { host.exitCopyMode() }
        else { host.enterCopyMode(modeKeys: HarnessOptions.shared.get("mode-keys", scope: .global)?.stringValue ?? "vi") }
    }

    func performCopyModeAction(_ action: CopyModeAction) {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.performCopyModeAction(action)
    }

    func detachActiveSurface() {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.detachFromDaemonSurface()
    }

    func reattachActiveSurface() {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.reattachToDaemonSurface()
    }

    var activePaneIsDetached: Bool {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return false }
        return host.isDetachedFromDaemon
    }

    func jumpToPreviousPrompt() {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.jumpToPreviousPrompt()
    }

    func jumpToNextPrompt() {
        guard let surfaceID = activeSurfaceID, let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.jumpToNextPrompt()
    }

    // MARK: - Misc

    func paneBorderContext(forSurface surfaceID: SurfaceID) -> FormatContext {
        let owningTab = surfaceIndex[surfaceID]?.tab
        let paneIndex = owningTab.flatMap { tab in tab.rootPane.allSurfaceIDs().firstIndex(of: surfaceID) }
        return FormatContext(
            paneID: surfaceID.uuidString, paneTitle: owningTab?.title, paneCwd: owningTab?.cwd,
            paneActive: surfaceID == activeSurfaceID, paneIndex: paneIndex,
            tabName: owningTab?.title, workspaceName: snapshot.activeWorkspace?.name,
            agentKind: owningTab?.agent?.kind.rawValue, agentChip: owningTab?.agent?.kind.chip,
            gitBranch: owningTab?.gitBranch, clientName: "Harness.app"
        )
    }

    func currentFormatContext() -> FormatContext {
        let workspace = snapshot.activeWorkspace
        let session = workspace?.activeSession
        let tab = workspace?.activeTab
        var context = FormatContext(
            paneID: activeSurfaceID?.uuidString, paneTitle: tab?.title, paneCwd: tab?.cwd,
            paneActive: activeSurfaceID != nil, paneIndex: nil,
            sessionName: session?.name.isEmpty == false ? session?.name : nil,
            tabName: tab?.title, tabIndex: session?.tabs.firstIndex(where: { $0.id == tab?.id }),
            workspaceName: workspace?.name, agentKind: tab?.agent?.kind.rawValue,
            agentActivity: tab?.agent?.activity.rawValue, agentChip: tab?.agent?.kind.chip,
            gitBranch: tab?.gitBranch, clientName: "Harness.app"
        )
        context.paneCurrentCommand = tab?.currentCommand
        context.paneDead = tab.map { $0.exitStatus != nil }
        context.paneExitStatus = tab?.exitStatus
        context.sessionID = session?.id.uuidString
        context.windowID = tab?.id.uuidString
        context.sessionWindows = session?.tabs.count
        context.windowPanes = tab?.rootPane.allPaneIDs().count
        if let tab, let session { context.windowActive = tab.id == session.activeTabID }
        context.sessionGroup = session.flatMap { snapshot.groupName(of: $0) }
        context.windowFlags = tab.map { ($0.zoomedPaneID != nil ? "Z" : "") + $0.alertFlags }
        return context
    }

    func selectWorkspace(byIndex index: Int) {
        guard index >= 0, index < snapshot.workspaces.count else { return }
        selectWorkspace(snapshot.workspaces[index].id)
    }

    func beginRenameActiveTab() {
        NotificationCenter.default.post(name: NotificationBus.shared.snapshotChanged, object: nil, userInfo: ["beginRenameActiveTab": true])
    }

    func updateFontSize(delta: Float) { applyFontSize(settings.fontSize + delta) }
    func resetFontSize() { applyFontSize(HarnessSettings().fontSize) }
    private func applyFontSize(_ size: Float) {
        settings.fontSize = max(8, min(32, size))
        try? settings.save()
        for host in terminalHosts.allHosts() { host.applySettings(settings) }
    }
}

// MARK: - TerminalHostDelegate — see SessionCoordinator+HostDelegate.swift

// MARK: - Supporting types — see SessionCoordinatorTypes.swift
