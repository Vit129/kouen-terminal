import Foundation
import AppKit
import HarnessCore

/// Coordinates scripting lifecycle, discovery, and file watching.
@MainActor
final class ScriptHookCoordinator {
    static let shared = ScriptHookCoordinator()

    private(set) var runtime: ScriptRuntime?
    private var configPath: String?
    private let watcher = ScriptFileWatcher()

    private init() {}

    /// Starts the configuration discovery and loads the script if found,
    /// then loads any plugins from `~/.config/harness/plugins/`.
    func start() {
        if let path = ScriptConfigLocator.locate() {
            self.configPath = path
            loadScript(at: path, isInitial: true)
        }
        // Load plugins after init.js so plugins can depend on globals defined there.
        // If no runtime exists yet (no init.js), create a bare one for plugins.
        if runtime == nil {
            runtime = ScriptRuntime()
        }
        if let runtime {
            PluginLoader.load(into: runtime)
        }
    }

    private func loadScript(at path: String, isInitial: Bool) {
        do {
            let scriptContent = try String(contentsOfFile: path, encoding: .utf8)
            let newRuntime = ScriptRuntime()
            try newRuntime.evaluate(script: scriptContent, sourceURL: URL(fileURLWithPath: path))

            // Evaluated successfully! Update the active runtime.
            self.runtime = newRuntime

            // Let `harness.events.on("configReloaded", ...)` handlers registered
            // during evaluation react to the (re)load that just happened.
            NotificationBus.shared.postConfigReloaded()

            if !isInitial {
                showToast("Script reloaded successfully")
            }
        } catch {
            let errorMsg = "Script Error (\(URL(fileURLWithPath: path).lastPathComponent)): \(error.localizedDescription)"
            NSLog("[ScriptHookCoordinator] \(errorMsg)")
            showToast(errorMsg)
            // Keep the last good runtime active (if one exists).
        }

        // Start/re-arm the file watcher so it survives atomic renames (RL-011).
        watcher.start(path: path) { [weak self] in
            guard let self = self else { return }
            self.loadScript(at: path, isInitial: false)
        }
    }

    private func showToast(_ message: String) {
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
