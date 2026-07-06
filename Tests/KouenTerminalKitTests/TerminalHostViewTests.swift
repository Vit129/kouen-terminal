import XCTest
@testable import KouenTerminalKit

final class TerminalHostViewTests: XCTestCase {
    @MainActor
    func testTerminalOverlayIndicatorsUseQuietMacPaneRadius() {
        XCTAssertEqual(TerminalHostView.terminalOverlayCornerRadius, 10)
    }
}
