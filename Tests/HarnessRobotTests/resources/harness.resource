*** Settings ***
Library    ../libraries/HarnessUILibrary.py

*** Variables ***
${TIMEOUT}    5s

*** Keywords ***
Split Right
    Press Shortcut    cmd+d
    Wait For UI    0.5

Split Down
    Press Shortcut    cmd+shift+d
    Wait For UI    0.5

Close Pane
    Press Shortcut    alt+shift+cmd+w
    Wait For UI    0.5

Toggle Sidebar
    Press Shortcut    cmd+backslash
    Wait For UI    0.5

Open Command Palette
    Press Shortcut    cmd+k
    Wait For UI    0.5

New Tab
    Press Shortcut    cmd+n
    Wait For UI    0.5

Switch To Session 1
    Press Shortcut    cmd+1
    Wait For UI    0.3

Switch To Session 2
    Press Shortcut    cmd+2
    Wait For UI    0.3

Next Session
    Press Shortcut    cmd+]
    Wait For UI    0.3

Previous Session
    Press Shortcut    cmd+[
    Wait For UI    0.3
