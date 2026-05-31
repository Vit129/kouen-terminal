import Foundation

/// The user-facing experience Harness presents on top of the one daemon-backed session
/// core. All four modes share the exact same PTY/session authority (the daemon owns
/// everything); a mode only changes *what's exposed* — which chrome is visible, the default
/// session persistence policy, and how prominent agent workflows are. Nothing about a mode
/// forks the session path.
///
/// - `plain`: a fast native terminal. No command prefix, no status line, no session
///   controls. Sessions are ephemeral by default (a clean quit closes them) so it feels
///   like a normal terminal.
/// - `persistent`: like `plain` visually, but sessions survive a clean quit and can be
///   driven/attached from the CLI. Individual sessions can be promoted/demoted.
/// - `tmux`: the full Harness surface — command prefix, status line, copy mode, paste
///   buffers, panes/splits, and the harness-cli command set, attach/detach.
/// - `agent`: persistent project workspaces with agent detection, notifications, and
///   jump-to-agent foregrounded. The full controls are available but off by default.
///
/// (The `tmux` raw value is retained for on-disk migration compatibility only; no
/// user-facing string names it — Harness uses its own vocabulary throughout.)
public enum ExperienceMode: String, Codable, Sendable, CaseIterable {
    case plain
    case persistent
    case tmux
    case agent

    /// Short title for menus and settings.
    public var displayName: String {
        switch self {
        case .plain: return "Plain Terminal"
        case .persistent: return "Persistent Terminal"
        case .tmux: return "Full Terminal"
        case .agent: return "Agent Workspace"
        }
    }

    /// One-line description for the settings picker / onboarding.
    public var summary: String {
        switch self {
        case .plain:
            return "A fast native terminal. No command prefix or status bar; sessions close when you quit."
        case .persistent:
            return "Like Plain, but sessions survive quitting and can be attached from the CLI."
        case .tmux:
            return "The full Harness experience: command prefix, status line, copy mode, paste buffers, panes, and the harness-cli command set."
        case .agent:
            return "Persistent project workspaces with AI-agent detection, notifications, and jump-to-agent."
        }
    }

    /// Whether the tmux chrome — prefix-key handling, the prefix indicator, the bottom
    /// status line, and multiplexer terminology in onboarding — is shown by default.
    /// Only `tmux` shows it by default; the others can opt in via `tmuxControlsEnabled`.
    public var showsTmuxChromeByDefault: Bool { self == .tmux }

    /// Whether sessions created in this mode persist across a *clean* GUI quit by default.
    /// Only `plain` is ephemeral. (A daemon or GUI crash never tears sessions down in any
    /// mode — survival across a crash is always a feature.)
    public var persistsSessionsByDefault: Bool { self != .plain }

    /// Whether agent workflows are foregrounded (Agent Workspace).
    public var foregroundsAgents: Bool { self == .agent }
}
