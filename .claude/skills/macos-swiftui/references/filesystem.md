# File System (Async)

```swift
// Async directory scan
func buildFileTree(at root: URL) async throws -> [FileNode] {
    try await Task.detached(priority: .utility) {
        var nodes: [FileNode] = []
        let fm = FileManager.default
        let contents = try fm.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        ).sorted { $0.lastPathComponent < $1.lastPathComponent }

        for url in contents {
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            nodes.append(FileNode(
                name: url.lastPathComponent,
                url: url,
                isDirectory: isDir,
                children: isDir ? [] : nil   // [] = expandable, load lazily
            ))
        }
        return nodes
    }.value
}

// In SwiftUI view
.task { nodes = try await buildFileTree(at: rootURL) }
.task(id: expandedNodeID) {
    guard let id = expandedNodeID else { return }
    // load children for expanded node
}
```
