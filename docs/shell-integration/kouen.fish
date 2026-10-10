# Kouen shell integration for fish — OSC 133 semantic prompts.
# Emits OSC 133;A to mark each prompt, OSC 133;C;<base64 command> right before a command
# runs (so Kouen knows the exact typed command, not a screen-scrape guess — this is our
# own extension to the C boundary), and OSC 133;D;<exit> to report the finished command's
# status. Drives the prompt gutter, success/failure coloring, jump-between-prompts, and
# accurate block Copy/Re-run. Active only inside a Kouen pane (the daemon exports $KOUEN).
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
        set -l rc 0
        for a in $argv
            switch $a
                case -p --print -h --help -v --version --cloud --remote --teleport --bg --background
                    __kouen_claude_next $argv; return
                case --remote-control --rc
                    set rc 1
                case -r --resume '--resume=*' -c --continue --from-pr '--from-pr=*'
                    set resume 1
            end
        end
        if test $rc -eq 1
            /usr/bin/open -a "Google Chrome" "https://claude.ai/code" >/dev/null 2>&1 &
            /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
            if type -q happy; and test -f "$HOME/.happy/access.key"
                set -l claude_path $HAPPY_CLAUDE_PATH
                test -n "$claude_path"; or set claude_path (type -p claude)
                env HAPPY_CLAUDE_PATH=$claude_path happy claude $argv
            else
                __kouen_claude_next $argv
            end
        else if test "$KOUEN_CLAUDE_SESSION_MODE" = cloud; and test $resume -eq 0
            __kouen_claude_next --cloud $argv
        else if test "$KOUEN_CLAUDE_SESSION_MODE" = cloud; or test "$KOUEN_CLAUDE_SESSION_MODE" = remote-control
            if test "$KOUEN_CLAUDE_SESSION_MODE" = remote-control
                /usr/bin/open -a "Google Chrome" "https://claude.ai/code" >/dev/null 2>&1 &
                /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
            end
            if type -q happy; and test -f "$HOME/.happy/access.key"
                set -l claude_path $HAPPY_CLAUDE_PATH
                test -n "$claude_path"; or set claude_path (type -p claude)
                env HAPPY_CLAUDE_PATH=$claude_path happy claude --remote-control --remote-control-session-name-prefix kouen $argv
            else
                __kouen_claude_next --remote-control --remote-control-session-name-prefix kouen $argv
            end
        else if test "$KOUEN_CLAUDE_SESSION_MODE" = happy; and type -q happy
            set -l claude_path $HAPPY_CLAUDE_PATH
            test -n "$claude_path"; or set claude_path (type -p claude)
            env HAPPY_CLAUDE_PATH=$claude_path happy claude --remote-control --remote-control-session-name-prefix kouen $argv
        else
            __kouen_claude_next $argv
        end
    end
end
# Codex session mode: a `codex` typed by hand runs through Happy when $KOUEN_CODEX_SESSION_MODE is `happy` or `remote-control` with Happy logged in.
if set -q KOUEN; and begin test "$KOUEN_CODEX_SESSION_MODE" = happy; or test "$KOUEN_CODEX_SESSION_MODE" = remote-control; end; and not set -q __kouen_codex_wrapped
    set -g __kouen_codex_wrapped 1
    if functions -q codex
        functions -c codex __kouen_codex_next
    else
        function __kouen_codex_next
            command codex $argv
        end
    end
    function codex
        switch "$argv[1]"
            case agents exec e review login logout mcp plugin app-server remote-control app completion update doctor sandbox debug apply a resume queue archive delete migrate-rollouts unarchive fork cloud exec-server features help
                __kouen_codex_next $argv; return
        end
        set -l rc 0
        for a in $argv
            switch $a
                case -h --help -V --version
                    __kouen_codex_next $argv; return
                case --remote-control --rc
                    set rc 1
            end
        end
        if test "$KOUEN_CODEX_SESSION_MODE" = remote-control; or test $rc -eq 1
            /usr/bin/open -a "Google Chrome" "https://chatgpt.com" >/dev/null 2>&1 &
            /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
        end
        if type -q happy; and test -f "$HOME/.happy/access.key"
            happy codex $argv
        else
            __kouen_codex_next $argv
        end
    end
end
# Antigravity (agy) session mode: a `agy` typed by hand gets --remote-control, or happy agy when in happy mode.
if set -q KOUEN; and begin test "$KOUEN_AGY_SESSION_MODE" = remote-control; or test "$KOUEN_AGY_SESSION_MODE" = happy; end; and not set -q __kouen_agy_wrapped
    set -g __kouen_agy_wrapped 1
    if functions -q agy
        functions -c agy __kouen_agy_next
    else
        function __kouen_agy_next; command agy $argv; end
    end
    function agy
        switch "$argv[1]"
            case auth config doctor help remote-control status update version
                __kouen_agy_next $argv; return
        end
        set -l n 0
        set -l rc 0
        for a in $argv
            switch $a
                case -h --help -v --version
                    __kouen_agy_next $argv; return
                case --remote-control --rc
                    set rc 1
                case '*'
                    set n (math $n + 1)
            end
        end
        if test "$KOUEN_AGY_SESSION_MODE" = remote-control; or test $rc -eq 1
            /usr/bin/open -a "Google Chrome" "https://antigravity.google.com" >/dev/null 2>&1 &
            /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
        end
        if test "$KOUEN_AGY_SESSION_MODE" = happy; and type -q happy
            happy agy $argv; return
        end
        if test $rc -eq 1
            __kouen_agy_next $argv
        else
            __kouen_agy_next --remote-control $argv
        end
    end
end
# GitHub Copilot session mode: a `copilot` typed by hand gets --remote when in remote-control mode ($KOUEN_COPILOT_SESSION_MODE), or happy acp when happy.
if set -q KOUEN; and begin test "$KOUEN_COPILOT_SESSION_MODE" = remote-control; or test "$KOUEN_COPILOT_SESSION_MODE" = happy; end; and not set -q __kouen_copilot_wrapped
    set -g __kouen_copilot_wrapped 1
    if functions -q copilot
        functions -c copilot __kouen_copilot_next
    else
        function __kouen_copilot_next; command copilot $argv; end
    end
    function copilot
        switch "$argv[1]"
            case auth config help login logout status version
                __kouen_copilot_next $argv; return
        end
        set -l rc 0
        for a in $argv
            switch $a
                case -h --help -v --version
                    __kouen_copilot_next $argv; return
                case --remote
                    set rc 1
            end
        end
        if test "$KOUEN_COPILOT_SESSION_MODE" = happy; and type -q happy
            happy acp -- copilot --acp $argv; return
        end
        if test $rc -eq 1
            __kouen_copilot_next $argv
        else
            __kouen_copilot_next --remote $argv
        end
    end
end
# Hermes session mode
if set -q KOUEN; and test "$KOUEN_HERMES_SESSION_MODE" = remote-control; and not set -q __kouen_hermes_wrapped
    set -g __kouen_hermes_wrapped 1
    if functions -q hermes
        functions -c hermes __kouen_hermes_next
    else
        function __kouen_hermes_next; command hermes $argv; end
    end
    function hermes
        switch "$argv[1]"
            case auth config help login status version
                __kouen_hermes_next $argv; return
        end
        for a in $argv
            switch $a
                case -h --help -v --version --remote
                    __kouen_hermes_next $argv; return
            end
        end
        __kouen_hermes_next --remote $argv
    end
end
# Kouen CLI wrapper: `kouen` command that supports `rc`/`--rc` to auto-open Chrome
# and delegates any other commands to `kouen-cli`.
if set -q KOUEN; and not set -q __kouen_cli_wrapped
    set -g __kouen_cli_wrapped 1
    if functions -q kouen
        functions -c kouen __kouen_next
    else
        function __kouen_next
            if type -q kouen-cli
                command kouen-cli $argv
            else if test -n "$KOUEN_CLI"; and test -x "$KOUEN_CLI"
                $KOUEN_CLI $argv
            else if test -x "$HOME/Library/Application Support/Kouen/bin/kouen-cli"
                "$HOME/Library/Application Support/Kouen/bin/kouen-cli" $argv
            else
                echo "kouen-cli: command not found" >&2
                return 1
            end
        end
    end
    function kouen
        set -l rc 0
        if test "$argv[1]" = "rc"; or test "$argv[1]" = "companion"
            set rc 1
        end
        for a in $argv
            switch $a
                case --remote-control --rc
                    set rc 1
            end
        end
        if test $rc -eq 1
            set -x KOUEN_RC_OPENED 1
            /usr/bin/open -a "Google Chrome" "http://localhost:7777" >/dev/null 2>&1 &
        end
        __kouen_next $argv
    end
end