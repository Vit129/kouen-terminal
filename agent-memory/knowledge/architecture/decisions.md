# Architecture Decisions — harness-terminal

Grep target: `grep -n "<keyword>" knowledge/architecture/decisions.md`

## AI / Agent Connectivity

- ACP shelved — re-enable when adapters ship with agent CLIs natively
- No built-in AI chat view — Harness connects AI via CLI agents (Claude Code, Codex) in terminal + ACP (like MCP). Removed HarnessAIChatView and SearchPanelView.
- AI connectivity model: (1) harness-mcp = MCP server CLI agents call, (2) ACP = LSP-style framing for agent→daemon notifications. Same pattern as Zed/SupaCode context providers.
- harness-mcp browser tools complete (14 tools): Open, Navigate, Wait, Snapshot, Interact, Close, Screenshot, Network, Cookies, Storage, Evaluate, GoBack, GoForward, Reload. Replaces chrome-devtools-mcp globally. ~70-75% token savings.

## Sessions / Tabs

- ⌘1–9: `selectSession(workspaceID:sessionID:)` — not `selectWorkspace`
- CWD tracking: daemon polls `proc_pidinfo` 500ms — no shell integration needed
- Worktree auto-isolate is ALWAYS ON — every branch switch → own worktree → correct git probe per tab
- Upstream merge not viable: codebase diverged too far (424 commits, 25% new code) — port by reading

## File Preview / Split Panes

- File preview: constraint-based sibling panel, never reparent terminal views (RL-004)
- Split pane CWD priority: `worktreePath → sourceCwd → tab.cwd`

## Keybindings

- Single source of truth: `BannerShortcutRegistry` (`Keybinding` struct) — menu, banner, onboarding, `docs/KEYBINDINGS.md` all derive from one place
- ⌘T = new session, ⌘W = close pane (fall through to close tab if single pane), ⌘⇧W = force close tab

## Browser Pane

- Browser multi-tab: WKWebView tab bar always visible, `target=_blank` opens new tab, persistent cookies
- GitHub URLs in terminal open in browser pane (not external Safari)
- CI status shown in PR badge (✓/✗/○)
- WKWebView console → `/tmp/harness-browser-[paneID].log`, included in BrowserSnapshot for agent debugging
- P28 Browser DevTools API: Phase 1 (snapshot+element+screenshot), Phase 2 (network XHR via JS inject), Phase 3 (cookies+storage). Config-driven via `HarnessSettings.browserHomePage`.

## UI / Navigation

- IDE-like navigation: double-click folder → `cd <path>` to active terminal
- `:cd` command sends actual `cd` to shell (not just switch tabs)
- `⌘P` palette zoxide entries cd active terminal (not create new session)
- Sidebar 2-line layout: Line 1 = branch (bold), Line 2 = short cwd (dimmed) — Supacode-style
- Top bar always shows branch (⎇) even when agent active — only hides cwd path
- Tab pill Line 1 = folder/agent name, Line 2 = ⎇ branch (NOT branch-first — identical titles on same branch)

## Sidebar

- [2026-06-23] SwiftUI migration complete — `@Observable SidebarListModel` replaces NSTableView; NSHostingView bridges into VC. VC 1676→890 lines. RL-051 crash class eliminated.
- `SwiftUI.Tab` collides with `HarnessCore.Tab` after `import SwiftUI` — always qualify as `HarnessCore.Tab`.

## Config / Settings

- Config centralization: JSON files in `~/Library/Application Support/Harness/` — fallback to hardcoded defaults
- Personal project config override: `~/.config/harness/projects/<name>.json`

## IPC / Daemon

- IPC protocol versioning: `ipcProtocolVersion=1`, `identifyClient` carries `protocolVersion:Int`, daemon returns `.protocolRejected` on mismatch.
- HarnessCore package split blocked — `AgentSnapshot/AIAgentConfig/WorkbenchCommand` embedded in core IPC/models/settings must be promoted first.
- vi mode: `ViEngine` `@MainActor final class` in `ViNormalMode.swift`
