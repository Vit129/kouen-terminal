#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import Foundation
import KouenCore

/// Implements read-only scripting APIs and maps command parsing to JS.
@MainActor
struct ScriptAPI {
    #if canImport(JavaScriptCore)
    /// Registers namespaces and functions on the JS runtime context.
    static func register(in runtime: ScriptRuntime) {
        let context = runtime.context
        guard let kouenObj = context.objectForKeyedSubscript("kouen") else { return }

        // 1. kouen.sessions namespace
        guard let sessionsObj = JSValue(newObjectIn: context) else { return }

        // kouen.sessions.list()
        let sessionsListBlock: @convention(block) () -> JSValue? = {
            let snapshot = SessionCoordinator.shared.snapshot
            var list: [[String: Any]] = []
            for workspace in snapshot.workspaces {
                let workspaceID = workspace.id
                for session in workspace.sessions {
                    var dict = session.toJSDictionary()

                    // session.spawn({cwd, shell, name}) — P11 PBI-SCRIPT-005. Spawns a new
                    // session in this session's workspace via the same `.newSession` IPC
                    // request the GUI "New Session" action and P12's MCP `spawnSession` use.
                    let spawnBlock: @convention(block) (JSValue?) -> JSValue? = { options in
                        var cwd: String?
                        var shell: String?
                        var name: String?
                        if let options, options.isObject {
                            if let v = options.objectForKeyedSubscript("cwd"), v.isString { cwd = v.toString() }
                            if let v = options.objectForKeyedSubscript("shell"), v.isString { shell = v.toString() }
                            if let v = options.objectForKeyedSubscript("name"), v.isString { name = v.toString() }
                        }
                        let coordinator = SessionCoordinator.shared
                        guard case let .sessionID(newSessionID)? = coordinator.requestDaemon(
                            .newSession(workspaceID: workspaceID, cwd: cwd, name: name, shell: shell)
                        ) else {
                            context.exception = JSValue(newErrorFromMessage: "session.spawn: failed", in: context)
                            return nil
                        }
                        coordinator.syncFromDaemon()
                        return JSValue(object: ["sessionId": newSessionID.uuidString], in: context)
                    }
                    dict["spawn"] = spawnBlock

                    list.append(dict)
                }
            }
            return JSValue(object: list, in: context)
        }
        sessionsObj.setObject(sessionsListBlock, forKeyedSubscript: "list" as NSString)
        kouenObj.setObject(sessionsObj, forKeyedSubscript: "sessions" as NSString)

        // 2. kouen.panes namespace
        guard let panesObj = JSValue(newObjectIn: context) else { return }

        // kouen.panes.list(sessionId?)
        let panesListBlock: @convention(block) (JSValue?) -> JSValue? = { sessionIdVal in
            let snapshot = SessionCoordinator.shared.snapshot
            let sessions = snapshot.workspaces.flatMap { $0.sessions }

            var targetSessionId: String? = nil
            if let val = sessionIdVal, !val.isUndefined && !val.isNull {
                targetSessionId = val.toString()
            }

            var results: [[String: Any]] = []
            for session in sessions {
                if let target = targetSessionId, session.id.uuidString != target {
                    continue
                }
                for tab in session.tabs {
                    let leaves = tab.rootPane.allLeaves()
                    for leaf in leaves {
                        var dict = leaf.toJSDictionary(
                            sessionId: session.id.uuidString,
                            tabId: tab.id.uuidString,
                            tabTitle: tab.title,
                            tabCwd: tab.cwd,
                            tabGitBranch: tab.gitBranch,
                            tabCurrentCommand: tab.currentCommand
                        )

                        let paneID = leaf.id
                        let surfaceID = leaf.activeSurfaceID ?? leaf.surfaceID
                        let tabID = tab.id

                        // pane.sendText(text) — P11 PBI-SCRIPT-005, same `.send` IPC request
                        // MCP's `sendPaneText` and the terminal input path use.
                        let sendTextBlock: @convention(block) (String) -> Void = { text in
                            let coordinator = SessionCoordinator.shared
                            _ = coordinator.requestDaemon(.send(surfaceID: surfaceID.uuidString, text: text))
                            coordinator.syncFromDaemon()
                        }
                        dict["sendText"] = sendTextBlock

                        // pane.split({direction, shell}) — direction is "right"/"left"/"up"/
                        // "down", mapped to the layout SplitDirection via the shared
                        // CommandIPCTranslator.layoutDirection(forPaneDirection:) helper so this
                        // agrees with P12's MCP `splitPane`.
                        let splitBlock: @convention(block) (JSValue?) -> JSValue? = { options in
                            var direction = "right"
                            var shell: String?
                            if let options, options.isObject {
                                if let v = options.objectForKeyedSubscript("direction"), v.isString, let s = v.toString() {
                                    direction = s
                                }
                                if let v = options.objectForKeyedSubscript("shell"), v.isString {
                                    shell = v.toString()
                                }
                            }
                            guard let layoutDirection = CommandIPCTranslator.layoutDirection(forPaneDirection: direction) else {
                                context.exception = JSValue(newErrorFromMessage: "pane.split: invalid direction '\(direction)'", in: context)
                                return nil
                            }
                            let coordinator = SessionCoordinator.shared
                            guard case let .paneID(newPaneID)? = coordinator.requestDaemon(
                                .newSplit(tabID: tabID, paneID: paneID, direction: layoutDirection, shell: shell)
                            ) else {
                                context.exception = JSValue(newErrorFromMessage: "pane.split: failed", in: context)
                                return nil
                            }
                            coordinator.syncFromDaemon()
                            return JSValue(object: ["paneId": newPaneID.uuidString], in: context)
                        }
                        dict["split"] = splitBlock

                        // pane.close() — same `.killPane` IPC request MCP's `closePane` uses.
                        let closeBlock: @convention(block) () -> Void = {
                            let coordinator = SessionCoordinator.shared
                            _ = coordinator.requestDaemon(.killPane(paneID: paneID))
                            coordinator.syncFromDaemon()
                        }
                        dict["close"] = closeBlock

                        results.append(dict)
                    }
                }
            }
            return JSValue(object: results, in: context)
        }
        panesObj.setObject(panesListBlock, forKeyedSubscript: "list" as NSString)
        kouenObj.setObject(panesObj, forKeyedSubscript: "panes" as NSString)

        // 3. kouen.board namespace (P16 PBI-BOARD-005)
        guard let boardObj = JSValue(newObjectIn: context) else { return }

        // kouen.board.list() — Kanban columns from the shared BoardModel, same
        // shape as the `kouenBoard` MCP tool and `kouen board` CLI output.
        let boardListBlock: @convention(block) () -> JSValue? = {
            let snapshot = SessionCoordinator.shared.snapshot
            let columns = BoardModel.classify(snapshot: snapshot)
            guard let data = try? JSONEncoder().encode(columns),
                  let foundationObj = try? JSONSerialization.jsonObject(with: data, options: [])
            else {
                return JSValue(object: [], in: context)
            }
            return JSValue(object: foundationObj, in: context)
        }
        boardObj.setObject(boardListBlock, forKeyedSubscript: "list" as NSString)
        kouenObj.setObject(boardObj, forKeyedSubscript: "board" as NSString)

        // 4. kouen.commands namespace
        guard let commandsObj = JSValue(newObjectIn: context) else { return }

        // kouen.commands.parse(commandSource)
        let commandsParseBlock: @convention(block) (String) -> JSValue? = { commandSource in
            do {
                let cmd = try CommandParser.parse(commandSource)
                let data = try JSONEncoder().encode(cmd)
                let foundationObj = try JSONSerialization.jsonObject(with: data, options: [])
                return JSValue(object: foundationObj, in: context)
            } catch {
                context.exception = JSValue(newErrorFromMessage: String(describing: error), in: context)
                return nil
            }
        }
        commandsObj.setObject(commandsParseBlock, forKeyedSubscript: "parse" as NSString)

        // kouen.commands.__runSync(commandSource) — parses and executes commandSource through
        // CommandParser + MainExecutor (which itself routes through CommandIPCTranslator using the
        // current GUI focus, per `runViaTranslator`). Wrapped below in a Promise so
        // `kouen.commands.run` matches the documented `Promise<Result>` signature even though
        // execution is synchronous on the main actor.
        let commandsRunSyncBlock: @convention(block) (String) -> JSValue? = { commandSource in
            do {
                let command = try CommandParser.parse(commandSource)
                try MainExecutor.shared.execute(command)
                return JSValue(object: ["ok": true], in: context)
            } catch {
                context.exception = JSValue(newErrorFromMessage: String(describing: error), in: context)
                return nil
            }
        }
        commandsObj.setObject(commandsRunSyncBlock, forKeyedSubscript: "__runSync" as NSString)
        kouenObj.setObject(commandsObj, forKeyedSubscript: "commands" as NSString)

        // `run` wraps `__runSync` in a Promise so callers can `await kouen.commands.run(...)`.
        context.evaluateScript("""
        kouen.commands.run = function(commandSource) {
            return new Promise(function(resolve, reject) {
                try {
                    resolve(kouen.commands.__runSync(commandSource));
                } catch (e) {
                    reject(e);
                }
            });
        };
        """)

        // 5. kouen.events namespace — bridges NotificationBus to JS handlers (P11
        // PBI-SCRIPT-003 gap / P15 step 3). v1 events: snapshotChanged, configReloaded.

        // kouen.events.on(name, handler)
        let eventsOnBlock: @convention(block) (String, JSValue) -> Void = { [weak runtime] name, handler in
            guard let runtime, handler.isObject else { return }
            runtime.eventHandlers[name, default: []].append(handler)
        }

        // kouen.events.off(name, handler?) — drops a specific handler, or all
        // handlers for `name` if `handler` is omitted.
        let eventsOffBlock: @convention(block) (String, JSValue?) -> Void = { [weak runtime] name, handler in
            guard let runtime else { return }
            guard let handler, handler.isObject else {
                runtime.eventHandlers[name] = nil
                return
            }
            runtime.eventHandlers[name]?.removeAll { $0.isEqual(to: handler) }
        }

        guard let eventsObj = JSValue(newObjectIn: context) else { return }
        eventsObj.setObject(eventsOnBlock, forKeyedSubscript: "on" as NSString)
        eventsObj.setObject(eventsOffBlock, forKeyedSubscript: "off" as NSString)
        kouenObj.setObject(eventsObj, forKeyedSubscript: "events" as NSString)

        // 6. kouen.config namespace (P11 PBI-SCRIPT-004) — allowlisted KouenSettings
        // read/write, persisted through KouenSettings.save() and applied through the same
        // refresh path the Settings UI uses (SessionCoordinator.applySettingsToHosts(), or
        // setTheme for "theme").
        guard let configObj = JSValue(newObjectIn: context) else { return }

        let configGetBlock: @convention(block) (String) -> JSValue? = { key in
            let coordinator = SessionCoordinator.shared
            let settings = coordinator.settings
            switch key {
            case "theme":
                return JSValue(object: coordinator.snapshot.themeName, in: context)
            case "fontFamily":
                return JSValue(object: settings.fontFamily, in: context)
            case "fontSize":
                return JSValue(double: Double(settings.fontSize), in: context)
            case "backgroundOpacity":
                return JSValue(double: Double(settings.backgroundOpacity), in: context)
            case "backgroundBlur":
                return JSValue(double: Double(settings.backgroundBlur), in: context)
            case "windowPaddingX":
                return JSValue(double: Double(settings.windowPaddingX), in: context)
            case "windowPaddingY":
                return JSValue(double: Double(settings.windowPaddingY), in: context)
            case "defaultShell":
                return JSValue(object: settings.defaultShell, in: context)
            case "defaultCWD":
                return JSValue(object: settings.defaultCWD, in: context)
            case "systemNotificationsEnabled":
                return JSValue(bool: settings.systemNotificationsEnabled, in: context)
            case "notificationSoundEnabled":
                return JSValue(bool: settings.notificationSoundEnabled, in: context)
            default:
                context.exception = JSValue(newErrorFromMessage: "kouen.config.get: unknown key '\(key)'", in: context)
                return nil
            }
        }
        configObj.setObject(configGetBlock, forKeyedSubscript: "get" as NSString)

        let configSetBlock: @convention(block) (String, JSValue) -> Void = { key, value in
            let coordinator = SessionCoordinator.shared
            switch key {
            case "theme":
                guard value.isString, let name = value.toString(), !name.isEmpty else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'theme' requires a non-empty string", in: context)
                    return
                }
                coordinator.setTheme(name)
                return
            case "fontFamily":
                guard value.isString, let name = value.toString() else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'fontFamily' requires a string", in: context)
                    return
                }
                coordinator.settings.fontFamily = name
            case "fontSize":
                guard value.isNumber else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'fontSize' requires a number", in: context)
                    return
                }
                coordinator.settings.fontSize = KouenSettings.clampedFontSize(Float(value.toDouble()))
            case "backgroundOpacity":
                guard value.isNumber else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'backgroundOpacity' requires a number", in: context)
                    return
                }
                coordinator.settings.backgroundOpacity = KouenSettings.clampedOpacity(Float(value.toDouble()))
            case "backgroundBlur":
                guard value.isNumber else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'backgroundBlur' requires a number", in: context)
                    return
                }
                coordinator.settings.backgroundBlur = KouenSettings.clampedBlur(Int(value.toDouble()))
            case "windowPaddingX":
                guard value.isNumber else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'windowPaddingX' requires a number", in: context)
                    return
                }
                coordinator.settings.windowPaddingX = KouenSettings.clampedPadding(Float(value.toDouble()))
            case "windowPaddingY":
                guard value.isNumber else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'windowPaddingY' requires a number", in: context)
                    return
                }
                coordinator.settings.windowPaddingY = KouenSettings.clampedPadding(Float(value.toDouble()))
            case "defaultShell":
                guard value.isString, let shell = value.toString() else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'defaultShell' requires a string", in: context)
                    return
                }
                coordinator.settings.defaultShell = shell
            case "defaultCWD":
                guard value.isString, let cwd = value.toString() else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'defaultCWD' requires a string", in: context)
                    return
                }
                coordinator.settings.defaultCWD = cwd
            case "systemNotificationsEnabled":
                guard value.isBoolean else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'systemNotificationsEnabled' requires a boolean", in: context)
                    return
                }
                coordinator.settings.systemNotificationsEnabled = value.toBool()
            case "notificationSoundEnabled":
                guard value.isBoolean else {
                    context.exception = JSValue(newErrorFromMessage: "kouen.config.set: 'notificationSoundEnabled' requires a boolean", in: context)
                    return
                }
                coordinator.settings.notificationSoundEnabled = value.toBool()
            default:
                context.exception = JSValue(newErrorFromMessage: "kouen.config.set: unknown key '\(key)'", in: context)
                return
            }
            // Persist and push to live terminals — the same refresh path Settings UI's
            // `flushAndApply()` uses (KouenSettings.save() + applySettingsToHosts()).
            try? coordinator.settings.save()
            coordinator.applySettingsToHosts()
        }
        configObj.setObject(configSetBlock, forKeyedSubscript: "set" as NSString)

        // kouen.config.reloadTerminalImport() — re-runs the tmux/ghostty config import
        // (same as the "Reimport Terminal Config" command palette action).
        let configReloadTerminalImportBlock: @convention(block) () -> Void = {
            SessionCoordinator.shared.reimportTerminalConfig()
        }
        configObj.setObject(configReloadTerminalImportBlock, forKeyedSubscript: "reloadTerminalImport" as NSString)
        kouenObj.setObject(configObj, forKeyedSubscript: "config" as NSString)

        // 7. kouen.keys namespace (P11 PBI-SCRIPT-004) — bind/unbind persist through
        // KeybindingsService/KeybindingsStore (the same store `bind-key`/`unbind-key` use);
        // `reload()` mirrors the `reload-keybindings` command's refresh path.
        guard let keysObj = JSValue(newObjectIn: context) else { return }

        // v1 allowlist: prefix, copy-mode, copy-mode-vi (alias for copy-mode), root.
        let keysAllowedTables: Set<String> = ["prefix", "copy-mode", "copy-mode-vi", "root"]

        let keysBindBlock: @convention(block) (String, String, String, JSValue?) -> Void = { table, keySpec, commandSource, options in
            guard keysAllowedTables.contains(table) else {
                context.exception = JSValue(newErrorFromMessage: "kouen.keys.bind: unknown table '\(table)'", in: context)
                return
            }
            var repeatable = false
            if let options, options.isObject {
                let repeatableVal = options.objectForKeyedSubscript("repeatable")
                if let repeatableVal, !repeatableVal.isUndefined && !repeatableVal.isNull {
                    repeatable = repeatableVal.toBool()
                }
            }
            do {
                let command = try CommandParser.parse(commandSource)
                let canonicalTable = CommandParser.canonicalTableName(table)
                try KeybindingsService.shared.bind(
                    table: KeyTableID(rawValue: canonicalTable), specRaw: keySpec,
                    command: command, repeatable: repeatable
                )
            } catch {
                context.exception = JSValue(newErrorFromMessage: "kouen.keys.bind: \(error)", in: context)
            }
        }
        keysObj.setObject(keysBindBlock, forKeyedSubscript: "bind" as NSString)

        let keysUnbindBlock: @convention(block) (String, String) -> Void = { table, keySpec in
            guard keysAllowedTables.contains(table) else {
                context.exception = JSValue(newErrorFromMessage: "kouen.keys.unbind: unknown table '\(table)'", in: context)
                return
            }
            do {
                let canonicalTable = CommandParser.canonicalTableName(table)
                try KeybindingsService.shared.unbind(table: KeyTableID(rawValue: canonicalTable), specRaw: keySpec)
            } catch {
                context.exception = JSValue(newErrorFromMessage: "kouen.keys.unbind: \(error)", in: context)
            }
        }
        keysObj.setObject(keysUnbindBlock, forKeyedSubscript: "unbind" as NSString)

        // kouen.keys.reload() — re-reads keybindings.json and rebuilds the prefix keymap,
        // the same refresh path the `reload-keybindings` command takes in MainExecutor.
        let keysReloadBlock: @convention(block) () -> Void = {
            KeybindingsService.shared.reload()
            PrefixKeymap.shared.rebuildFromSettings()
        }
        keysObj.setObject(keysReloadBlock, forKeyedSubscript: "reload" as NSString)
        kouenObj.setObject(keysObj, forKeyedSubscript: "keys" as NSString)

        // 9. kouen.profiles namespace (P19 WB-007) — opt-in IDE-migrant bindings
        guard let profilesObj = JSValue(newObjectIn: context) else { return }
        let profilesUseBlock: @convention(block) (String) -> Void = { name in
            guard name == "ide-migrant-terminal" else { return } // other profiles: silent no-op
            let bindings: [(table: String, key: String, cmd: String)] = [
                ("root", "Cmd-p", "find"),
                ("root", "Cmd-b", "board"),
                ("root", "Cmd-T", "make test"),
                ("root", "Cmd-B", "make build"),
                ("root", "Cmd-e", "errors"),
            ]
            for binding in bindings {
                guard let command = try? CommandParser.parse(binding.cmd) else { continue }
                let table = CommandParser.canonicalTableName(binding.table)
                try? KeybindingsService.shared.bind(
                    table: KeyTableID(rawValue: table), specRaw: binding.key,
                    command: command, repeatable: false
                )
            }
        }
        profilesObj.setObject(profilesUseBlock, forKeyedSubscript: "use" as NSString)
        kouenObj.setObject(profilesObj, forKeyedSubscript: "profiles" as NSString)

        // 10. kouen.plugin namespace — lifecycle hooks for plugins in ~/.config/kouen/plugins/
        // Plugins register handlers via kouen.plugin.on("eventName", handler).
        // Available events: "pluginsLoaded", "paneCreated", "paneRemoved",
        //                   "snapshotChanged", "configReloaded", "agentStateChanged".
        guard let pluginObj = JSValue(newObjectIn: context) else { return }

        let pluginOnBlock: @convention(block) (String, JSValue) -> Void = { [weak runtime] eventName, handler in
            guard let runtime else { return }
            runtime.eventHandlers[eventName, default: []].append(handler)
        }
        pluginObj.setObject(pluginOnBlock, forKeyedSubscript: "on" as NSString)

        let pluginOffBlock: @convention(block) (String) -> Void = { [weak runtime] eventName in
            guard let runtime else { return }
            runtime.eventHandlers.removeValue(forKey: eventName)
        }
        pluginObj.setObject(pluginOffBlock, forKeyedSubscript: "off" as NSString)

        kouenObj.setObject(pluginObj, forKeyedSubscript: "plugin" as NSString)
    }
    #endif
}
