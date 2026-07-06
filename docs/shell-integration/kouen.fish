# Kouen shell integration for fish — OSC 133 semantic prompts.
#
#   Add to ~/.config/fish/config.fish:   source /path/to/kouen.fish
#
# Emits OSC 133;A to mark each prompt line, OSC 133;C;<base64 command> right before a command
# runs (the exact typed command, from fish's own fish_preexec event — not a screen-scrape
# guess), and OSC 133;D;<exit> to report the finished command's status. Drives the prompt
# gutter, success/failure coloring, jump-between-prompts, and accurate block Copy/Re-run. Only
# active inside a Kouen terminal (the daemon exports $KOUEN).

if set -q KOUEN; and test "$TERM" != dumb
    function __kouen_osc133_prompt --on-event fish_prompt
        printf '\033]133;A\007'
    end
    function __kouen_osc133_preexec --on-event fish_preexec
        # base64 may wrap output across lines; command substitution splits on newlines,
        # so re-join the captured list before emitting a single OSC payload.
        set -l encoded (echo -n "$argv[1]" | base64)
        printf '\033]133;C;%s\007' (string join '' $encoded)
    end
    function __kouen_osc133_postexec --on-event fish_postexec
        printf '\033]133;D;%s\007' $status
    end
end
