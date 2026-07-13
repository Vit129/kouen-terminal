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

---

## Bug #2 — Cmd+\ squeezes the real terminal pane, real sidebar shows black (2026-07-13)

Different root cause, same shortcut, distinct symptom: after toggling the sidebar,
the **content/terminal pane** gets squeezed down to `KouenDesign.sidebarWidth` (220pt)
and the actual sidebar (never resized) is left showing black/blank at the leftover
(large) width.

**Root cause:** Settings → Appearance → "Sidebar on right" toggle called
`model.update(\.sidebarOnRight, $0)`, which only persists the flag + calls
`applySettingsToHosts()`. It never calls `updateSidebarPlacement()` — the function
that physically reorders the `NSSplitView` subviews to match. Only the menu command
(`toggleSidebarPosition()`, "Move Sidebar to Left/Right") did the flag-flip AND the
physical reorder together.

Once `settings.sidebarOnRight` and the live subview order disagree, the next
Cmd+\ reads the NEW flag for `setSidebarWidth()`'s divider-position math and for
`sidebarContainerView` (`subviews[sidebarOnRight ? 1 : 0]`) — but that index now
points at the OLD physical view. The animation resizes/hides the real terminal
content pane as if it were the sidebar; the real sidebar sits untouched at the
leftover width with no chrome applied at that size.

**Fix:** `SettingsAppearanceView.swift`'s "Sidebar on right" toggle now posts
`Notification.Name("KouenSidebarPlacementChanged")` after `model.update(...)`.
`MainSplitViewController` observes it and calls `updateSidebarPlacement()`
(`MainSplitViewController.swift` — observer added in `viewDidLoad()`, handler
`sidebarPlacementSettingChanged`), the same resync used by the menu command.

**Regression test:** `Tests/KouenAppTests/SidebarPlacementSyncTests.swift` —
reproduces the squeeze without the notification, verifies correct widths with it.

---

## Bug #3 — Same squeeze/black symptom, but from a launch-time layout race, not Settings (2026-07-13)

Same visual signature as Bug #2 (terminal squeezed to ~sidebar width, other side
black) but confirmed reproducible on a **fresh app launch with no Settings
interaction at all** — user reported "just pressing Cmd+\ once already does it."
Bug #2's fix (posting `KouenSidebarPlacementChanged`) did not address this case,
since no Settings change was involved.

**Root cause:** AppKit runs several `viewDidLayout()` passes on window construction
*before the window is ever shown*. During those passes the window is still pinned
to `NSWindow.minSize` (480×400 — set in `MainWindowController.swift`), not its real
launch frame; the real frame (e.g. `screen.visibleFrame`, ~1440×786) lands a few
passes later, once the window actually becomes visible/key. `viewDidLayout()`'s
guard (`!didApplyInitialSidebarState && split.bounds.width > 0`) doesn't check
visibility, so `applyInitialSidebarState()` — and by extension the very first
Cmd+\ toggle, if it lands in this window — can run against the transient 480pt
size. The sidebar's own per-frame math (`setSidebarWidth`) is correct at every
single step (confirmed via direct instrumentation of a real preview build: content
width tracked `totalWidth - width` exactly, frame by frame), but if the toggle's
animation straddles the window's own async resize-to-real-size, the two divider
writers (our manual `CADisplayLink`-driven `setPosition` calls vs. NSSplitView's
own resize-triggered repositioning) can race, leaving the divider at a stale width
even though every logged frame showed the right numbers.

Confirmed via a debug preview build (`Scripts/preview.sh` + temporary `fputs`
instrumentation in `viewDidLayout()`/`setSidebarWidth()`, since neither
`osascript`-driven keystrokes nor screen capture were available in this session —
both blocked by missing Accessibility/Screen-Recording TCC grants): one recorded
run showed `totalWidth` jump from 480→1440 between the initial layout and the
toggle firing 2s later, with every animation frame computing the correct position
relative to 1440 (ending at `position=1220.0`), yet the content pane measured
**479** one second after the toggle completed — reverted to the pre-resize width
despite the animation's own math being right throughout.

This is why it's inconsistently reproducible in a debug preview build but reliably
reproducible on the real (release, `-c release`) production app: release-vs-debug
timing shifts exactly how wide the race window is and how likely a human's Cmd+\
press is to land inside it — narrower/differently-timed in debug, apparently wide
enough in release to hit consistently.

**Fix:** `viewDidLayout()` now gates on `view.window?.isVisible == true` before
ever calling `applyInitialSidebarState()`. Since a keypress cannot fire before the
window is key/visible anyway, this closes the only window during which the race
could start.

**Regression test:** `Tests/KouenAppTests/SidebarPlacementSyncTests.swift` —
`testViewDidLayoutDoesNotAutoApplyStateWithoutAWindow` confirms the guard no-ops
with no window attached. A full real-window-visibility variant was attempted but
dropped: `NSWindow.makeKeyAndOrderFront` in this session's `swift test` CLI host
clamps windows to a tiny, unrelated size (no working WindowServer/display in this
sandboxed environment — the same limitation class as `CADisplayLink` never firing
and `bundleProxyForCurrentProcess` being nil in other tests), making frame-based
assertions unreliable. The guard's *effect* (no window → no auto-apply) is what's
tested; the full live race was verified via the instrumented preview build instead,
not via an automated test.
