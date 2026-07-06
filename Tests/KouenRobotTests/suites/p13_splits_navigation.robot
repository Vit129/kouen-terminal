*** Settings ***
Documentation    P13 — Split Panes + Tab Bar + Navigation
Resource         ../resources/kouen.resource
Library          ../libraries/KouenUILibrary.py
Test Setup       Launch Kouen
Test Teardown    Quit Kouen

*** Test Cases ***
Split Right Creates Pane
    [Documentation]    P13: ⌘D creates side-by-side split
    Split Right
    Element Should Exist    close-pane-button

Split Down Creates Pane
    [Documentation]    P13: ⌘⇧D creates top/bottom split
    Split Down
    Element Should Exist    close-pane-button

Close Pane Removes Split
    [Documentation]    P13: closing pane restores single view
    Split Right
    Close Pane
    Element Should Not Exist    close-pane-button

Sidebar Toggle Works
    [Documentation]    Sidebar ⌘\\ opens/closes
    Toggle Sidebar
    Wait For UI    0.5
    Element Should Exist    sidebar-tab-files
    Toggle Sidebar
    Wait For UI    0.5
    Element Should Not Exist    sidebar-tab-files

Tab Bar Close Button Hidden At Rest
    [Documentation]    CASE-028 regression: close button not visible without hover
    Element Should Not Exist    tab-close-0

Session Navigation Cmd Brackets
    [Documentation]    ⌘] / ⌘[ cycles sessions
    New Tab
    Wait For UI    0.5
    Next Session
    Previous Session
    # No crash = pass

Window Survives All Shortcuts
    [Documentation]    Smoke: rapid shortcut sequence doesn't crash
    Split Right
    Split Down
    Toggle Sidebar
    Next Session
    Close Pane
    Close Pane
    ${count}=    Get Window Count
    Should Be True    ${count} > 0
