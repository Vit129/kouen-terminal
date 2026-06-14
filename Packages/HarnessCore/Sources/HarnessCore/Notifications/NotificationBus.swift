import Foundation

/// @unchecked Sendable: the subscriber table is guarded by `lock`; posts hop to the main queue.
public final class NotificationBus: @unchecked Sendable {
    public static let shared = NotificationBus()

    public let notificationPosted = Notification.Name("HarnessNotificationPosted")
    public let tabStatusChanged = Notification.Name("HarnessTabStatusChanged")
    public let snapshotChanged = Notification.Name("HarnessSnapshotChanged")
    public let configReloaded = Notification.Name("HarnessConfigReloaded")
    public let sendKeysRequested = Notification.Name("HarnessSendKeysRequested")
    public let copyModeRequested = Notification.Name("HarnessCopyModeRequested")
    public let captureRequested = Notification.Name("HarnessCaptureRequested")
    /// Posted when a mutating MCP tool executes, carrying the surface ID and tool name.
    /// Used by StatusLineView to show a transient "MCP" indicator.
    public let mcpActivity = Notification.Name("HarnessMCPActivity")

    private var latest: AgentNotification?
    private let lock = NSLock()
    private var captureProvider: ((String, Bool) -> String?)?

    private init() {}

    public func post(_ notification: AgentNotification) {
        lock.lock()
        latest = notification
        lock.unlock()
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.notificationPosted,
                object: nil,
                userInfo: ["notification": notification]
            )
        }
    }

    public func postSnapshotChanged(revision: Int) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.snapshotChanged,
                object: nil,
                userInfo: ["revision": revision]
            )
        }
    }

    /// Posted after a script config file is (re)loaded, so `harness.events.on("configReloaded", ...)`
    /// handlers can react to the load that just happened.
    public func postConfigReloaded() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: self.configReloaded, object: nil)
        }
    }

    /// Posted when a mutating MCP tool is executed. `toolName` is e.g. "sendPaneText".
    public func postMCPActivity(surfaceID: String, toolName: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.mcpActivity, object: nil,
                userInfo: ["surfaceID": surfaceID, "toolName": toolName]
            )
        }
    }

    public func postSendKeys(surfaceID: String, data: Data) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.sendKeysRequested,
                object: nil,
                userInfo: [
                    "surfaceID": surfaceID,
                    "data": data,
                ]
            )
        }
    }

    public func postCopyMode(surfaceID: String, enabled: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.copyModeRequested,
                object: nil,
                userInfo: [
                    "surfaceID": surfaceID,
                    "enabled": enabled,
                ]
            )
        }
    }

    /// Register a synchronous capture provider for the renderer surfaces. The
    /// daemon calls `requestCapture` to read scrollback from the running app.
    public func registerCaptureProvider(_ provider: @escaping (String, Bool) -> String?) {
        lock.lock()
        captureProvider = provider
        lock.unlock()
    }

    public func requestCapture(surfaceID: String, includeScrollback: Bool) -> String? {
        lock.lock()
        let provider = captureProvider
        lock.unlock()
        return provider?(surfaceID, includeScrollback)
    }

    public func latestNotification() -> AgentNotification? {
        lock.lock()
        defer { lock.unlock() }
        return latest
    }
}
