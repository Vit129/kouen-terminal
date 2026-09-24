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
