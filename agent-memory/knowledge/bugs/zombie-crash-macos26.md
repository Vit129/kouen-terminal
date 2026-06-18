# Zombie View Crashes on macOS 26.5 + Swift 6.3.2

> Covers CASE-034 (superseded), CASE-037, CASE-038, CASE-039, CASE-040.
> Promoted from playbook — recurring pattern (40 crashes, Jun 13–18 2026).

## Root Cause

macOS 26.5 with Swift 6.3.2 changed executor isolation checking. Every `@objc` method/property thunk on a `@MainActor` class now calls `swift_task_isCurrentExecutorWithFlagsImpl` → `swift_getObjectType(self)` at **function entry** — before any user code executes.

If `self` is freed memory (zombie), `swift_getObjectType` dereferences invalid type metadata → `EXC_BAD_ACCESS`.

This means **no guard code inside the method body can prevent the crash** — it happens at the thunk level.

## What Triggers Zombie Views

1. **Snapshot fanout timing change** (commit `9792410`, Jun 16) — refactored 5-sec sync into on-demand → views get rebuilt/freed at different timings than before.
2. **Pane container rebuild** — `reloadIfNeeded` removes old PaneContainerView, frees orphaned terminal hosts.
3. **Session/tab close** — `TerminalPaneRegistry.removeHost()` drops the last strong reference.
4. **SwiftUI @Observable lifecycle** — `WorkspaceFileTreeView` dealloc frees `FileTreeContext` while SwiftUI observation tracking still holds a reference.

## Crash Sites (by frequency)

| Site | Count | Mechanism |
|------|-------|-----------|
| `@objc layout()` thunk | 12 | AppKit queued layout on freed view |
| `@objc resetCursorRects()` | 7 | AppKit async cursor rect callback |
| `@objc keyDown/keyUp(with:)` | 6 | Event dispatched to freed first responder |
| `FileTreeSwiftUIView.body.getter` | 5 | SwiftUI re-evaluates freed @Observable |
| `@objc mouseMoved(with:)` | 4 | NSTrackingArea callback on freed view |
| `restartBlinkTimer()` closure | 3 | Timer fires after view dealloc |
| `@objc isFlipped` getter | 2 | Hit-test reads property on freed view |
| `Optional.map {}` closure | 1 | Closure executor check on nil task context |

## Fixes Applied

### 1. `TerminalPaneRegistry.retire()` — deferred dealloc (100ms)

```swift
private func retire(_ host: TerminalHostView) {
    host.resignIfFirstResponder()
    host.removeFromSuperview()
    retired.append(host)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        self?.retired.removeAll { $0 === host }
    }
}
```

**Why 100ms:** `keyUp` arrives in a LATER event loop iteration than `keyDown`. A single async tick (1 run loop pass) is insufficient. 100ms covers the full key press/release cycle and any pending layout/hit-test passes.

**Also applied to:** `retiredContainer` in `ContentAreaViewController.reloadIfNeeded`.

### 2. Remove `nonisolated` from all layout overrides

```swift
// WRONG (crash at thunk + breaks AppKit semantics):
override nonisolated func layout() {
    MainActor.assumeIsolated { super.layout(); ... }
}

// CORRECT (Swift 6.3 allows this directly):
override func layout() {
    super.layout()
    ...
}
```

**Why it works:** Swift 6.3.2 allows `@MainActor` classes to override `layout()` without `nonisolated`. The `@objc` thunk generated for a non-`nonisolated` override doesn't do a runtime executor check — it trusts the compile-time annotation.

**Applied to:** 16 views across HarnessControls, HarnessDesign, ContentAreaViewController, TerminalTabBarView, WindowBorderOverlayView, NotificationBellButton, GitPanelView.

### 3. Remove `MainActor.assumeIsolated` from callbacks

```swift
// WRONG (crashes on macOS 26.5 outside Swift task context):
Timer(...) { [weak self] _ in
    MainActor.assumeIsolated { guard let self ... }
}

// CORRECT:
Timer(...) { [weak self] _ in
    Task { @MainActor in guard let self ... }
}
```

**Applied to:** blink timer, ResizeHUDView completion, TerminalScrollbarView completion, NSAnimationContext completion, AppDelegate KVO observer, AppIdleThrottle notifications.

### 4. Detach NSHostingView on teardown (FileTreeSwiftUIView)

```swift
override func viewWillMove(toWindow newWindow: NSWindow?) {
    super.viewWillMove(toWindow: newWindow)
    if newWindow == nil {
        hostingView?.removeFromSuperview()
    }
}
```

SwiftUI's observation tracking holds references to `@Observable` objects. Removing the hosting view stops body re-evaluation before the backing context is freed.

### 5. Avoid `Optional.map {}` in @MainActor code

```swift
// WRONG (closure triggers executor check → NULL task):
let x = optional.map { someMethod($0) } ?? fallback

// CORRECT:
let x: Type
if let val = optional { x = someMethod(val) }
else { x = fallback }
```

## The Misdiagnosis (CASE-034)

On Jun 16, an AI agent (Codex) saw `_checkExpectedExecutor` in the crash stack and diagnosed it as "AppKit calling layout from a non-main executor context." The prescribed fix was `override nonisolated func layout() { MainActor.assumeIsolated { ... } }`.

**This was wrong because:**
1. The crash address (`0x93a2df9308000200`) showed PAC-failed freed memory — it was a zombie, not an executor context issue.
2. `nonisolated` + `assumeIsolated` doesn't prevent the `@objc` thunk executor check from crashing on zombie `self`.
3. Deferring `super.layout()` via `DispatchQueue.main.async` breaks AppKit's expectation that layout completes synchronously.
4. The pattern was applied to 21 views, creating 21 new potential crash sites.

## Prevention Rules

1. **Never use `nonisolated` on AppKit overrides** in `@MainActor` classes on Swift 6.3+.
2. **Never use `MainActor.assumeIsolated`** in Timer/NotificationCenter/completion callbacks — use `Task { @MainActor in }` instead.
3. **Always defer view dealloc** when removing terminal hosts — use `retire()` with ≥100ms delay.
4. **Detach NSHostingView** in `viewWillMove(toWindow: nil)` for any NSView-hosted SwiftUI that references `@Observable` objects.
5. **Avoid closures** (`map`, `flatMap`, `compactMap`) on properties inside `@MainActor` code when the closure body calls instance methods — use `if let` / `guard let` instead.

## Timeline

| Date | Event | Version |
|------|-------|---------|
| Jun 15 | Feature rush (browser, IDE keys, agent, board) | v2.5→v3.1 |
| Jun 16 08:55 | Snapshot fanout refactor — changes view lifecycle timing | v3.1.2 |
| Jun 16 10:24 | First mass crashes begin | v3.1.2 |
| Jun 16 17:40 | Codex misdiagnosis — adds nonisolated+assumeIsolated | v3.2.0 |
| Jun 16-17 | 40 crashes total across all categories | v3.2.0-3.2.7 |
| Jun 18 08:10 | Optional.map crash discovered | preview |
| Jun 18 08:13 | keyUp timing discovered (1 tick insufficient) | preview |
| Jun 18 08:39 | All fixes committed — `9102192` | main |
