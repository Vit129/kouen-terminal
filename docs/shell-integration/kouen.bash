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
