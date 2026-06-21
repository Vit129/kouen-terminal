# Zombie View Crashes on macOS 26.5 + Swift 6.3.2

> Covers CASE-034 (superseded), CASE-037, CASE-038, CASE-039, CASE-040.
> Promoted from playbook — recurring pattern (63 crashes, Jun 13–18 2026).

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

### 1. `TerminalPaneRegistry.retire()` — deferred dealloc (500ms)

```swift
private func retire(_ host: TerminalHostView) {
    host.resignIfFirstResponder()
    host.removeFromSuperview()
    retired.append(host)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        self?.retired.removeAll { $0 === host }
    }
}
```

**Why 500ms:** `keyUp` arrives in a LATER event loop iteration than `keyDown`. A single async tick (1 run loop pass) is insufficient. 500ms covers the full key press/release cycle and any pending layout/hit-test passes.

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

### 6. Guard `updateTrackingAreas()` against windowless views

```swift
override public func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let trackingArea { removeTrackingArea(trackingArea) }
    guard window != nil else { trackingArea = nil; return }
    // ... create and add new tracking area ...
}
```

**Why:** AppKit calls `updateTrackingAreas()` during layout/dealloc cycles even AFTER `viewWillMove(toWindow: nil)` removed the tracking area. Without this guard, the tracking area is re-created on a windowless view → view deallocates → `mouseMoved` dispatches to zombie via the orphaned tracking area.

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
3. **Always defer view dealloc** when removing terminal hosts — use `retire()` with ≥500ms delay.
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
| Jun 18 11:00 | updateTrackingAreas re-add after removal discovered | preview |
| Jun 18 12:08 | TabPillView same pattern (18 total sites fixed) | build 153 |
| Jun 18 13:55 | 100ms retire insufficient — launch rebuild race | build 154 |
| Jun 18 14:12 | Script crash loop — old app crashes during install | build 154 |
| Jun 18 14:15 | All fixes complete: 500ms + script kill-first | main |
| Jun 18 17:32 | Confirmed use-after-free: `self` (x0) not in any VM region | build 154 |
| Jun 18 20:02 | 63 total crash reports; 3 distinct variants confirmed | build 154 |

## Why It Took So Long

1. **macOS 26.5 + Swift 6.3.2** changed executor check → exposed latent zombies that never crashed before
2. **Codex misdiagnosis** (CASE-034) added `nonisolated+assumeIsolated` which made things worse
3. **Multiple free paths**: `registry.prune`, `detachHostsOnly`, `retiredContainer`, `removeHost` — each needed separate handling
4. **Timing sensitivity**: 1 async tick → 100ms → 500ms — had to empirically find the right delay
5. **`updateTrackingAreas`** re-creates tracking areas after removal — required fixing all 18 sites
6. **Script ordering**: `make install` opened app before build finished → crash loop masked the real fix
7. **Binary mismatch**: fixes pushed to git but installed app still ran old binary → false "still crashing"

## Script Fix (Crash Loop Prevention)

Old order: `build → kill → open` (app crashes during build)
New order: `kill → wait 1s → build → install → open`

Applied to: `Scripts/run.sh` (prod), `Scripts/install-app.sh`

### 7. Guard NSTableView delegate against stale row index

```swift
func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard row < cachedSidebarRows.count else { return nil }
    // ...
}
```

**Why:** NSTableView can call delegate methods with a row index based on a stale `numberOfRows` count if the data source was rebuilt between the count query and the delegate call (classic AppKit race during rapid snapshot changes).

### 8. NSEvent local monitor — the definitive fix (sender-side prevention)

```swift
NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .mouseMoved, .mouseEntered, .mouseExited]) { event in
    guard let window = event.window else { return event }
    if let responder = window.firstResponder as? NSView, responder.window == nil {
        return nil // swallow — target view is no longer in a window
    }
    return event
}
```

**Why this is the definitive fix:** All other fixes (resign, retire, tracking area guard) operate at the *receiver side* — they try to prevent the view from being a target. But the crash occurs at the `@objc` thunk *before* any receiver code runs. The local event monitor fires *before* AppKit dispatches the event, allowing us to cancel it if the target is a zombie. This is the only approach that prevents the crash at source.

**Applied in:** `AppDelegate.applicationDidFinishLaunching` — runs once at app startup, protects all views for the app's lifetime.

### 9. Guard `keyDown`/`keyUp` against windowless view (defense-in-depth)

```swift
public override func keyDown(with event: NSEvent) {
    guard window != nil else { return }
    // ...
}
public override func keyUp(with event: NSEvent) {
    guard window != nil else { return }
    // ...
}
```

**Why:** Even with the event monitor (fix #8), if `self` is alive but detached (window == nil), the `@objc` thunk's executor check may still succeed on the alive-but-orphaned object, allowing execution to reach the method body. The body then crashes on dangling references. This guard prevents any processing on a detached view.

**Limitation:** Does NOT help when `self` is truly freed (use-after-free) — the crash happens at the thunk before any Swift code runs.

**Applied in:** `HarnessTerminalSurfaceView+Input.swift` (build 154+).

## Use-After-Free Confirmation (Jun 18 2026)

Analysis of crash report `Harness-2026-06-18-173225.ips`:
- `x0` (self) = `0x3e1aa0103e8`
- FAR (faulting address) = `0x3e1aa010408` (offset +32 from self — type metadata read)
- VM region info: "not in any region" — **object is freed memory**
- This proves a true use-after-free, not merely a detached-but-alive scenario

### Three distinct crash variants confirmed:

1. **keyDown thunk** (most frequent): `swift_getObjectType → swift_task_isCurrentExecutorWithFlagsImpl → @objc keyDown`
2. **[NSView subviews]** walk: `objc_class::realizeIfNeeded → class_createInstance → [NSView subviews]` — freed view hierarchy
3. **BrowserPaneView.removeFromSuperview()** thunk: executor check on `@MainActor` view during removal

All three share the same root: the Swift 6.3.2 runtime on macOS 26.5 crashes when verifying MainActor isolation on freed objects. The event monitor (fix #8) is the primary defense; the retire delay (fix #1) is the secondary defense. If both fail (race condition during rapid rebuild + dealloc), the crash is unavoidable at the Swift runtime level.

## Open: Remaining Crash Sources

~~The `ContentAreaViewController.detachHosts(in:)` method calls `host.removeFromSuperview()` directly (bypassing `TerminalPaneRegistry.retire()`).~~

**RESOLVED (2026-06-21):** Universal retire-hold via `removeFromSuperview()` override in `HarnessTerminalSurfaceView` eliminates ALL remaining free-path zombies. See Fix #10 below.

### 10. Universal retire-hold via `removeFromSuperview()` override (definitive)

```swift
// In HarnessTerminalSurfaceView:
private static var retiredSurfaces: [HarnessTerminalSurfaceView] = []

public override func removeFromSuperview() {
    Self.retiredSurfaces.append(self)
    super.removeFromSuperview()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        Self.retiredSurfaces.removeAll { $0 === self }
    }
}
```

**Why this is the definitive fix for surface views:** Instead of chasing every call site that removes the view (our code, AppKit internal rebuild, NSSplitView collapse, SwiftUI lifecycle, NSWindow close), the override catches ALL of them at the single chokepoint. No matter who calls `removeFromSuperview()`, the view lives for 1.5s after removal — covering the full keyDown→keyUp cycle and any pending layout/cursor-rect/tracking-area callbacks.

**Supersedes:** Fix #1 (`TerminalPaneRegistry.retire()`) and the `ContentAreaViewController.retiredHosts` static array are now redundant for surface views specifically, but left in place as defense-in-depth for non-surface terminal hosts.

### 11. NSEvent local monitor installed in AppDelegate (fix #8 actually deployed)

The knowledge doc documented Fix #8 but it was never actually installed in `AppDelegate.applicationDidFinishLaunching`. Added 2026-06-21:

```swift
NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .mouseMoved, .mouseEntered, .mouseExited]) { event in
    guard event.window != nil else { return event }
    if let responder = event.window?.firstResponder as? NSView, responder.window == nil {
        return nil
    }
    return event
}
```

**Note:** This only helps when `self` is alive but detached (window == nil). If `self` is truly freed (use-after-free), `firstResponder` is a dangling pointer and this check may itself crash. Fix #10 (retire-hold) is the primary defense; this monitor is secondary.