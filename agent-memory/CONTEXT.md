# Context — harness-terminal

## Now
- **Task:** Browser pane redesign — CMUX-style integrated browser
- **Branch:** main
- **Latest release:** v3.6.1 (build 162)
- **Status:** in-progress (design phase)

## Design Direction (CMUX-inspired)

1. **Translucent toolbar** — no solid background, blur from terminal window (like CMUX)
2. **No browser-level tabs** — tab management moves to terminal sidebar (reduce UI duplication)
3. **Agent-controlled** — API for agents to load URLs, inspect DOM, read console logs (like Chrome DevTools but terminal-native)
4. **Full web support** — not just localhost, any website works normally (cookies persist)

## Key Changes from Current Design

| Current | New |
|---------|-----|
| Tab bar inside BrowserPaneView (28pt) | Remove — sidebar manages tabs |
| Solid black toolbar background | Translucent/blur matching terminal |
| No agent API | Agent can: navigate, get DOM, read console, screenshot |
| Click-to-open only | Agent can open + inspect programmatically |

## Key Files
- `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift` — main browser view
- `agent-memory/knowledge/ui/browser-pane.md` — architecture doc

## Session Notes
- Build: `make preview`
- Read `agent-memory/knowledge/ui/browser-pane.md` for current architecture
