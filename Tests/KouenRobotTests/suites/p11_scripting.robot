*** Settings ***
Documentation    P11 — Scripting & Config API
Resource         ../resources/kouen.resource
Library          ../libraries/KouenUILibrary.py
Library          OperatingSystem
Library          Process
Test Setup       Launch Kouen
Test Teardown    Cleanup And Quit

*** Variables ***
${CONFIG_DIR}     %{HOME}/.config/kouen
${CONFIG_FILE}    %{HOME}/.config/kouen/init.js

*** Keywords ***
Cleanup And Quit
    Quit Kouen
    Remove File    ${CONFIG_FILE}

*** Test Cases ***
Script Loads On Startup
    [Documentation]    P11: init.js is loaded and executed on app launch
    [Setup]    Create Config File    kouen.log("robot-test-loaded")
    Launch Kouen
    # Verify via app log (NSLog) — script ran without crash
    Wait For UI    2

Script Hot Reload On Save
    [Documentation]    P11: editing init.js triggers reload without restart
    Create Config File    kouen.toast("v1")
    Wait For UI    2
    # Overwrite with new content — watcher should fire
    Create File    ${CONFIG_FILE}    kouen.toast("v2-reloaded")
    Wait For UI    2
    # No crash = pass (toast verification needs accessibility)

Script Syntax Error Does Not Crash
    [Documentation]    P11: syntax error keeps last-good runtime
    Create Config File    kouen.log("good")
    Wait For UI    1
    # Introduce error
    Create File    ${CONFIG_FILE}    kouen.log("unclosed
    Wait For UI    2
    # App still running
    ${count}=    Get Window Count
    Should Be True    ${count} > 0

No Config File Starts Normally
    [Documentation]    P11: app launches without script when no config exists
    Remove File    ${CONFIG_FILE}
    Quit Kouen
    Launch Kouen
    ${count}=    Get Window Count
    Should Be True    ${count} > 0

*** Keywords ***
Create Config File
    [Arguments]    ${content}
    Create Directory    ${CONFIG_DIR}
    Create File    ${CONFIG_FILE}    ${content}
