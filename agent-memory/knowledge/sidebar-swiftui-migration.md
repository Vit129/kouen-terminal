---
name: sidebar-swiftui-migration
description: Lessons from migrating NSTableView sidebar to SwiftUI List (RL-051 fix)
metadata:
  type: knowledge
---

# Sidebar SwiftUI Migration — Knowledge

> Migrated v3.9.0. NSTableView → SwiftUI List via @Observable SidebarListModel + NSHostingView.

## Architecture

- `SidebarListModel` (@Observable @MainActor) — single source of truth for rows
- `SidebarSessionListView` (SwiftUI) — ForEach over model.rows
- `NSHostingView` bridge in `HarnessSidebarPanelViewController`
- `snapshotChanged` → `model.update(from: snapshot)` → SwiftUI auto-diffs

## Critical Lessons (bugs fixed)

### 1. @MainActor + Task + Process.waitUntilExit = FREEZE (RL-052)
All async git/gh Process calls MUST use `Task.detached(priority: .utility)`.
`Task { }` inside @MainActor class inherits MainActor → waitUntilExit blocks main thread.

### 2. @Observable + mutation in body = infinite re-render loop (RL-053)
NEVER call a method that mutates @Observable state from a SwiftUI View body.
`gitMetadata()` was mutating `gitMetadataCache` → triggered re-render → called again → ∞

Fix: `@ObservationIgnored` on caches that are updated async, OR pass pre-computed values as parameters to child views.

### 3. Re-entrancy guard on rebuildRows
`rebuildRows()` can be called from multiple Task completions. Guard with `isRebuilding` flag.

### 4. Worktree display rules
- Sessions tab: only IDLE worktrees (no active session cwd matches), collapsed by default
- Main worktree: always hidden (redundant — it's the session itself)
- Active worktrees: already appear as session rows (no duplication)
- `collapsedWorktreeGroups` set tracks EXPANDED groups (inverted default)

## Patterns

```swift
// CORRECT: Process off main thread
private func fetchSomething() async -> String {
    await Task.detached(priority: .utility) {
        let p = Process(); ...; p.waitUntilExit(); return result
    }.value
}

// CORRECT: Cache excluded from observation
@ObservationIgnored private var cache: [String: Value] = [:]

// CORRECT: Pass data, don't read model in child body
SidebarRow(entry: entry, metadata: model.getMetadata(...))
// WRONG: let metadata = model.getMetadata(...) inside body
```

## Files
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarListModel.swift`
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarSessionListView.swift`
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift`
