# P27: Pane Drag-and-Drop Reorder

## Goal
ลาก terminal pane ไปวางตำแหน่งใหม่ — ซ้าย/ขวา/บน/ล่าง ของ pane อื่น หรือ swap ตรงกลาง

## Existing Infrastructure (ไม่ต้องแก้)

| Component | File | มีอะไร |
|-----------|------|--------|
| `SessionEditor.swapPanes()` | SessionEditor.swift:1016 | Swap leaf contents (structure unchanged) |
| `SessionEditor.joinPane()` | SessionEditor.swift:1429 | Remove source → insert as sibling of dest with direction |
| `insertSplit()` | SessionEditor.swift:1580 | Places target=first, new=second |
| `.swapPanes` IPC | IPCMessage.swift:82 | Already wired to daemon |
| `.joinPane` IPC | IPCMessage.swift:133 | Already wired to daemon |
| SurfaceRegistry handlers | SurfaceRegistry.swift:734,939 | Both IPC handlers exist |
| `reloadIfNeeded` rebuild | ContentAreaViewController.swift | Reuses host by surfaceID (RL-004 safe) |
| Tab bar drag pattern | TerminalTabBarView.swift:36-380 | Reference for drag gesture pattern |

## What Needs New Code

### Phase 1: Model — `before` parameter (SessionEditor + IPC)

`insertSplit` always puts new pane as `second` (right/bottom). Need `before: Bool`:

| Task | File | Change |
|------|------|--------|
| Add `before` param to `insertSplit` | SessionEditor.swift | `before ? (newLeaf, leaf) : (leaf, newLeaf)` in branch construction |
| Add `before` param to `joinPane` | SessionEditor.swift | Pass through to `insertSplit` |
| Add `before` to `.joinPane` IPC message | IPCMessage.swift | `case joinPane(..., before: Bool)` |
| Update daemon handler | SurfaceRegistry.swift | Pass `before` to editor |

### Phase 2: Service layer — SplitPaneCoordinator

| Task | File | Change |
|------|------|--------|
| `movePaneToDirection(src:dst:direction:before:)` | SplitPaneCoordinator.swift | Thin wrapper → `.joinPane` IPC + syncFromDaemon |
| `swapPanes(src:dst:)` | SplitPaneCoordinator.swift | Thin wrapper → `.swapPanes` IPC + syncFromDaemon |

### Phase 3: UI — Drop Zone Detection (main work)

| Task | File | Detail |
|------|------|--------|
| `PaneDragController` | NEW file | Centralized drag state machine |
| Drag handle on pane header | PaneSplitButtonsView.swift or new | ≡ grip icon — mouseDown starts drag session |
| `PaneDropZoneOverlay` | NEW file | Semi-transparent overlay showing L/R/T/B/Center zones |
| Drop zone hit test | PaneDropZoneOverlay | Mouse position → which zone → direction+before mapping |
| Drag visual (snapshot) | PaneDragController | `NSView.bitmapImageRepForCachingDisplay` of pane → drag image |
| Commit on drop | PaneDragController | Zone → call coordinator.movePaneToDirection or swapPanes |

### Phase 4: Integration & Polish

| Task | Detail |
|------|--------|
| Cancel on Escape | Dismiss overlay, restore |
| Minimum pane count guard | Don't allow drag if lone pane (joinPane already guards) |
| Animation | Brief fade on rebuild (presentsWithTransaction already handles flash) |
| Accessibility | VoiceOver announce: "Move pane left/right/up/down" |

## Drop Zone Mapping

```
┌────────────────────────────┐
│         TOP (before)       │
├──────┬──────────────┬──────┤
│      │              │      │
│ LEFT │    CENTER    │RIGHT │
│(before)│   (swap)   │(after)│
│      │              │      │
├──────┴──────────────┴──────┤
│        BOTTOM (after)      │
└────────────────────────────┘
```

| Zone | Action | IPC |
|------|--------|-----|
| Center | `swapPanes(src, dst)` | `.swapPanes` |
| Left | `joinPane(src, dst, .horizontal, before: true)` | `.joinPane` |
| Right | `joinPane(src, dst, .horizontal, before: false)` | `.joinPane` |
| Top | `joinPane(src, dst, .vertical, before: true)` | `.joinPane` |
| Bottom | `joinPane(src, dst, .vertical, before: false)` | `.joinPane` |

## Constraints

- **RL-004**: Never reparent Metal surface views — `reloadIfNeeded` already handles this via surfaceID-keyed host pool
- **RL-040/041**: Zombie views — existing 1.5s retire-hold covers this
- **CASE-003**: Black flash — `presentsWithTransaction` already in rebuild path
- **Drag activation**: Use a grip handle (not raw mouseDown) to avoid conflicting with text selection and scrollback

## Centralization Strategy

| Concern | Where |
|---------|-------|
| Drag state machine + zone calculation | `PaneDragController` (new, @MainActor) |
| Drop zone visuals | `PaneDropZoneOverlay` (new NSView) |
| Model mutation | `SplitPaneCoordinator` (existing, add 2 methods) |
| Tree restructure | `SessionEditor.joinPane` (existing, add `before` param) |
| View rebuild | `ContentAreaViewController.reloadIfNeeded` (existing, no change) |

## Effort Estimate

| Phase | Effort |
|-------|--------|
| 1. Model (before param) | 30 min |
| 2. Service wrappers | 15 min |
| 3. UI (drag controller + overlay) | 3-4 hours |
| 4. Polish | 1 hour |
| **Total** | **~5 hours** |
