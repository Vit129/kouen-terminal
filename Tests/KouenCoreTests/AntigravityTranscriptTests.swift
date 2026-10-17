import XCTest
@testable import KouenCore

final class AntigravityTranscriptTests: XCTestCase {
    private func items(_ json: String) -> [TranscriptItem] {
        AntigravityTranscriptLine.items(from: Data(json.utf8))
    }

    func testUserInputStripsUserRequestTags() {
        let line = #"{"type":"USER_INPUT","step_index":1,"content":"<USER_REQUEST>ทำต่อ feature นี้หน่อย</USER_REQUEST>"}"#
        let got = items(line)
        XCTAssertEqual(got.count, 1)
        XCTAssertEqual(got.first?.role, .user)
        XCTAssertEqual(got.first?.text, "ทำต่อ feature นี้หน่อย")
    }

    func testPlannerResponseExtractsToolsAndAssistantText() {
        let line = #"""
        {
            "type": "PLANNER_RESPONSE",
            "step_index": 2,
            "tool_calls": [
                {
                    "name": "replace_file_content",
                    "args": {"TargetFile": "/path/to/MobileBridgeServer.swift"}
                }
            ],
            "content": "Updating mobile bridge server now."
        }
        """#
        let got = items(line)
        XCTAssertEqual(got.count, 2)
        XCTAssertEqual(got[0].role, .tool)
        XCTAssertEqual(got[0].toolName, "replace_file_content")
        XCTAssertEqual(got[0].toolTarget, "MobileBridgeServer.swift")
        XCTAssertEqual(got[1].role, .assistant)
        XCTAssertEqual(got[1].text, "Updating mobile bridge server now.")
    }

    func testToolCallStripsQuotesFromPath() {
        let line = #"""
        {
            "type": "PLANNER_RESPONSE",
            "step_index": 3,
            "tool_calls": [
                {
                    "name": "view_file",
                    "args": {"AbsolutePath": "\"/Users/supavit.cho/Library/Application Support/Kouen/pasted-images/pasted-1792210825-02FA8614.png\""}
                }
            ],
            "content": ""
        }
        """#
        let got = items(line)
        XCTAssertEqual(got.count, 1)
        XCTAssertEqual(got[0].role, .tool)
        XCTAssertEqual(got[0].toolName, "view_file")
        XCTAssertEqual(got[0].toolTarget, "pasted-1792210825-02FA8614.png")
    }

    func testPlumbingAndGenericLinesAreDropped() {
        let lines = [
            #"{"type":"GENERIC","content":"Command exited with code 0"}"#,
            #"{"type":"CHECKPOINT","content":"checkpoint data"}"#,
            #"{"type":"SYSTEM_MESSAGE","content":"<SYSTEM_MESSAGE>info</SYSTEM_MESSAGE>"}"#
        ]
        for l in lines {
            XCTAssertTrue(items(l).isEmpty, "Expected line to be dropped: \(l)")
        }
    }

    func testAntigravityMetaAndUsageExtraction() {
        let lines = [
            #"{"type":"USER_INPUT","content":"hello"}"#,
            #"{"type":"PLANNER_RESPONSE","content":"Using model Model Selection` from None to gemini-2.5-pro. Here is my answer.","input_tokens":1250,"output_tokens":420,"cache_read_tokens":300}"#
        ].map { Data($0.utf8) }

        let meta = AntigravityTranscriptLine.meta(from: lines)
        XCTAssertEqual(meta.model, "gemini-2.5-pro")
        XCTAssertNotNil(meta.usage)
        XCTAssertEqual(meta.usage?.inputTokens, 1250)
        XCTAssertEqual(meta.usage?.outputTokens, 420)
        XCTAssertEqual(meta.usage?.cacheReadTokens, 300)
        XCTAssertEqual(meta.usage?.shortSummary, "1.6k ctx")
    }

    func testWorkspacePathBoundaryMatching() {
        let wsJson = #"["file:///Users/supavit.cho/Git/Personal/kouen-terminal"]"#
        // Exact match passes
        XCTAssertTrue(AntigravitySessionLocator.matchesWorkspace(wsStr: wsJson, stdCwd: "/Users/supavit.cho/Git/Personal/kouen-terminal"))
        // Subdirectory match passes
        XCTAssertTrue(AntigravitySessionLocator.matchesWorkspace(wsStr: wsJson, stdCwd: "/Users/supavit.cho/Git/Personal"))
        // Suffix/substring match without boundary fails
        XCTAssertFalse(AntigravitySessionLocator.matchesWorkspace(wsStr: wsJson, stdCwd: "/kouen-terminal"))
        XCTAssertFalse(AntigravitySessionLocator.matchesWorkspace(wsStr: wsJson, stdCwd: "/Personal/kouen-terminal"))
        XCTAssertFalse(AntigravitySessionLocator.matchesWorkspace(wsStr: wsJson, stdCwd: "/Users/supavit.cho/Git/Personal/kouen"))
    }

    // The agy CLI has no conversation_summaries.db: the session is matched by the project its
    // transcript works in, ignoring agy's own ~/.gemini reads, never by "newest wins".
    func testCLIWithoutSummaryDBMatchesTranscriptByDominantProject() throws {
        let home = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: home) }
        let brain = home.appendingPathComponent(".gemini/antigravity-cli/brain")
        func write(_ id: String, _ text: String, age: TimeInterval) throws {
            let logs = brain.appendingPathComponent(id).appendingPathComponent(".system_generated/logs")
            try FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
            let file = logs.appendingPathComponent("transcript.jsonl")
            try Data(text.utf8).write(to: file)
            try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(-age)], ofItemAtPath: file.path)
        }
        let gemini = String(repeating: #"{"p":"/Users/u/.gemini/config/skills/x/SKILL.md"}"# + "\n", count: 5)
        try write("aodd", gemini + String(repeating: #"{"p":"/Users/u/Git/Personal/aodd-aisdlc/README.md"}"# + "\n", count: 3), age: 60)
        try write("kouen", gemini + String(repeating: #"{"p":"/Users/u/Git/Personal/kouen-terminal/a.swift"}"# + "\n", count: 3), age: 0)

        let url = AntigravitySessionLocator.transcriptURL(pid: 0, surfaceCwd: "/Users/u/Git/Personal/aodd-aisdlc", home: home)
        XCTAssertEqual(url?.pathComponents.dropLast(3).last, "aodd")
        XCTAssertNil(AntigravitySessionLocator.transcriptURL(pid: 0, surfaceCwd: "/Users/u/Git/Personal/other", home: home))
    }

    func testParseRealAntigravityTranscriptIfAvailable() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let candidateDir = home.appendingPathComponent(".gemini/antigravity-cli/brain")
        guard FileManager.default.fileExists(atPath: candidateDir.path),
              let sessions = try? FileManager.default.contentsOfDirectory(atPath: candidateDir.path) else {
            return
        }

        var foundAny = false
        for session in sessions.prefix(20) {
            let transcriptFile = candidateDir.appendingPathComponent(session)
                .appendingPathComponent(".system_generated/logs/transcript.jsonl")
            if FileManager.default.fileExists(atPath: transcriptFile.path),
               let (lines, _) = AgentHistoryScanner.readJSONLLines(from: transcriptFile) {
                foundAny = true
                let meta = AntigravityTranscriptLine.meta(from: lines)
                if let usage = meta.usage {
                    XCTAssertGreaterThan(usage.contextTokens ?? 0, 0)
                    XCTAssertFalse(usage.shortSummary?.isEmpty ?? true)
                    return
                }
            }
        }
        if foundAny {
            XCTFail("Found Antigravity transcripts but none contained parsed token usage")
        }
    }
}
