# Harness shell integration for fish — OSC 133 semantic prompts.
# A/B bracket the rendered prompt; C starts output; D reports command status.
# Active only inside a Harness pane (the daemon exports $HARNESS).
# Interactive shells only: `exit` in a sourced file skips the rest
# of the file, so scripts and `fish -c` never register the hooks (the vendor_conf.d
# vehicle would otherwise run this for every fish).
status is-interactive; or exit
if set -q HARNESS; and test "$TERM" != dumb
    function __harness_osc133_prompt --on-event fish_prompt
        # Refresh the wrapper if a theme replaces fish_prompt after startup.
        if not functions fish_prompt | string match -q '*__harness_original_fish_prompt*'
            functions -e __harness_original_fish_prompt
            functions -c fish_prompt __harness_original_fish_prompt
            function fish_prompt
                __harness_original_fish_prompt
                set -l __harness_prompt_status $status
                printf '\033]133;B\007'
                return $__harness_prompt_status
            end
        end
        printf '\033]133;A\007'
    end
    function __harness_osc133_preexec --on-event fish_preexec
        printf '\033]133;C\007'
    end
    function __harness_osc133_postexec --on-event fish_postexec
        printf '\033]133;D;%s\007' $status
    end
end
