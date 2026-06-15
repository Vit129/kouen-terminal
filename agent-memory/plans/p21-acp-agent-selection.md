# P21 — ACP Re-enable + Agent Selection (Terminal-First)

Status: **PBI-ACP-001 planned; PBI-ACP-002/003 partially done via AgentCatalog+AgentBridge**
Priority: **P1** — enables AI workflow without panel
Owner surface: HarnessApp, HarnessCore, harness-cli
Created: 2026-06-15
Depends on: P12 (MCP/ToolPolicy), P19 (workbench commands), AgentBridge

---

## Goal

Re-enable ACP in Harness so agents (Claude, Codex, Kiro, Gemini, Goose, etc.)
run **in terminal panes** with full tool access — user selects agent + model +
effort level from a single command. No chat panel, no GUI tab.

```bash
:agent --claude --model sonnet --effort high "fix tests"
:agent --kiro --effort low "add docs"
harness agent start --codex --model o3
harness agent list
harness agent send <file> --kiro
```

---

## How ACP Works (from research)

```
Editor (Harness)
    │ JSON-RPC over stdio
    ▼
Agent Adapter (claude-code-acp / codex-acp / kiro-cli --acp)
    │ internal
    ▼
AI Model (Claude Sonnet / GPT-4 / Gemini)
```

- **Local agents** spawn as subprocess, communicate via stdio JSON-RPC
- Agent gets tools: readFile, writeFile, runCommand, listDirectory
- Agent output streams back to editor
- Editor controls which tools are allowed (ToolPolicy — already have this)

---

## Agent + Model + Effort Selection

### Agent
```
--claude     → claude-code-acp adapter
--codex      → codex-acp adapter  
--kiro       → kiro-cli --acp
--gemini     → gemini-cli
--goose      → goose
```

### Model (per agent)
```
--model sonnet       (Claude: sonnet/opus/haiku)
--model o3           (Codex: o3/o4-mini)
--model flash        (Gemini: flash/pro)
```

### Effort
```
--effort high    → agent does deep analysis, multiple iterations
--effort medium  → balanced (default)
--effort low     → quick fix, single pass
```

Effort maps to agent-specific parameters:
- Claude: `--max-turns` / thinking budget
- Codex: `--effort` flag (native)
- Kiro: reasoning effort parameter

---

## Architecture

```
User: :agent --claude --model sonnet "fix tests"
         │
         ▼
AgentBridge (existing)
    │ 1. resolve agent adapter binary
    │ 2. spawn in split pane (existing splitActivePaneAndRun)
    │ 3. attach ACP client to pane's PTY
    ▼
ACPClient (re-enabled from #if HARNESS_ACP)
    │ 4. send tools (readFile/writeFile/runCommand from ToolPolicy)
    │ 5. send initial message with file context
    │ 6. stream output → terminal pane
    ▼
Agent works in terminal pane (user sees output live)
```

**Key insight:** agent runs in a normal terminal pane. ACP is the *sideband*
that gives it file/tool access. User sees agent thinking/working in the pane
like any CLI tool.

---

## Implementation Plan

### PBI-ACP-001: Re-enable ACP compilation

- Remove `#if HARNESS_ACP` guards
- Fix any compilation issues from shelved code
- Do NOT wire into UI yet — just compile

### PBI-ACP-002: Agent Registry + Install

- `~/.config/harness/agents.json` — registered agent adapters
- `harness agents list` — show installed agents
- `harness agents install <name>` — download/register adapter
- Auto-detect installed agents (check PATH for `claude`, `codex`, `kiro-cli`)
- Agent config: binary path, supported models, default model, effort mapping

```json
{
  "agents": [
    {
      "id": "claude",
      "binary": "/usr/local/bin/claude",
      "acpMode": "--acp",
      "models": ["sonnet", "opus", "haiku"],
      "defaultModel": "sonnet",
      "effortMap": {
        "low": "--max-turns 3",
        "medium": "--max-turns 10",
        "high": "--max-turns 30"
      }
    }
  ]
}
```

### PBI-ACP-003: Agent spawn with model/effort

- Update `:agent` ex command to accept `--model` and `--effort`
- Spawn agent with correct flags: `claude --model sonnet --max-turns 10 --acp`
- Agent runs in split pane (reuse existing `splitActivePaneAndRun`)

### PBI-ACP-004: ACP sideband attach

- When agent spawns with `--acp`, attach `ACPClient` to the pane
- ACPClient exposes tools through ToolPolicy (P12):
  - readFile (allowed by default)
  - writeFile (gated)
  - runCommand (gated)
  - listDirectory (allowed)
- Agent uses tools → Harness executes → returns results
- All while agent output streams to terminal pane normally

### PBI-ACP-005: Agent Selection UI

- `:agent` with no args → show picker: which agent + model + effort
- Command Palette (⌘P) type "agent" → see agent actions
- Settings → Agents → configure default agent/model/effort
- `harness agent start` — CLI equivalent

---

## User Flow Examples

### Quick fix (1 command)
```
:agent fix --claude --effort low
```
→ spawns Claude in split → sends current file + errors → Claude fixes → done

### Deep review
```
:agent review --kiro --model opus --effort high
```
→ spawns Kiro → sends file → Kiro does thorough review with multiple passes

### Interactive session
```
:agent --codex --model o3
```
→ spawns Codex in split → user types naturally in the pane → Codex responds

### From CLI
```bash
harness agent start --claude --model sonnet
harness agent send src/App.swift --message "add error handling"
harness agent list
```

---

## Non-Goals

- No chat panel / GUI sidebar for agent
- No streaming diff viewer (agent writes files directly)
- No ACP remote agents (local stdio only for v1)
- No agent marketplace/store
- No auto-run on save/commit

---

## Acceptance Criteria

- `swift build` passes without `HARNESS_ACP` flag
- User can select agent + model + effort from `:agent` command
- Agent spawns in terminal pane and works normally
- Tools are gated by ToolPolicy
- `harness agents list` shows installed agents
- Multiple agents can run simultaneously in different panes

---

## Rollout Order

1. PBI-ACP-001 — compile (remove flags)
2. PBI-ACP-002 — agent registry + install
3. PBI-ACP-003 — spawn with model/effort
4. PBI-ACP-004 — ACP sideband (tools)
5. PBI-ACP-005 — selection UI

---

## Implementation Progress (2026-06-15)

### ✅ PBI-ACP-002: Agent Registry (via AgentCatalog)
`AgentCatalog.swift` is the centralized config for all agents:
- Models, effort levels, CLI flags for claude/codex/kiro/gemini
- `spawnCommand(kind:model:effort:acp:)` builds correct spawn command
- Update only this file when agents release new models

### ✅ PBI-ACP-003: Agent spawn with model/effort
`:agent fix --kiro --model auto --effort high` → spawns `kiro-cli --model auto --effort high`

### ❌ PBI-ACP-001: Re-enable ACP compilation
`#if HARNESS_ACP` guards still in place. Remove when ready to wire tools.

### ❌ PBI-ACP-004: ACP sideband (tool access)
Agents currently use their own built-in tools (read/write file via shell).
ACP would give Harness permission control over tool calls.

### ❌ PBI-ACP-005: Agent Selection UI + `harness chat`
No picker UI yet. CLI flags (`--claude/--kiro/--model/--effort`) handle selection.

`harness chat` first-party branding (from P20) is also scoped here:
- `harness chat` → interactive picker: which agent + model + effort
- `harness chat --claude --model opus-4.8 "fix tests"` → one-shot
- Abstracts vendor names behind "Harness" brand if desired
- Depends on PBI-ACP-001 (re-enable ACP) for full tool integration
