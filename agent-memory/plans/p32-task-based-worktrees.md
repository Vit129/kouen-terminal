# P32 — Task-Based Agent Worktrees

Status: **All 4 phases complete**
Priority: **P1** — closes the biggest gap vs Superset/cmux/Supacode found in 2026-07-01 competitor review
Owner surface: `WorktreeManager`, `WorktreeAutoIsolateService`, `SessionCoordinator`, `ProjectConfig`, new UI entry point (sidebar/command palette)
Created: 2026-07-01
Depends on: existing `WorktreeManager` (`Packages/HarnessCore/Sources/HarnessCore/Worktree/WorktreeManager.swift`), existing `WorktreeAutoIsolateService` (`Apps/Harness/Sources/HarnessApp/Services/WorktreeAutoIsolateService.swift`)

---

## Why

Competitor review (2026-07-01) of Superset, cmux, Supacode found Harness's worktree isolation is **reactive**, not a **workflow**:

- `WorktreeAutoIsolateService` only fires when a tab's branch changes (`HarnessActiveTabGitBranchDidChange`) — it exists to stop cwd/branch bleed across tabs sharing one repo, not to let a user deliberately spin up an isolated agent task.
- Keyed by **branch name**, reused across tabs — correct for "don't corrupt git state," wrong for "give this agent its own sandbox."
- No lifecycle hooks (setup/teardown), no named-task concept, no explicit "New Task" entry point.

Superset: every task gets its own worktree+branch+working-dir from creation, with `.superset/config.json` setup/teardown scripts and `SUPERSET_WORKSPACE_NAME`/`SUPERSET_ROOT_PATH` env vars, switchable via ⌘1-9.

Goal: add an **explicit, task-first** worktree flow on top of the existing branch-reactive one — don't replace it, since the existing mechanism still needs to exist for tabs that manually switch branches outside the new flow.

---

## Non-goals (this plan)

- Diff viewer / changes panel (separate gap, not in scope here)
- Cross-pane agent notification panel (separate gap)
- PR status in sidebar (separate gap)
- Multi-agent "teams" orchestration UI (separate gap)

These are noted in the 2026-07-01 competitor review but tracked as future plans, not bundled into P32.

---

## Feature Specs

### F1 — Explicit "New Task" entry point — P0

- Command palette action (`PaletteAction`, section `.actions`) + sidebar button: "New Agent Task"
- Prompts for a task name (used as worktree folder + branch suffix)
- **Integration point confirmed by code read:** `SessionLifecycleService.addSession(to:cwd:name:)`
  (`Apps/Harness/Sources/HarnessApp/Services/SessionLifecycleService.swift:25`) is the existing
  path for "create a session at a cwd" — it already resolves `ProjectConfig`, calls
  `.newSession` on the daemon, syncs, and auto-runs `setupScript` (P24, line 60-68).
  New flow = call `WorktreeManager.create(repoPath:sessionID:baseRef:)` **first** to get
  `wtPath`, then call the existing `addSession(to:cwd: wtPath, name: taskName)` — do **not**
  build a parallel session-creation pipeline.
- `PaletteAction.handler` is a synchronous `() -> Void` closure — wrap the worktree-create +
  addSession call in a `Task { }` like every other palette action that touches the daemon.

### F2 — Task metadata model — P0

- `Tab` (`Packages/HarnessIPC/Sources/HarnessIPC/Tab.swift:43`) already has `worktreePath` +
  `parentRepoPath` but **no `taskName`** — confirmed by full-file read. Add `taskName: String?`
  next to `worktreePath`, same optional/backfill-to-nil pattern as the other v3+ fields in
  `init(from decoder:)` (see lines 145-147) so older `layout.json` snapshots still decode.
- Task name shown in tab title / sidebar instead of raw branch name when present (`displaySubtitle`
  at Tab.swift:107 already prefers `gitBranch` — extend that precedence: taskName > gitBranch > cwd).

### F3 — Per-project setup/teardown hooks — P1

**Correction from initial draft:** `ProjectConfig` already has `setupScript` and `archiveScript`
fields (`Packages/HarnessSettings/Sources/HarnessSettings/ProjectConfig.swift:7,11`) — no new
fields needed.
- `setupScript` is **already wired** for every new session via P24
  (`SessionLifecycleService.swift:60-68`) — a task-worktree session gets this for free once F1
  routes through `addSession`.
- `archiveScript` **exists in the schema but is never invoked anywhere** (confirmed by repo-wide
  grep — zero call sites besides the struct itself). Phase 3's real work is: wire up this
  already-dead field on explicit task close, before `WorktreeManager.remove`.
- No `HARNESS_TASK_NAME`/`HARNESS_TASK_ROOT` env vars needed as a new mechanism — `ProjectConfig.env`
  already supports arbitrary env injection per repo; only add task-specific vars if `archiveScript`/
  `setupScript` consumers actually need to distinguish a task run from a normal session (defer until
  Phase 3 implementation surfaces a real need).

### F4 — Task switcher — P2

- ⌘1-9 style quick-switch between active task worktrees (mirrors Superset's workspace switcher), scoped per-workspace like existing tab shortcuts

---

## Implementation Phases

### Phase 1 — Explicit create path (P0)

- [x] Add a `SessionLifecycleService` method (`addAgentTask(to:taskName:)`) that: sanitizes
      task name → `WorktreeManager.create(repoPath:sessionID:branch:baseRef:)` → calls existing
      `addSession(to:cwd: wtPath, name: taskName)` — reuses P24's `setupScript` auto-run for free
- [x] Wire "New Agent Task" into command palette as a `PaletteAction` in `.actions` section
      (prompts for task name via `NSAlert` + `NSTextField`, matching the existing
      `renameSession` pattern in `SidebarSessionListView.swift:362`)
- [x] New tab ends up cd'd into worktree path via the *existing* `addSession` cwd param — no
      manual `cd` needed (that's only for `WorktreeAutoIsolateService` moving an already-running
      shell; `addSession` creates the shell with the right cwd from the start)

Implemented: `SessionLifecycleService.swift` (`addAgentTask`), `SessionCoordinator.swift`
(delegation), `CommandPaletteController.swift` (`action.newAgentTask` handler + config entry).
`swift build --product Harness` clean.

Exit criteria: user can create a named task worktree without touching git branches manually; existing branch-reactive auto-isolate untouched.

### Phase 2 — Task metadata + UI (P0)

- [x] Add `taskName: String?` to `Tab` (`Tab.swift`), same optional-backfill decode pattern as
      `parentRepoPath`; `displaySubtitle` precedence now `taskName > gitBranch > cwd`
- [x] Sidebar row title (`SidebarSessionListView.displayTitle`) now prefers `tab.taskName` over
      `gitBranch` over `session.name` — matters when the raw task name differs from its
      sanitized branch (e.g. "Fix Login Bug" → branch `fix-login-bug`)
- [x] Unit test: `WorktreeIsolationTests.testSetWorktreeTagsTaskName` — creating a task tab sets
      both `worktreePath` and `taskName`

Bonus fix while threading this: `worktreePath`/`parentRepoPath` were never actually being passed
from the GUI's `addAgentTask` → `addSession` → `.newSession` IPC call (only the CLI's `harness`
tool did) — so Phase 1 tabs had `tab.worktreePath == nil` despite living in a worktree. Extended
`IPCRequest.newSession` and `SessionEditor.setWorktree` with a `taskName` param and wired
`addSession`/`addAgentTask` to pass `worktreePath`/`parentRepoPath`/`taskName` through for real.

Exit criteria: task-created tabs are visually distinguishable from branch-auto-isolated tabs. ✅
`swift build --product Harness` clean; `swift test --filter WorktreeIsolationTests` 10/10 pass.

### Phase 3 — Setup/teardown hooks (P1)

- [x] ~~`ProjectConfig` gains `taskSetup`/`taskTeardown`~~ — superseded by the F3 correction:
      no new fields, reuse existing `setupScript`/`archiveScript`.
- [x] Setup: already covered for free — `setupScript` auto-runs on every `addSession` call
      (P24, `SessionLifecycleService.swift:71-78`), and `addAgentTask` routes through
      `addSession`, so task-worktree sessions get it with zero new code.
- [x] Teardown: `archiveScript` was dead code (schema-only, zero call sites) — wired it into
      `SurfaceRegistry.handle(.closeSession)` (`Packages/HarnessDaemon/Sources/HarnessDaemon/
      SurfaceRegistry.swift`), right before `WorktreeManager.remove`, gated on the worktree
      being clean (same branch the existing removal check already takes). Added
      `WorktreeManager.runArchiveScript(_:cwd:env:timeout:)` — runs via `/bin/sh -c`, injects
      `config.env`, hard-killed via `DispatchSourceTimer` after 30s so a hanging project script
      can't freeze the daemon's synchronous IPC handler for other clients.
      `HarnessDaemonCore` gained a new dependency on `HarnessSettings` for `ProjectConfig`.
- [x] Unit test: `WorktreeIsolationDaemonTests.testCloseSessionRunsArchiveScriptBeforeRemoval`
      — archiveScript writes a marker file outside the worktree (so it's checkable after the
      worktree dir is gone) using an injected env var, asserts it ran with worktree cwd and
      completed before removal.

Exit criteria: a project with `archiveScript` in `harness.json` runs it automatically on
explicit task close, before the worktree is deleted. ✅ `swift build` clean; `swift test
--filter WorktreeIsolationDaemonTests` 10/10 pass; full `swift test` shows only the 2
pre-existing unrelated failures noted in CONTEXT.md; `Tests/robot/run.sh` 10/10 pass.

### Phase 4 — Task switcher (P2)

- [x] Already delivered by the existing `⌘1-9` binding (`MainMenuBuilder.swift:71-80`,
      `MenuTarget.selectWorkspaceNumber`) — it switches to the Nth entry of
      `workspace.sessions` by index, and `addAgentTask` creates task-worktree sessions as
      regular entries in that same list, so they're already reachable by number.
      Considered adding a task-only-filtered `⌘1-9`, but that would collide with (and break)
      the existing all-session binding for no net gain — confirmed with user, closing as-is
      rather than duplicating a working shortcut.

Exit criteria: matches Superset's workspace-switch ergonomics. ✅ via existing binding.

---

## Testing and Verification

- [x] `swift build --product Harness` clean after each phase
- [ ] `swift test --filter WorktreeManagerTests` — new tests for explicit create path
- [ ] `Tests/robot/run.sh` — no regressions in existing worktree/session guards
- [x] Manual (2026-07-01, preview build): New Agent Task from a repo tab → new tab "testing",
      branch `testing`, worktree at `.harness-worktrees/testing`, cwd correct. Also verified the
      failure path (active tab outside any git repo) now shows an `NSAlert` instead of silently
      no-oping — was a real bug found during this test pass, fixed in `SessionLifecycleService.
      addAgentTask` (now returns `String?` error) + `CommandPaletteController`'s handler.
- [ ] Manual: create 2 named tasks in same repo, confirm no cwd bleed between them and existing branch-reactive tabs still isolate correctly
- Follow-up fix this pass: `.harness-worktrees/` was not gitignored — added to `.gitignore` (worktree dirs were getting staged as regular files).

---

## Risks

- Two worktree-creation paths (branch-reactive + task-explicit) must not race or double-create for the same branch — reuse `existingWorktrees` lookup logic from `WorktreeAutoIsolateService` rather than duplicating it.
- Setup hook running arbitrary project-defined shell commands is a trust boundary — only run for projects the user has already opened/trusted, same assumption as existing `ProjectConfig` loading.

---

## First Implementation Slice

1. Add a `WorktreeManager`-based "create task" function callable directly from a command palette action (Phase 1), no metadata/UI/hooks yet.
2. Verify end-to-end: new task → new tab → new worktree → no interference with existing auto-isolate.
3. Layer in task name display (Phase 2), then hooks (Phase 3), then switcher (Phase 4) — one phase per session, per user's "ค่อยๆทำ" pacing.
