# Embedding: AppKit ↔ SwiftUI

## NSHostingView — SwiftUI inside AppKit

```swift
// In NSViewController / NSView
let swiftUIView = FileTreeView(rootPath: path)
let hostingView = NSHostingView(rootView: swiftUIView)
hostingView.translatesAutoresizingMaskIntoConstraints = false
parentView.addSubview(hostingView)
NSLayoutConstraint.activate([
    hostingView.topAnchor.constraint(equalTo: parentView.topAnchor),
    hostingView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
    hostingView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
    hostingView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
])

// Update SwiftUI content
hostingView.rootView = FileTreeView(rootPath: newPath)
```

## NSViewRepresentable — AppKit inside SwiftUI

```swift
struct TerminalSurfaceView: NSViewRepresentable {
    var onDrop: (URL) -> Void

    func makeNSView(context: Context) -> TerminalSurfaceView {
        let view = TerminalSurfaceView()
        view.onFileDrop = context.coordinator.handleDrop
        return view
    }

    func updateNSView(_ nsView: TerminalSurfaceView, context: Context) {
        nsView.onFileDrop = context.coordinator.handleDrop
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        var parent: TerminalSurfaceView
        init(_ parent: TerminalSurfaceView) { self.parent = parent }
        func handleDrop(_ url: URL) { parent.onDrop(url) }
    }
}
```

**Rules:**
- `makeNSView` — create and configure once
- `updateNSView` — sync SwiftUI state → AppKit; guard before setting to avoid loops
- `makeCoordinator()` called before `makeNSView` — coordinator outlives view recreation
- Teardown: `static func dismantleNSView(_ nsView:, coordinator:)`

## Bridging Actions: SwiftUI → AppKit Host

```swift
struct FileTreeView: View {
    var onDoubleClick: (FileNode) -> Void
    var onContextAction: (FileNode, ContextAction) -> Void

    var body: some View {
        List(nodes, children: \.children) { node in
            Label(node.name, systemImage: node.isDirectory ? "folder" : "doc")
                .onTapGesture(count: 2) { onDoubleClick(node) }
                .contextMenu { /* calls onContextAction */ }
        }
    }
}

// In AppKit host
let view = FileTreeView(
    onDoubleClick: { node in coordinator.openFile(node.url) },
    onContextAction: { node, action in coordinator.handle(action, for: node) }
)
hostingView.rootView = view
```
