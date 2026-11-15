import XCTest
@testable import KouenTerminalKit

final class OutputCoalescerTests: XCTestCase {
    func test_TC1201_BEUT_drainIsCappedAndKeepsOrder() {
        let c = TerminalHostView.OutputCoalescer()
        let all = Data((0 ..< 1000).map { UInt8($0 % 251) })
        var scheduled = 0
        c.append(all) { scheduled += 1 }
        var out = Data()
        var drains = 0
        while true {
            let step = c.drain(maxBytes: 300)
            XCTAssertLessThanOrEqual(step.data.count, 300)
            out.append(step.data)
            drains += 1
            if !step.hasMore { break }
        }
        XCTAssertEqual(out, all)
        XCTAssertEqual(drains, 4)
        c.append(Data([1])) { scheduled += 1 }
        XCTAssertEqual(scheduled, 2, "after the last drain a new append must schedule again")
    }
}
