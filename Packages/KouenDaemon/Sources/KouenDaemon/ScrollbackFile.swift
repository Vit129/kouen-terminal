import Foundation
import KouenCore

/// Disk persistence for a surface's raw PTY output, so scrollback survives a daemon
/// restart or crash and a reattach replays history instead of a blank screen.
///
/// The daemon owns each shell via `forkpty`; when the daemon dies the master fd dies
/// with it and the orphaned shell can't be reacquired on restart — the new daemon
/// respawns a fresh shell per persisted surface. Without this, the replayed scrollback
/// would be empty. We mirror what the in-memory ring keeps (`RealPty`'s `scrollbackBytes`
/// cap) onto disk so the reattach after restart shows the same tail the user last saw.
///
/// Format: a flat append log of the raw output bytes — the same philosophy as the binary
/// IPC frames (no JSON/base64). A torn tail from a crash mid-write just decodes lossily,
/// exactly as the in-memory ring already tolerates (`String(decoding:as:UTF8.self)`).
///
/// Append is debounced off the PTY read hot path (the `SessionStore` pattern); the file is
/// compacted to the retention cap once it grows to a high-water mark, the disk analog of the
/// ring's head-index eviction. @unchecked Sendable: all disk state is confined to `queue`.
final class ScrollbackFile: @unchecked Sendable {
    static let minimumRetentionCap = 64 * 1024

    private let url: URL
    /// Retain roughly this many bytes on disk — sized to the surface's in-memory ring cap so
    /// "what survives a restart" matches "what was on screen".
    private let retentionCap: Int
    /// Let the log grow to 2× the cap before compacting, so compaction (a read + atomic rewrite)
    /// is amortized rather than firing on nearly every flush under a sustained output flood.
    private var highWater: Int { max(retentionCap * 2, retentionCap + 64 * 1024) }

    private let queue = DispatchQueue(label: "com.vit129.kouen.scrollback-file")
    private let debounceInterval: TimeInterval = 0.5
    /// Hard cap on the in-RAM `pending` buffer. A gapless output flood (`yes`, `cat bigfile`)
    /// re-arms the debounce faster than the 0.5s timer can ever fire, so without this `pending`
    /// would grow in proportion to total bytes produced — gigabytes for a sustained stream —
    /// and risk OOM-ing the session-authority daemon. Crossing this forces an immediate flush
    /// instead of another re-arm, bounding RAM to ~this size per surface regardless of duration.
    private let maxPendingBytes = 256 * 1024
    /// Longest the oldest buffered byte may wait before a forced flush, so a continuous trickle
    /// that never trips the size cap still reaches disk on a bounded schedule rather than being
    /// pushed indefinitely by re-arming.
    private let maxFlushDelay: TimeInterval = 2.0
    private var pending = Data()
    private var pendingFlush: DispatchWorkItem?
    /// Anchored at the first byte of the current batch; the debounce deadline is never pushed
    /// past this, giving the re-arming timer a hard ceiling (the `maxFlushDelay` max-wait).
    private var flushDeadline: DispatchTime?
    /// Set once the surface is gone for good; stops a late debounced flush from resurrecting a file
    /// we just deleted.
    private var closed = false
    /// Current on-disk size, seeded from the existing file so compaction accounting survives a
    /// restart that loaded a pre-existing log.
    private var fileBytes: Int

    init(url: URL, retentionCap: Int) {
        self.url = url
        self.retentionCap = max(retentionCap, Self.minimumRetentionCap)
        self.fileBytes = Self.compactExistingLogIfNeeded(url: url, retentionCap: self.retentionCap)
    }

    /// Read the persisted tail (at most `maxBytes`) for seeding `RealPty`'s in-memory ring on
    /// startup. Returns the most recent bytes — the oldest are what the ring would have evicted.
    static func loadTail(url: URL, maxBytes: Int) -> Data {
        readTail(url: url, maxBytes: maxBytes)
    }

    /// Seek-read at most the last `maxBytes` of the file — never the whole log.
    private static func readTail(url: URL, maxBytes: Int) -> Data {
        guard maxBytes > 0, let handle = try? FileHandle(forReadingFrom: url) else { return Data() }
        defer { try? handle.close() }
        guard let size = try? handle.seekToEnd(), size > 0 else { return Data() }
        let start = size > UInt64(maxBytes) ? size - UInt64(maxBytes) : 0
        guard (try? handle.seek(toOffset: start)) != nil else { return Data() }
        return (try? handle.readToEnd()) ?? Data()
    }

    private static func compactExistingLogIfNeeded(url: URL, retentionCap: Int) -> Int {
        let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
        guard size > retentionCap else { return size }
        return compactToTail(url: url, retentionCap: retentionCap) ?? size
    }

    /// Stream the last `retentionCap` bytes to a temp file in 4 MiB chunks, then atomic rename.
    /// Peak RAM is one chunk, not the whole retention cap.
    private static func compactToTail(url: URL, retentionCap: Int) -> Int? {
        let tmp = url.appendingPathExtension("compact-tmp")
        do {
            guard let reader = try? FileHandle(forReadingFrom: url) else { return nil }
            defer { try? reader.close() }
            let size = try reader.seekToEnd()
            guard size > UInt64(retentionCap) else { return nil }
            try reader.seek(toOffset: size - UInt64(retentionCap))
            guard FileManager.default.createFile(atPath: tmp.path, contents: nil,
                                                 attributes: [.posixPermissions: 0o600]),
                  let writer = try? FileHandle(forWritingTo: tmp)
            else { return nil }
            defer { try? writer.close() }
            let chunkSize = 4 * 1024 * 1024
            var written = 0
            while let chunk = try reader.read(upToCount: chunkSize), !chunk.isEmpty {
                try writer.write(contentsOf: chunk)
                written += chunk.count
            }
            _ = fsync(writer.fileDescriptor)
            guard rename(tmp.path, url.path) == 0 else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
            return written
        } catch {
            fputs("KouenDaemon scrollback: compaction failed for \(url.lastPathComponent): \(error)\n", kouenStderr)
            try? FileManager.default.removeItem(at: tmp)
            return nil
        }
    }

    /// Queue a chunk of output for persistence. Cheap on the caller (the PTY read loop): append
    /// to the pending buffer and (re)arm the debounce. The actual disk write happens on `queue`.
    func append(_ data: Data) {
        guard !data.isEmpty else { return }
        queue.async { [weak self] in
            guard let self, !self.closed else { return }
            self.pending.append(data)
            // Bound RAM under a sustained flood: once buffered output crosses the cap, flush
            // synchronously rather than re-arming the debounce (which a gapless stream would
            // otherwise never let fire). Normal bursts stay batched off the hot path.
            if self.pending.count >= self.maxPendingBytes {
                self.pendingFlush?.cancel()
                self.pendingFlush = nil
                self.flushPending()
            } else {
                self.scheduleFlush()
            }
        }
    }

    private func scheduleFlush() {
        pendingFlush?.cancel()
        // Anchor the max-wait ceiling at the first byte of this batch, then never schedule
        // later than it — so a continuous trickle that keeps re-arming still flushes within
        // `maxFlushDelay` instead of being deferred forever.
        let ceiling = flushDeadline ?? (.now() + maxFlushDelay)
        flushDeadline = ceiling
        let deadline = min(DispatchTime.now() + debounceInterval, ceiling)
        let work = DispatchWorkItem { [weak self] in self?.flushPending() }
        pendingFlush = work
        queue.asyncAfter(deadline: deadline, execute: work)
    }

    /// Synchronously persist any buffered output. Called on graceful shutdown so the last
    /// debounce window isn't lost when the daemon exits.
    func flush() {
        queue.sync { self.flushPending() }
    }

    /// Drop all persisted history (used by `respawn(clearHistory: true)` — the user asked to
    /// start clean). The file may be written to again afterwards.
    func reset() {
        queue.async { [weak self] in
            guard let self else { return }
            self.pendingFlush?.cancel()
            self.flushDeadline = nil
            self.pending.removeAll(keepingCapacity: true)
            try? FileManager.default.removeItem(at: self.url)
            self.fileBytes = 0
        }
    }

    /// Permanently delete the file and stop accepting writes — the surface is gone. Synchronous so
    /// the caller (surface teardown) knows no late debounced flush can resurrect the file.
    func delete() {
        queue.sync {
            self.closed = true
            self.pendingFlush?.cancel()
            self.pending.removeAll(keepingCapacity: false)
            try? FileManager.default.removeItem(at: self.url)
            self.fileBytes = 0
        }
    }

    // MARK: - queue-confined

    private func flushPending() {
        // The batch is being drained (or there's nothing to drain) — re-anchor the max-wait
        // window so the next byte starts a fresh ceiling.
        flushDeadline = nil
        guard !closed, !pending.isEmpty else { return }
        let chunk = pending
        pending.removeAll(keepingCapacity: true)
        guard appendToDisk(chunk) else { return }
        fileBytes += chunk.count
        if fileBytes > highWater { compact() }
    }

    private func appendToDisk(_ data: Data) -> Bool {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            // First write: create the (owner-only) directory + file in one shot.
            try? KouenPaths.ensureDirectories()
            return KouenPaths.atomicWrite(data, to: url, label: "KouenDaemon scrollback")
        }
        guard let handle = try? FileHandle(forWritingTo: url) else {
            // Fall back to a full rewrite if we somehow can't open for append. The rewrite
            // must include the existing log — writing just `data` would atomically replace
            // the entire history with the latest chunk. If the existing bytes can't be read
            // either, drop this flush (the chunk stays lost, but the on-disk log survives).
            guard let existing = try? Data(contentsOf: url) else {
                fputs("KouenDaemon scrollback: append-open and read both failed for \(url.lastPathComponent); dropping flush\n", kouenStderr)
                return false
            }
            return KouenPaths.atomicWrite(existing + data, to: url, label: "KouenDaemon scrollback")
        }
        defer { try? handle.close() }
        do {
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
            return true
        } catch {
            fputs("KouenDaemon scrollback: append failed for \(url.lastPathComponent): \(error)\n", kouenStderr)
            return false
        }
    }

    /// Trim the log back to the retention cap by rewriting just its tail. Atomic (temp + rename)
    /// so a crash mid-compaction leaves the previous complete log intact.
    private func compact() {
        if let newSize = Self.compactToTail(url: url, retentionCap: retentionCap) {
            fileBytes = newSize
        }
    }
}
