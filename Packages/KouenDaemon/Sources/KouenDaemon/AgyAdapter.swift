import Foundation
import KouenCore

/// Antigravity (`agy`) CLI implementation of `HeadlessCLIAdapter`.
///
/// Drives `agy --print=<prompt> --output-format stream-json` in headless mode. Verified
/// against a real local install — captured JSONL shape:
/// ```
/// {"event":"init","conversation_id":"37e2...", ...}
/// {"event":"step_update","step_update":{"conversation_id":"...","step_index":1,"state":"ACTIVE","step_type":"agent_response","text_delta":"hi"}}
/// {"event":"step_update","step_update":{"conversation_id":"...","step_index":1,"state":"DONE","step_type":"agent_response","text_delta":"\n", "usage":{...}}}
/// {"event":"result","result":{"conversation_id":"...","status":"SUCCESS","response":"hi\n","usage":{...}}}
/// ```
/// `step_update`'s `text_delta` is an incremental chunk, not the full message — accumulating it
/// correctly would need per-run state, which adapters can't hold (a single adapter instance is
/// shared across every concurrent run of its kind). Unnecessary here anyway: the final `result`
/// event already carries the complete answer in `response`, so `parseLine` only decodes that one
/// line shape and ignores every `step_update`/`init` line. `--conversation <id>` is agy's resume
/// flag, but (same as Codex) `agy` assigns its own `conversation_id` rather than accepting a
/// caller-chosen one — `resumeSessionID` is accepted per the protocol but ignored, same
/// not-yet-built-slice boundary as `CodexAdapter`. No cost-in-USD is exposed, only token usage,
/// so `totalCostUSD` stays nil.
public struct AgyAdapter: HeadlessCLIAdapter {
    public let agentKind: AgentKind = .antigravity
    public let binaryName: String = "agy"
    public let candidateBinaryPaths: [String] = [
        "~/.local/bin/agy",
        "/opt/homebrew/bin/agy",
        "/usr/local/bin/agy",
    ]

    public init() {}

    public func probeCommand(shellPath: String) -> String {
        shellPath.hasSuffix("zsh") ? "whence -p agy" : "type -P agy"
    }

    /// `readonly` maps to `--mode plan` (agy's read/analyze-only mode, no file edits);
    /// `edit` maps to `--mode accept-edits`. `--print=<prompt>` (not a separate `--print`
    /// flag followed by the prompt as its own argument) is required — agy's own CLI error
    /// message for the two-argument form is explicit: "--print took --output-format as its
    /// prompt", i.e. `--print` greedily consumes the very next token as the prompt text.
    /// `--dangerously-skip-permissions` is never passed — headless mode has no UI to answer
    /// permission prompts, so `--mode`'s own boundary is the entire permission surface, same
    /// role Claude's `--allowedTools` plays.
    public func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String] {
        var args = [
            "--output-format", "stream-json",
            "--mode", profile == .readonly ? "plan" : "accept-edits",
            "--print=\(prompt)",
        ]
        if let model { args += ["--model", model] }
        if let effort { args += ["--effort", effort] }
        return args
    }

    private struct ResultLine: Decodable {
        struct Result: Decodable { var status: String; var response: String? }
        var event: String
        var result: Result
    }

    public func parseLine(_ lineData: Data) -> [HeadlessRunEvent] {
        guard let line = try? JSONDecoder().decode(ResultLine.self, from: lineData), line.event == "result" else {
            return []
        }
        return [.result(text: line.result.response, costUSD: nil, isError: line.result.status != "SUCCESS")]
    }
}
