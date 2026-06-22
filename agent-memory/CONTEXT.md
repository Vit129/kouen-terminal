# Context — harness-terminal

## Now
- **Task:** None active — ready for next session
- **Branch:** main
- **Status:** idle (Completed terminal flicker fix — presentsWithTransaction order in layout())

## Last Session (2026-06-23) — Sidebar SwiftUI Migration Complete

**Completed (all 6 phases):**
- Phase 1: `SidebarListModel.swift` — `@Observable` model with rows, git metadata, worktrees
- Phase 2: `SidebarSessionListView.swift` — SwiftUI `LazyVStack` with all 5 row types
- Phase 3: `NSHostingView` bridge in VC — replaces NSTableView scroll
- Phase 4: `reload()` / `refreshMetadata()` wired to model — no more manual `reloadData()`
- Phase 5: Native SwiftUI `.contextMenu {}` on session and group header rows
- Phase 6: All dead NSTableView code removed — VC 1676 → 890 lines (~47KB reduction)

**Result:** RL-051 class of NSTableView row-index race crashes permanently eliminated.

## Plans
- `agent-memory/plans/sidebar-swiftui-migration.md` — DONE
- `agent-memory/plans/sidebar-race-fix.md` — superseded by migration

## Open Questions
- Drag-to-reorder was removed with the NSTableView. If needed, implement with SwiftUI `.draggable` / `.dropDestination`.

## Key Files
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarListModel.swift` — observable model (new)
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarSessionListView.swift` — SwiftUI list (new)
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift` — 890 lines (was 1676)
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController+DragReorder.swift` — emptied

## Session Notes
- Build: `swift build --product Harness` — passes clean
- NSClickGestureRecognizer ALWAYS consumes mouse events — use mouseUp override (RL-043)
- `onGroupOptions` callback kept in `SidebarSessionListView` as no-op for now (⋯ button removed from header row — use right-click context menu instead)
