import AppKit
import HarnessCore
import UserNotifications

struct NotificationEntry: Identifiable, Equatable {
    let workspaceID: WorkspaceID
    let workspaceName: String
    let sessionID: SessionID
    let tabID: TabID
    let tabTitle: String
    let surfaceID: SurfaceID
    let agentKind: AgentKind?
    let body: String
    var id: TabID { tabID }
}

enum DesktopNotifier {
    // UNUserNotificationCenter.current() crashes on macOS 26 beta due to a corrupted
    // NSCalendarDate in the notification database. Fallback: osascript AppleScript notification.
    // Use `tell application "Harness"` (by name) so macOS attributes the notification to
    // our app in Notification Center — `tell application id` doesn't work reliably unless
    // the app has registered via UNUserNotificationCenter (which we can't do on macOS 26).
    static func requestAuthorizationIfNeeded() {}
    static func show(title: String, body: String, withSound: Bool = true) {
        let soundClause = withSound ? " sound name \"Glass\"" : ""
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Harness"
        let script = """
            tell application "\(appName)"
                display notification "\(Self.escape(body))" with title "\(Self.escape(title))"\(soundClause)
            end tell
            """
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
    }
    static func authorizationStatus(_ completion: @escaping @MainActor (UNAuthorizationStatus) -> Void) {
        Task { @MainActor in completion(.authorized) }
    }
    static func requestOrOpenSettings() { openSystemNotificationSettings() }
    static func openSystemNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }
    static func sendTest() {
        show(title: "Harness", body: "Notifications are working!")
    }
    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\")
         .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

enum HarnessPathDisplay {
    static func title(for path: String, fallback: String) -> String {
        if path == "/" { return "/" }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        let shortened = path.hasPrefix(home + "/") ? "~" + path.dropFirst(home.count) : path
        let last = (String(shortened) as NSString).lastPathComponent
        if !last.isEmpty { return last }
        if !fallback.isEmpty, fallback != "Shell" { return fallback }
        return "Terminal"
    }
}
