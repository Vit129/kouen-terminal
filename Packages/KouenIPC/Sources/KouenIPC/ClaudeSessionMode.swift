import Foundation

/// Where a Claude Code session Kouen launches actually runs, and whether it's reachable from
/// the Claude Desktop/mobile apps and claude.ai/code. Keep stable strings — persisted in
/// `settings.json` as `claudeSessionMode`.
///
/// - `local`: plain `claude` in the pane. Only reachable from this Mac.
/// - `remoteControl`: `claude --remote-control` — the agent still runs in the pane (local
///   files, MCP servers, hooks), and the same session is steerable from the Claude app.
/// - `cloud`: `claude --cloud` — the agent runs in an Anthropic cloud container; the pane is
///   a client for it, and the CLI syncs this folder's files to/from that container. Cloud
///   sessions are listed in the Claude app by default, so no remote-control flag is needed
///   (the CLI refuses Remote Control inside a cloud session).
public enum ClaudeSessionMode: String, Codable, Sendable, CaseIterable {
    case local
    case remoteControl = "remote-control"
    case cloud

    /// Groups Kouen-launched sessions together in the Claude app's session list.
    static let remoteControlNamePrefix = "kouen"

    /// Flags that go right after the `claude` binary when starting a fresh session.
    public var launchFlags: [String] {
        switch self {
        case .local: return []
        case .remoteControl: return remoteControlFlags
        case .cloud: return ["--cloud"]
        }
    }

    /// Command (no trailing newline) that starts a fresh Claude Code session in this mode.
    public var launchCommand: String {
        (["claude"] + launchFlags).joined(separator: " ")
    }

    /// Command that resumes a *local* transcript (`~/.claude/projects/...`). `--cloud` only
    /// accepts cloud session IDs, so `.cloud` falls back to Remote Control here: the resumed
    /// session still lands in the Claude app, just running on this Mac.
    public func resumeCommand(sessionID: String) -> String {
        switch self {
        case .local: return "claude --resume \(sessionID)"
        case .remoteControl, .cloud:
            return (["claude", "--resume", sessionID] + remoteControlFlags).joined(separator: " ")
        }
    }

    private var remoteControlFlags: [String] {
        ["--remote-control", "--remote-control-session-name-prefix", Self.remoteControlNamePrefix]
    }
}
