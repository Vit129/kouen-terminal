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
Library          Process

*** Variables ***
${ROOT}              ${CURDIR}/../..
${APP_DELEGATE}      ${ROOT}/Apps/Kouen/Sources/KouenApp/AppDelegate.swift
${ISOLATE_SERVICE}   ${ROOT}/Apps/Kouen/Sources/KouenApp/Services/WorktreeAutoIsolateService.swift
${CONTENT_AREA}      ${ROOT}/Apps/Kouen/Sources/KouenApp/UI/Chrome/ContentAreaViewController.swift
${APP_SOURCES}       ${ROOT}/Apps/Kouen/Sources/KouenApp

*** Test Cases ***
Guard - WorktreeAutoIsolateService Is Actually Started At Launch
    [Documentation]    The service's NotificationCenter observer is only installed inside
    ...                `start()` — without this call site, branch-switch detection silently
    ...                never fires and every tab that checks out a non-default branch stays
    ...                pinned at the repo root forever (no error, no log, nothing to notice).
    ${content}=    Get File    ${APP_DELEGATE}
    Should Contain    ${content}    WorktreeAutoIsolateService.shared.start()
    ...    msg=AppDelegate must call WorktreeAutoIsolateService.shared.start() at launch

Guard - Branch Change Only Publishes A Notice
    [Documentation]    Ask-first: a tab switching to a non-default branch must NOT checkout in
    ...                the shared primary tree, create a worktree, or `cd` the tab. The branch-
    ...                change path (observer + `refreshNotices`) may only compute and publish a
    ...                notice; every git/IPC mutation lives below `// MARK: - Explicit isolate`.
    ...                Regression: CASE-007 — an agent's commits landed on local main because
    ...                Kouen moved the shared folder unprompted.
    ${content}=    Get File    ${ISOLATE_SERVICE}
    ${observe_only}=    Evaluate    $content.split('// MARK: - Explicit isolate')[0]
    Should Not Contain    ${observe_only}    checkoutLocked
    ...    msg=branch-change path must never checkout in the primary tree
    Should Not Contain    ${observe_only}    requestDaemon
    ...    msg=branch-change path must never cd a tab or retag it
    Should Not Contain    ${observe_only}    manager.create
    ...    msg=branch-change path must never create a worktree
    Should Not Contain    ${observe_only}    Process()
    ...    msg=branch-change path must not shell out to git

Guard - Isolate Is Only Reachable From The Notice Action
    [Documentation]    The one caller of `isolate(tabID:)` is the notice's button handler in
    ...                ContentAreaViewController — no observer, timer or service may call it.
    ${result}=    Run Process    grep    -rln    WorktreeAutoIsolateService.shared.isolate    ${APP_SOURCES}
    Should Contain    ${result.stdout}    ContentAreaViewController.swift
    ${others}=    Evaluate    [l for l in $result.stdout.splitlines() if l and not l.endswith('ContentAreaViewController.swift')]
    Should Be Empty    ${others}    msg=only the notice action may call isolate(tabID:)
