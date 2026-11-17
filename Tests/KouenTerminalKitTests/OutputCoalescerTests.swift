import XCTest
@testable import KouenTerminalKit

final class OutputCoalescerTests: XCTestCase {
    func test_TS_2288_BE_UT_DrainIsCappedAndKeepsOrder() throws {
        let c = TerminalHostView.OutputCoalescer()
        let all = Data((0 ..< 1000).map { UInt8($0 % 251) })
        var scheduled = 0
        try c.append(all) { scheduled += 1 }
        var out = Data()
        var drains = 0
        while true {
            let step = try c.drain(maxBytes: 300)
            XCTAssertLessThanOrEqual(step.data.count, 300)
            out.append(step.data)
            drains += 1
            if !step.hasMore { break }
        }
        XCTAssertEqual(out, all)
        XCTAssertEqual(drains, 4)
        try c.append(Data([1])) { scheduled += 1 }
        XCTAssertEqual(scheduled, 2, "after the last drain a new append must schedule again")
    }

    func test_TS_2289_BE_UT_OverflowSpoolsInOrderWithinMemoryWindow() throws {
        let memoryLimit = 64 * 1024
        let c = TerminalHostView.OutputCoalescer(maxMemoryBytes: memoryLimit)
        let first = Data((0 ..< 48_000).map { UInt8($0 % 251) })
        let overflow = Data((48_000 ..< 248_000).map { UInt8($0 % 251) })
        var expected = first
        expected.append(overflow)
        var scheduled = 0
        try c.append(first) { scheduled += 1 }
        try c.append(overflow) { scheduled += 1 }

        XCTAssertLessThanOrEqual(c.bufferedMemoryBytes, memoryLimit)
        XCTAssertEqual(c.bufferedSpoolBytes, overflow.count)
        XCTAssertEqual(scheduled, 1)

        var output = Data()
        while true {
            let (chunk, hasMore) = try c.drain(maxBytes: 17_000)
            XCTAssertLessThanOrEqual(chunk.count, 17_000)
            output.append(chunk)
            if !hasMore { break }
        }
        XCTAssertEqual(output, expected)
        XCTAssertEqual(c.bufferedMemoryBytes, 0)
        XCTAssertEqual(c.bufferedSpoolBytes, 0)
    }

    func test_TS_2310_BE_UT_stopReleasesQueuedOutput() throws {
        let c = TerminalHostView.OutputCoalescer(maxMemoryBytes: 8)
        try c.append(Data(repeating: 1, count: 16)) {}
        XCTAssertEqual(c.bufferedSpoolBytes, 16)
        c.stop()
        XCTAssertEqual(c.bufferedMemoryBytes, 0)
        XCTAssertEqual(c.bufferedSpoolBytes, 0)
        try c.append(Data([2])) { XCTFail("retired output must not schedule more work") }
        let drained = try c.drain()
        XCTAssertTrue(drained.data.isEmpty)
        XCTAssertFalse(drained.hasMore)
    }

    func test_TS_2323_BE_UT_spoolLimitThrowsInsteadOfDroppingOutput() throws {
        let c = TerminalHostView.OutputCoalescer(maxMemoryBytes: 4, maxSpoolBytes: 5)
        try c.append(Data([1, 2, 3, 4])) {}
        try c.append(Data([5, 6])) {}
        XCTAssertEqual(c.bufferedSpoolBytes, 2)
        XCTAssertThrowsError(try c.append(Data([7, 8, 9, 10])) {})
        XCTAssertEqual(c.bufferedSpoolBytes, 2, "failed append must preserve already buffered bytes for the overlay failure path")
    }

    func test_TS_2293_BE_UT_ContinuousDrainReleasesConsumedChunks() throws {
        let c = TerminalHostView.OutputCoalescer(maxMemoryBytes: 1024)
        try c.append(Data(repeating: 1, count: 32)) {}
        for _ in 0..<10000 {
            try c.append(Data(repeating: 2, count: 32)) {}
            let result = try c.drain(maxBytes: 32)
            XCTAssertTrue(result.hasMore)
        }
        XCTAssertLessThanOrEqual(c.retainedChunkSlots, 128)
        XCTAssertEqual(c.bufferedMemoryBytes, 32)
    }

}
