*** Settings ***
Documentation    Regression guards for memory-leak fixes.
...              Leak A: SessionCoordinator's per-surface AI controller dicts only ever
...                      inserted (one pair per pane) and were never removed on close —
...                      every closed pane leaked its Inline/Chat controllers + subviews.
...              Leak B: Browser pane network-capture JS array grew without bound on
...                      long-lived polling/streaming pages.
...              Leak C: Structural guard — any NEW [String: T] dict added to
...                      SessionCoordinator must have a .removeValue in the onRetire closure.
...                      Prevents future contributors from repeating the insert-only pattern.
...              Leak D: Structural guard — any NEW [String: T] dict added to
...                      NotificationCoordinator must be swept via .filter { live.contains }
...                      on each snapshot sync. Same insert-only prevention, different cleanup strategy.
Library          OperatingSystem
Library          Process

*** Variables ***
${ROOT}              ${CURDIR}/../..
${PANE_REGISTRY}     ${ROOT}/Apps/Kouen/Sources/KouenApp/Services/TerminalPaneRegistry.swift
${COORDINATOR}       ${ROOT}/Apps/Kouen/Sources/KouenApp/Services/SessionCoordinator.swift
${NOTIFICATION_COORD}    ${ROOT}/Apps/Kouen/Sources/KouenApp/Services/NotificationCoordinator.swift
${BROWSER_PANE}      ${ROOT}/Apps/Kouen/Sources/KouenApp/UI/Chrome/BrowserPaneView.swift
${RETIRE_CHECKER}    ${CURDIR}/helpers/check_retire_coverage.py

*** Test Cases ***
Leak A - Retiring A Host Drops Its AI Controllers
    [Documentation]    Host retire (close + prune both funnel through retire()) must notify
    ...                the coordinator so the parallel AI-controller dicts can't grow forever.
    ${registry}=    Get File    ${PANE_REGISTRY}
    Should Contain    ${registry}    onRetire
    ...    msg=TerminalPaneRegistry must expose an onRetire hook fired from retire()
    ${coord}=    Get File    ${COORDINATOR}
    Should Contain    ${coord}    inlineAIControllers.removeValue
    ...    msg=Coordinator must drop the inline AI controller when its host retires

Leak B - Browser Network Capture Is Bounded
    [Documentation]    The injected fetch/XHR capture array must be capped so a
    ...                long-lived page cannot grow it without bound.
    ${content}=    Get File    ${BROWSER_PANE}
    Should Contain    ${content}    __cap()
    ...    msg=Network capture pushes must call __cap() to trim the ring
    Should Not Contain    ${content}    window.__kouenNetwork.length + 1
    ...    msg=Use a monotonic seq for ids, not array length (collides after trim)

Leak C - Every Per-Surface Dict In Coordinator Has Retire Cleanup
    [Documentation]    Every private var [String: T] in SessionCoordinator must have a
    ...                .removeValue call inside the onRetire closure. This guard catches
    ...                the "insert-only dict" pattern before it ships — add the dict,
    ...                forget the cleanup, this fails at PR time.
    ${result}=    Run Process    python3    ${RETIRE_CHECKER}    ${COORDINATOR}
    ...           stdout=PIPE    stderr=PIPE
    Log    ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=Missing onRetire cleanup — ${result.stdout}

Leak D - Every Per-Surface Dict In NotificationCoordinator Is Snapshot-Swept
    [Documentation]    Every private var [String: T] in NotificationCoordinator must be
    ...                reassigned via .filter { live.contains } inside the snapshot-sync sweep.
    ...                NotificationCoordinator uses snapshot iteration (not onRetire) for cleanup —
    ...                this guard enforces the same insert-only prevention with the correct strategy.
    ${result}=    Run Process    python3    ${RETIRE_CHECKER}    ${NOTIFICATION_COORD}
    ...           --mode    filter
    ...           stdout=PIPE    stderr=PIPE
    Log    ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=Missing snapshot-sweep cleanup — ${result.stdout}
