import Foundation
import HarnessCore

extension HarnessCLI {

    /// harness-cli mcp <subcommand>
    ///
    ///   setup   — write mcpServers.harness to every detected agent config file
    ///   status  — print which agents are configured and where harness-mcp lives
    ///   remove  — remove mcpServers.harness from all configured agents
    static func handleMCP(_ args: [String]) {
        let sub = args.dropFirst().first ?? "status"
        switch sub {
        case "setup":   mcpSetup()
        case "status":  mcpStatus()
        case "remove":  mcpRemove()
        default:
            fputs("""
            Usage: harness-cli mcp <subcommand>
              setup   Write harness-mcp into each agent's MCP config
              status  Show which agents have harness configured
              remove  Remove harness-mcp from all agent configs
            """, harnessStderr)
            exit(1)
        }
    }

    // MARK: - Subcommands

    private static func mcpSetup() {
        let binaryPath = resolveMCPBinaryPath()
        guard let binaryPath else {
            fputs(
                "harness-cli mcp setup: harness-mcp binary not found.\n" +
                "Run `make build` or install Harness.app first.\n",
                harnessStderr
            )
            exit(1)
        }
        print("Using harness-mcp at: \(binaryPath)")

        var configured = 0
        var skipped = 0
        for agent in AgentKind.allCases where MCPConfigWriter.canConfigure(agent) {
            // Skip agents not installed on this machine.
            guard isAgentInstalled(agent) else {
                print("  \(agentLabel(agent)): not installed — skipped")
                skipped += 1
                continue
            }
            do {
                try MCPConfigWriter.add(agent, mcpBinaryPath: binaryPath)
                let already = MCPConfigWriter.isConfigured(agent)
                print("  \(agentLabel(agent)): \(already ? "✓ configured" : "added")")
                configured += 1
            } catch {
                fputs("  \(agentLabel(agent)): error — \(error.localizedDescription)\n", harnessStderr)
            }
        }
        print("\n\(configured) agent(s) configured. Restart each agent to load the MCP server.")
        if skipped > 0 {
            print("(\(skipped) skipped — not installed)")
        }
    }

    private static func mcpStatus() {
        let binaryPath = resolveMCPBinaryPath() ?? "(not found)"
        print("harness-mcp: \(binaryPath)\n")
        print(String(repeating: "-", count: 50))
        print(col("Agent", 20) + col("Installed", 12) + "MCP")
        print(String(repeating: "-", count: 50))
        for agent in AgentKind.allCases where MCPConfigWriter.canConfigure(agent) {
            let installed = isAgentInstalled(agent) ? "yes" : "no"
            let configured = MCPConfigWriter.isConfigured(agent) ? "✓ configured" : "—"
            print(col(agentLabel(agent), 20) + col(installed, 12) + configured)
        }
        print("")
        print("Note: Codex uses its plugin marketplace — mcpServers not supported in config.toml")
    }

    private static func col(_ s: String, _ width: Int) -> String {
        s + String(repeating: " ", count: max(0, width - s.count))
    }

    private static func mcpRemove() {
        var removed = 0
        for agent in AgentKind.allCases where MCPConfigWriter.canConfigure(agent) {
            guard MCPConfigWriter.isConfigured(agent) else { continue }
            do {
                try MCPConfigWriter.remove(agent)
                print("  \(agentLabel(agent)): removed")
                removed += 1
            } catch {
                fputs("  \(agentLabel(agent)): error — \(error.localizedDescription)\n", harnessStderr)
            }
        }
        if removed == 0 {
            print("No agents had harness-mcp configured.")
        } else {
            print("\n\(removed) agent(s) removed.")
        }
    }

    // MARK: - Helpers

    /// Resolve `harness-mcp` binary path with priority:
    /// 1. Installed app-support bin/ directory (survives app moves)
    /// 2. Same directory as the running harness-cli executable (bundle or dev build)
    /// 3. Debug build directory (for `swift run` / direct dev usage)
    private static func resolveMCPBinaryPath() -> String? {
        let candidates: [URL] = [
            BinaryRefresher.binDirectory.appendingPathComponent("harness-mcp"),
            executableSiblingURL(named: "harness-mcp"),
        ].compactMap { $0 } + devBuildCandidates()

        return candidates.first {
            FileManager.default.isExecutableFile(atPath: $0.path)
        }?.path
    }

    private static func executableSiblingURL(named name: String) -> URL? {
        guard let selfPath = ProcessInfo.processInfo.arguments.first else { return nil }
        let dir = URL(fileURLWithPath: selfPath).deletingLastPathComponent()
        return dir.appendingPathComponent(name)
    }

    private static func devBuildCandidates() -> [URL] {
        // Walk up from executable toward the repo root to find .build/
        var dir = URL(fileURLWithPath: ProcessInfo.processInfo.arguments.first ?? ".")
            .deletingLastPathComponent()
        for _ in 0..<6 {
            let debug   = dir.appendingPathComponent(".build/debug/harness-mcp")
            let release = dir.appendingPathComponent(".build/release/harness-mcp")
            if FileManager.default.fileExists(atPath: debug.path)   { return [debug] }
            if FileManager.default.fileExists(atPath: release.path) { return [release] }
            dir = dir.deletingLastPathComponent()
        }
        return []
    }

    /// True when the agent CLI binary is reachable on the current PATH.
    private static func isAgentInstalled(_ agent: AgentKind) -> Bool {
        let binary: String
        switch agent {
        case .claudeCode:   binary = "claude"
        case .kiro:         binary = "kiro"
        case .antigravity:  binary = "agy"
        default:            return false
        }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        proc.arguments = [binary]
        proc.standardOutput = Pipe()
        proc.standardError  = Pipe()
        guard (try? proc.run()) != nil else { return false }
        proc.waitUntilExit()
        return proc.terminationStatus == 0
    }

    private static func agentLabel(_ agent: AgentKind) -> String {
        switch agent {
        case .claudeCode:   return "Claude Code"
        case .kiro:         return "Kiro"
        case .antigravity:  return "Agy (Gemini)"
        default:            return agent.rawValue
        }
    }
}
