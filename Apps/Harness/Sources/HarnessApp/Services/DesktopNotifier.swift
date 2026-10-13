import AVFoundation
import AppKit
import Foundation
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit
import HarnessTheme
import Network
import UserNotifications

enum DesktopNotifier {
    private static var notificationCenter: UNUserNotificationCenter? {
        // UserNotifications traps when invoked by an unpackaged executable or XCTest host.
        guard Bundle.main.bundleURL.pathExtension == "app", Bundle.main.bundleIdentifier != nil else { return nil }
        return UNUserNotificationCenter.current()
    }

    /// Register foreground delivery without asking for permission before the user chooses setup.
    static func configurePresentation() {
        guard let center = notificationCenter else { return }
        // Without a delegate that opts in, macOS suppresses banners while Harness is
        // the *frontmost* app — so an agent notification fired while you're looking at
        // another tab would silently no-op. The presenter forces banner + sound + list
        // even in the foreground, so agent alerts always land.
        center.delegate = ForegroundPresenter.shared
    }

    static func show(title: String, body: String, withSound: Bool = true, owner: String? = nil, surfaceID: String? = nil) {
        guard let center = notificationCenter else { return }
        // The delegate is set once in `configurePresentation` (called at app launch
        // before any notification can fire) and in `requestOrOpenSettings` / `sendTest`.
        // Re-setting it here on every banner delivery was redundant and slightly wasteful
        // (UNUserNotificationCenter retains the delegate strongly per Apple docs, so it can
        // never be nil'd between those bootstrap calls and this point).
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                add(title: title, body: body, withSound: withSound, owner: owner, surfaceID: surfaceID)
            case .notDetermined, .denied:
                if withSound {
                    DispatchQueue.main.async { NSSound(named: "Glass")?.play() }
                }
            @unknown default:
                add(title: title, body: body, withSound: withSound, owner: owner, surfaceID: surfaceID)
            }
        }
    }

    private static func add(title: String, body: String, withSound: Bool, owner: String?, surfaceID: String?) {
        let content = UNMutableNotificationContent()
        if let owner, let surfaceID { content.userInfo = ["owner": owner, "surfaceID": surfaceID] }
        content.title = title
        content.body = body
        content.sound = withSound ? .default : nil
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        guard let center = notificationCenter else { return }
        center.add(request) { error in
            if let error {
                fputs("Harness notification delivery failed: \(error)\n", harnessStderr)
            }
        }
    }

    /// The current system authorization status, on the main actor — drives the Settings
    /// permission indicator so the user can tell whether macOS is allowing alerts at all.
    static func authorizationStatus(_ completion: @escaping @MainActor (UNAuthorizationStatus) -> Void) {
        guard let center = notificationCenter else { return }
        center.getNotificationSettings { settings in
            let status = settings.authorizationStatus
            DispatchQueue.main.async { MainActor.assumeIsolated { completion(status) } }
        }
    }

    /// Drive the permission flow from a user action: prompt when undecided, or open System
    /// Settings ▸ Notifications when macOS has already denied us (the system never re-prompts
    /// after a denial, so the only path back is the settings pane).
    static func requestOrOpenSettings() {
        guard let center = notificationCenter else { return }
        center.delegate = ForegroundPresenter.shared
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async { openSystemNotificationSettings() }
            default:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if !granted {
                        DispatchQueue.main.async { openSystemNotificationSettings() }
                    }
                }
            }
        }
    }

    static func openSystemNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }

    /// Fire a one-off banner so the user can confirm delivery end-to-end (bypasses the
    /// agent-activity gates; still honors the system permission). If permission isn't granted
    /// yet, request/route it first so the test isn't a silent no-op.
    static func sendTest(_ completion: @escaping @MainActor @Sendable (String) -> Void) {
        guard let center = notificationCenter else {
            DispatchQueue.main.async { completion("Notifications require a packaged macOS application.") }
            return
        }
        center.delegate = ForegroundPresenter.shared
        let report: @Sendable (String) -> Void = { message in
            DispatchQueue.main.async { completion(message) }
        }
        let submit: @Sendable () -> Void = {
            let content = UNMutableNotificationContent()
            content.title = "Harness"
            content.body = "Test notification — alerts are working."
            content.sound = .default
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)) { error in
                if let error {
                    let failure = error as NSError
                    report("macOS refused the test (\(failure.domain), code \(failure.code)). Check this app's "
                        + "signing and notification permission in System Settings.")
                } else {
                    report("Test accepted by macOS. Banner visibility also depends on Focus and system notification settings.")
                }
            }
        }
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                submit()
            case .denied:
                report("macOS is blocking Harness notifications. Allow them in System Settings ▸ Notifications.")
                DispatchQueue.main.async { openSystemNotificationSettings() }
            default:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error {
                        let failure = error as NSError
                        report("macOS could not request permission (\(failure.domain), code \(failure.code)). "
                            + "Check this app's signing and registration before trying again.")
                    } else if granted {
                        submit()
                    } else {
                        report("Notification permission was not granted. Allow this app in System Settings ▸ Notifications.")
                        DispatchQueue.main.async { openSystemNotificationSettings() }
                    }
                }
            }
        }
    }
}

/// Presents agent notifications as banners even when Harness is frontmost (the OS
/// default is to swallow them). Retained for the process lifetime as the UN delegate.
private final class ForegroundPresenter: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = ForegroundPresenter()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        let owner = info["owner"] as? String
        let surface = (info["surfaceID"] as? String).flatMap(UUID.init(uuidString:))
        DispatchQueue.main.async {
            guard let owner, let surface else { return }
            let coordinator = SessionCoordinator.shared
            if let item = coordinator.attentionList().first(where: { $0.owner == owner && $0.entry.surfaceID == surface }) {
                NSApp.activate(ignoringOtherApps: true)
                coordinator.openAttention(item)
            } else { DisplayMessage.show("This pane has closed or its host is disconnected.") }
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
