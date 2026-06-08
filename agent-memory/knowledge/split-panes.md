# Split Panes (NSSplitView)

## Ratio Persistence (CASE-002)

NSSplitView subviews collapse to 0 when custom ratios are lost on rebuild.

**Fix:** Set subviews `autoresizingMask = [.width, .height]`. Store ratio in `HarnessSplitView`, call `setPosition` on first layout pass with non-zero frame. Set `appliedRatio` flag *before* calling `setPosition` to prevent recursive stack overflow.

## Infinite Recursion (CASE-006)

`NSSplitView.setPosition` in `layout()` causes infinite recursion when N>2 subviews.

**Fix:** Add `isApplyingPositions` bool guard — set true before loop, check at entry. `appliedRatio` alone insufficient because `setPosition` triggers layout for each divider.

## Subview Reorder (CASE-007)

Reordering via `removeFromSuperview` + `addSubview` causes window collapse/black.

**Fix:** Remove only the view being moved, reinsert with `addSubview(_:positioned:relativeTo:)`, restore frames after reinsert, call `adjustSubviews()`. Never remove both subviews simultaneously.

## Architecture

- `PaneContainerView` builds from `PaneNode` binary tree
- `HarnessSplitView` (NSSplitView subclass) per branch node
- Split buttons: `PaneSplitButtonsView` — overlay at top-right with zPosition 1000
