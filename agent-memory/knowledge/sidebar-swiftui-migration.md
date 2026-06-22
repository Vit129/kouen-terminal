---
name: sidebar-swiftui-migration
description: Lessons from migrating NSTableView sidebar to SwiftUI List (RL-051 fix)
metadata:
  type: knowledge
---

# Sidebar NSTableView → SwiftUI Migration (Option B)

## Problem Solved
**RL-051**: NSTableView row-index crashes when `z`/`cd`/`⌘\` rapidly navigated. Root cause: `view(atColumn:row:)` called with stale row count after sessions changed.

**Solution**: SwiftUI's diffing automatically handles row identity and ordering — no manual row manipulation.

## Core Pattern

### 1. Observable Model
Move all row state into `@Observable @MainActor` class:
```swift
@Observable @MainActor
final class SidebarListModel {
    var rows: [SidebarSessionRow] = []
    private(set) var sessions: [SessionGroup] = []
    var collapsedGroups = Set<String>()
    // Caches for git metadata, worktrees, repo roots (tracked by @Observable)
    private var gitMetadataCache: [...] = [:]
    
    func update(from snapshot: SessionSnapshot) {
        sessions = ...
        rebuildRows()  // Called whenever sessions or collapse state changes
    }
}
```

**Why**: `@Observable` tracking on cache properties automatically triggers SwiftUI re-renders when git metadata arrives async — no manual `rebuildRows()` needed.

### 2. SwiftUI View + NSHostingView Bridge
```swift
struct SidebarSessionListView: View {
    var model: SidebarListModel  // Not @Bindable — model is mutable via callbacks
    var onSelect: (SessionID) -> Void
    // ... other callbacks
    
    var body: some View {
        ScrollView { LazyVStack { ForEach(model.rows) { rowContent($0) } } }
    }
}

// In VC:
let hosting = NSHostingView(rootView: SidebarSessionListView(model: sidebarListModel, ...))
view.addSubview(hosting)
```

**Why**: SwiftUI List can be slow with 50+ rows; `LazyVStack + ScrollView` gives better control.

### 3. Row Types with Collision-Safe IDs
```swift
enum SidebarSessionRow: Identifiable {
    case groupHeader(name: String, rootPath: String, count: Int, isCollapsed: Bool, status: BoardColumnKind)
    case session(SessionGroup)
    case worktreeHeader(rootPath: String, count: Int, isCollapsed: Bool)
    case worktree(SidebarWorktreeEntry, rootPath: String)
    case divider
    
    var id: String {
        switch self {
        case let .groupHeader(_, rootPath, _, _, _): "group-\(rootPath)"  // ← prefix
        case let .session(s): "sess-\(s.id.uuidString)"
        case let .worktreeHeader(rootPath, _, _): "wth-\(rootPath)"
        case let .worktree(entry, _): "wt-\(entry.path)"
        case .divider: "divider"
        }
    }
}
```

**Why**: Prefixes prevent collisions when the same rootPath appears in both groups and worktree headers.

### 4. Native SwiftUI Context Menus
```swift
private struct SidebarSessionItemRow: View {
    let session: SessionGroup
    var model: SidebarListModel
    
    var body: some View {
        ZStack { /* row content */ }
            .contextMenu {
                Button("Rename session…") { renameSession(...) }
                Button("Split session right") { ... }
                Button("Close session", role: .destructive) { ... }
            }
    }
}
```

**Why**: Avoids NSViewRepresentable + NSMenu hit-testing issues. Direct `SessionCoordinator.shared` calls work fine.

### 5. Type Collision Handling
When importing `SwiftUI` in AppKit code:
```swift
// ❌ Ambiguous after import SwiftUI
private func columnKind(for tab: Tab) -> BoardColumnKind

// ✅ Always qualify in method signatures
private func columnKind(for tab: HarnessCore.Tab) -> BoardColumnKind
```

**Why**: `SwiftUI.Tab` (macOS 18+ tab view type) collides with `HarnessCore.Tab`. Qualification in the signature avoids shadow warnings.

## Why RL-051 is Eliminated

| NSTableView | SwiftUI |
|---|---|
| Manual row indices: `view(atColumn:0, row:42, ...)` | Row identity via `Identifiable.id` |
| Stale row counts → crash | Diffing tracks identity automatically |
| `reloadData()` + iterate rows → O(n) manual updates | Re-render entire view tree (fast for <100 rows) |
| Selection state scattered (NSTableView + VC properties) | Single source: `model.activeSessionID` |

SwiftUI's diffing is O(n) but deterministic: same ID = same row. No stale indices.

## Reusable Checklist

- [ ] Move row state to `@Observable @MainActor` model
- [ ] Implement `func update(from snapshot) { ... rebuildRows() }`
- [ ] Define `enum Row: Identifiable` with prefixed IDs
- [ ] Create SwiftUI view with callbacks (don't use `@Bindable`)
- [ ] Bridge with `NSHostingView` using same layout constraints as old scroll view
- [ ] Implement `.contextMenu {}` on row views (no NSViewRepresentable)
- [ ] Remove NSTableViewDataSource/Delegate conformance and dead helpers
- [ ] Qualify all `Tab` references as `HarnessCore.Tab` in method signatures
- [ ] Test rapid navigation (z/cd/⌘\) without crashes
- [ ] Verify build size reduction (~47KB for Harness sidebar VC)
