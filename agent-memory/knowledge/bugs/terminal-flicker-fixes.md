---
name: terminal-flicker-fixes
description: Root causes and fixes for terminal/UI flicker on layout changes
metadata:
  type: knowledge
---

# Terminal Flicker Fixes

## Root Cause Pattern

All terminal flicker traces to one of two things:
1. **`layoutSubtreeIfNeeded()`** — forces full constraint engine rebuild on entire view subtree including Metal surfaces
2. **Metal surface reparenting** — detach + re-add = 1-2 frame black (RL-004)

## Fixes Applied (v3.9.1+)

### 1. Sidebar toggle (⌘\)
- **Before:** `panel.layoutSubtreeIfNeeded()` before animation + `split.layoutSubtreeIfNeeded()` every frame
- **After:** Removed pre-animation call; per-frame uses `split.layout()` (self only, no subtree)
- **File:** `MainSplitViewController.swift`

### 2. File preview open/close
- **Before:** `containerView.layoutSubtreeIfNeeded()` + `terminalHost.layoutSubtreeIfNeeded()`
- **After:** `containerView.layout()` only
- **File:** `FilePreviewCoordinator.swift`

### 3. Tab switch (⌘1-9, ✕ close)
- **Before:** Full rebuild every tab switch (detach all hosts → remove container → new container → reparent Metal)
- **After:** Cache `PaneContainerView` per tab ID. Tab switch = `isHidden` toggle (zero reparent). Rebuild only on `force` or structural change.
- **File:** `PaneLifecycleManager.swift`

### 4. presentsWithTransaction order fix (ALL remaining flash cases) — v3.9.x+
- **Root cause:** In `HarnessTerminalSurfaceView.layout()`, `metalLayer.presentsWithTransaction = true`
  was set AFTER `updateGridSize()` which changes `metalLayer.drawableSize`. When `drawableSize`
  changes, Metal immediately invalidates the layer's cached content; if no new frame has arrived
  before the next compositor pass, the compositor sees 1 frame of black.
- **Why production flashes but preview doesn't:** REBUILD path calls `detachHostsOnly()` →
  `removeFromSuperview()` → `viewWillMove(toWindow: nil)` → resets `presentsWithTransaction = false`,
  even after `PaneLifecycleManager` set it to `true`. Preview build never hits the rebuild path
  (single session, no persisted tabs, no pane structure changes).
- **Fix:** Set `presentsWithTransaction = true` BEFORE `updateGridSize()` in `layout()`.
  Save/restore the original value (`wasAlreadySync`) so live-resize and PaneLifecycleManager
  ownership is respected.
- **File:** `HarnessTerminalSurfaceView.swift` — `layout()` method

## Rules

```
NEVER use layoutSubtreeIfNeeded() in paths that include terminal Metal surfaces.
Use layout() (self only) or let AppKit layout naturally.

NEVER reparent Metal surfaces for visual state changes.
Use isHidden toggle on cached containers instead.

Cache PaneContainerView per tab — destroy only on tab close, not tab switch.

presentsWithTransaction MUST be set BEFORE drawableSize changes (updateGridSize).
Setting it after is too late — Metal has already invalidated the cached drawable.
```

## Related Lessons
- RL-004: Never reparent Metal terminal surfaces — 1-2s black screen
- RL-052: Task {} + @MainActor + Process.waitUntilExit = freeze
- RL-053: @Observable mutation in SwiftUI body = infinite render loop
- RL-054: viewWillMove(toWindow:nil) resets presentsWithTransaction — don't rely on external
  setPresentsWithTransaction(true) surviving across removeFromSuperview()/addSubview() cycles
