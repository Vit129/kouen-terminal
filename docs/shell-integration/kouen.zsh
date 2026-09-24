# Kouen shell integration for zsh — OSC 133 semantic prompts.
#
#   Add to ~/.zshrc:   source "/path/to/kouen.zsh"
#
# Emits OSC 133;A to mark each prompt line, OSC 133;C;<base64 command> right before a command
# runs (the exact typed command, from zsh's own preexec hook — not a screen-scrape guess), and
# OSC 133;D;<exit> to report the finished command's status. Drives the prompt gutter,
# success/failure coloring, jump-between-prompts, and accurate block Copy/Re-run. Only active
# inside a Kouen terminal (the daemon exports $KOUEN).

if [[ -n "$KOUEN" && "$TERM" != "dumb" ]]; then
  autoload -Uz add-zsh-hook 2>/dev/null
  __kouen_precmd() {
    # Runs before each prompt: report the previous command's exit, then mark the new prompt.
    printf '\033]133;D;%s\007' "$?"
    printf '\033]133;A\007'
  }
  __kouen_preexec() {
    # Runs right before a typed command executes: report it (base64, so `;`/newlines in the
    # command don't collide with the OSC-133 field separator Kouen splits on).
    printf '\033]133;C;%s\007' "$(printf '%s' "$1" | base64 | tr -d '\n')"
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
