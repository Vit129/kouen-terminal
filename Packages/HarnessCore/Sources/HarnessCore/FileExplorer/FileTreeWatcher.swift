import Foundation

public actor FileTreeWatcher {
    private static let excludedDirectoryNames: Set<String> = [
        ".git",
        "node_modules",
        ".build",
        "DerivedData",
    ]
    private static let maxNodeCount = 10_000

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Scan `rootPath` and optionally merge a pre-fetched git status map.
    ///
    /// - Parameters:
    ///   - rootPath: Directory to scan.
    ///   - gitStatus: Optional map of relative path → `GitStatusType` from
    ///     `GitStatusProvider.status(rootPath:)`. Pass `nil` (default) to skip
    ///     git colouring (e.g. when expanding a child directory).
    public func scan(rootPath: String, gitStatus: [String: GitStatusType]? = nil) async throws -> [FileNode] {
        let nodes = try scanDirectory(atPath: rootPath)
        guard let gitStatus, !gitStatus.isEmpty else { return nodes }
        return applyGitStatus(gitStatus, rootPath: rootPath, to: nodes)
    }

    public func expand(node: FileNode, gitStatus: [String: GitStatusType]? = nil) async throws -> [FileNode] {
        guard node.isDirectory else { return [] }
        let nodes = try scanDirectory(atPath: node.path)
        guard let gitStatus, !gitStatus.isEmpty else { return nodes }
        return applyGitStatus(gitStatus, rootPath: node.path, to: nodes)
    }

    // MARK: - FSEvents live watcher (F1-G)

    /// Opaque box that holds a `DispatchSourceFileSystemObject` without
    /// requiring it to be `Sendable`. The actor serialises all access.
    private final class SourceBox {
        let source: DispatchSourceFileSystemObject
        let fd: Int32
        init(source: DispatchSourceFileSystemObject, fd: Int32) {
            self.source = source
            self.fd = fd
        }
    }

    // nonisolated(unsafe) is safe here: SourceBox is only ever touched from
    // within the actor's executor (startWatching / stopWatching).
    private nonisolated(unsafe) var watchBoxes: [SourceBox] = []
    private nonisolated(unsafe) var debounceItem: DispatchWorkItem?

    /// Start watching `rootPath` for filesystem changes (branch switch, file
    /// add/delete/modify). Fires `onChange` on the **main actor** after a
    /// 500 ms debounce so rapid git operations coalesce into one refresh.
    ///
    /// We watch the `.git` directory instead of the project root because:
    /// - `HEAD` changes on every `git checkout` / `git commit`
    /// - `index` changes on every `git add` / `git rm` / `git reset`
    /// - Watching root directly fires on every file save (too noisy)
    ///
    /// Falls back to watching `rootPath` itself for non-git directories.
    public func startWatching(rootPath: String, onChange: @MainActor @escaping () -> Void) {
        stopWatching()

        var pathsToWatch = [rootPath]
        let gitDir = rootPath + "/.git"
        if fileManager.fileExists(atPath: gitDir) {
            pathsToWatch.append(gitDir)
        }

        for watchPath in pathsToWatch {
            let fd = open(watchPath, O_EVTONLY)
            guard fd >= 0 else { continue }

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: [.write, .rename, .delete, .extend],
                queue: DispatchQueue.global(qos: .utility)
            )

            let box = SourceBox(source: source, fd: fd)
            watchBoxes.append(box)

            source.setEventHandler { [weak self] in
                guard let self else { return }
                // Cancel previous pending bounce and schedule a new one.
                self.debounceItem?.cancel()
                let work = DispatchWorkItem {
                    Task { @MainActor in onChange() }
                }
                self.debounceItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
            }

            source.setCancelHandler {
                close(fd)
            }

            source.resume()
        }
    }

    /// Stop the active filesystem watcher and release its file descriptor.
    public func stopWatching() {
        debounceItem?.cancel()
        debounceItem = nil
        for box in watchBoxes {
            box.source.cancel()
        }
        watchBoxes.removeAll()
    }

    // MARK: - Private

    private func applyGitStatus(
        _ gitStatus: [String: GitStatusType],
        rootPath: String,
        to nodes: [FileNode]
    ) -> [FileNode] {
        // rootPath may or may not have a trailing slash; normalise once.
        let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
        return nodes.map { node in
            let rel = node.path.hasPrefix(prefix)
                ? String(node.path.dropFirst(prefix.count))
                : node.path
            var updated = node
            updated.gitStatus = gitStatus[rel] ?? .unmodified
            return updated
        }
    }

    private func scanDirectory(atPath path: String) throws -> [FileNode] {
        let rootURL = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
        let urls = try fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: []
        )

        var nodes: [FileNode] = []
        nodes.reserveCapacity(min(urls.count, Self.maxNodeCount))
        for url in urls where nodes.count < Self.maxNodeCount {
            let name = url.lastPathComponent
            guard shouldInclude(name: name) else { continue }

            let values = try url.resourceValues(forKeys: [.isDirectoryKey])
            let isDirectory = values.isDirectory ?? false
            guard !isDirectory || !Self.excludedDirectoryNames.contains(name) else { continue }

            let path = url.standardizedFileURL.path
            nodes.append(FileNode(
                id: path,
                name: name,
                path: path,
                isDirectory: isDirectory,
                children: nil,
                gitStatus: .unmodified
            ))
        }

        return nodes.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory { return lhs.isDirectory && !rhs.isDirectory }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    private func shouldInclude(name: String) -> Bool {
        !name.isEmpty && !name.hasPrefix(".") && !Self.excludedDirectoryNames.contains(name)
    }
}
