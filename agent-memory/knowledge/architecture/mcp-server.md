# MCP Server (harness-mcp)

## Status: SHIPPED (P12, v2.x+)

## What It Is

`harness-mcp` is a standalone executable that speaks MCP (Model Context Protocol) — JSON-RPC 2.0 over stdin/stdout — so AI agents (Claude Code, Codex, Kiro) can control and observe Harness as a tool provider. It connects to the running Harness daemon over the same Unix-domain socket as the GUI and CLI.

## Architecture

```
Agent (Claude/Codex/Kiro)
    ↓ JSON-RPC 2.0 (stdin/stdout, Content-Length frames)
MCPServer (actor)
    ↓
StdioTransport ──── reads/writes ACPMessage
ToolRegistry
  ├── HarnessDaemonTools  ── DaemonClient → Unix socket → HarnessDaemon
  └── HarnessBrowserTools ── IPC to GUI BrowserPaneView via daemon
ToolPolicy  ──── ~/.config/harness/mcp-policy.json or HARNESS_MCP_ALLOW_CONTROL=1
```

- `MCPServer` is an `actor`; `StdioTransport` vends `incoming: AsyncStream<ACPMessage>`.
- Protocol version advertised: `2024-11-05`.
- Reuses `ACPMessage` from `HarnessCore/ACP` for framing (shared with ACP path).

## Tool Categories (27 tools across 6 categories)

### Session/Pane (read + control)
| Tool | What it does |
|------|-------------|
| `harnessList` | All workspaces/sessions/tabs/panes with agent detection |
| `harnessBoard` | Kanban board of sessions by status |
| `readPaneOutput` | Scrollback text from any pane (up to 2000 lines) |
| `waitForPaneOutput` | Block until pane emits a string pattern |
| `sendPaneText` / `sendPaneKeys` | Input to terminal pane (control — gated) |
| `spawnSession` / `splitPane` / `closePane` | Session/pane lifecycle (control — gated) |

### File I/O
| Tool | What it does |
|------|-------------|
| `readFile` | Read file contents |
| `writeFile` | Write file (control — gated) |
| `listDirectory` | List directory entries |

### Git
| Tool | What it does |
|------|-------------|
| `gitStatus` / `gitDiff` / `gitLog` | Git read operations |

### Workbench
| Tool | What it does |
|------|-------------|
| `harnessFind` / `harnessGrep` / `harnessRecent` / `harnessErrors` | Find, grep, recent files, LSP diagnostics |
| `runCommand` | Shell exec with cwd (control — gated) |

### Browser Pane
| Tool | What it does |
|------|-------------|
| `harnessBrowserOpen` / `harnessBrowserNavigate` / `harnessBrowserInteract` / `harnessBrowserClose` | Browser pane control (control — gated) |
| `harnessBrowserSnapshot` | DOM snapshot + interactive elements |
| `harnessBrowserWait` | Wait for browser load |

### Agents
| Tool | What it does |
|------|-------------|
| `harnessSpawnAgent` | Spawn an agent process in a Harness pane (control — gated) |

## Agent Config Wiring

`MCPConfigWriter` (HarnessCore) reads and writes `mcpServers.harness` in each agent's config file:

| Agent | Config file | Supported |
|-------|-------------|-----------|
| Claude Code | `~/.claude.json` | ✓ |
| Kiro | `~/.kiro/settings/mcp.json` | ✓ |
| Agy/Gemini | `~/.gemini/settings.json` | ✓ |
| Codex | `~/.codex/config.toml` | ✗ (uses plugin marketplace) |

Entry written: `{ "type": "stdio", "command": "/path/to/harness-mcp" }` under `mcpServers.harness`.

CLI: `harness-cli mcp setup|status|remove` (no daemon connection required).
GUI: Settings ▸ Agents — "Add MCP" / "✓ MCP" button per supported agent row.

Binary ships at `Harness.app/Contents/MacOS/harness-mcp` in production. Dev builds use `.build/debug/harness-mcp` resolved by walking up the directory tree.

## Policy Gating

- `ToolPolicy.load()` reads `~/.config/harness/mcp-policy.json`
- `HARNESS_MCP_ALLOW_CONTROL=1` overrides policy to allow all control tools
- Unapproved control calls return a `JSONRPCError` with instructions to set env var

## Tab Bar Badge

`lastMCPControlAt` timestamp on `Tab` snapshot drives the MCP badge shown in the tab pill — agents actively controlling a pane show a badge so the user can see which tab is being automated.

## Relationship to ACP

ACP and MCP share `ACPMessage` framing in `HarnessCore` but serve opposite directions:
- **MCP**: external agent → Harness (agent *uses* Harness as a tool)
- **ACP**: Harness → external agent (Harness *embeds* an agent chat UI — shelved)

MCP is the active path for agent ↔ terminal integration. ACP re-enable criteria in `patterns/acp-client.md`.

## Key Files

- `Tools/harness-mcp/Sources/HarnessMCP/MCPServer.swift` — core actor
- `Tools/harness-mcp/Sources/HarnessMCP/ToolRegistry.swift` — 27 tool implementations
- `Tools/harness-mcp/Sources/HarnessMCP/ToolPolicy.swift` — policy gating
- `Tools/harness-mcp/Sources/HarnessMCP/HarnessDaemonTools.swift` — daemon IPC
- `Tools/harness-mcp/Sources/HarnessMCP/HarnessBrowserTools.swift` — browser IPC
- `Tools/harness-mcp/Sources/HarnessMCP/StdioTransport.swift` — stdin/stdout framing
- `HarnessCore/ACP/ACPMessage.swift` — shared message model
