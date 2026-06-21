# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Latest release:** v3.6.1 (build 162)
- **Status:** idle

## Last Session (2026-06-21)
- CMUX-style browser redesign: translucent toolbar (NSVisualEffectView .hudWindow), 2-row compact layout (28pt tab + 32pt toolbar)
- Fixed tab close button: removed NSScrollView + NSClickGestureRecognizer that consumed mouse events
- AI agent selector (⌘I pill click) — persists to settings.json
- RL-040 universal fix: removeFromSuperview() override with 1.5s retire-hold
- Shared memory protocol: .ai/memory-protocol.md symlink architecture
- Rules restructure: 7 files (1000 lines) → 3 files (136 lines)
- AIDLC Mode Lock fully unlocked (Full/QA/Dev all active)

## Open Questions
- [priority] Fix harness-mcp round-trip first — agent sends command but response doesn't come back
- [next] Wire WKWebView API (navigate, snapshot, evaluateJS, consoleLogs) through IPC/MCP — covers 90% agent browser use cases
- [later] Browser tab management via sidebar (CMUX-style)

## Key Files
- `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift` — browser view
- `~/.claude/rules/` — core.md, coding.md, routing.md (restructured)
- `~/.claude/scripts/shared/memory-protocol.md` — shared protocol

## Session Notes
- Build: `make preview`
- NSClickGestureRecognizer ALWAYS consumes mouse events — use mouseUp override instead (RL-043)
