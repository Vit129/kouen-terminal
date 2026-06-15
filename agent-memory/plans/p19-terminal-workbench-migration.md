# P19 — Terminal Workbench Migration Layer

Status: **DONE** — PBI-WB-001..007 fully implemented and merged to main.
Priority: **P2** — product/workflow bridge for IDE migrants, built on P4/P11/P12/P16
Owner surface: HarnessApp UI, HarnessCLI, HarnessCore workflow commands, scripting/MCP integration
Created: 2026-06-14
Depends on:

- [[p4-lsp-file-view]] for vi-style file/code navigation
- [[p11-scripting-config-api]] for user-configurable workflow glue
- [[p12-agent-orchestration-mcp]] for external agent pane/session control
- [[p16-task-board]] for live session/agent visibility
- [[p15-integration-roadmap]] event bridge for live attention/automation flows

---

## Goal

Make Harness easy for users moving from an IDE to a terminal-first workflow
without turning Harness into a full IDE.

The target user can already remember basic `vi`, shell, and Unix commands. The
gap is that real work needs IDE-like context: fast file discovery, jump-to-source,
project errors, running task state, agent/session visibility, and repeatable
workflow shortcuts. P19 adds a **Terminal Workbench** layer: commands, overlays,
board state, and scriptable bindings that keep the terminal primary while
removing the avoidable friction of memorizing every project command and path.

Example end state:

```text
:workbench start swift
:find SessionCoordinator
:grep BoardModel
:make test BoardModelTests
:errors
:recent
:copy-path
:board
```

And in config:

```js
harness.keys.bind("root", "Cmd-P", "find")
harness.keys.bind("root", "Cmd-B", "board")
harness.keys.bind("root", "Cmd-Shift-T", "make test current-file")
harness.events.on("taskFailed", event => harness.toast(event.summary))
```

---

## Product Direction

Harness stays **terminal + Unix + vi first**.

This plan should make common IDE workflows available as terminal-native actions:

- Find files and symbols without leaving the current pane.
- Jump from compiler/test output to source with `gf` and related motions.
- Run project tasks through deterministic commands rather than GUI-only buttons.
- Show live process/agent state in a board, but keep cards derived from real
  session state.
- Let users bind their own workflow shortcuts through the scripting layer.
- Let agents use the same primitives through MCP, not a separate chat sidebar.

The right mental model is not "VS Code inside Harness." It is "tmux + vi + Unix
tools with a narrow context layer that remembers the project for you."

---

## Non-Goals

- Do not add debugger panels, breakpoints, watch variables, or call stacks.
- Do not add a persistent IDE project model.
- Do not make file panels the primary editing surface.
- Do not make task/board cards user-assigned status tickets. Status is derived
  from live processes, agent state, diagnostics, and notifications.
- Do not execute project-local scripts automatically.
- Do not make scripting mandatory for normal startup.
- Do not duplicate MCP/script/CLI implementations of workflow commands; shared
  command primitives should live once and be consumed by each surface.

---

## Current State

- P4 already shipped terminal-first file viewing and lightweight LSP:
  `harness view`, `harness lsp ...`, `gf`, `gd`, `K`, `]d`/`[d`,
  `:find`, `:view`, `:edit`, `:split`, and `:vsplit`.
- P4 explicitly deferred `:recent`, `:cd`/`:mark`, `:copy-path`, `:grep`, and
  `:make`, which are exactly the missing daily-workflow bridge commands.
- P11 has runtime/config discovery/reload/read-only snapshot APIs done, but
  config/keybinding writes, `harness.events`, and command/session/pane mutators
  are not done.
- P12 has MCP read/control/wait/policy tools done, with UI visibility scoped but
  not implemented.
- P16 has shared board model, GUI board, CLI board, scripting board list, and MCP
  board list done. Live event-driven movement and acknowledgement/dismissal are
  deferred.

---

## User Jobs

### 1. Open and move through code quickly

The user wants to think in partial names and output paths, not full absolute
paths.

Required primitives:

- `:find <query>`
- `:recent`
- `:copy-path`
- `gf` from terminal/compiler/test output
- `gd`, `K`, `]d`/`[d` when LSP exists
- `harness view <file>` and future `harness cat --highlight`

### 2. Run the right project command without memorizing it

The user wants a stable command vocabulary that maps to repo-specific tools.

Required primitives:

- `:make`
- `:make test`
- `:make test current-file`
- `:make build`
- `:errors`
- `:open-output`
- command aliases loaded from script/config

### 3. Know what is happening now

The user wants to see whether builds, tests, agents, and sessions are running,
idle, failed, done, or awaiting input.

Required primitives:

- GUI Board tab
- `harness board`
- `harness board --watch`
- event-driven Needs Attention updates
- acknowledgement/dismissal for attention cards
- transient MCP-controlled/agent-controlled indicator

### 4. Personalize muscle memory

The user wants to keep IDE keyboard habits while executing terminal-native
commands.

Required primitives:

- `harness.keys.bind(...)`
- `harness.commands.run(...)`
- `harness.events.on(...)`
- project-safe built-in profiles, not project-auto-executed scripts

### 5. Let agents participate without hijacking the UI

The user wants agents to inspect and drive panes using the same workflow state
humans see.

Required primitives:

- MCP `harnessBoard`
- MCP pane read/send/wait tools
- MCP policy gate
- shared workbench command facade
- visible "agent/MCP touched this pane" runtime signal

---

## Architecture

```
P4 vi/LSP/file commands ─┐
P16 BoardModel          ├──► WorkbenchCommandFacade
P12 MCP pane tools      │         │
P11 ScriptRuntime       ┘         ├──► HarnessApp command palette / ex commands
                                  ├──► HarnessCLI workbench commands
                                  ├──► harness.commands.run(...)
                                  └──► harness-mcp tools where safe

SessionCoordinator.snapshot ─┐
NotificationBus events       ├──► WorkbenchEventBridge
LSP diagnostics/task output  ┘         │
                                       ├──► Board live movement
                                       ├──► :errors / taskFailed
                                       └──► script events/toasts
```

Key rule: workflow classification and command translation should be shared.
The GUI, CLI, scripting API, and MCP tools should not each invent their own idea
of "current file", "current task", "failed task", or "needs attention."

---

## Workbench Command Vocabulary

### Navigation

| Command | Meaning |
|---------|---------|
| `:find <query>` | Fuzzy-open file by fragment (already shipped in P4). |
| `:recent` | Show MRU file/session paths and open by index/query. |
| `:copy-path [relative|absolute]` | Copy current file or pane CWD path. |
| `:cd <path|mark>` | Change pane/workspace CWD using path or saved mark. |
| `:mark <name> <path>` | Save a local path mark. |

### Search and errors

| Command | Meaning |
|---------|---------|
| `:grep <query>` | Run project search and show terminal-first ranked results. |
| `:errors` | Show latest diagnostics/build/test errors as navigable paths. |
| `:open-output` | Focus or split to the latest task output pane. |

### Tasks

| Command | Meaning |
|---------|---------|
| `:make` | Run default project build/test command. |
| `:make build` | Run configured build command. |
| `:make test` | Run configured test command. |
| `:make test current-file` | Run nearest file/test target when detectable. |
| `:make last` | Repeat last workbench task. |

### State

| Command | Meaning |
|---------|---------|
| `:board` / `harness board` | Show live session/agent/task board. |
| `:attention` | Jump to the next Needs Attention card/pane. |
| `:ack` | Acknowledge current attention item when supported. |

---

## Configuration Model

P19 should not introduce a new persistent settings store. It should layer on top
of P11 and existing stores:

- static settings remain in `HarnessSettings`
- keybindings remain in `KeybindingsStore`
- tmux-style options remain in `OptionStore`
- script config is `~/.config/harness/init.js`
- project task detection is read-only unless the user explicitly binds a command

Future optional profile:

```js
harness.profiles.use("ide-migrant-terminal")
```

This profile should only bind local UI/command behavior. It must not run
project-local scripts or shell commands automatically.

---

## Implementation Plan

### PBI-WB-001: Shared workbench command facade

Files:

- New: `Packages/HarnessCore/Sources/HarnessCore/Workbench/WorkbenchCommand.swift`
- New: `Packages/HarnessCore/Sources/HarnessCore/Workbench/WorkbenchContext.swift`
- Touch: app-side ex command routing only where needed

Tasks:

- Define shared command intent types for navigation/search/task/state commands.
- Define a narrow context model: current workspace, session, tab, pane, cwd,
  current file if known, last task pane if known.
- Keep command parsing deterministic and testable.
- Do not run shell commands in HarnessCore; return an intent that app/CLI can
  execute through existing command/IPC paths.

Tests:

- Parse/normalize command intents.
- Current-file/current-cwd fallback behavior.
- Unknown command errors are stable and user-readable.

### PBI-WB-002: P4 daily navigation follow-ups

Files:

- Touch: `ViNormalMode.swift`
- Touch: `SyntaxTextView.swift` only if command/status plumbing needs it
- Touch: CLI docs and command catalog as needed

Tasks:

- Implement `:recent` with MRU file paths and session paths.
- Implement `:copy-path [relative|absolute]`.
- Implement `:cd <path|mark>` and `:mark <name> <path>`.
- Add `harness cat --highlight` if the ANSI renderer can reuse P4 syntax logic
  without heavy AppKit coupling; otherwise defer renderer extraction explicitly.

Tests:

- Ex-command parsing and status messages.
- MRU ordering and dedupe.
- Path copy/cd/mark edge cases.

### PBI-WB-003: Project task runner commands

Files:

- New: `Packages/HarnessCore/Sources/HarnessCore/Workbench/ProjectTaskDetector.swift`
- New: `Packages/HarnessCore/Sources/HarnessCore/Workbench/WorkbenchTask.swift`
- Touch: `Tools/harness/Sources/HarnessCLI`
- Touch: app command/ex routing

Tasks:

- Detect safe, common task sources: `Package.swift`, `Makefile`,
  `package.json`, `justfile`, `Taskfile.yml`.
- Implement `:make`, `:make build`, `:make test`, `:make last`.
- Run tasks in terminal panes, not hidden background jobs.
- Capture task metadata: command, cwd, surfaceID, start time, exit status.
- Do not invent a GUI task-runner panel in this PBI.

Tests:

- Detector fixtures for SwiftPM/Make/npm/just.
- Command selection precedence.
- `:make last` repeats exact command/cwd.

### PBI-WB-004: Search/errors surface

Files:

- Touch: workbench facade and ex routing
- Touch: LSP diagnostics integration if needed
- Touch: board/task metadata if task failures should create attention events

Tasks:

- Implement `:grep <query>` using existing shell tools where possible.
- Implement `:errors` combining:
  - latest LSP diagnostics when available
  - latest task output path:line:col matches
  - compiler/test output captured from task panes
- Make every result navigable via `gf`-compatible path tokens.
- Keep raw command output accessible and unmodified.

Tests:

- Parse common `path:line:column: message` formats.
- `:errors` ordering and dedupe.
- No diagnostics available yields a clear status message, not a dialog.

### PBI-WB-005: Event bridge for workbench state

Files:

- Touch: `NotificationBus`
- Touch: P11 `ScriptAPI.swift`
- Touch: P16 `BoardViewController.swift`
- Touch: CLI board watch path only if needed

Tasks:

- Land the minimal event bridge needed by P11 and P16:
  - `snapshotChanged`
  - `taskStarted`
  - `taskFinished`
  - `taskFailed`
  - `agentStateChanged`
  - `notificationPosted`
- Let Board move cards from events without relying only on full refreshes.
- Let scripts observe `snapshotChanged` and run harmless commands.
- Keep event payloads bounded and serializable.

Tests:

- Script can observe `snapshotChanged`.
- Simulated task failure emits `taskFailed` and updates board state.
- Event handler errors are caught and surfaced once per reload cycle.

### PBI-WB-006: Attention workflow

Files:

- Touch: `BoardModel.swift`
- Touch: `BoardViewController.swift`
- Touch: `HarnessCLI+Board.swift`
- Touch: scripting/MCP board JSON shape if needed

Tasks:

- Add runtime-only attention acknowledgements.
- Implement `harness board ack <id>` and `:ack`.
- Implement `:attention` to focus the next Needs Attention card/pane.
- Add a transient MCP/agent-touched indicator after mutating MCP requests.
- Do not persist acknowledgement state in `HarnessSettings`.

Tests:

- Acknowledgement hides/demotes an attention item without changing process state.
- `:attention` focuses the expected pane.
- Read-only board APIs remain available without MCP policy changes.

### PBI-WB-007: Scriptable IDE-migrant profile

Files:

- Touch: P11 script API
- New: built-in profile definition if an existing profile mechanism exists;
  otherwise document as sample `init.js`
- Touch: docs

Tasks:

- Implement enough `harness.keys.bind`, `harness.config.set`, and
  `harness.commands.run` for a user to map IDE muscle memory to workbench
  commands.
- Provide an opt-in sample profile:
  - Cmd-P -> find
  - Cmd-B -> board
  - Cmd-Shift-T -> make test current-file
  - Cmd-Shift-B -> make build
  - Cmd-E -> errors
- Keep startup unchanged when no config/profile is present.

Tests:

- Valid keybinding writes persist.
- Invalid commands fail without partial writes.
- Profile load is opt-in and does not run shell commands.

---

## Rollout Order

1. PBI-WB-001 shared command facade.
2. PBI-WB-002 navigation follow-ups (`:recent`, `:copy-path`, marks).
3. PBI-WB-003 task runner commands (`:make ...`) in terminal panes.
4. PBI-WB-004 `:grep` and `:errors`.
5. PBI-WB-005 event bridge for P11/P16.
6. PBI-WB-006 attention workflow and MCP/agent visibility.
7. PBI-WB-007 scriptable IDE-migrant profile.

The event bridge is intentionally after basic task/search commands because it
needs real task/error events to be useful. If P11/P16 need it sooner, PBI-WB-005
can move earlier as a standalone infrastructure slice.

---

## Acceptance Criteria

- `swift build` passes.
- Existing P4/P11/P12/P16 behavior is preserved.
- A user can open/search/jump around a repo from vi/ex-style commands without
  memorizing full paths.
- A user can run build/test tasks in terminal panes through `:make` commands.
- Failed tasks and diagnostics are reachable through `:errors` and `gf`.
- Board/CLI/script/MCP surfaces agree on live session/task/attention state.
- No project-local script is auto-executed.
- No new debugger/IDE workbench panel is added.

---

## Risks

- Task detection can become too magical. Keep detection conservative and expose
  the selected command before running.
- Event payloads can grow too large. Use IDs and summaries, not full scrollback.
- `:errors` can become noisy if it merges diagnostics and task output badly.
  Prefer stable ordering and dedupe over aggressive inference.
- Script/keybinding writes can overlap with P11. Keep P19 as the product layer
  and implement the underlying mutation primitives in P11-compatible APIs.
- MCP control visibility needs daemon-origin metadata. If that is too invasive,
  start with transient app-side notification state.

