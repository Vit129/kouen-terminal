# Competitive Position (as of v4.3.1, 2026-07-11)

> Merged from the 2026-07-02 baseline (then named "Harness") + the P39 refresh
> (2026-07-11, added Zed/Superset/tmux, re-verified every claim against current
> source). See `agent-memory/plans/p39-competitive-feature-gaps.md` for the
> per-gap evidence trail and phase-by-phase implementation notes.

## Kouen Wins

| vs | Advantage |
|----|-----------|
| Supacode | Daemon persistence, remote/headless, CLI scripting depth, browser pane, multiplexer, macOS 15 support (Supacode needs 26), custom engine (no libghostty), MCP server |
| Warp | Daemon/remote, open source, no account required, multiplexer, agent-aware worktrees, MCP server, agent selector (multi-AI), browser pane |
| iTerm2 | Agent detection, worktree isolation, GitHub PR inline, MCP server, browser pane, agent selector |
| Ghostty | Built-in multiplexer, agent hooks, browser pane, IDE navigation, PR/CI inline, MCP server |
| WezTerm | Agent-aware tabs, worktree isolation, daemon persistence, remote, browser pane, MCP, no Lua required |
| cmux | GitHub PR/CI, IDE navigation, worktree management, experience modes, MCP server, agent selector, compact CMUX-style browser (matched), notification rings (matched) |
| tmux | Full scripting/copy-mode/status-line/hooks/format-string parity (`docs/TMUX_PARITY.md`) plus daemon persistence tmux itself doesn't have across full app quit |
| Zed | CLI-agents-in-panes + MCP context pull (`kouenErrors`/`kouenGetBlock`/`kouenGrep`/`kouenFind`) instead of Zed's UI @-mention Agent Panel — deliberate positioning, not a gap |
| Superset | In-app browser + 27 MCP tools (matched), native Swift vs Electron |

## Kouen Gaps

### Closed 2026-07-11 (P39 phases A–D — build/test green, live-hardware check still owed on each)

| Gap | Who had it | Fix |
|-----|-----------|-----|
| Sidebar dev-server port badge | cmux | `ListeningPortScanner` + sidebar badge |
| SSH agent forwarding on remote hosts | WezTerm | `SettingsRemoteView` toggle on `-A` passthrough |
| PR merge strategy (squash/rebase/merge) in-app | Supacode | `GitHubCLIClient.merge()` + sidebar context menu |
| In-app git hunk staging | Superset | `GitPanelView` hunk popover, `git apply --cached` |
| Fleet dashboard (10+ agents at a glance) | Superset | Footer badge count + inbox header "N running · M need you" |

### Still open (not re-verified since 2026-07-02, watch for staleness)

| Gap | Who has it |
|-----|-----------|
| Cross-platform GUI (Win/Linux) | Warp, WezTerm, Ghostty (Linux) — macOS-only is a strategic choice, not an oversight |
| Team sharing / cloud sync | Warp Teams |
| Extensions/plugins ecosystem | iTerm2 (python API), WezTerm (Lua) — includes tpm-style plugin manager (resurrect/continuum/thumbs) |
| GPU shader customization | Ghostty |
| Large community (1M+ users) | Warp, iTerm2, Ghostty |
| Block-based terminal (command grouping) | Warp — planned P34 |

## Not gaps — deliberate positioning differences (no action)

- **Zed's built-in chat/Agent Panel UI** — Kouen removed inline AI chat deliberately (`c4e1e15`, 2026-06-29). Re-adding contradicts the CLI-agents-in-terminal-panes + MCP philosophy.
- **Superset/cmux Electron vs native** — Kouen's native Swift engine is a stated USP.

## Known Limitations (honest assessment)

| Feature | Status | Issue |
|---------|--------|-------|
| MCP server | Works | RL-048: round-trip timeout fixed — 35s timeout matching daemon's 30s internal timeout |
| Inline AI chat (⌘I) | Removed | `c4e1e15` erased ACP + inline AI chat entirely. Agent interaction is CLI-only |
| Agent selector | Works | Persists to settings, switches CLI binary |
| Browser pane | Works | Navigate, tabs, console capture |
| Browser agent API | Works | snapshot/evaluateJS/network/cookies/storage wired via IPC/MCP (P28) |

## Unique Selling Points (no competitor has all)

1. **MCP server built-in** — `kouen-mcp` exposes 27 tools; Claude Code/Codex/Kiro can read panes, control sessions, interact with browser pane
2. **Agent selector** — switch between Claude/Codex/Gemini/Kiro mid-session, persisted to settings
3. **Browser pane with agent API** — navigate, snapshot DOM, read console logs, evaluate JS — no other terminal has this
4. Daemon + Remote + CLI + GUI in one app (tmux-killer)
5. 4 experience modes (plain → persistent → full → agent workspace)
6. macOS 15+ (Supacode requires macOS 26)
7. Custom Swift terminal engine (no libghostty/Electron dependency)
8. Auto-isolate worktrees per branch per agent

## Feature Matrix (2026-07-11)

| Feature | Kouen | Warp | iTerm2 | Ghostty | Supacode | cmux | Zed | Superset | tmux |
|---------|:-----:|:----:|:------:|:-------:|:--------:|:----:|:---:|:--------:|:----:|
| MCP server (agent→terminal) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | partial | ✓ | ✗ |
| Agent selector (multi-AI) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Browser pane + agent API | ✓ | ✗ | ✗ | ✗ | ✗ | partial | ✗ | ✓ | ✗ |
| Daemon persistence | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ |
| Remote (SSH tunnel + agent forwarding) | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | partial |
| Built-in multiplexer | ✓ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✗ | ✓ |
| Worktree auto-isolate | ✓ | ✗ | ✗ | ✗ | ✓ | partial | ✗ | ✓ | ✗ |
| In-app git hunk staging | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| PR merge strategy picker | ✓ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Sidebar dev-server port badge | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ |
| Fleet/multi-agent dashboard | partial | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ |
| No account required | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ |
| Open source | ✓ | ✗ | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ |
| Cross-platform GUI | ✗ | ✓ | ✗ | partial | ✗ | ✗ | ✓ | ✗ | ✓ (terminal-native) |
| Block-based terminal | ✗ (planned, P34) | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

## Positioning Statement

> "Kouen is the only terminal with a built-in MCP server + multi-agent selector + browser
> DevTools API — all in one open-source app. Claude Code, Codex, Gemini, and Kiro can
> directly observe and control your terminal sessions, panes, and browser via `kouen-mcp`.
> No account required, runs on macOS 15+, works headless in CI, and combines agent-ready
> MCP tooling + tmux-style persistence + IDE navigation."

## Sources (2026-07-11 research)
- cmux: https://github.com/manaflow-ai/cmux
- Supacode: https://supacode.sh/ , https://github.com/supabitapp/supacode
- Superset: https://superset.sh/ , https://github.com/superset-sh/superset
- WezTerm: https://wezterm.org/config/lua/config/mux_enable_ssh_agent.html
- Zed: https://zed.dev/docs/ai/agent-panel , https://andrew.ooo/answers/what-is-zed-terminal-threads-may-2026/
