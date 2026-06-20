# Competitive Position (as of v3.5.0, June 2026)

## Harness Wins

| vs | Advantage |
|----|-----------|
| Supacode | Daemon persistence, remote/headless, CLI scripting depth, browser pane multi-tab, multiplexer, macOS 15 support, custom engine (no libghostty dependency), MCP server |
| Warp | Daemon/remote, open source, no account required, multiplexer, agent-aware worktrees, MCP server for agent control |
| iTerm2 | Agent detection, worktree isolation, GitHub PR inline, project config, notifications, MCP server, browser pane |
| Ghostty | Built-in multiplexer, agent hooks, browser pane, IDE navigation, PR/CI inline, MCP server |
| WezTerm | Agent-aware tabs, worktree isolation, daemon persistence, remote, browser pane, MCP, no Lua scripting required |
| cmux | Browser pane, GitHub PR/CI, IDE navigation, worktree management, experience modes, MCP server |

## Harness Gaps

| Gap | Who has it |
|-----|-----------|
| Cross-platform GUI (Win/Linux) | Warp, WezTerm, Ghostty (Linux) |
| AI chat built-in (embedded sidebar) | Warp AI — ACP shelved in Harness |
| Block-based terminal (command grouping) | Warp |
| Team sharing / cloud sync | Warp Teams |
| Extensions/plugins ecosystem | iTerm2 (python API), WezTerm (Lua) |
| GPU shader customization | Ghostty |
| Large community (1M+ users) | Warp, iTerm2, Ghostty |
| Inline AI autocomplete | Warp, Fig/Cursor-in-terminal |
| Native ACP chat (Harness→agent) | Warp AI, Cursor — Harness ACP shelved |

## Unique Selling Points (no competitor has all)

1. **MCP server built-in** — `harness-mcp` exposes 25 tools; Claude Code/Codex/Kiro can read panes, control sessions, interact with browser pane — no other terminal ships this
2. Daemon + Remote + CLI + GUI in one app (tmux-killer)
3. Browser pane multi-tab in terminal (PR review inline, agent-controllable, cookies persist)
4. 4 experience modes (plain → persistent → full → agent workspace)
5. macOS 15+ (Supacode requires macOS 26)
6. Custom Swift terminal engine (no libghostty/Electron dependency)
7. Auto-isolate worktrees per branch per agent (correct branch display per pane)

## ACP vs MCP Positioning

- **MCP (shipped P12)**: agent *uses* Harness as a tool. Enables headless CI, AI-driven terminal workflows, automated browser testing. Works TODAY with Claude Code `--mcp-config`.
- **ACP (shelved P5)**: Harness *embeds* an agent chat sidebar. Requires adapter binaries not widely available. Re-enable when `brew install claude-acp-adapter` works.
- Key message: Warp has ACP-style chat but no MCP. Harness has MCP but not ACP. MCP is more powerful for agentic workflows; ACP is better for human-in-the-loop chat.

## Positioning Statement

> "Harness is the only terminal with a built-in MCP server — Claude Code, Codex, and Kiro
> can directly observe and control your terminal sessions, panes, and browser without any
> plugin. Warp has AI chat but requires an account, has no daemon, no remote, no MCP, no
> multiplexer. Supacode is a worktree command center for macOS 26 only. Harness runs on
> macOS 15+, works headless in CI, and is the only terminal that combines agent-ready MCP
> tooling + tmux-style persistence + IDE navigation in one open-source app."

## Feature Matrix (June 2026)

| Feature | Harness | Warp | iTerm2 | Ghostty | Supacode |
|---------|:-------:|:----:|:------:|:-------:|:--------:|
| MCP server (agent→terminal) | ✓ | ✗ | ✗ | ✗ | ✗ |
| Daemon persistence | ✓ | ✗ | ✗ | ✗ | ✓ |
| Remote (SSH tunnel) | ✓ | ✓ | ✗ | ✗ | ✗ |
| Built-in multiplexer | ✓ | ✗ | ✓ | ✗ | ✓ |
| Browser pane | ✓ | ✗ | ✗ | ✗ | ✗ |
| AI chat sidebar (ACP) | shelved | ✓ | ✗ | ✗ | ✓ |
| Worktree auto-isolate | ✓ | ✗ | ✗ | ✗ | ✓ |
| LSP integration | ✓ | ✗ | ✗ | ✗ | partial |
| No account required | ✓ | ✗ | ✓ | ✓ | ✓ |
| macOS 15+ | ✓ | ✓ | ✓ | ✓ | ✗ |
| Open source | ✓ | ✗ | ✓ | ✓ | ✗ |
| Cross-platform GUI | ✗ | ✓ | ✗ | partial | ✗ |
