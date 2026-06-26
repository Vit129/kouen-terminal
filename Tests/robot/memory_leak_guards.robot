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
Library          OperatingSystem
Library          Process

*** Variables ***
${ROOT}              ${CURDIR}/../..
${PANE_REGISTRY}     ${ROOT}/Apps/Harness/Sources/HarnessApp/Services/TerminalPaneRegistry.swift
${COORDINATOR}       ${ROOT}/Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator.swift
${BROWSER_PANE}      ${ROOT}/Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift
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
    Should Contain    ${coord}    aiChatControllers.removeValue
    ...    msg=Coordinator must drop the AI chat controller when its host retires

Leak B - Browser Network Capture Is Bounded
    [Documentation]    The injected fetch/XHR capture array must be capped so a
    ...                long-lived page cannot grow it without bound.
    ${content}=    Get File    ${BROWSER_PANE}
    Should Contain    ${content}    __cap()
    ...    msg=Network capture pushes must call __cap() to trim the ring
    Should Not Contain    ${content}    window.__harnessNetwork.length + 1
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
