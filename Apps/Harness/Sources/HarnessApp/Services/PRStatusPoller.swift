import Foundation
import HarnessCore

/// Polls GitHub PR status per active session (30s interval).
/// Only polls sessions whose branch ≠ default (main/master).
@MainActor
final class PRStatusPoller {
    static let shared = PRStatusPoller()

    private let client = GitHubCLIClient()
    private var timer: DispatchSourceTimer?
    private var available: Bool?

    /// Current PR info keyed by session ID.
    private(set) var prBySession: [SessionID: GitHubCLIClient.PRInfo] = [:]

    /// Callback when PR data changes — sidebar observes this.
    var onUpdate: (() -> Void)?

    private static let pollInterval: TimeInterval = 30
    private static let defaultBranches: Set<String> = ["main", "master", "develop"]

    private init() {}

    func start() {
        guard timer == nil else { return }
        // Check availability once
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let avail = self?.client.isAvailable() ?? false
            DispatchQueue.main.async { self?.available = avail }
        }
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 2, repeating: Self.pollInterval)
        t.setEventHandler { [weak self] in self?.poll() }
        t.resume()
        timer = t
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    /// Force an immediate poll (e.g. after user action).
    func pollNow() { poll() }

    private func poll() {
        guard available == true else { return }
        let sessions = SessionCoordinator.shared.snapshot.workspaces.flatMap(\.sessions)
        var updated = false

        for session in sessions {
            guard let tab = session.tabs.first,
                  let branch = tab.gitBranch,
                  !Self.defaultBranches.contains(branch)
            else {
                if prBySession.removeValue(forKey: session.id) != nil { updated = true }
                continue
            }
            let cwd = tab.cwd
            let sessionID = session.id
            // Poll off main thread
            DispatchQueue.global(qos: .utility).async { [weak self, client] in
                let pr = client.prForCurrentBranch(repoPath: cwd)
                DispatchQueue.main.async {
                    guard let self else { return }
                    if self.prBySession[sessionID] != pr {
                        self.prBySession[sessionID] = pr
                        self.onUpdate?()
                    }
                }
            }
        }
        if updated { onUpdate?() }
    }
}
