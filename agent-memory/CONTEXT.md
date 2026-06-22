# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Status:** idle

## Last Session (2026-06-22) — harness-mcp Complete + Crash Fixes

**Completed:**
- harness-mcp browser tools complete: 14 tools (evaluate, goBack, goForward, reload added)
- MCP config wired for all agents: Claude (.claude/settings.json), Codex (~/.codex/config.toml), Kiro (~/.kiro/settings/mcp.json), Gemini (~/.gemini/config/mcp_config.json)
- chrome-devtools-mcp disabled/replaced across all agents
- Sidebar crash fix (RL-051): `refreshMetadata()` now calls `reloadData()` before row iteration
- Worktree auto-isolation fix: multiple tabs on same branch get separate worktrees
- TerminalTabBarView zombie thunk fix (RL-040 variant)

**Blocked / Pending:**
- Item 3 (HarnessCore package split): circular dep blocks extraction
- Sidebar race condition long-term fix: see `agent-memory/plans/sidebar-race-fix.md`

## Plans
- `agent-memory/plans/sidebar-race-fix.md` — NSTableView row crash elimination (Option A: diffable, Option B: SwiftUI)

## Open Questions
- (none)

## Key Files
- `Tools/harness-mcp/Sources/HarnessMCP/` — complete MCP browser tools
- `Packages/HarnessCore/Sources/HarnessCore/IPC/IPCMessage.swift` — BrowserRequestPayload (evaluate/goBack/goForward/reload)
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift` — crash fix at refreshMetadata()
- `Apps/Harness/Sources/HarnessApp/Services/DaemonSyncService.swift` — GUI browser request handlers

## Session Notes
- Build: `swift build` / `make preview`
- All 4 agent configs point to `/Applications/Harness.app/Contents/MacOS/harness-mcp` with `HARNESS_MCP_ALLOW_CONTROL=1`
- NSClickGestureRecognizer ALWAYS consumes mouse events — use mouseUp override instead (RL-043)
