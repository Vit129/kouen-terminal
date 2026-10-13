import AVFoundation
import AppKit
import Foundation
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit
import HarnessTheme
import Network
import UserNotifications

extension SessionCoordinator {
    func addWorkspace(name: String) {
        requestDaemonAsync(.newWorkspace(name: name))
        refreshSnapshot()
    }

    func addSession(to workspaceID: WorkspaceID, cwd: String? = nil, name: String? = nil) {
        createSession(in: workspaceID, cwd: cwd, name: name)
        refreshSnapshot()
    }

    /// Ask the daemon for a session without syncing, so a caller can open its window before
    /// the snapshot that makes it active arrives.
    func createSession(in workspaceID: WorkspaceID, cwd: String? = nil, name: String? = nil,
                       completion: @escaping @MainActor @Sendable (SessionID?) -> Void = { _ in }) {
        let cwd = cwd ?? activeTabCWD ?? settings.defaultCWD
        requestDaemonAsync(.newSession(workspaceID: workspaceID, cwd: cwd, name: name, shell: settings.defaultShell)) {
            guard case let .sessionID(id)? = $0 else { completion(nil); return }
            completion(id)
        }
    }

    func addTab(to workspaceID: WorkspaceID, cwd: String? = nil) {
        requestDaemonAsync(.newTab(workspaceID: workspaceID, cwd: cwd ?? activeTabCWD ?? settings.defaultCWD, shell: settings.defaultShell))
        refreshSnapshot()
    }

    func openDefaultTerminalLaunch(_ launch: DefaultTerminalLaunchRequest) {
        guard let workspaceID = snapshot.activeWorkspace?.id ?? snapshot.workspaces.first?.id else { return }
        let cwd = launch.cwd ?? settings.defaultCWD, shell = settings.defaultShell
        let owner = activeOwner
        performDaemonOperation(operation: { service in
            guard case let .tabID(tabID) = try service.request(.newTab(workspaceID: workspaceID, cwd: cwd, shell: shell)) else {
                throw DaemonSessionError.unexpectedResponse
            }
            if let title = launch.title, !title.isEmpty { try service.request(.renameTab(tabID: tabID, name: title)) }
            let snapshot = try service.fetchSnapshot()
            guard let surfaceID = snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs)
                .first(where: { $0.id == tabID })?.rootPane.allSurfaceIDs().first else {
                throw DaemonSessionError.unexpectedResponse
            }
            if let command = launch.command, !command.isEmpty {
                try service.request(.sendData(surfaceID: surfaceID.uuidString, data: Data((command + "\r").utf8)))
            }
            return .surfaceID(surfaceID.uuidString)
        }, completion: { [weak self] response in
            guard let self, self.activeOwner == owner,
                  case let .surfaceID(raw)? = response, let surfaceID = UUID(uuidString: raw) else { return }
            self.setActiveSurface(surfaceID)
        })
    }

    func splitActivePane(direction: SplitDirection) {
        guard let workspace = snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        requestDaemonAsync(.newSplit(tabID: tab.id, paneID: paneID, direction: direction, shell: settings.defaultShell))
        refreshSnapshot()
    }

    /// Move a tab into `session` (at `index`, else the end), or with nil into a new session of
    /// its own. Returns where it went. Moving into a new session doesn't sync, so the caller can
    /// open its window before the snapshot that makes it active arrives.
    func moveTab(_ tabID: TabID, toSession session: SessionID?, index: Int? = nil,
                 completion: @escaping @MainActor @Sendable (SessionID?) -> Void = { _ in }) {
        requestDaemonAsync(.moveTab(tabID: tabID, toSessionID: session, index: index)) {
            guard case let .sessionID(id)? = $0 else { completion(nil); return }
            completion(id)
        }
    }

    /// A pane dragged onto another: an edge splits the target with the dragged pane on that
    /// side, the middle swaps them. The dragged pane may come from another tab.
    func dropPane(_ source: SurfaceID, onto target: SurfaceID, zone: PaneDropZone) {
        let tabs = snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs)
        guard let sourcePane = tabs.lazy.compactMap({ self.paneID(for: source, in: $0.rootPane) }).first,
              let targetPane = tabs.lazy.compactMap({ self.paneID(for: target, in: $0.rootPane) }).first
        else { return }
        let request: IPCRequest = zone.direction.map {
            .joinPane(sourcePaneID: sourcePane, destPaneID: targetPane, direction: $0, placement: zone.placement)
        } ?? .swapPanes(srcPaneID: sourcePane, dstPaneID: targetPane)
        requestDaemonAsync(request)
        refreshSnapshot()
    }

    /// A pane dropped on a tab moves into it, beside that tab's focused pane; dropped on empty
    /// tab-bar space it gets a tab of its own.
    func dropPane(_ source: SurfaceID, ontoTab tabID: TabID?) {
        let tabs = snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs)
        guard let sourcePane = tabs.lazy.compactMap({ self.paneID(for: source, in: $0.rootPane) }).first else { return }
        let request: IPCRequest
        if let tabID, let tab = tabs.first(where: { $0.id == tabID }) {
            guard let anchor = tab.activePaneID ?? tab.rootPane.allPaneIDs().first, anchor != sourcePane else { return }
            request = .joinPane(sourcePaneID: sourcePane, destPaneID: anchor, direction: .horizontal, placement: .after)
        } else {
            request = .breakPane(paneID: sourcePane)
        }
        requestDaemonAsync(request)
        refreshSnapshot()
    }

    func paneID(for surfaceID: SurfaceID, in node: PaneNode) -> PaneID? {
        switch node {
        case let .leaf(leaf) where leaf.surfaceID == surfaceID:
            return leaf.id
        case let .branch(_, _, first, second):
            return paneID(for: surfaceID, in: first) ?? paneID(for: surfaceID, in: second)
        default:
            return nil
        }
    }

    private func firstSurfaceID(forTab tabID: TabID) -> SurfaceID? {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                if let tab = session.tabs.first(where: { $0.id == tabID }) {
                    return tab.rootPane.allSurfaceIDs().first
                }
            }
        }
        return nil
    }

    func selectWorkspace(_ id: WorkspaceID) {
        selectionsSent += 1
        requestDaemonAsync(.selectWorkspace(id: id))
        refreshSnapshot()
    }

    func selectSession(workspaceID: WorkspaceID, sessionID: SessionID) {
        selectionsSent += 1
        // A session already showing in another window: go to that window (becoming key
        // selects it there) rather than pulling its panes into this one.
        if let window = WindowContexts.window(showing: sessionID), window !== NSApp.keyWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }
        if snapshot.activeWorkspaceID == workspaceID,
           snapshot.activeWorkspace?.activeSessionID == sessionID
        {
            return
        }
        requestDaemonAsync(.selectSession(workspaceID: workspaceID, sessionID: sessionID))
        refreshSnapshot()
    }

    func selectTab(workspaceID: WorkspaceID, tabID: TabID) {
        selectionsSent += 1
        if snapshot.activeWorkspaceID == workspaceID,
           snapshot.activeWorkspace?.activeTabID == tabID
        {
            return
        }
        requestDaemonAsync(.selectTab(workspaceID: workspaceID, tabID: tabID))
        refreshSnapshot()
    }

    func selectAdjacentTab(offset: Int) {
        guard let workspace = snapshot.activeWorkspace,
              let activeTabID = workspace.activeTabID,
              let index = workspace.tabs.firstIndex(where: { $0.id == activeTabID }),
              !workspace.tabs.isEmpty
        else { return }
        let count = workspace.tabs.count
        let nextIndex = (index + offset % count + count) % count
        selectTab(workspaceID: workspace.id, tabID: workspace.tabs[nextIndex].id)
    }

    /// Select the Nth (0-based) tab — backs the ⌘1–9 tab-switch shortcuts.
    /// Out-of-range numbers (e.g. ⌘5 with 3 tabs) are no-ops.
    func selectTab(atIndex index: Int) {
        guard let workspace = snapshot.activeWorkspace,
              index >= 0, index < workspace.tabs.count
        else { return }
        selectTab(workspaceID: workspace.id, tabID: workspace.tabs[index].id)
    }

    func closeActiveTab() {
        guard let disposition = activeTabCloseDisposition() else { return }
        performClose(disposition)
    }

    private func closeActiveTabOnly() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        requestDaemonAsync(.closeTab(tabID: tab.id))
        refreshSnapshot()
    }

    var canReopenClosedTab: Bool { !snapshot.library.recentlyClosed.isEmpty }

    func reopenLastClosedTab() {
        guard let closed = snapshot.library.recentlyClosed.first else { return }
        let owner = activeOwner
        performLibrary(.restoreClosed(closed.id), owner: owner) { result in
            switch result {
            case let .success(.sessionID(id)):
                self.refreshSnapshot()
                self.showDaemon(owner, session: id)
            case let .failure(error): DisplayMessage.show(error.localizedDescription)
            default: break
            }
        }
    }

    func toggleFindBar() {
        guard let surfaceID = activeSurfaceID, let host = terminalHosts.host(for: surfaceID) else { return }
        host.toggleFind()
    }

    func findInActivePane(forward: Bool) {
        guard let surfaceID = activeSurfaceID, let host = terminalHosts.host(for: surfaceID) else { return }
        if forward { host.findNext() } else { host.findPrevious() }
    }

    /// ⌘W: the focused pane when the tab is split, else the tab (or, for the last tab, its
    /// session or window). Asks first only when something other than a shell is running.
    func closeFocusedPaneOrTab() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let leaves = tab.rootPane.allLeaves()
        guard leaves.count > 1 else {
            closeActiveTabWithConfirmation()
            return
        }
        let leaf = leaves.first { $0.surfaceID == activeSurfaceID } ?? leaves.first { $0.id == tab.activePaneID } ?? leaves[0]
        let identity = PaneIdentity.of(leaf: leaf, in: tab)
        guard identity.isBusy else {
            killPane(surfaceID: leaf.surfaceID)
            return
        }
        let alert = NSAlert()
        alert.messageText = "Close this pane?"
        alert.informativeText = "\(identity.agent?.displayName ?? identity.program ?? "A program") is still running in it."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Close Pane")
        alert.addButton(withTitle: "Cancel")
        let surfaceID = leaf.surfaceID
        let apply: (NSApplication.ModalResponse) -> Void = { [weak self] response in
            if response == .alertFirstButtonReturn { self?.killPane(surfaceID: surfaceID) }
        }
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window, completionHandler: apply)
        } else {
            apply(alert.runModal())
        }
    }

    /// Spread the active tab's splits evenly: each divider sits where its panes get equal room
    /// along its axis (three side-by-side panes get a third each).
    func equalizeActiveSplits() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        func weight(_ node: PaneNode, along direction: SplitDirection) -> Double {
            guard case let .branch(d, _, first, second) = node, d == direction else { return 1 }
            return weight(first, along: direction) + weight(second, along: direction)
        }
        func firstLeaf(_ node: PaneNode) -> PaneID? {
            switch node {
            case let .leaf(leaf): return leaf.id
            case let .branch(_, _, first, _): return firstLeaf(first)
            }
        }
        var changed = false
        func visit(_ node: PaneNode) {
            guard case let .branch(direction, ratio, first, second) = node else { return }
            let a = weight(first, along: direction), b = weight(second, along: direction)
            let even = a / (a + b)
            if abs(even - ratio) > 0.001, let firstID = firstLeaf(first), let secondID = firstLeaf(second) {
                requestDaemonAsync(.resizePaneRatio(tabID: tab.id, firstPaneID: firstID, secondPaneID: secondID, ratio: even))
                changed = true
            }
            visit(first)
            visit(second)
        }
        visit(tab.rootPane)
        if changed { refreshSnapshot() }
    }

    func closeActiveTabWithConfirmation() {
        guard let disposition = activeTabCloseDisposition(),
              let copy = closeConfirmationCopy(for: disposition)
        else { return }
        // Nothing but shells at their prompts: close without asking.
        if let tab = snapshot.activeWorkspace?.activeTab,
           !tab.rootPane.allLeaves().contains(where: { PaneIdentity.of(leaf: $0, in: tab).isBusy }) {
            performClose(disposition, closingWindow: NSApp.keyWindow)
            return
        }
        let alert = NSAlert()
        alert.messageText = copy.message
        alert.informativeText = copy.informative
        alert.alertStyle = .warning
        alert.addButton(withTitle: copy.button)
        alert.addButton(withTitle: "Cancel")

        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window) { [weak self, weak window] response in
                guard response == .alertFirstButtonReturn else { return }
                Task { @MainActor in
                    self?.performClose(disposition, closingWindow: window)
                }
            }
        } else {
            guard alert.runModal() == .alertFirstButtonReturn else { return }
            performClose(disposition)
        }
    }

    private func activeTabCloseDisposition() -> ActiveTabCloseDisposition? {
        guard let workspace = snapshot.activeWorkspace,
              let session = workspace.activeSession,
              session.activeTab != nil
        else { return nil }
        if session.tabs.count > 1 { return .tab }
        if workspace.sessions.count > 1 { return .session }
        if snapshot.workspaces.count > 1 { return .workspace }
        return .window
    }

    private func closeConfirmationCopy(for disposition: ActiveTabCloseDisposition) -> CloseConfirmationCopy? {
        guard let workspace = snapshot.activeWorkspace,
              let session = workspace.activeSession,
              let tab = session.activeTab
        else { return nil }
        let tabTitle = HarnessPathDisplay.title(for: tab.cwd, fallback: tab.title)
        switch disposition {
        case .tab:
            return CloseConfirmationCopy(
                message: "Close tab \"\(tabTitle)\"?",
                informative: "This will close the tab and its running shell.",
                button: "Close Tab"
            )
        case .session:
            let sessionTitle = session.name.isEmpty ? tabTitle : session.name
            return CloseConfirmationCopy(
                message: "Close session \"\(sessionTitle)\"?",
                informative: "This is the last tab in the session. The session and its running shell will close.",
                button: "Close Session"
            )
        case .workspace:
            return CloseConfirmationCopy(
                message: "Close workspace \"\(workspace.name)\"?",
                informative: "This is the last tab in the workspace. The workspace and its running shell will close.",
                button: "Close Workspace"
            )
        case .window:
            return CloseConfirmationCopy(
                message: "Close Harness window?",
                informative: "This is the last tab in the window. The running shell will close and the window will close.",
                button: "Close Window"
            )
        }
    }

    private func performClose(_ disposition: ActiveTabCloseDisposition, closingWindow: NSWindow? = nil) {
        switch disposition {
        case .tab:
            closeActiveTabOnly()
        case .session:
            closeActiveSession()
        case .workspace:
            closeActiveWorkspace()
        case .window:
            closeActiveTabOnly()
            (closingWindow ?? NSApp.keyWindow ?? NSApp.mainWindow)?.close()
        }
    }

    func closeActiveSession() {
        guard let session = snapshot.activeWorkspace?.activeSession else { return }
        closeSession(session)
    }

    /// Close a specific session by ID. The daemon resolves the ID directly — no
    /// select-first dance, so a failed/raced selection can never close a different
    /// session than the one the user confirmed.
    func closeSession(_ session: SessionGroup) {
        requestDaemonAsync(.closeSession(sessionID: session.id))
        refreshSnapshot()
    }

    func openTabInActiveWorkspace() {
        guard let workspace = snapshot.activeWorkspace else { return }
        addTab(to: workspace.id)
    }

    /// Close every tab in the active session except `keepID` (the "Close Others"
    /// context action). Frees each closed tab's terminal hosts.
    func closeOtherTabs(keeping keepID: TabID) {
        guard let workspace = snapshot.activeWorkspace, let session = workspace.activeSession else { return }
        let others = session.tabs.filter { $0.id != keepID }
        guard !others.isEmpty else { return }
        for tab in others {
            requestDaemonAsync(.closeTab(tabID: tab.id))
        }
        selectTab(workspaceID: workspace.id, tabID: keepID)
        refreshSnapshot()
    }

    /// Select a tab, then split its active pane — used by the tab context menu so the
    /// split lands in the right tab regardless of which tab was previously active.
    func splitTab(workspaceID: WorkspaceID, tabID: TabID, direction: SplitDirection) {
        selectTab(workspaceID: workspaceID, tabID: tabID)
        splitActivePane(direction: direction)
    }

    func killActivePane() {
        guard let workspace = snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        requestDaemonAsync(.killPane(paneID: paneID))
        refreshSnapshot()
    }

    func zoomActivePane() {
        guard let workspace = snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        requestDaemonAsync(.zoomPane(paneID: paneID))
        refreshSnapshot()
    }

    func cycleActivePane(forward: Bool) {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let panes = tab.rootPane.allPaneIDs()
        guard !panes.isEmpty else { return }
        let currentIndex: Int
        if let surfaceID = activeSurfaceID,
           let pane = paneID(for: surfaceID, in: tab.rootPane),
           let idx = panes.firstIndex(of: pane)
        {
            currentIndex = idx
        } else {
            currentIndex = 0
        }
        let nextIndex = (currentIndex + (forward ? 1 : -1) + panes.count) % panes.count
        let targetPane = panes[nextIndex]
        if let surfaceID = surfaceID(forPane: targetPane, in: tab.rootPane) {
            setActiveSurface(surfaceID)
            focusPaneContent(surfaceID)
        }
    }

    /// Single source of truth for which pane shows the active-pane border. Setting it
    /// updates `activeSurfaceID` and toggles the border on every live host so exactly
    /// one pane (app-wide) is highlighted — but only when its tab is actually split.
    /// A lone terminal needs no "which pane is focused" hint, so it stays borderless.
    func setActiveSurface(_ surfaceID: SurfaceID?) {
        // last-pane MRU: when the user switches to a different pane *within the same
        // tab*, remember where they came from. Tab switches and remounts (different
        // tab, or a no-op re-set) don't pollute the within-tab history.
        if let old = activeSurfaceID, let new = surfaceID, old != new,
           let oldTab = tabID(forSurface: old), oldTab == tabID(forSurface: new) {
            lastActiveSurfaceID = old
        }
        activeSurfaceID = surfaceID
        // Refresh `window-style`/`pane-style` before the border toggle so each host has the
        // current base before it re-resolves active vs inactive on the focus change.
        // One read of options.json serves both.
        let options = OptionStore()
        refreshPaneStyles(options)
        let showBorder = surfaceID.map { paneCount(forSurface: $0) > 1 } ?? false
        for host in terminalHosts.allHosts() {
            host.showsActiveBorder = showBorder && host.surfaceID == surfaceID
        }
        // pane-border labels re-evaluate per host (active state just changed above).
        refreshPaneBorders(options)
        NotificationCenter.default.post(name: .harnessActiveSurfaceDidChange, object: self)
        // Push focus to the daemon (single source of truth) so other clients —
        // attach-window compositors, target-less CLI commands — agree on the active
        // pane. Suppressed while reflecting a remote change to avoid a feedback loop. Off the
        // main thread: focus moves with every window that comes forward, on any daemon.
        if !suppressActivePaneSync, let surfaceID, let loc = tabAndPane(forSurface: surfaceID) {
            send(.selectPane(tabID: loc.tabID, paneID: loc.paneID))
        }
    }

    /// Read the `window-style`/`pane-style` options (fresh from the daemon-authored
    /// `options.json`, so a CLI `set-option` lands without an app restart) and push the
    /// resolved set to every host. Each host dims itself when inactive via its own
    /// `showsActiveBorder`. Called on focus changes — the moment dimming matters.
    func refreshPaneStyles(_ opts: OptionStore = OptionStore()) {
        func value(_ key: String) -> String { opts.get(key, scope: .global)?.stringValue ?? "" }
        let styles = PaneStyleSet(
            window: value("window-style"),
            windowActive: value("window-active-style"),
            pane: value("pane-style"),
            paneActive: value("pane-active-style")
        )
        let separators = CopyModeWords.smallWordSeparators(stored: opts.get("word-separators", scope: .global)?.stringValue)
        for host in terminalHosts.allHosts() {
            host.applyPaneStyles(styles)
            host.copyModeWordSeparators = separators
        }
    }

    /// Evaluate `pane-border-format` per host and push the label (or hide it when
    /// `pane-border-status off`). Read fresh from the daemon-authored `options.json`.
    func refreshPaneBorders(_ opts: OptionStore = OptionStore()) {
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

    /// Format context for a specific pane (for `pane-border-format`): its index in the owning
    /// tab's pane order, the tab title (Harness has no per-pane title), and active state.
    private func paneBorderContext(forSurface surfaceID: SurfaceID) -> FormatContext {
        var owningTab: Tab?
        var paneIndex: Int?
        outer: for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    if let idx = tab.rootPane.allSurfaceIDs().firstIndex(of: surfaceID) {
                        owningTab = tab; paneIndex = idx; break outer
                    }
                }
            }
        }
        var context = FormatContext(
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
        context.commandDurationSeconds = lastCommandDurations[surfaceID]
        return context
    }

    /// Resolve the owning tab + pane IDs for a surface, for daemon focus sync.
    private func tabAndPane(forSurface surfaceID: SurfaceID) -> (tabID: TabID, paneID: PaneID)? {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    if let pane = paneID(for: surfaceID, in: tab.rootPane) {
                        return (tab.id, pane)
                    }
                }
            }
        }
        return nil
    }

    /// Reflect the daemon's authoritative `activePaneID` (e.g. changed by another
    /// client) into local focus, without echoing the change back to the daemon.
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

    /// Surface backing a pane within a node (inverse of `paneID(for:in:)`).
    private func surfaceID(forPaneID paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        switch node {
        case let .leaf(leaf): return leaf.id == paneID ? leaf.surfaceID : nil
        case let .branch(_, _, first, second):
            return surfaceID(forPaneID: paneID, in: first) ?? surfaceID(forPaneID: paneID, in: second)
        }
    }

    /// Number of panes in the tab that owns `surfaceID` (1 when unsplit).
    private func paneCount(forSurface surfaceID: SurfaceID) -> Int {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    let ids = tab.rootPane.allSurfaceIDs()
                    if ids.contains(surfaceID) { return ids.count }
                }
            }
        }
        return 0
    }

    /// The tab that owns `surfaceID`, if any.
    private func tabID(forSurface surfaceID: SurfaceID) -> TabID? {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs where tab.rootPane.allSurfaceIDs().contains(surfaceID) {
                    return tab.id
                }
            }
        }
        return nil
    }

    /// Jump to the most-recently-active pane in the current tab (`select-pane -l`).
    /// No-op if there's no remembered pane still present in this tab.
    func selectLastPane() {
        guard let tab = snapshot.activeWorkspace?.activeTab,
              let last = lastActiveSurfaceID,
              tab.rootPane.allSurfaceIDs().contains(last)
        else { return }
        setActiveSurface(last)
        focusPaneContent(last)
    }

    /// Mark/unmark the active pane as the `join-pane` source (`select-pane -m`/`-M`).
    /// Marking a second pane moves the mark; `set: false` clears it.
    func setMarkedPane(_ set: Bool) {
        markedSurfaceID = set ? activeSurfaceID : nil
        for host in terminalHosts.allHosts() {
            host.showsMarkedBorder = host.surfaceID == markedSurfaceID
        }
    }

    /// Re-assert the marked border after a pane remount (called from the content
    /// mount path alongside `ensureActivePane`).
    func reassertMarkedPane() {
        for host in terminalHosts.allHosts() {
            host.showsMarkedBorder = markedSurfaceID != nil && host.surfaceID == markedSurfaceID
        }
    }

    /// `display-panes`: overlay a number on each pane of the active tab; the digit
    /// the user presses jumps to that pane.
    func showDisplayPanes() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let surfaces = tab.rootPane.allSurfaceIDs()
        let panes = surfaces.enumerated().compactMap { index, sid -> (number: Int, host: TerminalHostView)? in
            guard let host = terminalHosts.host(for: sid) else { return nil }
            return (number: index, host: host)
        }
        DisplayPanesOverlay.shared.show(panes: panes) { [weak self] surfaceID in
            self?.setActiveSurface(surfaceID)
            self?.focusPaneContent(surfaceID)
        }
    }

    /// `synchronize-panes`: toggle (or set) input mirroring across all panes of the
    /// active tab. `on == nil` toggles.
    func setSynchronizePanes(_ on: Bool?) {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let nowOn = on ?? !synchronizedTabIDs.contains(tab.id)
        if nowOn { synchronizedTabIDs.insert(tab.id) } else { synchronizedTabIDs.remove(tab.id) }
        // Write the per-tab option through (tmux: synchronize-panes IS a window
        // option), so `setw -t <tab> synchronize-panes` and the GUI toggle are one
        // state — the compositor honors the same option for the same tab.
        requestDaemonAsync(.setOption(
            scope: "tab", target: tab.id.uuidString,
            key: "synchronize-panes", rawValue: nowOn ? "on" : "off"
        ))
        refreshSyncSiblings()
        DisplayMessage.show(nowOn ? "synchronize-panes: on" : "synchronize-panes: off")
    }

    /// Adopt per-tab `synchronize-panes` options written outside the GUI (`setw`,
    /// the compositor toggle) into the local mirror. Called from full syncs, so it asks off the
    /// main thread: a window coming forward never waits on a (remote) daemon for it.
    func adoptSynchronizeOptions() {
        let service = DaemonSessionService(endpoint: activeEndpoint)
        let owner = activeOwner
        DispatchQueue.global(qos: .userInitiated).async {
            guard case let .options(entries)? = try? service.request(.showOptions(scope: "tab")) else { return }
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    guard owner == self.activeOwner else { return }
                    var changed = false
                    for entry in entries where entry.key == "synchronize-panes" {
                        guard let target = entry.target, let tabID = TabID(uuidString: target) else { continue }
                        let on = entry.value == "on" || entry.value == "true" || entry.value == "1"
                        if on != self.synchronizedTabIDs.contains(tabID) {
                            if on { self.synchronizedTabIDs.insert(tabID) } else { self.synchronizedTabIDs.remove(tabID) }
                            changed = true
                        }
                    }
                    if changed { self.refreshSyncSiblings() }
                }
            }
        }
    }

    /// Push each live host its sibling surface ids when its tab is synchronized
    /// (and clears them otherwise). Called on toggle and after every structure sync.
    func refreshSyncSiblings() {
        let liveTabIDs = Set(snapshot.workspaces.flatMap { $0.sessions.flatMap { $0.tabs.map(\.id) } })
        synchronizedTabIDs.formIntersection(liveTabIDs)
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    let surfaceIDs = tab.rootPane.allSurfaceIDs()
                    let synced = synchronizedTabIDs.contains(tab.id) && surfaceIDs.count > 1
                    for sid in surfaceIDs {
                        guard let host = terminalHosts.host(for: sid) else { continue }
                        host.setSyncSiblings(synced ? surfaceIDs.filter { $0 != sid }.map(\.uuidString) : [])
                    }
                }
            }
        }
    }

    /// Join the marked pane into the active pane as a split (`join-pane`). The
    /// marked pane becomes a new split alongside the active pane, then the mark
    /// clears. No-op (with a toast) if nothing is marked or the mark is gone.
    func joinMarkedPane(direction: SplitDirection) {
        guard let markedSurface = markedSurfaceID,
              let tab = snapshot.activeWorkspace?.activeTab,
              let activeSurface = activeSurfaceID,
              let destPane = paneID(for: activeSurface, in: tab.rootPane)
        else { DisplayMessage.show("join-pane: no marked pane"); return }
        // The marked pane can live in any tab; find its pane id across the snapshot.
        let sourcePane = snapshot.workspaces
            .flatMap(\.sessions).flatMap(\.tabs)
            .compactMap { paneID(for: markedSurface, in: $0.rootPane) }
            .first
        guard let sourcePane, sourcePane != destPane else {
            DisplayMessage.show("join-pane: invalid mark")
            return
        }
        requestDaemonAsync(.joinPane(sourcePaneID: sourcePane, destPaneID: destPane, direction: direction))
        setMarkedPane(false)
        refreshSnapshot()
    }

    /// Re-assert the active-pane border after a (re)mount of `tab`'s panes. If the
    /// tracked active surface isn't part of this tab, fall back to its first pane so
    /// a freshly shown tab always has a clearly focused pane.
    func ensureActivePane(for tab: Tab) {
        let surfaces = tab.rootPane.allSurfaceIDs()
        guard !surfaces.isEmpty else { return }
        let target = activeSurfaceID.flatMap { surfaces.contains($0) ? $0 : nil } ?? surfaces.first
        setActiveSurface(target)
        // Focus the active pane's terminal so typing + copy/paste target it immediately.
        // Reused host views don't re-fire `viewDidMoveToWindow`, so this mount path (run on
        // every tab/pane switch) must re-assert first responder explicitly — otherwise the
        // first responder can linger on the previous tab's view and ⌘C/⌘V miss.
        if let target { focusPaneContent(target) }
    }

    /// Persist a divider drag. Metadata-only sync: ratio isn't part of the structure
    /// fingerprint, so this never remounts panes or re-fades the chrome.
    /// It lands after a debounce, so it goes to the tab's own daemon: the window may have gone
    /// behind one on another machine by then.
    func setSplitRatio(tabID: TabID, firstPaneID: PaneID, secondPaneID: PaneID, ratio: Double,
                       completion: @escaping @MainActor @Sendable () -> Void = {}) {
        let request = IPCRequest.resizePaneRatio(tabID: tabID, firstPaneID: firstPaneID, secondPaneID: secondPaneID, ratio: ratio)
        let endpoint = tab(tabID)?.rootPane.allSurfaceIDs().first.map(endpoint(forSurface:)) ?? activeEndpoint
        requestDaemonBatch([request], endpoint: endpoint) { _ in completion() }
    }

    /// Commit a tab drag-reorder. Full sync so the tab bar rebuilds in the new order
    /// (the metadata path updates pills in place by ID and wouldn't reflect a reorder).
    func reorderSession(workspaceID: WorkspaceID, sessionID: SessionID, toIndex: Int) {
        requestDaemonAsync(.reorderSession(workspaceID: workspaceID, sessionID: sessionID, toIndex: toIndex))
        refreshSnapshot()
    }

    func renameWorkspace(id: WorkspaceID, name: String) {
        requestDaemonAsync(.renameWorkspace(workspaceID: id, name: name))
        refreshSnapshot()
    }

    func reorderTab(workspaceID: WorkspaceID, tabID: TabID, toIndex: Int) {
        requestDaemonAsync(.reorderTab(workspaceID: workspaceID, tabID: tabID, toIndex: toIndex))
        refreshSnapshot()
    }

    private func surfaceID(forPane paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        switch node {
        case let .leaf(leaf) where leaf.id == paneID:
            return leaf.surfaceID
        case let .branch(_, _, first, second):
            return surfaceID(forPane: paneID, in: first) ?? surfaceID(forPane: paneID, in: second)
        default:
            return nil
        }
    }

    /// A daemon-relayed request from the CLI (`harness-cli copy-mode`).
    func handleDirective(_ directive: ClientDirective, owner: String? = nil) {
        switch directive {
        case let .capabilities(values): notificationOwners[owner ?? activeOwner] = values.contains(DaemonStats.notificationPolicy)
        case let .notification(delivery):
            guard delivery.expires > .now else { return }
            let notice = delivery.notice, source = owner ?? activeOwner
            if NSApp.isActive, source == activeOwner, notice.surfaceID == activeSurfaceID?.uuidString { return }
            if delivery.banners {
                let body = notice.message.isEmpty ? notice.minimalMessage : notice.message
                DesktopNotifier.show(
                    title: notice.title, body: body, withSound: delivery.chimes, owner: source, surfaceID: notice.surfaceID)
            } else if delivery.chimes { NSSound(named: "Glass")?.play() }
            if delivery.speech, !notificationSpeech.isSpeaking {
                notificationSpeech.speak(AVSpeechUtterance(string: notice.minimalMessage))
            }
        case let .copyMode(surfaceID, enabled):
            guard let id = UUID(uuidString: surfaceID),
                  let host = TerminalPaneRegistryAccess.host(for: id),
                  host.isInCopyMode != enabled
            else { return }
            if enabled {
                host.enterCopyMode(modeKeys: HarnessOptions.shared.get("mode-keys", scope: .global)?.stringValue ?? "vi")
            } else {
                host.exitCopyMode()
            }
        }
    }

    /// Toggle the in-pane copy-mode overlay on the active pane. The native surface owns the
    /// scrollback and drives the shared `CopyModeReducer`, so no daemon text capture is needed.
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

    /// Forward a `copy-mode -X` action (from the `:` prompt / `send-keys -X`) to the active pane.
    func performCopyModeAction(_ action: CopyModeAction) {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.performCopyModeAction(action)
    }

    /// Release the active pane to headless: drop this client's output subscription + size vote so
    /// the PTY keeps running (and can grow to other clients), then re-grab with
    /// `reattachActiveSurface()`. Routed through the host — the daemon's per-client detach acts on
    /// the subscribing connection, which an ephemeral RPC socket is not.
    func detachActiveSurface() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.detachFromDaemonSurface()
    }

    /// Re-grab a surface released with `detachActiveSurface()`: resubscribe and replay scrollback.
    func reattachActiveSurface() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.reattachToDaemonSurface()
    }

    /// True when the active pane has been released from the daemon (its detach overlay is up) —
    /// drives Detach/Reattach menu-item enablement.
    var activePaneIsDetached: Bool {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return false }
        return host.isDetachedFromDaemon
    }

    /// Scroll the active pane's viewport to the previous OSC 133 shell prompt (no-op without marks).
    func jumpToPreviousPrompt() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.jumpToPreviousPrompt()
    }

    /// Scroll the active pane's viewport to the next OSC 133 shell prompt (no-op without marks).
    func jumpToNextPrompt() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.jumpToNextPrompt()
    }

    /// Select the active pane's last finished command output (OSC 133 marks; no-op without them).
    func selectLastCommandOutput() {
        guard let surfaceID = activeSurfaceID,
              let host = TerminalPaneRegistryAccess.host(for: surfaceID) else { return }
        host.selectLastCommandOutput()
    }

    func selectWorkspace(byIndex index: Int) {
        guard index >= 0, index < snapshot.workspaces.count else { return }
        selectWorkspace(snapshot.workspaces[index].id)
    }

    /// Rename the active tab in a sheet on its window. The name sticks: the program's own
    /// title no longer replaces it.
}
