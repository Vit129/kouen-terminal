# Memory — harness-terminal

## Decisions
- ACP shelved — re-enable when adapters ship with agent CLIs natively
- CWD tracking: daemon polls proc_pidinfo 500ms — no shell integration needed
- File preview: constraint-based sibling panel, never reparent terminal views
- ⌘1–9: `selectSession(workspaceID:sessionID:)` — not `selectWorkspace`
- vi mode: `ViEngine` `@MainActor final class` in `ViNormalMode.swift`

## Lessons
- RL-004: Never reparent Metal terminal surfaces — 1-2s black screen (CASE-003)
- RL-010: `NSView.displayLink` does NOT strongly retain target — always `deinit { displayLink?.invalidate() }`
- RL-021: Pure transparent window fails on bright bg — use `window.backgroundColor = themeColor.withAlphaComponent(opacity)`
- RL-030: Every `snapshotChanged` consumer must check `metadataOnly` flag before rebuilding
- RL-031: Double-subscription — parent routes to child AND child has own observer = fires twice

## Conventions
- Build: `make preview`
- Test: `swift build` + all test targets
- Services: unowned back-reference to coordinator, lazy init

## Tech Debt
- PBI-REFACTOR-004: `#if HARNESS_ACP` deferred
