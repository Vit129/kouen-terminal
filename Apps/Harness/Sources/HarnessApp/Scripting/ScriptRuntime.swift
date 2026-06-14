#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import Foundation
import AppKit
import HarnessCore

/// Wraps the JavaScriptCore runtime and exposes the public JS API.
@MainActor
final class ScriptRuntime: NSObject {
    #if canImport(JavaScriptCore)
    let context: JSContext
    #endif

    /// JS handlers registered via `harness.events.on(name, handler)`, keyed by event name.
    var eventHandlers: [String: [JSValue]] = [:]
    private var hasReportedEventError = false

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
        // Create the top-level harness object
        guard let harnessObj = JSValue(newObjectIn: context) else { return }

        // harness.version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        harnessObj.setValue(version, forProperty: "version")

        // harness.log(msg)
        let logBlock: @convention(block) (String) -> Void = { msg in
            NSLog("[Script] \(msg)")
        }
        harnessObj.setObject(logBlock, forKeyedSubscript: "log" as NSString)

        // harness.toast(msg)
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
        harnessObj.setObject(toastBlock, forKeyedSubscript: "toast" as NSString)

        context.setObject(harnessObj, forKeyedSubscript: "harness" as NSString)
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

    /// Bridges `NotificationBus` signals to `harness.events.on(name, handler)` listeners.
    private func registerNotificationBridge() {
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
    }

    @objc private func handleConfigReloaded(_ note: Notification) {
        dispatchEvent("configReloaded", payload: [:])
    }

    /// Invokes JS handlers registered via `harness.events.on(name, ...)` serially.
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
