#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import HarnessCore

extension HarnessCLI {
    /// `harness-cli install-mcp [--claude-code] [--claude-desktop] [--all]`
    ///
    /// Registers harness-mcp with AI agent host applications so they can discover and launch
    /// the server automatically. Defaults to --all when no target flag is given.
    ///
    /// Claude Code: delegates to `claude mcp add` (user scope) so Claude manages the JSON.
    /// Claude Desktop: writes `mcpServers.harness` directly into claude_desktop_config.json
    ///   because Claude Desktop has no CLI installer.
    static func handleInstallMCP(_ args: [String]) throws {
        let wantsClaudeCode = args.contains("--claude-code")
        let wantsClaudeDesktop = args.contains("--claude-desktop")
        let all = !wantsClaudeCode && !wantsClaudeDesktop || args.contains("--all")

        guard let mcpBin = locateMCPBinary() else {
            fputs(
                "install-mcp: harness-mcp binary not found.\n"
                    + "  Run 'harness-cli install' first to copy binaries into place,\n"
                    + "  or set HARNESS_MCP_PATH to the binary location.\n",
                harnessStderr
            )
            exit(1)
        }

        var anySuccess = false

        if all || wantsClaudeCode {
            anySuccess = installForClaudeCode(mcpBin: mcpBin) || anySuccess
        }
        if all || wantsClaudeDesktop {
            anySuccess = installForClaudeDesktop(mcpBin: mcpBin) || anySuccess
        }

        if anySuccess {
            fputs(
                "\nNote: read-only tools are enabled by default.\n"
                    + "To allow control tools (send keys, run commands, write files), set:\n"
                    + "  HARNESS_MCP_ALLOW_CONTROL=1\n"
                    + "Or add tool names to mcp-policy.json in the Harness config directory.\n",
                stdout
            )
        }
    }

    // MARK: - Claude Code

    @discardableResult
    private static func installForClaudeCode(mcpBin: URL) -> Bool {
        // Use the official `claude mcp add` CLI so Claude Code manages its own config.
        guard let claudePath = findClaudeCLI() else {
            fputs("install-mcp: 'claude' CLI not found — install Claude Code first.\n", harnessStderr)
            return false
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: claudePath)
        // -s user → writes to ~/.claude.json (user scope, available in all projects)
        process.arguments = ["mcp", "add", "harness", mcpBin.path, "-s", "user"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.standardError
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                print("claude-code: registered 'harness' MCP server (user scope)")
                return true
            } else {
                fputs("install-mcp: 'claude mcp add' exited \(process.terminationStatus)\n", harnessStderr)
                return false
            }
        } catch {
            fputs("install-mcp: failed to run 'claude mcp add': \(error.localizedDescription)\n", harnessStderr)
            return false
        }
    }

    private static func findClaudeCLI() -> String? {
        let candidates = [
            "/usr/local/bin/claude",
            "/opt/homebrew/bin/claude",
        ]
        if let found = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return found
        }
        // Fall back to PATH resolution via /usr/bin/env.
        let check = Process()
        check.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        check.arguments = ["claude"]
        let pipe = Pipe()
        check.standardOutput = pipe
        check.standardError = FileHandle.nullDevice
        try? check.run()
        check.waitUntilExit()
        guard check.terminationStatus == 0 else { return nil }
        let raw = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let path = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return path.isEmpty ? nil : path
    }

    // MARK: - Claude Desktop

    @discardableResult
    private static func installForClaudeDesktop(mcpBin: URL) -> Bool {
        let configPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Claude/claude_desktop_config.json")

        // Load existing config or start with empty object.
        var config: [String: Any] = [:]
        if FileManager.default.fileExists(atPath: configPath.path),
           let data = try? Data(contentsOf: configPath),
           let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            config = parsed
        }

        var mcpServers = config["mcpServers"] as? [String: Any] ?? [:]
        mcpServers["harness"] = [
            "command": mcpBin.path,
            "args": [String](),
        ]
        config["mcpServers"] = mcpServers

        do {
            // Ensure parent directory exists.
            try FileManager.default.createDirectory(
                at: configPath.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            // Back up existing file before overwriting.
            if FileManager.default.fileExists(atPath: configPath.path) {
                let backup = configPath.deletingLastPathComponent()
                    .appendingPathComponent("claude_desktop_config.json.bak")
                _ = try? FileManager.default.removeItem(at: backup)
                try FileManager.default.copyItem(at: configPath, to: backup)
            }

            let data = try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: configPath, options: .atomic)
            print("claude-desktop: registered 'harness' MCP server in \(configPath.path)")
            print("  Restart Claude Desktop to pick up the change.")
            return true
        } catch {
            fputs("install-mcp: failed to write \(configPath.path): \(error.localizedDescription)\n", harnessStderr)
            return false
        }
    }
}
