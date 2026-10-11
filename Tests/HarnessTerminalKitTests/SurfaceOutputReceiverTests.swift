import Foundation
import XCTest
@testable import HarnessTerminalKit

final class SurfaceOutputReceiverTests: XCTestCase {
    /// The fixture executes scheduled work manually on this test's thread.
    private final class Delivery: @unchecked Sendable {
        var jobs: [@Sendable () -> Void] = []
        var parsed: [(String, Bool)] = []
        var parsedBytes: [Data] = []
        var completions: [@Sendable () -> Void] = []
        var consumed: [Int] = []
    }

    func testBatchingPreservesReplayBoundariesAndReleasesEveryPacketAfterParsing() {
        let delivery = Delivery()
        let receiver = SurfaceOutputReceiver(schedule: { delivery.jobs.append($0) }, receive: { data, replay, consumed in
            delivery.parsed.append((String(decoding: data, as: UTF8.self), replay))
            delivery.completions.append(consumed)
        })
        for (index, packet) in [("a", false), ("b", false), ("history", true), ("c", false), ("d", false)].enumerated() {
            receiver.enqueue(Data(packet.0.utf8), replay: packet.1) { delivery.consumed.append(index) }
        }
        XCTAssertEqual(delivery.jobs.count, 1)
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.parsed.map(\.0), ["ab", "history", "cd"])
        XCTAssertEqual(delivery.parsed.map(\.1), [false, true, false])
        XCTAssertTrue(delivery.consumed.isEmpty, "budget stays reserved until the parser completes")
        for completion in delivery.completions { completion() }
        XCTAssertEqual(delivery.consumed, [0, 1, 2, 3, 4])
        XCTAssertFalse(receiver.hasPendingWork)
    }
    func testLargePacketYieldsToQueuedWorkWithoutReleasingIngressBudgetEarly() {
        let delivery = Delivery()
        let receiver = SurfaceOutputReceiver(schedule: { delivery.jobs.append($0) }, receive: { data, _, consumed in
            delivery.parsedBytes.append(data)
            delivery.completions.append(consumed)
        })
        // Include non-ASCII bytes crossing the batch boundary; splitting must be byte-exact.
        let packet = Data(String(repeating: "界👩🏽‍💻", count: 10_000).utf8)
        receiver.enqueue(packet) { delivery.consumed.append(1) }
        delivery.jobs.append { delivery.consumed.append(0) } // A queued frame/input-mode read.
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.parsedBytes.map(\.count), [64 * 1024])
        delivery.completions.removeFirst()()
        XCTAssertTrue(delivery.consumed.isEmpty)
        XCTAssertTrue(receiver.hasPendingWork)
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.consumed, [0], "other worker operations run before the next parse batch")
        while !delivery.jobs.isEmpty { delivery.jobs.removeFirst()() }
        XCTAssertEqual(delivery.parsedBytes.reduce(into: Data()) { $0.append($1) }, packet)
        XCTAssertTrue(delivery.parsedBytes.allSatisfy { $0.count <= 64 * 1024 })
        XCTAssertEqual(delivery.consumed, [0])
        for completion in delivery.completions { completion() }
        XCTAssertEqual(delivery.consumed, [0, 1], "the packet's budget is released exactly once after all bytes parse")
        XCTAssertFalse(receiver.hasPendingWork)
    }

    func testPartialPacketKeepsReplayBoundariesAndCompletionOrder() {
        let delivery = Delivery()
        let receiver = SurfaceOutputReceiver(schedule: { delivery.jobs.append($0) }, receive: { data, replay, consumed in
            delivery.parsed.append((String(decoding: data, as: UTF8.self), replay))
            consumed()
        })
        receiver.enqueue(Data(repeating: 97, count: 64 * 1024 - 1)) { delivery.consumed.append(0) }
        receiver.enqueue(Data("history".utf8), replay: true) { delivery.consumed.append(1) }
        receiver.enqueue(Data("live".utf8)) { delivery.consumed.append(2) }
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.parsed.map(\.1), [false, true])
        XCTAssertEqual(delivery.parsed.last?.0, "h")
        XCTAssertEqual(delivery.consumed, [0])
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.parsed.suffix(2).map(\.0), ["istory", "live"])
        XCTAssertEqual(delivery.parsed.suffix(2).map(\.1), [true, false])
        XCTAssertEqual(delivery.consumed, [0, 1, 2])
    }

    func testEmptyPacketFloodHasBoundedTurnsAndPreservesQueueOrder() {
        let delivery = Delivery()
        let receiver = SurfaceOutputReceiver(schedule: { delivery.jobs.append($0) }, receive: { _, _, consumed in consumed() })
        for index in 0..<4096 {
            receiver.enqueue(Data()) { delivery.consumed.append(index) }
        }
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.consumed.count, 256)
        while !delivery.jobs.isEmpty { delivery.jobs.removeFirst()() }
        XCTAssertEqual(delivery.consumed, Array(0..<4096))
        receiver.enqueue(Data("after drain".utf8)) { delivery.consumed.append(4096) }
        delivery.jobs.removeFirst()()
        XCTAssertEqual(delivery.consumed.last, 4096)
        XCTAssertFalse(receiver.hasPendingWork)
    }

    @MainActor
    func testReconnectWaitsForAdmittedParserWorkAndPublishesItsExactResumeFence() async {
        let delivery = Delivery()
        let receiver = SurfaceOutputReceiver(schedule: { delivery.jobs.append($0) }, receive: { data, replay, consumed in
            delivery.parsed.append((String(decoding: data, as: UTF8.self), replay))
            delivery.completions.append(consumed)
        })
        var resume: UInt64?
        var finished = false
        let done = expectation(description: "all admitted bytes settled before reconnect")
        let progress = AttachProgress(receiver: receiver, surfaceID: "pane") { resume = $0 }
        progress.setHistoryEnd(1)
        progress.start()
        progress.enqueue(Data("a".utf8), sequence: 1, drain: {})
        progress.drain { data, _, consumed in receiver.enqueue(data, onConsumed: consumed) }
        delivery.jobs.removeFirst()()
        progress.enqueue(Data("bc".utf8), sequence: 2, drain: {})
        progress.finish { finished = true; done.fulfill() }
        progress.enqueue(Data("not-admitted".utf8), sequence: 4, drain: {})
        await withCheckedContinuation { continuation in DispatchQueue.main.async { continuation.resume() } }
        XCTAssertFalse(finished)
        XCTAssertNil(resume, "Received bytes are not a consumed resume fence")
        delivery.completions.removeFirst()()
        await withCheckedContinuation { continuation in DispatchQueue.main.async { continuation.resume() } }
        XCTAssertFalse(finished, "The next admitted batch is still waiting on the parser")
        XCTAssertEqual(resume, 2)
        delivery.jobs.removeFirst()()
        delivery.completions.removeFirst()()
        await fulfillment(of: [done], timeout: 2)
        XCTAssertEqual(resume, 4)
        XCTAssertEqual(delivery.parsed.map(\.0), ["a", "bc"])
    }

    @MainActor
    func testAcknowledgementThresholdDoesNotOverflowAtSequenceLimit() async {
        let delivery = Delivery()
        let receiver = SurfaceOutputReceiver(schedule: { delivery.jobs.append($0) }, receive: { _, _, consumed in consumed() })
        var resume: UInt64?
        let done = expectation(description: "maximum valid sequence consumed")
        let progress = AttachProgress(receiver: receiver, surfaceID: "pane") { resume = $0 }
        progress.setHistoryEnd(UInt64.max - 2)
        progress.start()
        progress.enqueue(Data([65]), sequence: UInt64.max - 2, drain: {})
        progress.drain { data, _, consumed in receiver.enqueue(data, onConsumed: consumed) }
        delivery.jobs.removeFirst()()
        progress.enqueue(Data([66]), sequence: UInt64.max - 1, drain: {})
        delivery.jobs.removeFirst()()
        progress.finish { done.fulfill() }
        await fulfillment(of: [done], timeout: 2)
        XCTAssertEqual(resume, UInt64.max)
    }

    @MainActor
    func testDisconnectBeforeReplayConsumptionDoesNotInventAResumeFence() async {
        let receiver = SurfaceOutputReceiver(schedule: { $0() }, receive: { _, _, consumed in consumed() })
        var resume: UInt64?
        let done = expectation(description: "empty attach settled")
        let progress = AttachProgress(receiver: receiver, surfaceID: "pane") { resume = $0 }
        progress.setHistoryEnd(1 << 20)
        progress.start()
        progress.finish { done.fulfill() }
        await fulfillment(of: [done], timeout: 2)
        XCTAssertNil(resume, "An advertised replay end is not evidence that its bytes were parsed")
    }

}
