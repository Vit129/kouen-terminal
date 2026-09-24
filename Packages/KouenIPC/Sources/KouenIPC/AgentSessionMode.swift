import Foundation

/// Where an agent session Kouen launches actually runs, and whether it's reachable from
/// vendor companion apps (web/mobile). Keep stable strings — persisted in `settings.json`
/// as `agentSessionModes`.
///
/// - `local`: plain CLI in the pane. Only reachable from this Mac.
/// - `remoteControl`: remote connection enabled — agent runs in the pane (local files,
///   MCP servers, hooks) while being steerable from mobile/web.
/// - `cloud`: agent runs in a cloud environment (e.g. Anthropic cloud container for Claude Code).
public enum AgentSessionMode: String, Codable, Sendable, CaseIterable {
    case local
    case remoteControl = "remote-control"
    case cloud

    /// Groups Kouen-launched sessions together in vendor apps where supported.
    public static let remoteControlNamePrefix = "kouen"

    /// Flags that go right after the agent binary for a given agent kind.
    public func launchFlags(for kind: AgentKind) -> [String] {
        AgentLaunchCommands.launchFlags(kind: kind, mode: self)
    }

    /// Command (no trailing newline) that starts a fresh session for a given agent kind.
    public func launchCommand(for kind: AgentKind, cwd: String? = nil) -> String {
        AgentLaunchCommands.launch(kind: kind, mode: self, cwd: cwd)
    }

    /// Command that resumes a session for a given agent kind given its session ID.
    public func resumeCommand(for kind: AgentKind, sessionID: String) -> String {
        AgentLaunchCommands.resume(kind: kind, sessionID: sessionID, mode: self)
    }

    /// Flags that go right after the agent binary when starting a fresh session.
    /// Defaults to Claude Code flags for backwards compatibility.
    public var launchFlags: [String] {
        launchFlags(for: .claudeCode)
    }

    /// Command (no trailing newline) that starts a fresh session in this mode.
    /// Defaults to Claude Code for backwards compatibility.
    public var launchCommand: String {
        launchCommand(for: .claudeCode)
    }

    /// Command that resumes a session given its session ID.
    /// Defaults to Claude Code for backwards compatibility.
    public func resumeCommand(sessionID: String) -> String {
        resumeCommand(for: .claudeCode, sessionID: sessionID)
    }
}

/// Backwards compatibility alias for Claude-specific references.
public typealias ClaudeSessionMode = AgentSessionMode
