import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

/// Guards against the corrupted-notification-database crash on some macOS 26 installs:
/// `UNUserNotificationCenter.current()` crashes while reading the database, and that crash
/// happens INSIDE Apple's framework code — it's not a catchable Swift error, so no amount of
/// do/try/catch around the call can protect against it (see
/// `agent-memory/knowledge/bugs/zombie-crash-macos26.md` and
/// `REVIEW-graphify-kouen-2026-07-03.md` Part 3 for the original crash report).
///
/// The only way to detect "did the last attempt survive" without ever hard-crashing the app is a
/// flag written to disk BEFORE the risky call and cleared immediately after. If the app relaunches
/// with the flag still set, the previous launch never returned from the call — it crashed — so
/// this permanently avoids `UNUserNotificationCenter` from then on, until `resetForRetry()` is
/// called after the user repairs the database (Step 2 of the review's fix plan).
///
/// Lives in KouenCore (not KouenApp) because both KouenApp's `DesktopNotifier` and
/// KouenOnboarding's `NotificationPermission` need it, and KouenOnboarding cannot depend on
/// the app target — KouenCore is the shared package both already depend on.
public enum NotificationCenterProbe {
    private static let knownBadKey = "notificationCenterKnownBad"
    private static let pendingKey = "notificationCenterProbePending"
    // UserDefaults is internally thread-safe (Apple-documented) but predates Sendable, so the
    // compiler can't verify it - nonisolated(unsafe) matches probeAction's justification above.
    private nonisolated(unsafe) static let defaults = UserDefaults.standard

    /// The risky call being probed. Overridable so tests can exercise the flag state machine
    /// (crash-recovery path, idempotence) without touching the real framework API — a unit test
    /// can't simulate the actual crash (that would kill the test process too), but it can set
    /// `pendingKey` directly to simulate "a prior launch never returned from this call".
    #if canImport(UserNotifications)
    public nonisolated(unsafe) static var probeAction: () -> Void = { _ = UNUserNotificationCenter.current() }
    #else
    // Linux (daemon/CLI only, no notification center to probe): stays a no-op default;
    // only macOS callers (KouenApp, KouenOnboarding) ever touch this type at runtime.
    public nonisolated(unsafe) static var probeAction: () -> Void = {}
    #endif

    /// True once a prior probe attempt never returned - callers must not touch
    /// `UNUserNotificationCenter` while this is true.
    public static var isKnownBad: Bool {
        defaults.bool(forKey: knownBadKey)
    }

    /// Call once, as early as possible at launch, before any other code touches
    /// `UNUserNotificationCenter`. If the previous launch's probe never completed (crashed),
    /// marks the center permanently bad and returns without probing again. Otherwise, if not
    /// already known bad, performs the real probe now.
    public static func runAtLaunch() {
        if defaults.bool(forKey: pendingKey) {
            defaults.set(true, forKey: knownBadKey)
            defaults.removeObject(forKey: pendingKey)
            return
        }
        guard !isKnownBad else { return }
        defaults.set(true, forKey: pendingKey)
        probeAction()
        defaults.removeObject(forKey: pendingKey)
    }

    /// Reset after the user repairs the notification database (Step 2), so the next launch
    /// re-probes instead of permanently avoiding `UNUserNotificationCenter` forever.
    public static func resetForRetry() {
        defaults.removeObject(forKey: knownBadKey)
        defaults.removeObject(forKey: pendingKey)
    }
}
