# harness-mcp Install Chain

## What It Is

`harness-mcp` is Harness's MCP (Model Context Protocol) server — JSON-RPC 2.0 over stdin/stdout.
AI agents (Claude Code, Claude Desktop, Cursor, Codex) connect to it as a tool provider with 24+
tools for session control, terminal I/O, file navigation, git, and the agent board.

Direction: **AI agent → harness-mcp** (agent consumes Harness as a tool). Contrast with ACP where
**Harness → agent** (Harness is the consumer).

## Install Chain (all gaps fixed June 2026)

| Step | File | What it does |
|------|------|-------------|
| Build | `Scripts/build-release.sh` | `swift build -c release --product harness-mcp` |
| Bundle | `Scripts/package-app.sh` | `cp .build/release/harness-mcp Harness.app/Contents/MacOS/` |
| Register path | `BinaryRefresher.swift` | `installedMCPPath = binDirectory/"harness-mcp"` |
| Auto-refresh | `DaemonLauncher.refreshInstalledBinaries()` | Copies bundled → installed on every app launch (release only) |
| CLI copy | `HarnessCLI.installCLI()` (install command) | Copies harness-mcp alongside harness-cli into bin/ |
| Register | `HarnessCLI+InstallMCP.swift` | `harness-cli install-mcp [--claude-code|--claude-desktop|--all]` |

## harness-cli install-mcp

```bash
harness-cli install-mcp              # registers with both Claude Code + Claude Desktop
harness-cli install-mcp --claude-code    # claude mcp add harness <path> -s user
harness-cli install-mcp --claude-desktop # merges mcpServers.harness into claude_desktop_config.json
```

- Claude Code: delegates to `claude mcp add` → writes `~/.claude.json` (user scope)
- Claude Desktop: reads/writes `~/Library/Application Support/Claude/claude_desktop_config.json` with `.bak` backup
- Locates `claude` CLI at `/usr/local/bin/claude`, `/opt/homebrew/bin/claude`, or PATH fallback

## Binary Location Priority (locateMCPBinary)

1. `HARNESS_MCP_PATH` env override
2. Sibling of `harness-cli` source binary
3. `~/Library/Application Support/Harness/bin/harness-mcp` (installed copy)
4. `/Applications/Harness.app/Contents/MacOS/harness-mcp`

## Tool-Call Policy

Default: read-only tools only.
To allow control tools (send keys, run commands, write files):
```bash
HARNESS_MCP_ALLOW_CONTROL=1 harness-mcp
```
Or add tool names to `~/Library/Application Support/Harness/mcp-policy.json`.
