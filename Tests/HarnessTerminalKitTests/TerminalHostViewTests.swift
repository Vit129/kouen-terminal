import XCTest
@testable import HarnessTerminalKit

final class TerminalHostViewTests: XCTestCase {
    @MainActor
    func testTerminalOverlayIndicatorsUseQuietMacPaneRadius() {
        XCTAssertEqual(TerminalHostView.terminalOverlayCornerRadius, 10)
    }
}
