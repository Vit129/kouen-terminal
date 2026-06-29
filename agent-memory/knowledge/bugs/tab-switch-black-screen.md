---
name: tab-switch-black-screen
description: Tab switching (⌘1/2/3) shows black screen on revisiting a previously-visited tab. Root cause: container caching introduced Jun 22 had multiple compounding failure modes.
metadata:
  type: project
  confidence: 1.0
  date: 2026-06-29
  branch: fix/display-switch-black-screen
---

# Bug: Tab-Switch Black Screen

## Symptom
Switching between terminal tabs (⌘1/⌘2/⌘3) shows a **black content area** when returning to a previously-visited tab.

## Root Cause Chain

Container caching was introduced in `de39a37` (Jun 22). Fast path reveals a cached `PaneContainerView` instead of rebuilding. Four independent failure modes made the cached container empty:

### FM-1: detachHostsOnly() before caching (always broken)
Original slow path called `detachHostsOnly()` on the current container, then stored the now-empty shell in `containerCache[prevTabID]`. Fast path would reveal an empty container → black.

**Fix:** Skip `detachHostsOnly()` when `force=false` (tab switch). Only detach on structural rebuild (`force=true`).

### FM-2: force=true rebuild caches the stripped container
When a structural rebuild (`force=true`) ran while on tab X, `detachHostsOnly()` stripped tab X's container, then `containerCache["tabX"] = empty container`. Next revisit → fast path → black.

**Fix:** When `force=true`, `containerCache.removeValue(forKey: prevTabID)` + `removeFromSuperview()` instead of caching the emptied shell.

### FM-3: Host theft by another tab's build
`TerminalHostView` is **shared single-instance per surfaceID** (via `coordinator.terminalHost(for:)`). When any tab's `PaneContainerView.build()` calls `coordinator.terminalHost(for: surfaceID)` and the returned host currently lives in a hidden cached container, `paneShell.addSubview(host)` **silently removes it from the hidden container**. Next fast-path revisit: `collectTerminalHosts()` → 0 → black.

**Fix:** Validate `Set(displayNode.allSurfaceIDs()).isSubset(of: Set(cachedHosts.keys))` before committing to fast path. If any host is missing → evict + fall through to slow rebuild.

### FM-4: Cache overwrite leaks orphan containers
`containerCache[tabID] = newContainer` without evicting the previous entry → orphaned hidden subview with live Metal surfaces and display links accumulate in `terminalHost`.

**Fix:** Before storing new entry: if `containerCache[tabID] !== newContainer`, call `containerCache[tabID]?.removeFromSuperview()`.

## Instrumentation method
Added `NSLog("[TAB-DBG]")` probes at fast/slow path decision points. Key finding: tab `4E14E95D` consistently showed `hosts found: 0` — traced to FM-2 (force=1 structural rebuild ran while that tab was active).

## Final fast-path guard (PaneLifecycleManager.swift)

```swift
if !force, let cached = containerCache[tabID], cached !== paneContainer, cached.superview == terminalHost {
    let expectedSurfaces = Set(displayNode.allSurfaceIDs())
    let cachedHosts = cached.collectTerminalHosts()
    if expectedSurfaces.isSubset(of: Set(cachedHosts.keys)) {
        // reveal, forceRepaint, return
    }
    // validation failed → evict
    containerCache.removeValue(forKey: tabID)
    cached.removeFromSuperview()
}
```

## Key invariant
`forceRepaint()` → `nativeView.layout()` is always safe for a stayed-in-window host: `renderer` is never nil (never torn down while in window), `window` is non-nil (container is in terminalHost). `layout()` calls `repaintLastFrame()` or falls back to `forceRender()` — both produce visible content synchronously.

## Key anti-pattern
**Never call `detachHostsOnly()` before caching a container.** Detach is for structural rebuilds only (reuse hosts in new container). Tab switch caching must leave hosts intact.

## Files changed
- `Apps/Harness/Sources/HarnessApp/UI/Chrome/PaneLifecycleManager.swift` (all fixes)
- `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/TerminalHostView.swift` (added `forceRepaint()`)
