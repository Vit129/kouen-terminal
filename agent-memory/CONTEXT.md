# Context — harness-terminal

## Now
- **Task:** P26 AI chat — add model/agent selector (Claude default, Codex, Antigravity)
- **Branch:** main
- **Latest release:** v3.6.0 (build 161)
- **Status:** done — builds clean

## What Was Done
- `AIQueryInputView.agentPill` → NSButton with ▾ indicator
- Click pill → NSMenu popup with Claude/Codex/Gemini/Kiro (checkmark on active)
- Selection → `onAgentChanged` callback → `AITerminalChatController.changeAgent()` → persists to settings.json via `settings.save()`
- Next session respects saved choice (loaded from `settings.aiAgent.activeAgent`)

## Key Files
- `Apps/Harness/Sources/HarnessApp/UI/AIChat/AIQueryInputView.swift` — pill button + menu
- `Apps/Harness/Sources/HarnessApp/UI/AIChat/AITerminalChatController.swift` — wires callback, persists
- `Packages/HarnessCore/Sources/HarnessCore/AI/AIAgentConfig.swift` — config model
- `Packages/HarnessCore/Sources/HarnessCore/Settings/HarnessSettings.swift` — save()

## Session Notes
- Build: `make preview`
- Read `agent-memory/knowledge/ai/terminal-chat.md` for P26 context
