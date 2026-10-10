# Kouen shell integration for bash — OSC 133 semantic prompts.
# Emits OSC 133;A to mark each prompt and OSC 133;D;<exit> to report the previous command's
# status, so Kouen draws the prompt gutter, colors success/failure, and jumps between
# prompts. Active only inside a Kouen pane (the daemon exports $KOUEN).
if [ -n "$KOUEN" ] && [ "$TERM" != "dumb" ]; then
  __kouen_precmd() {
    printf '\001\033]133;D;%s\007\002' "$?"
  }
  case ";${PROMPT_COMMAND};" in
    *";__kouen_precmd;"*) : ;;
    *) PROMPT_COMMAND="__kouen_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
  case "$PS1" in
    *'133;A'*) : ;;
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
      if command -v happy >/dev/null 2>&1 && [ -f "$HOME/.happy/access.key" ]; then HAPPY_CLAUDE_PATH="${HAPPY_CLAUDE_PATH:-$(type -P claude)}" happy claude "$@"; else __kouen_claude_next "$@"; fi
      return
    fi
    if [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud && $resume -eq 0 ]]; then
      __kouen_claude_next --cloud "$@"
    elif [[ "$KOUEN_CLAUDE_SESSION_MODE" == cloud || "$KOUEN_CLAUDE_SESSION_MODE" == remote-control ]]; then
      if [[ "$KOUEN_CLAUDE_SESSION_MODE" == remote-control ]]; then
        /usr/bin/open -a "Google Chrome" "https://claude.ai/code" >/dev/null 2>&1 &
        /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
      fi
      if command -v happy >/dev/null 2>&1 && [ -f "$HOME/.happy/access.key" ]; then
        HAPPY_CLAUDE_PATH="${HAPPY_CLAUDE_PATH:-$(type -P claude)}" happy claude --remote-control --remote-control-session-name-prefix kouen "$@"
      else
        __kouen_claude_next --remote-control --remote-control-session-name-prefix kouen "$@"
      fi
    elif [[ "$KOUEN_CLAUDE_SESSION_MODE" == happy ]] && command -v happy >/dev/null 2>&1; then
      HAPPY_CLAUDE_PATH="${HAPPY_CLAUDE_PATH:-$(type -P claude)}" happy claude --remote-control --remote-control-session-name-prefix kouen "$@"
    else
      __kouen_claude_next "$@"
    fi
  }
fi
# Codex session mode: a `codex` typed by hand runs through Happy when $KOUEN_CODEX_SESSION_MODE is `happy` or `remote-control` with Happy logged in.
if [ -n "$KOUEN" ] && ([ "$KOUEN_CODEX_SESSION_MODE" = "happy" ] || [ "$KOUEN_CODEX_SESSION_MODE" = "remote-control" ]) && [ -z "$__kouen_codex_wrapped" ]; then
  __kouen_codex_wrapped=1
  if declare -F codex >/dev/null 2>&1; then
    eval "$(declare -f codex | sed '1s/^codex /__kouen_codex_next /')"
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
    if command -v happy >/dev/null 2>&1 && [ -f "$HOME/.happy/access.key" ]; then happy codex "$@"; else __kouen_codex_next "$@"; fi
  }
fi
# Antigravity (agy) session mode: a `agy` typed by hand gets --remote-control, or happy agy when in happy mode.
if [ -n "$KOUEN" ] && ([ "$KOUEN_AGY_SESSION_MODE" = "remote-control" ] || [ "$KOUEN_AGY_SESSION_MODE" = "happy" ]) && [ -z "$__kouen_agy_wrapped" ]; then
  __kouen_agy_wrapped=1
  if declare -F agy >/dev/null 2>&1; then
    eval "$(declare -f agy | sed '1s/^agy /__kouen_agy_next /')"
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
    if command -v happy >/dev/null 2>&1 && [[ "$KOUEN_AGY_SESSION_MODE" == "happy" ]]; then happy agy "$@"; return; fi
    if (( rc )); then __kouen_agy_next "$@"; else __kouen_agy_next --remote-control "$@"; fi
  }
fi
# GitHub Copilot session mode: a `copilot` typed by hand gets --remote when in remote-control mode ($KOUEN_COPILOT_SESSION_MODE), or happy acp when happy.
if [ -n "$KOUEN" ] && ([ "$KOUEN_COPILOT_SESSION_MODE" = "remote-control" ] || [ "$KOUEN_COPILOT_SESSION_MODE" = "happy" ]) && [ -z "$__kouen_copilot_wrapped" ]; then
  __kouen_copilot_wrapped=1
  if declare -F copilot >/dev/null 2>&1; then
    eval "$(declare -f copilot | sed '1s/^copilot /__kouen_copilot_next /')"
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
    if command -v happy >/dev/null 2>&1 && [[ "$KOUEN_COPILOT_SESSION_MODE" == "happy" ]]; then happy acp -- copilot --acp "$@"; return; fi
    if (( rc )); then __kouen_copilot_next "$@"; else __kouen_copilot_next --remote "$@"; fi
  }
fi
# Hermes session mode
if [ -n "$KOUEN" ] && [ "$KOUEN_HERMES_SESSION_MODE" = "remote-control" ] && [ -z "$__kouen_hermes_wrapped" ]; then
  __kouen_hermes_wrapped=1
  if declare -F hermes >/dev/null 2>&1; then
    eval "$(declare -f hermes | sed '1s/^hermes /__kouen_hermes_next /')"
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
if [ -n "$KOUEN" ] && [ -z "$__kouen_cli_wrapped" ]; then
  __kouen_cli_wrapped=1
  if declare -F kouen >/dev/null 2>&1; then
    eval "$(declare -f kouen | sed '1s/^kouen /__kouen_next /')"
  else
    __kouen_next() {
      if command -v kouen-cli >/dev/null 2>&1; then
        command kouen-cli "$@"
      elif [ -n "$KOUEN_CLI" ] && [ -x "$KOUEN_CLI" ]; then
        "$KOUEN_CLI" "$@"
      elif [ -x "$HOME/Library/Application Support/Kouen/bin/kouen-cli" ]; then
        "$HOME/Library/Application Support/Kouen/bin/kouen-cli" "$@"
      else
        echo "kouen-cli: command not found" >&2
        return 1
      fi
    }
  fi
  kouen() {
    local a rc=0
    if [ "$1" = "rc" ] || [ "$1" = "companion" ]; then
      rc=1
    fi
    for a in "$@"; do
      case "$a" in
        --rc|--remote-control) rc=1 ;;
      esac
    done
    if [ $rc -eq 1 ]; then
      export KOUEN_RC_OPENED=1
      /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
    fi
    __kouen_next "$@"
  }
fi