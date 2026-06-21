# P26 — Agent Connection: MCP + Terminal Chat (Warp-style)

Status: **Design**
Priority: MCP wiring = P1 (config-only) · Terminal Chat = P1 (core feature) · ACP sidebar = P3 (deferred)
Created: 2026-06-21
Depends on: P12 (MCP shipped), P5 (ACP code preserved)

---

## Problem

Code for both paths is complete, but neither is connected — and the chat UX direction has changed:

| Path | Direction | Code state | Connection state |
|------|-----------|------------|-----------------|
| MCP (`harness-mcp`) | agent → Harness | Shipped, binary built | NOT in any agent MCP config |
| Terminal Chat (new) | user → agent inline | Not built | New feature — Warp-style inline AI blocks |
| ACP sidebar | Harness → agent sidebar | `#if HARNESS_ACP` gated | Deferred — replaced by terminal chat |

**Direction:** User wants AI in the terminal pane itself, not a sidebar. Type like `cd` or `z`,
AI response appears as an inline styled block — same UX as Warp AI.

---

## Path A: MCP (agent→Harness) — P1, near-term

### What exists

- Binary: `.build/release/harness-mcp` (or inside `Harness.app/Contents/MacOS/`)
- 27 tools, policy gating, JSON-RPC 2.0 over stdin/stdout
- Works as soon as the Harness daemon is running

### What's missing

**1. Stable install location**

The binary lives in `.build/release/` which changes on every build. Agents need a path that
survives rebuilds. Two options:

| Option | Path | Pro | Con |
|--------|------|-----|-----|
| A — App bundle | `Harness.app/Contents/MacOS/harness-mcp` | Self-contained, no install step | Requires prod build to test |
| B — `harness-cli install-mcp` | `~/.local/bin/harness-mcp` → symlink | Works with debug builds | Extra install step |

**Recommendation: A** — bundle inside `Harness.app`, same as HarnessDaemon and harness-cli today.
Add to `make install` and `Scripts/build-release.sh` packaging. For dev: use `.build/debug/harness-mcp` path directly in MCP config.

**2. Agent MCP config wiring**

Each agent needs an entry. `harness-mcp` speaks stdio, so the pattern is identical for all:

```json
// Claude Code: ~/.claude.json  →  mcpServers
"harness": {
  "type": "stdio",
  "command": "/Applications/Harness.app/Contents/MacOS/harness-mcp",
  "env": {}
}
```

```json
// Codex: ~/.codex/config.toml  (mcpServers table)
[mcpServers.harness]
type = "stdio"
command = "/Applications/Harness.app/Contents/MacOS/harness-mcp"
```

```
// Kiro: .kiro/settings/mcp.json
{ "harness": { "command": "/Applications/Harness.app/Contents/MacOS/harness-mcp" } }
```

**3. Policy file**

Control tools are blocked by default. Create once:

```json
// ~/Library/Application Support/Harness/mcp-policy.json
{
  "version": 1,
  "allowControl": true
}
```

Or set `HARNESS_MCP_ALLOW_CONTROL=1` in the agent MCP env block (per-agent override).

**4. CLI install helper (optional but good UX)**

```
harness-cli mcp setup
```

Should: detect which agents are installed → write their config entries → write policy file →
print confirmation. Removes manual JSON editing.

### Connection flow (after setup)

```
Claude Code / Codex / Kiro
  ↓ spawns process
harness-mcp (stdio)
  ↓ DaemonClient.connect(Endpoint.unix)
HarnessDaemon (running)
  ↓ session/pane/file/git/browser tools
```

Daemon must be running. `harness-mcp` exits with a clear error if daemon socket not found.

### Phase A PBIs

- [x] **A-0:** MCP status UI in Agents settings page — `MCPConfigWriter` + "Add MCP"/"✓ MCP" button per agent row (2026-06-21)
- [x] **A-1:** Bundle `harness-mcp` in `Harness.app/Contents/MacOS/` via `build-release.sh` + `package-app.sh` (2026-06-21)
- [x] **A-2:** `harness-cli mcp setup|status|remove` — detects Claude Code / Kiro / Agy, writes mcpServers.harness (2026-06-21)
- [x] **A-3:** Wire agents via `harness-cli mcp setup` (covered by A-0 UI + A-2 CLI) (2026-06-21)
- [x] **A-4:** Updated `docs/AGENT-HANDBOOK.md` with MCP setup steps + config targets (2026-06-21)
- [x] **A-5:** Update `knowledge/architecture/mcp-server.md` — 27 tools, 6 categories, agent config wiring section (2026-06-21)

---

## Path B: Terminal Chat (Warp-style inline AI) — P1, new build

### What it looks like

```
┌─────────────────────────────────────────┐
│  $ git rebase --onto main HEAD~3        │  ← normal PTY output
│  error: could not apply 3f2c1a...       │
│                                         │
│ ╭─ ✦ Claude ────────────────────── ✕ ─╮│  ← AIResponseBlockView (overlay)
│ │ The rebase failed because commit     ││
│ │ 3f2c1a has a conflict in auth.swift. ││
│ │                                      ││
│ │ Run this to resolve:                 ││
│ │  ┌────────────────────────────────┐  ││
│ │  │ git checkout --theirs auth.swift│  ││  ← runnable code block
│ │  │ git add auth.swift             │  ││
│ │  │ git rebase --continue          │  ││
│ │  └────────────────────────────────┘  ││
│ │  [▶ Run]  [⎘ Copy]  [✕ Dismiss]     ││
│ ╰──────────────────────────────────────╯│
│ ╭─ ✦ AI ──────────────────────────────╮│  ← AIQueryInputView
│ │ > |                                  ││
│ ╰──────────────────────────────────────╯│
└─────────────────────────────────────────┘
```

### Architecture

```
HarnessTerminalSurfaceView (existing Metal surface)
  └── AITerminalChatController  ← new, @MainActor, manages overlay lifecycle
       ├── AIQueryInputView     ← NSView, input bar, bottom-pinned
       └── AIResponseBlockView  ← NSView, streaming response, stackable
            ├── HarnessOverlayBackground  ← reuse existing
            ├── agent icon + name label
            ├── AIMarkdownTextView        ← NSTextView with code block detection
            └── action bar: [▶ Run] [⎘ Copy] [✕ Dismiss]
```

Overlay sits on top of the Metal surface — same layer-hosting pattern as `CompletionPopupView`
and `DisplayPanesOverlay`. No changes to `TerminalEmulator` or `HarnessTerminalRenderer`.

### Agent process

All supported CLIs have non-interactive/print mode — no ACP framing needed:

| Agent | Command | Stdin |
|-------|---------|-------|
| `claude` | `claude -p "<query>"` | context piped to stdin |
| `codex` | `codex exec "<query>"` | stdin auto-appended as `<stdin>` block |
| `agy` (Gemini) | `agy -p "<query>"` | context piped to stdin |
| `kiro` | TBD — likely `-p` or `exec` | TBD |

```
AITerminalChatController
  ↓ AgentProcessManager  (new, plain Process — NO ACP framing)
     ├── stdin pipe: last 80 pane lines as plain text
     ├── stdout pipe: raw text streamed to AIResponseBlockView
     └── stderr: captured for error display
```

```swift
// AgentProcessManager core — no ACPProcess, just Process
func query(_ text: String, context: String) -> AsyncStream<String> {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: resolvedPath)
    proc.arguments = agentArgs(for: agent, query: text)  // -p / exec

    let stdin  = Pipe(); proc.standardInput  = stdin
    let stdout = Pipe(); proc.standardOutput = stdout

    stdin.fileHandleForWriting.write((context + "\n").data(using: .utf8)!)
    stdin.fileHandleForWriting.closeFile()

    try proc.run()
    return AsyncStream { continuation in
        // read stdout line-by-line and yield to stream
    }
}
```

PATH resolution: `/bin/zsh -l -c "which <agent>"` on first use, cached in `AIAgentConfig`.

### Agent config (per workspace, switchable)

```swift
// HarnessSettings (new field)
struct AIAgentConfig: Codable {
    var agent: AgentKind       // .claudeCode | .codex | .gemini | .kiro
    var resolvedBinaryPath: String?
    var extraArgs: [String]
}

enum AgentKind: String, Codable {
    case claudeCode = "claude"
    case codex      = "codex"
    case gemini     = "gemini"
    case kiro       = "kiro"
}
```

Switcher: Settings → AI tab, or a quick-switch pill inside `AIQueryInputView`
(click agent icon → popover with agent list).

### Context injection

When user submits a query, Harness reads the last 80 lines of the current pane's scrollback
(via `SurfaceRegistry`/`TerminalEmulator` — same path as `readPaneOutput` MCP tool) and
prepends as context:

```
[Terminal context — last 80 lines]
<pane output>
...
</pane output>
User query: <query>
```

Agent receives context on stdin before the query. No tool calling needed for the MVP.

### Trigger

| Trigger | Action |
|---------|--------|
| `⌘I` (default) | Open `AIQueryInputView` in current terminal pane |
| `Esc` | Dismiss query input (response block stays) |
| `⌘I` again | Clear all response blocks |
| Click `[▶ Run]` | Send code block text to PTY as if typed |
| Click `[✕ Dismiss]` | Remove that response block |

Keybinding is rebindable via normal Harness keybinding config.

### Phase B PBIs

- [ ] **B-1:** `AgentProcessManager` — PATH resolution via login shell, spawn CLI with `-p`/`exec`, stream stdout, crash handle
- [ ] **B-2:** `AIQueryInputView` — NSView input bar, bottom-pinned to terminal pane, Esc/Enter
- [ ] **B-3:** `AIResponseBlockView` — streaming text render, fenced code block detection, [▶ Run] [⎘ Copy] [✕ Dismiss]
- [ ] **B-4:** `AITerminalChatController` — orchestrates B-1/B-2/B-3 on `HarnessTerminalSurfaceView`
- [ ] **B-5:** Context injection — last 80 pane lines via `TerminalEmulator.plainText()` → stdin
- [ ] **B-6:** `AgentKind` + `AIAgentConfig` in `HarnessSettings`, per-workspace storage
- [ ] **B-7:** `⌘I` keybinding → new `Command.openAIChat` → `CommandIPCTranslator` + `MainExecutor`
- [ ] **B-8:** Settings → AI tab: agent picker, binary path auto-detect + override, keybinding

---

## Path C: ACP sidebar — P3, deferred

Sidebar chat (original P5 ACP) is **deferred** — terminal inline chat (Path B) covers the same
use case with better UX. Code stays gated behind `#if HARNESS_ACP`. Re-enable criteria unchanged:
- ACP adapters installable via `brew install`
- Tool sandboxing at protocol level
- PATH resolution (Path B's login-shell solution is reusable here when the time comes)

---

## Decision: MCP vs Terminal Chat vs ACP

```
┌─────────────────────────────────────────────────┐
│                USE CASE SPLIT                   │
│                                                 │
│  MCP (agent→Harness)               Priority: P1 │
│  Agent is the driver: runs tests, greps, etc.   │
│  Claude Code / Codex / Kiro call Harness tools  │
│  Config-only, no new code needed                │
│                                                 │
│  Terminal Chat (inline)            Priority: P1 │
│  User wants to ask AI while in terminal         │
│  ⌘I → type query → response block inline        │
│  Warp-style — native, not a sidebar             │
│                                                 │
│  ACP sidebar (Harness→agent)       Priority: P3 │
│  Deferred — terminal chat covers the use case   │
└─────────────────────────────────────────────────┘
```

Ship MCP wiring first (A-1 to A-3, ~1 day). Terminal Chat next (B-1 to B-8, ~1 week).

---

## Out of Scope

- TCP/WebSocket transport for MCP (SSH tunnel covers remote use cases via P23)
- Multi-agent terminal chat (single agent per session for MVP)
- Terminal Chat on iOS/iPadOS (P25 first)
- ACP sidebar re-enable (deferred to P3)
