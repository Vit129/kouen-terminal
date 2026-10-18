import Foundation

/// Fires `onEvent` when the file at `url` is written to, extended, deleted or renamed.
/// Replaces the transcript tail's 1s poll: the agent's JSONL transcript only needs reading when
/// it actually changed. The fd is opened here and closed exactly once in the source's cancel
/// handler, so `cancel()` (or dropping the last reference) can never leak it.
///
/// `onEvent` runs on `queue`. The event flags let the caller tell an append (`.write`/`.extend`)
/// from the file going away (`.delete`/`.rename`) — after the latter this watcher is dead (it is
/// bound to the old inode) and the caller should re-resolve and build a new one.
final class TranscriptFileWatcher: @unchecked Sendable {
    /// Held only so tests can prove the descriptor is closed after `cancel()`.
    let fd: Int32
    private let source: DispatchSourceFileSystemObject

    /// nil when the file cannot be opened (missing, permission) — caller falls back to polling.
    init?(url: URL, queue: DispatchQueue, onEvent: @escaping (DispatchSource.FileSystemEvent) -> Void) {
        #if canImport(Darwin)
        let descriptor = open(url.path, O_EVTONLY) // event-only: doesn't block unmounts
        #else
        let descriptor = open(url.path, O_RDONLY)
        #endif
        guard descriptor >= 0 else { return nil }
        fd = descriptor
        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .extend, .delete, .rename],
            queue: queue
        )
        src.setEventHandler { [weak src] in
            guard let src else { return }
            onEvent(src.data)
        }
        src.setCancelHandler { close(descriptor) }
        source = src
        src.resume()
    }

    func cancel() { source.cancel() }

    deinit { source.cancel() }
}
