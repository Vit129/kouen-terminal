import XCTest
@testable import KouenCLI
import KouenCore
import KouenIPC

final class TaskCommandTests: XCTestCase {
    func testFeatureSummarySerialization() throws {
        let gate = GateSummary(gate: 1, approver: "supavit.cho", timestamp: Date(), approved: true, notes: "Design looks good")
        let taskItem = FeatureTaskSummary(id: UUID(), label: "Task 1", tags: ["core"], artifacts: ["a.swift"], done: false)
        let summary = FeatureSummary(
            id: UUID(),
            slug: "p46-test",
            repoPath: "/repo",
            phase: "architect",
            gates: [gate],
            tasks: [taskItem],
            worktreePath: "/repo/.kouen-worktrees/p46-test",
            branch: "feat/p46",
            baseBranch: "main",
            supersededBy: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(summary)
        XCTAssertFalse(data.isEmpty)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(FeatureSummary.self, from: data)
        XCTAssertEqual(decoded.slug, "p46-test")
        XCTAssertEqual(decoded.phase, "architect")
        XCTAssertEqual(decoded.gates.count, 1)
        XCTAssertEqual(decoded.gates.first?.gate, 1)
        XCTAssertEqual(decoded.gates.first?.approver, "supavit.cho")
        XCTAssertEqual(decoded.tasks.count, 1)
    }

    func testFeaturePhaseEnum() {
        XCTAssertEqual(FeaturePhase.interview.rawValue, "interview")
        XCTAssertEqual(FeaturePhase.architect.rawValue, "architect")
        XCTAssertEqual(FeaturePhase.qaDesign.rawValue, "qa-design")
        XCTAssertEqual(FeaturePhase.dev.rawValue, "dev")
        XCTAssertEqual(FeaturePhase.qaVerify.rawValue, "qa-verify")
        XCTAssertEqual(FeaturePhase.completed.rawValue, "completed")

        XCTAssertEqual(FeaturePhase(rawValue: "qa-design"), .qaDesign)
        XCTAssertEqual(FeaturePhase(rawValue: "qa-verify"), .qaVerify)
    }
}
