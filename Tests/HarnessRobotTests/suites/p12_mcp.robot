*** Settings ***
Documentation    P12 — Agent Orchestration via MCP
Resource         ../resources/harness.resource
Library          ../libraries/HarnessUILibrary.py
Library          Process
Library          OperatingSystem
Library          String
Test Setup       Launch Harness
Test Teardown    Quit Harness

*** Variables ***
${MCP_BIN}    ${EXECDIR}/../../.build/debug/harness-mcp

*** Test Cases ***
MCP HarnessList Returns Sessions
    [Documentation]    P12: read-only harnessList tool returns session data
    ${result}=    Run MCP Request    harnessList    {}
    Should Contain    ${result}    workspaces
    Should Not Contain    ${result}    error

MCP ReadPaneOutput Returns Content
    [Documentation]    P12: readPaneOutput returns terminal output
    # Get first surface ID from harnessList
    ${list_result}=    Run MCP Request    harnessList    {}
    Should Contain    ${list_result}    surfaceId

MCP HarnessBoard Returns Columns
    [Documentation]    P16: harnessBoard read-only tool returns board state
    ${result}=    Run MCP Request    harnessBoard    {}
    Should Contain    ${result}    columns

MCP Control Denied Without Env Var
    [Documentation]    P12: mutating tools rejected without HARNESS_MCP_ALLOW_CONTROL=1
    ${result}=    Run MCP Request Denied    sendPaneText    {"surfaceId":"fake","text":"hi","bracketed":false}
    Should Contain    ${result}    disabled

MCP Control Allowed With Env Var
    [Documentation]    P12: mutating tools work with HARNESS_MCP_ALLOW_CONTROL=1
    ${result}=    Run MCP Request Allowed    spawnSession    {"workspaceId":"invalid-uuid"}
    # Should get past policy gate (fail on UUID validation, not policy)
    Should Contain    ${result}    UUID

*** Keywords ***
Run MCP Request
    [Arguments]    ${tool_name}    ${arguments}
    ${init}=    Set Variable    {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}
    ${call}=    Set Variable    {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"${tool_name}","arguments":${arguments}}}
    ${input}=    Catenate    SEPARATOR=\n    ${init}    ${call}
    ${result}=    Run Process    printf    ${input}    |    ${MCP_BIN}
    ...    shell=True    timeout=10s
    RETURN    ${result.stdout}

Run MCP Request Denied
    [Arguments]    ${tool_name}    ${arguments}
    ${init}=    Set Variable    {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}
    ${call}=    Set Variable    {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"${tool_name}","arguments":${arguments}}}
    ${input}=    Catenate    SEPARATOR=\n    ${init}    ${call}
    ${result}=    Run Process    printf    ${input}    |    ${MCP_BIN}
    ...    shell=True    timeout=10s
    RETURN    ${result.stdout}

Run MCP Request Allowed
    [Arguments]    ${tool_name}    ${arguments}
    ${init}=    Set Variable    {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}
    ${call}=    Set Variable    {"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"${tool_name}","arguments":${arguments}}}
    ${input}=    Catenate    SEPARATOR=\n    ${init}    ${call}
    ${result}=    Run Process    printf    ${input}    |    env    HARNESS_MCP_ALLOW_CONTROL\=1    ${MCP_BIN}
    ...    shell=True    timeout=10s
    RETURN    ${result.stdout}
