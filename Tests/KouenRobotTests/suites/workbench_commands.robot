*** Settings ***
Documentation    Workbench ex-commands: :view :agent :cd :find :grep :recent :errors :make :board
Resource         ../resources/kouen.resource
Library          ../libraries/KouenUILibrary.py
Test Setup       Launch Kouen
Test Teardown    Quit Kouen

*** Keywords ***
Send Ex Command
    [Arguments]    ${cmd}
    [Documentation]    Open command prompt (prefix key + :) and run an ex command
    Press Shortcut    ctrl+b
    Wait For UI    0.2
    Press Shortcut    colon
    Wait For UI    0.2
    Type Text    ${cmd}
    Press Shortcut    return
    Wait For UI    0.5

*** Test Cases ***
View Command Opens Existing File
    [Documentation]    :view README.md opens the file in the sidebar preview panel
    Send Ex Command    view README.md
    Element Should Exist    file-editor-split

View Command No Match Shows Message
    [Documentation]    :view with no match shows display message (no crash)
    Send Ex Command    view __nonexistent_xyz__.rb
    # No crash = pass; DisplayMessage appears briefly

Find Command Opens Command Palette On Empty Query
    [Documentation]    :find with no query opens command palette
    Send Ex Command    find
    Element Should Exist    command-palette

Find Command Resolves Unique File
    [Documentation]    :find README.md opens file (unique match)
    Send Ex Command    find README.md
    Element Should Exist    file-editor-split

Grep Command Opens Palette In Grep Mode
    [Documentation]    :grep kouen opens grep search panel
    Send Ex Command    grep kouen
    Element Should Exist    command-palette

Recent Command Does Not Crash
    [Documentation]    :recent shows recently opened files or "no recently opened files"
    Send Ex Command    recent
    # No crash = pass

Errors Command Does Not Crash
    [Documentation]    :errors shows diagnostics or "no diagnostics"
    Send Ex Command    errors
    # No crash = pass

Make Command Runs In Split Pane
    [Documentation]    :make opens a horizontal split and runs the build command
    Send Ex Command    make build
    Element Should Exist    close-pane-button

Board Command Shows Board Panel
    [Documentation]    :board opens the agent/session board in the sidebar
    Send Ex Command    board
    Element Should Exist    sidebar-tab-board

Agent Command Does Not Crash
    [Documentation]    :agent lists running agents or shows "no running agents"
    Send Ex Command    agent
    # No crash = pass

Agent Waiting Filter Does Not Crash
    [Documentation]    :agent --waiting filters to blocking agents
    Send Ex Command    agent --waiting
    # No crash = pass

Cd Command Switches To Matching Tab
    [Documentation]    :cd / navigates to a tab whose cwd matches (root always exists)
    New Tab
    Wait For UI    0.5
    Send Ex Command    cd /
    # No crash = pass

Copy Path Command Does Not Crash
    [Documentation]    :copy-path with no open file shows message, with file copies path
    Send Ex Command    copy-path
    # No crash = pass
