# Memory — harness-terminal

## Decisions
- ACP shelved — re-enable when adapters ship with agent CLIs natively
- CWD tracking: daemon polls proc_pidinfo 500ms — no shell integration needed
- File preview: constraint-based sibling panel, never reparent terminal views
- ⌘1–9: `selectSession(workspaceID:sessionID:)` — not `selectWorkspace`
- vi mode: `ViEngine` `@MainActor final class` in `ViNormalMode.swift`
- Config centralization: JSON files in `~/Library/Application Support/Harness/` — fallback to hardcoded defaults
- Upstream merge not viable: codebase diverged too far (424 commits, 25% new code) — port by reading instead
- Keybinding single source of truth: `BannerShortcutRegistry` (`Keybinding` struct) — menu, banner, and onboarding all read from one place
- ⌘W = close pane → fall through to close tab if single pane (iTerm2/Warp pattern). ⌘⇧W = force close tab
- ⌘T = new session (not ⌘⇧N)
- IDE-like navigation: double-click folder in sidebar sends `cd <path>` to active terminal
- `:cd` command now sends actual `cd` to shell (not just switch tabs)
- `⌘P` palette zoxide entries cd active terminal instead of creating new session

## Lessons
- RL-004: Never reparent Metal terminal surfaces — 1-2s black screen (CASE-003)
- RL-010: `NSView.displayLink` does NOT strongly retain target — always `deinit { displayLink?.invalidate() }`
- RL-021: Pure transparent window fails on bright bg — use `window.backgroundColor = themeColor.withAlphaComponent(opacity)`
- RL-030: Every `snapshotChanged` consumer must check `metadataOnly` flag before rebuilding
- RL-031: Double-subscription — parent routes to child AND child has own observer = fires twice
- RL-032: NSAlert first button auto-gets `keyEquivalent = "\r"` — Enter ALWAYS fires it regardless of Tab focus. Clear it for destructive dialogs.
- RL-033: Borderless NSPanel `canBecomeKey` defaults to `false` — must subclass and override to accept keyboard input.
- RL-034: Zombie surface view — must discardCursorRects + resign first responder in viewWillMove(toWindow:nil), prune paths, AND deinit. AppKit cursor rect system holds unsafe references. Swift 6 nonisolated deinit workaround: call via `perform(NSSelectorFromString("discardCursorRects"))` — NSObject.perform is not @MainActor and bypasses actor isolation check.
- RL-040: MainActor.assumeIsolated crashes on macOS 26.5 / Swift 6.3.2 when called outside a Swift task context. swift_task_isCurrentExecutorWithFlagsImpl dereferences nil/freed task pointer. Same crash manifests at @MainActor @objc thunk boundary (even without explicit assumeIsolated). Root fix: (1) eliminate zombie views via `TerminalPaneRegistry.retire()` with 500ms delay, (2) remove `nonisolated` from layout overrides — Swift 6.3 allows `@MainActor` override of NSView.layout() directly, (3) avoid `Optional.map {}` closures in @MainActor code (use `if let` instead), (4) NSEvent local monitor in AppDelegate swallows events targeting windowless views, (5) `guard window != nil` at top of keyDown/keyUp as defense-in-depth. The `nonisolated + assumeIsolated` pattern is WRONG — it doesn't prevent thunk-level crashes and breaks AppKit layout semantics. 63 crash reports confirmed; use-after-free proven (FAR not in any VM region).
- RL-041: `keyUp` arrives in a LATER event loop iteration than `keyDown`. A 1-tick async deferred dealloc is insufficient — must hold zombie-prone views for ~500ms to cover the full key press/release cycle and rapid rebuilds.
- RL-035: `local` keyword only works inside bash functions — shell scripts with inline logic must omit it.
- RL-036: NotificationCenter `queue: .main` closures are `@Sendable` — wrap body in `MainActor.assumeIsolated` for Swift 6.
- RL-037: Original upstream had wrong assumption: `CADisplayLink` retains target on macOS (it doesn't — only iOS does).
- RL-038: `NSPanel` never takes `mainWindow` status — use `NSApp.mainWindow` (not `keyWindow`) to anchor floating panels; on 2nd+ open `keyWindow` points at the panel itself and the anchor drifts each time.
- RL-039: Menu `@objc` actions fail before first user click (`keyWindow=nil` on launch). Always chain: `keyWindow ?? mainWindow ?? windows.first(where: { $0.contentViewController is MainSplitViewController })`.
- RL-042: `KeyModifiers` name exists in HarnessTerminalEngine (InputEncoder) — adding same name in HarnessCore causes ambiguity. Used `MenuModifiers` to avoid collision.

## Conventions
- Build: `make preview`
- Test: `swift build` + all test targets
- Services: unowned back-reference to coordinator, lazy init

## Docs
- Keybinding single source of truth: `BannerShortcutRegistry` (`Keybinding` struct) — menu, banner, onboarding, and `docs/KEYBINDINGS.md` all derive from one place
- ⌘T = new session, ⌘W = close pane (or tab if single pane, iTerm2/Warp pattern), ⌘⇧W = force close tab
- IDE-like navigation: double-click folder → cd, `⌘P` fuzzy jump via zoxide, `⌘;` → `:cd <path>` sends to shell, ⌘-click file path → editor
- `⌘P` palette zoxide entries cd active terminal (not create new session)
- Welcome page (CompleteStepView) and terminal banner read shortcuts from `BannerShortcutRegistry`

## Tech Debt
- PBI-REFACTOR-004: `#if HARNESS_ACP` deferred
