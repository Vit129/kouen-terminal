import Foundation

/// Reads and writes the `harness-mcp` entry in each supported agent's MCP server config file.
///
/// Supported agents and their config files:
/// - Claude Code  → `~/.claude.json`              (mcpServers key)
/// - Kiro         → `~/.kiro/settings/mcp.json`   (mcpServers key)
/// - Antigravity  → `~/.gemini/settings.json`      (mcpServers key)
///
/// All writes are atomic and create parent directories as needed. Existing keys in the
/// config file are preserved — only the `harness` key under `mcpServers` is touched.
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

    /// Key Harness uses inside `mcpServers`.
    public static let serverKey = "harness"

    // MARK: - Public API

    public static func canConfigure(_ agent: AgentKind) -> Bool {
        configURL(for: agent) != nil
    }

    /// Returns true when `mcpServers.harness` already exists in the agent's config file.
    public static func isConfigured(_ agent: AgentKind) -> Bool {
        guard let url = configURL(for: agent) else { return false }
        guard let json = readJSON(at: url),
              let servers = json["mcpServers"] as? [String: Any]
        else { return false }
        return servers[serverKey] != nil
    }

    /// Adds `mcpServers.harness` pointing at `mcpBinaryPath`. Idempotent — re-adding
    /// overwrites the previous path (handles binary relocation after app update).
    public static func add(_ agent: AgentKind, mcpBinaryPath: String) throws {
        guard let url = configURL(for: agent) else { throw ConfigError.unsupportedAgent(agent) }
        var json = readJSON(at: url) ?? [:]
        var servers = json["mcpServers"] as? [String: Any] ?? [:]
        servers[serverKey] = ["type": "stdio", "command": mcpBinaryPath]
        json["mcpServers"] = servers
        do { try writeJSON(json, to: url) }
        catch { throw ConfigError.writeFailure(url, error) }
    }

    /// Removes `mcpServers.harness` from the agent's config file. No-op if not present.
    public static func remove(_ agent: AgentKind) throws {
        guard let url = configURL(for: agent) else { throw ConfigError.unsupportedAgent(agent) }
        var json = readJSON(at: url) ?? [:]
        var servers = json["mcpServers"] as? [String: Any] ?? [:]
        servers.removeValue(forKey: serverKey)
        json["mcpServers"] = servers
        do { try writeJSON(json, to: url) }
        catch { throw ConfigError.writeFailure(url, error) }
    }

    // MARK: - Config file locations

    /// The config file that holds `mcpServers` for `agent`, or nil when not supported.
    public static func configURL(for agent: AgentKind) -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        switch agent {
        case .claudeCode:   return home.appendingPathComponent(".claude.json")
        case .kiro:         return home.appendingPathComponent(".kiro/settings/mcp.json")
        case .antigravity:  return home.appendingPathComponent(".gemini/settings.json")
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
}
