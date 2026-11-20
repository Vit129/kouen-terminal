*** Settings ***
Documentation    Regression checks for the shipped CLI and repository workflow configuration.
Library          OperatingSystem
Library          Process
Library          String
Suite Setup      Find Built CLI

*** Variables ***
${ROOT}          ${CURDIR}/../..

*** Test Cases ***
[TS-0001] [BE-IT] CLI Catalog And Dispatch Exclude Embedded Workflow
    ${catalog}=    Run Process    ${CLI}    list-commands
    Should Be Equal As Integers    ${catalog.rc}    0    ${catalog.stderr}
    ${commands}=    Split To Lines    ${catalog.stdout}
    Should Contain    ${commands}    list-sessions
    Should Contain    ${commands}    agent
    Should Not Contain    ${commands}    task

    ${removed}=    Run Process    ${CLI}    task    list
    Should Be Equal As Integers    ${removed.rc}    1
    Should Contain    ${removed.stdout}    Commands:
    Should Not Contain    ${removed.stdout}    ${SPACE}${SPACE}task${SPACE}
    Should Not Contain    ${removed.stdout}    --feature

    FOR    ${command}    IN    agent    undo    verify
        ${removed}=    Run Process    ${CLI}    ${command}    --feature    legacy
        Should Be Equal As Integers    ${removed.rc}    1
        Should Contain    ${removed.stderr}    --feature is no longer supported
    END

[TS-0006] [BE-BL] Embedded Workflow Definitions Are Absent
    File Should Not Exist    ${ROOT}/.claude/aidlc.json
    File Should Not Exist    ${ROOT}/.claude/rules/ai-sdlc-workflow.md
    File Should Not Exist    ${ROOT}/.claude/skills/ai-sdlc/SKILL.md

*** Keywords ***
Find Built CLI
    ${build}=    Run Process    swift    build    --product    kouen-cli    cwd=${ROOT}
    Should Be Equal As Integers    ${build.rc}    0    ${build.stderr}
    ${bin}=    Run Process    swift    build    --show-bin-path    cwd=${ROOT}
    Should Be Equal As Integers    ${bin.rc}    0    ${bin.stderr}
    VAR    ${CLI}    ${bin.stdout}/kouen-cli    scope=SUITE
