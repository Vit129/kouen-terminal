import AppKit
import XCTest
@testable import HarnessApp

@MainActor
final class ToolSectionViewTests: XCTestCase {
    func testDisclosureTracksItsDetailsRatherThanTheMomentaryPressedState() throws {
        _ = NSApplication.shared
        let detail = NSTextField(labelWithString: "Exact review controls")
        let section = ToolSectionView("Review and session actions", views: [detail], collapsible: true)
        let button = try XCTUnwrap(section.arrangedSubviews.first as? NSButton)
        XCTAssertTrue(detail.isHidden)
        XCTAssertFalse(button.isAccessibilityExpanded())
        XCTAssertEqual(button.accessibilityRole(), .disclosureTriangle)
        // AppKit enters this state before dispatching a momentary button action.
        // Repeating the same transient state must still open, then close details.
        for expanded in [true, false] {
            button.state = .on
            XCTAssertTrue(button.sendAction(button.action, to: button.target))
            XCTAssertEqual(detail.isHidden, !expanded)
            XCTAssertEqual(button.isAccessibilityExpanded(), expanded)
            XCTAssertEqual((button.accessibilityValue() as? NSNumber)?.boolValue, expanded)
            XCTAssertEqual(button.accessibilityLabel(), (expanded ? "Hide " : "Show ") + "Review and session actions")
        }
        button.performClick(nil)
        XCTAssertFalse(detail.isHidden, "A regular native click must also expose the review controls")
        XCTAssertTrue(button.isAccessibilityExpanded())
        XCTAssertTrue(button.accessibilityPerformPress())
        XCTAssertTrue(detail.isHidden, "The accessibility press follows the same disclosure action")
        XCTAssertFalse(button.isAccessibilityExpanded())
    }
}
