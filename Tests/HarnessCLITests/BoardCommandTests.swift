import XCTest
@testable import HarnessCLI
import HarnessCore

/// P16 PBI-BOARD-003: `harness board` renders `BoardModel.classify(...)` as a
/// plain-text table grouped by column.
final class BoardCommandTests: XCTestCase {
    func testRenderBoardShowsAllColumnsWithCounts() {
        let tab = Tab(title: "build", cwd: "/tmp/project", gitBranch: "main", currentCommand: "npm")
        let session = SessionGroup(id: UUID(), name: "s", tabs: [tab], activeTabID: tab.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "W", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        let output = HarnessCLI.renderBoard(BoardModel.classify(snapshot: snap))

        XCTAssertTrue(output.contains("== Needs Attention (0) =="))
        XCTAssertTrue(output.contains("== Running (1) =="))
        XCTAssertTrue(output.contains("== Idle (0) =="))
        XCTAssertTrue(output.contains("== Done (0) =="))
        XCTAssertTrue(output.contains("== Error (0) =="))
        XCTAssertTrue(output.contains("build"))
        XCTAssertTrue(output.contains("/tmp/project"))
        XCTAssertTrue(output.contains("⎇ main"))
        XCTAssertTrue(output.contains("$ npm"))
    }

    func testRenderBoardShowsPlaceholderForEmptyColumns() {
        let output = HarnessCLI.renderBoard(BoardModel.classify(snapshot: SessionSnapshot()))
        // Default snapshot has exactly one idle tab; every other column is empty.
        XCTAssertTrue(output.contains("== Idle (1) =="))
        XCTAssertTrue(output.contains("== Running (0) =="))
        XCTAssertTrue(output.contains("(none)"))
    }
}
