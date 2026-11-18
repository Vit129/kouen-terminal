import Foundation
import KouenCore

/// Watches category roots and immediate child Git metadata without recursive traversal.
@MainActor
final class ProjectGroupWatcher {
    @MainActor
    private final class StreamBox {
        let rootPath: String
        private var sources: [String: DispatchSourceFileSystemObject] = [:]
        private var refreshTask: Task<Void, Never>?

        init(rootPath: String) { self.rootPath = rootPath }

        func start(onEvent: @escaping @MainActor () -> Void) {
            watch(rootPath, root: true, onEvent: onEvent)
            for path in ProjectGroupWatcher.shallowWatchPaths(rootPath: rootPath).dropFirst() {
                watch(path, root: false, onEvent: onEvent)
            }
            refreshGitWatches(onEvent: onEvent)
        }

        func refreshGitWatches(onEvent: @escaping @MainActor () -> Void) {
            refreshTask?.cancel()
            let path = rootPath
            refreshTask = Task { [weak self] in
                let paths = await Task.detached(priority: .utility) {
                    ProjectGroupWatcher.discoveryWatchPaths(rootPath: path)
                }.value
                guard !Task.isCancelled, let self else { return }
                let desired = Set(paths)
                let stale = self.sources.keys.filter { $0 != self.rootPath && !desired.contains($0) }
                for path in stale { self.sources.removeValue(forKey: path)?.cancel() }
                for path in desired where self.sources[path] == nil {
                    self.watch(path, root: false, onEvent: onEvent)
                }
                // Cover filesystem changes that occurred while watches were being installed.
                onEvent()
            }
        }

        private func watch(_ path: String, root: Bool, onEvent: @escaping @MainActor () -> Void) {
            let fd = open(path, O_EVTONLY)
            guard fd >= 0 else { return }
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: [.write, .delete, .rename, .extend, .attrib],
                queue: .main)
            source.setEventHandler { [weak self] in
                self?.refreshGitWatches(onEvent: onEvent)
                onEvent()
            }
            source.setCancelHandler { close(fd) }
            source.resume()
            sources[path] = source
        }

        func stop() {
            refreshTask?.cancel()
            sources.values.forEach { $0.cancel() }
            sources.removeAll()
        }

        deinit { sources.values.forEach { $0.cancel() } }
    }

    private var streams: [String: StreamBox] = [:] // categoryID -> root watcher
    private var debounceTasks: [String: Task<Void, Never>] = [:]

    /// Root plus immediate child directories only; child watches detect `.git` entry changes.
    static func shallowWatchPaths(rootPath: String) -> [String] {
        guard let children = try? FileManager.default.contentsOfDirectory(
            at: URL(fileURLWithPath: rootPath), includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return [rootPath]
        }
        let childPaths = children.compactMap { child -> String? in
            guard (try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else { return nil }
            return child.path
        }
        return [rootPath] + childPaths
    }

    nonisolated static func discoveryWatchPaths(rootPath: String) -> [String] {
        (try? WorkspaceRepositoryScanner.watchDirectories(root: rootPath)) ?? [rootPath]
    }

    func update(folders: [(id: String, folder: String)], onChange: @MainActor @escaping (String) -> Void) {
        let desiredIDs = Set(folders.map(\.id))
        for (id, stream) in streams where !desiredIDs.contains(id) {
            stream.stop()
            streams.removeValue(forKey: id)
            debounceTasks[id]?.cancel()
            debounceTasks.removeValue(forKey: id)
        }

        for item in folders {
            if let existing = streams[item.id], Self.shouldReplaceStream(existingRootPath: existing.rootPath, newRootPath: item.folder) {
                existing.stop()
                streams.removeValue(forKey: item.id)
            }
            if streams[item.id] == nil {
                startStream(categoryID: item.id, rootPath: item.folder, onChange: onChange)
            }
        }
    }

    static func shouldReplaceStream(existingRootPath: String, newRootPath: String) -> Bool {
        existingRootPath != newRootPath
    }

    private func startStream(categoryID: String, rootPath: String, onChange: @MainActor @escaping (String) -> Void) {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: rootPath, isDirectory: &isDir), isDir.boolValue else { return }
        let box = StreamBox(rootPath: rootPath)
        box.start { [weak self] in
            guard let self else { return }
            self.debounceTasks[categoryID]?.cancel()
            self.debounceTasks[categoryID] = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                onChange(categoryID)
            }
        }
        streams[categoryID] = box
    }

    func stopAll() {
        streams.values.forEach { $0.stop() }
        streams.removeAll()
        debounceTasks.values.forEach { $0.cancel() }
        debounceTasks.removeAll()
    }
}
