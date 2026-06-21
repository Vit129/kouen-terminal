# Competitive Position (as of v3.6.1, June 2026)

## Harness Wins

| vs | Advantage |
|----|-----------|
| Supacode | Daemon persistence, remote/headless, CLI scripting depth, browser pane, multiplexer, macOS 15 support, custom engine (no libghostty), MCP server, inline AI chat |
| Warp | Daemon/remote, open source, no account required, multiplexer, agent-aware worktrees, MCP server, agent selector (multi-AI), browser pane |
| iTerm2 | Agent detection, worktree isolation, GitHub PR inline, MCP server, browser pane, inline AI chat, agent selector |
| Ghostty | Built-in multiplexer, agent hooks, browser pane, IDE navigation, PR/CI inline, MCP server, inline AI chat |
| WezTerm | Agent-aware tabs, worktree isolation, daemon persistence, remote, browser pane, MCP, inline AI, no Lua required |
| cmux | GitHub PR/CI, IDE navigation, worktree management, experience modes, MCP server, inline AI chat, agent selector, compact CMUX-style browser (matched) |

## Harness Gaps

| Gap | Who has it |
|-----|-----------|
| Cross-platform GUI (Win/Linux) | Warp, WezTerm, Ghostty (Linux) |
| Team sharing / cloud sync | Warp Teams |
| Extensions/plugins ecosystem | iTerm2 (python API), WezTerm (Lua) |
| GPU shader customization | Ghostty |
| Large community (1M+ users) | Warp, iTerm2, Ghostty |
| Block-based terminal (command grouping) | Warp |

## Gaps Closed (v3.6.0–3.6.1)

| Was a gap | How closed |
|-----------|-----------|
| AI chat built-in | ⌘I inline chat — CLI print mode (no ACP needed) |
| Single AI provider lock-in | Agent selector: Claude/Codex/Gemini/Kiro switchable |
| Browser chrome too heavy | CMUX-style 2-row compact layout (28+32pt) |

## Unique Selling Points (no competitor has all)

1. **MCP server built-in** — `harness-mcp` exposes 25 tools; Claude Code/Codex/Kiro can read panes, control sessions, interact with browser pane
2. **Inline AI chat (⌘I) + agent selector** — switch between Claude/Codex/Gemini/Kiro mid-session, persisted to settings
3. **Browser pane with agent API** — navigate, snapshot DOM, read console logs, evaluate JS — no other terminal has this
4. Daemon + Remote + CLI + GUI in one app (tmux-killer)
5. 4 experience modes (plain → persistent → full → agent workspace)
6. macOS 15+ (Supacode requires macOS 26)
7. Custom Swift terminal engine (no libghostty/Electron dependency)
8. Auto-isolate worktrees per branch per agent

## Feature Matrix (June 2026)

| Feature | Harness | Warp | iTerm2 | Ghostty | Supacode | cmux |
|---------|:-------:|:----:|:------:|:-------:|:--------:|:----:|
| MCP server (agent→terminal) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Inline AI chat | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ |
| Agent selector (multi-AI) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Browser pane + agent API | ✓ | ✗ | ✗ | ✗ | ✗ | partial |
| Daemon persistence | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ |
| Remote (SSH tunnel) | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Built-in multiplexer | ✓ | ✗ | ✓ | ✗ | ✓ | ✗ |
| Worktree auto-isolate | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ |
| No account required | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| Open source | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| Cross-platform GUI | ✗ | ✓ | ✗ | partial | ✗ | ✗ |

## Positioning Statement

> "Harness is the only terminal with a built-in MCP server + inline AI chat + multi-agent
> selector + browser DevTools API — all in one open-source app. Claude Code, Codex, Gemini,
> and Kiro can directly observe and control your terminal sessions, panes, and browser.
> No account required, runs on macOS 15+, works headless in CI, and combines agent-ready
> MCP tooling + tmux-style persistence + IDE navigation."
