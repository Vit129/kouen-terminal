*** Settings ***
Documentation    Keybinding shortcuts + crash regressions (RL-040/041, CASE-023)
Resource         ../resources/kouen.resource
Library          ../libraries/KouenUILibrary.py
Test Setup       Launch Kouen
Test Teardown    Quit Kouen

*** Test Cases ***
Cmd T Creates New Session
    [Documentation]    ⌘T opens a new session tab
    New Tab
    App Should Not Crash

Cmd W Closes Pane When Split
    [Documentation]    ⌘W closes active pane in a split layout
    Split Right
    Close Pane
    App Should Not Crash

Cmd W Closes Tab When Single Pane
    [Documentation]    ⌘W closes the tab when only one pane remains
    New Tab
    Wait For UI    0.5
    Close Pane
    App Should Not Crash

Cmd Shift W Force Closes Tab
    [Documentation]    ⌘⇧W always closes the entire tab
    Split Right
    Close Tab
    App Should Not Crash

Zombie Crash Rapid Close While Typing
    [Documentation]    RL-040/041 regression: keyDown/keyUp on zombie view after pane close
    Split Right
    Wait For UI    0.3
    Type Text    hello
    Close Pane
    Wait For UI    0.2
    App Should Not Crash

Zombie Crash Rapid Split Close Cycle
    [Documentation]    RL-040: rapid split+close doesn't crash from stale key events
    Split Right
    Type Text    a
    Close Pane
    Split Down
    Type Text    b
    Close Pane
    Wait For UI    0.3
    App Should Not Crash

Zombie Crash Close Tab While Typing
    [Documentation]    RL-041: close tab mid-keystroke doesn't crash
    New Tab
    Wait For UI    0.3
    Type Text    testing
    Close Tab
    Wait For UI    0.3
    App Should Not Crash

Window Survives Full Shortcut Sequence
    [Documentation]    Smoke: all new keybindings in sequence don't crash
    New Tab
    Split Right
    Split Down
    Close Pane
    Close Pane
    Close Tab
    ${count}=    Get Window Count
    Should Be True    ${count} > 0
    App Should Not Crash
