import XCTest
@testable import HarnessApp

final class AgentApprovalBarTests: XCTestCase {

    func testWaitingInputWithPromptShows() {
        XCTAssertEqual(
            AgentApprovalBar.action(for: "waiting_input", prompt: "May I delete temp files?"),
            .show("May I delete temp files?")
        )
    }

    func testWaitingInputEmptyPromptIsNoop() {
        XCTAssertEqual(AgentApprovalBar.action(for: "waiting_input", prompt: ""), .noop)
        XCTAssertEqual(AgentApprovalBar.action(for: "waiting_input", prompt: nil), .noop)
    }

    func testIdleHides() {
        XCTAssertEqual(AgentApprovalBar.action(for: "idle", prompt: nil), .hide)
    }

    func testErroredHides() {
        XCTAssertEqual(AgentApprovalBar.action(for: "errored", prompt: nil), .hide)
    }

    /// Regression: concurrent OSC 26 Notification hooks emit "working" while a PermissionRequest
    /// bar is visible. The bar must survive — "working" must never dismiss it.
    func testWorkingIsNoop() {
        XCTAssertEqual(AgentApprovalBar.action(for: "working", prompt: nil), .noop)
        XCTAssertEqual(AgentApprovalBar.action(for: "working", prompt: "ignored"), .noop)
    }

    func testUnknownActivityIsNoop() {
        XCTAssertEqual(AgentApprovalBar.action(for: "unknown_future_state", prompt: nil), .noop)
    }
}
