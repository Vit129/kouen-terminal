import Foundation

/// The subscription submits ordered batches directly to the terminal worker. Completion
/// releases the caller's ingress budget only after parsing, so buffering cannot hide lag.
/// `schedule` and `receive` must preserve submission order on the terminal worker. A split
/// packet keeps its completion on the final fragment, after every preceding byte is parsed.
public final class SurfaceOutputReceiver: @unchecked Sendable {
    private struct Chunk {
        var data: Data
        let replay: Bool
        let consumed: @Sendable () -> Void
    }
    private let lock = NSLock()
    private var pending: [Chunk?] = []
    private var pendingHead = 0
    private var draining = false
    private let schedule: @Sendable (@escaping @Sendable () -> Void) -> Void
    private let receive: @Sendable (Data, Bool, @escaping @Sendable () -> Void) -> Void

    var hasPendingWork: Bool {
        lock.lock(); defer { lock.unlock() }
        return draining
    }

    init(schedule: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void,
         receive: @escaping @Sendable (Data, Bool, @escaping @Sendable () -> Void) -> Void) {
        self.schedule = schedule
        self.receive = receive
    }

    public func enqueue(_ data: Data, replay: Bool = false,
                        onConsumed: @escaping @Sendable () -> Void = {}) {
        lock.lock()
        pending.append(Chunk(data: data, replay: replay, consumed: onConsumed))
        let start = !draining
        draining = true
        lock.unlock()
        if start { schedule { self.drain() } }
    }

    private func drain() {
        lock.lock()
        var batch: [Chunk] = []
        var remainingBytes = 64 * 1024
        // Bound both parser work and per-packet bookkeeping, including empty packets.
        while pendingHead < pending.count, remainingBytes > 0, batch.count < 256 {
            var chunk = pending[pendingHead]!
            if chunk.data.count > remainingBytes {
                batch.append(Chunk(data: Data(chunk.data.prefix(remainingBytes)),
                                   replay: chunk.replay, consumed: {}))
                chunk.data = chunk.data.dropFirst(remainingBytes)
                pending[pendingHead] = chunk
                remainingBytes = 0
            } else {
                remainingBytes -= chunk.data.count
                batch.append(chunk)
                pending[pendingHead] = nil
                pendingHead += 1
            }
        }
        if pendingHead == pending.count {
            pending.removeAll(keepingCapacity: true)
            pendingHead = 0
        } else if pendingHead >= 1024, pendingHead >= pending.count / 2 {
            pending.removeFirst(pendingHead)
            pendingHead = 0
        }
        lock.unlock()
        var first = 0
        while first < batch.count {
            var end = first + 1
            while end < batch.count, batch[end].replay == batch[first].replay { end += 1 }
            if end == first + 1 {
                let chunk = batch[first]
                receive(chunk.data, chunk.replay, chunk.consumed)
            } else {
                // Tiny PTY packets become one parse and one staged UI update under load.
                // A lone echo takes the original path immediately; replay boundaries stay ordered.
                let chunks = Array(batch[first..<end])
                var data = Data()
                data.reserveCapacity(chunks.reduce(0) { $0 + $1.data.count })
                for chunk in chunks { data.append(chunk.data) }
                receive(data, batch[first].replay) {
                    for chunk in chunks { chunk.consumed() }
                }
            }
            first = end
        }
        lock.lock()
        let again = pendingHead < pending.count
        draining = again
        lock.unlock()
        // Yield to queued frame builds between batches so continuous output cannot starve echo.
        if again { schedule { self.drain() } }
    }
}
