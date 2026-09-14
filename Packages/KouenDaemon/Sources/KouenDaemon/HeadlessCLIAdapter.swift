import Foundation
import KouenCore

/// One implementation per headless-capable CLI. Pure data-in/data-out — no
/// process/fd ownership — so adapters are easy to unit-test with captured
/// fixture output. The engine (`ClaudeCodeHarness`) owns all process
/// spawning/lifecycle; adapters only know how to build a CLI's arguments and
/// decode its output lines.
public protocol HeadlessCLIAdapter: Sendable {
    var agentKind: AgentKind { get }
    var binaryName: String { get }
    /// Absolute fallback paths to check if the shell probe (see `probeCommand`)
    /// fails to resolve the binary. `~` is expanded by the caller.
    var candidateBinaryPaths: [String] { get }
    /// Shell command that resolves this CLI's true executable path when it may
    /// be a shell function/alias in interactive shells (Claude's case: `claude`
    /// is a zsh function, so `which`/`command -v` under a non-login shell won't
    /// resolve it — `whence -p claude` / `type -P claude` does).
    func probeCommand(shellPath: String) -> String

    func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String]

    /// Decode one line of subprocess stdout into zero or more engine-neutral
    /// events. Adapters never touch any shared state directly — they return
    /// data, the engine applies it.
    func parseLine(_ lineData: Data) -> [HeadlessRunEvent]
}

public enum HeadlessRunEvent: Sendable, Equatable {
    case assistantText(String)
    case result(text: String?, costUSD: Double?, isError: Bool)
}
