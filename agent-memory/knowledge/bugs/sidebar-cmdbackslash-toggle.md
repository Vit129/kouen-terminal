# Bug — Cmd+\ sidebar toggle gone after collapse

**File:** `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainSplitViewController.swift`
**Status:** FIXED — 2026-06-30
**Introduced:** commit `b9f94cd` (CADisplayLink animation replacing `presentsWithTransaction`)

---

## Symptom

With `sidebarCollapsedOnLaunch = true`:
1. App opens → sidebar collapsed
2. Cmd+\ → sidebar expands ✓
3. Cmd+\ → sidebar collapses ✓
4. Cmd+\ → sidebar stays gone until relaunch ✗

Not 100% reproducible = timing-dependent. Persists for the entire session once triggered.

---

## Confirmed facts

- `sidebarCollapsedOnLaunch = true` (user confirmed)
- `applyInitialSidebarState` sets `settings.sidebarVisible = false` in-memory WITHOUT `settings.save()` → disk says `true`, memory says `false` on launch
- `toggleSidebar` correctly reads in-memory `settings.sidebarVisible` (not disk), so the disk/memory divergence alone doesn't cause the bug

---

## Suspect A — Dead token guard (confirmed code bug)

```swift
// _sidebarLinkFired (line ~357):
animateSidebar(from: _sidebarStart, to: _sidebarTarget, t0: _sidebarT0,
               visible: _sidebarVisible, token: sidebarAnimToken)  // ← live property

// animateSidebar (line ~325):
guard token == sidebarAnimToken  // ← sidebarAnimToken == sidebarAnimToken, ALWAYS TRUE
```

Intent was to pass a *captured snapshot* of the token so that when a new animation starts
(incrementing `sidebarAnimToken`), old display link frames would fail the guard and bail.
Instead, both sides read the live property — the guard is a no-op.

Old display link cancellation relies entirely on `sidebarDisplayLink?.invalidate()`.
If an old link fires one last time after invalidation (same run-loop pass), it reads the
NEW animation's state including `_sidebarVisible`, and may incorrectly complete it.

**Fix:** Capture token at animation start and pass as a local variable to `_sidebarLinkFired`:
```swift
// In applySidebarVisibility:
let capturedToken = sidebarAnimToken
sidebarDisplayLink = view.displayLink(target: BlockTarget { [weak self] link in
    self?.animateSidebar(..., token: capturedToken)
}, selector: #selector(BlockTarget.fire(_:)))
```

---

## Suspect B — Zero-delta early exit trap

```swift
panel.isHidden = false
let start = panel.frame.width        // read DURING collapse animation (may be non-zero)
guard abs(target - start) > 0.5 else {
    // early exit — no animation, panel.isHidden stays false
    ...
    return
}
```

If the user presses Cmd+\ to expand while a collapse animation is still in flight,
`panel.frame.width` may read an intermediate value. If it equals `HarnessDesign.sidebarWidth`
(240), the zero-delta guard triggers: no animation, `panel.isHidden = false`. The in-flight
collapse then completes: `panel.isHidden = true` → panel gone.

---

## Fix

Move `sidebarDisplayLink?.invalidate(); sidebarDisplayLink = nil` to happen **before** reading `panel.frame.width` in the animated path of `applySidebarVisibility`.

**Before (broken):**
```swift
panel.isHidden = false
let start = panel.frame.width      // old link still running — may read stale position
guard abs(target - start) > 0.5 else {
    // early exit — sidebarDisplayLink NOT replaced → old collapse link keeps running
    return
}
...
sidebarDisplayLink?.invalidate()   // too late, only reached when no early exit
```

**After (fixed):**
```swift
sidebarDisplayLink?.invalidate()   // kill in-flight animation first
sidebarDisplayLink = nil
panel.isHidden = false
let start = panel.frame.width      // stable — no animation in flight
guard abs(target - start) > 0.5 else {
    // early exit — safe, old link is already dead
    return
}
```

---

## Related

- `_sidebarLinkFired` / `animateSidebar` / `applySidebarVisibility`: `MainSplitViewController.swift` ~273–360
- CADisplayLink introduced: commit `b9f94cd`
- macOS 26 animation fix: commit `d5833b0`
