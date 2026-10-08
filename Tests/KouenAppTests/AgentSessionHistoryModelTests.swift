import Foundation
@testable import KouenApp
import KouenCore
import KouenIPC
import XCTest

@MainActor
final class AgentSessionHistoryModelTests: XCTestCase {
    private func makeRecord(
        id: String,
        title: String,
        projectPath: String = "/Users/test/my-repo",
        projectName: String = "my-repo",
        gitBranch: String? = "main",
        updatedAt: Date = Date(),
        firstPrompt: String = "help me fix this",
        turns: [AgentHistoryTurn] = []
    ) -> AgentSessionRecord {
        AgentSessionRecord(
            id: id,
            agentKind: .claudeCode,
            title: title,
            projectPath: projectPath,
            projectName: projectName,
            gitBranch: gitBranch,
            modelName: "claude-sonnet-4-6",
            messageCount: 5,
            updatedAt: updatedAt,
            firstPrompt: firstPrompt,
            latestTurns: turns,
            transcriptPath: "/tmp/\(id).jsonl",
            worktreeAvailable: true
        )
    }

    func testDateGrouping() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now)!

        XCTAssertEqual(AgentHistoryDateGroup.group(for: now, relativeTo: now), .today)
        XCTAssertEqual(AgentHistoryDateGroup.group(for: yesterday, relativeTo: now), .yesterday)
        XCTAssertEqual(AgentHistoryDateGroup.group(for: threeDaysAgo, relativeTo: now), .thisWeek)
        XCTAssertEqual(AgentHistoryDateGroup.group(for: twoWeeksAgo, relativeTo: now), .older)
    }

    func testSearchQueryIgnoresScopeAndWindow() {
        let calendar = Calendar.current
        let now = Date()
        let oldDate = calendar.date(byAdding: .day, value: -30, to: now)!

        let r1 = makeRecord(id: "r1", title: "Build feature A", projectPath: "/repo/one", projectName: "one", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Fix bug in older task", projectPath: "/repo/two", projectName: "two", updatedAt: oldDate)

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .repo

        // Empty query with .repo scope filters out /repo/two if active repo doesn't match
        // But when searching for "older", it matches r2 regardless of scope AND 14-day cutoff
        model.searchQuery = "older"
        XCTAssertEqual(model.filteredRecords.count, 1)
        XCTAssertEqual(model.filteredRecords.first?.id, "r2")
        XCTAssertEqual(model.windowedRecords.count, 1)
        XCTAssertEqual(model.groupedRecords.first?.title, "Best matches")
        XCTAssertEqual(model.groupedRecords.first?.records.count, 1)
    }

    func testEmptyQueryGroupsByDate() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let r1 = makeRecord(id: "r1", title: "Task 1", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Task 2", updatedAt: yesterday)

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all
        model.searchQuery = ""

        let groups = model.groupedRecords
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].title, "Today")
        XCTAssertEqual(groups[1].title, "Yesterday")
    }

    func testKeyboardSelectionMovement() {
        let r1 = makeRecord(id: "r1", title: "Task 1")
        let r2 = makeRecord(id: "r2", title: "Task 2")

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all

        XCTAssertEqual(model.selectedIndex, 0)
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, 1)
        // Clamped at bottom
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, 1)
        model.moveSelection(by: -1)
        XCTAssertEqual(model.selectedIndex, 0)
        // Clamped at top
        model.moveSelection(by: -1)
        XCTAssertEqual(model.selectedIndex, 0)
    }
}
