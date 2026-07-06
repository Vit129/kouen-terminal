#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import Foundation
import AppKit
import KouenCore

/// Loads JavaScript plugins from `~/.config/kouen/plugins/*.js`.
///
/// Each plugin file is evaluated in the shared `ScriptRuntime` context, so plugins
/// can call any `kouen.*` API. Plugins are loaded after `init.js` so they can
/// depend on custom globals defined there.
///
/// Plugin directory: `~/.config/kouen/plugins/` (XDG: `$XDG_CONFIG_HOME/kouen/plugins/`).
@MainActor
struct PluginLoader {
    /// Load all `.js` files from the plugins directory into `runtime`.
    /// Files are loaded in lexicographic order so plugins can declare ordering
    /// via filename prefixes (e.g. `01-theme.js`, `02-keybinds.js`).
    static func load(into runtime: ScriptRuntime) {
        guard let dir = pluginsDirectory() else { return }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: dir, isDirectory: &isDirectory), isDirectory.boolValue else {
            return
        }
        let entries = (try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? []
        let plugins = entries.filter { $0.hasSuffix(".js") }.sorted()
        for name in plugins {
            let path = (dir as NSString).appendingPathComponent(name)
            do {
                let source = try String(contentsOfFile: path, encoding: .utf8)
                try runtime.evaluate(script: source, sourceURL: URL(fileURLWithPath: path))
                NSLog("[PluginLoader] Loaded plugin: \(name)")
            } catch {
                NSLog("[PluginLoader] Failed to load \(name): \(error.localizedDescription)")
                showToast("Plugin error (\(name)): \(error.localizedDescription)")
            }
        }
        // Fire the onStartup hooks now that all plugins are loaded.
        runtime.dispatchEvent("pluginsLoaded", payload: ["count": plugins.count])
    }

    private static func pluginsDirectory() -> String? {
        let env = ProcessInfo.processInfo.environment
        let configBase: String
        if let xdg = env["XDG_CONFIG_HOME"], !xdg.isEmpty {
            configBase = xdg
        } else {
            let home = env["HOME"] ?? NSHomeDirectory()
            guard !home.isEmpty else { return nil }
            configBase = (home as NSString).appendingPathComponent(".config")
        }
        return (configBase as NSString).appendingPathComponent("kouen/plugins")
    }

    private static func showToast(_ message: String) {
        guard NSClassFromString("XCTest") == nil else { return }
        guard let app = NSApplication.shared as AnyObject? as? NSApplication else { return }
        if let host = (app.keyWindow ?? app.mainWindow)?.contentView {
            Toast.show(message, in: host, hold: 4.0)
        }
    }
}
