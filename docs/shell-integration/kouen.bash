# Kouen shell integration for bash — OSC 133 semantic prompts.
#
#   Add to ~/.bashrc:   source "/path/to/kouen.bash"
#
# Emits OSC 133;A to mark each prompt line and OSC 133;D;<exit> to report the previous
# command's status, so Kouen can draw the prompt gutter, color success/failure, and
# jump between prompts. Only active inside a Kouen terminal (the daemon exports $KOUEN).

if [ -n "$KOUEN" ] && [ "$TERM" != "dumb" ]; then
  __kouen_precmd() {
    # Report the just-finished command's exit status (runs before the new prompt).
    printf '\001\033]133;D;%s\007\002' "$?"
  }
  case ";${PROMPT_COMMAND};" in
    *";__kouen_precmd;"*) : ;;                                   # already installed
    *) PROMPT_COMMAND="__kouen_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
  # Mark the start of the prompt itself (wrapped in \[ \] so it has zero display width).
  case "$PS1" in
    *'133;A'*) : ;;                                                # already installed
    *) PS1='\[\033]133;A\007\]'"$PS1" ;;
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
