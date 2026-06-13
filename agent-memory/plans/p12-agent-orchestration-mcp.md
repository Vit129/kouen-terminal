# P12 — Agent Orchestration via MCP (cmux parity)

Status: **idea / not started**
Priority: **P2** — biggest capability gap vs cmux; builds on existing `harness-mcp`
Depends on: none (deliberately *not* the shelved ACP path — see "Relationship to ACP" below)
Gap source: WezTerm/tmux/cmux comparison (2026-06-13) — cmux's defining feature is a socket/CLI
API that lets an AI agent drive multiple panes (spawn, run, read, get notified). Harness has the
IPC primitives (`DaemonClient`, `CommandIPCTranslator`, `harness-mcp`) but `harness-mcp` today only
exposes filesystem/git tools, not pane/session control.

---

## Goal

Extend `harness-mcp` so an external agent (Claude Code, Codex, etc. — *running outside* Harness,
talking over MCP) can: list sessions/panes, spawn a new pane/session, send input to a pane, read
its scrollback/output, and get notified when a command finishes — i.e. the cmux "control plane"
experience, without needing ACP adapter binaries inside the app.

## Relationship to ACP ([[acp-client]])

ACP was shelved because Harness-as-ACP-**client** requires adapter binaries + PATH resolution
inside a sandboxed .app + has no tool-control story. This plan is the **inverse direction**:
Harness-as-MCP-**server**, called by an agent that's already running in a normal shell (so PATH/
adapter problems don't apply). PBI-004 (tool allowlist) below also directly addresses ACP
shelving reason #3 ("no tool control") and could later de-risk re-enabling ACP.

## Current State

- `Tools/harness-mcp/Sources/HarnessMCP/ToolRegistry.swift` (211 LOC) — tools: `readFile`,
  `writeFile`, `listDirectory`, `runCommand`, `gitStatus`, `gitDiff`, `gitLog`
- `harness-mcp` depends only on `HarnessCore` per `CLAUDE.md` — currently operates on the
  filesystem directly, **not** connected to `HarnessDaemon`
- `DaemonClient` / `DaemonClientActor` (P2, done) already provide async session/pane queries used
  by the GUI — same surface this plan would reuse

## Architecture

```
External Agent (Claude Code / Codex CLI, in a normal shell)
    │ MCP (JSON-RPC over stdio)
    ▼
harness-mcp (ToolRegistry — extended)
    │ Unix socket IPC (existing DaemonClient)
    ▼
HarnessDaemon (SurfaceRegistry — sessions/panes already exist)
```

## PBIs

### PBI-ORCH-001: harness-mcp ↔ daemon connection
- Add `DaemonClient` (or `DaemonClientActor`) to `harness-mcp`'s dependencies
- New tools: `listSessions`, `listPanes` — read-only, mirrors sidebar session list

### PBI-ORCH-002: Pane spawn & input
- `spawnPane(workspaceId, command?)`, `sendKeys(paneId, text)` — routed through
  `CommandIPCTranslator` the same as GUI actions

### PBI-ORCH-003: Output read-back
- `readPaneOutput(paneId, lines?)` — snapshot of scrollback/visible grid (reuse
  `HarnessTerminalEngine` grid access, virtual-line indexing per RL-025)
- `waitForIdle(paneId, timeoutMs)` — polls output-changed / exit-code (builds on
  `SurfaceShellTracker`, already does process-tree scanning)

### PBI-ORCH-004: Tool allowlist / confirmation gate
- Config flag (per-workspace) restricting which MCP tools an agent session may call
  (`readPaneOutput` always allowed, `runCommand`/`sendKeys` opt-in)
- Addresses the "no tool control" gap that blocked ACP

### PBI-ORCH-005: Visibility — "agent-controlled" badge
- Sidebar session card shows a badge when a pane has an active MCP-driven session attached
  (small UI addition to existing session-state-dot mechanism)

## Key Files

```
Tools/harness-mcp/Sources/HarnessMCP/
├── ToolRegistry.swift          — extend dispatch (PBI-ORCH-001/002/003)
├── PaneControlTools.swift      — new: spawn/sendKeys/readOutput/waitForIdle
└── ToolAllowlist.swift         — new: per-workspace tool gating (PBI-ORCH-004)

Packages/HarnessCore/Sources/HarnessCore/IPC/
└── DaemonClient.swift           — reused as-is; confirm harness-mcp can link against it
```

## Estimate

3–4 sessions (daemon connection + spawn/input + output read-back + allowlist + badge)
