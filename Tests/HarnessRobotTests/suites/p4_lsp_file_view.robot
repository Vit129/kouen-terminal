*** Settings ***
Documentation    P4 — Terminal-First LSP & File View
Resource         ../resources/harness.resource
Library          ../libraries/HarnessUILibrary.py
Test Setup       Launch Harness
Test Teardown    Quit Harness

*** Test Cases ***
Harness View Prints File Content
    [Documentation]    P4 Track 3: harness view outputs file to stdout
    ${output}=    Harness CLI Should Succeed    view    README.md
    Should Contain    ${output}    Harness

Harness View Binary Shows Guard Message
    [Documentation]    P4 Track 1: binary file detection
    ${output}=    Harness CLI Should Succeed    view    Harness.dmg
    Should Contain    ${output}    Binary

Harness LSP Start Returns JSON
    [Documentation]    P4 Track 3: LSP lifecycle
    ${output}=    Harness CLI Should Succeed    lsp    start
    Should Contain    ${output}    status

Harness LSP Hover Returns Result
    [Documentation]    P4 Track 3: hover info
    ${output}=    Harness CLI Should Succeed    lsp    hover    Package.swift:5:8
    # May return "no info" or actual hover — both are valid (no crash)
    Should Not Be Empty    ${output}

Harness LSP Diagnostics Does Not Crash
    [Documentation]    P4 Track 3: diagnostics graceful
    ${output}=    Harness CLI Should Succeed    lsp    diagnostics    Package.swift
    Log    ${output}
