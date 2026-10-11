# Harness shell integration for bash — OSC 133 semantic prompts.
# A/B bracket the rendered prompt; C starts output; D reports command status.
# Active only inside a Harness pane (the daemon exports $HARNESS).
if [ -n "$HARNESS" ] && [ "$TERM" != "dumb" ]; then
  __harness_precmd() {
    local __harness_status=$?
    printf '\033]133;D;%s\007' "$__harness_status"
    return "$__harness_status"
  }
  __harness_wrap_prompt() {
    local __harness_status=$?
    case "$PS1" in
      *'133;A'*) : ;;
      *) PS1='\[\033]133;A\007\]'"$PS1" ;;
    esac
    case "$PS1" in
      *'133;B'*) : ;;
      *) PS1="$PS1"'\[\033]133;B\007\]' ;;
    esac
    return "$__harness_status"
  }
  __harness_pc_decl=$(declare -p PROMPT_COMMAND 2>/dev/null)
  if [[ "$__harness_pc_decl" == "declare -a "* ]]; then
    __harness_pc_found=0
    for __harness_pc_item in "${PROMPT_COMMAND[@]}"; do
      [[ "$__harness_pc_item" == __harness_precmd ]] && __harness_pc_found=1
    done
    if [[ "$__harness_pc_found" == 0 ]]; then
      PROMPT_COMMAND=(__harness_precmd "${PROMPT_COMMAND[@]}" __harness_wrap_prompt)
    fi
    unset __harness_pc_found __harness_pc_item
  else
    case ";${PROMPT_COMMAND};" in
      *";__harness_precmd;"*) : ;;
      *) PROMPT_COMMAND="__harness_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND};__harness_wrap_prompt" ;;
    esac
  fi
  unset __harness_pc_decl
  # Bash >= 4.4 provides PS0 before command output without replacing DEBUG traps.
  if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )); then
    case "$PS0" in
      *'133;C'*) : ;;
      *) PS0=$'\033]133;C\007'"$PS0" ;;
    esac
  fi
  __harness_wrap_prompt
fi
