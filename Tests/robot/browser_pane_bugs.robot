*** Settings ***
Documentation    Regression tests for browser pane and tab bugs.
...              Bug 1: Browser reloads on tab switch (WKWebView not cached)
...              Bug 2: CMD+SHIFT+N creates tab from stale snapshot
...              Bug 3: Browser shows blank after reattach (no redraw trigger)
Library          OperatingSystem
Library          Process

*** Variables ***
${ROOT}              ${CURDIR}/../..
${CONTENT_AREA}      ${ROOT}/Apps/Harness/Sources/HarnessApp/UI/Chrome/ContentAreaViewController.swift
${BROWSER_PANE}      ${ROOT}/Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift
${MAIN_MENU}         ${ROOT}/Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift

*** Test Cases ***
Bug 1 - Browser Pane Reuse On Rebuild
    [Documentation]    PaneContainerView must cache and reuse BrowserPaneView
    ...                instances during pane tree rebuilds, same as TerminalHostView.
    ${content}=    Get File    ${CONTENT_AREA}
    Should Contain    ${content}    existingBrowserPanes
    ...    msg=PaneContainerView must track existing browser panes for reuse
    Should Contain    ${content}    collectBrowserPanes()
    ...    msg=Must collect browser panes before teardown
    Should Contain    ${content}    existingBrowserPanes.removeValue(forKey: bl.id)
    ...    msg=Build must reuse cached BrowserPaneView by pane ID

Bug 1 - Browser Pane Deferred Unregister
    [Documentation]    BrowserPaneView must defer unregistration during rebuild
    ...                to avoid premature dealloc while view is being reattached.
    ${content}=    Get File    ${BROWSER_PANE}
    Should Contain    ${content}    asyncAfter
    ...    msg=viewWillMove must defer unregister to survive rebuild cycle
    Should Not Contain    ${content}    BrowserPaneRegistry.shared.unregister(self.paneID)
    ...    msg=Must NOT unregister synchronously in viewWillMove(toWindow:nil)

Bug 2 - New Session Syncs Before Reading Active Tab
    [Documentation]    CMD+SHIFT+N (newSession) must sync from daemon before
    ...                reading activeWorkspaceID to avoid stale CWD.
    ${content}=    Get File    ${MAIN_MENU}
    Should Contain    ${content}    coordinator.syncFromDaemon()
    ...    msg=newSession must call syncFromDaemon before addSession
    # Verify sync appears in the newSession function (grep context)
    ${result}=    Run Process    grep    -A10    func newSession    ${MAIN_MENU}
    Should Contain    ${result.stdout}    syncFromDaemon
    ...    msg=syncFromDaemon must be inside newSession() function
    Should Contain    ${result.stdout}    addSession
    ...    msg=addSession must follow syncFromDaemon in newSession()

Bug 2 - Tab Bar New Tab Also Syncs
    [Documentation]    The + button in tab bar must also sync before creating session.
    ${content}=    Get File    ${CONTENT_AREA}
    # Find tabBarDidRequestNewTab and verify it calls syncFromDaemon
    ${func_start}=    Evaluate    """${content}""".find("func tabBarDidRequestNewTab()")
    ${slice}=    Evaluate    """${content}"""[${func_start}:${func_start}+300]
    Should Contain    ${slice}    syncFromDaemon()
    ...    msg=tabBarDidRequestNewTab must sync before creating session

Bug 3 - Browser Pane Forces Redraw On Reattach
    [Documentation]    WKWebView must be nudged to repaint after reattachment
    ...                to prevent blank/pink frame.
    ${content}=    Get File    ${BROWSER_PANE}
    Should Contain    ${content}    viewDidMoveToSuperview
    ...    msg=Must override viewDidMoveToSuperview for redraw trigger
    Should Contain    ${content}    setNeedsDisplay
    ...    msg=Must call setNeedsDisplay on webView after reattach
    Should Contain    ${content}    evaluateJavaScript
    ...    msg=Must evaluate trivial JS to wake WKWebView compositor

Build Compiles Successfully
    [Documentation]    The project must compile without errors after all fixes.
    ${result}=    Run Process    swift    build
    ...    cwd=${ROOT}    timeout=120s
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=swift build must succeed: ${result.stderr}
