import Foundation
import KouenCore

/// Codex CLI implementation of `HeadlessCLIAdapter`.
///
/// Drives `codex exec --json` in headless mode. Verified against a real local install
/// (`codex 0.153.2`) — captured JSONL shape:
/// ```
/// {"type":"thread.started","thread_id":"01a0..."}
/// {"type":"turn.started"}
/// {"type":"item.completed","item":{"id":"item_0","type":"error","message":"..."}}   // informational, not fatal
/// {"type":"item.completed","item":{"id":"item_1","type":"agent_message","text":"hi"}}
/// {"type":"turn.completed","usage":{...}}
/// ```
/// No `--session-id`-style flag exists to make Codex resume under a caller-chosen id — it
/// always generates its own `thread_id` (visible only in `thread.started`), so unlike Claude,
/// `id` here is never actually passed to the process. Resuming a specific run would need the
/// engine to capture and store that reported `thread_id` separately from `id`, which is a
/// separate not-yet-built slice (see agent-memory/plans/agent-swarm-core/design.md) — for now
/// `resumeSessionID` is accepted but ignored, same scope boundary already established for
/// Lane A follow-up turns generally.
///
/// `turn.completed` carries no final-text/success field of its own — `parseLine` only ever
/// emits `.assistantText` (from `agent_message` items) and never `.result`; success/failure and
/// the final `resultText` both come from the engine's own exit-code/last-assistant-text
/// fallbacks in `ClaudeCodeHarness.finish(id:exitCode:)`. No cost-in-USD is exposed by Codex,
/// only token counts, so `totalCostUSD` stays nil for every Codex run.
public struct CodexAdapter: HeadlessCLIAdapter {
    public let agentKind: AgentKind = .codex
    public let binaryName: String = "codex"
    public let candidateBinaryPaths: [String] = [
        "~/.local/bin/codex",
        "/opt/homebrew/bin/codex",
        "/usr/local/bin/codex",
    ]

    public init() {}

    public func probeCommand(shellPath: String) -> String {
        shellPath.hasSuffix("zsh") ? "whence -p codex" : "type -P codex"
    }

    /// `readonly` maps to `-s read-only` (no writes at all); `edit` maps to `-s
    /// workspace-write` (file writes allowed within the sandbox, no network) — `exec` mode
    /// never prompts for approval (there's no TTY to prompt on), so the sandbox flag alone is
    /// the entire permission boundary, same role Claude's `--allowedTools`/`--disallowedTools`
    /// play. `--skip-git-repo-check` makes headless runs robust regardless of whether `cwd`
    /// happens to be on Codex's own trusted-directory list. `model`/`resumeSessionID` are
    /// accepted per the protocol but `resumeSessionID` is a no-op (see the type's doc comment);
    /// Codex `exec` exposes no reasoning-effort flag, so `effort` is also ignored.
    public func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String] {
        var args = ["exec", "--json", "--skip-git-repo-check", "-s", profile == .readonly ? "read-only" : "workspace-write"]
        if let model { args += ["-m", model] }
        args.append(prompt)
        return args
    }

    private struct ItemCompletedLine: Decodable {
        struct Item: Decodable { var type: String; var text: String? }
        var type: String
        var item: Item
    }

    public func parseLine(_ lineData: Data) -> [HeadlessRunEvent] {
        guard let line = try? JSONDecoder().decode(ItemCompletedLine.self, from: lineData),
              line.type == "item.completed", line.item.type == "agent_message",
              let text = line.item.text
        else { return [] }
        return [.assistantText(text)]
    }
}
