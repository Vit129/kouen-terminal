import XCTest
@testable import HarnessTerminalKit

final class TerminalHostViewTests: XCTestCase {
    @MainActor
    func testTerminalFrameUsesPhysicalHairlineAtRetinaScales() {
        XCTAssertEqual(TerminalHostView.terminalFrameLineWidth(backingScaleFactor: 1), 1)
        XCTAssertEqual(TerminalHostView.terminalFrameLineWidth(backingScaleFactor: 2), 0.5)
        XCTAssertEqual(TerminalHostView.terminalFrameLineWidth(backingScaleFactor: 3), 1.0 / 3.0)
        XCTAssertEqual(TerminalHostView.terminalFrameLineWidth(backingScaleFactor: nil), 1)
    }

    @MainActor
    func testTerminalFrameShapeMatchesQuietMacPaneChrome() {
        XCTAssertEqual(TerminalHostView.terminalFrameCornerRadius, 10)
        XCTAssertEqual(TerminalHostView.terminalFrameInset, 1)
    }
}
