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
    // MARK: - Remote daemons

    /// Every attached daemon, the active one first.
    var connectedOwners: [String] { [activeOwner] + links.keys.sorted() }

    func connectionDescription(for owner: String) -> String {
        if pendingRemoteAttachments[owner] != nil { return "Connecting…" }
        if reconnectingHosts.contains(owner) { return "Reconnecting…" }
        if let error = remoteAttachmentErrors[owner] { return "Disconnected: " + error }
        if disconnectedHosts.contains(owner) || !isConnected(owner) { return "Disconnected" }
        return "Connected"
    }

    func retryConnection(_ owner: String) {
        guard owner != DaemonSidebar.localID else { return }
        if isConnected(owner) { remoteTunnelDropped(owner) }
        else { connectToRemote(named: owner) }
    }

    func isConnected(_ owner: String) -> Bool { owner == activeOwner || links[owner] != nil }

    /// The latest snapshot of `owner`'s daemon (empty when it isn't attached).
    func snapshot(for owner: String) -> SessionSnapshot {
        owner == activeOwner ? snapshot : links[owner]?.snapshot ?? SessionSnapshot(workspaces: [])
    }

    /// A tab on any attached daemon.
    func tab(_ id: TabID) -> Tab? {
        for owner in connectedOwners {
            if let tab = snapshot(for: owner).workspaces.lazy.flatMap(\.sessions).flatMap(\.tabs).first(where: { $0.id == id }) {
                return tab
            }
        }
        return nil
    }

    /// Where a pane's daemon is reached: the attached daemon whose snapshot has it.
    func notificationOwner(for surfaceID: SurfaceID) -> String {
        if Self.surfaces(in: snapshot).contains(surfaceID) { return activeOwner }
        return links.values.first { Self.surfaces(in: $0.snapshot).contains(surfaceID) }?.owner ?? activeOwner
    }

    func endpoint(forSurface surfaceID: SurfaceID) -> Endpoint {
        guard !Self.surfaces(in: snapshot).contains(surfaceID) else { return activeEndpoint }
        return links.values.first { Self.surfaces(in: $0.snapshot).contains(surfaceID) }?.endpoint ?? activeEndpoint
    }

    func endpoint(forOwner owner: String) -> Endpoint? {
        owner == activeOwner ? activeEndpoint : links[owner]?.endpoint
    }

    func performLibrary(_ operation: LibraryOperation, owner: String,
                        completion: @escaping @MainActor @Sendable (Result<IPCResponse, Error>) -> Void) {
        guard let endpoint = endpoint(forOwner: owner) else {
            completion(.failure(SetupError.invalid("Reconnect to \(owner) first.")))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let result = Result<(IPCResponse, SessionSnapshot), Error> {
                let client = DaemonClient(endpoint: endpoint)
                guard case let .daemonStats(stats) = try client.request(.daemonStats),
                      stats.capabilities?.contains(DaemonStats.sessionLibrary) == true else {
                    throw SetupError.invalid("Update the daemon on this host to use Saved Setups and Recently Closed.")
                }
                let response = try client.requestForCurrentClient(.library(operation), timeout: 10)
                if case let .error(message) = response { throw SetupError.invalid(message) }
                return (response, try DaemonSessionService(endpoint: endpoint).fetchSnapshot())
            }
            DispatchQueue.main.async {
                switch result {
                case let .success((response, fresh)):
                    if owner == self.activeOwner { self.applySnapshot(fresh, metadataOnly: false) }
                    else { self.links[owner]?.accept(fresh) }
                    completion(.success(response))
                case let .failure(error): completion(.failure(error))
                }
            }
        }
    }

    /// Two panes on one machine: a pane can move next to the other (panes never cross daemons).
    func sameMachine(_ a: SurfaceID, _ b: SurfaceID) -> Bool {
        endpoint(forSurface: a) == endpoint(forSurface: b)
    }

    static func surfaces(in snapshot: SessionSnapshot) -> Set<SurfaceID> {
        Set(snapshot.workspaces.flatMap { $0.sessions.flatMap { $0.tabs.flatMap { $0.rootPane.allSurfaceIDs() } } })
    }

    /// Make `owner`'s daemon the active one: its window came to the front. With `session`,
    /// that session (and its workspace) is selected before the first sync, so the window never
    /// flashes another. Nothing here waits on the daemon: the selection shows at once and the
    /// daemon hears about it off the main thread. The daemon that was active stays attached in
    /// the background, panes and all.
    func activate(owner: String, selecting session: SessionID? = nil) {
        if owner != activeOwner {
            guard let link = links.removeValue(forKey: owner) else { return }
            link.stop()
            attachLink(DaemonLink(owner: activeOwner, endpoint: activeEndpoint, snapshot: snapshot))
            switchActiveDaemon(to: owner, endpoint: link.endpoint, known: link.snapshot, selecting: session)
        } else if let session, let selected = select(session) {
            applySnapshot(selected, metadataOnly: false)
            refreshSnapshot()
        }
    }

    /// `snapshot` with `session` and its workspace active; nil when they already are (or no
    /// workspace has it). The selection goes to the daemon off the main thread; fetches and
    /// commands after it wait for it. The revision stays: the daemon's own commit moves it.
    private func select(_ session: SessionID) -> SessionSnapshot? {
        guard let index = snapshot.workspaces.firstIndex(where: { $0.sessions.contains { $0.id == session } }) else { return nil }
        var selected = snapshot
        let workspaceID = selected.workspaces[index].id
        selected.workspaces[index].activeSessionID = session
        selected.activeWorkspaceID = workspaceID
        guard selected != snapshot else { return nil }
        // The session first: selecting the workspace first would show its other session for a moment.
        send(.selectSession(workspaceID: workspaceID, sessionID: session), .selectWorkspace(id: workspaceID))
        return selected
    }

    /// Send selections to the active daemon off the main thread, in order (see `SelectionQueue`).
    func send(_ requests: IPCRequest...) {
        selectionsSent += 1
        let queue = selections(for: activeEndpoint)
        for request in requests { queue.async(request) }
    }

    private func attachLink(_ link: DaemonLink) {
        link.onChange = { [weak self] link in self?.linkChanged(link) }
        let owner = link.owner
        link.onCapabilities = { [weak self] values in self?.notificationOwners[owner] = values.contains(DaemonStats.notificationPolicy) }
        link.onDirective = { [weak self] directive in self?.handleDirective(directive, owner: owner) }
        links[link.owner] = link
        if link.owner != DaemonSidebar.localID || localServiceReady { link.start() }
    }

    /// A background daemon moved: its windows and every sidebar re-render.
    private func linkChanged(_ link: DaemonLink) {
        pruneHosts()
        pushAgentNotifications()
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: ["revision": snapshot.revision, "structureChanged": false, "chromeChanged": false, "metadataOnly": false]
        )
    }

    /// Attach to a saved remote daemon and bring it to the front in a window (with `session`,
    /// that session). The windows on other daemons stay as they are.
    func connectToRemote(named name: String, showing session: SessionID? = nil) {
        attachRemote(named: name) { [weak self] attached in
            if attached { self?.showDaemon(name, session: session) }
            else if let self, let message = self.remoteAttachmentErrors[name] {
                let alert = NSAlert()
                alert.messageText = "Could not connect to \(name)"
                alert.informativeText = message + "\n\nCheck the host, SSH configuration and remote socket, then "
                    + "choose Retry Connection. Existing sessions remain running."
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }

    func attachRemote(named name: String, then done: @escaping @MainActor @Sendable (Bool) -> Void) {
        if isConnected(name) {
            done(true)
            return
        }
        if pendingRemoteAttachments[name] != nil {
            pendingRemoteAttachments[name]?.callbacks.append(done)
            return
        }
        let id = UUID()
        pendingRemoteAttachments[name] = (id, [done])
        remoteAttachmentErrors.removeValue(forKey: name)
        if let host = (NSApp.keyWindow ?? NSApp.mainWindow)?.contentView {
            Toast.show("Connecting to " + name + "…", in: host)
        }
        let epoch = SSHTunnelManager.shared.connectionEpoch(for: name)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Carry Sendable values (an endpoint, a snapshot, a message) back to the main actor.
            var resolved: Endpoint?
            var failureMessage: String?
            do {
                resolved = try RemoteHostsService.shared.connect(named: name, expectedEpoch: epoch)
            } catch {
                failureMessage = "\(error)"
            }
            let endpoint = resolved
            let first = endpoint.flatMap { try? DaemonSessionService(endpoint: $0).fetchSnapshot() }
            let message = failureMessage ?? "\(name) didn't answer"
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    guard let self else { return }
                    guard self.pendingRemoteAttachments[name]?.id == id else {
                        if self.pendingRemoteAttachments[name] == nil, !self.isConnected(name) {
                            RemoteHostsService.shared.disconnect(named: name)
                        }
                        return
                    }
                    let callbacks = self.pendingRemoteAttachments.removeValue(forKey: name)?.callbacks ?? []
                    guard let endpoint, let first else {
                        self.remoteAttachmentErrors[name] = String(message.prefix(1024))
                        for callback in callbacks { callback(false) }
                        return
                    }
                    if !self.isConnected(name) {
                        self.attachLink(DaemonLink(owner: name, endpoint: endpoint, snapshot: first))
                    }
                    self.disconnectedHosts.remove(name)
                    self.remoteAttachmentErrors.removeValue(forKey: name)
                    for callback in callbacks { callback(true) }
                }
            }
        }
    }

    /// Bring an attached daemon to the front: the window showing `session`, else a window
    /// already on that daemon (switched to `session`), else a new window.
    func showDaemon(_ owner: String, session: SessionID? = nil) {
        guard isConnected(owner) else { return }
        if let session, let window = WindowContexts.window(showing: session) {
            window.makeKeyAndOrderFront(nil)
            return
        }
        let snap = snapshot(for: owner)
        if let context = WindowContexts.all.first(where: { $0.owner == owner && $0.window != nil }), let window = context.window {
            activate(owner: owner, selecting: session ?? context.sessionID)
            window.makeKeyAndOrderFront(nil)
            // Becoming key selects the window's own session: `session` replaces it.
            if let session { activate(owner: owner, selecting: session) }
            return
        }
        guard let target = session ?? snap.activeWorkspace?.activeSessionID ?? snap.workspaces.first?.sessions.first?.id else { return }
        (NSApp.delegate as? AppDelegate)?.openWindow(showing: target, owner: owner)
    }

    func observeRemoteConnectivity() {
        let center = NSWorkspace.shared.notificationCenter
        wakeObserver = center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.probeRemoteConnections() }
        }
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard path.status == .satisfied else { return }
            DispatchQueue.main.async { self?.probeRemoteConnections() }
        }
        networkMonitor.start(queue: DispatchQueue(label: "com.harness.remote-connectivity"))
    }
    private func probeRemoteConnections() {
        for owner in connectedOwners
        where owner != DaemonSidebar.localID && !remoteProbePending.contains(owner) && remoteProbePending.count < 64 {
            guard let endpoint = endpoint(forOwner: owner) else { continue }
            remoteProbePending.insert(owner)
            let epoch = SSHTunnelManager.shared.connectionEpoch(for: owner)
            remoteProbeQueue.addOperation { [weak self] in
                let reachable: Bool
                if case .pong? = try? DaemonClient(endpoint: endpoint).request(.ping, timeout: 1) {
                    reachable = true
                } else {
                    reachable = false
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }; self.remoteProbePending.remove(owner)
                    guard self.isConnected(owner), epoch == SSHTunnelManager.shared.connectionEpoch(for: owner) else { return }
                    if reachable {
                        self.disconnectedHosts.remove(owner)
                        self.links[owner]?.refreshConnection()
                        if self.activeOwner == owner { self.refreshSnapshot() }
                    } else { self.remoteTunnelDropped(owner) }
                }
            }
        }
    }

    /// A tunnel died (sleep, Wi-Fi change, remote reboot). Bring it back with backoff
    /// instead of leaving that daemon's windows on a dead socket.
    func remoteTunnelDropped(_ name: String) {
        // One reconnect chain per host: a retry's own short-lived ssh also reports a drop.
        guard isConnected(name), !reconnectingHosts.contains(name) else { return }
        reconnectingHosts.insert(name)
        disconnectedHosts.insert(name)
        NotificationCenter.default.post(name: NotificationBus.shared.snapshotChanged, object: self)
        DisplayMessage.show("Lost the connection to \(name). Reconnecting…")
        let generation = UUID(); reconnectGenerations[name] = generation
        scheduleRemoteReconnect(name, attempt: 0, generation: generation)
    }

    private func scheduleRemoteReconnect(_ name: String, attempt: Int, generation: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + RemoteReconnect.jitteredDelay(attempt: attempt)) { [weak self] in
            MainActor.assumeIsolated {
                // The person may have disconnected meanwhile.
                guard let self, self.isConnected(name), self.reconnectGenerations[name] == generation else {
                    return
                }
                let epoch = SSHTunnelManager.shared.connectionEpoch(for: name)
                DispatchQueue.global(qos: .userInitiated).async {
                    let endpoint = try? RemoteHostsService.shared.connect(named: name, expectedEpoch: epoch)
                    DispatchQueue.main.async {
                        MainActor.assumeIsolated {
                            guard self.isConnected(name), self.reconnectGenerations[name] == generation else {
                                return
                            }
                            if let endpoint {
                                self.disconnectedHosts.remove(name)
                                self.reconnectingHosts.remove(name)
                                if self.activeOwner == name {
                                    self.switchActiveDaemon(to: name, endpoint: endpoint)
                                } else {
                                    self.links[name]?.start(endpoint: endpoint)
                                }
                                DisplayMessage.show("Reconnected to \(name).")
                            } else if attempt + 1 < RemoteReconnect.maxAttempts {
                                self.scheduleRemoteReconnect(name, attempt: attempt + 1, generation: generation)
                            } else {
                                self.reconnectingHosts.remove(name)
                                NotificationCenter.default.post(name: NotificationBus.shared.snapshotChanged, object: self)
                                DisplayMessage.show("Couldn't reach \(name). Use Remote ▸ \(name) ▸ Retry Connection to try again.")
                            }
                        }
                    }
                }
            }
        }
    }

    /// Detach from a remote daemon: its windows close (the last one moves to this Mac), and
    /// its tunnel goes down. Its sessions keep running there.
    func disconnectRemote(named name: String) {
        guard name != DaemonSidebar.localID else { return }
        reconnectGenerations.removeValue(forKey: name); reconnectingHosts.remove(name)
        let callbacks = pendingRemoteAttachments.removeValue(forKey: name)?.callbacks ?? []
        for callback in callbacks { callback(false) }
        guard isConnected(name) else {
            RemoteHostsService.shared.disconnect(named: name)
            return
        }
        if activeOwner == name {
            // This Mac is attached whenever a remote is active.
            guard let local = links.removeValue(forKey: DaemonSidebar.localID) else { return }
            local.stop()
            switchActiveDaemon(to: DaemonSidebar.localID, endpoint: local.endpoint, known: local.snapshot)
        } else {
            links.removeValue(forKey: name)?.stop()
        }
        RemoteHostsService.shared.disconnect(named: name)
        reconnectingHosts.remove(name)
        pruneHosts()
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: ["revision": snapshot.revision, "structureChanged": true, "chromeChanged": false, "metadataOnly": false]
        )
    }

    /// Sessions on every attached daemon, grouped by machine, for the sidebar and switcher.
    func sidebarGroups() -> [DaemonSidebarGroup] {
        var rows: [DaemonSidebarSession] = []
        for owner in connectedOwners {
            guard let workspace = snapshot(for: owner).activeWorkspace else { continue }
            rows += workspace.sessions.map { session in
                DaemonSidebarSession(id: session.id.uuidString, name: SessionDisplayName.title(of: session, in: workspace), owner: owner)
            }
        }
        return DaemonSidebar.groups(
            localTitle: "This Mac",
            sessions: rows,
            remoteHosts: connectedOwners.filter { $0 != DaemonSidebar.localID }.sorted(),
            remoteDetail: RemoteAttach.explanation
        ).map { group in
            var group = group
            if !group.local { group.detail = connectionDescription(for: group.id) }
            return group
        }
    }

    /// A session row from another daemon: show it in a window (connecting first if needed).
    func focusSidebar(owner: String, sessionID: String) {
        let target = DaemonSidebar.splitDaemon(owner: owner)
        guard let id = UUID(uuidString: sessionID) else { return }
        if target == activeOwner, let workspace = snapshot.workspaces.first(where: { $0.sessions.contains { $0.id == id } }) {
            selectSession(workspaceID: workspace.id, sessionID: id)
        } else {
            connectToRemote(named: target, showing: id)
        }
    }

    func insertListedPath() {
        DirectoryBrowserController.present(over: NSApp.keyWindow ?? NSApp.mainWindow, mode: .insert)
    }

    func goToListedDirectory() {
        DirectoryBrowserController.present(over: NSApp.keyWindow ?? NSApp.mainWindow)
    }

    /// Point commands, new panes, and the push channel at `owner`'s daemon and sync from it.
    /// Panes of the daemon that was active keep their hosts (its windows still show them).
    /// `known` is that daemon's last snapshot: it shows at once (with `session` selected) and
    /// stands in until the fetch answers off the main thread, so a daemon that's slow to answer
    /// never holds up the window or shows another machine's sessions as its own.
    private func switchActiveDaemon(
        to owner: String, endpoint: Endpoint, known: SessionSnapshot? = nil, selecting session: SessionID? = nil
    ) {
        activeOwner = owner
        RemoteHostsService.shared.setActiveHost(owner == DaemonSidebar.localID ? nil : owner)
        activeEndpoint = endpoint
        daemon.switchEndpoint(endpoint)
        if let known {
            // Taken quietly first, so only the selection counts as a change.
            snapshot = known
            lastRevision = known.revision
            applySnapshot(session.flatMap(select) ?? known, metadataOnly: false)
        }
        // Re-point the push channel: the old subscription is pinned to the old daemon
        // (its onEnd is invalidated by the generation bump inside). A failed attempt has
        // no onEnd to retry from, so back off explicitly.
        startSnapshotSubscription()
        refreshSnapshot()
    }

    /// Drop hosts (and per-pane bookkeeping) for panes no attached daemon has any more.
    private func pruneHosts() {
        let live = connectedOwners.reduce(into: Set<SurfaceID>()) { $0.formUnion(Self.surfaces(in: snapshot(for: $1))) }
        terminalHosts.prune(keeping: live)
        let previewKeys = connectedOwners.reduce(into: Set<String>()) { keys, owner in
            let leaves = snapshot(for: owner).workspaces.flatMap(\.sessions).flatMap(\.tabs).flatMap { $0.rootPane.allLeaves() }
            for leaf in leaves where !leaf.paneContent.isTerminal { keys.insert(owner + ":" + leaf.surfaceID.uuidString) }
        }
        for key in previewHosts.keys.filter({ !previewKeys.contains($0) }) { previewHosts.removeValue(forKey: key)?.stop() }

        surfaceRemoteHosts = surfaceRemoteHosts.filter { live.contains($0.key) }
        lastCommandDurations = lastCommandDurations.filter { live.contains($0.key) }
    }

    func syncFromDaemon(completion: @escaping @MainActor @Sendable (Bool) -> Void) {
        guard activeOwner != DaemonSidebar.localID || localServiceReady else { completion(false); return }
        requestDaemonAsync(.getSnapshot, refresh: false) { [weak self] response in
            guard let self, case let .snapshot(snapshot)? = response else { completion(false); return }
            self.applySnapshot(snapshot, metadataOnly: false)
            completion(true)
        }
    }

    var isAwaitingInitialSnapshot: Bool { !hasLocalSnapshot }

    private func updateLocalStartupState(_ state: SessionStartupState) {
        localStartupState = state
        NotificationCenter.default.post(name: .harnessLocalStartupChanged, object: self)
    }

    func connectLocalService(completion: @escaping @MainActor @Sendable (Bool) -> Void = { _ in }) {
        localConnectionCompletions.append(completion)
        guard localConnectionCompletions.count == 1 else { return }
        localServiceReady = false
        links[DaemonSidebar.localID]?.stop()
        updateLocalStartupState(.connecting)
        DaemonLauncher.shared.ensureRunning { [weak self] ready in
            guard let self else { completion(false); return }
            guard ready else {
                self.updateLocalStartupState(DaemonLauncher.shared.pendingUpgrade.map(SessionStartupState.blocked) ?? .unavailable)
                self.finishLocalConnection(false)
                return
            }
            self.localServiceReady = true
            StartupMetrics.shared.mark(.daemonConnected)
            // The user may activate a remote window while local startup is pending.
            // Hydrate the local endpoint regardless of which window is now active.
            self.requestDaemonBatch([.getSnapshot], refresh: false, endpoint: .localControlSocket, deliverStaleResult: true) { response in
                guard case let .snapshot(snapshot)? = response else {
                    self.updateLocalStartupState(.unavailable)
                    self.finishLocalConnection(false)
                    return
                }
                self.hasLocalSnapshot = true
                if self.activeOwner == DaemonSidebar.localID { self.applySnapshot(snapshot, metadataOnly: false) }
                else if let link = self.links[DaemonSidebar.localID] { link.accept(snapshot); link.start() }
                self.finishLocalConnection(true)
            }
        }
    }

    private func finishLocalConnection(_ synced: Bool) {
        let completions = localConnectionCompletions
        localConnectionCompletions.removeAll()
        for completion in completions { completion(synced) }
    }

    func presentSessionServiceRestart() {
        let count = DaemonLauncher.shared.pendingUpgrade?.shellCount
            ?? snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs).flatMap { $0.rootPane.allSurfaceIDs() }.count
        let alert = NSAlert()
        alert.messageText = "Restart the session service?"
        let panes = count == 1 ? "1 pane" : "\(count) panes"
        alert.informativeText = "This stops every shell and program owned by the service, including background "
            + "jobs. The service reports \(panes). Saved layouts will reopen with fresh shells."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Restart Only If Empty")
        alert.addButton(withTitle: "Stop Shells and Restart")
        let result = alert.runModal()
        guard result != .alertFirstButtonReturn else { return }
        localServiceReady = false
        links[DaemonSidebar.localID]?.stop()
        updateLocalStartupState(.connecting)
        DaemonLauncher.shared.restart(force: result == .alertThirdButtonReturn) { failure in
            if let failure {
                self.updateLocalStartupState(DaemonLauncher.shared.pendingUpgrade.map(SessionStartupState.blocked) ?? .unavailable)
                let error = NSAlert()
                error.messageText = "Session service could not restart"
                error.informativeText = failure
                error.runModal()
                self.connectLocalService()
            } else { self.connectLocalService() }
        }
    }

    func applySnapshot(_ remote: SessionSnapshot, metadataOnly: Bool) {
        // Activation, settings and polling can race startup. Never mount an old
        // service's panes before the compatibility handshake has admitted it.
        guard activeOwner != DaemonSidebar.localID || localServiceReady else { return }
        if activeOwner == DaemonSidebar.localID { hasLocalSnapshot = true }
        StartupMetrics.shared.mark(.firstSnapshot) // idempotent: records the first hydration only
        let firstSnapshot = appliedSnapshots == 0
        appliedSnapshots += 1
        // Nothing moved (the safety poll, a sync after an action that changed nothing): no
        // window needs to hear about it.
        if !firstSnapshot, metadataOnly, remote == snapshot, lastRevision == remote.revision { return }
        let structureChanged = structureFingerprint(remote) != structureFingerprint(snapshot)
        // A CLI-driven theme change arrives by push (metadata-only), so it must force the
        // chrome path itself — recurring syncs otherwise never rebuild renderers.
        let themeChanged = remote.themeName != snapshot.themeName
        if let error = remote.persistenceError, error != snapshot.persistenceError {
            DisplayMessage.show("Sessions could not be saved: \(error)")
        }
        if let error = remote.activityError, error != snapshot.activityError { DisplayMessage.show(error) }
        snapshot = remote
        lastRevision = remote.revision
        // The daemon answered: bring up the push channel if it isn't already, and reconcile
        // the branch watchers against the fresh tab set (cheap when nothing moved).
        startSnapshotSubscriptionIfNeeded()
        gitBranchMonitor.update(tabs: gitBranchRecords(from: remote))
        if structureChanged {
            structureRevision += 1
            // Drop hosts for surfaces the daemon no longer knows: killPane / remote closes remount
            // the pane UI but never told the registry, so dead TerminalHostViews (and their Metal
            // surfaces) accumulated for the life of the app. Hosts are only ever registered while
            // building panes from a snapshot, so anything outside the latest snapshot is gone for
            // good. Only the confirmed snapshot retires IO: a failed close must keep its
            // existing terminal usable.
            // Per-surface bookkeeping leaks one entry per pane ever created otherwise: these
            // only shrink on explicit callbacks (an OSC 7 nil-host reset / a command finish),
            // which a killed pane never emits. Panes on other attached daemons stay.
            pruneHosts()
        }
        pushAgentNotifications()
        // Hosts only need re-skinning when the theme moved (settings changes re-apply on their
        // own path, and new hosts are themed when they're made). Options a command may have
        // changed (synchronize-panes, the marked pane, profiles) still re-adopt on full syncs.
        if themeChanged { updateChromeAndHosts() }
        if !metadataOnly || themeChanged { adoptHostOptions() }
        updateDockBadge(from: remote)
        reflectRemoteActivePane()
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: [
                "revision": remote.revision,
                "structureChanged": structureChanged,
                "chromeChanged": themeChanged,
                "metadataOnly": metadataOnly,
            ]
        )
        if firstSnapshot { (NSApp.delegate as? AppDelegate)?.sessionServiceDidConnect() }
    }

    /// Clean-quit reap of ephemeral (Plain-mode, unpinned) sessions. Best-effort but *reliable*: the
    /// daemon can be momentarily busy at quit and a single default-timeout request that drops would
    /// silently leave Plain tabs alive (breaking "quit closes my tabs"). Uses a longer timeout and one
    /// retry, and is bounded so it can never hang process exit. Synchronous — must finish before exit.
    /// Every attached daemon reaps its own: a remote window in front mustn't leave this Mac's
    /// Plain tabs running (or the other way round).
    func closeEphemeralSessionsBeforeQuit() {
        let clients = [DaemonClient(endpoint: activeEndpoint)] + links.values.map { DaemonClient(endpoint: $0.endpoint) }
        for client in clients {
            var confirmed = false
            for attempt in 0 ..< 2 where !confirmed {
                confirmed = (try? client.request(.closeEphemeralSessions, timeout: 4)) != nil
                if !confirmed, attempt == 0 { Thread.sleep(forTimeInterval: 0.1) } // brief gap before the single retry
            }
            if !confirmed { fputs("Harness: closeEphemeralSessions did not confirm before quit\n", harnessStderr) }
        }
    }

    private func structureFingerprint(_ snap: SessionSnapshot) -> Int {
        var hasher = Hasher()
        // Include the active workspace/session/tab identity so intra-tab focus changes
        // and tab switches still bump structureRevision (same behaviour as before).
        if let ws = snap.activeWorkspace {
            hasher.combine(ws.id)
            if let session = ws.activeSession {
                hasher.combine(session.id)
                if let tab = session.activeTab { hasher.combine(tab.id) }
            }
        }
        // Walk *all* workspaces/sessions/tabs so a split added to a background tab (e.g.
        // via the CLI) bumps structureRevision even when that tab isn't active.  This mirrors
        // the prune pass at syncFromDaemon which also walks the full set.
        for ws in snap.workspaces {
            for session in ws.sessions {
                for tab in session.tabs {
                    for surface in tab.rootPane.allSurfaceIDs() {
                        hasher.combine(surface)
                    }
                }
            }
        }
        return hasher.finalize()
    }

    /// After a full snapshot sync: adopt any synchronize-panes changes that arrived with the
    /// snapshot, rebuild the sibling lists for input mirroring, and re-assert the marked-pane
    /// border and per-pane profiles.
    private func adoptHostOptions() {
        adoptSynchronizeOptions()
        refreshSyncSiblings()
        reassertMarkedPane()
        // Foreground-command changes ride snapshot syncs, so profile matches re-evaluate here
        // too (host changes have their own delegate path). Cheap no-op without profiles.
        applyProfileOverridesToAllHosts()
    }
}
