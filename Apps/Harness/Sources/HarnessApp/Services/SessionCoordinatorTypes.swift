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
    // UNUserNotificationCenter.current() crashes on macOS 26 due to a corrupted NSCalendarDate
    // in the notification database. Use NSAppleScript in-process instead: Standard Additions
    // attributes `display notification` to the process that executes it, so running inside
    // Harness attributes the notification to Harness rather than to the frontmost app.
    static func requestAuthorizationIfNeeded() {}
    /// - Parameter completion: reports whether the AppleScript actually ran without error.
    ///   `NSAppleScript` is main-thread-only, so this always dispatches there — running it on a
    ///   background queue (the previous behavior) could fail silently depending on caller context.
    static func show(
        title: String, body: String, withSound: Bool = true,
        completion: (@MainActor @Sendable (Bool) -> Void)? = nil
    ) {
        let soundClause = withSound ? " sound name \"Glass\"" : ""
        let script = """
            display notification "\(Self.escape(body))" with title "\(Self.escape(title))"\(soundClause)
            """
        DispatchQueue.main.async {
            var error: NSDictionary?
            NSAppleScript(source: script)?.executeAndReturnError(&error)
            if let error {
                NSLog("DesktopNotifier: display notification failed: %@", error)
            }
            let succeeded = error == nil
            Task { @MainActor in completion?(succeeded) }
        }
    }
    static func authorizationStatus(_ completion: @escaping @MainActor (UNAuthorizationStatus) -> Void) {
        Task { @MainActor in completion(.authorized) }
    }
    static func requestOrOpenSettings() { openSystemNotificationSettings() }
    static func openSystemNotificationSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }
    static func sendTest(completion: (@MainActor @Sendable (Bool) -> Void)? = nil) {
        show(title: "Harness", body: "Notifications are working!", completion: completion)
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
