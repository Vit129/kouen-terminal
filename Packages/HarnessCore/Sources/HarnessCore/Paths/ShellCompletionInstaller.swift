import Foundation

/// Installs `harness-cli` shell completions so they work out of the box after `install`:
/// - **fish**: written to `~/.config/fish/completions/harness-cli.fish`, which fish auto-loads
///   (no rc edit needed).
/// - **zsh/bash**: the script is written under the Harness home and a guarded, backed-up,
///   idempotent `source` block is wired into the user's rc (`.zshrc`/`.bashrc`) — the same
///   mechanism `ShellIntegration` uses for OSC 133.
///
/// Scripts come from `CompletionGenerator` (one canonical command catalog), so the installed
/// files, `harness-cli completions <shell>`, and `Scripts/completions/harness-cli.fish` never drift.
public enum ShellCompletionInstaller {
    /// The fish completion script — generated from the command catalog.
    public static var fishCompletionSource: String { CompletionGenerator.script(for: .fish) }

    private static let markerBegin = "# >>> Harness CLI completions >>>"
    private static let markerEnd = "# <<< Harness CLI completions <<<"

    public struct InstallResult: Sendable, Equatable {
        public let shell: ShellIntegration.Shell
        /// Where the completion script was written.
        public let scriptPath: URL
        /// The rc the source block was wired into (nil for fish — its dir auto-loads).
        public let rcPath: URL?
        /// True when the rc already had the block (zsh/bash) and nothing was appended this run.
        public let alreadyWired: Bool
        /// Backup of the rc taken before the first edit, if any.
        public let rcBackedUp: URL?
    }

    /// Where a shell's completion script lives. fish uses its native auto-load dir; zsh/bash live
    /// under the Harness home's `completions/` directory (sourced from the rc). `homeOverride` (the
    /// user home) redirects both for tests, mirroring `ShellIntegration`.
    public static func scriptURL(for shell: ShellIntegration.Shell, homeOverride: URL? = nil) -> URL {
        switch shell {
        case .fish:
            if let home = homeOverride {
                return home.appendingPathComponent(".config/fish/completions/harness-cli.fish")
            }
            return HarnessPaths.fishCompletionURL
        case .zsh, .bash:
            let appSupport = homeOverride.map {
                $0.appendingPathComponent("Library/Application Support/Harness", isDirectory: true)
            } ?? HarnessPaths.applicationSupport
            return appSupport.appendingPathComponent("completions", isDirectory: true)
                .appendingPathComponent("harness-cli.\(shell.rawValue)")
        }
    }

    /// Install completion for one shell. fish drops into its auto-load dir; zsh/bash write the
    /// script under the Harness home and wire a guarded `source` block into the rc (idempotent,
    /// backed up). Returns what happened so the caller can report it.
    @discardableResult
    public static func install(for shell: ShellIntegration.Shell, homeOverride: URL? = nil) throws -> InstallResult {
        let scriptURL = scriptURL(for: shell, homeOverride: homeOverride)
        try FileManager.default.createDirectory(
            at: scriptURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(CompletionGenerator.script(for: shell).utf8).write(to: scriptURL, options: .atomic)

        switch shell {
        case .fish:
            // fish auto-loads from the completions dir; no rc wiring required.
            return InstallResult(shell: shell, scriptPath: scriptURL, rcPath: nil,
                                 alreadyWired: false, rcBackedUp: nil)
        case .zsh, .bash:
            let rc = ShellIntegration.rcURL(for: shell, homeOverride: homeOverride)
            let body = sourceBody(for: shell, scriptPath: scriptURL)
            let wired = try ShellRCWiring.wire(into: rc, begin: markerBegin, end: markerEnd, body: body)
            return InstallResult(shell: shell, scriptPath: scriptURL, rcPath: rc,
                                 alreadyWired: wired.alreadyWired, rcBackedUp: wired.backedUp)
        }
    }

    /// Install completions for the user's login shell (`shellPath` or `$SHELL`): always lay down
    /// the fish drop-in (auto-loaded; inert without fish) and, for a zsh/bash login, wire the rc.
    /// Returns human-readable summary lines for the installer to print/show.
    public static func installForLoginShell(shellPath: String? = nil, homeOverride: URL? = nil) throws -> [String] {
        var lines: [String] = []
        let fish = try install(for: .fish, homeOverride: homeOverride)
        lines.append("fish-completion: \(fish.scriptPath.path)")

        switch ShellIntegration.Shell.detect(from: shellPath ?? ProcessInfo.processInfo.environment["SHELL"] ?? "") {
        case .zsh:
            lines.append(try wireSummary(for: .zsh, homeOverride: homeOverride))
        case .bash:
            lines.append(try wireSummary(for: .bash, homeOverride: homeOverride))
        case .fish, nil:
            break // fish handled above; an unknown shell can use `harness-cli completions <shell>`.
        }
        return lines
    }

    private static func wireSummary(for shell: ShellIntegration.Shell, homeOverride: URL?) throws -> String {
        let result = try install(for: shell, homeOverride: homeOverride)
        let rc = result.rcPath?.path ?? "your rc"
        if result.alreadyWired {
            return "\(shell.rawValue)-completion: already enabled in \(rc)"
        }
        let backup = result.rcBackedUp.map { " (backed up \($0.lastPathComponent))" } ?? ""
        return "\(shell.rawValue)-completion: enabled in \(rc)\(backup) — restart your shell"
    }

    /// The rc line that loads our completion. bash sources it directly; zsh bootstraps `compinit`
    /// first only if the completion system isn't already initialized (so it works even in a bare
    /// zsh, without a redundant init for users who already run compinit).
    private static func sourceBody(for shell: ShellIntegration.Shell, scriptPath: URL) -> String {
        switch shell {
        case .bash:
            return "[ -f \"\(scriptPath.path)\" ] && source \"\(scriptPath.path)\""
        case .zsh:
            return """
            if ! whence compdef >/dev/null 2>&1; then autoload -Uz compinit && compinit -u 2>/dev/null; fi
            [ -f \"\(scriptPath.path)\" ] && source \"\(scriptPath.path)\"
            """
        case .fish:
            return "" // fish never wires an rc line.
        }
    }

    /// Write the fish completion script to its standard location. Returns the installed URL.
    /// Idempotent. Kept for callers that only want fish (the GUI's legacy path delegates here).
    @discardableResult
    public static func installFishCompletion() throws -> URL {
        try install(for: .fish).scriptPath
    }
}
