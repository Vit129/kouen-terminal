import Foundation
import HarnessIPC

/// Configuration for the Warp-style inline terminal AI chat (⌘I).
/// Stored in `HarnessSettings.aiAgent`; persisted to `settings.json`.
public struct AIAgentConfig: Codable, Sendable, Equatable {
    /// The CLI agent to use for inline terminal chat.
    public var activeAgent: AgentKind
    /// Override the auto-detected binary path. `nil` = resolve via login shell `which`.
    public var binaryPathOverride: String?
    /// How many lines of pane scrollback to inject as context before the query.
    public var contextLines: Int
    /// Model override per agent (e.g. "claude-opus-4.8"). `nil` = agent default.
    public var activeModel: String?
    /// Effort level override (e.g. "high"). `nil` = agent default. Only used by agents that support it.
    public var activeEffort: String?

    public init(
        activeAgent: AgentKind = .claudeCode,
        binaryPathOverride: String? = nil,
        contextLines: Int = 80,
        activeModel: String? = nil,
        activeEffort: String? = nil
    ) {
        self.activeAgent = activeAgent
        self.binaryPathOverride = binaryPathOverride
        self.contextLines = contextLines
        self.activeModel = activeModel
        self.activeEffort = activeEffort
    }

    // MARK: - CLI print-mode args

    /// Arguments to pass to the agent CLI for a one-shot print-mode query.
    /// Context is injected on stdin; flags precede the positional `-p query`.
    public func cliArgs(query: String) -> [String] {
        switch activeAgent {
        case .claudeCode:
            // activeEffort shown in UI but not passed — Claude uses /effort in-session instead.
            var args: [String] = []
            if let model = activeModel { args += ["--model", model] }
            args += ["-p", query]
            return args
        case .codex:
            var args: [String] = []
            if let model = activeModel { args += ["--model", model] }
            if let effort = activeEffort { args += ["-c", "model_reasoning_effort=\(effort)"] }
            args += ["exec", query]
            return args
        case .kiro:
            var args: [String] = []
            if let model = activeModel { args += ["--model", model] }
            if let effort = activeEffort { args += ["--effort", effort] }
            args += ["-p", query]
            return args
        case .antigravity:
            var args: [String] = []
            if let model = activeModel { args += ["--model", model] }
            args += ["-p", query]
            return args
        default:
            var args: [String] = []
            if let model = activeModel { args += ["--model", model] }
            args += ["-p", query]
            return args
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
