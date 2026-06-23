# RL Lessons — harness-terminal

Grep target: `grep -n "RL-<number>\|<keyword>" knowledge/rl-lessons.md`

## AppKit / Views

- RL-004: Never reparent Metal terminal surfaces — 1-2s black screen (CASE-003)
- RL-010: `NSView.displayLink` does NOT strongly retain target — always `deinit { displayLink?.invalidate() }`
- RL-021: Pure transparent window fails on bright bg — use `window.backgroundColor = themeColor.withAlphaComponent(opacity)`
- RL-030: Every `snapshotChanged` consumer must check `metadataOnly` flag before rebuilding
- RL-031: Double-subscription — parent routes to child AND child has own observer = fires twice
- RL-032: NSAlert first button auto-gets `keyEquivalent = "\r"` — Enter ALWAYS fires it regardless of Tab focus. Clear it for destructive dialogs.
- RL-033: Borderless NSPanel `canBecomeKey` defaults to `false` — must subclass and override to accept keyboard input.
- RL-035: `local` keyword only works inside bash functions — shell scripts with inline logic must omit it.
- RL-037: `CADisplayLink` does NOT retain target on macOS (only iOS does) — always invalidate in deinit.
- RL-038: `NSPanel` never takes `mainWindow` status — use `NSApp.mainWindow` (not `keyWindow`) to anchor floating panels; on 2nd+ open `keyWindow` points at the panel itself.
- RL-039: Menu `@objc` actions fail before first user click (`keyWindow=nil` on launch). Chain: `keyWindow ?? mainWindow ?? windows.first(where: { $0.contentViewController is MainSplitViewController })`.
- RL-042: `KeyModifiers` name exists in HarnessTerminalEngine — adding same in HarnessCore causes ambiguity. Use `MenuModifiers`.
- RL-043: NSClickGestureRecognizer on parent view intercepts child NSButton clicks — check click location in handler or use mouseUp override instead.
- RL-044: Documenting a verb in COMMANDS.md/BannerShortcutRegistry without adding it to `CommandParser.buildCommand` + `knownVerbs` = silent `unknownCommand`. Always wire both layers.
- RL-049: `nonisolated override func layout()` + `assumeIsolated` is WRONG for non-zombie-prone views (TerminalTabBarView, WindowBorderOverlayView) — triggers thunk executor check crashes under Swift 6.3/6.4. Use standard `override func layout()`.
- RL-050: Retain cycles in NSEvent local monitors prevent deinit. Use `[weak self]`.
- RL-051: `NSTableView.view(atColumn:row:makeIfNecessary:)` throws NSRangeException if row ≥ count. Call `reloadData()` BEFORE iterating rows. Guard with `min(rows.count, sessionTable.numberOfRows)`.
- RL-054: Toggling `isHidden` on NSSplitView subview — always call `split.adjustSubviews()` explicitly to force other subviews to resize.

## Swift 6 / Concurrency

- RL-034: Zombie surface view — discardCursorRects + resign first responder in `viewWillMove(toWindow:nil)`. Swift 6 nonisolated deinit workaround: `perform(NSSelectorFromString("discardCursorRects"))`.
- RL-036: NotificationCenter `queue: .main` closures are `@Sendable` — wrap body in `MainActor.assumeIsolated` for Swift 6.
- RL-040: `@MainActor @objc` thunks on macOS 26.5/Swift 6.3 call `swift_getObjectType(self)` before method body — zombie = crash. Fix: `nonisolated override` + `MainActor.assumeIsolated` on ALL high-freq AppKit callbacks. See `knowledge/bugs/zombie-crash-macos26.md` for full detail.
- RL-041: `keyUp` arrives in a LATER event loop iteration than `keyDown`. Hold zombie-prone views ≥500ms.
- RL-045: Override `removeFromSuperview()` on zombie-prone views — catches ALL removal paths at single chokepoint.
- RL-046: `nonisolated + assumeIsolated` must cover ALL `@objc` callbacks: `layout()`, `resetCursorRects()`, `viewDidMoveToWindow()`, `viewDidMoveToSuperview()`, `viewWillMove(toWindow:)`, `displayTick()`.
- RL-052: `Task { }` inside `@MainActor` class inherits MainActor — `Process.waitUntilExit()` blocks main thread. Fix: `Task.detached(priority: .utility)`.
- RL-053: Mutating `@Observable` state from SwiftUI `body` = infinite re-render loop. Use `@ObservationIgnored` on async caches, pass pre-computed values to child views.

## Browser / WKWebView

- RL-048: harness-mcp DaemonClientActor default timeout=2s but WKWebView ops take 2–5s. Fix: `HarnessBrowserTools.send()` passes `timeout:35`.
- RL-055: `DateFormatter` init inside high-frequency main thread WKWebView callbacks blocks UI run loop. Offload to `DispatchQueue.global(qos: .utility)`.
- RL-056: High-frequency WKScriptMessageHandler (console.log) must batch writes — spawning one `DispatchQueue.global` work item per message saturates main thread. Throttle: collect into array, flush every 100ms with single async dispatch.
- RL-057: `PaneLifecycleManager` fast path (`!force && cached tabID → skip rebuild`) fires even when pane structure changes in-place (e.g. adding browser pane to existing tab). Guard: `cached !== paneContainer` — ensures fast path only applies to tab-switch restores, not structural mutations.
- RL-058: `NSSplitView.adjustSubviews()` after sidebar `isHidden` toggle redistributes ALL subview frames from scratch — triggers Metal surface layout cascade → 1-frame black flash. Use `setSidebarWidth() + split.layout()` instead. `adjustSubviews()` is only safe when no Metal terminal surfaces are in the subtree.

## Architecture / Daemon

- RL-047: Split pane CWD must prefer `tab.worktreePath` over live process CWD. Agent CWD = repo root. Priority: `worktreePath → sourceCwd → tab.cwd`.
