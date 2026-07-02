# Competitive Position (as of v3.12.0, 2026-07-02)

## Harness Wins

| vs | Advantage |
|----|-----------|
| Supacode | Daemon persistence, remote/headless, CLI scripting depth, browser pane, multiplexer, macOS 15 support, custom engine (no libghostty), MCP server |
| Warp | Daemon/remote, open source, no account required, multiplexer, agent-aware worktrees, MCP server, agent selector (multi-AI), browser pane |
| iTerm2 | Agent detection, worktree isolation, GitHub PR inline, MCP server, browser pane, agent selector |
| Ghostty | Built-in multiplexer, agent hooks, browser pane, IDE navigation, PR/CI inline, MCP server |
| WezTerm | Agent-aware tabs, worktree isolation, daemon persistence, remote, browser pane, MCP, no Lua required |
| cmux | GitHub PR/CI, IDE navigation, worktree management, experience modes, MCP server, agent selector, compact CMUX-style browser (matched) |

## Harness Gaps

| Gap | Who has it |
|-----|-----------|
| Cross-platform GUI (Win/Linux) | Warp, WezTerm, Ghostty (Linux) |
| Team sharing / cloud sync | Warp Teams |
| Extensions/plugins ecosystem | iTerm2 (python API), WezTerm (Lua) |
| GPU shader customization | Ghostty |
| Large community (1M+ users) | Warp, iTerm2, Ghostty |
| Block-based terminal (command grouping) | Warp |

## Known Limitations (honest assessment)

| Feature | Status | Issue |
|---------|--------|-------|
| MCP server | ✅ Works | RL-048: round-trip timeout (2s too short for WKWebView ops) fixed — `HarnessBrowserTools.send()` now uses 35s timeout matching daemon's 30s internal timeout |
| Inline AI chat (⌘I) | ❌ Removed | `c4e1e15` (2026-06-29) erased ACP + inline AI chat entirely — no longer a Harness feature. Agent interaction is CLI-only (Claude Code, Codex, etc. in a terminal pane) |
| Agent selector | ✅ Works | Persists to settings, switches CLI binary |
| Browser pane | ✅ Works | Navigate, tabs, console capture — functional |
| Browser agent API | ✅ Works | snapshot/evaluateJS/network/cookies/storage wired via IPC/MCP (P28, all 3 phases) — see `architecture/browser-devtools-api.md` |

**Honest status (updated 2026-07-02):** MCP round-trip and browser agent API are functionally complete as of P28 + RL-048. Inline AI chat and ACP are no longer part of Harness — deliberately removed, not a gap to close. Agent integration is exclusively via `harness-mcp` (agent → Harness) and CLI agents running in terminal panes, not a built-in chat UI.

## Unique Selling Points (no competitor has all)

1. **MCP server built-in** — `harness-mcp` exposes 27 tools; Claude Code/Codex/Kiro can read panes, control sessions, interact with browser pane
2. **Agent selector** — switch between Claude/Codex/Gemini/Kiro mid-session, persisted to settings
3. **Browser pane with agent API** — navigate, snapshot DOM, read console logs, evaluate JS — no other terminal has this
4. Daemon + Remote + CLI + GUI in one app (tmux-killer)
5. 4 experience modes (plain → persistent → full → agent workspace)
6. macOS 15+ (Supacode requires macOS 26)
7. Custom Swift terminal engine (no libghostty/Electron dependency)
8. Auto-isolate worktrees per branch per agent

## Feature Matrix (2026-07-02)

| Feature | Harness | Warp | iTerm2 | Ghostty | Supacode | cmux |
|---------|:-------:|:----:|:------:|:-------:|:--------:|:----:|
| MCP server (agent→terminal) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Agent selector (multi-AI) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Browser pane + agent API | ✓ | ✗ | ✗ | ✗ | ✗ | partial |
| Daemon persistence | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ |
| Remote (SSH tunnel) | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Built-in multiplexer | ✓ | ✗ | ✓ | ✗ | ✓ | ✗ |
| Worktree auto-isolate | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ |
| No account required | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ |
| Open source | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ |
| Cross-platform GUI | ✗ | ✓ | ✗ | partial | ✗ | ✗ |
| Block-based terminal | ✗ (planned, P34) | ✓ | ✗ | ✗ | ✗ | ✗ |

## Positioning Statement

> "Harness is the only terminal with a built-in MCP server + multi-agent selector + browser
> DevTools API — all in one open-source app. Claude Code, Codex, Gemini, and Kiro can
> directly observe and control your terminal sessions, panes, and browser via `harness-mcp`.
> No account required, runs on macOS 15+, works headless in CI, and combines agent-ready
> MCP tooling + tmux-style persistence + IDE navigation."
