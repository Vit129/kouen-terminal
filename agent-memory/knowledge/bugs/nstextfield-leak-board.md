# NSTextField Leak in BoardViewController (P20 Performance)

> Memory leak: 21GB in 11 hours. CPU: 30% steady state.
> Fixed in commit `2d3a577` (Jun 18 2026).

## Symptom

After 10+ hours of use with active agents (Claude Code, Codex, etc.):
- Physical memory: 21GB+ (should be ~300MB)
- CPU: 30% constant (should be <5% idle)
- UI lag: layout passes take 670/776 samples (86% of main thread)

## Root Cause

`BoardViewController.reload()` rebuilds the entire board UI on every `agentStateChanged` and `snapshotChanged` notification:

```swift
columnsStack.subviews.forEach { $0.removeFromSuperview() }
for column in columns {
    columnsStack.addArrangedSubview(makeColumnView(column))  // creates NSTextFields
}
```

Each `makeColumnView` / `makeCardView` creates 3-5 new `NSTextField` instances. `removeFromSuperview()` removes them from the view hierarchy but **doesn't guarantee deallocation** — AppKit's internal `NSNotificationCenter` observers (registered in `-[NSView _commonAwake]`) hold references that prevent immediate collection.

With active agents, `agentStateChanged` fires every few seconds → ~17 leaked NSTextFields/sec → 1M+ per day.

## Why CPU Goes Up

The ObjC runtime's weak reference table grows proportionally to leaked objects. `weak_entry_for_referent` (hash table lookup) degrades from O(1) to O(n) as the table fills. Every `NSTextField.layout()` triggers multiple weak ref operations → 86% of main thread consumed by layout.

## Fix

```swift
@objc func reload() {
    let newColumns = BoardModel.classify(...)
    guard newColumns != columns else { return }  // ← skip if unchanged
    columns = newColumns
    // ... rebuild UI ...
}
```

`BoardColumn` is already `Equatable`, so the comparison is cheap. This eliminates ~99% of redundant rebuilds since board state rarely changes between notifications.

## Detection Method

```bash
# Check NSTextField count (should be <100 for a terminal app)
heap <PID> -s 2>&1 | grep NSTextField

# Check growth rate (run twice with 30s gap)
heap <PID> -s 2>&1 | grep NSTextField
sleep 30
heap <PID> -s 2>&1 | grep NSTextField

# CPU profile (1 second sample)
sample <PID> 1 -file /tmp/sample.txt
grep "weak_entry_for_referent\|NSTextField.*layout" /tmp/sample.txt
```

## Prevention Rules

1. **Never rebuild a view hierarchy unconditionally in a notification handler.** Always diff first.
2. **NSTextField created in a function body** (not as a stored property) is a leak risk — AppKit internal observers can hold it alive after `removeFromSuperview`.
3. **`agentStateChanged` fires frequently** when agents are active — any observer must be cheap or gated.
4. Same applies to `snapshotChanged` (non-metadataOnly) — fires on every session/tab/pane structural change.

## Related Files

- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/BoardViewController.swift` — the leak source
- `Packages/HarnessCore/Sources/HarnessCore/Notifications/NotificationBus.swift` — notification dispatch
- `Apps/Harness/Sources/HarnessApp/Services/NotificationCoordinator.swift` — posts `agentStateChanged`
- `Apps/Harness/Sources/HarnessApp/UI/Git/GitPanelView.swift` — similar pattern (lower risk, FSEvents-gated)
