# Browser Tab Close Button Unresponsive

Status: **Potentially unresolved** — fix applied but not yet verified on device.

## Symptom

Clicking the `×` (close) button on a browser tab does nothing. The tab cannot be closed.

## Root Cause

`BrowserTabButton` has an `NSClickGestureRecognizer` on the entire view for tab selection.
This gesture recognizer intercepts clicks on the embedded `NSButton` (`closeBtn`) before
the button's target-action fires.

## Fix Applied

`selectTapped(_:)` now receives the gesture recognizer parameter and checks if the
click location falls within `closeBtn.frame` — if yes, returns early without calling
`onSelect()`, allowing the button's own action to fire.

## If Fix Is Insufficient

The `NSClickGestureRecognizer` may still consume the event before the `NSButton` processes
it. Alternative fixes in order of preference:

1. **Remove gesture recognizer entirely** — override `mouseUp(with:)` on `BrowserTabButton`
   and check if click is on close button vs body area
2. **Use `NSGestureRecognizerDelegate`** — implement `gestureRecognizer(_:shouldReceive:)`
   to reject events in close button's rect
3. **Replace `NSButton` with another gesture recognizer** for close — both fire independently

## Files

- `Apps/Harness/Sources/HarnessApp/UI/Chrome/BrowserPaneView.swift` (BrowserTabButton class, end of file)
