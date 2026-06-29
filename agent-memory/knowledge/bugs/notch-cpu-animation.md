# Notch Panel CPU Spike — AnimatableFrameAttribute Loop

## Symptom

`sample <pid> 5` shows 70–100% CPU dominated by:
```
AnimatableFrameAttribute.updateValue()
  DefaultCombiningAnimation._updateAnimation()
    CA::Transaction::commit()
      NSDisplayCycleFlush (RunLoop observer)
```

App idles at 0% CPU except for the Notch panel.

## Root Cause Chain

```
snapshotChanged (every 0.5–2s)
  → refreshVisibility()
  → updatePanelGeometry()
  → panel.setFrame()            ← triggers NSHostingView layout pass
  → NSHostingView.layout()      ← SwiftUI re-evaluates body
  → .animation(.spring, value: openContentHeight) on .frame()
  → AnimatableFrameAttribute.updateValue() fires 60×/s
  → spring never converges (setFrame restarts it before 0.3s settle)
  → 100% CPU forever
```

**Secondary:** `AgentDetector.scan()` called every 1.5s via `AgentScanner`,
which calls `proc_listpids(ALL_PIDS)` + `proc_pidinfo` per PID — expensive.

## Fixes Applied (layered)

### 1. Data / Geometry Separation (primary fix)
`snapshotChanged` must NOT call geometry-touching code. Panel geometry
is screen-layout, not snapshot-driven.

```swift
// NotchPanelController.snapshotChanged
// BEFORE: refreshVisibility() → panel.setFrame() on every snapshot
// AFTER:
coalescer.signal { [weak self] in self?.model.refreshFromCoordinator() }
```

### 2. SnapshotCoalescer (cmux NotificationBurstCoalescer pattern)
Collapse snapshot storms to one refresh per runloop turn.

```swift
// SnapshotCoalescer.swift
func signal(_ action: @escaping @MainActor () -> Void) {
    self.action = action
    guard !pending else { return }
    pending = true
    DispatchQueue.main.async { [weak self] in self?.flush() }
}
```

### 3. Equality Guard on updateGeometry (Zed pattern)
```swift
func updateGeometry(_ geometry: NotchLayoutMetrics) {
    guard geometry != self.geometry else { return }  // skip @Published fire if unchanged
    self.geometry = geometry
}
```

### 4. Dirty Flag on setFrame (Otty/WezTerm pattern)
```swift
let newFrame = nsRect(metrics.panelFrame)
guard panel.frame != newFrame else { return }
panel.setFrame(newFrame, display: true)
```

### 5. GPU Animation — CAShapeLayer Mask (Zed/Otty GPU path)
Remove SwiftUI `.animation()` on `.frame()` entirely.
Replace with `CABasicAnimation` on `CAShapeLayer.path` — runs on render server.
See `patterns/gpu-animation-ca.md`.

### 6. AgentScanner timer split
Split 1.5s combined timer into:
- `metadataTimer` (1.5s) — cheap per-surface `proc_pidinfo`
- `agentScanTimer` (30s) — expensive `proc_listpids(ALL_PIDS)` fallback
- OSC 26 is the primary zero-cost push-based path

## Files

- `HarnessApp/UI/Notch/NotchPanelController.swift`
- `HarnessApp/UI/Notch/AgentNotchViewModel.swift`
- `HarnessApp/UI/Notch/AgentNotchRootView.swift`
- `HarnessApp/UI/Notch/NotchMaskAnimator.swift`
- `HarnessApp/UI/Notch/NotchShape.swift`
- `HarnessApp/UI/Notch/NotchPanel.swift`
- `HarnessApp/Services/SnapshotCoalescer.swift`
- `HarnessDaemon/AgentScanner.swift`

## Profiling Command

```bash
sample $(pgrep Harness) 5 | grep -A5 "AnimatableFrame\|proc_listpids\|NSHostingView"
```
