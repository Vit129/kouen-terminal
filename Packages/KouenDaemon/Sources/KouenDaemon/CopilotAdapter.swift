import Foundation
import KouenCore

/// GitHub Copilot CLI implementation of `HeadlessCLIAdapter`.
///
/// Drives `copilot -p <prompt> --output-format json --allow-all-tools` in headless mode.
/// Verified against a real local install — captured JSONL shape:
/// ```
/// {"type":"assistant.message_delta","data":{"messageId":"...","deltaContent":"hi"}}
/// {"type":"assistant.message","data":{"messageId":"...","content":"hi","toolRequests":[]}}
/// {"type":"result","sessionId":"d6fd...","exitCode":0,"usage":{...}}
/// ```
/// `assistant.message_delta` is an incremental chunk (like `AgyAdapter`'s `text_delta`) —
/// ignored in favor of `assistant.message`, which carries each turn's complete `content`.
/// `result` carries no text field at all, only `exitCode`/`sessionId`/`usage` — `isError`
/// comes from `exitCode != 0` (a precise signal Copilot itself reports, unlike Codex's
/// `turn.completed`), and `resultText` falls back to the engine's own last-`.assistantText`
/// tracking (`ClaudeCodeHarness.finish(id:exitCode:)`), same shape as `CodexAdapter`.
///
/// Unlike Codex/Agy, `--session-id <uuid>` DOES let the caller set the id for a *new* session
/// (confirmed: `--session-id <id> Resume an existing session or task by ID, or set the UUID
/// for a new session`) — so `id`/`resumeSessionID` map onto it exactly the way Claude's
/// `--session-id`/`--resume` do; no "CLI assigns its own id" workaround needed here. No
/// cost-in-USD is exposed (only `usage.premiumRequests`), so `totalCostUSD` stays nil.
public struct CopilotAdapter: HeadlessCLIAdapter {
    public let agentKind: AgentKind = .copilot
    public let binaryName: String = "copilot"
    /// GitHub's official install is `npm install -g @github/copilot` (a plain `copilot` on
    /// PATH, first two fallbacks below). The third is where `gh copilot` itself downloads a
    /// private copy when only the `gh` CLI extension is installed — real path confirmed on a
    /// local machine, not officially documented as stable, kept as a last-resort fallback.
    public let candidateBinaryPaths: [String] = [
        "~/.local/bin/copilot",
        "/opt/homebrew/bin/copilot",
        "~/.local/share/gh/copilot/copilot",
    ]

    public init() {}

    public func probeCommand(shellPath: String) -> String {
        shellPath.hasSuffix("zsh") ? "whence -p copilot" : "type -P copilot"
    }

    /// `--allow-all-tools` is required for non-interactive mode per the CLI's own help text
    /// ("required for non-interactive mode") — headless has no UI to answer permission
    /// prompts, matching every other adapter's "the profile/mode flag is the entire
    /// permission boundary" shape. There is no separate readonly/edit distinction exposed by
    /// this CLI's flags (`--allow-all-tools` is all-or-nothing) — `profile` is accepted per
    /// the protocol but doesn't change the argument list; edit-vs-readonly enforcement for
    /// Copilot would need a real allow/deny tool list, which is future work, not invented here.
    public func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String] {
        var args = ["-p", prompt, "--output-format", "json", "--allow-all-tools", "--no-color"]
        args += ["--session-id", (resumeSessionID ?? id).uuidString]
        if let model { args += ["--model", model] }
        return args
    }

    private struct AssistantMessageLine: Decodable {
        struct Data: Decodable { var content: String? }
        var type: String
        var data: Data
    }

    private struct ResultLine: Decodable {
        var type: String
        var exitCode: Int
    }

    public func parseLine(_ lineData: Data) -> [HeadlessRunEvent] {
        if let line = try? JSONDecoder().decode(AssistantMessageLine.self, from: lineData),
           line.type == "assistant.message", let content = line.data.content
        {
            return [.assistantText(content)]
        }
        if let line = try? JSONDecoder().decode(ResultLine.self, from: lineData), line.type == "result" {
            return [.result(text: nil, costUSD: nil, isError: line.exitCode != 0)]
        }
        return []
    }
}
