*** Settings ***
Documentation    Structural regression guard for the worktree auto-isolate service wiring.
...              `WorktreeAutoIsolateService.shared.start()` had never been called from
...              anywhere in the app (confirmed via full git history search — the call site
...              never existed, from the feature's introduction in P24 through 2026-07-15) —
...              the class was fully implemented and documented as a working "always-on"
...              feature, but its NotificationCenter observer was never installed, so no tab
...              ever auto-isolated into its own worktree on a branch switch, regardless of
...              any downstream fix to the notification/filter logic it depends on. This guard
...              fails the build the moment the launch-time `.start()` call is removed again.
Library          OperatingSystem

*** Variables ***
${ROOT}              ${CURDIR}/../..
${APP_DELEGATE}      ${ROOT}/Apps/Kouen/Sources/KouenApp/AppDelegate.swift

*** Test Cases ***
Guard - WorktreeAutoIsolateService Is Actually Started At Launch
    [Documentation]    The service's NotificationCenter observer is only installed inside
    ...                `start()` — without this call site, branch-switch detection silently
    ...                never fires and every tab that checks out a non-default branch stays
    ...                pinned at the repo root forever (no error, no log, nothing to notice).
    ${content}=    Get File    ${APP_DELEGATE}
    Should Contain    ${content}    WorktreeAutoIsolateService.shared.start()
    ...    msg=AppDelegate must call WorktreeAutoIsolateService.shared.start() at launch
