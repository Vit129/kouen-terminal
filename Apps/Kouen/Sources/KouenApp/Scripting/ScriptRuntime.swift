#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import Foundation
import AppKit
import KouenCore

/// Wraps the JavaScriptCore runtime and exposes the public JS API.
@MainActor
final class ScriptRuntime: NSObject {
    #if canImport(JavaScriptCore)
    let context: JSContext
    #endif

    /// JS handlers registered via `kouen.events.on(name, handler)`, keyed by event name.
    var eventHandlers: [String: [JSValue]] = [:]
    private var hasReportedEventError = false

    /// Pane IDs seen as of the last `snapshotChanged` — diffed on each new snapshot to derive
    /// `paneCreated`/`paneRemoved` (P38 Phase E; these events were documented in `ScriptAPI.swift`
    /// but never actually dispatched — see RL-067's sibling case, caught while auditing this file).
    private var lastKnownPaneIDs: Set<PaneID> = []

    override init() {
        #if canImport(JavaScriptCore)
        self.context = JSContext()!
        super.init()
        setupAPI()
        registerNotificationBridge()
        #else
        super.init()
        #endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    #if canImport(JavaScriptCore)
    private func setupAPI() {
        // Create the top-level kouen object
        guard let kouenObj = JSValue(newObjectIn: context) else { return }

        // kouen.version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        kouenObj.setValue(version, forProperty: "version")

        // kouen.log(msg)
        let logBlock: @convention(block) (String) -> Void = { msg in
            NSLog("[Script] \(msg)")
        }
        kouenObj.setObject(logBlock, forKeyedSubscript: "log" as NSString)

        // kouen.toast(msg)
        let toastBlock: @convention(block) (String) -> Void = { msg in
            DispatchQueue.main.async {
                if NSClassFromString("XCTest") != nil {
                    NSLog("[Script Toast (Test Mode)] \(msg)")
                    return
                }
                guard let app = NSApplication.shared as AnyObject? as? NSApplication else { return }
                if let host = (app.keyWindow ?? app.mainWindow ?? app.windows.first(where: { $0.contentView != nil }))?.contentView {
                    Toast.show(msg, in: host, hold: 3.0)
                }
            }
        }
        kouenObj.setObject(toastBlock, forKeyedSubscript: "toast" as NSString)

        context.setObject(kouenObj, forKeyedSubscript: "kouen" as NSString)
        ScriptAPI.register(in: self)

        // Default exception handler: log and preserve JSContext's normal behavior of
        // recording the exception on `context.exception` for callers to inspect.
        context.exceptionHandler = { context, exception in
            if let exc = exception {
                NSLog("[Script Error] \(exc)")
            }
            context?.exception = exception
        }
    }

    /// Bridges `NotificationBus` signals to `kouen.events.on(name, handler)` listeners.
    private func registerNotificationBridge() {
        // Seed the baseline from whatever panes already exist — otherwise the FIRST
        // `snapshotChanged` after script load would diff against an empty set and fire a
        // spurious `paneCreated` for every pane already open before the script ever ran.
        lastKnownPaneIDs = Set(
            SessionCoordinator.shared.snapshot.workspaces
                .flatMap { $0.sessions.flatMap { $0.tabs } }
                .flatMap { $0.rootPane.allPaneIDs() }
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleSnapshotChanged(_:)),
            name: NotificationBus.shared.snapshotChanged, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleConfigReloaded(_:)),
            name: NotificationBus.shared.configReloaded, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAgentStateChanged(_:)),
            name: NotificationBus.shared.agentStateChanged, object: nil
        )
    }

    @objc private func handleAgentStateChanged(_ note: Notification) {
        let surfaceID = note.userInfo?["surfaceID"] as? String ?? ""
        let activity = note.userInfo?["activity"] as? String ?? ""
        dispatchEvent("agentStateChanged", payload: ["surfaceID": surfaceID, "activity": activity])
    }

    @objc private func handleSnapshotChanged(_ note: Notification) {
        let revision = note.userInfo?["revision"] as? Int ?? 0
        dispatchEvent("snapshotChanged", payload: ["revision": revision])
        dispatchPaneDiff()
    }

    /// Diffs the current pane-ID set against the last known one and fires `paneCreated`/
    /// `paneRemoved` for whatever changed. Skips the diff entirely (but still updates the
    /// baseline) when no JS handler is listening for either event — no reason to walk every
    /// workspace/session/tab on every snapshot change if nothing reads the result.
    /// `internal` (not `private`) so tests can call it directly without posting through the real
    /// `NotificationBus` — that fans out to `NotificationCoordinator`, which hits RL-065's
    /// UNUserNotificationCenter bundle-context crash outside a real app process.
    func dispatchPaneDiff() {
        let hasCreatedHandler = !(eventHandlers["paneCreated"]?.isEmpty ?? true)
        let hasRemovedHandler = !(eventHandlers["paneRemoved"]?.isEmpty ?? true)
        let currentPaneIDs = Set(
            SessionCoordinator.shared.snapshot.workspaces
                .flatMap { $0.sessions.flatMap { $0.tabs } }
                .flatMap { $0.rootPane.allPaneIDs() }
        )
        defer { lastKnownPaneIDs = currentPaneIDs }
        guard hasCreatedHandler || hasRemovedHandler else { return }

        if hasCreatedHandler {
            for paneID in currentPaneIDs.subtracting(lastKnownPaneIDs) {
                dispatchEvent("paneCreated", payload: ["paneID": paneID.uuidString])
            }
        }
        if hasRemovedHandler {
            for paneID in lastKnownPaneIDs.subtracting(currentPaneIDs) {
                dispatchEvent("paneRemoved", payload: ["paneID": paneID.uuidString])
            }
        }
    }

    @objc private func handleConfigReloaded(_ note: Notification) {
        dispatchEvent("configReloaded", payload: [:])
    }

    /// Invokes JS handlers registered via `kouen.events.on(name, ...)` serially.
    /// Handler errors are caught, logged, and surfaced via toast at most once per
    /// script load to avoid toast spam (RL: a misbehaving handler fires on every
    /// `snapshotChanged`, which can be many times per second).
    func dispatchEvent(_ name: String, payload: [String: Any]) {
        guard let handlers = eventHandlers[name], !handlers.isEmpty else { return }
        guard let jsPayload = JSValue(object: payload, in: context) else { return }
        for handler in handlers {
            handler.call(withArguments: [jsPayload])
            if let exception = context.exception {
                reportEventError(name: name, exception: exception)
                context.exception = nil
            }
        }
    }

    private func reportEventError(name: String, exception: JSValue) {
        guard !hasReportedEventError else { return }
        hasReportedEventError = true
        let message = "Script event handler error (\(name)): \(exception)"
        NSLog("[Script Error] \(message)")
        DispatchQueue.main.async {
            if NSClassFromString("XCTest") != nil {
                NSLog("[Script Toast (Test Mode)] \(message)")
                return
            }
            guard let app = NSApplication.shared as AnyObject? as? NSApplication else { return }
            if let host = (app.keyWindow ?? app.mainWindow ?? app.windows.first(where: { $0.contentView != nil }))?.contentView {
                Toast.show(message, in: host, hold: 3.5)
            }
        }
    }
    #endif

    /// Evaluates the script content. Throws a ScriptError if evaluation fails.
    func evaluate(script: String, sourceURL: URL) throws {
        #if canImport(JavaScriptCore)
        var caughtException: JSValue? = nil
        context.exceptionHandler = { _, exception in
            caughtException = exception
        }

        context.evaluateScript(script, withSourceURL: sourceURL)

        if let exc = caughtException {
            throw ScriptError.evaluationError(exc.toString() ?? "Unknown JS evaluation error")
        }
        #else
        throw ScriptError.unsupportedPlatform
        #endif
    }
}

enum ScriptError: Error, LocalizedError {
    case evaluationError(String)
    case unsupportedPlatform

    var errorDescription: String? {
        switch self {
        case .evaluationError(let msg):
            return msg
        case .unsupportedPlatform:
            return "Scripting is not supported on this platform."
        }
    }
}
