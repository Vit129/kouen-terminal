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

    // MARK: - Services (created after self is valid)
    private(set) lazy var daemonSyncService: DaemonSyncService = DaemonSyncService(coordinator: self)
    private(set) lazy var splitPaneCoordinator: SplitPaneCoordinator = SplitPaneCoordinator(coordinator: self)
    private(set) lazy var sessionLifecycleService: SessionLifecycleService = SessionLifecycleService(coordinator: self)
    private(set) lazy var notificationCoordinator: NotificationCoordinator = NotificationCoordinator(coordinator: self)

    // MARK: - State (owned here; services read/write via `coord` back-reference)

    /// Snapshot forwarded from DaemonSyncService for convenience access.
    var snapshot: SessionSnapshot {
        get { daemonSyncService.snapshot }
    }

    var settings = HarnessSettings.load()
    private(set) var activeEndpoint: Endpoint = .localControlSocket
    var activeSurfaceID: SurfaceID?
    private(set) var lastActiveSurfaceID: SurfaceID?
    private var suppressActivePaneSync = false
    private(set) var markedSurfaceID: SurfaceID?
    private var synchronizedTabIDs: Set<TabID> = []
    var structureRevision = 0
    var appliedThemeKey = ""
    /// Flat index rebuilt once per `syncFromDaemon`.
    var surfaceIndex: [SurfaceID: (tab: Tab, tabID: TabID)] = [:]
    /// The most recently closed tab's directory + title for ⇧⌘T reopen.
    var lastClosedTab: (cwd: String, title: String)?
    /// The TerminalPaneRegistry — package-internal so services can reference it.
    let terminalHosts = TerminalPaneRegistry()
    private var lastDaemonErrorNotice: Date?

    var activeTabCWD: String? {
        guard let cwd = snapshot.activeWorkspace?.activeTab?.cwd, !cwd.isEmpty else { return nil }
        return cwd
    }

    private override init() {
        super.init()
        observeNotifications()
        // Trigger lazy init so services are ready before the first notification fires.
        _ = daemonSyncService
        _ = notificationCoordinator
        _ = splitPaneCoordinator
        _ = sessionLifecycleService
        daemonSyncService.startMetadataRefresh()
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(snapshotChangedNotification(_:)),
            name: NotificationBus.shared.snapshotChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: NotificationBus.shared.notificationPosted,
            object: nil
        )
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

    // MARK: - Remote daemons

    func connectToRemote(named name: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var resolved: Endpoint?
            var failureMessage: String?
            do {
                resolved = try RemoteHostsService.shared.connect(named: name)
            } catch {
                failureMessage = "\(error)"
            }
            let endpoint = resolved
            let message = failureMessage
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    guard let self else { return }
                    if let endpoint {
                        self.applyEndpointSwitch(endpoint)
                    } else {
                        self.noteDaemonError(DaemonSessionError.daemonError(message ?? "connection failed"))
                    }
                }
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

    // MARK: - Sync (facade delegating to DaemonSyncService)

    @discardableResult
    func syncFromDaemon(metadataOnly: Bool = false) -> Bool {
        daemonSyncService.sync(metadataOnly: metadataOnly)
    }

    @discardableResult
    func syncFromDaemon(metadataOnly: Bool = false) async -> Bool {
        await daemonSyncService.sync(metadataOnly: metadataOnly)
    }

    func closeEphemeralSessionsBeforeQuit() {
        daemonSyncService.closeEphemeralSessionsBeforeQuit()
    }

    func saveImmediately() {
        syncFromDaemon()
    }

    // MARK: - Daemon request

    @discardableResult
    func requestDaemon(_ request: IPCRequest) -> IPCResponse? {
        daemonSyncService.request(request)
    }

    @discardableResult
    func requestDaemon(_ request: IPCRequest) async -> IPCResponse? {
        await daemonSyncService.request(request)
    }

    func noteDaemonError(_ error: Error) {
        let now = Date()
        if let last = lastDaemonErrorNotice, now.timeIntervalSince(last) < 8 { return }
        lastDaemonErrorNotice = now
        guard let host = (NSApp.keyWindow ?? NSApp.mainWindow)?.contentView else { return }
        Toast.show("Reconnecting to HarnessDaemon…", in: host)
    }

    // MARK: - Session lifecycle (facade)

    func addWorkspace(name: String) { sessionLifecycleService.addWorkspace(name: name) }
    func addSession(to workspaceID: WorkspaceID, cwd: String? = nil, name: String? = nil) {
        sessionLifecycleService.addSession(to: workspaceID, cwd: cwd, name: name)
    }
    func addTab(to workspaceID: WorkspaceID, cwd: String? = nil) {
        sessionLifecycleService.addTab(to: workspaceID, cwd: cwd)
    }
    func openDefaultTerminalLaunch(_ launch: DefaultTerminalLaunchRequest) {
        sessionLifecycleService.openDefaultTerminalLaunch(launch)
    }
    func selectWorkspace(_ id: WorkspaceID) { sessionLifecycleService.selectWorkspace(id) }
    func selectSession(workspaceID: WorkspaceID, sessionID: SessionID) {
        sessionLifecycleService.selectSession(workspaceID: workspaceID, sessionID: sessionID)
    }
    func selectTab(workspaceID: WorkspaceID, tabID: TabID) {
        sessionLifecycleService.selectTab(workspaceID: workspaceID, tabID: tabID)
    }
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

    // MARK: - Split pane (facade)

    func splitActivePane(direction: SplitDirection) { splitPaneCoordinator.splitActivePane(direction: direction) }
    func splitActivePaneAndRun(direction: SplitDirection, command: String) {
        splitPaneCoordinator.splitActivePaneAndRun(direction: direction, command: command)
    }
    func focusPaneDirectional(_ direction: DirectionalAxis) { splitPaneCoordinator.focusPaneDirectional(direction) }
    func splitPaneSurface(
        tabID: TabID, sourcePaneID: PaneID, surfaceID: SurfaceID,
        targetPaneID: PaneID, direction: SplitDirection, beforeTarget: Bool
    ) {
        splitPaneCoordinator.splitPaneSurface(
            tabID: tabID, sourcePaneID: sourcePaneID, surfaceID: surfaceID,
            targetPaneID: targetPaneID, direction: direction, beforeTarget: beforeTarget
        )
    }
    func splitTab(workspaceID: WorkspaceID, tabID: TabID, direction: SplitDirection) {
        splitPaneCoordinator.splitTab(workspaceID: workspaceID, tabID: tabID, direction: direction)
    }
    func splitSession(workspaceID: WorkspaceID, sessionID: SessionID, direction: SplitDirection) {
        splitPaneCoordinator.splitSession(workspaceID: workspaceID, sessionID: sessionID, direction: direction)
    }
    func killActivePane() { splitPaneCoordinator.killActivePane() }
    func killPane(paneID: PaneID) { splitPaneCoordinator.killPane(paneID: paneID) }

    // Internal pane-tree helpers (used by services and self)
    func paneID(for surfaceID: SurfaceID, in node: PaneNode) -> PaneID? {
        splitPaneCoordinator.paneID(for: surfaceID, in: node)
    }
    func firstSurfaceID(forTab tabID: TabID) -> SurfaceID? {
        splitPaneCoordinator.firstSurfaceID(forTab: tabID)
    }
    private func surfaceID(forPaneID paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        splitPaneCoordinator.surfaceID(forPaneID: paneID, in: node)
    }
    private func surfaceID(forPane paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        splitPaneCoordinator.surfaceID(forPane: paneID, in: node)
    }

    // MARK: - Notifications (facade)

    func jumpToLatestNotification() { notificationCoordinator.jumpToLatestNotification() }
    func isSurfaceWaiting(_ surfaceID: UUID) -> Bool { notificationCoordinator.isSurfaceWaiting(surfaceID) }
    func notificationsList() -> [NotificationEntry] { notificationCoordinator.notificationsList() }
    func agentsList() -> [AgentSessionSummary] { notificationCoordinator.agentsList() }
    func openAgent(_ agent: AgentSessionSummary) { notificationCoordinator.openAgent(agent) }
    func openNotification(_ entry: NotificationEntry) { notificationCoordinator.openNotification(entry) }
    func clearNotification(surfaceID: SurfaceID) { notificationCoordinator.clearNotification(surfaceID: surfaceID) }
    func clearAllNotifications() { notificationCoordinator.clearAllNotifications() }
    func handleNotification(for surfaceID: SurfaceID, event: NotificationEvent, title: String, body: String) {
        notificationCoordinator.handleNotification(for: surfaceID, event: event, title: title, body: body)
    }
    func syncWaitingRings() { notificationCoordinator.syncWaitingRings() }

    // MARK: - Theme

    /// Push the current `settings` to every live terminal host and refresh chrome.
    func applySettingsToHosts() {
        HarnessChrome.update(
            themeName: snapshot.themeName,
            opacity: CGFloat(settings.backgroundOpacity),
            blur: settings.backgroundBlur,
            backgroundHex: settings.customBackgroundHex,
            foregroundHex: settings.customForegroundHex,
            cursorHex: settings.customCursorHex
        )
        let allowClipboard = HarnessOptions.shared.get("set-clipboard")?.boolValue ?? true
        let wordSep = HarnessOptions.shared.get("word-separators")?.stringValue ?? " \t"
        let wrapSearch = HarnessOptions.shared.get("wrap-search")?.boolValue ?? true
        for host in terminalHosts.allHosts() {
            host.applyTheme(named: snapshot.themeName)
            host.applySettings(settings)
            host.allowProgramClipboardAccess = allowClipboard
            host.wordSeparators = wordSep
            host.wrapSearch = wrapSearch
            applyTerminalIdentity(to: host)
            pushBorderColors(to: host)
        }
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: [
                "revision": snapshot.revision,
                "structureChanged": false,
                "chromeChanged": true,
            ]
        )
    }

    func applyThemeToAllHosts() {
        HarnessChrome.update(
            themeName: snapshot.themeName,
            opacity: CGFloat(settings.backgroundOpacity),
            blur: settings.backgroundBlur,
            backgroundHex: settings.customBackgroundHex,
            foregroundHex: settings.customForegroundHex,
            cursorHex: settings.customCursorHex
        )
        let allowClipboard = HarnessOptions.shared.get("set-clipboard")?.boolValue ?? true
        let wordSep = HarnessOptions.shared.get("word-separators")?.stringValue ?? " \t"
        let wrapSearch = HarnessOptions.shared.get("wrap-search")?.boolValue ?? true
        for host in terminalHosts.allHosts() {
            host.applyTheme(named: snapshot.themeName)
            host.applySettings(settings)
            host.allowProgramClipboardAccess = allowClipboard
            host.wordSeparators = wordSep
            host.wrapSearch = wrapSearch
            applyTerminalIdentity(to: host)
            pushBorderColors(to: host)
        }
        adoptSynchronizeOptions()
        refreshSyncSiblings()
        reassertMarkedPane()
    }

    private func applyTerminalIdentity(to host: TerminalHostView) {
        let spec = TerminalIdentity.spec(forOption: HarnessOptions.shared.get(TerminalIdentity.optionKey)?.stringValue)
        host.setTerminalIdentity(name: spec.name, version: spec.version, daVersion: spec.daVersion)
    }

    private func pushBorderColors(to host: TerminalHostView) {
        let chrome = HarnessChrome.current
        host.applyBorderColors(
            active: chrome.focusRing,
            waiting: chrome.waiting
        )
    }

    func setTheme(_ name: String, seedColors: Bool = true) {
        if seedColors {
            let preset = ThemeManager.presetColors(themeName: name)
            settings.customBackgroundHex = preset.backgroundHex
            settings.customForegroundHex = preset.foregroundHex
            settings.customCursorHex = preset.cursorHex
            settings.cursorTextHex = preset.cursorTextHex
            settings.selectionBackgroundHex = preset.selectionBackgroundHex
            settings.selectionForegroundHex = preset.selectionForegroundHex
            settings.boldColorHex = preset.boldHex
            settings.paletteHex = HarnessSettings.normalizedPalette(preset.paletteHex)
            settings.dividerHex = nil
            settings.statusLineHex = nil
            try? settings.save()
        }
        requestDaemon(.setTheme(name: name))
        syncFromDaemon()
    }

    func applyImportedTheme(_ document: ThemeDocument) {
        let colors = document.colors
        settings.customBackgroundHex = colors.background.hexString
        settings.customForegroundHex = colors.foreground.hexString
        settings.customCursorHex = colors.cursor?.hexString
        settings.cursorTextHex = colors.cursorText?.hexString
        settings.selectionBackgroundHex = colors.selectionBackground?.hexString
        settings.selectionForegroundHex = colors.selectionForeground?.hexString
        settings.boldColorHex = colors.bold?.hexString
        settings.paletteHex = HarnessSettings.normalizedPalette(colors.palette.map { $0.hexString })
        settings.dividerHex = nil
        settings.statusLineHex = nil
        if let appearance = document.appearance {
            if let opacity = appearance.backgroundOpacity {
                settings.backgroundOpacity = HarnessSettings.clampedOpacity(Float(opacity))
            }
            if let blur = appearance.backgroundBlur {
                settings.backgroundBlur = HarnessSettings.clampedBlur(blur)
            }
            if let family = appearance.fontFamily, !family.isEmpty {
                settings.fontFamily = family
            }
            if let size = appearance.fontSize {
                settings.fontSize = HarnessSettings.clampedFontSize(Float(size))
            }
            if let px = appearance.windowPaddingX {
                settings.windowPaddingX = HarnessSettings.clampedPadding(Float(px))
            }
            if let py = appearance.windowPaddingY {
                settings.windowPaddingY = HarnessSettings.clampedPadding(Float(py))
            }
            if let applyToOutput = appearance.applyToTerminalOutput {
                settings.applyThemeToTerminalOutput = applyToOutput
            }
        }
        try? settings.save()
        requestDaemon(.setTheme(name: document.name))
        syncFromDaemon()
    }

    static var isSystemAppearanceDark: Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }

    func applyAutoThemeForCurrentAppearance() {
        guard let light = settings.lightThemeName, let dark = settings.darkThemeName else { return }
        let isDark = SessionCoordinator.isSystemAppearanceDark
        let target = isDark ? dark : light
        let targetOpacity = isDark ? settings.darkThemeOpacity : settings.lightThemeOpacity

        var didChange = false
        if target != snapshot.themeName {
            setTheme(target, seedColors: true)
            didChange = true
        }
        if let targetOpacity {
            let clamped = HarnessSettings.clampedOpacity(targetOpacity)
            if settings.backgroundOpacity != clamped {
                settings.backgroundOpacity = clamped
                try? settings.save()
                didChange = true
            }
        }
        if didChange {
            applySettingsToHosts()
        }
    }

    func reimportTerminalConfig() {
        if let imported = TerminalConfigImporter.load() {
            settings = HarnessSettings.makeDefaults(imported: imported)
            try? settings.save()
            if let theme = imported.themeName {
                setTheme(theme, seedColors: false)
            } else {
                setTheme(ThemeManager.defaultDisplayName, seedColors: false)
            }
            applyAutoThemeForCurrentAppearance()
            applySettingsToHosts()
        }
    }

    // MARK: - Active surface and pane management

    func setActiveSurface(_ surfaceID: SurfaceID?) {
        if let old = activeSurfaceID, let new = surfaceID, old != new,
           let oldTab = tabID(forSurface: old), oldTab == tabID(forSurface: new) {
            lastActiveSurfaceID = old
        }
        activeSurfaceID = surfaceID
        refreshPaneStyles()
        let showBorder = surfaceID.map { paneCount(forSurface: $0) > 1 } ?? false
        for host in terminalHosts.allHosts() {
            host.showsActiveBorder = showBorder && host.surfaceID == surfaceID
        }
        refreshPaneBorders()
        if !suppressActivePaneSync, let surfaceID, let loc = tabAndPane(forSurface: surfaceID) {
            _ = requestDaemon(.selectPane(tabID: loc.tabID, paneID: loc.paneID))
        }
    }

    func reflectRemoteActivePane() {
        guard let tab = snapshot.activeWorkspace?.activeTab,
              let paneID = tab.activePaneID,
              let surfaceID = surfaceID(forPaneID: paneID, in: tab.rootPane),
              surfaceID != activeSurfaceID
        else { return }
        suppressActivePaneSync = true
        setActiveSurface(surfaceID)
        suppressActivePaneSync = false
    }

    func refreshPaneStyles() {
        let opts = OptionStore()
        func value(_ key: String) -> String { opts.get(key, scope: .global)?.stringValue ?? "" }
        let styles = PaneStyleSet(
            window: value("window-style"),
            windowActive: value("window-active-style"),
            pane: value("pane-style"),
            paneActive: value("pane-active-style")
        )
        for host in terminalHosts.allHosts() { host.applyPaneStyles(styles) }
    }

    func refreshPaneBorders() {
        let opts = OptionStore()
        let status = PaneBorderStatus(option: opts.get("pane-border-status", scope: .global)?.stringValue ?? "off")
        let atTop = status == .top
        let format = opts.get("pane-border-format", scope: .global)?.stringValue ?? ""
        for host in terminalHosts.allHosts() {
            if status == .off || format.isEmpty {
                host.setPaneBorderLabel(nil, atTop: atTop)
            } else {
                let label = FormatString.evaluate(format, context: paneBorderContext(forSurface: host.surfaceID))
                host.setPaneBorderLabel(label, atTop: atTop)
            }
        }
    }

    private func paneBorderContext(forSurface surfaceID: SurfaceID) -> FormatContext {
        let owningTab = surfaceIndex[surfaceID]?.tab
        let paneIndex = owningTab.flatMap { tab in
            tab.rootPane.allSurfaceIDs().firstIndex(of: surfaceID)
        }
        return FormatContext(
            paneID: surfaceID.uuidString,
            paneTitle: owningTab?.title,
            paneCwd: owningTab?.cwd,
            paneActive: surfaceID == activeSurfaceID,
            paneIndex: paneIndex,
            tabName: owningTab?.title,
            workspaceName: snapshot.activeWorkspace?.name,
            agentKind: owningTab?.agent?.kind.rawValue,
            gitBranch: owningTab?.gitBranch,
            clientName: "Harness.app"
        )
    }

    private func tabAndPane(forSurface surfaceID: SurfaceID) -> (tabID: TabID, paneID: PaneID)? {
        guard let entry = surfaceIndex[surfaceID],
              let pane = paneID(for: surfaceID, in: entry.tab.rootPane)
        else { return nil }
        return (entry.tabID, pane)
    }

    private func paneCount(forSurface surfaceID: SurfaceID) -> Int {
        guard let tab = surfaceIndex[surfaceID]?.tab else { return 0 }
        return tab.rootPane.allSurfaceIDs().count
    }

    private func tabID(forSurface surfaceID: SurfaceID) -> TabID? {
        surfaceIndex[surfaceID]?.tabID
    }

    func selectLastPane() {
        guard let tab = snapshot.activeWorkspace?.activeTab,
              let last = lastActiveSurfaceID,
              tab.rootPane.allSurfaceIDs().contains(last)
        else { return }
        setActiveSurface(last)
        terminalHosts.host(for: last)?.focusTerminal()
    }

    func setMarkedPane(_ set: Bool) {
        markedSurfaceID = set ? activeSurfaceID : nil
        for host in terminalHosts.allHosts() {
            host.showsMarkedBorder = host.surfaceID == markedSurfaceID
        }
    }

    func reassertMarkedPane() {
        for host in terminalHosts.allHosts() {
            host.showsMarkedBorder = markedSurfaceID != nil && host.surfaceID == markedSurfaceID
        }
    }

    func showDisplayPanes() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let surfaces = tab.rootPane.allSurfaceIDs()
        let panes = surfaces.enumerated().compactMap { index, sid -> (number: Int, host: TerminalHostView)? in
            guard let host = terminalHosts.host(for: sid) else { return nil }
            return (number: index, host: host)
        }
        DisplayPanesOverlay.shared.show(panes: panes) { [weak self] surfaceID in
            self?.setActiveSurface(surfaceID)
            self?.terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    func setSynchronizePanes(_ on: Bool?) {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let nowOn = on ?? !synchronizedTabIDs.contains(tab.id)
        if nowOn { synchronizedTabIDs.insert(tab.id) } else { synchronizedTabIDs.remove(tab.id) }
        requestDaemon(.setOption(
            scope: "tab", target: tab.id.uuidString,
            key: "synchronize-panes", rawValue: nowOn ? "on" : "off"
        ))
        refreshSyncSiblings()
        DisplayMessage.show(nowOn ? "synchronize-panes: on" : "synchronize-panes: off")
    }

    func adoptSynchronizeOptions() {
        guard case let .options(entries)? = requestDaemon(.showOptions(scope: "tab")) else { return }
        var changed = false
        for entry in entries where entry.key == "synchronize-panes" {
            guard let target = entry.target, let tabID = TabID(uuidString: target) else { continue }
            let on = entry.value == "on" || entry.value == "true" || entry.value == "1"
            if on != synchronizedTabIDs.contains(tabID) {
                if on { synchronizedTabIDs.insert(tabID) } else { synchronizedTabIDs.remove(tabID) }
                changed = true
            }
        }
        if changed { refreshSyncSiblings() }
    }

    func refreshSyncSiblings() {
        let liveTabIDs = Set(surfaceIndex.values.map(\.tabID))
        synchronizedTabIDs.formIntersection(liveTabIDs)
        var seenTabIDs = Set<TabID>()
        for (_, entry) in surfaceIndex {
            guard seenTabIDs.insert(entry.tabID).inserted else { continue }
            let surfaceIDs = entry.tab.rootPane.allSurfaceIDs()
            let synced = synchronizedTabIDs.contains(entry.tabID) && surfaceIDs.count > 1
            for sid in surfaceIDs {
                guard let host = terminalHosts.host(for: sid) else { continue }
                host.setSyncSiblings(synced ? surfaceIDs.filter { $0 != sid }.map(\.uuidString) : [])
            }
        }
    }

    func joinMarkedPane(direction: SplitDirection) {
        guard let markedSurface = markedSurfaceID,
              let tab = snapshot.activeWorkspace?.activeTab,
              let activeSurface = activeSurfaceID,
              let destPane = paneID(for: activeSurface, in: tab.rootPane)
        else { DisplayMessage.show("join-pane: no marked pane"); return }
        let sourcePane = snapshot.workspaces
            .flatMap(\.sessions).flatMap(\.tabs)
            .compactMap { paneID(for: markedSurface, in: $0.rootPane) }
            .first
        guard let sourcePane, sourcePane != destPane else {
            DisplayMessage.show("join-pane: invalid mark")
            return
        }
        _ = requestDaemon(.joinPane(sourcePaneID: sourcePane, destPaneID: destPane, direction: direction))
        setMarkedPane(false)
        syncFromDaemon()
    }

    func ensureActivePane(for tab: Tab) {
        let surfaces = tab.rootPane.allSurfaceIDs()
        guard !surfaces.isEmpty else { return }
        let target = activeSurfaceID.flatMap { surfaces.contains($0) ? $0 : nil } ?? surfaces.first
        setActiveSurface(target)
        if let target { terminalHosts.host(for: target)?.focusTerminal() }
    }

    func setSplitRatio(tabID: TabID, firstPaneID: PaneID, secondPaneID: PaneID, ratio: Double) {
        requestDaemon(.resizePaneRatio(tabID: tabID, firstPaneID: firstPaneID, secondPaneID: secondPaneID, ratio: ratio))
        syncFromDaemon(metadataOnly: true)
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

    // MARK: - Terminal host management

    func terminalHostIfExists(for surfaceID: SurfaceID) -> TerminalHostView? {
        terminalHosts.host(for: surfaceID)
    }

    func terminalHost(for surfaceID: SurfaceID, cwd: String) -> TerminalHostView {
        if let existing = terminalHosts.host(for: surfaceID) {
            return existing
        }
        let host = TerminalHostView(
            surfaceID: surfaceID,
            workingDirectory: cwd,
            harnessSurfaceEnv: surfaceID.uuidString,
            settings: settings,
            themeName: snapshot.themeName,
            endpoint: activeEndpoint
        )
        host.hostDelegate = self
        host.applyTheme(named: snapshot.themeName)
        host.applySettings(settings)
        applyTerminalIdentity(to: host)
        pushBorderColors(to: host)
        terminalHosts.register(host)
        return host
    }

    // MARK: - Pane operations

    func newSurface(tabID: TabID, paneID: PaneID) {
        Task {
            guard case let .surfaceID(raw)? = await requestDaemon(.newSurface(tabID: tabID, paneID: paneID, shell: settings.defaultShell)),
                  let surfaceID = UUID(uuidString: raw)
            else {
                await syncFromDaemon()
                return
            }
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

    func zoomActivePane() {
        guard let workspace = snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        requestDaemon(.zoomPane(paneID: paneID))
        syncFromDaemon()
    }

    func cycleActivePane(forward: Bool) {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let panes = tab.rootPane.allPaneIDs()
        guard !panes.isEmpty else { return }
        let currentIndex: Int
        if let surfaceID = activeSurfaceID,
           let pane = paneID(for: surfaceID, in: tab.rootPane),
           let idx = panes.firstIndex(of: pane) {
            currentIndex = idx
        } else {
            currentIndex = 0
        }
        let nextIndex = (currentIndex + (forward ? 1 : -1) + panes.count) % panes.count
        let targetPane = panes[nextIndex]
        if let surfaceID = surfaceID(forPane: targetPane, in: tab.rootPane) {
            setActiveSurface(surfaceID)
            terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    // MARK: - Find bar

    func toggleFindBar() {
        guard let surfaceID = activeSurfaceID, let host = terminalHosts.host(for: surfaceID) else { return }
        host.toggleFind()
    }

    // MARK: - Copy mode / detach / prompts

    func toggleCopyMode() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        if host.isInCopyMode {
            host.exitCopyMode()
        } else {
            let modeKeys = HarnessOptions.shared.get("mode-keys", scope: .global)?.stringValue ?? "vi"
            host.enterCopyMode(modeKeys: modeKeys)
        }
    }

    func performCopyModeAction(_ action: CopyModeAction) {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.performCopyModeAction(action)
    }

    func detachActiveSurface() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.detachFromDaemonSurface()
    }

    func reattachActiveSurface() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.reattachToDaemonSurface()
    }

    var activePaneIsDetached: Bool {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return false }
        return host.isDetachedFromDaemon
    }

    func jumpToPreviousPrompt() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.jumpToPreviousPrompt()
    }

    func jumpToNextPrompt() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.jumpToNextPrompt()
    }

    // MARK: - Misc

    func currentFormatContext() -> FormatContext {
        let workspace = snapshot.activeWorkspace
        let session = workspace?.activeSession
        let tab = workspace?.activeTab
        var context = FormatContext(
            paneID: activeSurfaceID?.uuidString,
            paneTitle: tab?.title,
            paneCwd: tab?.cwd,
            paneActive: activeSurfaceID != nil,
            paneIndex: nil,
            sessionName: session?.name.isEmpty == false ? session?.name : nil,
            tabName: tab?.title,
            tabIndex: session?.tabs.firstIndex(where: { $0.id == tab?.id }),
            workspaceName: workspace?.name,
            agentKind: tab?.agent?.kind.rawValue,
            agentActivity: tab?.agent?.activity.rawValue,
            gitBranch: tab?.gitBranch,
            clientName: "Harness.app"
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

    func updateFontSize(delta: Float) {
        applyFontSize(settings.fontSize + delta)
    }

    func resetFontSize() {
        applyFontSize(HarnessSettings().fontSize)
    }

    private func applyFontSize(_ size: Float) {
        settings.fontSize = max(8, min(32, size))
        try? settings.save()
        for host in terminalHosts.allHosts() {
            host.applySettings(settings)
        }
    }
}

// MARK: - TerminalHostDelegate

extension SessionCoordinator: TerminalHostDelegate {
    func terminalHostDidChangeTitle(_ title: String, surfaceID: SurfaceID) {
        Task {
            await daemonSyncService.logIfFailed(.updateTabTitle(surfaceID: surfaceID.uuidString, title: title))
            await syncFromDaemon(metadataOnly: true)
        }
    }

    func terminalHostDidUpdateProgress(_ report: TerminalProgressReport, surfaceID: SurfaceID) {
        SurfaceProgressTracker.shared.update(report, forSurface: surfaceID)
    }

    func terminalHostDidChangeWorkingDirectory(_ path: String, surfaceID: SurfaceID) {
        Task {
            await daemonSyncService.logIfFailed(.updateTabCwd(surfaceID: surfaceID.uuidString, path: path))
            await syncFromDaemon(metadataOnly: true)
        }
    }

    func surfaceShellTrackerDidUpdateCwd(_ surfaceID: SurfaceID, cwd: String) {
        let current = snapshot.workspaces
            .flatMap { workspace in workspace.sessions.flatMap { $0.tabs } }
            .first { $0.rootPane.allSurfaceIDs().contains(surfaceID) }?.cwd
        if current == cwd { return }
        Task {
            await daemonSyncService.logIfFailed(.updateTabCwd(surfaceID: surfaceID.uuidString, path: cwd))
            await syncFromDaemon(metadataOnly: true)
        }
    }

    func terminalHostDidChangeFocus(_ focused: Bool, surfaceID: SurfaceID) {
        guard focused else { return }
        setActiveSurface(surfaceID)
        guard tabIsWaiting(forSurface: surfaceID) else { return }
        clearNotification(for: surfaceID)
    }

    private func tabIsWaiting(forSurface surfaceID: SurfaceID) -> Bool {
        snapshot.workspaces
            .flatMap { workspace in workspace.sessions.flatMap { $0.tabs } }
            .first { $0.rootPane.allSurfaceIDs().contains(surfaceID) }?
            .status == .waiting
    }

    func terminalHostDidRingBell(surfaceID: SurfaceID) {
        handleNotification(for: surfaceID, event: .bell, title: "Terminal", body: "Bell")
    }

    func terminalHostDidFinishCommand(duration: TimeInterval, exitCode: Int?, surfaceID: SurfaceID) {
        guard settings.isEventEnabled(.commandFinished),
              duration >= Double(max(0, settings.commandFinishedThresholdSeconds)) else { return }
        if NSApp.isActive, surfaceID == activeSurfaceID { return }
        let code = exitCode ?? 0
        let status = code == 0 ? "succeeded" : "failed (exit \(code))"
        notificationCoordinator.deliverAgentAlert(event: .commandFinished, title: "Command \(status)", body: "Ran for \(Self.formatDuration(duration)).")
    }

    private static func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        if total < 60 { return "\(total)s" }
        let minutes = total / 60, secs = total % 60
        if minutes < 60 { return secs == 0 ? "\(minutes)m" : "\(minutes)m \(secs)s" }
        let hours = minutes / 60, mins = minutes % 60
        return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
    }

    func terminalHostDidRequestDesktopNotification(title: String, body: String, surfaceID: SurfaceID) {
        handleNotification(for: surfaceID, event: .agentWaiting, title: title, body: body)
    }

    func terminalHostDidClose(surfaceID: SurfaceID) {
        terminalHosts.removeHost(for: surfaceID)
        SurfaceProgressTracker.shared.forget(surfaceID)
    }
}

// MARK: - clearNotification(for:) needed by TerminalHostDelegate

extension SessionCoordinator {
    func clearNotification(for surfaceID: SurfaceID) {
        requestDaemon(.clearNotification(surfaceID: surfaceID.uuidString))
        syncFromDaemon()
    }
}

// MARK: - Supporting types

struct NotificationEntry: Identifiable, Equatable {
    let workspaceID: WorkspaceID
    let workspaceName: String
    let sessionID: SessionID
    let tabID: TabID
    let tabTitle: String
    let surfaceID: SurfaceID
    let agentKind: AgentKind?
    let body: String
    var id: TabID { tabID }
}

enum DesktopNotifier {
    // UNUserNotificationCenter.current() crashes on macOS 26 beta due to a corrupted
    // NSCalendarDate in the notification database. All banner delivery is disabled until
    // the system issue is resolved; sound fallback is preserved.

    static func requestAuthorizationIfNeeded() {}

    static func show(title: String, body: String, withSound: Bool = true) {
        if withSound {
            DispatchQueue.main.async { NSSound(named: "Glass")?.play() }
        }
    }

    static func authorizationStatus(_ completion: @escaping @MainActor (UNAuthorizationStatus) -> Void) {
        DispatchQueue.main.async { MainActor.assumeIsolated { completion(.notDetermined) } }
    }

    static func requestOrOpenSettings() {
        openSystemNotificationSettings()
    }

    static func openSystemNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }

    static func sendTest() {}
}

enum HarnessPathDisplay {
    static func title(for path: String, fallback: String) -> String {
        if path == "/" { return "/" }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        let shortened = path.hasPrefix(home + "/") ? "~" + path.dropFirst(home.count) : path
        let last = (String(shortened) as NSString).lastPathComponent
        if !last.isEmpty { return last }
        if !fallback.isEmpty, fallback != "Shell" { return fallback }
        return "Terminal"
    }
}
