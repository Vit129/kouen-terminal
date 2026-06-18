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
    Press Shortcut    cmd+w
    Wait For UI    0.5

Close Tab
    Press Shortcut    cmd+shift+w
    Wait For UI    0.5

Toggle Sidebar
    Press Shortcut    cmd+backslash
    Wait For UI    0.5

Open Command Palette
    Press Shortcut    cmd+p
    Wait For UI    0.5

New Tab
    Press Shortcut    cmd+t
    Wait For UI    0.5

Switch To Session 1
    Press Shortcut    cmd+1
    Wait For UI    0.3

Switch To Session 2
    Press Shortcut    cmd+2
    Wait For UI    0.3

Next Session
    Press Shortcut    cmd+shift+]
    Wait For UI    0.3

Previous Session
    Press Shortcut    cmd+shift+[
    Wait For UI    0.3

Find In Files
    Press Shortcut    cmd+f
    Wait For UI    0.5

Command Prompt
    Press Shortcut    cmd+;
    Wait For UI    0.5

Git Panel
    Press Shortcut    cmd+g
    Wait For UI    0.5
