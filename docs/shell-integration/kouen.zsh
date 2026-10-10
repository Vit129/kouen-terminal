# Kouen shell integration for zsh — OSC 133 semantic prompts.
# Emits OSC 133;A to mark each prompt, OSC 133;C;<base64 command> right before a command
# runs (so Kouen knows the exact typed command, not a screen-scrape guess — this is our
# own extension to the C boundary), and OSC 133;D;<exit> to report the finished command's
# status. Drives the prompt gutter, success/failure coloring, jump-between-prompts, and
# accurate block Copy/Re-run. Active only inside a Kouen pane (the daemon exports $KOUEN).
if [[ -n "$KOUEN" && "$TERM" != "dumb" ]]; then
  autoload -Uz add-zsh-hook 2>/dev/null
  __kouen_precmd() {
    printf '\033]133;D;%s\007' "$?"
    printf '\033]133;A\007'
  }
  __kouen_preexec() {
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
    local a resume=0 rc=0
    case "$1" in
      agents|attach|auth|auto-mode|doctor|gateway|import|install|logs|mcp|plugin|plugins|project|respawn|rm|setup-token|stop|kill|ultrareview|update|upgrade) __kouen_claude_next "$@"; return ;;
    esac
    for a in "$@"; do
      case "$a" in
        -p|--print|-h|--help|-v|--version|--cloud|--remote|--teleport|--bg|--background) __kouen_claude_next "$@"; return ;;
        --remote-control|--rc) rc=1 ;;
        -r|--resume|--resume=*|-c|--continue|--from-pr|--from-pr=*) resume=1 ;;
      esac
    done
    if (( rc )); then
      /usr/bin/open -a "Google Chrome" "https://claude.ai/code" >/dev/null 2>&1 &
      /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
      if (( ${+commands[happy]} )) && [[ -f "$HOME/.happy/access.key" ]]; then HAPPY_CLAUDE_PATH="${HAPPY_CLAUDE_PATH:-${commands[claude]}}" happy claude "$@"; else __kouen_claude_next "$@"; fi
      return
    fi
    if [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud && $resume -eq 0 ]]; then
      __kouen_claude_next --cloud "$@"
    elif [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud || "$KOUEN_CLAUDE_SESSION_MODE" == remote-control ]]; then
      if [[ "$KOUEN_CLAUDE_SESSION_MODE" == remote-control ]]; then
        /usr/bin/open -a "Google Chrome" "https://claude.ai/code" >/dev/null 2>&1 &
        /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
      fi
      if (( ${+commands[happy]} )) && [[ -f "$HOME/.happy/access.key" ]]; then
        HAPPY_CLAUDE_PATH="${HAPPY_CLAUDE_PATH:-${commands[claude]}}" happy claude --remote-control --remote-control-session-name-prefix kouen "$@"
      else
        __kouen_claude_next --remote-control --remote-control-session-name-prefix kouen "$@"
      fi
    elif [[ "$KOUEN_CLAUDE_SESSION_MODE" == happy ]] && (( ${+commands[happy]} )); then
      HAPPY_CLAUDE_PATH="${HAPPY_CLAUDE_PATH:-${commands[claude]}}" happy claude --remote-control --remote-control-session-name-prefix kouen "$@"
    else
      __kouen_claude_next "$@"
    fi
  }
fi
# Codex session mode: a `codex` typed by hand runs through Happy when $KOUEN_CODEX_SESSION_MODE is `happy` or `remote-control` with Happy logged in.
if [[ -n "$KOUEN" && ("$KOUEN_CODEX_SESSION_MODE" == "happy" || "$KOUEN_CODEX_SESSION_MODE" == "remote-control") && -z "$__kouen_codex_wrapped" ]]; then
  __kouen_codex_wrapped=1
  if (( ${+functions[codex]} )); then
    functions[__kouen_codex_next]=$functions[codex]
  else
    __kouen_codex_next() { command codex "$@"; }
  fi
  codex() {
    local a rc=0
    case "$1" in
      agents|exec|e|review|login|logout|mcp|plugin|app-server|remote-control|app|completion|update|doctor|sandbox|debug|apply|a|resume|queue|archive|delete|migrate-rollouts|unarchive|fork|cloud|exec-server|features|help) __kouen_codex_next "$@"; return ;;
    esac
    for a in "$@"; do
      case "$a" in
        -h|--help|-V|--version) __kouen_codex_next "$@"; return ;;
        --remote-control|--rc) rc=1 ;;
      esac
    done
    if [[ "$KOUEN_CODEX_SESSION_MODE" == "remote-control" || $rc -eq 1 ]]; then
      /usr/bin/open -a "Google Chrome" "https://chatgpt.com" >/dev/null 2>&1 &
      /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
    fi
    if (( ${+commands[happy]} )) && [[ -f "$HOME/.happy/access.key" ]]; then happy codex "$@"; else __kouen_codex_next "$@"; fi
  }
fi
# Antigravity (agy) session mode: a `agy` typed by hand gets --remote-control, or happy agy when in happy mode.
if [[ -n "$KOUEN" && ("$KOUEN_AGY_SESSION_MODE" == "remote-control" || "$KOUEN_AGY_SESSION_MODE" == "happy") && -z "$__kouen_agy_wrapped" ]]; then
  __kouen_agy_wrapped=1
  if (( ${+functions[agy]} )); then
    functions[__kouen_agy_next]=$functions[agy]
  else
    __kouen_agy_next() { command agy "$@"; }
  fi
  agy() {
    local a n=0 rc=0
    case "$1" in
      auth|config|doctor|help|remote-control|status|update|version) __kouen_agy_next "$@"; return ;;
    esac
    for a in "$@"; do
      case "$a" in
        -h|--help|-v|--version) __kouen_agy_next "$@"; return ;;
        --remote-control|--rc) rc=1 ;;
        *) n=$((n+1)) ;;
      esac
    done
    if [[ "$KOUEN_AGY_SESSION_MODE" == "remote-control" || $rc -eq 1 ]]; then
      /usr/bin/open -a "Google Chrome" "https://antigravity.google.com" >/dev/null 2>&1 &
      /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
    fi
    if (( ${+commands[happy]} )) && [[ "$KOUEN_AGY_SESSION_MODE" == "happy" ]]; then happy agy "$@"; return; fi
    if (( rc )); then __kouen_agy_next "$@"; else __kouen_agy_next --remote-control "$@"; fi
  }
fi
# GitHub Copilot session mode: a `copilot` typed by hand gets --remote when in remote-control mode ($KOUEN_COPILOT_SESSION_MODE), or happy acp when happy.
if [[ -n "$KOUEN" && ("$KOUEN_COPILOT_SESSION_MODE" == "remote-control" || "$KOUEN_COPILOT_SESSION_MODE" == "happy") && -z "$__kouen_copilot_wrapped" ]]; then
  __kouen_copilot_wrapped=1
  if (( ${+functions[copilot]} )); then
    functions[__kouen_copilot_next]=$functions[copilot]
  else
    __kouen_copilot_next() { command copilot "$@"; }
  fi
  copilot() {
    local a n=0 rc=0
    case "$1" in
      auth|config|help|login|logout|status|version) __kouen_copilot_next "$@"; return ;;
    esac
    for a in "$@"; do
      case "$a" in
        -h|--help|-v|--version) __kouen_copilot_next "$@"; return ;;
        --remote) rc=1 ;;
      esac
    done
    if (( ${+commands[happy]} )) && [[ "$KOUEN_COPILOT_SESSION_MODE" == "happy" ]]; then happy acp -- copilot --acp "$@"; return; fi
    if (( rc )); then __kouen_copilot_next "$@"; else __kouen_copilot_next --remote "$@"; fi
  }
fi
# Hermes session mode: a `hermes` typed by hand gets --remote when in remote-control mode ($KOUEN_HERMES_SESSION_MODE).
if [[ -n "$KOUEN" && "$KOUEN_HERMES_SESSION_MODE" == "remote-control" && -z "$__kouen_hermes_wrapped" ]]; then
  __kouen_hermes_wrapped=1
  if (( ${+functions[hermes]} )); then
    functions[__kouen_hermes_next]=$functions[hermes]
  else
    __kouen_hermes_next() { command hermes "$@"; }
  fi
  hermes() {
    case "$1" in
      auth|config|help|login|status|version) __kouen_hermes_next "$@"; return ;;
    esac
    for a in "$@"; do
      case "$a" in
        -h|--help|-v|--version|--remote) __kouen_hermes_next "$@"; return ;;
      esac
    done
    __kouen_hermes_next --remote "$@"
  }
fi
# Kouen CLI wrapper: `kouen` command that supports `rc`/`--rc` to auto-open Chrome
# and delegates any other commands to `kouen-cli`.
if [[ -n "$KOUEN" && -z "$__kouen_cli_wrapped" ]]; then
  __kouen_cli_wrapped=1
  if (( ${+functions[kouen]} )); then
    functions[__kouen_next]=$functions[kouen]
  else
    __kouen_next() {
      if (( ${+commands[kouen-cli]} )); then
        command kouen-cli "$@"
      elif [[ -n "$KOUEN_CLI" && -x "$KOUEN_CLI" ]]; then
        "$KOUEN_CLI" "$@"
      elif [[ -x "$HOME/Library/Application Support/Kouen/bin/kouen-cli" ]]; then
        "$HOME/Library/Application Support/Kouen/bin/kouen-cli" "$@"
      else
        echo "kouen-cli: command not found" >&2
        return 1
      fi
    }
  fi
  kouen() {
    local a rc=0
    if [[ "$1" == "rc" || "$1" == "companion" ]]; then
      rc=1
    fi
    for a in "$@"; do
      case "$a" in
        --rc|--remote-control) rc=1 ;;
      esac
    done
    if (( rc )); then
      export KOUEN_RC_OPENED=1
      /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
    fi
    __kouen_next "$@"
  }
fi