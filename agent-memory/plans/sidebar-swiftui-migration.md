# Plan: Sidebar SwiftUI List Migration (Option B)

> **Goal:** Replace NSTableView-based session list with SwiftUI List to permanently eliminate row-index race crashes.
> **Estimated:** 4-6 hours
> **Prerequisite:** None (standalone refactor)
> **Status:** ✅ DONE (2026-06-23)

---

## Phase 1: Create Observable Model (30 min)

### Tasks
1. Create `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarListModel.swift`
2. Define `@Observable class SidebarListModel`:
   ```swift
   @Observable @MainActor
   final class SidebarListModel {
       var rows: [SidebarSessionRow] = []
       var activeSessionID: UUID?
       var activeWorkspaceID: UUID?
       
       func update(from snapshot: SessionSnapshot) {
           // rebuild rows logic (move from rebuildSidebarRows)
       }
   }
   ```
3. Move `rebuildSidebarRows()` logic into `SidebarListModel.update()`
4. Move `cachedSidebarRows`, `lastRefreshedSessions`, `lastRefreshedActiveID` into model

### Verify
- Model compiles standalone
- `swift build` passes

---

## Phase 2: Create SwiftUI Session List View (1-2 hrs)

### Tasks
1. Create `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarSessionListView.swift`
2. SwiftUI view structure:
   ```swift
   struct SidebarSessionListView: View {
       @Bindable var model: SidebarListModel
       var onSelect: (UUID) -> Void
       var onContextMenu: (SessionGroup, NSView) -> Void
       
       var body: some View {
           List(selection: $model.activeSessionID) {
               ForEach(model.rows, id: \.id) { row in
                   switch row {
                   case .groupHeader(...): GroupHeaderRow(...)
                   case .session(let s): SessionRow(session: s, isSelected: ...)
                   case .divider: Divider()
                   }
               }
           }
       }
   }
   ```
3. Create `SessionRowView` (SwiftUI) — port from `WorktreeRowView`:
   - 2-line layout: branch (bold) + short cwd (dimmed)
   - Agent badge if active
   - Git metadata (ahead/behind/dirty)
4. Create `GroupHeaderRowView` (SwiftUI) — port from `SessionGroupHeaderRowView`:
   - Repo name + collapse chevron + session count
5. Add `SidebarSessionRow: Identifiable` conformance

### Verify
- Preview renders in Xcode
- `swift build` passes

---

## Phase 3: Host in NSHostingView (30 min)

### Tasks
1. In `HarnessSidebarPanelViewController`:
   - Create `SidebarListModel` instance
   - Create `NSHostingView(rootView: SidebarSessionListView(model: model, ...))`
   - Replace `sessionTable` (NSTableView + scroll view) with hosting view in same constraints
2. Wire `onSelect` callback → `SessionCoordinator.shared.selectSession(...)`
3. Wire `onContextMenu` → existing context menu logic

### Verify
- App launches, sidebar shows sessions
- Selecting a session switches terminal

---

## Phase 4: Wire snapshotChanged → Model (30 min)

### Tasks
1. In `refreshMetadata()` / `reload()`:
   - Replace all `rebuildSidebarRows()` + `sessionTable.reloadData()` + row iteration
   - With single call: `sidebarListModel.update(from: snapshot)`
2. SwiftUI handles diffing automatically — no manual row manipulation needed
3. Remove:
   - `cachedSidebarRows` property
   - `rebuildSidebarRows()` method
   - All `sessionTable.view(atColumn:row:...)` calls for session list
   - `sessionTable.reloadData()` calls related to session list

### Verify
- `z` / `cd` → sidebar updates without crash
- `⌘\` toggle → no crash
- Tab close → sidebar removes row smoothly

---

## Phase 5: Context Menu + Drag & Drop (1-2 hrs)

### Tasks
1. Context menu: Use `.contextMenu { }` modifier on SessionRow
   - Port items from `sessionContextMenu()` 
   - Close, rename, move to workspace, duplicate, pin
2. Drag to reorder (within group):
   - `.draggable(session.id)` + `.dropDestination(for: UUID.self)`
   - Update order in model + persist
3. Selection highlight: SwiftUI `List(selection:)` handles natively

### Verify
- Right-click → menu shows
- Drag reorder works
- Multi-select (if supported) works

---

## Phase 6: Cleanup Dead Code (30 min)

### Tasks
1. Remove from `HarnessSidebarPanelViewController`:
   - `sessionTable` (NSTableView)
   - `sessionScrollView`
   - `NSTableViewDataSource` conformance
   - `NSTableViewDelegate` conformance
   - `WorktreeRowView` (AppKit cell)
   - `SessionGroupHeaderRowView` (AppKit cell)
   - All manual row-index logic
2. Keep: file tree, git panel, workspace picker (separate sections)

### Verify
- `swift build` passes
- No dead code warnings
- File size reduced significantly (target: -30KB from 72KB)

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| SwiftUI List performance with 50+ rows | Use `LazyVStack` inside `ScrollView` if List is slow |
| Context menu not matching AppKit fidelity | Use `NSViewRepresentable` wrapper for menu if needed |
| Selection state drift | Single source of truth in `SidebarListModel.activeSessionID` |
| Keyboard navigation (↑↓) | SwiftUI List supports this natively |
| Accessibility regression | SwiftUI provides accessibility labels by default |

---

## Definition of Done
- [ ] No crash on rapid `z`/`cd`/`⌘\` (stress test: 10 rapid navigations)
- [ ] Session list renders correctly (groups, headers, dividers)
- [ ] Select session → terminal switches
- [ ] Context menu → all actions work
- [ ] Tab close → row disappears (no stale state)
- [ ] Sidebar toggle → no crash
- [ ] `swift build` passes, no warnings in new files
- [ ] HarnessSidebarPanelViewController reduced by ~30KB
