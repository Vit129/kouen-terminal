# Harness shell integration for zsh — OSC 133 semantic prompts.
#
#   Add to ~/.zshrc:   source "/path/to/harness.zsh"
#
# Emits OSC 133;A to mark each prompt line, OSC 133;C;<base64 command> right before a command
# runs (the exact typed command, from zsh's own preexec hook — not a screen-scrape guess), and
# OSC 133;D;<exit> to report the finished command's status. Drives the prompt gutter,
# success/failure coloring, jump-between-prompts, and accurate block Copy/Re-run. Only active
# inside a Harness terminal (the daemon exports $HARNESS).

if [[ -n "$HARNESS" && "$TERM" != "dumb" ]]; then
  autoload -Uz add-zsh-hook 2>/dev/null
  __harness_precmd() {
    # Runs before each prompt: report the previous command's exit, then mark the new prompt.
    printf '\033]133;D;%s\007' "$?"
    printf '\033]133;A\007'
  }
  __harness_preexec() {
    # Runs right before a typed command executes: report it (base64, so `;`/newlines in the
    # command don't collide with the OSC-133 field separator Harness splits on).
    printf '\033]133;C;%s\007' "$(printf '%s' "$1" | base64 | tr -d '\n')"
  }
  if (( ${+functions[add-zsh-hook]} )); then
    add-zsh-hook precmd __harness_precmd
    add-zsh-hook preexec __harness_preexec
  else
    precmd_functions+=(__harness_precmd)
    preexec_functions+=(__harness_preexec)
  fi
fi
