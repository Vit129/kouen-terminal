import Foundation

/// Reads and writes the `kouen-mcp` entry in each supported agent's MCP server config file.
///
/// Supported agents and their config files:
/// - Claude Code  → `~/.claude.json`              (mcpServers key, JSON)
/// - Kiro         → `~/.kiro/settings/mcp.json`   (mcpServers key, JSON)
/// - Antigravity  → `~/.gemini/settings.json`      (mcpServers key, JSON)
/// - Codex        → `~/.codex/config.toml`         (`[mcp_servers.kouen]` table, TOML)
///
/// All writes are atomic and create parent directories as needed. Existing keys in the
/// config file are preserved — only the `kouen` entry is touched.
public enum MCPConfigWriter {

    public enum ConfigError: Error, LocalizedError {
        case unsupportedAgent(AgentKind)
        case writeFailure(URL, Error)

        public var errorDescription: String? {
            switch self {
            case .unsupportedAgent(let k): return "\(k.displayName) does not support MCP config"
            case .writeFailure(let url, let err): return "Could not write \(url.lastPathComponent): \(err.localizedDescription)"
            }
        }
    }

    /// Key Kouen uses inside `mcpServers`.
    public static let serverKey = "kouen"

    // MARK: - Public API

    public static func canConfigure(_ agent: AgentKind) -> Bool {
        configURL(for: agent) != nil
    }

    /// Returns true when the agent's config already declares the `kouen` MCP server.
    public static func isConfigured(_ agent: AgentKind) -> Bool {
        guard let url = configURL(for: agent) else { return false }
        if agent == .codex {
            return tomlKouenBlock(in: (try? String(contentsOf: url, encoding: .utf8)) ?? "") != nil
        }
        guard let json = readJSON(at: url),
              let servers = json["mcpServers"] as? [String: Any]
        else { return false }
        return servers[serverKey] != nil
    }

    /// Adds the `kouen` MCP server entry pointing at `mcpBinaryPath`. Idempotent — re-adding
    /// overwrites the previous path (handles binary relocation after app update).
    public static func add(_ agent: AgentKind, mcpBinaryPath: String) throws {
        guard let url = configURL(for: agent) else { throw ConfigError.unsupportedAgent(agent) }
        if agent == .codex {
            try writeTOML(mcpBinaryPath: mcpBinaryPath, to: url)
            return
        }
        var json = readJSON(at: url) ?? [:]
        var servers = json["mcpServers"] as? [String: Any] ?? [:]
        servers[serverKey] = ["type": "stdio", "command": mcpBinaryPath]
        json["mcpServers"] = servers
        do { try writeJSON(json, to: url) }
        catch { throw ConfigError.writeFailure(url, error) }
    }

    /// Removes the `kouen` MCP server entry from the agent's config file. No-op if not present.
    public static func remove(_ agent: AgentKind) throws {
        guard let url = configURL(for: agent) else { throw ConfigError.unsupportedAgent(agent) }
        if agent == .codex {
            try removeTOML(from: url)
            return
        }
        var json = readJSON(at: url) ?? [:]
        var servers = json["mcpServers"] as? [String: Any] ?? [:]
        servers.removeValue(forKey: serverKey)
        json["mcpServers"] = servers
        do { try writeJSON(json, to: url) }
        catch { throw ConfigError.writeFailure(url, error) }
    }

    // MARK: - Config file locations

    /// The config file that holds the agent's MCP server declarations, or nil when not supported.
    public static func configURL(for agent: AgentKind) -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        switch agent {
        case .claudeCode:   return home.appendingPathComponent(".claude.json")
        case .kiro:         return home.appendingPathComponent(".kiro/settings/mcp.json")
        case .antigravity:  return home.appendingPathComponent(".gemini/settings.json")
        case .codex:        return home.appendingPathComponent(".codex/config.toml")
        default:            return nil
        }
    }

    // MARK: - JSON helpers

    private static func readJSON(at url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    private static func writeJSON(_ json: [String: Any], to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        let data = try JSONSerialization.data(
            withJSONObject: json,
            options: [.prettyPrinted, .sortedKeys]
        )
        try data.write(to: url, options: .atomic)
    }

    // MARK: - TOML helpers (Codex's `[mcp_servers.kouen]` table)

    /// Codex has no JSON config — its MCP servers are `[mcp_servers.<name>]` tables in
    /// `config.toml`. We only ever own the single `kouen` table, so a full TOML parser is
    /// unnecessary: match that table's header through the next top-level `[...]` header (or
    /// EOF) and replace/append it as a block, leaving every other table untouched.
    static func tomlKouenBlock(in text: String) -> Range<String.Index>? {
        guard let regex = try? NSRegularExpression(
            pattern: #"^\[mcp_servers\.kouen\]\n(?:(?!^\[).*\n?)*"#, options: [.anchorsMatchLines]
        ) else { return nil }
        guard let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else { return nil }
        return Range(match.range, in: text)
    }

    private static func writeTOML(mcpBinaryPath: String, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil
        )
        var text = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        let block = "[mcp_servers.\(serverKey)]\ncommand = \"\(mcpBinaryPath)\"\nargs = []\n"
        if let existing = tomlKouenBlock(in: text) {
            text.replaceSubrange(existing, with: block)
        } else {
            if !text.isEmpty, !text.hasSuffix("\n\n") { text += text.hasSuffix("\n") ? "\n" : "\n\n" }
            text += block
        }
        do { try text.write(to: url, atomically: true, encoding: .utf8) }
        catch { throw ConfigError.writeFailure(url, error) }
    }

    private static func removeTOML(from url: URL) throws {
        guard var text = try? String(contentsOf: url, encoding: .utf8),
              let existing = tomlKouenBlock(in: text)
        else { return }
        text.removeSubrange(existing)
        do { try text.write(to: url, atomically: true, encoding: .utf8) }
        catch { throw ConfigError.writeFailure(url, error) }
    }
}
