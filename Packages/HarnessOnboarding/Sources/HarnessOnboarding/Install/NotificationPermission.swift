import AppKit
import UserNotifications

/// Lets the first-run wizard ask macOS for notification permission with context, so a freshly
/// downloaded Harness can alert on agent activity without the user hunting through Settings.
///
/// The app installs the foreground-presentation delegate at launch (`DesktopNotifier`); this
/// helper only drives the system prompt, or routes to System Settings when already denied
/// (macOS never re-prompts after a denial).
enum NotificationPermission {
    enum State: Equatable { case granted, denied, undetermined }

    private static func map(_ status: UNAuthorizationStatus) -> State {
        switch status {
        case .authorized, .provisional, .ephemeral: return .granted
        case .denied: return .denied
        default: return .undetermined
        }
    }

    /// Current permission, delivered on the main queue.
    static func current(_ completion: @escaping (State) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let state = map(settings.authorizationStatus)
            DispatchQueue.main.async { completion(state) }
        }
    }

    /// Prompt when undecided; open System Settings ▸ Notifications when already denied.
    static func request(_ completion: @escaping (State) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async {
                    openSystemSettings()
                    completion(.denied)
                }
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(.granted) }
            default:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async { completion(granted ? .granted : .denied) }
                }
            }
        }
    }

    static func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }
}
