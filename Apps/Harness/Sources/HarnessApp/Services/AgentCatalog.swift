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
    }

    public static let agents: [AgentKind: AgentConfig] = loadCatalog()

    private static func loadCatalog() -> [AgentKind: AgentConfig] {
        if let loaded = loadFromDisk() { return loaded }
        return defaultAgents
    }

    private struct DiskAgentConfig: Codable {
        let id: String
        let binary: String
        let models: [String]
        let effortLevels: [String]?
        let modelFlag: String
        let effortFlag: String?
        let defaultEffort: String?
    }

    private static func loadFromDisk() -> [AgentKind: AgentConfig]? {
        let file = HarnessPaths.applicationSupport.appendingPathComponent("agent-catalog.json")
        guard let data = try? Data(contentsOf: file),
              let entries = try? JSONDecoder().decode([DiskAgentConfig].self, from: data),
              !entries.isEmpty else { return nil }
        var result: [AgentKind: AgentConfig] = [:]
        for entry in entries {
            guard let kind = AgentKind(rawValue: entry.id) else { continue }
            result[kind] = AgentConfig(
                id: kind, binary: entry.binary, models: entry.models,
                effortLevels: entry.effortLevels, modelFlag: entry.modelFlag,
                effortFlag: entry.effortFlag, defaultEffort: entry.defaultEffort
            )
        }
        return result.isEmpty ? nil : result
    }

    private static let defaultAgents: [AgentKind: AgentConfig] = [
        .claudeCode: AgentConfig(
            id: .claudeCode,
            binary: "claude",
            models: [
                "claude-opus-4-8",
                "claude-sonnet-4-6",
                "claude-haiku-4-5-20251001",
            ],
            effortLevels: ["low", "medium", "high"], // UI-only; no CLI flag — use /effort in-session
            modelFlag: "--model",
            effortFlag: nil,
            defaultEffort: "medium",
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
        ),

        .cursor: AgentConfig(
            id: .cursor,
            binary: "cursor",
            models: ["claude-sonnet-4.5", "gpt-4.1", "gemini-2.5-pro"],
            effortLevels: ["auto", "normal", "max"],
            modelFlag: "--model",
            effortFlag: "--effort",
            defaultEffort: "normal",
        ),
    ]

    // MARK: - Spawn Command Builder

    /// Build the full spawn command string for a given agent configuration.
    public static func spawnCommand(
        kind: AgentKind,
        model: String? = nil,
        effort: String? = nil
    ) -> String? {
        guard let config = agents[kind] else { return nil }

        var parts = [config.binary]

        let resolvedModel = model ?? config.models.first
        if let m = resolvedModel {
            parts += [config.modelFlag, shellQuote(m)]
        }

        if let effort = effort ?? config.defaultEffort,
           let effortFlag = config.effortFlag {
            if effortFlag.hasSuffix("=") {
                parts.append("\(effortFlag)\(shellQuote(effort))")
            } else {
                parts += [effortFlag, shellQuote(effort)]
            }
        }



        return parts.joined(separator: " ")
    }

    /// POSIX single-quote wrapping for values sourced from disk or user input.
    /// Clean identifiers (alphanum, dash, dot, slash, @, colon) pass through unquoted.
    private static func shellQuote(_ s: String) -> String {
        let safe = CharacterSet.alphanumerics.union(.init(charactersIn: "-_./@:"))
        guard s.unicodeScalars.allSatisfy({ safe.contains($0) }) else {
            return "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'"
        }
        return s
    }

    /// Check if a model name is valid for a given agent.
    public static func isValidModel(_ model: String, for kind: AgentKind) -> Bool {
        agents[kind]?.models.contains(model) ?? false
    }

    /// Check if an effort level is valid for a given agent.
    public static func isValidEffort(_ effort: String, for kind: AgentKind) -> Bool {
        agents[kind]?.effortLevels?.contains(effort) ?? false
    }

    /// Serialize current defaults to JSON string for the starter agent-catalog.json.
    public static func exportDefaultsJSON() -> String {
        let entries = defaultAgents.values.sorted { $0.id.rawValue < $1.id.rawValue }.map { c in
            var lines = [
                "    {",
                "      \"id\": \"\(c.id.rawValue)\",",
                "      \"binary\": \"\(c.binary)\",",
                "      \"models\": [\(c.models.map { "\"\($0)\"" }.joined(separator: ", "))],",
                "      \"modelFlag\": \"\(c.modelFlag)\",",
            ]
            if let levels = c.effortLevels {
                lines.append("      \"effortLevels\": [\(levels.map { "\"\($0)\"" }.joined(separator: ", "))],")
            }
            if let flag = c.effortFlag  { lines.append("      \"effortFlag\": \"\(flag)\",") }
            if let def  = c.defaultEffort { lines.append("      \"defaultEffort\": \"\(def)\",") }
            // Trim trailing comma on last field
            lines[lines.count - 1] = lines[lines.count - 1].hasSuffix(",")
                ? String(lines[lines.count - 1].dropLast()) : lines[lines.count - 1]
            lines.append("    }")
            return lines.joined(separator: "\n")
        }
        return "[\n\(entries.joined(separator: ",\n"))\n]\n"
    }
}
