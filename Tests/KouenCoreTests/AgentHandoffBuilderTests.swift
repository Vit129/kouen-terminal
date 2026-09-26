import XCTest
import KouenIPC
@testable import KouenCore

final class AgentHandoffBuilderTests: XCTestCase {
    func testBuildBriefWithFirstPromptAndTurns() {
        let record = AgentSessionRecord(
            id: "session-123",
            agentKind: .claudeCode,
            title: "Fix bug in parser",
            projectPath: "/Users/test/Project",
            projectName: "Project",
            messageCount: 5,
            updatedAt: Date(),
            firstPrompt: "Please fix the crash in JSON parser",
            latestTurns: [
                AgentHistoryTurn(role: "user", content: "Did you run tests?"),
                AgentHistoryTurn(role: "assistant", content: "Yes, 3 tests passed.")
            ],
            transcriptPath: "/path/to/transcript.jsonl",
            worktreeAvailable: false
        )

        let brief = AgentHandoffBuilder.buildBrief(from: record, targetAgent: .codex)

        XCTAssertTrue(brief.contains("Task Handoff from Claude Code to Codex"))
        XCTAssertTrue(brief.contains("Please fix the crash in JSON parser"))
        XCTAssertTrue(brief.contains("**[User]** Did you run tests?"))
        XCTAssertTrue(brief.contains("**[Assistant]** Yes, 3 tests passed."))
        XCTAssertTrue(brief.contains("Please inspect `git status` and `git diff`"))
    }

    func testBuildBriefFallbackToTitleWhenFirstPromptEmpty() {
        let record = AgentSessionRecord(
            id: "session-456",
            agentKind: .antigravity,
            title: "Refactor database client",
            projectPath: "/Users/test/Project",
            projectName: "Project",
            messageCount: 1,
            updatedAt: Date(),
            firstPrompt: "",
            latestTurns: [],
            transcriptPath: "/path/to/transcript.jsonl",
            worktreeAvailable: false
        )

        let brief = AgentHandoffBuilder.buildBrief(from: record, targetAgent: .claudeCode)

        XCTAssertTrue(brief.contains("Task Handoff from Antigravity to Claude Code"))
        XCTAssertTrue(brief.contains("Refactor database client"))
    }

    func testBracketedPasteDataFormatting() {
        let text = "Line 1\nLine 2\nLine 3"
        let data = AgentHandoffBuilder.bracketedPasteData(for: text)
        let string = String(decoding: data, as: UTF8.self)

        XCTAssertTrue(string.hasPrefix("\u{1b}[200~"))
        XCTAssertTrue(string.contains("Line 1\nLine 2\nLine 3"))
        XCTAssertTrue(string.hasSuffix("\u{1b}[201~\r"))
    }
}
