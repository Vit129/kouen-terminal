import AppKit

/// Suspends expensive *UI-facing* background work (shell tracker polling, status line
/// timer) while the screen is asleep/locked. The daemon and terminal sessions keep running
/// normally (agents finish their work). Only visual refresh is paused — it can't be seen
/// anyway. On screen wake, a single sync catches up instead of replaying every notification.
@MainActor
final class AppIdleThrottle {
    static let shared = AppIdleThrottle()

    private(set) var isSuspended = false
    private var observers: [NSObjectProtocol] = []

    private init() {}

    func install() {
        guard observers.isEmpty else { return }
        let nc = NSWorkspace.shared.notificationCenter
        observers.append(nc.addObserver(
            forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in Task { @MainActor in self?.suspend() } })
        observers.append(nc.addObserver(
            forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in Task { @MainActor in self?.resume() } })
    }

    private func suspend() {
        guard !isSuspended else { return }
        isSuspended = true
        SurfaceShellTracker.shared.stop()
        NotificationCenter.default.post(name: Self.didSuspend, object: nil)
    }

    private func resume() {
        guard isSuspended else { return }
        isSuspended = false
        SurfaceShellTracker.shared.start()
        // Single sync picks up all state changes at once instead of replaying every
        // queued snapshot notification individually (which causes the post-unlock stutter).
        SessionCoordinator.shared.syncFromDaemon()
        NotificationCenter.default.post(name: Self.didResume, object: nil)
    }

    static let didSuspend = Notification.Name("AppIdleThrottleDidSuspend")
    static let didResume = Notification.Name("AppIdleThrottleDidResume")
}
