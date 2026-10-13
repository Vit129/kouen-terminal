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
    // MARK: Event-driven metadata + snapshot pushes
    // (replaced the 2 s loop that spawned `git rev-parse` per tab per tick and blind-synced
    // a full snapshot at 0.5 Hz forever)

    func configureGitBranchMonitor() {
        gitBranchMonitor.onBranchChange = { [weak self] workspaceID, tabID, branch in
            // The daemon commit pushes back through the snapshot subscription, which is
            // what refreshes the visible label — no manual re-sync here.
            self?.logIfFailed(.updateTabGitBranch(workspaceID: workspaceID, tabID: tabID, branch: branch))
        }
    }

    /// The active workspace's tabs, shaped for the branch monitor. Matches the old poll's
    /// scope: background workspaces refresh when they become active.
    func gitBranchRecords(from snapshot: SessionSnapshot) -> [GitBranchMonitor.TabRecord] {
        // A remote cwd belongs to the remote filesystem. A local lookup could erase its
        // real branch or substitute a different repository at the same path on this Mac.
        guard activeOwner == DaemonSidebar.localID else { return [] }
        guard let workspace = snapshot.activeWorkspace else { return [] }
        return workspace.sessions.flatMap(\.tabs).map { tab in
            GitBranchMonitor.TabRecord(
                workspaceID: workspace.id,
                tabID: tab.id,
                cwd: tab.cwd,
                snapshotBranch: tab.gitBranch
            )
        }
    }

    func startSnapshotSubscriptionIfNeeded() {
        guard snapshotSubscription == nil, !snapshotSubscriptionPending else { return }
        startSnapshotSubscription()
    }

    func startSnapshotSubscription() {
        snapshotSubscriptionGeneration += 1
        snapshotSubscription?.cancel()
        snapshotSubscription = nil
        snapshotSubscriptionPending = false
        // Switching to a local window must retire the previous remote subscription
        // even when local readiness still prevents opening the replacement.
        guard activeOwner != DaemonSidebar.localID || localServiceReady else { return }
        let generation = snapshotSubscriptionGeneration
        let subscribedOwner = activeOwner
        notificationOwners[subscribedOwner] = false
        snapshotSubscriptionPending = true
        let service = DaemonSessionService(endpoint: activeEndpoint)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let subscription = try? service.subscribeSnapshot(
                label: "harness-app",
                capabilities: [
                    DaemonStats.clientCapabilities, DaemonStats.notificationPolicy, DaemonStats.paneContent,
                    DaemonStats.activityState, DaemonStats.agentIdentities,
                ],
                onRevision: { [weak self] revision in
                    DispatchQueue.main.async {
                        guard let self, generation == self.snapshotSubscriptionGeneration else { return }
                        self.handlePushedRevision(revision)
                    }
                },
                onDirective: { [weak self] directive in
                    DispatchQueue.main.async {
                        guard let self, generation == self.snapshotSubscriptionGeneration else { return }
                        self.handleDirective(directive, owner: subscribedOwner)
                    }
                },
                onEnd: { [weak self] in
                    DispatchQueue.main.async {
                        guard let self, generation == self.snapshotSubscriptionGeneration else { return }
                        // Invalidate an attachment completion still on its way to main.
                        self.snapshotSubscriptionGeneration += 1
                        self.snapshotSubscriptionPending = false
                        self.snapshotSubscription = nil
                        self.scheduleSnapshotResubscribe()
                    }
                }
            )
            DispatchQueue.main.async { [weak self] in
                guard let self, generation == self.snapshotSubscriptionGeneration else {
                    subscription?.cancel()
                    return
                }
                self.snapshotSubscriptionPending = false
                self.snapshotSubscription = subscription
                if subscription != nil {
                    self.snapshotResubscribeDelay = 1
                    self.refreshSnapshot() // Close the fetch-to-subscribe revision gap.
                } else {
                    self.scheduleSnapshotResubscribe()
                }
            }
        }
    }

    private func handlePushedRevision(_ revision: Int) {
        // Echo guard: our own mutations sync synchronously, so the push for a revision we
        // already hold must not trigger a second fetch.
        guard revision != lastRevision else { return }
        refreshSnapshot()
    }

    func selections(for endpoint: Endpoint) -> SelectionQueue {
        if let queue = selectionQueues[endpoint] { return queue }
        let service = DaemonSessionService(endpoint: endpoint)
        let queue = SelectionQueue { _ = try? service.request($0) }
        selectionQueues[endpoint] = queue
        return queue
    }

    /// Fetch the active daemon's snapshot off the main thread (a remote daemon answers over SSH)
    /// and apply it. metadataOnly: a pushed revision never rebuilds every pane's renderer — the
    /// daemon commits often while an agent streams. Structure changes still remount
    /// (structureChanged is computed independently) and a CLI theme change still applies
    /// (themeChanged forces the chrome path).
    func refreshSnapshot() {
        guard activeOwner != DaemonSidebar.localID || localServiceReady else { return }
        guard pendingDaemonOperations[activeEndpoint, default: 0] == 0 else { refetch = true; return }
        guard !fetchInFlight else {
            refetch = true
            return
        }
        fetchInFlight = true
        refetch = false
        let service = DaemonSessionService(endpoint: activeEndpoint)
        let owner = activeOwner
        let applied = appliedSnapshots
        let sent = selectionsSent
        let queue = selections(for: activeEndpoint)
        DispatchQueue.global(qos: .userInitiated).async {
            queue.sync {} // after the selections already sent, without holding up later ones
            let fresh = try? service.fetchSnapshot()
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    self.fetchInFlight = false
                    // Another daemon became active, or a sync landed meanwhile (it is at least as
                    // new): this answer is stale. So is one that started before a selection went
                    // out (a pane click applies no snapshot): ask again, or the old active pane
                    // takes focus back.
                    if sent != self.selectionsSent {
                        self.refetch = true
                    } else if let fresh, owner == self.activeOwner, applied == self.appliedSnapshots {
                        self.applySnapshot(fresh, metadataOnly: true)
                    }
                    if self.refetch { self.refreshSnapshot() }
                }
            }
        }
    }

    /// The daemon went away (restart, backlog eviction, socket death): retry with capped
    /// backoff until it answers. On success, fetch at once — revisions pushed during the
    /// gap were lost with the socket.
    private func scheduleSnapshotResubscribe() {
        let delay = snapshotResubscribeDelay
        let generation = snapshotSubscriptionGeneration
        snapshotResubscribeDelay = min(delay * 2, 8)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, generation == self.snapshotSubscriptionGeneration,
                  self.snapshotSubscription == nil, !self.snapshotSubscriptionPending else { return }
            self.startSnapshotSubscription()
        }
    }

    func startSafetyPoll() {
        safetyPollTimer?.invalidate()
        let timer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshSnapshot() }
        }
        timer.tolerance = 5
        RunLoop.main.add(timer, forMode: .common)
        safetyPollTimer = timer
    }

    func observeAppActivation() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        // Any number of external `git` operations may have happened while the watchers
        // were paused — resume re-resolves and re-reads everything.
        gitBranchMonitor.resume()
        startSafetyPoll()
    }

    @objc private func appDidResignActive() {
        gitBranchMonitor.pause()
        safetyPollTimer?.invalidate()
        safetyPollTimer = nil
    }

    // MARK: OSC 1337 user variables (coalesced daemon push)

    static let maxUserVariablesPerSurface = 64

    func afterDaemonOperations(_ completion: @escaping @MainActor @Sendable () -> Void) {
        selections(for: activeEndpoint).perform { DispatchQueue.main.async { completion() } }
    }

    /// GUI operations are ordered per captured endpoint, independently of the input streams.
    /// A failed mutation is never retried; only a subsequent snapshot may reconcile its outcome.
    func requestDaemonAsync(_ request: IPCRequest, refresh: Bool = true, deliverStaleResult: Bool = false,
                            completion: @escaping @MainActor @Sendable (IPCResponse?) -> Void = { _ in }) {
        requestDaemonBatch([request], refresh: refresh, deliverStaleResult: deliverStaleResult, completion: completion)
    }

    func requestDaemonBatch(_ requests: [IPCRequest], refresh: Bool = true,
                            endpoint: Endpoint? = nil, deliverStaleResult: Bool = false,
                            completion: @escaping @MainActor @Sendable (IPCResponse?) -> Void = { _ in }) {
        performDaemonOperation(endpoint: endpoint, refresh: refresh, deliverStaleResult: deliverStaleResult, operation: { service in
            var response = IPCResponse.ok
            for request in requests { response = try service.request(request) }
            return response
        }, completion: completion)
    }

    func performDaemonOperation(
        endpoint: Endpoint? = nil, refresh: Bool = true, deliverStaleResult: Bool = false,
        operation: @escaping @Sendable (DaemonSessionService) throws -> IPCResponse,
        completion: @escaping @MainActor @Sendable (IPCResponse?) -> Void = { _ in }
    ) {
        let endpoint = endpoint ?? activeEndpoint
        guard endpoint != .localControlSocket || localServiceReady else { completion(nil); return }
        let owner = activeOwner, sent = selectionsSent
        let service = DaemonSessionService(endpoint: endpoint)
        pendingDaemonOperations[endpoint, default: 0] += 1
        selections(for: endpoint).perform { [weak self] in
            let result = Result { try operation(service) }
            let fresh = refresh ? try? service.fetchSnapshot() : nil
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.pendingDaemonOperations[endpoint, default: 1] -= 1
                let current = owner == self.activeOwner && endpoint == self.activeEndpoint && sent == self.selectionsSent
                switch result {
                case let .success(response): completion(current || deliverStaleResult ? response : nil)
                case let .failure(error):
                    self.daemonFailureRevision += 1
                    fputs("Harness daemon operation failed: \(error)\n", harnessStderr)
                    if current { DisplayMessage.show("\(error). Check the current state before trying again.") }
                    completion(nil)
                }
                if current, let fresh, fresh.revision >= self.snapshot.revision {
                    self.applySnapshot(fresh, metadataOnly: false)
                    self.refetch = false
                }
                if endpoint == self.activeEndpoint, self.refetch,
                   self.pendingDaemonOperations[endpoint, default: 0] == 0 { self.refreshSnapshot() }
            }
        }
    }

    /// A throttled, non-blocking notice that the daemon is unreachable.
    func noteDaemonError(_ error: Error) {
        let now = Date()
        if let last = lastDaemonErrorNotice, now.timeIntervalSince(last) < 8 { return }
        lastDaemonErrorNotice = now
        guard let host = (NSApp.keyWindow ?? NSApp.mainWindow)?.contentView else { return }
        Toast.show("Reconnecting to HarnessDaemon…", in: host)
    }

    /// Fire-and-forget metadata update that logs on failure instead of silently
    /// swallowing it. No modal — these (title/cwd/branch) are too frequent to alert on,
    /// but a stale label is worth a diagnostic line.
    /// What a pane reports goes to that pane's own daemon: a window behind may be on another
    /// machine. That daemon's next push refreshes whichever snapshot holds the pane.
    /// A request about one pane, sent to that pane's own daemon (errors show like any request).
    func logIfFailed(_ request: IPCRequest, surface surfaceID: SurfaceID? = nil) {
        let endpoint = surfaceID.map(endpoint(forSurface:)) ?? activeEndpoint
        let service = DaemonSessionService(endpoint: endpoint)
        selections(for: endpoint).perform {
            do { try service.request(request) }
            catch { fputs("Harness daemon metadata update failed: \(error)\n", harnessStderr) }
        }
    }
}
