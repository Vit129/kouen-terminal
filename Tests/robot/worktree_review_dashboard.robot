*** Settings ***
Documentation    Structural regression guards for P38 Phase A (cross-agent worktree diff/review
...              dashboard). This project's .robot suite is source-guard regression, not a
...              GUI-clicking E2E harness — there is no AppKit UI driver in use, so these guards
...              assert source-level invariants instead of driving clicks. Actual click-through
...              (segment nav, diff popover, badge flip, merge, abort) is covered by a live
...              `make preview` walkthrough, same as every other GUI feature in this project.
...              Guard A: the merge call site must be a plain `git merge` — never `--no-ff` —
...                       per the locked v1 decision (fast-follow, not built now).
...              Guard B: the merge/conflict code path must never auto-resolve a conflict —
...                       no `--theirs`/`--ours`/`checkout` call anywhere near it.
...              Guard C: a resolved/aborted merge conflict must not leave a stale conflict
...                       card forever — `activeMergeConflicts` must be reconciled against real
...                       `MERGE_HEAD` state on every refresh, not just read once and trusted.
Library          OperatingSystem

*** Variables ***
${ROOT}              ${CURDIR}/../..
${GIT_PANEL}         ${ROOT}/Apps/Kouen/Sources/KouenApp/UI/Git/GitPanelView.swift

*** Test Cases ***
Guard A - Merge Call Site Never Passes --no-ff
    [Documentation]    v1 locked decision: plain `git merge`, no `--no-ff` (fast-follow only).
    ...                A `--no-ff` string anywhere in this file would mean either the merge
    ...                call site regressed to always-branch-commit, or dead/leftover code from
    ...                exploring that option — neither should ship.
    ${content}=    Get File    ${GIT_PANEL}
    Should Contain    ${content}    runGitWithStatus(["merge", branch], in: mainWorktreePath)
    ...    msg=Merge call site must be the plain two-arg `git merge <branch>` form
    Should Not Contain    ${content}    "--no-ff"
    ...    msg=No git invocation may pass a quoted --no-ff argument (v1 is plain merge only)

Guard B - No Auto-Resolve Anywhere In The Merge/Conflict Path
    [Documentation]    A conflict must always be left for the user to resolve — the whole point
    ...                of the inline conflict card (Abort Merge / Resolve in Changes) is that
    ...                neither button silently picks a side. This guard fails the build the
    ...                moment anyone adds a --theirs/--ours/auto-resolving checkout call.
    ${content}=    Get File    ${GIT_PANEL}
    Should Not Contain    ${content}    --theirs
    ...    msg=No git invocation may auto-resolve conflicts via --theirs
    Should Not Contain    ${content}    --ours
    ...    msg=No git invocation may auto-resolve conflicts via --ours
    Should Not Contain    ${content}    checkout --force
    ...    msg=No force-checkout auto-resolve shortcut is permitted in the merge/conflict path

Guard C - Merge Conflict State Is Reconciled, Not Just Read Once
    [Documentation]    activeMergeConflicts is a snapshot taken the moment a merge failed with
    ...                MERGE_HEAD set — it goes stale the instant the user resolves or aborts
    ...                outside this UI (e.g. in a terminal). Without reconciliation the conflict
    ...                card would render forever. This guard requires the reconcile step to
    ...                exist AND to be wired into every refresh, not just defined and forgotten.
    ${content}=    Get File    ${GIT_PANEL}
    Should Contain    ${content}    func reconcileMergeConflicts
    ...    msg=Missing reconcileMergeConflicts — conflict cards would never self-clear
    Should Contain    ${content}    MERGE_HEAD
    ...    msg=Reconciliation must re-verify MERGE_HEAD, not trust the stored dict
    Should Contain    ${content}    await reconcileMergeConflicts(generation: generation)
    ...    msg=reconcileMergeConflicts must be called from refresh(), not just defined
    Should Contain    ${content}    activeMergeConflicts[worktree.path]
    ...    msg=makeWorktreeRow must read activeMergeConflicts — a write-only dict would never show it
