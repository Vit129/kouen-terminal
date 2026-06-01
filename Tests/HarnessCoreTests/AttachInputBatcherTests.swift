import XCTest
@testable import HarnessCore

final class AttachInputBatcherTests: XCTestCase {
    // Default detach sequence: Ctrl-A 'd'.
    private let detach: [UInt8] = [0x01, 0x64]

    func testNormalBytesForwarded() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        let out = batcher.ingest([0x61, 0x62, 0x63]) // "abc"
        XCTAssertNil(out.flush, "under the cap, nothing flushes yet")
        XCTAssertFalse(out.detach)
        XCTAssertEqual(batcher.drain(), Data([0x61, 0x62, 0x63]))
    }

    func testDetachSequenceConsumed() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        let out = batcher.ingest([0x01, 0x64]) // Ctrl-A d
        XCTAssertTrue(out.detach)
        XCTAssertNil(out.flush, "no bytes preceded the detach sequence")
        XCTAssertNil(batcher.drain(), "the detach sequence itself is never forwarded")
    }

    func testDetachFlushesPrecedingBytes() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        let out = batcher.ingest([0x61, 0x01, 0x64]) // "a" then Ctrl-A d
        XCTAssertTrue(out.detach)
        XCTAssertEqual(out.flush, Data([0x61]), "bytes before detach are flushed")
        XCTAssertNil(batcher.drain())
    }

    func testPartialDetachPrefixThenNormalByteSingleIngest() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        let out = batcher.ingest([0x01, 0x78]) // Ctrl-A x — not the detach key
        XCTAssertFalse(out.detach)
        XCTAssertNil(out.flush)
        XCTAssertEqual(batcher.drain(), Data([0x01, 0x78]), "broken prefix is forwarded verbatim")
    }

    func testPartialDetachPrefixThenNormalByteSplitAcrossIngests() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        let first = batcher.ingest([0x01]) // prefix held
        XCTAssertFalse(first.detach)
        XCTAssertNil(first.flush)
        XCTAssertNil(batcher.drain(), "a held partial prefix is not flushed on its own")

        let second = batcher.ingest([0x78]) // 'x' breaks the prefix
        XCTAssertFalse(second.detach)
        XCTAssertEqual(batcher.drain(), Data([0x01, 0x78]), "prefix + byte forwarded together")
    }

    func testDetachSequenceSplitAcrossIngestsStillDetaches() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        XCTAssertFalse(batcher.ingest([0x01]).detach)
        let out = batcher.ingest([0x64])
        XCTAssertTrue(out.detach)
        XCTAssertNil(out.flush)
        XCTAssertNil(batcher.drain())
    }

    func testLargeInputBecomesFewerBatches() {
        var batcher = AttachInputBatcher(detachSequence: detach, maxBatchBytes: 16 * 1024)
        let chunk = [UInt8](repeating: 0x41, count: 4096) // 'A' — never the detach prefix
        let reads = 25 // 100 KB total
        var flushes = 0
        var total = 0
        for _ in 0..<reads {
            let out = batcher.ingest(chunk)
            if let flushed = out.flush {
                flushes += 1
                total += flushed.count
            }
        }
        if let tail = batcher.drain() {
            flushes += 1
            total += tail.count
        }
        XCTAssertEqual(total, reads * 4096, "every byte is forwarded exactly once")
        XCTAssertLessThan(flushes, reads, "batching produces far fewer sends than one per read")
        // 100 KB / 16 KB ≈ 7 batches.
        XCTAssertLessThanOrEqual(flushes, 8)
    }

    func testFlushOnExit() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        let out = batcher.ingest([0x68, 0x69]) // "hi" — under the cap
        XCTAssertNil(out.flush)
        XCTAssertEqual(batcher.drain(), Data([0x68, 0x69]), "buffered bytes flush on exit")
        XCTAssertNil(batcher.drain(), "drain is idempotent once empty")
    }

    func testEmptyDetachSequenceForwardsEverything() {
        var batcher = AttachInputBatcher(detachSequence: [])
        let out = batcher.ingest([0x01, 0x64, 0x01]) // would-be detach bytes
        XCTAssertFalse(out.detach, "an empty detach sequence never detaches")
        XCTAssertNil(out.flush)
        XCTAssertEqual(batcher.drain(), Data([0x01, 0x64, 0x01]))
    }

    func testHasPendingReflectsBufferedBytesNotHeldPrefix() {
        var batcher = AttachInputBatcher(detachSequence: detach)
        XCTAssertFalse(batcher.hasPending)
        _ = batcher.ingest([0x01]) // held prefix only, nothing forwardable yet
        XCTAssertFalse(batcher.hasPending, "a held partial prefix is not pending output")
        _ = batcher.ingest([0x62]) // 'b' breaks prefix -> [0x01, 0x62] buffered
        XCTAssertTrue(batcher.hasPending)
        _ = batcher.drain()
        XCTAssertFalse(batcher.hasPending)
    }
}
