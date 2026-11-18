import Foundation

/// Discovers primary Git checkouts without following symlinks or linked worktrees.
public enum WorkspaceRepositoryScanner {
    private static let ignored: Set<String> = [
        "testing-repo", ".git", ".build", "node_modules", "DerivedData", ".gradle",
        ".idea", ".vscode", "Pods", "Carthage", "target", "dist", "build", "vendor",
        ".venv", "venv", "__pycache__"
    ]

    public static func isPrimaryRepository(_ path: String) -> Bool {
        let url = URL(fileURLWithPath: path).standardizedFileURL
        guard !url.pathComponents.contains("testing-repo"),
              let root = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey]),
              root.isDirectory == true, root.isSymbolicLink != true,
              let git = try? url.appendingPathComponent(".git").resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey]) else { return false }
        return git.isDirectory == true && git.isSymbolicLink != true
    }

    public static func scan(root: String, maxDepth: Int = 3) throws -> [String] {
        try walk(root: root, maxDepth: maxDepth).repositories
    }

    public static func watchDirectories(root: String, maxDepth: Int = 3) throws -> [String] {
        try walk(root: root, maxDepth: maxDepth).directories
    }

    private static func walk(root: String, maxDepth: Int) throws -> (repositories: [String], directories: [String]) {
        let fm = FileManager.default
        let rootURL = URL(fileURLWithPath: root).standardizedFileURL
        var result: [String] = []
        var directories: [String] = []
        func visit(_ url: URL, depth: Int) throws {
            let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            guard values.isDirectory == true, values.isSymbolicLink != true,
                  !ignored.contains(url.lastPathComponent) else { return }
            directories.append(url.path)
            if isPrimaryRepository(url.path) {
                result.append(url.path)
                return
            }
            guard depth < maxDepth else { return }
            for child in try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey]) {
                guard !child.lastPathComponent.hasPrefix("."), !ignored.contains(child.lastPathComponent) else { continue }
                // Preserve the caller's root spelling (for example /var versus /private/var).
                try visit(url.appendingPathComponent(child.lastPathComponent), depth: depth + 1)
            }
        }
        try visit(rootURL, depth: 0)
        return (result.sorted { $0.localizedStandardCompare($1) == .orderedAscending }, directories)
    }
}
