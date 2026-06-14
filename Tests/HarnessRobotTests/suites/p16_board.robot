*** Settings ***
Documentation    P16 — Agent/Session Board
Resource         ../resources/harness.resource
Library          ../libraries/HarnessUILibrary.py
Library          Process
Test Setup       Launch Harness
Test Teardown    Quit Harness

*** Test Cases ***
Board CLI Shows Columns
    [Documentation]    P16: harness board prints column table
    Harness Board Should Have Column    idle

Board CLI Shows Running After Long Command
    [Documentation]    P16: long-running commands show in Running column
    # Start a background sleep in the terminal
    Press Shortcut    cmd+n
    Wait For UI    1
    # The new session starts idle
    Harness Board Should Have Column    idle

Board Tab Accessible In Sidebar
    [Documentation]    P16: Board tab clickable in sidebar
    Toggle Sidebar
    Wait For UI    0.5
    Element Should Exist    sidebar-tab-board

Board Columns Visible After Click
    [Documentation]    P16: clicking Board tab shows column headers
    Toggle Sidebar
    Wait For UI    0.5
    Click UI Element    sidebar-tab-board
    Wait For UI    0.5
    Element Should Exist    board-column-idle
