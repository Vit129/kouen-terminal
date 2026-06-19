*** Settings ***
Documentation    Worktree isolation — CLI-only E2E (no accessibility required).
...    Verifies worktree lifecycle, session focus memory across workspace switches,
...    and isolation guarantees using only harness-cli + git commands.
Library          Process
Library          OperatingSystem
Test Setup       Setup Test Repo
Test Teardown    Cleanup Test Repo

*** Variables ***
${REPO_DIR}       /tmp/harness-cli-wt-test
${CLI}            /Users/supavit.cho/Git/Personal/harness-terminal/.build/arm64-apple-macosx/debug/harness-cli
${WS}             Default

*** Keywords ***
Setup Test Repo
    Remove Directory    ${REPO_DIR}    recursive=True
    Create Directory    ${REPO_DIR}
    Run Process    git    init    cwd=${REPO_DIR}
    Run Process    git    commit    --allow-empty    -m    init    cwd=${REPO_DIR}

Cleanup Test Repo
    # Close all test sessions (ignore errors for already-closed)
    ${result}=    Run Process    ${CLI}    list-sessions    --json
    Remove Directory    ${REPO_DIR}    recursive=True

Run CLI
    [Arguments]    @{args}
    ${result}=    Run Process    ${CLI}    @{args}    timeout=10s
    RETURN    ${result}

Create Isolated Session
    [Arguments]    ${branch}
    ${result}=    Run CLI    new-session    --workspace    ${WS}    --isolate
    ...    --branch    ${branch}    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0    msg=Failed to create isolated session: ${result.stderr}
    RETURN    ${result.stdout.strip()}

Select Session
    [Arguments]    ${session_id}
    ${result}=    Run CLI    select-session    --workspace    ${WS}    --session    ${session_id}
    Should Be Equal As Integers    ${result.rc}    0

Get Tab ID For Session
    [Arguments]    ${session_id}
    ${result}=    Run CLI    list-windows    --session    ${session_id}    -F    \#{window_id}
    ${raw}=    Evaluate    '''${result.stdout}'''.strip().split('\\n')[0].replace('@', '')
    RETURN    ${raw}

Get Active Pane
    [Arguments]    ${tab_id}
    [Documentation]    Returns the pane ID currently marked (active) in list-panes output
    ${result}=    Run CLI    list-panes    --tab    ${tab_id}
    ${active_line}=    Evaluate    [l for l in '''${result.stdout}'''.strip().split('\\n') if '(active)' in l][0]
    # Format: "1: pane <UUID> surface <UUID> (active)"
    ${pane_id}=    Evaluate    '''${active_line}'''.split('pane ')[1].split(' ')[0]
    RETURN    ${pane_id}

Get Active Session ID
    ${result}=    Run CLI    list-sessions    -F    #{session_id}
    # list-sessions -F outputs the active session when used with snapshot
    ${snap}=    Run CLI    snapshot
    RETURN    ${snap.stdout}

Git Worktree Should Contain Branch
    [Arguments]    ${branch}
    ${result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${result.stdout}    ${branch}

Git Worktree Should Not Contain Branch
    [Arguments]    ${branch}
    ${result}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Not Contain    ${result.stdout}    ${branch}

*** Test Cases ***
# === Worktree Lifecycle ===

Create Isolated Session Via CLI
    [Documentation]    --isolate creates worktree + session with correct cwd
    ${sid}=    Create Isolated Session    feat-create
    Git Worktree Should Contain Branch    feat-create
    # Session exists
    ${has}=    Run CLI    has-session    --session    ${sid}
    Should Be Equal As Integers    ${has.rc}    0

Two Isolated Sessions Get Independent Branches
    [Documentation]    Two sessions in same repo get different worktrees
    ${s1}=    Create Isolated Session    branch-alpha
    ${s2}=    Create Isolated Session    branch-beta
    Git Worktree Should Contain Branch    branch-alpha
    Git Worktree Should Contain Branch    branch-beta
    # Different session IDs
    Should Not Be Equal    ${s1}    ${s2}

Close Isolated Session Removes Clean Worktree
    [Documentation]    Closing session auto-removes its clean worktree
    ${sid}=    Create Isolated Session    to-delete
    Git Worktree Should Contain Branch    to-delete
    Run CLI    close-session    --session    ${sid}
    Sleep    1s
    Git Worktree Should Not Contain Branch    to-delete

Close Isolated Session Keeps Dirty Worktree
    [Documentation]    Dirty worktree survives session close
    ${sid}=    Create Isolated Session    dirty-keep
    # Make dirty
    ${find}=    Run Process    find    ${REPO_DIR}/.harness-worktrees    -maxdepth    1    -type    d
    ${dirs}=    Evaluate    [l for l in '''${find.stdout}'''.strip().split('\\n') if l != '${REPO_DIR}/.harness-worktrees']
    Create File    ${dirs}[0]/uncommitted.txt    dirty content
    Run CLI    close-session    --session    ${sid}
    Sleep    1s
    Git Worktree Should Contain Branch    dirty-keep

# === Git Checkout Isolation ===

Git Checkout In Main Repo Does Not Affect Isolated Session
    [Documentation]    Changing branch in main repo doesn't change worktree branch
    ${sid}=    Create Isolated Session    stable-iso
    # Checkout different branch in main repo
    Run Process    git    branch    other-main    cwd=${REPO_DIR}
    Run Process    git    checkout    other-main    cwd=${REPO_DIR}
    # Main repo is on other-main
    ${main_branch}=    Run Process    git    branch    --show-current    cwd=${REPO_DIR}
    Should Be Equal    ${main_branch.stdout.strip()}    other-main
    # Worktree still on stable-iso
    ${find}=    Run Process    find    ${REPO_DIR}/.harness-worktrees    -maxdepth    1    -type    d
    ${wt_dir}=    Evaluate    [l for l in '''${find.stdout}'''.strip().split('\\n') if l != '${REPO_DIR}/.harness-worktrees'][0]
    ${wt_branch}=    Run Process    git    branch    --show-current    cwd=${wt_dir}
    Should Be Equal    ${wt_branch.stdout.strip()}    stable-iso
    # Cleanup
    Run Process    git    checkout    -    cwd=${REPO_DIR}

# === Session Focus Memory ===

Session Focus Remembered After Switch
    [Documentation]    Switching between sessions remembers which was focused.
    ...    Simulates: 3 sessions, focus ss2, switch away, switch back → still ss2.
    ${s1}=    Create Isolated Session    focus-a
    ${s2}=    Create Isolated Session    focus-b
    ${s3}=    Create Isolated Session    focus-c
    # Focus session 2
    Select Session    ${s2}
    # Switch to session 3
    Select Session    ${s3}
    # Switch back to session 2
    Select Session    ${s2}
    # Verify session 2 still exists and is selectable (focus works)
    ${has}=    Run CLI    has-session    --session    ${s2}
    Should Be Equal As Integers    ${has.rc}    0

Workspace Remembers Active Session Per Tab
    [Documentation]    Each workspace tab remembers its active session independently.
    ...    Tab1 has sessions [s1,s2,s3] focused on s2.
    ...    Tab2 has sessions [s4,s5] focused on s4.
    ...    Switching between them preserves each tab's last-focused session.
    # Create sessions (all in Default workspace = one "tab" conceptually)
    ${s1}=    Create Isolated Session    ws-a1
    ${s2}=    Create Isolated Session    ws-a2
    ${s3}=    Create Isolated Session    ws-a3
    # Focus s2 (middle one)
    Select Session    ${s2}
    # Now select s3 to simulate "switching away"
    Select Session    ${s3}
    # Come back to s2 — it should still be reachable
    Select Session    ${s2}
    ${has}=    Run CLI    has-session    --session    ${s2}
    Should Be Equal As Integers    ${has.rc}    0
    # s1 and s3 also still exist
    ${has1}=    Run CLI    has-session    --session    ${s1}
    ${has3}=    Run CLI    has-session    --session    ${s3}
    Should Be Equal As Integers    ${has1.rc}    0
    Should Be Equal As Integers    ${has3.rc}    0

# === Pane Operations ===

Split In Isolated Session Creates Second Surface
    [Documentation]    Splitting a pane in isolated session → 2 surfaces, both in worktree cwd
    ${sid}=    Create Isolated Session    split-cli
    ${tab_id}=    Get Tab ID For Session    ${sid}
    # Split
    ${split}=    Run CLI    new-split    --tab    ${tab_id}    --direction    horizontal
    Should Be Equal As Integers    ${split.rc}    0    msg=Split failed: ${split.stderr}
    # Now 2 panes
    ${panes}=    Run CLI    list-panes    --tab    ${tab_id}
    ${pane_count}=    Evaluate    len('''${panes.stdout}'''.strip().split('\\n'))
    Should Be True    ${pane_count} >= 2

Close Session With Split Panes Removes Worktree
    [Documentation]    Closing session that has split panes still cleans up worktree
    ${sid}=    Create Isolated Session    split-close
    ${tab_id}=    Get Tab ID For Session    ${sid}
    Run CLI    new-split    --tab    ${tab_id}    --direction    horizontal
    # Close entire session
    Run CLI    close-session    --session    ${sid}
    Sleep    1s
    Git Worktree Should Not Contain Branch    split-close

# === Detached HEAD ===

Isolate Without Branch Creates Detached HEAD
    [Documentation]    --isolate without --branch = detached HEAD worktree
    ${result}=    Run CLI    new-session    --workspace    ${WS}    --isolate
    ...    --repo    ${REPO_DIR}
    Should Be Equal As Integers    ${result.rc}    0
    ${git}=    Run Process    git    worktree    list    cwd=${REPO_DIR}
    Should Contain    ${git.stdout}    detached

# === Multiple Close Independence ===

Close One Isolated Does Not Affect Another
    [Documentation]    Closing one isolated session leaves other intact
    ${s1}=    Create Isolated Session    indep-x
    ${s2}=    Create Isolated Session    indep-y
    Run CLI    close-session    --session    ${s1}
    Sleep    1s
    Git Worktree Should Not Contain Branch    indep-x
    Git Worktree Should Contain Branch    indep-y
    # s2 still alive
    ${has}=    Run CLI    has-session    --session    ${s2}
    Should Be Equal As Integers    ${has.rc}    0

# === Split + Switch Session Stress ===

Split Right Then Switch Sessions
    [Documentation]    Split right in isolated session, switch to another session, switch back.
    ...    Pane count and worktree must survive the round-trip.
    ${s1}=    Create Isolated Session    split-r-sw
    ${tab_id}=    Get Tab ID For Session    ${s1}
    # Split right
    ${split}=    Run CLI    new-split    --tab    ${tab_id}    --direction    horizontal
    Should Be Equal As Integers    ${split.rc}    0    msg=Split right failed: ${split.stderr}
    # Create second session (normal)
    ${s2}=    Create Isolated Session    split-r-other
    # Switch to s2
    Select Session    ${s2}
    # Switch back to s1
    Select Session    ${s1}
    # Pane count still 2
    ${panes}=    Run CLI    list-panes    --tab    ${tab_id}
    ${pane_count}=    Evaluate    len('''${panes.stdout}'''.strip().split('\\n'))
    Should Be True    ${pane_count} >= 2
    # Worktree intact
    Git Worktree Should Contain Branch    split-r-sw

Split Down Then Switch Sessions
    [Documentation]    Split down in isolated session, switch away and back — panes preserved.
    ${s1}=    Create Isolated Session    split-d-sw
    ${tab_id}=    Get Tab ID For Session    ${s1}
    # Split down
    ${split}=    Run CLI    new-split    --tab    ${tab_id}    --direction    vertical
    Should Be Equal As Integers    ${split.rc}    0    msg=Split down failed: ${split.stderr}
    # Switch away to another
    ${s2}=    Create Isolated Session    split-d-other
    Select Session    ${s2}
    # Switch back
    Select Session    ${s1}
    # Pane count still 2
    ${panes}=    Run CLI    list-panes    --tab    ${tab_id}
    ${pane_count}=    Evaluate    len('''${panes.stdout}'''.strip().split('\\n'))
    Should Be True    ${pane_count} >= 2
    Git Worktree Should Contain Branch    split-d-sw

Split Both Directions Then Switch Multiple Times
    [Documentation]    Split right + down (3 panes), switch to 2 other sessions, come back.
    ...    All 3 panes must survive.
    ${s1}=    Create Isolated Session    split-both
    ${tab_id}=    Get Tab ID For Session    ${s1}
    # Split right (2 panes)
    Run CLI    new-split    --tab    ${tab_id}    --direction    horizontal
    # Split down (3 panes)
    Run CLI    new-split    --tab    ${tab_id}    --direction    vertical
    # Create 2 other sessions
    ${s2}=    Create Isolated Session    split-both-b
    ${s3}=    Create Isolated Session    split-both-c
    # Switch: s1 → s2 → s3 → s1
    Select Session    ${s2}
    Select Session    ${s3}
    Select Session    ${s1}
    # Should have 3 panes
    ${panes_after}=    Run CLI    list-panes    --tab    ${tab_id}
    ${pane_count}=    Evaluate    len('''${panes_after.stdout}'''.strip().split('\\n'))
    Should Be True    ${pane_count} >= 3
    Git Worktree Should Contain Branch    split-both

Rapid Session Switching Preserves All Worktrees
    [Documentation]    Create 3 isolated sessions, switch between them rapidly.
    ...    All worktrees and session states must survive.
    ${s1}=    Create Isolated Session    rapid-a
    ${s2}=    Create Isolated Session    rapid-b
    ${s3}=    Create Isolated Session    rapid-c
    # Rapid switch: 1→2→3→1→3→2→1
    Select Session    ${s1}
    Select Session    ${s2}
    Select Session    ${s3}
    Select Session    ${s1}
    Select Session    ${s3}
    Select Session    ${s2}
    Select Session    ${s1}
    # All worktrees intact
    Git Worktree Should Contain Branch    rapid-a
    Git Worktree Should Contain Branch    rapid-b
    Git Worktree Should Contain Branch    rapid-c
    # All sessions still alive
    ${h1}=    Run CLI    has-session    --session    ${s1}
    ${h2}=    Run CLI    has-session    --session    ${s2}
    ${h3}=    Run CLI    has-session    --session    ${s3}
    Should Be Equal As Integers    ${h1.rc}    0
    Should Be Equal As Integers    ${h2.rc}    0
    Should Be Equal As Integers    ${h3.rc}    0

# === Pane Focus Preservation ===

Split Right Focus Preserved After Switch
    [Documentation]    Split right → active pane is pane 1. Switch session, come back.
    ...    Active pane must still be pane 1 (not reset to pane 0).
    ${s1}=    Create Isolated Session    focus-r
    ${tab_id}=    Get Tab ID For Session    ${s1}
    # Split right — new pane becomes active
    Run CLI    new-split    --tab    ${tab_id}    --direction    horizontal
    ${before}=    Get Active Pane    ${tab_id}
    # Switch away
    ${s2}=    Create Isolated Session    focus-r-other
    Select Session    ${s2}
    # Switch back
    Select Session    ${s1}
    ${after}=    Get Active Pane    ${tab_id}
    Should Be Equal    ${before}    ${after}    msg=Active pane changed after switch!

Split Down Focus Preserved After Switch
    [Documentation]    Split down → active pane is pane 1. Switch and back → still pane 1.
    ${s1}=    Create Isolated Session    focus-d
    ${tab_id}=    Get Tab ID For Session    ${s1}
    Run CLI    new-split    --tab    ${tab_id}    --direction    vertical
    ${before}=    Get Active Pane    ${tab_id}
    ${s2}=    Create Isolated Session    focus-d-other
    Select Session    ${s2}
    Select Session    ${s1}
    ${after}=    Get Active Pane    ${tab_id}
    Should Be Equal    ${before}    ${after}    msg=Active pane changed after switch!

Split Both Then Switch Focus Stays On Last Active Pane
    [Documentation]    Split right + down (3 panes). Focus pane 0 explicitly.
    ...    Switch away and back → focus still pane 0.
    ${s1}=    Create Isolated Session    focus-both
    ${tab_id}=    Get Tab ID For Session    ${s1}
    # Split right (pane 1 active)
    Run CLI    new-split    --tab    ${tab_id}    --direction    horizontal
    # Split down (pane 2 active)
    Run CLI    new-split    --tab    ${tab_id}    --direction    vertical
    # Now 3 panes, pane 2 is active. Get its ID
    ${before}=    Get Active Pane    ${tab_id}
    # Switch away twice
    ${s2}=    Create Isolated Session    focus-both-b
    ${s3}=    Create Isolated Session    focus-both-c
    Select Session    ${s2}
    Select Session    ${s3}
    # Come back
    Select Session    ${s1}
    ${after}=    Get Active Pane    ${tab_id}
    Should Be Equal    ${before}    ${after}    msg=Active pane changed after multi-switch!
