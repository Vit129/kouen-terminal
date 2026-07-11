import AppKit
import Foundation
import KouenCore
import KouenTerminalEngine
import KouenTerminalKit
import KouenTheme

/// Handles daemon IPC, snapshot hydration, metadata refresh, and structure indexing.
@MainActor
final class DaemonSyncService {
    private unowned let coord: SessionCoordinator
    private let daemon = DaemonSessionService()
    private(set) var snapshot = SessionSnapshot()
    private(set) var lastRevision = -1
    private var metadataTask: Task<Void, Never>?
    private(set) var snapshotRefreshTask: Task<Void, Never>?
    var pendingSnapshotRevision: Int?
    private var snapshotSub: DaemonSubscription?

    init(coordinator: SessionCoordinator) {
        self.coord = coordinator
    }

    // MARK: - Endpoint

    func switchEndpoint(_ endpoint: Endpoint) {
        daemon.switchEndpoint(endpoint)
        snapshotSub = nil
        ensureSnapshotSubscription()
    }

    func ensureSnapshotSubscription() {
        guard snapshotSub == nil else { return }
        do {
            let endpoint = daemon.endpoint
            let client = DaemonClient(endpoint: endpoint)
            snapshotSub = try client.subscribeSnapshot(
                label: "KouenGUI",
                onRevision: { [weak self] revision in
                    guard let self else { return }
                    Task { @MainActor in
                        guard revision != self.lastRevision,
                              revision != self.pendingSnapshotRevision else { return }
                        self.pendingSnapshotRevision = revision
                        self.scheduleSnapshotRefresh()
                    }
                },
                onBrowserRequest: { [weak self] id, paneID, req in
                    guard let self else { return }
                    Task { @MainActor in
                        await self.handleBrowserRequest(id: id, req: req)
                    }
                },
                onOpenGitPanel: { repoPath in
                    Task { @MainActor in
                        NotificationCenter.default.post(
                            name: .kouenOpenGitPanel,
                            object: nil,
                            userInfo: repoPath.map { ["repoPath": $0] }
                        )
                    }
                },
                onEnd: { [weak self] in
                    // Daemon restarted or socket dropped — clear the dead sub so
                    // ensureSnapshotSubscription() can re-subscribe on next call.
                    Task { @MainActor in
                        self?.snapshotSub = nil
                        self?.ensureSnapshotSubscription()
                    }
                }
            )
        } catch {
            fputs("Kouen: failed to subscribe to snapshot channel: \(error)\n", kouenStderr)
        }
    }

    private func handleBrowserRequest(id: UUID, req: BrowserRequestPayload) async {
        switch req {
        case let .open(url, direction, originSurfaceID):
            let newPaneID = UUID()
            coord.splitPaneCoordinator.openBrowserPane(
                url: url, direction: direction ?? .horizontal, paneID: newPaneID, originSurfaceID: originSurfaceID
            )
            _ = await request(.browserResponse(id: id, response: .open(paneID: newPaneID)))

        case let .navigate(paneID, url):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            view.navigate(to: url)
            _ = await request(.browserResponse(id: id, response: .ok))

        case let .wait(paneID, timeoutSeconds):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            do {
                try await view.waitForLoad(timeout: timeoutSeconds ?? 30.0)
                _ = await request(.browserResponse(id: id, response: .ok))
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .snapshot(paneID, interactive):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            do {
                let snap = try await view.snapshot(interactive: interactive ?? false)
                _ = await request(.browserResponse(id: id, response: .snapshot(snap)))
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .interact(paneID, action, elementID, text):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            
            // extract the index from elementID, e.g. "e3" -> 3
            let numericString = elementID.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
            guard let index = Int(numericString) else {
                _ = await request(.browserResponse(id: id, response: .error("Invalid element ID '\(elementID)'")))
                return
            }
            
            let script: String
            if action.lowercased() == "type" {
                let escapedText = (text ?? "").replacingOccurrences(of: "\\", with: "\\\\")
                                               .replacingOccurrences(of: "\"", with: "\\\"")
                                               .replacingOccurrences(of: "\n", with: "\\n")
                script = """
                (function(){
                  var all=document.querySelectorAll('a,button,input,select,textarea,[role=button]');
                  var el=all[\(index) - 1];
                  if(!el) return JSON.stringify({ok:false,error:'element not found'});
                  el.focus();
                  el.value = "\(escapedText)";
                  el.dispatchEvent(new Event('input', { bubbles: true }));
                  el.dispatchEvent(new Event('change', { bubbles: true }));
                  return JSON.stringify({ok:true});
                })()
                """
            } else if action.lowercased() == "click" {
                script = """
                (function(){
                  var all=document.querySelectorAll('a,button,input,select,textarea,[role=button]');
                  var el=all[\(index) - 1];
                  if(!el) return JSON.stringify({ok:false,error:'element not found'});
                  el.click();
                  return JSON.stringify({ok:true});
                })()
                """
            } else if action.lowercased() == "scroll" {
                script = """
                (function(){
                  var all=document.querySelectorAll('a,button,input,select,textarea,[role=button]');
                  var el=all[\(index) - 1];
                  if(!el) return JSON.stringify({ok:false,error:'element not found'});
                  el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                  return JSON.stringify({ok:true});
                })()
                """
            } else {
                _ = await request(.browserResponse(id: id, response: .error("Unknown action '\(action)'")))
                return
            }
            
            do {
                let jsonResult = try await view.evaluateJS(script)
                struct JSResult: Codable {
                    var ok: Bool
                    var error: String?
                }
                if let data = jsonResult.data(using: .utf8),
                   let parsed = try? JSONDecoder().decode(JSResult.self, from: data) {
                    if parsed.ok {
                        _ = await request(.browserResponse(id: id, response: .ok))
                    } else {
                        _ = await request(.browserResponse(id: id, response: .error(parsed.error ?? "Interaction failed")))
                    }
                } else {
                    _ = await request(.browserResponse(id: id, response: .ok))
                }
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .cookies(paneID):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            let jar = await view.cookies()
            _ = await request(.browserResponse(id: id, response: .cookies(jar)))

        case let .storage(paneID, storageType):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            do {
                let items = try await view.storage(type: storageType)
                _ = await request(.browserResponse(id: id, response: .storage(items)))
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .network(paneID):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            do {
                let entries = try await view.networkRequests()
                _ = await request(.browserResponse(id: id, response: .network(entries)))
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .screenshot(paneID):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            do {
                let base64 = try await view.screenshot()
                _ = await request(.browserResponse(id: id, response: .screenshot(base64)))
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .close(paneID):
            coord.splitPaneCoordinator.killPane(paneID: paneID)
            _ = await request(.browserResponse(id: id, response: .ok))

        case let .evaluate(paneID, script):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            do {
                let result = try await view.evaluateJS(script)
                _ = await request(.browserResponse(id: id, response: .text(result)))
            } catch {
                _ = await request(.browserResponse(id: id, response: .error(error.localizedDescription)))
            }

        case let .goBack(paneID):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            view.webView.goBack()
            _ = await request(.browserResponse(id: id, response: .ok))

        case let .goForward(paneID):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            view.webView.goForward()
            _ = await request(.browserResponse(id: id, response: .ok))

        case let .reload(paneID):
            guard let view = BrowserPaneRegistry.shared.get(paneID) else {
                _ = await request(.browserResponse(id: id, response: .error("Browser pane not found")))
                return
            }
            view.webView.reload()
            _ = await request(.browserResponse(id: id, response: .ok))
        }
    }

    // MARK: - Sync

    func scheduleSnapshotRefresh() {
        guard !AppIdleThrottle.shared.isSuspended else { return }
        guard snapshotRefreshTask == nil else { return }
        snapshotRefreshTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while true {
                pendingSnapshotRevision = nil
                _ = await coord.syncFromDaemon()
                guard let pendingSnapshotRevision, pendingSnapshotRevision != lastRevision else {
                    snapshotRefreshTask = nil
                    return
                }
            }
        }
    }

    @discardableResult
    func sync(metadataOnly: Bool = false) -> Bool {
        ensureSnapshotSubscription()
        let remote: SessionSnapshot
        do {
            remote = try daemon.fetchSnapshot()
        } catch {
            fputs("Kouen: snapshot fetch failed: \(error)\n", kouenStderr)
            coord.noteDaemonError(error)
            return false
        }
        StartupMetrics.shared.mark(.firstSnapshot)
        applySnapshot(remote, metadataOnly: metadataOnly)
        return true
    }

    @discardableResult
    func sync(metadataOnly: Bool = false) async -> Bool {
        ensureSnapshotSubscription()
        let remote: SessionSnapshot
        do {
            remote = try await daemon.fetchSnapshot()
        } catch {
            fputs("Kouen: snapshot fetch failed: \(error)\n", kouenStderr)
            coord.noteDaemonError(error)
            return false
        }
        StartupMetrics.shared.mark(.firstSnapshot)
        applySnapshot(remote, metadataOnly: metadataOnly)
        return true
    }

    private func applySnapshot(_ remote: SessionSnapshot, metadataOnly: Bool, preserveBrowserPanes: Bool = true) {
        let structureChanged = Self.structureFingerprint(remote) != Self.structureFingerprint(snapshot)
        var merged = remote
        if preserveBrowserPanes {
            // Fast path: skip the O(W×S×T) merge entirely when no browser panes exist
            // in the current snapshot — the common case for non-browser-pane users.
            let hasBrowserPanes = snapshot.workspaces.contains { ws in
                ws.sessions.contains { session in
                    session.tabs.contains { !$0.rootPane.allBrowserLeaves().isEmpty }
                }
            }
            if hasBrowserPanes {
                for (wIdx, ws) in snapshot.workspaces.enumerated() {
                    guard wIdx < merged.workspaces.count else { continue }
                    for (sIdx, session) in ws.sessions.enumerated() {
                        guard sIdx < merged.workspaces[wIdx].sessions.count else { continue }
                        for (tIdx, tab) in session.tabs.enumerated() {
                            guard tIdx < merged.workspaces[wIdx].sessions[sIdx].tabs.count else { continue }
                            let browserLeaves = tab.rootPane.allBrowserLeaves()
                            guard !browserLeaves.isEmpty else { continue }
                            let incomingBrowserLeaves = merged.workspaces[wIdx].sessions[sIdx].tabs[tIdx].rootPane.allBrowserLeaves()
                            if incomingBrowserLeaves.isEmpty {
                                merged.workspaces[wIdx].sessions[sIdx].tabs[tIdx].rootPane = tab.rootPane
                            }
                        }
                    }
                }
            }
        }
        snapshot = merged
        lastRevision = remote.revision
        if structureChanged {
            coord.structureRevision += 1
            let live = Set(remote.workspaces.flatMap { ws in
                ws.sessions.flatMap { session in
                    session.tabs.flatMap { $0.rootPane.allSurfaceIDs() }
                }
            })
            coord.terminalHosts.prune(keeping: live)
        }
        coord.notificationCoordinator.pushNewRemoteNotifications(from: remote)
        coord.notificationCoordinator.pushAgentActivityNotifications(from: remote)
        // Surface index only needs rebuild when pane tree changes.
        if structureChanged {
            coord.surfaceIndex = buildSurfaceIndex(remote)
        }
        if !metadataOnly {
            let themeKey = "\(remote.themeName)|\(coord.settings.backgroundOpacity)|\(coord.settings.backgroundBlur)|\(coord.settings.customBackgroundHex ?? "")|\(coord.settings.customForegroundHex ?? "")|\(coord.settings.customCursorHex ?? "")"
            if themeKey != coord.appliedThemeKey {
                coord.appliedThemeKey = themeKey
                coord.applyThemeToAllHosts()
            }
        }
        coord.syncWaitingRings()
        coord.notificationCoordinator.updateDockBadge(from: remote)
        coord.reflectRemoteActivePane()
        NotificationBus.shared.postSnapshotChanged(SnapshotChangedPayload(
            revision: remote.revision,
            structureChanged: structureChanged,
            metadataOnly: metadataOnly,
            chromeChanged: !metadataOnly
        ))
    }

    func applyLocalSnapshot(_ updated: SessionSnapshot) {
        // `updated` already reflects the desired local pane tree (including any
        // browser pane additions/removals), so skip the daemon-sync re-injection
        // that would otherwise restore a just-closed browser pane.
        applySnapshot(updated, metadataOnly: false, preserveBrowserPanes: false)
    }

    // MARK: - Ephemeral cleanup

    func closeEphemeralSessionsBeforeQuit() {
        for attempt in 0 ..< 2 {
            if (try? daemon.request(.closeEphemeralSessions, timeout: 4)) != nil { return }
            if attempt == 0 { Thread.sleep(forTimeInterval: 0.1) }
        }
        fputs("Kouen: closeEphemeralSessions did not confirm before quit\n", kouenStderr)
    }

    // MARK: - Index

    func buildSurfaceIndex(_ snap: SessionSnapshot) -> [SurfaceID: (tab: Tab, tabID: TabID)] {
        var index: [SurfaceID: (tab: Tab, tabID: TabID)] = [:]
        for workspace in snap.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    for sid in tab.rootPane.allSurfaceIDs() {
                        index[sid] = (tab, tab.id)
                    }
                }
            }
        }
        return index
    }

    static func structureFingerprint(_ snap: SessionSnapshot) -> String {
        // Hash ALL tabs across every workspace/session so pane kills in non-active tabs
        // trigger structureChanged and prune() runs. allSurfaceIDs() already returns []
        // for .browser nodes, so browser-pane IDs are excluded automatically — no risk
        // of the blink loop (daemon snapshot never contains browser IDs either).
        let surfaces = snap.workspaces.flatMap { ws in
            ws.sessions.flatMap { session in
                session.tabs.flatMap { $0.rootPane.allSurfaceIDs() }
            }
        }.map(\.uuidString).sorted().joined(separator: ",")
        let panes = snap.workspaces.flatMap { ws in
            ws.sessions.flatMap { session in
                session.tabs.flatMap { $0.rootPane.allLeaves() }
            }
        }.map(\.id.uuidString).sorted().joined(separator: ",")
        return "\(surfaces)|\(panes)"
    }

    // MARK: - Daemon request

    @discardableResult
    func request(_ request: IPCRequest) -> IPCResponse? {
        do {
            return try daemon.request(request)
        } catch {
            fputs("Kouen daemon request failed: \(error)\n", kouenStderr)
            coord.noteDaemonError(error)
            return nil
        }
    }

    @discardableResult
    func request(_ request: IPCRequest) async -> IPCResponse? {
        do {
            return try await daemon.request(request)
        } catch {
            fputs("Kouen daemon request failed: \(error)\n", kouenStderr)
            coord.noteDaemonError(error)
            return nil
        }
    }

    func logIfFailed(_ request: IPCRequest) {
        do {
            _ = try daemon.request(request)
        } catch {
            fputs("Kouen daemon metadata update failed: \(error)\n", kouenStderr)
        }
    }

    func logIfFailed(_ request: IPCRequest) async {
        do {
            _ = try await daemon.request(request)
        } catch {
            fputs("Kouen daemon metadata update failed: \(error)\n", kouenStderr)
        }
    }

    // MARK: - Metadata refresh

    func startMetadataRefresh() {
        metadataTask?.cancel()
        metadataTask = Task { [weak self] in
            let git = GitMetadataProvider()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                let work = await MainActor.run { () -> [(WorkspaceID, Tab)] in
                    guard let self,
                          !AppIdleThrottle.shared.isSuspended,
                          let workspace = self.snapshot.activeWorkspace else { return [] }
                    return workspace.sessions.flatMap { $0.tabs }.map { (workspace.id, $0) }
                }
                var probedCWDs = [String: String?]() // probePath → branch result
                let updates = work.compactMap { workspaceID, tab -> (WorkspaceID, TabID, String?)? in
                    let probePath = tab.worktreePath ?? tab.cwd
                    let branch: String?
                    if let cached = probedCWDs[probePath] {
                        branch = cached
                    } else {
                        let updated = git.refresh(tab: tab)
                        branch = updated.gitBranch
                        probedCWDs[probePath] = branch
                    }
                    guard branch != tab.gitBranch else { return nil }
                    return (workspaceID, tab.id, branch)
                }
                guard !updates.isEmpty else { continue }
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    var activeTabGitBranchDidChange = false
                    for update in updates {
                        self.logIfFailed(.updateTabGitBranch(
                            workspaceID: update.0,
                            tabID: update.1,
                            branch: update.2
                        ))
                        if self.snapshot.activeWorkspaceID == update.0,
                           self.snapshot.activeWorkspace?.activeTab?.id == update.1 {
                            activeTabGitBranchDidChange = true
                        }
                    }
                    self.coord.syncFromDaemon(metadataOnly: true)
                    if activeTabGitBranchDidChange {
                        NotificationCenter.default.post(
                            name: Notification.Name("KouenActiveTabGitBranchDidChange"),
                            object: nil
                        )
                    }
                }
            }
        }
    }
}
