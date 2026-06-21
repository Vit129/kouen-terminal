import Foundation

/// Configuration for the Warp-style inline terminal AI chat (⌘I).
/// Stored in `HarnessSettings.aiAgent`; persisted to `settings.json`.
public struct AIAgentConfig: Codable, Sendable, Equatable {
    /// The CLI agent to use for inline terminal chat.
    public var activeAgent: AgentKind
    /// Override the auto-detected binary path. `nil` = resolve via login shell `which`.
    public var binaryPathOverride: String?
    /// How many lines of pane scrollback to inject as context before the query.
    public var contextLines: Int

    public init(
        activeAgent: AgentKind = .claudeCode,
        binaryPathOverride: String? = nil,
        contextLines: Int = 80
    ) {
        self.activeAgent = activeAgent
        self.binaryPathOverride = binaryPathOverride
        self.contextLines = contextLines
    }

    // MARK: - CLI print-mode args

    /// Arguments to pass to the agent CLI for a one-shot print-mode query.
    /// Context is injected on stdin; the query is the final positional argument.
    public func cliArgs(query: String) -> [String] {
        switch activeAgent {
        case .claudeCode:   return ["-p", query]
        case .codex:        return ["exec", query]
        case .antigravity:  return ["-p", query]
        default:            return ["-p", query]
        }
    }

    /// The binary name to resolve when `binaryPathOverride` is nil.
    public var binaryName: String {
        switch activeAgent {
        case .claudeCode:   return "claude"
        case .codex:        return "codex"
        case .antigravity:  return "agy"
        case .kiro:         return "kiro"
        default:            return activeAgent.rawValue
        }
    }

    /// True if this agent kind supports CLI print mode for terminal chat.
    public static func supportsTerminalChat(_ agent: AgentKind) -> Bool {
        switch agent {
        case .claudeCode, .codex, .antigravity, .kiro: return true
        default: return false
        }
    }
}
