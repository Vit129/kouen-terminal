import Foundation

/// `/model <id>` / `/effort <level>` + Enter, as two separate writes. Same for Claude and agy.
func slashCommandChunks(_ command: String, _ value: String) -> [Data] {
    [Data("/\(command) \(value)".utf8), Data("\r".utf8)]
}

#if canImport(Network)
import KouenCore
import Network

// Model / effort / mode control from the Companion page. Each agent's TUI takes these differently,
// so the per-agent rules live in `ClaudeMobileCommands` and `AgyMobileCommands`; this file only
// picks the agent and types the result into its pane.

extension MobileBridgeServer {
    /// Chunks to type for an agent command, or nil when the request is not allowlisted. Pure so it is
    /// unit-testable; `currentMode` is the mode last read from the transcript (a cycle needs a start).
    /// `agyCatalog` is what `agy models` reported (nil = unavailable, so nothing is allowed for agy).
    static func agentCommandInput(kind: String, value: String, currentMode: String?, agent: AgentKind = .claudeCode,
                                  agyCatalog: AgyModelCatalog.Catalog? = nil) -> [Data]? {
        agent == .antigravity
            ? AgyMobileCommands.input(kind: kind, value: value, catalog: agyCatalog)
            : ClaudeMobileCommands.input(kind: kind, value: value, currentMode: currentMode)
    }

    func handleAgentCommand(_ cmd: ControlMessage.AgentCommandRequest, connection: NWConnection, state: ConnectionState) {
        guard let surfaceID = state.surfaceID, let subscription = state.subscription else {
            sendText(#"{"error":"not attached to a session — go back and reopen it"}"#, on: connection)
            return
        }
        let supported: Set<AgentKind> = [.claudeCode, .antigravity]
        let detected = AgentDetector.snapshot(forSurfaceKey: surfaceID)?.kind
        let hinted = cmd.agent.flatMap(AgentKind.init(rawValue:))
        guard let kind = [detected, hinted].compactMap({ $0 }).first(where: supported.contains) else {
            sendText(#"{"error":"model and effort can only be changed on a Claude or agy session (detected: \#(detected?.rawValue ?? "none"))"}"#, on: connection)
            return
        }
        let catalog = kind == .antigravity ? AgyModelCatalog.current() : nil
        guard let chunks = Self.agentCommandInput(kind: cmd.kind, value: cmd.value, currentMode: state.agentMode, agent: kind, agyCatalog: catalog) else {
            sendText(#"{"error":"unsupported agent command"}"#, on: connection)
            return
        }
        // Text and Enter go as separate writes (as a human types); the TUI treats one burst as a paste.
        for chunk in chunks {
            _ = subscription.sendInput(chunk, surfaceID: surfaceID)
            Thread.sleep(forTimeInterval: 0.15)
        }
        if cmd.kind == "mode" { state.agentMode = cmd.value }
        sendText(#"{"ok":"agentCommand"}"#, on: connection)
    }
}
#endif
