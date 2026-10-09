import Foundation
import CoreServices

/// FSEvents watcher monitoring top-level additions/removals in category `sourceFolder`s.
/// Adheres to P53: depth-1 filtering prevents event storms inside nested git repos;
/// uses a dedicated serial queue with safe teardown (RL-075 pattern).
@MainActor
final class ProjectGroupWatcher {
    private final class StreamBox {
        private var streamRef: FSEventStreamRef?
        private var contextPointer: UnsafeMutableRawPointer?
        let queue: DispatchQueue

        init(streamRef: FSEventStreamRef, contextPointer: UnsafeMutableRawPointer, queue: DispatchQueue) {
            self.streamRef = streamRef
            self.contextPointer = contextPointer
            self.queue = queue
        }

        func stop() {
            guard let streamRef else { return }
            FSEventStreamStop(streamRef)
            FSEventStreamInvalidate(streamRef)
            FSEventStreamRelease(streamRef)
            self.streamRef = nil

            if let contextPointer {
                self.contextPointer = nil
                let bitPattern = UInt(bitPattern: contextPointer)
                queue.async {
                    let ptr = UnsafeMutableRawPointer(bitPattern: bitPattern)!
                    Unmanaged<WatcherContext>.fromOpaque(ptr).release()
                }
            }
        }

        deinit {
            stop()
        }
    }

    private final class WatcherContext {
        let rootPath: String
        let categoryID: String
        let onTrigger: @MainActor (String) -> Void

        init(rootPath: String, categoryID: String, onTrigger: @MainActor @escaping (String) -> Void) {
            self.rootPath = rootPath
            self.categoryID = categoryID
            self.onTrigger = onTrigger
        }
    }

    private var streams: [String: StreamBox] = [:] // categoryID -> StreamBox
    private var debounceTasks: [String: Task<Void, Never>] = [:]

    /// Determines if `eventPath` represents a depth-1 change directly under `rootPath`
    /// or the `.git` directory of a direct child (e.g. `root/child` or `root/child/.git`).
    /// Discards any deeper events (e.g. `root/child/src/...`).
    static func isDirectChild(eventPath: String, rootPath: String) -> Bool {
        guard eventPath.hasPrefix(rootPath) else { return false }
        var rel = String(eventPath.dropFirst(rootPath.count))
        while rel.hasPrefix("/") { rel.removeFirst() }
        while rel.hasSuffix("/") { rel.removeLast() }
        if rel.isEmpty { return true } // root folder itself changed
        let parts = rel.split(separator: "/")
        // parts.count == 1: direct child (e.g. "repoA" created/deleted)
        // parts.count == 2 && parts[1] == ".git": repoA/.git created
        return parts.count == 1 || (parts.count == 2 && parts[1] == ".git")
    }

    func update(folders: [(id: String, folder: String)], onChange: @MainActor @escaping (String) -> Void) {
        let desiredIDs = Set(folders.map(\.id))
        // Stop removed streams
        for (id, stream) in streams where !desiredIDs.contains(id) {
            stream.stop()
            streams.removeValue(forKey: id)
            debounceTasks[id]?.cancel()
            debounceTasks.removeValue(forKey: id)
        }

        // Start new or updated streams
        for item in folders {
            if streams[item.id] == nil {
                startStream(categoryID: item.id, rootPath: item.folder, onChange: onChange)
            }
        }
    }

    private func startStream(categoryID: String, rootPath: String, onChange: @MainActor @escaping (String) -> Void) {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: rootPath, isDirectory: &isDir), isDir.boolValue else { return }

        let contextWrapper = WatcherContext(rootPath: rootPath, categoryID: categoryID) { [weak self] catID in
            guard let self else { return }
            self.debounceTasks[catID]?.cancel()
            self.debounceTasks[catID] = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1.0s debounce
                guard !Task.isCancelled else { return }
                onChange(catID)
            }
        }

        let contextPointer = UnsafeMutableRawPointer(Unmanaged.passRetained(contextWrapper).toOpaque())
        var context = FSEventStreamContext(
            version: 0,
            info: contextPointer,
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { (streamRef, clientInfo, numEvents, eventPaths, eventFlags, eventIds) in
            guard let clientInfo else { return }
            let ctx = Unmanaged<WatcherContext>.fromOpaque(clientInfo).takeUnretainedValue()
            let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] ?? []

            var hasRelevantEvent = false
            for path in paths {
                if ProjectGroupWatcher.isDirectChild(eventPath: path, rootPath: ctx.rootPath) {
                    hasRelevantEvent = true
                    break
                }
            }

            if hasRelevantEvent {
                DispatchQueue.main.async {
                    ctx.onTrigger(ctx.categoryID)
                }
            }
        }

        let queue = DispatchQueue(label: "com.vit129.kouen.projectgroupwatcher.\(categoryID)")
        guard let stream = FSEventStreamCreate(
            nil,
            callback,
            &context,
            [rootPath] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.5,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
        ) else {
            Unmanaged<WatcherContext>.fromOpaque(contextPointer).release()
            return
        }

        let box = StreamBox(streamRef: stream, contextPointer: contextPointer, queue: queue)
        FSEventStreamSetDispatchQueue(stream, queue)
        FSEventStreamStart(stream)
        streams[categoryID] = box
    }

    func stopAll() {
        for (_, box) in streams {
            box.stop()
        }
        streams.removeAll()
        for (_, task) in debounceTasks {
            task.cancel()
        }
        debounceTasks.removeAll()
    }
}
