# Drag and Drop

## Generation 1: NSItemProvider (macOS 11+)

```swift
// Source
Label(node.name, systemImage: "doc")
    .onDrag {
        NSItemProvider(contentsOf: node.url) ?? NSItemProvider()
    }

// Destination
VStack { }
    .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
        for provider in providers {
            provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url else { return }
                DispatchQueue.main.async { handleDrop(url: url) }
            }
        }
        return true
    }
```

**macOS quirks:**
- `.onDrag` can conflict with tap gesture on the same view — workaround: apply `.onDrag` to a dedicated drag handle or outer container
- NSItemProvider callbacks fire on background thread — always dispatch UI updates to `DispatchQueue.main`
- Drag previews on macOS can be invisible/corrupt — known SwiftUI bug; no pure-SwiftUI fix

## Generation 2: Transferable (macOS 13+) — prefer for in-app

```swift
// Step 1: Conform to Transferable
extension UTType {
    static let fileNode = UTType(exportedAs: "com.example.filenode")
}

extension FileNode: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .fileNode)
        ProxyRepresentation(exporting: \.url)   // fallback for cross-app
    }
}

// Step 2: Use .draggable / .dropDestination
List(nodes, children: \.children) { node in
    Label(node.name, systemImage: "doc")
        .draggable(node)
}

DropZone()
    .dropDestination(for: FileNode.self) { items, _ in
        handleDrop(items); return true
    } isTargeted: { highlighted = $0 }

// Drop URLs from Finder (URL already Transferable)
TerminalView()
    .dropDestination(for: URL.self) { urls, _ in
        urls.forEach { pastePathToTerminal($0) }; return true
    }
```

**TransferRepresentation types:**

| Type | Use When |
|---|---|
| `CodableRepresentation` | Custom `Codable` types within app |
| `ProxyRepresentation` | Delegate to another Transferable (URL, String) |
| `DataRepresentation` | Manual byte-level encoding |
| `FileRepresentation` | Large files — avoid loading into memory |

**Known bug:** `FileRepresentation`-only conformance silently fails on macOS drop. Always include `CodableRepresentation` or `DataRepresentation` as fallback.

## UTType Reference

```swift
UTType.fileURL    UTType.url       UTType.plainText
UTType.json       UTType.image     UTType.png
UTType.jpeg       UTType.pdf       UTType.folder
```
