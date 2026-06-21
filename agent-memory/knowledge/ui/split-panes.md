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

## Two-Axis Split Parity (P13)

`SplitDirection.horizontal` = side-by-side leaves (vertical divider, "Split Right",
⌘D); `.vertical` = stacked leaves (horizontal divider, "Split Down", ⌘⇧D). AppKit
naming is inverted from this: `split.isVertical = direction == .horizontal` (a
side-by-side leaf pair sits in a *vertical* `NSSplitView` divider). Don't conflate
the two naming systems when reading `PaneContainerView`.

`SessionCoordinator.splitActivePane(direction:)` previously gated out `.vertical`
with a "vertical splits are removed" comment — removed in P13; both directions now
reach `.newSplit(tabID:paneID:direction:shell:)` identically.

For 2-child `.branch` nodes, `PaneContainerView` now wires `split.firstPaneID`,
`split.secondPaneID`, and `split.ratio` from the node (previously left nil for the
general branch case, which broke ratio persistence for stacked splits). N-child
flattened layouts (`flattenSameDirection`) still use `split.ratio = nil`.

`SessionEditor.adjustRatio` takes a `direction: ResizeDirection` parameter and only
adjusts a branch's ratio when the branch's `SplitDirection` matches the resize
axis (`.left/.right` ⟺ `.horizontal`, `.up/.down` ⟺ `.vertical`). Without this axis
check, `resizePane` could walk up to and adjust the wrong-axis ancestor's ratio in
mixed nested layouts (e.g. a `.vertical` resize accidentally resizing a `.horizontal`
ancestor branch).

Backend (`CommandParser`, `CommandIPCTranslator.layoutDirection(for:)`, CLI
`new-split --direction`, `SurfaceRegistry`, `TargetSpec`) already supported `.vertical`
splits and `select-pane -U/-D`/`kill-pane` collapse before P13 — only the
`SessionCoordinator` gate, UI affordances (hover buttons, tab/sidebar/main menus,
command palette), ratio wiring, and docs were blocking. See
`agent-memory/plans/p13-split-pane-parity.md` for the full PBI breakdown.

## Pane Drag-and-Drop (P27)

User drags the ⋮⋮ grip icon (PaneDragGripView) in the pane hover buttons to reorder panes.

**Architecture:**
- `PaneDragGripView` — custom NSView, mouseDown+mouseDragged initiates drag
- `PaneDragController` — singleton state machine, installs NSEvent local monitor for drag/drop/escape
- `PaneDropZoneOverlay` — CAShapeLayer-based zone highlight (L/R/T/B/Center), animated transitions
- Commit: zone → `SplitPaneCoordinator.swapPanes` (center) or `.movePaneToDirection` (edges)
- Model rebuild triggers automatically via `reloadIfNeeded` (no manual view manipulation)

**Zone mapping:**
- Left edge → `joinPane(src, dst, .horizontal, before: true)`
- Right edge → `joinPane(src, dst, .horizontal, before: false)`
- Top edge → `joinPane(src, dst, .vertical, before: true)`
- Bottom edge → `joinPane(src, dst, .vertical, before: false)`
- Center → `swapPanes(src, dst)` (disabled when ≤2 panes)

**Key files:**
- `Apps/.../UI/Chrome/PaneDragController.swift`
- `Apps/.../UI/Chrome/PaneDropZoneOverlay.swift`
- `Apps/.../UI/Chrome/ContentAreaViewController.swift` (PaneDragGripView, paneShell identifier)
- `Apps/.../Services/SplitPaneCoordinator.swift` (swapPanes, movePaneToDirection)

**Constraints respected:** RL-004 (no Metal reparent), RL-040/041 (retire-hold), CASE-003 (presentsWithTransaction)

## Split CWD Resolution — Worktree Priority (2026-06-21)

**Bug:** Cmd+D / Cmd+Shift+D creates new split pane that starts in repo root (`main` branch) instead of the current worktree branch when an agent process is running.

**Root cause:** In `SurfaceRegistry.handleMessage(.newSplit)`, the CWD for the new surface was resolved as:
```swift
let cwd = sourceCwd ?? tabRef?.worktreePath ?? tabRef?.cwd
```

`sourceCwd` = live CWD of the deepest descendant process in the source pane. When an agent (Claude Code, Codex, etc.) runs, `deepestReadableDescendant()` returns the agent's own CWD — which is typically the **repo root** (main branch), not the worktree the session was intended to operate in.

**Fix:** Reorder priority — worktree path wins when set:
```swift
let cwd = tabRef?.worktreePath ?? sourceCwd ?? tabRef?.cwd
```

**Why worktreePath must win:** The `worktreePath` is set when a session is created via worktree auto-isolate — it represents the *intended workspace* for that session/tab. The live process CWD is just an artifact of whatever subprocess happens to be running.

**File:** `Packages/HarnessDaemon/Sources/HarnessDaemon/SurfaceRegistry.swift` (line ~360)

**Related:** `DaemonSyncService` git branch probe already uses `tab.worktreePath ?? tab.cwd` — this aligns the split creation with the same priority.
