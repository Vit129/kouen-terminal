# Memory — harness-terminal

## Decisions
- ACP shelved — re-enable when adapters ship with agent CLIs natively
- CWD tracking: daemon polls proc_pidinfo 500ms — no shell integration needed
- File preview: constraint-based sibling panel, never reparent terminal views
- ⌘1–9: `selectSession(workspaceID:sessionID:)` — not `selectWorkspace`
- vi mode: `ViEngine` `@MainActor final class` in `ViNormalMode.swift`
- Config centralization: JSON files in `~/Library/Application Support/Harness/` — fallback to hardcoded defaults
- Upstream merge not viable: codebase diverged too far (424 commits, 25% new code) — port by reading instead

## Lessons
- RL-004: Never reparent Metal terminal surfaces — 1-2s black screen (CASE-003)
- RL-010: `NSView.displayLink` does NOT strongly retain target — always `deinit { displayLink?.invalidate() }`
- RL-021: Pure transparent window fails on bright bg — use `window.backgroundColor = themeColor.withAlphaComponent(opacity)`
- RL-030: Every `snapshotChanged` consumer must check `metadataOnly` flag before rebuilding
- RL-031: Double-subscription — parent routes to child AND child has own observer = fires twice
- RL-032: NSAlert first button auto-gets `keyEquivalent = "\r"` — Enter ALWAYS fires it regardless of Tab focus. Clear it for destructive dialogs.
- RL-033: Borderless NSPanel `canBecomeKey` defaults to `false` — must subclass and override to accept keyboard input.
- RL-034: Zombie surface view — must discardCursorRects + resign first responder in viewWillMove(toWindow:nil), prune paths, AND deinit. AppKit cursor rect system holds unsafe references.
- RL-035: `local` keyword only works inside bash functions — shell scripts with inline logic must omit it.
- RL-036: NotificationCenter `queue: .main` closures are `@Sendable` — wrap body in `MainActor.assumeIsolated` for Swift 6.
- RL-037: Original upstream had wrong assumption: `CADisplayLink` retains target on macOS (it doesn't — only iOS does).
- RL-038: `NSPanel` never takes `mainWindow` status — use `NSApp.mainWindow` (not `keyWindow`) to anchor floating panels; on 2nd+ open `keyWindow` points at the panel itself and the anchor drifts each time.
- RL-039: Menu `@objc` actions fail before first user click (`keyWindow=nil` on launch). Always chain: `keyWindow ?? mainWindow ?? windows.first(where: { $0.contentViewController is MainSplitViewController })`.

## Conventions
- Build: `make preview`
- Test: `swift build` + all test targets
- Services: unowned back-reference to coordinator, lazy init

## Tech Debt
- PBI-REFACTOR-004: `#if HARNESS_ACP` deferred
