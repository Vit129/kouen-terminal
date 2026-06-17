# P16 — Agent/Session Board (Jira/Trello/Devin-Windsurf parity, GUI + Terminal)

Status: **DONE** — PBI-BOARD-001/002/003/004/005 complete; PBI-BOARD-006 closed (auto-clear sufficient)
in each PBI section and "Deferred PBIs" below).
Priority: **P3** — strategic, builds on [[p15-integration-roadmap]] step 3 (event bridge)
Owner surface: HarnessApp UI (new sidebar tab/panel) + harness-cli + harness-mcp (read-only)
Created: 2026-06-14

---

## Goal

Give Harness a **Kanban-style board view** over its own live sessions/tabs/panes —
similar to how Devin (Windsurf) shows a board of agent tasks, or Jira/Trello show
tickets in columns by status. Unlike those tools, the "cards" here are **live
terminal sessions and agent runs**, not externally-tracked tickets, and the board
must be usable from **both** the HarnessApp GUI and the terminal/CLI, consistent
with the "terminal first, IDE convenient" direction (P4/P10).

Example end state:

- GUI: a new sidebar tab (or dedicated panel) shows columns like *Running*,
  *Needs Attention*, *Idle*, *Done* — each card is a session/tab/pane with name,
  cwd, git branch, current command, and agent type if any. Clicking a card focuses
  that pane.
- CLI: `harness board` prints the same columns as a text table;
  `harness board --watch` live-updates in place (tmux/htop-style).
- Scripting (P11): `harness.board.list()` and a `boardChanged` event for
  `init.js` automations (e.g. toast when a card enters *Needs Attention*).
- MCP (P12): a read-only `harnessBoard` tool so an orchestrator agent can see what
  its sibling agents/panes are doing without parsing raw snapshots itself.

## Non-Goals

- No external sync (no Jira/Trello/Linear API integration). The board reflects
  **this machine's** live Harness state only.
- No persisted board state in `HarnessSettings` — board membership is derived from
  live snapshot + agent state, recomputed each time, per the same guidance P12
  PBI-ORCH-005 already follows ("should not be stored in `HarnessSettings`").
- Do not implement free-form drag-and-drop status changes. Columns are **derived**
  from live process/agent state (see "Column Model"), not user-assigned — dragging
  a card cannot make a running process finish. Any drag interaction is limited to
  *acknowledgement/dismissal* (see PBI-BOARD-006), not state mutation.
- Do not conflate this with P10's Makefile/`package.json` "Task Board Sidebar Tab"
  (a task **runner** — click to run a build/test target). That feature's "task" =
  a runnable command; this feature's "card" = a live session/pane. If both ship,
  rename one to avoid the name collision (suggest: P10's stays "Run Tasks", this
  feature is the "Board" or "Agent Board"). Note: a repo-wide search at planning
  time found no `TaskBoard`/"Task Board" symbols on `main`, so this collision may
  not yet be live — confirm before naming PBI-BOARD-002's UI.

## Current State

- `SessionCoordinator.shared.snapshot` already exposes `SessionGroup` → `Tab` →
  `PaneLeaf` with `id`, `name`, `cwd`, `title`, `gitBranch`, `currentCommand`
  (see `ScriptSnapshotModels.swift`'s `toJSDictionary()` for the exact fields
  already considered "safe to expose").
- P10 shipped a **Session State Dot** (blue=running, gray=idle, green=exit 0,
  red=error) driven by snapshot diffing — this is exactly the per-card status
  signal a board needs; reuse its classification logic rather than re-deriving it.
- P11's `harness.events` namespace (`agentStateChanged`, `notificationPosted`,
  `snapshotChanged`, etc.) is planned but **not yet implemented** — see
  [[p15-integration-roadmap]] step 3. This board's live-update path (PBI-BOARD-004)
  depends on that bridge existing.
- P12's `harnessList` MCP tool already flattens workspaces/sessions/tabs/panes with
  `agent` info — the board's data model should be a thin status-classification
  layer over the same shape, not a parallel snapshot walker.
- No Kanban/board UI exists anywhere in `HarnessApp` today.

## Column Model

Columns are derived, not stored. Initial default mapping (subject to the same
classification P10's Session State Dot already uses):

| Column | Derived from |
|--------|--------------|
| **Needs Attention** | `notificationPosted` for this pane not yet acknowledged, or agent state == waiting-for-input |
| **Running** | active process / agent state == running (blue dot) |
| **Idle** | shell idle, no foreground process (gray dot) |
| **Done** | last foreground process exited 0 (green dot) |
| **Error** | last foreground process exited non-zero (red dot) |

Swimlanes (optional, PBI-BOARD-002 stretch): group cards by workspace or session
group, so a board with multiple projects open doesn't interleave their cards.

## Architecture

```
SessionCoordinator.snapshot ──┐
P10 state-dot classification ─┼──► BoardModel (BoardColumn[BoardCard])
NotificationBus (P15 bridge) ─┘            │
                                            ├──► HarnessApp: BoardViewController (sidebar tab)
                                            ├──► harness-cli: `harness board` renderer
                                            ├──► harness.board (P11 ScriptAPI, read-only)
                                            └──► harness-mcp: harnessBoard tool (read-only)
```

`BoardModel` lives in `HarnessCore` so all four consumers (GUI, CLI, scripting,
MCP) share one classification implementation — avoids the P11/P12 "shared
primitives" duplication problem flagged in [[p15-integration-roadmap]].

## Implementation Plan

### PBI-BOARD-001: Board data model (read-only)

Files:

- New: `Packages/HarnessCore/Sources/HarnessCore/Board/BoardModel.swift`
  (`BoardColumn`, `BoardCard`, `classify(snapshot:) -> [BoardColumn]`)

Tasks:

- Define `BoardCard` (sessionID, tabID, paneID, title, cwd, gitBranch,
  currentCommand, agent info, column).
- Port P10's Session State Dot classification logic into `classify(...)` so both
  the dot and the board agree on status.
- Pure function over `WorkspaceSnapshot` — no daemon calls, no UI dependencies.

Tests:

- Snapshot fixtures → expected column assignment for each state-dot color.

**Done.** `BoardModel.swift` defines `BoardCard`, `BoardColumnKind` (5 cases,
`CaseIterable`, in canonical order Needs Attention/Running/Idle/Done/Error), and
`BoardColumn`. `classify(snapshot:)` always returns all 5 columns (even if empty)
and ports the exact P10 Session State Dot precedence (exit 0 → Done, exit non-zero
→ Error, non-shell `currentCommand` → Running, else Idle). 11 tests in
`BoardModelTests.swift`, all passing.

**"Needs Attention" simplification:** classified solely from
`tab.agent?.activity == .awaiting`, given precedence over exit-status-based
Done/Error. The Column Model table above also lists "unacknowledged
`notificationPosted`" as a Needs-Attention trigger, but that signal doesn't exist
yet — it depends on the same `harness.events`/`NotificationBus` bridge as
PBI-BOARD-004 ([[p15-integration-roadmap]] step 3). Per Non-Goals, no new
persisted/ack state was invented to fake it. Once the event bridge lands, extend
`columnKind(for tab:)` to also check unacknowledged notifications for that tab.

### PBI-BOARD-002: GUI board view

Files:

- New: `Apps/Harness/Sources/HarnessApp/UI/BoardViewController.swift`
- Touch: sidebar tab registration (wherever `HarnessSidebarPanelViewController`
  registers its tabs).

Tasks:

- Render `BoardModel.classify(...)` as horizontal Kanban columns of cards.
- Card click → focus the corresponding pane/tab/window (reuse existing
  focus/navigation helpers, not a new IPC path).
- Resolve the P10 task-runner naming collision noted in Non-Goals before adding
  the sidebar tab title.

Tests:

- Snapshot fixture → view renders expected card count per column (snapshot test
  or structural assertion, matching existing `HarnessAppTests` conventions).

**Done.** New `BoardViewController.swift` renders `BoardModel.classify(...)` as a
horizontally-scrolling `NSStackView` of columns, each a vertical stack of
`BoardCardView` cards (title, cwd/branch meta, current command, agent chip). Card
click reuses `SessionCoordinator.selectWorkspace`/`selectTab` — no new IPC path.
Refresh wired to `NotificationBus.shared.snapshotChanged`, same as other sidebar
panels.

**Naming decision:** used **"Board"** as-is. Re-confirmed via repo-wide search
that no `TaskBoard`/"Task Board" symbols exist on `main` — the collision flagged
in Non-Goals is not live, so no rename/"Agent Board" fallback was needed.

**Sidebar wiring:** `HarnessSidebarPanelViewController.sidebarTabs` went from
`["Sessions", "Files", "Git"]` to `["Sessions", "Files", "Git", "Board"]` (index
3). The previously-unreachable `case 3`/`case 4` (Search/Agent, for the shelved
ACP panel and unwired search panel) were shifted to indices 4/5 with an
explanatory comment — those views/cases are kept intact, just no longer collide
with the new Board tab. 3 structural tests in `BoardViewControllerTests.swift`.

### PBI-BOARD-003: CLI board view

Files:

- New: `Tools/harness/Sources/HarnessCLI/HarnessCLI+Board.swift`
- Touch: `HarnessCLI` command dispatch table, `docs/COMMANDS.md`.

Tasks:

- `harness board` — one-shot render of `BoardModel.classify(...)` against
  `.getSnapshot` as a text table (columns as sections, cards as rows).
- `harness board --watch` — subscribe to snapshot changes (existing subscription
  pattern from `AttachClient`/`ControlModeClient`) and re-render in place.

Tests:

- `HarnessCLITests`: snapshot fixture → expected table output (one-shot mode).

**Done.** New `HarnessCLI+Board.swift` adds `harness board` (one-shot, renders
`BoardModel.classify(...)` against `.getSnapshot` as a text table grouped by
column, "(none)" placeholder for empty columns) and `harness board --watch`
(subscribes via `client.subscribeSnapshot`, clears + re-renders on each
revision until the connection ends). Renderer factored into a pure
`renderBoard(_ columns:) -> String` for testability. Registered in the CLI
dispatch table, `CLICommandCatalog` (shell completion), and
`docs/COMMANDS.md`. 2 new tests in `BoardCommandTests.swift`.

### PBI-BOARD-004: Live updates via event bridge

Files:

- Touch: `BoardViewController.swift`, CLI `--watch` path.

Tasks:

- Depends on [[p15-integration-roadmap]] step 3 (`harness.events`/`NotificationBus`
  bridge). Subscribe `BoardViewController` and CLI `--watch` to the same bridge
  used by P11's `snapshotChanged`/`agentStateChanged` events — do not add a third
  polling/diffing implementation.

Tests:

- Integration: simulate a state-dot transition, verify board card moves column
  without a full re-snapshot poll.

**Deferred.** Not implemented in this pass — `harness.events`/`NotificationBus`
event bridge ([[p15-integration-roadmap]] step 3) does not exist yet, and this
PBI explicitly depends on it (per Rollout Order item 5, ordered after
PBI-BOARD-005). Both the GUI board tab (PBI-BOARD-002, refreshed via
`NotificationBus.shared.snapshotChanged` on a full reload — cheap enough for the
current handful of columns/cards) and `harness board --watch` (PBI-BOARD-003,
polls via `client.subscribeSnapshot` on every snapshot revision) already get
"live enough" updates through existing snapshot-change notifications; this PBI is
specifically about avoiding a full reclassify/re-render and instead moving a
single card between columns when its event fires. Revisit once the event bridge
lands — wire `BoardViewController` and the CLI `--watch` path to
`agentStateChanged`/`notificationPosted` instead of (or in addition to)
`snapshotChanged`.

### PBI-BOARD-005: Scripting + MCP read access

Files:

- Touch: `Apps/Harness/Sources/HarnessApp/Scripting/ScriptAPI.swift`
  (`harness.board.list()`)
- Touch: `Tools/harness-mcp/Sources/HarnessMCP/HarnessDaemonTools.swift`
  (`harnessBoard` tool), `ToolRegistry.swift`

Tasks:

- Both call `BoardModel.classify(...)` from `HarnessCore` — no reimplementation.
- `harnessBoard` is read-only; per P12's policy defaults, read-only tools are
  enabled without an allowlist entry.
- `harness.board.list()` returns the same JSON shape as `harnessBoard` for
  consistency between scripted automations and MCP agents.

Tests:

- `ScriptingTests`: `harness.board.list()` shape matches fixture.
- `HarnessMCPTests` (or equivalent): `harnessBoard` tool output matches fixture.

**Done.** `ScriptAPI.swift` adds `harness.board.list()` (same
`Codable`→`JSONEncoder`→`JSONSerialization`→`JSValue` pattern as
`harness.commands.parse`). `HarnessDaemonTools.swift` adds `harnessBoard()`
(`.getSnapshot` → `BoardModel.classify` → `AnyCodable` → `toolResult(json:)`),
registered in `ToolRegistry.listTools()` and the tool-dispatch switch. No
`ToolPolicy` changes needed — `harnessBoard` isn't in `dangerousTools`, so it's
allowed by default like `harnessList`. New test
`ScriptingTests.testBoardListReturnsAllColumns` (5 columns,
`kind === 'needsAttention'` first, default snapshot's 1 idle tab appears in the
`idle` column) and `HarnessDaemonToolsTests.testHarnessBoardIsReadOnlyAndRegistered`
(default policy allows it, `listTools()` includes it).

### PBI-BOARD-006 (stretch): Card acknowledgement/dismissal

Files:

- Touch: `BoardModel.swift` (ack/dismiss state), `BoardViewController.swift`,
  CLI board command.

Tasks:

- "Needs Attention" cards can be acknowledged (dismiss the notification without
  affecting the underlying session) — drag-to-dismiss in GUI, `harness board ack
  <id>` in CLI.
- Acknowledgement state is in-memory/runtime only (per Non-Goals), not persisted
  to `HarnessSettings`.
- Do **not** add a "kill from board" action in this PBI — if wanted later, route
  through `CommandIPCTranslator`'s existing `killPane`/`killSession` path behind
  the same policy gate P12 uses for mutating MCP tools, as its own PBI.

**Deferred.** Not started — per Rollout Order item 6, this stretch PBI only makes
sense once PBI-BOARD-001/002/003/005 are stable (done, this pass) **and**
PBI-BOARD-004's live-update path exists, since "acknowledging" a Needs Attention
card is most useful when the card can move/disappear from the board live without
a manual reload. Also blocked on the same missing
"unacknowledged-notification-per-pane" signal noted under PBI-BOARD-001 — there is
currently nothing to acknowledge beyond `AgentSnapshot.activity == .awaiting`,
which isn't a per-notification flag. Revisit after PBI-BOARD-004.

---

## Acceptance Criteria

- `BoardModel.classify(...)` in `HarnessCore` is the single source of truth for
  column assignment, used by GUI, CLI, `harness.board`, and `harnessBoard`.
- `harness board` and the GUI board tab show the same cards/columns for the same
  snapshot.
- No board state is persisted in `HarnessSettings`.
- P10's existing task-runner sidebar tab (if/when present) and this board do not
  share a confusing name.
- `swift build` passes; new tests in `HarnessCoreTests`, `HarnessCLITests`,
  `HarnessAppTests`, and scripting tests pass.

## Rollout Order

1. PBI-BOARD-001 (shared model) — do first, everything else depends on it.
2. PBI-BOARD-003 (CLI) — cheapest consumer, validates the model end-to-end without
   AppKit UI work.
3. PBI-BOARD-002 (GUI) — once CLI proves the model.
4. PBI-BOARD-005 (scripting + MCP read access) — can run in parallel with 2/3 once
   PBI-BOARD-001 lands.
5. PBI-BOARD-004 (live updates) — after [[p15-integration-roadmap]] step 3 ships
   the event bridge.
6. PBI-BOARD-006 (stretch) — only after the above are stable.
