# Context — harness-terminal

## Now
- **Task:** Architecture refactor (items 1–5 from review) — items 1, 2, 4, 5 complete; item 3 (HarnessCore split) blocked, plan written
- **Branch:** fix-app-crashes
- **Status:** Items 1/2/4/5 committed; item 3 needs 2-step plan before implementation

## Session 2026-06-22 — P28 Complete + CLI Infrastructure

**P28 Browser DevTools API:**
- Phase 1: snapshot (role/bounds/visible) + screenshot (WKWebView.takeSnapshot → base64 PNG)
- Phase 2: network capture (fetch + XHR via JS monkey-patch at atDocumentStart)
- Phase 3: cookies (WKHTTPCookieStore) + localStorage + sessionStorage (evaluateJS)
- RL-048 fix: DaemonClientActor timeout 2s → 35s (WKWebView ops take 2–5s)
- Config-driven browser home page: HarnessSettings.browserHomePage (default google.com)
- v3.7.0 released on GitHub with full release notes

**Release Infrastructure:**
- `make start` fixed: full-cycle `git push` now only pushes new tags (avoids rejected existing tags)
- full-cycle CHANGELOG guard: prompt user if CHANGELOG entry missing before gh release
- v3.7.0 build 164 available with P28 + RL-048

**CLI Infrastructure (My-Investment-Port pattern):**
- `.claude/settings.json`: permissions (allow swift/make/git), PreToolUse graphify hint, UserPromptSubmit skill-trigger
- `.claude/hooks/skill-trigger.py`: auto-invoke matching Skill() when keywords detected
- `.claude/hooks/skill-keywords.json`: routes debug/zombie/rl- → debug-mantra; swiftui/appkit → macos-swiftui; graphify → graphify
- `.gitignore`: track .claude/hooks/ and .claude/settings.json (only ignore worktrees)

## Open Questions
- [none — P28 scope complete]

## Key Files
- `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift` — browser view
- `~/.claude/rules/` — core.md, coding.md, routing.md (restructured)
- `~/.claude/scripts/shared/memory-protocol.md` — shared protocol

## Session Notes
- Build: `make preview`
- NSClickGestureRecognizer ALWAYS consumes mouse events — use mouseUp override instead (RL-043)
