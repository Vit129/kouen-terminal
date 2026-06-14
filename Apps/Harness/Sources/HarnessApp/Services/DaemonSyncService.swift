import AppKit
import Foundation
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit
import HarnessTheme

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

    init(coordinator: SessionCoordinator) {
        self.coord = coordinator
    }

    // MARK: - Endpoint

    func switchEndpoint(_ endpoint: Endpoint) {
        daemon.switchEndpoint(endpoint)
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
        let remote: SessionSnapshot
        do {
            remote = try daemon.fetchSnapshot()
        } catch {
            fputs("Harness: snapshot fetch failed: \(error)\n", harnessStderr)
            coord.noteDaemonError(error)
            return false
        }
        StartupMetrics.shared.mark(.firstSnapshot)
        applySnapshot(remote, metadataOnly: metadataOnly)
        return true
    }

    @discardableResult
    func sync(metadataOnly: Bool = false) async -> Bool {
        let remote: SessionSnapshot
        do {
            remote = try await daemon.fetchSnapshot()
        } catch {
            fputs("Harness: snapshot fetch failed: \(error)\n", harnessStderr)
            coord.noteDaemonError(error)
            return false
        }
        StartupMetrics.shared.mark(.firstSnapshot)
        applySnapshot(remote, metadataOnly: metadataOnly)
        return true
    }

    private func applySnapshot(_ remote: SessionSnapshot, metadataOnly: Bool) {
        let structureChanged = structureFingerprint(remote) != structureFingerprint(snapshot)
        snapshot = remote
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
        coord.surfaceIndex = buildSurfaceIndex(remote)
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
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: [
                "revision": remote.revision,
                "structureChanged": structureChanged,
                "chromeChanged": !metadataOnly,
                "metadataOnly": metadataOnly,
            ]
        )
    }

    // MARK: - Ephemeral cleanup

    func closeEphemeralSessionsBeforeQuit() {
        for attempt in 0 ..< 2 {
            if (try? daemon.request(.closeEphemeralSessions, timeout: 4)) != nil { return }
            if attempt == 0 { Thread.sleep(forTimeInterval: 0.1) }
        }
        fputs("Harness: closeEphemeralSessions did not confirm before quit\n", harnessStderr)
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

    func structureFingerprint(_ snap: SessionSnapshot) -> String {
        guard let ws = snap.activeWorkspace, let session = ws.activeSession, let tab = session.activeTab else { return "" }
        let surfaces = tab.rootPane.allSurfaceIDs().map(\.uuidString).sorted().joined(separator: ",")
        return "\(ws.id)|\(session.id)|\(tab.id)|\(surfaces)"
    }

    // MARK: - Daemon request

    @discardableResult
    func request(_ request: IPCRequest) -> IPCResponse? {
        do {
            return try daemon.request(request)
        } catch {
            fputs("Harness daemon request failed: \(error)\n", harnessStderr)
            coord.noteDaemonError(error)
            return nil
        }
    }

    @discardableResult
    func request(_ request: IPCRequest) async -> IPCResponse? {
        do {
            return try await daemon.request(request)
        } catch {
            fputs("Harness daemon request failed: \(error)\n", harnessStderr)
            coord.noteDaemonError(error)
            return nil
        }
    }

    func logIfFailed(_ request: IPCRequest) {
        do {
            _ = try daemon.request(request)
        } catch {
            fputs("Harness daemon metadata update failed: \(error)\n", harnessStderr)
        }
    }

    func logIfFailed(_ request: IPCRequest) async {
        do {
            _ = try await daemon.request(request)
        } catch {
            fputs("Harness daemon metadata update failed: \(error)\n", harnessStderr)
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
                    guard let self, let workspace = self.snapshot.activeWorkspace else { return [] }
                    return workspace.sessions.flatMap { $0.tabs }.map { (workspace.id, $0) }
                }
                var probedCWDs = Set<String>()
                let updates = work.compactMap { workspaceID, tab -> (WorkspaceID, TabID, String?)? in
                    let cwd = tab.cwd
                    guard !probedCWDs.contains(cwd) else { return nil }
                    probedCWDs.insert(cwd)
                    let updated = git.refresh(tab: tab)
                    guard updated.gitBranch != tab.gitBranch else { return nil }
                    return (workspaceID, tab.id, updated.gitBranch)
                }
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
                            name: Notification.Name("HarnessActiveTabGitBranchDidChange"),
                            object: nil
                        )
                    }
                }
            }
        }
    }
}
