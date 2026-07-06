*** Settings ***
Documentation    P4 — Terminal-First LSP & File View
Resource         ../resources/kouen.resource
Library          ../libraries/KouenUILibrary.py
Test Setup       Launch Kouen
Test Teardown    Quit Kouen

*** Test Cases ***
Kouen View Prints File Content
    [Documentation]    P4 Track 3: kouen view outputs file to stdout
    ${output}=    Kouen CLI Should Succeed    view    README.md
    Should Contain    ${output}    Kouen

Kouen View Binary Shows Guard Message
    [Documentation]    P4 Track 1: binary file detection
    ${output}=    Kouen CLI Should Succeed    view    Kouen.dmg
    Should Contain    ${output}    Binary

Kouen LSP Start Returns JSON
    [Documentation]    P4 Track 3: LSP lifecycle
    ${output}=    Kouen CLI Should Succeed    lsp    start
    Should Contain    ${output}    status

Kouen LSP Hover Returns Result
    [Documentation]    P4 Track 3: hover info
    ${output}=    Kouen CLI Should Succeed    lsp    hover    Package.swift:5:8
    # May return "no info" or actual hover — both are valid (no crash)
    Should Not Be Empty    ${output}

Kouen LSP Diagnostics Does Not Crash
    [Documentation]    P4 Track 3: diagnostics graceful
    ${output}=    Kouen CLI Should Succeed    lsp    diagnostics    Package.swift
    Log    ${output}
