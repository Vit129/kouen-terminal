import XCTest
@testable import KouenApp

/// [TC-0601][FE-UT] `switchEndpoint` drops the old subscription, whose `onEnd` then fires. That stale
/// end must not clear + re-create the new subscription (which re-triggered the whole cycle).
@MainActor
final class ResubscribingSlotTests: XCTestCase {
    func test_TC0601_FE_UT_staleEndAfterSwitchDoesNotResubscribe() async {
        let slot = ResubscribingSlot<Int>()
        var makes = 0
        var ends: [@Sendable () -> Void] = []
        let make: ResubscribingSlot<Int>.Maker = { onEnd in
            makes += 1
            ends.append(onEnd)
            return makes
        }

        slot.ensure(make)               // initial subscription
        slot.reset()                    // switchEndpoint: drop the old one
        slot.ensure(make)               // subscribe on the new endpoint
        XCTAssertEqual(makes, 2)

        ends[0]()                       // the old subscription's onEnd fires after being dropped
        let quiet = expectation(description: "no extra subscribe")
        quiet.isInverted = true
        Task { @MainActor in
            while true { if makes > 2 { quiet.fulfill(); return }; await Task.yield() }
        }
        await fulfillment(of: [quiet], timeout: 1)
        XCTAssertEqual(makes, 2, "stale end must not trigger another subscribe")
    }

    func test_TC0601_FE_UT_endOfCurrentSubscriptionResubscribes() async {
        let slot = ResubscribingSlot<Int>()
        var makes = 0
        var ends: [@Sendable () -> Void] = []
        let make: ResubscribingSlot<Int>.Maker = { onEnd in
            makes += 1
            ends.append(onEnd)
            return makes
        }
        slot.ensure(make)
        ends[0]()
        let resubscribed = expectation(description: "resubscribed")
        Task { @MainActor in
            while makes < 2 { await Task.yield() }
            resubscribed.fulfill()
        }
        await fulfillment(of: [resubscribed], timeout: 2)
    }
}
