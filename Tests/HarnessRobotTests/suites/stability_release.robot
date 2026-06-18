*** Settings ***
Documentation    Stability tests — release build, isolated state.
...              Catches crashes that only appear in optimized builds.
Resource         ../resources/harness.resource
Library          ../libraries/HarnessUILibrary.py
Library          Process
Library          OperatingSystem
Test Setup       Launch Harness Staging
Test Teardown    Quit Harness Staging

*** Keywords ***
Launch Harness Staging
    [Documentation]    Launch release-optimized build with isolated state
    Launch Harness    env=staging

Quit Harness Staging
    Quit Harness    env=staging

*** Test Cases ***
Sidebar Toggle Immediately After Launch
    [Documentation]    ⌘\\ must work even before first layout pass (CASE-034 regression)
    Press Shortcut    cmd+backslash
    Wait For UI    1.0
    Element Should Exist    sidebar-tab-files

Rapid Session Switch While Typing
    [Documentation]    Zombie keyDown crash regression — switch session while keys held
    Send Keys    hello
    Switch To Session 2
    Wait For UI    0.3
    Switch To Session 1
    Wait For UI    0.3
    App Should Not Crash

Browser Pane Open Close Rapid
    [Documentation]    BrowserPaneView dealloc crash — open and close browser quickly
    Press Shortcut    cmd+b
    Wait For UI    0.5
    Press Shortcut    cmd+b
    Wait For UI    0.3
    Press Shortcut    cmd+b
    Wait For UI    0.5
    Press Shortcut    cmd+b
    Wait For UI    0.3
    App Should Not Crash

Tab Close While Mouse Moving
    [Documentation]    Tracking area zombie — close tab while hovering
    New Tab
    Wait For UI    0.3
    Hover Tab    1
    Press Shortcut    cmd+w
    Wait For UI    0.5
    App Should Not Crash

File Preview Open Close
    [Documentation]    QLPreviewView blink/crash regression
    Send Ex Command    :view README.md
    Wait For UI    1.0
    Press Shortcut    cmd+backslash
    Wait For UI    0.5
    Press Shortcut    cmd+backslash
    Wait For UI    0.5
    App Should Not Crash

Git Fetch Shows Toast
    [Documentation]    Git panel fetch/pull feedback
    Press Shortcut    cmd+g
    Wait For UI    0.5
    Click Sync Button
    Wait For UI    3.0
    Toast Should Appear

Split Pane And Resize
    [Documentation]    Terminal resize after split
    Split Right
    Wait For UI    0.5
    ${size1}=    Get Terminal Size
    Toggle Sidebar
    Wait For UI    0.5
    ${size2}=    Get Terminal Size
    Should Not Be Equal    ${size1}    ${size2}
    App Should Not Crash

Memory Stability After 30 Seconds
    [Documentation]    No runaway NSTextField leak (BoardViewController regression)
    ${heap1}=    Get Heap Count    NSTextField
    Wait For UI    30.0
    ${heap2}=    Get Heap Count    NSTextField
    ${growth}=    Evaluate    ${heap2} - ${heap1}
    Should Be True    ${growth} < 100    NSTextField grew by ${growth} — possible leak
