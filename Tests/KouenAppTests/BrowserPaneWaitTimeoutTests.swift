import XCTest
@testable import KouenApp

/// [TC-0701][FE-UT] `waitForLoad(timeout:)` takes the timeout from an MCP/CLI caller; converting it
/// with `UInt64(timeout * 1e9)` traps on NaN, negatives and huge values.
final class BrowserPaneWaitTimeoutTests: XCTestCase {
    func test_TC0701_FE_UT_untrustedTimeoutsNeverTrap() {
        XCTAssertEqual(BrowserPaneView.sleepNanoseconds(forTimeout: .nan), 0)
        XCTAssertEqual(BrowserPaneView.sleepNanoseconds(forTimeout: -5), 0)
        XCTAssertEqual(BrowserPaneView.sleepNanoseconds(forTimeout: -.infinity), 0)
        XCTAssertEqual(BrowserPaneView.sleepNanoseconds(forTimeout: .infinity), 120_000_000_000)
        XCTAssertEqual(BrowserPaneView.sleepNanoseconds(forTimeout: 1e30), 120_000_000_000)
        XCTAssertEqual(BrowserPaneView.sleepNanoseconds(forTimeout: 2.5), 2_500_000_000)
    }
}
