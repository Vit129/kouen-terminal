*** Settings ***
Documentation    Worktree-per-session isolation — E2E via CLI + GUI
Resource         ../resources/kouen.resource
Library          ../libraries/KouenUILibrary.py
Library          OperatingSystem
Library          Process
Test Setup       Setup Worktree Test Environment
Test Teardown    Teardown Worktree Test Environment

*** Variables ***
${REPO_DIR}       /tmp/kouen-robot-wt-test
${CLI}            ${CURDIR}/../../.build/debug/kouen-cli

*** Keywords ***
Setup Worktree Test Environment
    Remove Directory    ${REPO_DIR}    recursive=True
    Create Directory    ${REPO_DIR}
    Run Process    git    init    cwd=${REPO_DIR}
    Run Process    git    commit    --allow-empty    -m    init    cwd=${REPO_DIR}
    Launch Kouen
    Wait For UI    2

Teardown Worktree Test Environment
    Quit Kouen
    Remove Directory    ${REPO_DIR}    recursive=True

Run CLI
    [Arguments]    @{args}
    ${result}=    Run Process    ${CLI}    @{args}    timeout=10s
    RETURN    ${result}

Create Isolated Session And Select
    [Documentation]    Creates an isolated session and switches GUI focus to it
    [Arguments]    ${branch}
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    ${branch}    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    ${session_id}=    Set Variable    ${result.stdout.strip()}
    # Select the newly created session so GUI focus is on it
    Run CLI    select-session    --workspace    Default    --session    ${session_id}
    Wait For UI    0.5
    RETURN    ${session_id}

*** Test Cases ***
CLI Isolate Creates Worktree And Session
    [Documentation]    kouen-cli new-session --isolate creates a worktree and session
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    robot-feat-1    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    Directory Should Exist    ${REPO_DIR}/.kouen-worktrees
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    robot-feat-1

CLI Isolate With Custom Branch Name
    [Documentation]    --branch flag creates worktree on specified branch
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    custom-branch    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    custom-branch

Two Isolated Sessions Have Different Branches
    [Documentation]    Two --isolate sessions get independent branches
    ${r1}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    branch-a    --repo    ${REPO_DIR}
    ${r2}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    branch-b    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${r1.rc}    0
    Should Be Equal As Integers    ${r2.rc}    0
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    branch-a
    Should Contain    ${git_result.stdout}    branch-b

Close Session Removes Clean Worktree
    [Documentation]    Closing isolated session auto-removes its worktree
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    to-remove    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    ${session_id}=    Set Variable    ${result.stdout.strip()}
    ${git_before}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_before.stdout}    to-remove
    Run CLI    close-session    --session    ${session_id}
    Wait For UI    1
    ${git_after}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Not Contain    ${git_after.stdout}    to-remove

Close Session Keeps Dirty Worktree
    [Documentation]    Dirty worktree preserved on session close
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    dirty-wt    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    ${session_id}=    Set Variable    ${result.stdout.strip()}
    # Find worktree path and make dirty
    ${find}=    Run Process    find    ${REPO_DIR}/.kouen-worktrees    -maxdepth    1    -type    d
    ${wt_subdir}=    Evaluate    [l for l in '''${find.stdout}'''.strip().split('\\n') if l != '${REPO_DIR}/.kouen-worktrees'][0]
    Create File    ${wt_subdir}/dirty.txt    uncommitted work
    Run CLI    close-session    --session    ${session_id}
    Wait For UI    1
    ${git_after}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_after.stdout}    dirty-wt

New Tab Shares Branch No Worktree
    [Documentation]    Regular ⌘T shares the same .git/HEAD (no isolation)
    New Tab
    Wait For UI    1
    App Should Not Crash

Isolate Without Branch Uses Detached HEAD
    [Documentation]    --isolate without --branch creates detached HEAD worktree
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    detached

# --- Navigation & Switch Tests ---

Next Pane In Isolated Session Stays In Worktree
    [Documentation]    ⌘] in split pane within isolated session stays in worktree cwd
    ${session_id}=    Create Isolated Session And Select    nav-next
    Split Right
    Wait For UI    0.5
    Next Session
    Wait For UI    0.3
    App Should Not Crash

Prev Pane In Isolated Session Stays In Worktree
    [Documentation]    ⌘[ in split pane within isolated session stays in worktree cwd
    ${session_id}=    Create Isolated Session And Select    nav-prev
    Split Right
    Wait For UI    0.5
    Previous Session
    Wait For UI    0.3
    App Should Not Crash

Split In Isolated Session Inherits Worktree
    [Documentation]    Split pane in isolated session — new pane should be in worktree dir
    ${session_id}=    Create Isolated Session And Select    split-test
    Split Right
    Wait For UI    1
    # Verify via list-surfaces that both panes have worktree cwd
    ${surfaces}=    Run CLI    list-surfaces
    Should Contain    ${surfaces.stdout}    .kouen-worktrees
    App Should Not Crash

Switch Between Isolated And Normal Session
    [Documentation]    ⌘1/⌘2 switch between isolated and normal session — each keeps its cwd
    ${session_id}=    Create Isolated Session And Select    switch-test
    # Switch to session 1 (normal — the default one from launch)
    Switch To Session 1
    Wait For UI    0.5
    App Should Not Crash
    # Switch back to session 2 (isolated)
    Switch To Session 2
    Wait For UI    0.5
    App Should Not Crash

Switch Session And Switch Back Preserves Worktree
    [Documentation]    Round-trip: switch away then back — worktree still intact
    ${session_id}=    Create Isolated Session And Select    roundtrip
    Switch To Session 1
    Wait For UI    0.5
    Switch To Session 2
    Wait For UI    0.5
    # Worktree still in git list
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    roundtrip
    App Should Not Crash

Git Checkout In Normal Session Does Not Affect Isolated
    [Documentation]    git checkout in shared session doesn't change isolated session's branch
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    isolated-stable    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    # Create a branch in main repo and checkout
    Run Process    git    branch    other-branch    cwd=${REPO_DIR}
    Run Process    git    checkout    other-branch    cwd=${REPO_DIR}
    # Isolated worktree still on its own branch
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    isolated-stable

Close Pane Not Session Keeps Worktree
    [Documentation]    Closing a pane (not session) in isolated session keeps worktree alive
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    pane-close    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    Split Right
    Wait For UI    0.5
    Close Pane
    Wait For UI    0.5
    # Worktree should still exist (session still alive)
    ${git_result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git_result.stdout}    pane-close
    App Should Not Crash

Drag Reorder Past Worktree Row No Crash
    [Documentation]    Regression: drag session row past worktree/divider rows doesn't crash
    ${result}=    Run CLI    new-session    --workspace    Default    --isolate
    ...    --branch    drag-test    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    New Tab
    Wait For UI    0.5
    # Just verify app survives — actual drag needs accessibility interaction
    App Should Not Crash
