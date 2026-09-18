import XCTest
@testable import KouenCore

final class AgentAvailabilityCheckerTests: XCTestCase {
    func testInstalledExecutableResolvesOnPath() {
        // `ls` is guaranteed present on every macOS/Linux CI runner.
        let table = AgentTable(entries: [AgentTableEntry(kind: .claudeCode, executables: ["ls"])])
        let result = AgentAvailabilityChecker.check(kind: .claudeCode, table: table)
        switch result {
        case .installedAuthenticated, .installedNeedsKey:
            break // either is fine — this asserts "found on PATH", not the config-file heuristic
        case .notInstalled:
            XCTFail("expected `ls` to resolve on PATH")
        }
    }

    func testMissingExecutableReportsNotInstalled() {
        let table = AgentTable(entries: [AgentTableEntry(kind: .codex, executables: ["kouen-test-nonexistent-binary-9f3a"])])
        XCTAssertEqual(AgentAvailabilityChecker.check(kind: .codex, table: table), .notInstalled)
    }

    func testUnknownKindWithNoTableEntryReportsNotInstalled() {
        let table = AgentTable(entries: [])
        XCTAssertEqual(AgentAvailabilityChecker.check(kind: .aider, table: table), .notInstalled)
    }

    func testCheckAllCoversEveryTableEntry() {
        let table = AgentTable(entries: [
            AgentTableEntry(kind: .claudeCode, executables: ["ls"]),
            AgentTableEntry(kind: .codex, executables: ["kouen-test-nonexistent-binary-9f3a"]),
        ])
        let results = AgentAvailabilityChecker.checkAll(table: table)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[.codex], .notInstalled)
        XCTAssertNotEqual(results[.claudeCode], .notInstalled)
    }
}
