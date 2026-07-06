import AppKit
import KouenCore
import UserNotifications

/// Lets the first-run wizard ask macOS for notification permission with context, so a freshly
/// downloaded Kouen can alert on agent activity without the user hunting through Settings.
///
/// The app installs the foreground-presentation delegate at launch (`DesktopNotifier`); this
/// helper only drives the system prompt, or routes to System Settings when already denied
/// (macOS never re-prompts after a denial).
enum NotificationPermission {
    enum State: Equatable, Sendable { case granted, denied, undetermined }

    private static func map(_ status: UNAuthorizationStatus) -> State {
        switch status {
        case .authorized, .provisional, .ephemeral: return .granted
        case .denied: return .denied
        default: return .undetermined
        }
    }

    /// Current permission, delivered on the main queue. Falls back to `.undetermined` when
    /// `UNUserNotificationCenter` is known-bad on this machine (see `NotificationCenterProbe` in
    /// KouenApp — corrupted-database crash on some macOS 26 installs).
    static func current(_ completion: @escaping @MainActor @Sendable (State) -> Void) {
        guard !NotificationCenterProbe.isKnownBad else {
            deliver(.undetermined, to: completion)
            return
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = settings.authorizationStatus
            Task { @MainActor in completion(map(status)) }
        }
    }

    /// Prompt when undecided; open System Settings ▸ Notifications when already denied. Falls
    /// back to opening Settings + `.undetermined` when `UNUserNotificationCenter` is known-bad.
    static func request(_ completion: @escaping @MainActor @Sendable (State) -> Void) {
        guard !NotificationCenterProbe.isKnownBad else {
            openSystemSettings()
            deliver(.undetermined, to: completion)
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error {
                NSLog("NotificationPermission: requestAuthorization failed: %@", error.localizedDescription)
            }
            Task { @MainActor in completion(granted ? .granted : .denied) }
        }
    }

    private static func deliver(_ state: State, to completion: @escaping @MainActor @Sendable (State) -> Void) {
        Task { @MainActor in completion(state) }
    }

    static func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }
}
