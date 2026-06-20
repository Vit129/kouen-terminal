# Memory — harness-terminal

## Decisions
- ACP enabled (June 2026) — `HARNESS_ACP` flag set in Package.swift; Agent sidebar tab at index 3; adapter binaries `claude-code-acp`/`codex-acp` installed via `harness-cli install-acp`
- MCP install chain complete — `harness-mcp` is built, bundled in .app, auto-refreshed on launch; register with `harness-cli install-mcp [--claude-code|--claude-desktop|--all]`
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
- P24 Complete: all 4 phases shipped (ProjectConfig, agent badges, worktree auto-isolate/archive, GitHub PR/CI inline, browser multi-tab, :make/:recent scoped)
- Browser multi-tab: WKWebView tab bar always visible, target=_blank opens new tab, persistent cookies
- GitHub URLs in terminal open in browser pane (not external Safari)
- CI status shown in PR badge (✓/✗/○)
- Personal project config override: ~/.config/harness/projects/<name>.json
- Sidebar 2-line layout: Line 1 = branch (bold), Line 2 = short cwd (dimmed) — Supacode-style info density
- Top bar always shows branch (⎇) even when agent active — only hides cwd path
- Worktree auto-isolate is ALWAYS ON (not config-gated) — every branch switch → own worktree → correct git probe per tab
- ⌘I opens Agent Notch panel (select notifying agent), persistent peek (no auto-dismiss)

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
- RL-043: NSClickGestureRecognizer on parent view intercepts child NSButton clicks — check click location in handler or use mouseUp override instead

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
