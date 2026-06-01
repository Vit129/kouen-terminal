import Foundation

/// Coalesces forwarded `harness-cli attach` stdin into fewer, larger payloads
/// while preserving single-key latency and the configurable detach sequence.
///
/// The attach loop reads stdin and forwards bytes to the daemon. Sending each
/// read as its own `sendData` request makes large paste bursts request/response
/// bound. This helper accumulates forwardable bytes into a `pending` batch and
/// only emits a flush when the batch reaches `maxBatchBytes` (or when detach
/// fires); the I/O loop is responsible for flushing the tail on a short timeout
/// and before blocking/exiting via `drain()`.
///
/// The detach matcher is the same state machine the loop used inline — the
/// matched-prefix count is held across `ingest` calls so the detach sequence
/// can split across reads, a broken prefix is forwarded, and a completed
/// sequence is consumed (never forwarded). Keeping it pure makes it testable;
/// the `HarnessCLI` executable target is not unit-testable, `HarnessCore` is.
public struct AttachInputBatcher {
    /// Bytes that trigger a clean detach when observed in stdin. Empty disables
    /// detaching (everything is forwarded).
    public let detachSequence: [UInt8]
    /// Soft cap that drives flushing during a burst. A single read can exceed it
    /// (the whole read is still buffered); the next `ingest`/`drain` flushes.
    public let maxBatchBytes: Int

    /// Forwardable bytes awaiting a flush.
    private var pending = Data()
    /// Count of leading detach-sequence bytes matched so far but not yet
    /// forwarded (a partial prefix that may complete on a later byte/read).
    private var matchedPrefix = 0

    public init(detachSequence: [UInt8], maxBatchBytes: Int = 16 * 1024) {
        self.detachSequence = detachSequence
        self.maxBatchBytes = max(1, maxBatchBytes)
        pending.reserveCapacity(self.maxBatchBytes)
    }

    /// True when there are buffered, forwardable bytes. A held partial detach
    /// prefix alone does not count — it is not yet forwardable.
    public var hasPending: Bool { !pending.isEmpty }

    public struct Outcome: Equatable {
        /// Bytes to send to the daemon now, or `nil` if the batch is still under
        /// the cap and no detach occurred.
        public var flush: Data?
        /// True when the full detach sequence completed during this `ingest`.
        public var detach: Bool

        public init(flush: Data?, detach: Bool) {
            self.flush = flush
            self.detach = detach
        }
    }

    /// Feed a chunk of stdin bytes.
    ///
    /// Accumulates forwardable bytes into the pending batch, tracking a partial
    /// detach-sequence prefix across calls. Returns a flush payload only when the
    /// batch reaches `maxBatchBytes`, or when the detach sequence completes — in
    /// which case any pre-detach bytes are flushed and the detach-sequence bytes
    /// themselves are consumed (never forwarded).
    public mutating func ingest<C: Collection>(_ bytes: C) -> Outcome where C.Element == UInt8 {
        for byte in bytes {
            if !detachSequence.isEmpty, byte == detachSequence[matchedPrefix] {
                matchedPrefix += 1
                if matchedPrefix == detachSequence.count {
                    // Full match — consume the sequence and flush whatever
                    // preceded it so nothing the user typed is lost.
                    matchedPrefix = 0
                    return Outcome(flush: takePending(), detach: true)
                }
            } else {
                if matchedPrefix > 0 {
                    // Prefix broke — forward the partial so the shell sees what
                    // the user actually typed.
                    pending.append(contentsOf: detachSequence.prefix(matchedPrefix))
                    matchedPrefix = 0
                }
                if !detachSequence.isEmpty, byte == detachSequence[0] {
                    matchedPrefix = 1
                } else {
                    pending.append(byte)
                }
            }
        }
        if pending.count >= maxBatchBytes {
            return Outcome(flush: takePending(), detach: false)
        }
        return Outcome(flush: nil, detach: false)
    }

    /// Flush whatever is buffered (short flush timeout, before blocking, or
    /// exit). A held partial detach prefix is intentionally NOT flushed — it
    /// stays pending until a later byte resolves the match, so a detach split
    /// across a quiet gap still works (mirrors the prior cross-read behavior).
    public mutating func drain() -> Data? {
        takePending()
    }

    private mutating func takePending() -> Data? {
        guard !pending.isEmpty else { return nil }
        let out = pending
        pending = Data()
        pending.reserveCapacity(maxBatchBytes)
        return out
    }
}
