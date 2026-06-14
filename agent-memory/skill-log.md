# Skill Log — Improvement Proposals

<!-- Append-only. Never delete entries. -->

| Date | Skill | Problem | Proposed Change | Status |
|------|-------|---------|-----------------|--------|
| 2026-06-07 | AppKit/NSSplitView | Reordering subviews by removing both causes window collapse | Remove only one subview, reinsert with frame restoration — never remove both simultaneously | applied |
| 2026-06-07 | AppKit/NSButton | SoftIconButton with isTransparent=true doesn't forward rightMouseDown | Override rightMouseDown in SoftIconButton to pop up .menu if assigned | applied |
| 2026-06-07 | AppKit/Menu | NSApp.keyWindow can be nil when menu triggered via AppleScript or non-frontmost | Always use `NSApp.keyWindow ?? NSApp.mainWindow` in menu targets | applied |
| 2026-06-07 | Swift6/Compiler | sortSubviews closure with captured non-Sendable reference crashes compiler (signal 6) | Avoid closures that capture @MainActor refs in C-style comparators; use remove+add instead | applied |
| 2026-06-14 | QA/UIAutomation | P18 UI automation uses Robot Framework + Appium Mac2Driver (not XCUITest) | Load `~/.kiro/skills/qa/robotframework-testing/SKILL.md` + `rules/robotframework-rules` before writing any P18 test code. Requires `accessibilityIdentifier` on NSView elements first (PBI-UI-001). | planned |
| 2026-06-14 | QA/UIAutomation | Appium Mac2Driver requires Appium 3.x (RC); Appium 2.x fails to install mac2 driver | Use osascript (System Events) + harness CLI for macOS native UI tests instead. No Appium server needed — simpler stack, zero extra deps. Implemented in Tests/HarnessRobotTests/libraries/HarnessUILibrary.py | applied |
| 2026-06-14 | Refactoring | SessionCoordinator god-object decomposition (2050→397 LOC) — circular deps between services resolved by `unowned let coord` back-reference pattern | For @MainActor god objects: extract into focused services with lazy init, unowned back-ref, and internal (not private(set)) setters for shared state. Test between each extraction step. | applied |
