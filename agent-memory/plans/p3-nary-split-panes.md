# P3 — N-ary Split Panes (Fix terminal disappearing + even sizing)

Status: **in progress** — same-direction flatten done, split-down still broken  
Priority: **P0** — core UX broken  
Depends on: none  
Reference: [cmuxlayer](https://github.com/EtanHey/cmuxlayer) — MCP tool layer over CMUX socket (architecture reference for P5 ACP)

---

## Progress

✅ Same-direction flatten: binary tree chain flattened into single NSSplitView + N subviews  
✅ Equal distribution: `layout()` sets divider positions at `totalSize/N` intervals  
✅ Recursion fix: `isApplyingPositions` guard prevents layout→setPosition→layout loop  
✅ Host reuse: detach existing TerminalHostViews before rebuild, re-insert into new container  
⚠️ Split right 3+ still slightly uneven (minor — ratio math correct but timing race)  
❌ Split down (⌘⇧D) still causes terminal black (Metal CADisplayLink dies on reparent)  

## Remaining Work

1. **Split down terminal black** — `viewDidMoveToWindow` not called on same-window reparent → CADisplayLink dead
   - Fix: Override `viewDidMoveToSuperview()` in HarnessTerminalSurfaceView to restart display link
   - Alt: Incremental update — don't rebuild container, just `insertArrangedSubview` into existing NSSplitView
2. **Slight unevenness at 3+ splits** — timing race between `setPosition` and Auto Layout
   - Fix: Schedule `setPosition` in `DispatchQueue.main.async` after layout settles
3. **Mixed H+V splits** — split-down uses old binary nest (different direction path)
   - Fix: For cross-direction, nest a child NSSplitView with opposite `isVertical` inside the flat parent

## Key Insights

**Ghostty has the [same bug](https://github.com/ghostty-org/ghostty/discussions/9442):**
"SurfaceScrollView instance is not persistent, it's replaced every time the split tree is rebuilt"

**[cmuxlayer](https://github.com/EtanHey/cmuxlayer):** 33-tool MCP server over CMUX Unix socket.
Architecture reference for P5 (ACP) — shows split/surface/agent operations via JSON-RPC.
Socket (0.1ms) vs CLI (142ms) matches our daemon IPC approach.

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
