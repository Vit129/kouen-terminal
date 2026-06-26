# Memory Leak Audit — 34 GB Long-Session Case (2026-06-26)

## Symptom
Activity Monitor showed Harness at **34.69 GB resident** after a long session.

## Triage method (always do this first)

```bash
vmmap -summary <pid>    # separates MALLOC_SMALL (heap) vs IOSurface (GPU)
footprint <pid>         # confirms dirty vs. compressed breakdown
```

Result: **MALLOC_SMALL = 30 GB** (Swift heap objects). IOSurface only 36 MB.
→ GPU/Metal hypothesis ruled out immediately. Saved wasted work on `autoreleasepool`.

**Rule: measure the memory region before theorising the mechanism.**

## Root causes found and fixed

### Cause 1 — `existingHosts` strong dict in TerminalPaneRegistry (DOMINANT)
- **Commit:** `0430ed8` (already on main before this audit)
- **Effect:** Every `TerminalHostView` (and its entire Metal/terminal graph) held alive in a strong dict that was never pruned. Dominant contributor to 34 GB.
- **Lesson:** The running binary was built Jun 24, but fix landed Jun 25. Check app mtime vs. fix commit before re-investigating a "still leaks" report.
  ```bash
  stat /Applications/Harness.app/Contents/MacOS/Harness  # mtime
  git log --oneline -1 <fix-commit>                       # commit date
  ```

### Cause 2 — Insert-only AI controller dicts in SessionCoordinator
- **File:** `SessionCoordinator.swift` lines 36–37
- **Pattern:** `private var inlineAIControllers: [String: T] = [:]` — only ever inserted, never removed on pane close.
- **Fix:** `TerminalPaneRegistry.onRetire` hook in `retire()` — the single chokepoint both `removeHost()` and `prune()` funnel through.
  ```swift
  terminalHosts.onRetire = { [weak self] surfaceID in
      self?.inlineAIControllers.removeValue(forKey: surfaceID.uuidString)
      self?.aiChatControllers.removeValue(forKey: surfaceID.uuidString)
  }
  ```
- **Guard:** `Tests/robot/memory_leak_guards.robot` + `Tests/robot/helpers/check_retire_coverage.py` — fails if any `[String: T]` in `SessionCoordinator` is missing from the `onRetire` closure.

### Cause 3 — Uncapped browser network capture array
- **File:** `BrowserPaneView.swift` — JS injection
- **Pattern:** `window.__harnessNetwork.push(entry)` with no trim → grows forever on polling pages.
- **Fix:** `__cap()` function trims to 500 max; monotonic `++window.__harnessNetworkSeq` for IDs (safe after trim, unlike `array.length + 1`).

## Pattern to watch: "insert-only per-surface dict"

Any `[String: T]` or `[SurfaceID: T]` keyed by `surfaceID.uuidString` in `SessionCoordinator` (or similar coordinator) that is **only inserted, never removed** will leak one entry per pane closed forever.

**Invariant:** All such dicts MUST wire into `TerminalPaneRegistry.onRetire`. The Robot guard enforces this automatically.

## What NOT to fix

`autoreleasepool` around `metalLayer.nextDrawable()` — GPU framebuffers were NOT the cause (IOSurface = 36 MB). Do not add this.

## Release
Fixed in v3.9.4 (build 170).
