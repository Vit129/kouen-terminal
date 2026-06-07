# P3 — N-ary Split Panes (Fix terminal disappearing + even sizing)

Status: **planned**  
Priority: **P0** — core UX broken  
Depends on: none  

---

## Problem

1. **Split down → terminal goes black** — `PaneContainerView` rebuilds entire view tree on structure change; `removeFromSuperview()` kills Metal CADisplayLink; `viewDidMoveToWindow` not fired on same-window reparent.
2. **Split 3+ panes stack right** — PaneNode is a binary tree; nested 50/50 NSSplitViews = each new pane gets half of the previous (50% → 25% → 12.5%).

## Root Cause

- Binary tree model forces nested NSSplitView (2 children each)
- Full rebuild on every structure change destroys live Metal surfaces
- NSSplitView natively supports N subviews with `adjustSubviews()` — we don't leverage this

## Solution: Flat N-ary PaneNode + Incremental Update

### Model Change

```swift
// Before: binary tree
enum PaneNode {
    case leaf(PaneLeaf)
    case branch(direction: SplitDirection, ratio: Double, first: PaneNode, second: PaneNode)
}

// After: N-ary flat list per direction
enum PaneNode {
    case leaf(PaneLeaf)
    case split(direction: SplitDirection, children: [PaneNode], ratios: [Double])
}
```

### View Change

```swift
// Before: nested NSSplitView (1 per branch node, 2 subviews)
// After: single NSSplitView per split node, N subviews

let split = NSSplitView()
split.isVertical = (direction == .horizontal)
for child in children {
    let container = NSView()
    build(node: child, into: container)  // recursive for nested directions
    split.addSubview(container)
}
split.adjustSubviews()  // equal sizing
```

### Incremental Update (no full rebuild)

```swift
// Instead of removeFromSuperview + rebuild:
// 1. Diff old tree vs new tree
// 2. For added leaves: create host, addSubview to existing NSSplitView
// 3. For removed leaves: just removeFromSuperview that one host
// 4. call adjustSubviews() to redistribute
// → existing Metal surfaces never get removed
```

## Steps

1. Add `PaneNode.split(direction:children:ratios:)` case alongside existing `.branch` (backward compat)
2. Update `SessionEditor.splitPane` to append child to existing split node (same direction) instead of nesting
3. Update `PaneContainerView.build` to create single NSSplitView with N subviews
4. Implement incremental diff: detect added/removed leaves, mutate existing NSSplitView in-place
5. Migrate daemon IPC to emit new node format
6. Update persistence/decode (backward compat with old binary tree snapshots)
7. Remove `.branch` case once fully migrated

## Risk

- Breaking change to snapshot JSON format (needs migration path)
- 40+ test cases reference binary tree structure
- Daemon must understand new format

## Estimate

3–4 sessions
