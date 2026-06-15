import Foundation
import HarnessCore

/// Centralized agent configuration catalog.
/// Single source of truth for spawn commands, model options, and effort flags.
/// Update this file when agents release new models or change CLI flags.
public enum AgentCatalog {

    // MARK: - Agent Definitions

    public struct AgentConfig: Sendable {
        public let id: AgentKind
        /// Executable name to check in PATH
        public let binary: String
        /// Available models (first = default)
        public let models: [String]
        /// Effort levels supported (nil = not supported)
        public let effortLevels: [String]?
        /// How to pass model flag: e.g. "--model"
        public let modelFlag: String
        /// How to pass effort: e.g. "--effort" or "-c model_reasoning_effort="
        public let effortFlag: String?
        /// Default effort level
        public let defaultEffort: String?
        /// ACP mode flag (nil = no ACP support yet)
        public let acpFlag: String?
    }

    public static let agents: [AgentKind: AgentConfig] = [
        .claudeCode: AgentConfig(
            id: .claudeCode,
            binary: "claude",
            models: [
                "claude-opus-4.8",   // most reliable, flags errors
                "claude-opus-4.7",   // adaptive thinking
                "claude-opus-4.6",   // long sessions
                "claude-sonnet-4.6", // efficient near-opus
                "claude-sonnet-4.5", // agentic coding
                "claude-sonnet-4.0", // stable baseline
                "claude-haiku-4.5",  // fast/cheap
            ],
            effortLevels: nil, // Claude uses /effort slash command in-session, not CLI flag
            modelFlag: "--model",
            effortFlag: nil,
            defaultEffort: nil,
            acpFlag: nil // Claude ACP via adapter binary (claude-code-acp)
        ),

        .codex: AgentConfig(
            id: .codex,
            binary: "codex",
            models: [
                "gpt-5.4",    // latest
                "o3",         // reasoning
                "o4-mini",    // fast reasoning
                "gpt-4.1",    // balanced
            ],
            effortLevels: ["low", "medium", "high"],
            modelFlag: "--model",
            effortFlag: "-c model_reasoning_effort=",
            defaultEffort: "medium",
            acpFlag: nil // Codex ACP via adapter (codex-acp)
        ),

        .kiro: AgentConfig(
            id: .kiro,
            binary: "kiro-cli",
            models: [
                "auto",              // recommended: routes to best model
                "claude-opus-4.8",
                "claude-opus-4.7",
                "claude-opus-4.6",
                "claude-sonnet-4.6",
                "claude-sonnet-4.5",
                "claude-sonnet-4.0",
                "claude-haiku-4.5",
                "deepseek-3.2",      // 0.25x cost
                "minimax-m2.5",      // near-opus at 0.25x
                "glm-5",             // repo-scale
                "qwen3-coder-next",  // cheapest: 0.05x
            ],
            effortLevels: ["low", "medium", "high", "xhigh", "max"],
            modelFlag: "--model",
            effortFlag: "--effort",
            defaultEffort: "medium",
            acpFlag: "--acp"
        ),

        .gemini: AgentConfig(
            id: .gemini,
            binary: "gemini",
            models: [
                "gemini-2.5-pro",
                "gemini-2.5-flash",
                "gemini-2.0-flash",
            ],
            effortLevels: nil,
            modelFlag: "--model",
            effortFlag: nil,
            defaultEffort: nil,
            acpFlag: "--acp" // Gemini CLI is reference ACP implementation
        ),

        .cursor: AgentConfig(
            id: .cursor,
            binary: "cursor",
            models: ["claude-sonnet-4.5", "gpt-4.1", "gemini-2.5-pro"],
            effortLevels: ["auto", "normal", "max"],
            modelFlag: "--model",
            effortFlag: "--effort",
            defaultEffort: "normal",
            acpFlag: "--acp"
        ),
    ]

    // MARK: - Spawn Command Builder

    /// Build the full spawn command string for a given agent configuration.
    public static func spawnCommand(
        kind: AgentKind,
        model: String? = nil,
        effort: String? = nil,
        acp: Bool = false
    ) -> String? {
        guard let config = agents[kind] else { return nil }

        var parts = [config.binary]

        let resolvedModel = model ?? config.models.first
        if let m = resolvedModel {
            parts += [config.modelFlag, m]
        }

        if let effort = effort ?? config.defaultEffort,
           let effortFlag = config.effortFlag {
            if effortFlag.hasSuffix("=") {
                parts.append("\(effortFlag)\(effort)")
            } else {
                parts += [effortFlag, effort]
            }
        }

        if acp, let acpFlag = config.acpFlag {
            parts.append(acpFlag)
        }

        return parts.joined(separator: " ")
    }

    /// Check if a model name is valid for a given agent.
    public static func isValidModel(_ model: String, for kind: AgentKind) -> Bool {
        agents[kind]?.models.contains(model) ?? false
    }

    /// Check if an effort level is valid for a given agent.
    public static func isValidEffort(_ effort: String, for kind: AgentKind) -> Bool {
        agents[kind]?.effortLevels?.contains(effort) ?? false
    }
}
