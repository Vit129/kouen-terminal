import Foundation

// MARK: - SnapshotChangedPayload

/// Typed payload for the `snapshotChanged` notification, replacing the stringly-typed
/// userInfo dictionary. Consumers read this via `Notification.snapshotPayload`.
public struct SnapshotChangedPayload: Sendable {
    /// IPC revision from the daemon. Used by SessionCoordinator for deduplication.
    public let revision: Int
    /// True when the pane tree structure changed (split/close/switch). Consumers that
    /// rebuild expensive layout should gate on this.
    public let structureChanged: Bool
    /// True when only metadata (agent badges, cwd, status) changed — no pane rebuild needed.
    public let metadataOnly: Bool
    /// True when the active theme or opacity changed and renderers should repaint.
    public let chromeChanged: Bool

    public init(revision: Int, structureChanged: Bool, metadataOnly: Bool, chromeChanged: Bool) {
        self.revision = revision
        self.structureChanged = structureChanged
        self.metadataOnly = metadataOnly
        self.chromeChanged = chromeChanged
    }
}

// MARK: - Notification typed accessor

public extension Notification {
    /// Returns the typed `SnapshotChangedPayload` posted by `NotificationBus`.
    /// Falls back to safe conservative defaults for revision-only pings from DaemonClient
    /// (structureChanged=true, metadataOnly=false) so old-path consumers remain correct.
    var snapshotPayload: SnapshotChangedPayload {
        if let p = userInfo?["payload"] as? SnapshotChangedPayload { return p }
        let revision = userInfo?["revision"] as? Int ?? 0
        return SnapshotChangedPayload(revision: revision, structureChanged: true, metadataOnly: false, chromeChanged: true)
    }
}

// MARK: - NotificationBus

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
    /// Posted when an agent's activity state changes (idle↔working↔awaiting).
    /// Used by BoardViewController for live card movement and ScriptRuntime for harness.events.
    public let agentStateChanged = Notification.Name("HarnessAgentStateChanged")

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

    /// Post a full typed payload (called by DaemonSyncService and other in-process sources).
    public func postSnapshotChanged(_ payload: SnapshotChangedPayload) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.snapshotChanged,
                object: nil,
                userInfo: ["payload": payload, "revision": payload.revision]
            )
        }
    }

    /// Low-level ping from DaemonClient: daemon reports a new revision but we haven't
    /// fetched or applied the snapshot yet. Carries only `revision` so SessionCoordinator
    /// can schedule a sync and deduplicate in-flight requests.
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

    /// Posted when an agent's activity state changes. `surfaceID` identifies the pane.
    public func postAgentStateChanged(surfaceID: String, activity: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: self.agentStateChanged, object: nil,
                userInfo: ["surfaceID": surfaceID, "activity": activity]
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
