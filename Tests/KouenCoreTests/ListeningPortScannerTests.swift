import XCTest
@testable import KouenCore

final class ListeningPortScannerTests: XCTestCase {
    func testParsesIPv4AndIPv6ListenAddressesGroupedByPID() {
        let text = """
        p111
        n*:3000
        p222
        n127.0.0.1:8080
        n[::1]:9229
        """
        let result = ListeningPortScanner.parseFieldOutput(text)
        XCTAssertEqual(result[111], [3000])
        XCTAssertEqual(Set(result[222] ?? []), Set([8080, 9229]))
    }

    func testEmptyOutputYieldsNoPorts() {
        XCTAssertTrue(ListeningPortScanner.parseFieldOutput("").isEmpty)
    }

    func testIgnoresLinesBeforeAnyPIDTag() {
        // Malformed/unexpected lsof output shouldn't crash or attribute ports to PID 0.
        let text = "n*:3000\np111\nn*:4000"
        let result = ListeningPortScanner.parseFieldOutput(text)
        XCTAssertEqual(result, [111: [4000]])
    }

    func testScanEmptyRootsReturnsEmpty() {
        XCTAssertTrue(ListeningPortScanner.scan(roots: [:]).isEmpty)
    }
}
