import Foundation

/// Auto-injected shell integration (OSC 133 prompt marks) at spawn — Ghostty's "it just
/// works" behavior, without touching the user's rc files. The daemon owns the spawn
/// environment, so each shell gets its standard injection vehicle:
///
/// - **zsh** — `ZDOTDIR` shim: a directory whose `.zshenv` restores the user's real
///   `ZDOTDIR`, chains to their own `.zshenv`, then sources the integration for
///   interactive shells only.
/// - **bash** — the `--posix` + `$ENV` technique (kitty/Ghostty lineage): POSIX-mode
///   interactive bash reads only `$ENV`, so the shim un-posixes, replays the startup
///   files a normal bash would have read (login files when `HARNESS_BASH_LOGIN` is set,
///   `.bashrc` otherwise), then sources the integration. Known cost, stated loudly:
///   `shopt -q login_shell` reports off inside the pane.
/// - **fish** — `XDG_DATA_DIRS` vendor dir: fish sources
///   `<dir>/fish/vendor_conf.d/*.fish` from every data dir, so prepending ours injects
///   without touching user config.
///
/// Idempotent against a manual `install-shell-integration`: the snippets guard their own
/// re-registration (zsh `add-zsh-hook` dedupes, bash pattern-checks `PROMPT_COMMAND`/`PS1`,
/// fish replaces same-named event functions). Never active for non-interactive shells —
/// each vehicle is interactive-gated by construction AND the shims re-check. Opt out with
/// `set-option shell-integration off` (applies to subsequently spawned panes).
public enum ShellIntegrationInjector {
    /// What a spawn must change to carry the injection. `environment` merges over the
    /// inherited process env (and under the user's `set-environment` table, which always
    /// wins); `argumentsOverride` replaces the shell's launch arguments when non-nil.
    public struct Plan: Sendable, Equatable {
        public var environment: [String: String]
        public var argumentsOverride: [String]?
    }

    /// Build (and lay down on disk, idempotently) the injection for `shellPath`, or nil
    /// for shells without a vehicle (the pane still works; integration is just manual).
    /// `baseEnvironment` is the environment the child would otherwise inherit — the zsh
    /// shim needs the user's original `ZDOTDIR` and fish needs the existing
    /// `XDG_DATA_DIRS` to chain correctly.
    public static func plan(
        shellPath: String,
        baseEnvironment: [String: String],
        home: URL = HarnessPaths.applicationSupport
    ) -> Plan? {
        guard let shell = ShellIntegration.Shell.detect(from: shellPath) else { return nil }
        let root = home.appendingPathComponent("shell-integration", isDirectory: true)
        do {
            switch shell {
            case .zsh:
                let script = try writeIntegrationScript(.zsh, root: root)
                let zdotdir = root.appendingPathComponent("zdotdir", isDirectory: true)
                try writeIfChanged(zshShim(scriptPath: script.path), to: zdotdir.appendingPathComponent(".zshenv"))
                var env = ["ZDOTDIR": zdotdir.path]
                if let original = baseEnvironment["ZDOTDIR"], !original.isEmpty {
                    env["HARNESS_ORIG_ZDOTDIR"] = original
                }
                return Plan(environment: env, argumentsOverride: nil)
            case .bash:
                let script = try writeIntegrationScript(.bash, root: root)
                let shim = root.appendingPathComponent("bash-shim.sh")
                try writeIfChanged(bashShim(scriptPath: script.path), to: shim)
                return Plan(
                    environment: ["ENV": shim.path, "HARNESS_BASH_LOGIN": "1"],
                    // Replaces the profile's `-l`: POSIX-mode non-login interactive bash
                    // reads exactly `$ENV`; the shim replays the login files itself.
                    argumentsOverride: ["--posix"]
                )
            case .fish:
                let dataDir = root.appendingPathComponent("fish-xdg", isDirectory: true)
                let vendorDir = dataDir.appendingPathComponent("fish/vendor_conf.d", isDirectory: true)
                try writeIfChanged(ShellIntegration.script(for: .fish),
                                   to: vendorDir.appendingPathComponent("harness.fish"))
                let existing = baseEnvironment["XDG_DATA_DIRS"].flatMap { $0.isEmpty ? nil : $0 }
                    ?? "/usr/local/share:/usr/share" // the XDG spec default, preserved for other vendors
                return Plan(
                    environment: ["XDG_DATA_DIRS": "\(dataDir.path):\(existing)"],
                    argumentsOverride: nil
                )
            }
        } catch {
            // Injection is best-effort sugar: a full disk / unwritable home must never
            // stop a pane from spawning. The pane just runs without prompt marks.
            return nil
        }
    }

    /// The canonical integration script on disk (same location the manual installer
    /// uses, so both paths share one file).
    private static func writeIntegrationScript(_ shell: ShellIntegration.Shell, root: URL) throws -> URL {
        let url = root.appendingPathComponent("harness.\(shell.rawValue)")
        try writeIfChanged(ShellIntegration.script(for: shell), to: url)
        return url
    }

    /// Idempotent write: spawn-time injection runs per pane, so skip the disk write when
    /// the content already matches (the common case after the first spawn).
    private static func writeIfChanged(_ content: String, to url: URL) throws {
        if let existing = try? String(contentsOf: url, encoding: .utf8), existing == content { return }
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(content.utf8).write(to: url, options: .atomic)
    }

    /// The `.zshenv` shim. zsh re-resolves `$ZDOTDIR` per startup file, so restoring it
    /// here makes `.zprofile`/`.zshrc`/`.zlogin` load from the user's real location.
    static func zshShim(scriptPath: String) -> String {
        """
        # Harness shell-integration shim (auto-injected via ZDOTDIR).
        # Restores your real ZDOTDIR, chains to your own .zshenv, then loads the OSC 133
        # integration for interactive shells only.
        # Opt out: harness-cli set-option shell-integration off
        if [[ -n "${HARNESS_ORIG_ZDOTDIR-}" ]]; then
          export ZDOTDIR="$HARNESS_ORIG_ZDOTDIR"
          unset HARNESS_ORIG_ZDOTDIR
        else
          unset ZDOTDIR
        fi
        if [[ -f "${ZDOTDIR:-$HOME}/.zshenv" ]]; then
          builtin source "${ZDOTDIR:-$HOME}/.zshenv"
        fi
        if [[ -o interactive && -f "\(scriptPath)" ]]; then
          builtin source "\(scriptPath)"
        fi
        """
    }

    /// The `$ENV` shim for `bash --posix`. POSIX-mode interactive bash reads only `$ENV`,
    /// so this replays normal startup (login files under `HARNESS_BASH_LOGIN`, otherwise
    /// the interactive rc chain) before loading the integration.
    static func bashShim(scriptPath: String) -> String {
        """
        # Harness shell-integration shim (auto-injected via ENV under `bash --posix`).
        # Replays the startup files a normal bash would have read, then loads the OSC 133
        # integration for interactive shells.
        # Opt out: harness-cli set-option shell-integration off
        builtin set +o posix
        builtin unset ENV
        if [ -n "${HARNESS_BASH_LOGIN-}" ]; then
          builtin unset HARNESS_BASH_LOGIN
          [ -r /etc/profile ] && builtin source /etc/profile
          for __harness_rc in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile"; do
            if [ -r "$__harness_rc" ]; then
              builtin source "$__harness_rc"
              break
            fi
          done
          builtin unset __harness_rc
        else
          [ -r /etc/bash.bashrc ] && builtin source /etc/bash.bashrc
          [ -r "$HOME/.bashrc" ] && builtin source "$HOME/.bashrc"
        fi
        case "$-" in
          *i*) [ -r "\(scriptPath)" ] && builtin source "\(scriptPath)" ;;
        esac
        """
    }
}
