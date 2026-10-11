# Harness shell integration for zsh — OSC 133 semantic prompts.
# A/B bracket the rendered prompt; C starts output; D reports command status.
# Active only inside a Harness pane (the daemon exports $HARNESS).
if [[ -n "$HARNESS" && "$TERM" != "dumb" ]]; then
  autoload -Uz add-zsh-hook 2>/dev/null
  __harness_precmd() {
    local __harness_status=$?
    printf '\033]133;D;%s\007' "$__harness_status"
    case "$PS1" in
      *'133;A'*) ;;
      *) PS1=$'%{\033]133;A\007%}'"$PS1" ;;
    esac
    case "$PS1" in
      *'133;B'*) ;;
      *) PS1="$PS1"$'%{\033]133;B\007%}' ;;
    esac
    return "$__harness_status"
  }
  __harness_preexec() { printf '\033]133;C\007'; }
  if (( ${+functions[add-zsh-hook]} )); then
    add-zsh-hook precmd __harness_precmd
    add-zsh-hook preexec __harness_preexec
  else
    (( ${precmd_functions[(Ie)__harness_precmd]} )) || precmd_functions+=(__harness_precmd)
    (( ${preexec_functions[(Ie)__harness_preexec]} )) || preexec_functions+=(__harness_preexec)
  fi
fi
