*** Settings ***
Documentation    Regression guards for memory-leak fixes.
...              Leak A: SessionCoordinator's per-surface AI controller dicts only ever
...                      inserted (one pair per pane) and were never removed on close —
...                      every closed pane leaked its Inline/Chat controllers + subviews.
...              Leak B: Browser pane network-capture JS array grew without bound on
...                      long-lived polling/streaming pages.
Library          OperatingSystem
Library          Process

*** Variables ***
${ROOT}              ${CURDIR}/../..
${PANE_REGISTRY}     ${ROOT}/Apps/Harness/Sources/HarnessApp/Services/TerminalPaneRegistry.swift
${COORDINATOR}       ${ROOT}/Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator.swift
${BROWSER_PANE}      ${ROOT}/Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift

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
