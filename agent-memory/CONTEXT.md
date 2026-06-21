# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Latest release:** v3.6.1 (build 162)
- **Status:** idle

## Last Session (2026-06-21)
- Fixed RL-040 keyDown zombie crash: (1) installed missing NSEvent local monitor in AppDelegate, (2) added 1.5s retire-hold to ContentAreaViewController.detachHosts()
- Added AI agent selector (click pill in ⌘I to switch Claude/Codex/Gemini/Kiro), persisted to settings.json
- Released v3.6.1 build 162

## Open Questions
- [open] `@` auto-include in memory-protocol only works for Claude Code — Codex/Gemini use rules/ fallback
- [open] Per-session-tab focus not restored on cmd+1/2/3. Partial fix not verified.

## Key Files
- `AppDelegate.swift` — NSEvent local monitor (RL-040 fix #8)
- `ContentAreaViewController.swift` — `detachHosts` retire-hold
- `AIQueryInputView.swift` — agent pill selector
- `AITerminalChatController.swift` — agent change + persist

## Session Notes
- Build: `make preview`
- Never reparent Metal terminal surfaces — causes black screen (RL-004)
