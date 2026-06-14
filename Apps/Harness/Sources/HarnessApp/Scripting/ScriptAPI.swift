#if canImport(JavaScriptCore)
import JavaScriptCore
#endif
import Foundation
import HarnessCore

/// Implements read-only scripting APIs and maps command parsing to JS.
@MainActor
struct ScriptAPI {
    #if canImport(JavaScriptCore)
    /// Registers namespaces and functions on the JS runtime context.
    static func register(in runtime: ScriptRuntime) {
        let context = runtime.context
        guard let harnessObj = context.objectForKeyedSubscript("harness") else { return }

        // 1. harness.sessions namespace
        guard let sessionsObj = JSValue(newObjectIn: context) else { return }

        // harness.sessions.list()
        let sessionsListBlock: @convention(block) () -> JSValue? = {
            let snapshot = SessionCoordinator.shared.snapshot
            let sessions = snapshot.workspaces.flatMap { $0.sessions }
            let list = sessions.map { $0.toJSDictionary() }
            return JSValue(object: list, in: context)
        }
        sessionsObj.setObject(sessionsListBlock, forKeyedSubscript: "list" as NSString)
        harnessObj.setObject(sessionsObj, forKeyedSubscript: "sessions" as NSString)

        // 2. harness.panes namespace
        guard let panesObj = JSValue(newObjectIn: context) else { return }

        // harness.panes.list(sessionId?)
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
                        results.append(leaf.toJSDictionary(
                            sessionId: session.id.uuidString,
                            tabId: tab.id.uuidString,
                            tabTitle: tab.title,
                            tabCwd: tab.cwd,
                            tabGitBranch: tab.gitBranch,
                            tabCurrentCommand: tab.currentCommand
                        ))
                    }
                }
            }
            return JSValue(object: results, in: context)
        }
        panesObj.setObject(panesListBlock, forKeyedSubscript: "list" as NSString)
        harnessObj.setObject(panesObj, forKeyedSubscript: "panes" as NSString)

        // 3. harness.commands namespace
        guard let commandsObj = JSValue(newObjectIn: context) else { return }

        // harness.commands.parse(commandSource)
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
        harnessObj.setObject(commandsObj, forKeyedSubscript: "commands" as NSString)
    }
    #endif
}
