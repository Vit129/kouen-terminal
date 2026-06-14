#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import Foundation
import AppKit

/// Wraps the JavaScriptCore runtime and exposes the public JS API.
@MainActor
final class ScriptRuntime {
    #if canImport(JavaScriptCore)
    let context: JSContext
    #endif

    init() {
        #if canImport(JavaScriptCore)
        self.context = JSContext()!
        setupAPI()
        #endif
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
