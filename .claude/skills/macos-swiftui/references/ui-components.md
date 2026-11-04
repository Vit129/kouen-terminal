# SwiftUI macOS UI Components

## NavigationSplitView (macOS 13+)

```swift
NavigationSplitView {
    List(items, selection: $selected) { Label($0.name, systemImage: $0.icon) }
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
} detail: {
    if let selected { DetailView(item: selected) }
    else { Text("Select an item").foregroundStyle(.secondary) }
}
```

## List — Hierarchical (File Tree)

```swift
struct FileNode: Identifiable {
    let id = UUID()
    var name: String
    var url: URL
    var isDirectory: Bool
    var children: [FileNode]?   // nil = leaf, [] = empty expandable dir
}

// Auto expand/collapse — built in, no delegate needed
List(rootNodes, children: \.children, selection: $selection) { node in
    Label(node.name, systemImage: node.isDirectory ? "folder" : "doc")
        .onDrag {
            NSItemProvider(contentsOf: node.url) ?? NSItemProvider()
        }
        .contextMenu {
            Button("Copy Path") { copyPath(node) }
            Button("Reveal in Finder") { reveal(node) }
        }
        .onTapGesture(count: 2) { openFile(node) }
}
.listStyle(.sidebar)
.scrollContentBackground(.hidden)
```

**Why List > NSOutlineView for drag-source trees:**
- `.onDrag` has no event conflict with click or expand — no `action` selector needed
- `children:` auto-manages expand/collapse — no `outlineViewItemWillExpand` delegate
- No `pasteboardWriterForRow`, `setDraggingSourceOperationMask`, `registerForDraggedTypes` on source side
- Terminal drop destination (AppKit) reads pasteboard from SwiftUI drag — fully compatible

## Context Menu

```swift
Text(item.name)
    .contextMenu {
        Button("Open") { open(item) }
        Button("Rename...") { rename(item) }
        Divider()
        Button("Delete", role: .destructive) { delete(item) }
    }
```

## Toolbar

```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button(action: add) { Label("Add", systemImage: "plus") }
    }
}
```

## Keyboard Shortcuts

```swift
Button("Save") { save() }.keyboardShortcut("s", modifiers: .command)
Button("Delete") { delete() }.keyboardShortcut(.delete, modifiers: [])
```
