# P15 — Integration Roadmap (P4 + P10 + P11 + P12 + P13/P14)

Status: **in progress** — Sequencing steps 1, 2, 3, and 6 done (P13, P4 Track 2/3,
the `harness.events` bridge, and P16 PBI-BOARD-001/002/003/005 all landed). Steps
4, 5, 7, and P16's PBI-BOARD-004/006 are now unblocked.
Priority: **P2** — sequencing/coordination plan, not a feature in itself
Owner surface: cross-cutting (HarnessCore, HarnessApp UI, harness-mcp, harness-cli)
Created: 2026-06-14, after P11 PBI-SCRIPT-001/002/003 and P13 PBI-SPLIT-001..005 landed

---

## Goal

P4, P10, P11, P12, and P13/P14 were planned somewhat independently (each from its own
"gap review" pass). Individually they are coherent; together several of them assume
the same underlying primitives (a pane/session command facade, the `PaneNode` split
tree, and an app-side event bus). This document is the integration map: which plans
share a primitive, what order avoids rework, and which open gaps from each plan are
now blocking another plan.

This is a **planning/sequencing** document. It does not introduce new features —
it cross-references existing plan docs ([[p4]], [[p10]], [[p11]], [[p12]], [[p13]])
and records the decisions needed to land them without duplicate or conflicting work.

## Non-Goals

- Do not re-litigate decisions already marked DONE in P11 PBI-SCRIPT-001/002/003 or
  P13 PBI-SPLIT-001..005.
- Do not redesign `PaneNode`, `CommandIPCTranslator`, or the daemon IPC surface here —
  those stay owned by their respective plans.
- Do not start P14 (embedded browser) work from this doc; it only notes where P14
  will plug in once P13 is merged.

---

## Current State Snapshot (2026-06-14, updated after PRs #10/#13–#19 merged)

| Plan | Status | Key deliverable |
|------|--------|-----------------|
| P4 — LSP + File View | **Done and merged** (PR #16, `worktree-p4-track23`). The divergent-docs gap noted below is resolved — `agent-memory/plans/p4-lsp-file-view.md` on `main` is now the single authoritative doc, marking Track 1/2/3 DONE. | Sidebar file viewer + `HarnessLSP` client, `ContentAreaViewController.showFileEditorSplit()` sibling panel (not a `PaneNode` leaf). |
| P10 — Performance & Feature Roadmap | Items 1-3 done (lazy reflow, local completion, keyboard layout presets). Item 4 (ACP sidebar) deferred. Also shipped: Session State Dot, IDE Mode Persistence, Task Board Sidebar Tab (Makefile/package.json runner), Focus Mode (⌘P). | `WorkspaceSymbolIndex`, `CompletionPopupView`, per-session state dot, Makefile/package.json task runner sidebar tab. |
| P11 — Scripting & Config API | PBI-SCRIPT-001/002/003 DONE (merged PR #15, JavaScriptCore runtime, reload lifecycle, read-only snapshot API + `commands.parse`). `harness.events` bridge (`snapshotChanged`/`configReloaded`) now done as part of P15 step 3. PBI-SCRIPT-004/005 (`harness.config.set`/`harness.keys`/mutating pane-session API, and remaining v1 events) not started. | `ScriptRuntime`, `ScriptHookCoordinator`, `ScriptAPI` (`harness.sessions`, `harness.panes`, `harness.commands.parse`, `harness.board`, `harness.events`). |
| P12 — Agent Orchestration via MCP | PBI-ORCH-001/002/003/004 DONE. PBI-ORCH-005 (UI visibility indicator) scoped only, no implementation — now unblocked by the P15 step 3 `harness.events`/`NotificationBus` bridge. | `harnessList`, `readPaneOutput`, `waitForPaneOutput`, gated mutating tools (`sendPaneText`, `sendPaneKeys`, `spawnSession`, `splitPane`, `closePane`), `ToolPolicy`, read-only `harnessBoard`. |
| P13 — Split Pane Parity | **Done and merged** (PR #10). PBI-SPLIT-001..005 implemented; top/bottom splits restored alongside side-by-side. | Vertical-split gate removed in `SessionCoordinator.splitActivePane`, "Split Down" UI affordances, CLI/docs parity, geometry + targeting tests. |
| P13 (alt doc) — Embedded Browser ("P14" in narrative) | Idea / not started. Explicitly depends on split panes landing first (P13 is now merged, so P14 can be scoped). | `WKWebView`-backed third `PaneNode` leaf kind. |
| P16 — Agent/Session Board | PBI-BOARD-001/002/003/005 **done and merged** (PRs #17–#19: `BoardModel`, `harness board` CLI, GUI "Board" sidebar tab, scripting `harness.board.list()` + MCP `harnessBoard`). PBI-BOARD-004/006 now unblocked by the P15 step 3 `harness.events`/`NotificationBus` bridge. | Shared `BoardModel.classify(snapshot:)` consumed by GUI/CLI/scripting/MCP. |

---

## Shared Primitives Map

Three primitives are referenced by name across multiple plans. Landing each one
once, in the right order, avoids three teams (or three agent sessions) building
slightly different versions.

### 1. The narrow pane/session command facade

- **P12** PBI-ORCH-002 built `sendPaneText`, `sendPaneKeys`, `spawnSession`,
  `splitPane`, `closePane` as MCP tools over existing `DaemonClientActor` IPC
  requests (`.send`, `.sendKeys`, `.newSession`, `.newSplit`, `.killPane`).
- **P11** PBI-SCRIPT-005 ("Mutating command/session/pane API") is explicitly gated:
  *"Do not start PBI-SCRIPT-005 until P12's MCP pane-control API is either
  implemented or deliberately deferred, because both features want the same narrow
  pane/session command facade."*
- **Status:** P12's facade is DONE (PBI-ORCH-002/004). **P11 PBI-SCRIPT-005 is now
  unblocked** — `ScriptAPI.swift` mutators (`pane.sendText`, `pane.split`,
  `pane.close`, `session.spawn`) should call the *same* `CommandParser` +
  `CommandIPCTranslator` + `DaemonClientActor` path that `HarnessDaemonTools.swift`
  uses for MCP, not a third implementation. Concretely: factor the
  direction-parsing / IPC-dispatch helpers in `HarnessDaemonTools.swift` so both
  `harness-mcp` and `ScriptAPI` (app-side, `@MainActor`) can call into them, or at
  minimum keep both call sites going through `CommandIPCTranslator` with identical
  direction-mapping so `harness.panes.split({direction: "right"})` and MCP's
  `splitPane({direction: "right"})` agree.

### 2. The `PaneNode` split tree (P13 → P14, P4's file editor)

- **P13** (done) restored `.vertical`/`.horizontal` splits end-to-end through
  `PaneNode`, `SessionCoordinator.splitActivePane`, `HarnessSplitView`, and CLI.
- **P13-embedded-browser** ("P14") explicitly depends on P13 landing first and
  notes the file-editor split is "currently a sibling panel, *not* part of the
  `PaneNode` tree" and "may need to become a `PaneNode` case."
- **P4**'s `ContentAreaViewController.showFileEditorSplit()` is that same sibling
  panel. Any future work that promotes the file editor into `PaneNode` (for P14
  parity, or to fix the editor/sidebar coupling noted below) touches P4, P10's IDE
  Mode layout presets, and P14 simultaneously — scope that as its own PBI rather
  than folding it into any one of those plans silently.
- **Status:** P13 merge is the gate. Once `worktree-p13-split-pane` is reviewed and
  merged, P14 can be scoped concretely (current doc is "idea / not started").

### 3. The app-side event bus (`harness.events`, `NotificationBus`, MCP visibility)

- **P11**'s "Public JS API v1" defines `harness.events.on(name, handler)` with v1
  events including `snapshotChanged`, `sessionCreated`, `agentStateChanged`,
  `notificationPosted` — this namespace was an explicit **gap**, called out
  directly in PBI-SCRIPT-003's notes.
- **P12** PBI-ORCH-005 (scoped only) proposes a "MCP-controlled" indicator driven by
  "the normal `NotificationBus.snapshotChanged` path or a narrow new notification
  emitted when the daemon accepts MCP-originated control," explicitly *not*
  persisted in `HarnessSettings`.
- **P10** shipped a Session State Dot (blue=running/gray=idle/green=exit0/red=error)
  driven by snapshot diffing — the same signal `agentStateChanged` would carry.
- **Status: DONE.** The `harness.events` bridge is implemented as the single
  fan-out point from `NotificationBus`:
  - `NotificationBus` gained `configReloaded` (`postConfigReloaded()`), alongside
    the existing `snapshotChanged` (`postSnapshotChanged(revision:)`).
  - `ScriptRuntime` (an `NSObject` subclass) registers `NotificationCenter`
    observers for both in `registerNotificationBridge()` and removes them in
    `deinit`.
  - `ScriptAPI.swift` adds `harness.events.on(name, handler)` /
    `harness.events.off(name, handler?)`, storing JS handlers per event name on
    the owning `ScriptRuntime`.
  - `ScriptRuntime.dispatchEvent(name:payload:)` invokes handlers serially on
    `@MainActor`, catches/logs JS exceptions, and surfaces at most one toast per
    script load (`hasReportedEventError`) to avoid toast spam.
  - `ScriptHookCoordinator.loadScript` calls `NotificationBus.shared
    .postConfigReloaded()` after every successful (re)load — initial and reload —
    so a script's own `harness.events.on("configReloaded", ...)` handler observes
    the load that just happened.
  - v1 implements `snapshotChanged` and `configReloaded` only (the acceptance bar
    for this step). The remaining P11 v1 events (`sessionCreated`, `sessionClosed`,
    `tabCreated`, `tabClosed`, `paneExited`, `agentStateChanged`,
    `notificationPosted`) have no direct `NotificationBus` signal today — they
    require snapshot-diffing (the same derivation P10's Session State Dot already
    does) and are left for follow-up scripting work, not this step.
  - P12 PBI-ORCH-005 and any future "board" feature (see [[p16-task-board]]) can
    now subscribe to the same `NotificationBus` → bridge pattern rather than
    re-deriving state from raw snapshot diffs independently.
  - Tests: `Tests/HarnessAppTests/ScriptingTests.swift` —
    `testEventsOnDispatchesHandlerWithPayload`, `testEventsOffRemovesHandler`,
    `testEventsHandlerErrorDoesNotCrashOrLeakException`,
    `testNotificationBusConfigReloadedReachesScriptHandler`.

---

## Known Gap: Divergent P4 Docs — RESOLVED

`agent-memory/plans/p4-lsp-file-view.md` previously differed between `origin/main`
(older doc, "Track 2 — Quick Look Preview" / "Track 3 — LSP Integration" framed as
not started) and `worktree-p4-track23` (rewritten doc, "Track 1/2/3 DONE"). This was
resolved by merging `worktree-p4-track23` to `main` (PR #16) — there is now one
authoritative P4 doc and one authoritative `ContentAreaViewController`/`HarnessLSP`
implementation to integrate against.

---

## Recommended Sequencing

1. ✅ **Merge P13** (PR #10) — unblocks P14 scoping and is a
   prerequisite for any `PaneNode` changes touched by P4/P10/P14 integration. Done.
2. ✅ **Merge P4 Track 2/3** (PR #16) — reconciles the divergent P4
   docs; gives P14 and the file-editor/`PaneNode` question one ground truth. Done.
3. ✅ **Build the `harness.events` bridge** (remaining P11 gap) — single
   `NotificationBus`-backed fan-out (`snapshotChanged`, `configReloaded`) used by
   P11 scripts, with P12 PBI-ORCH-005's MCP indicator and the board feature
   ([[p16-task-board]]) able to subscribe to the same pattern. Done — see "Shared
   Primitives Map" item 3 for implementation details.
4. ⬜ **P11 PBI-SCRIPT-004/005** — config/keybinding writes and mutating pane/session
   API, reusing P12's command facade per "Shared Primitives Map" item 1. Not started.
5. ⬜ **P12 PBI-ORCH-005** — MCP-controlled indicator. Unblocked by step 3.
6. ✅ **P16 (board feature)** — read-only PBI-BOARD-001/002/003/005 merged
   (PRs #17–#19); PBI-BOARD-004/006 are now unblocked by step 3.
7. ⬜ **P14 (embedded browser)** — step 1 is done; the file-editor
   `PaneNode` question from step 2 is now resolvable since P4 is merged (a
   `WKWebView` leaf and a promoted file-editor leaf are the same kind of change; do
   them together or in the same PBI sequence to avoid two separate `PaneNode`
   migrations). Not started.

## Acceptance Criteria

- A single, current P4 plan doc exists on `main` (no divergent copies).
- ✅ `harness.events` bridge exists, is used by at least P11's `configReloaded`/
  `snapshotChanged` events, and is documented as the integration point for P12
  PBI-ORCH-005 and P16.
- P11 PBI-SCRIPT-005 mutators and P12's MCP mutating tools share direction-parsing
  and IPC-dispatch code (no duplicated `CommandIPCTranslator` call sites with
  diverging direction maps).
- P14 scoping doc references the resolved file-editor/`PaneNode` decision instead
  of leaving it as an open question.
