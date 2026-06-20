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
    // NSCalendarDate in the notification database. Fallback: osascript AppleScript notification
    // using `tell application` to attribute the notification to Harness (not Script Editor).
    static func requestAuthorizationIfNeeded() {}
    static func show(title: String, body: String, withSound: Bool = true) {
        let soundClause = withSound ? " sound name \"Glass\"" : ""
        // Use the bundle identifier to tell the system this notification belongs to Harness.
        // `tell application id` with our CFBundleIdentifier makes macOS attribute the
        // notification (and its icon) to Harness.app instead of Script Editor.
        let bundleID = Bundle.main.bundleIdentifier ?? "com.robert.harness"
        let script = """
            tell application id "\(bundleID)"
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
