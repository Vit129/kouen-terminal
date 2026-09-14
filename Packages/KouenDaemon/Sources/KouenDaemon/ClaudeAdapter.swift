import Foundation
import KouenCore

/// Claude Code implementation of `HeadlessCLIAdapter`.
///
/// Drives `claude -p --output-format stream-json` in headless mode.
/// Pure data-in/data-out: builds Claude-specific CLI flags and decodes stream-json lines.
public struct ClaudeAdapter: HeadlessCLIAdapter {
    public let agentKind: AgentKind = .claudeCode
    public let binaryName: String = "claude"

    /// Absolute fallback paths to check if the shell probe fails to resolve the binary.
    /// `~` is expanded by the caller.
    public let candidateBinaryPaths: [String] = [
        "~/.local/bin/claude",
        "/opt/homebrew/bin/claude",
        "/usr/local/bin/claude",
    ]

    public init() {}

    /// `claude` is a zsh *function* in interactive shells (injects `-n <dirname>`), not a
    /// directly executable path — plain `which`/`command -v` under a non-login shell won't
    /// resolve it. `whence -p` (zsh) / `type -P` (bash) finds the real binary. Probed once
    /// per daemon lifetime and cached; this is also what fixes the launchd-minimal-PATH
    /// problem that shelved the ACP integration (`Kouen.entitlements` has App Sandbox off,
    /// so it was never a sandbox restriction — just a PATH one).
    public func probeCommand(shellPath: String) -> String {
        shellPath.hasSuffix("zsh") ? "whence -p claude" : "type -P claude"
    }

    /// `readonly`: no writes, no Bash — analysis/review only. `edit`: Edit/Write allowed,
    /// a git-readonly Bash allowlist, `rm`/`sudo`/`git push` explicitly denied. Never
    /// `bypassPermissions` — headless mode has no UI to answer prompts, so the allowlist
    /// is the entire security boundary. `--setting-sources ""` skips the user's global
    /// CLAUDE.md + hooks (measured ~83% cache-creation-token cut) without touching OAuth
    /// auth the way `--bare` does — see design.md's "Cost/context overhead control".
    public func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String] {
        var args = ["-p", prompt, "--output-format", "stream-json", "--verbose", "--setting-sources", ""]
        if let resumeSessionID {
            args += ["--resume", resumeSessionID.uuidString]
        } else {
            args += ["--session-id", id.uuidString]
        }
        switch profile {
        case .readonly:
            args += ["--permission-mode", "dontAsk", "--allowedTools", "Read", "Glob", "Grep", "Task", "WebFetch"]
        case .edit:
            args += [
                "--permission-mode", "acceptEdits",
                "--allowedTools", "Read", "Glob", "Grep", "Task", "Edit", "Write",
                "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",
                "--disallowedTools", "Bash(rm:*)", "Bash(sudo:*)", "Bash(git push:*)",
            ]
        }
        if let model { args += ["--model", model] }
        if let effort { args += ["--effort", effort] }
        return args
    }

    /// Decodes only the two line shapes the harness needs (`type: "assistant"` for a live
    /// preview, `type: "result"` for the terminal outcome) — the raw JSONL transcript
    /// keeps full fidelity on disk, so nothing else needs modeling in Swift.
    private struct AssistantLine: Decodable {
        struct Message: Decodable {
            struct Content: Decodable { var type: String; var text: String? }
            var content: [Content]
        }
        var type: String
        var message: Message
    }

    private struct ResultLine: Decodable {
        var type: String
        var is_error: Bool
        var result: String?
        var total_cost_usd: Double?
    }

    /// Decode one line of subprocess stdout into zero or more engine-neutral
    /// events. Adapters never touch any shared state directly — they return
    /// data, the engine applies it.
    public func parseLine(_ lineData: Data) -> [HeadlessRunEvent] {
        guard !lineData.isEmpty else { return [] }
        if let assistant = try? JSONDecoder().decode(AssistantLine.self, from: lineData), assistant.type == "assistant" {
            if let text = assistant.message.content.first(where: { $0.type == "text" })?.text {
                return [.assistantText(text)]
            }
        } else if let result = try? JSONDecoder().decode(ResultLine.self, from: lineData), result.type == "result" {
            return [.result(text: result.result, costUSD: result.total_cost_usd, isError: result.is_error)]
        }
        return []
    }
}
