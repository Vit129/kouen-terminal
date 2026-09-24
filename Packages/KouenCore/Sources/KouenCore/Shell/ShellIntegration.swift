import Foundation

/// OSC 133 shell integration: the per-shell scripts that emit semantic prompt marks (`133;A`)
/// and command-finished status (`133;D;<exit>`), plus an installer that drops the script under
/// the Kouen home and wires a `source` line into the user's shell rc — idempotently, backing
/// the rc up first. These scripts are the runtime source of truth (the copies under
/// `docs/shell-integration/` mirror them for reading); the daemon exports `$KOUEN`, which they
/// gate on, so they activate only inside a Kouen pane.
public enum ShellIntegration {
    public enum Shell: String, CaseIterable, Sendable {
        case bash, zsh, fish

        /// Resolve a shell path or name (`/bin/zsh`, `zsh`, `-fish`) to a known shell.
        public static func detect(from shellPath: String) -> Shell? {
            let name = (shellPath as NSString).lastPathComponent
                .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
            switch name {
            case "bash": return .bash
            case "zsh": return .zsh
            case "fish": return .fish
            default: return nil
            }
        }
    }

    public struct InstallResult: Sendable, Equatable {
        /// Where the script was written.
        public let scriptPath: URL
        /// The rc file the source line was added to.
        public let rcPath: URL
        /// The exact line wired into the rc (for display).
        public let sourceLine: String
        /// True when the rc already had the integration (nothing appended this run).
        public let alreadyWired: Bool
        /// Backup of the rc if one was made before editing it.
        public let rcBackedUp: URL?
    }

    /// The script body for a shell — the runtime source of truth.
    public static func script(for shell: Shell) -> String {
        switch shell {
        case .zsh: return zshScript
        case .bash: return bashScript
        case .fish: return fishScript
        }
    }

    /// The file the script is written to under the Kouen home.
    public static func scriptURL(for shell: Shell) -> URL {
        KouenPaths.applicationSupport
            .appendingPathComponent("shell-integration", isDirectory: true)
            .appendingPathComponent("kouen.\(shell.rawValue)")
    }

    /// The conventional rc file for a shell (honoring `$ZDOTDIR` for zsh).
    public static func rcURL(for shell: Shell, homeOverride: URL? = nil) -> URL {
        let home = homeOverride ?? FileManager.default.homeDirectoryForCurrentUser
        switch shell {
        case .bash: return home.appendingPathComponent(".bashrc")
        case .zsh:
            if let zdot = ProcessInfo.processInfo.environment["ZDOTDIR"], !zdot.isEmpty, homeOverride == nil {
                return URL(fileURLWithPath: (zdot as NSString).expandingTildeInPath)
                    .appendingPathComponent(".zshrc")
            }
            return home.appendingPathComponent(".zshrc")
        case .fish: return home.appendingPathComponent(".config/fish/config.fish")
        }
    }

    private static let markerBegin = "# >>> Kouen shell integration >>>"
    private static let markerEnd = "# <<< Kouen shell integration <<<"

    /// Write the script under the Kouen home and wire a guarded `source` line into the shell's
    /// rc. Idempotent (a marker block guards against duplicate appends) and the rc is backed up
    /// before the first edit. Creating the rc (and `~/.config/fish/`) if absent.
    @discardableResult
    public static func install(_ shell: Shell, homeOverride: URL? = nil) throws -> InstallResult {
        let scriptURL = homeOverride.map {
            $0.appendingPathComponent("Library/Application Support/Kouen/shell-integration/kouen.\(shell.rawValue)")
        } ?? scriptURL(for: shell)
        try FileManager.default.createDirectory(at: scriptURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(script(for: shell).utf8).write(to: scriptURL, options: .atomic)

        let rc = rcURL(for: shell, homeOverride: homeOverride)
        let sourceLine = sourceLine(for: shell, scriptPath: scriptURL)
        let wired = try ShellRCWiring.wire(into: rc, begin: markerBegin, end: markerEnd, body: sourceLine)
        return InstallResult(scriptPath: scriptURL, rcPath: rc, sourceLine: sourceLine,
                             alreadyWired: wired.alreadyWired, rcBackedUp: wired.backedUp)
    }

    /// The `source` line for a shell (fish has no `[ -f ]` test syntax).
    public static func sourceLine(for shell: Shell, scriptPath: URL) -> String {
        switch shell {
        case .bash, .zsh: return "[ -f \"\(scriptPath.path)\" ] && source \"\(scriptPath.path)\""
        case .fish: return "test -f \"\(scriptPath.path)\"; and source \"\(scriptPath.path)\""
        }
    }

    // MARK: - Scripts (runtime source of truth; docs/shell-integration/ mirrors these)

    private static let zshScript = """
    # Kouen shell integration for zsh — OSC 133 semantic prompts.
    # Emits OSC 133;A to mark each prompt, OSC 133;C;<base64 command> right before a command
    # runs (so Kouen knows the exact typed command, not a screen-scrape guess — this is our
    # own extension to the C boundary), and OSC 133;D;<exit> to report the finished command's
    # status. Drives the prompt gutter, success/failure coloring, jump-between-prompts, and
    # accurate block Copy/Re-run. Active only inside a Kouen pane (the daemon exports $KOUEN).
    if [[ -n "$KOUEN" && "$TERM" != "dumb" ]]; then
      autoload -Uz add-zsh-hook 2>/dev/null
      __kouen_precmd() {
        printf '\\033]133;D;%s\\007' "$?"
        printf '\\033]133;A\\007'
      }
      __kouen_preexec() {
        printf '\\033]133;C;%s\\007' "$(printf '%s' "$1" | base64 | tr -d '\\n')"
      }
      if (( ${+functions[add-zsh-hook]} )); then
        add-zsh-hook precmd __kouen_precmd
        add-zsh-hook preexec __kouen_preexec
      else
        precmd_functions+=(__kouen_precmd)
        preexec_functions+=(__kouen_preexec)
      fi
    fi
    # Claude Code session mode: a `claude` typed by hand gets the same --remote-control/--cloud
    # flags as a Kouen-launched one ($KOUEN_CLAUDE_SESSION_MODE, exported by the daemon). Wraps an
    # existing `claude` function rather than replacing it; `command claude` bypasses both. Flags
    # the user already passed (--cloud, --remote-control, -p, --teleport, subcommands) win.
    if [[ -n "$KOUEN" && -n "$KOUEN_CLAUDE_SESSION_MODE" && -z "$__kouen_claude_wrapped" ]]; then
      __kouen_claude_wrapped=1
      if (( ${+functions[claude]} )); then
        functions[__kouen_claude_next]=$functions[claude]
      else
        __kouen_claude_next() { command claude "$@"; }
      fi
      claude() {
        local a resume=0
        case "$1" in
          agents|attach|auth|auto-mode|doctor|gateway|import|install|logs|mcp|plugin|plugins|project|respawn|rm|setup-token|stop|kill|ultrareview|update|upgrade) __kouen_claude_next "$@"; return ;;
        esac
        for a in "$@"; do
          case "$a" in
            -p|--print|-h|--help|-v|--version|--cloud|--remote|--remote-control|--rc|--teleport|--bg|--background) __kouen_claude_next "$@"; return ;;
            -r|--resume|--resume=*|-c|--continue|--from-pr|--from-pr=*) resume=1 ;;
          esac
        done
        if [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud && $resume -eq 0 ]]; then
          __kouen_claude_next --cloud "$@"
        elif [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud || "$KOUEN_CLAUDE_SESSION_MODE" == remote-control ]]; then
          __kouen_claude_next --remote-control --remote-control-session-name-prefix kouen "$@"
        else
          __kouen_claude_next "$@"
        fi
      }
    fi
    """

    // ponytail: bash has no native preexec hook (only the DEBUG trap, which fires per
    // simple-command in a pipeline and needs a PROMPT_COMMAND/COMP_LINE reentrancy guard to be
    // safe to source into every bash user's rc) — deferred, so bash panes get A+D only (prompt
    // gutter + exit color) and Re-run/block-command-text falls back to the prior regex-strip.
    // Ceiling: add a guarded DEBUG trap (the bash-preexec pattern) emitting 133;C;<base64> like
    // zsh/fish do, once that guard has its own test coverage.
    private static let bashScript = """
    # Kouen shell integration for bash — OSC 133 semantic prompts.
    # Emits OSC 133;A to mark each prompt and OSC 133;D;<exit> to report the previous command's
    # status, so Kouen draws the prompt gutter, colors success/failure, and jumps between
    # prompts. Active only inside a Kouen pane (the daemon exports $KOUEN).
    if [ -n "$KOUEN" ] && [ "$TERM" != "dumb" ]; then
      __kouen_precmd() {
        printf '\\001\\033]133;D;%s\\007\\002' "$?"
      }
      case ";${PROMPT_COMMAND};" in
        *";__kouen_precmd;"*) : ;;
        *) PROMPT_COMMAND="__kouen_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
      esac
      case "$PS1" in
        *'133;A'*) : ;;
        *) PS1='\\[\\033]133;A\\007\\]'"$PS1" ;;
      esac
    fi
    # Claude Code session mode: a `claude` typed by hand gets the same --remote-control/--cloud
    # flags as a Kouen-launched one ($KOUEN_CLAUDE_SESSION_MODE, exported by the daemon). Wraps an
    # existing `claude` function rather than replacing it; `command claude` bypasses both. Flags
    # the user already passed (--cloud, --remote-control, -p, --teleport, subcommands) win.
    if [ -n "$KOUEN" ] && [ -n "$KOUEN_CLAUDE_SESSION_MODE" ] && [ -z "$__kouen_claude_wrapped" ]; then
      __kouen_claude_wrapped=1
      if declare -F claude >/dev/null 2>&1; then
        eval "$(declare -f claude | sed '1s/^claude /__kouen_claude_next /')"
      else
        __kouen_claude_next() { command claude "$@"; }
      fi
      claude() {
        local a resume=0
        case "$1" in
          agents|attach|auth|auto-mode|doctor|gateway|import|install|logs|mcp|plugin|plugins|project|respawn|rm|setup-token|stop|kill|ultrareview|update|upgrade) __kouen_claude_next "$@"; return ;;
        esac
        for a in "$@"; do
          case "$a" in
            -p|--print|-h|--help|-v|--version|--cloud|--remote|--remote-control|--rc|--teleport|--bg|--background) __kouen_claude_next "$@"; return ;;
            -r|--resume|--resume=*|-c|--continue|--from-pr|--from-pr=*) resume=1 ;;
          esac
        done
        if [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud && $resume -eq 0 ]]; then
          __kouen_claude_next --cloud "$@"
        elif [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud || "$KOUEN_CLAUDE_SESSION_MODE" == remote-control ]]; then
          __kouen_claude_next --remote-control --remote-control-session-name-prefix kouen "$@"
        else
          __kouen_claude_next "$@"
        fi
      }
    fi
    """

    private static let fishScript = """
    # Kouen shell integration for fish — OSC 133 semantic prompts.
    # Emits OSC 133;A to mark each prompt, OSC 133;C;<base64 command> right before a command
    # runs (so Kouen knows the exact typed command, not a screen-scrape guess — this is our
    # own extension to the C boundary), and OSC 133;D;<exit> to report the finished command's
    # status. Drives the prompt gutter, success/failure coloring, jump-between-prompts, and
    # accurate block Copy/Re-run. Active only inside a Kouen pane (the daemon exports $KOUEN).
    if set -q KOUEN; and test "$TERM" != dumb
        function __kouen_osc133_prompt --on-event fish_prompt
            printf '\\033]133;A\\007'
        end
        function __kouen_osc133_preexec --on-event fish_preexec
            # base64 may wrap output across lines; command substitution splits on newlines,
            # so re-join the captured list before emitting a single OSC payload.
            set -l encoded (echo -n "$argv[1]" | base64)
            printf '\\033]133;C;%s\\007' (string join '' $encoded)
        end
        function __kouen_osc133_postexec --on-event fish_postexec
            printf '\\033]133;D;%s\\007' $status
        end
    end
    # Claude Code session mode: a `claude` typed by hand gets the same --remote-control/--cloud
    # flags as a Kouen-launched one ($KOUEN_CLAUDE_SESSION_MODE, exported by the daemon). Wraps an
    # existing `claude` function rather than replacing it; `command claude` bypasses both. Flags
    # the user already passed (--cloud, --remote-control, -p, --teleport, subcommands) win.
    if set -q KOUEN; and set -q KOUEN_CLAUDE_SESSION_MODE; and not set -q __kouen_claude_wrapped
        set -g __kouen_claude_wrapped 1
        if functions -q claude
            functions -c claude __kouen_claude_next
        else
            function __kouen_claude_next
                command claude $argv
            end
        end
        function claude
            switch "$argv[1]"
                case agents attach auth auto-mode doctor gateway import install logs mcp plugin plugins project respawn rm setup-token stop kill ultrareview update upgrade
                    __kouen_claude_next $argv; return
            end
            set -l resume 0
            for a in $argv
                switch $a
                    case -p --print -h --help -v --version --cloud --remote --remote-control --rc --teleport --bg --background
                        __kouen_claude_next $argv; return
                    case -r --resume '--resume=*' -c --continue --from-pr '--from-pr=*'
                        set resume 1
                end
            end
            if test "$KOUEN_CLAUDE_SESSION_MODE" = cloud; and test $resume -eq 0
                __kouen_claude_next --cloud $argv
            else if test "$KOUEN_CLAUDE_SESSION_MODE" = cloud; or test "$KOUEN_CLAUDE_SESSION_MODE" = remote-control
                __kouen_claude_next --remote-control --remote-control-session-name-prefix kouen $argv
            else
                __kouen_claude_next $argv
            end
        end
    end
    """
}
