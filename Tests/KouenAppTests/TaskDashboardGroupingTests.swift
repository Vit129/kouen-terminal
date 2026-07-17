import XCTest
import KouenIPC
@testable import KouenApp

final class TaskDashboardGroupingTests: XCTestCase {
    private func task(cwd: String?) -> TaskSummary {
        TaskSummary(
            id: UUID(), sessionID: UUID(), title: "t", done: false,
            createdAt: Date(), updatedAt: Date(), cwd: cwd
        )
    }

    func testTasksFromTheSameRepoGroupTogetherEvenFromDifferentSubdirectories() async {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Tests/KouenAppTests
            .deletingLastPathComponent() // Tests
            .path
        let subdir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path

        let groups = await TaskDashboardBody.groupByRoot([
            task(cwd: repoRoot),
            task(cwd: subdir),
        ])

        XCTAssertEqual(groups.count, 1, "same repo from root and a subdirectory must collapse to one group")
        XCTAssertEqual(groups.values.first?.count, 2)
    }

    func testNilCwdGroupsUnderEmptyRootKey() async {
        let groups = await TaskDashboardBody.groupByRoot([task(cwd: nil), task(cwd: "")])
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[""]?.count, 2)
    }
}
