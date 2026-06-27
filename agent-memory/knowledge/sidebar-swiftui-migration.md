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

## Sidebar Chrome — Full SwiftUI (v3.9.5)

Entire sidebar chrome migrated: workspace pill, tab bar, section label, footer — all via `@Observable` model + `NSHostingView`. Deleted `HarnessControls.swift` (−998 lines).

### chromeEpoch — force SwiftUI re-render from static state

`HarnessDesign.sidebarBackground` is a static var (not `@Observable`). To propagate chrome changes into SwiftUI bodies, models carry `var chromeEpoch: Int = 0`. Increment in `applyChromeColors()`. Consume in body with `let _ = model.chromeEpoch`.

```swift
var body: some View {
    let _ = model.chromeEpoch  // subscribe to chrome changes
    ...
}
// In applyChromeColors():
model.chromeEpoch += 1
```

### Picker as NSSegmentedControl replacement

`Picker(.segmented)` is a 1:1 drop-in. Bind via `Binding(get:set:)` on `@Observable` model.

```swift
Picker("", selection: Binding(get: { model.selectedTab }, set: { model.selectedTab = $0; onTabChange($0) })) {
    Text("Sessions").tag(0); Text("Files").tag(1); Text("Git").tag(2)
}
.pickerStyle(.segmented).labelsHidden()
```

### Open With Harness — file routing

`ExternalOpenKind` classifies URLs → `.filePreview` for regular source/text files.
Chain: `AppDelegate` → `performExternalOpen` → `openFilePreview` → `MainSplitViewController.previewExternalFile` → `HarnessSidebarPanelViewController.openExternalFile`.
`openExternalFile` calls `selectFilesTab(revealPath:)` (expand tree, no viewer) + creates/selects session at git root.

### File tree: root at git root, expand on CWD change

Re-rooting on every `cd` collapses the tree. Instead root at git root and expand+scroll to CWD.

```swift
private static func gitRoot(for path: String) -> String? {
    var dir = (path as NSString).deletingLastPathComponent
    while dir != "/" {
        if FileManager.default.fileExists(atPath: dir + "/.git") { return dir }
        let parent = (dir as NSString).deletingLastPathComponent
        if parent == dir { break }
        dir = parent
    }
    return nil
}
// In update:
let root = Self.gitRoot(for: cwd) ?? cwd
fileTreeView.updateRoot(path: root, sessionID: activeSessionID)
if cwd != lastFileTreeCWD { fileTreeView.revealFileInTree(path: cwd); lastFileTreeCWD = cwd }
if sessionChanged { lastFileTreeCWD = nil }
```

## Files
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarListModel.swift`
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarSessionListView.swift`
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/SidebarWorkspaceViews.swift`
- `Apps/Harness/Sources/HarnessApp/UI/Sidebar/HarnessSidebarPanelViewController.swift`
- `Apps/Harness/Sources/HarnessApp/Services/ThemeImportController.swift`
- `Apps/Harness/Sources/HarnessApp/Resources/Info.plist`
