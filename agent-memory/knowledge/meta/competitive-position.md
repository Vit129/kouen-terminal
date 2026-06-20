# Competitive Position (as of v3.4.0, June 2026)

## Harness Wins

| vs | Advantage |
|----|-----------|
| Supacode | Daemon persistence, remote/headless, CLI scripting depth, browser pane multi-tab, multiplexer, macOS 15 support, custom engine (no libghostty dependency) |
| Warp | Daemon/remote, open source, no account required, multiplexer, agent-aware worktrees |
| iTerm2 | Agent detection, worktree isolation, GitHub PR inline, project config, notifications |
| Ghostty | Built-in multiplexer, agent hooks, browser pane, IDE navigation, PR/CI inline |
| cmux | Browser pane, GitHub PR/CI, IDE navigation, worktree management, experience modes |

## Harness Gaps

| Gap | Who has it |
|-----|-----------|
| Cross-platform GUI (Win/Linux) | Warp, WezTerm |
| AI chat built-in | Warp AI |
| Block-based terminal (command grouping) | Warp |
| Team sharing / cloud sync | Warp Teams |
| Extensions/plugins ecosystem | iTerm2 (python API) |
| GPU shader customization | Ghostty |
| Large community (1M+ users) | Warp, iTerm2, Ghostty |
| Auto-complete / AI suggestions inline | Warp, Fig |

## Unique Selling Points (no competitor has all)

1. Daemon + Remote + CLI + GUI in one app (tmux-killer)
2. Browser pane multi-tab in terminal (PR review inline, cookies persist)
3. 4 experience modes (plain → persistent → full → agent workspace)
4. macOS 15+ (Supacode requires macOS 26)
5. Custom Swift terminal engine (no libghostty/Electron dependency)
6. Auto-isolate worktrees per branch per agent (correct branch display)

## Positioning Statement

> "Supacode is a worktree command center. Harness is a terminal that manages
> worktrees too — plus daemon persistence, remote, multiplexer, and CLI scripting
> that Supacode can't do. Warp has AI chat, but requires an account and has no
> daemon, no remote, no multiplexer. Harness is the only terminal that combines
> all three: agent-aware workspace + tmux-style persistence + IDE navigation."
