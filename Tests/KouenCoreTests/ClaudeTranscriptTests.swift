import XCTest
@testable import KouenCore

final class ClaudeTranscriptTests: XCTestCase {
    private func items(_ json: String) -> [TranscriptItem] {
        ClaudeTranscriptLine.items(from: Data(json.utf8))
    }

    // MARK: - ClaudeTranscriptLine

    func testTS5701_userStringContentBecomesUserItem() {
        let got = items(#"{"uuid":"u1","type":"user","message":{"role":"user","content":"  fix the sidebar  "}}"#)
        XCTAssertEqual(got, [TranscriptItem(id: "u1#0", role: .user, text: "fix the sidebar")])
    }

    func testTS5702_assistantTextThenToolUseInOrder() {
        let got = items(#"""
        {"uuid":"a1","type":"assistant","message":{"role":"assistant","content":[
          {"type":"text","text":"Patching it."},
          {"type":"tool_use","name":"Edit","input":{"file_path":"/repo/Sources/ShellIntegration.swift"}}]}}
        """#.replacingOccurrences(of: "\n", with: ""))
        XCTAssertEqual(got, [
            TranscriptItem(id: "a1#0", role: .assistant, text: "Patching it."),
            TranscriptItem(id: "a1#1", role: .tool, text: "", toolName: "Edit", toolTarget: "ShellIntegration.swift"),
        ])
    }

    func testTS5801_placeholdersStrippedAndImageBlockBecomesAttachment() {
        let got = items(#"{"uuid":"u9","message":{"role":"user","content":[{"type":"text","text":"[Image #4]"},{"type":"image","source":{"type":"base64","data":"AAA"}},{"type":"text","text":"look [Pasted text #2 +10 lines] here"}]}}"#)
        XCTAssertEqual(got, [
            TranscriptItem(id: "u9#1", role: .user, text: "", attachment: "image"),
            TranscriptItem(id: "u9#2", role: .user, text: "look  here"),
        ])
    }

    func testTS5802_metaTakesLastModelAndMode() {
        let lines = [
            #"{"type":"permission-mode","permissionMode":"manual"}"#,
            #"{"message":{"role":"assistant","model":"claude-opus-5-5","content":"a"}}"#,
            #"{"type":"permission-mode","permissionMode":"plan"}"#,
            #"{"message":{"role":"assistant","model":"<synthetic>","content":"a"}}"#,
        ].map { Data($0.utf8) }
        let m = ClaudeTranscriptLine.meta(from: lines)
        XCTAssertEqual(m.model, "claude-opus-5-5")
        XCTAssertEqual(m.mode, "plan")
    }

    func testTS5702_bashToolTargetIsTheCommand() {
        let got = items(#"{"uuid":"a2","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"swift test"}}]}}"#)
        XCTAssertEqual(got.first?.toolTarget, "swift test")
    }

    func testTS5703_toolResultOnlyLineIsDropped() {
        XCTAssertEqual(items(#"{"uuid":"u2","message":{"role":"user","content":[{"type":"tool_result","content":"ok"}]}}"#), [])
    }

    func testTS5704_metaAndWrapperLinesAreDropped() {
        XCTAssertEqual(items(#"{"uuid":"u3","isMeta":true,"message":{"role":"user","content":"Caveat: ..."}}"#), [])
        XCTAssertEqual(items(#"{"uuid":"u4","message":{"role":"user","content":"<command-name>/clear</command-name>"}}"#), [])
        XCTAssertEqual(items(#"{"uuid":"u5","message":{"role":"user","content":"<system-reminder>x</system-reminder>"}}"#), [])
    }

    func testTS5705_thinkingAndMalformedAreDropped() {
        XCTAssertEqual(items(#"{"uuid":"a3","message":{"role":"assistant","content":[{"type":"thinking","thinking":"hmm"}]}}"#), [])
        XCTAssertEqual(items("{not json"), [])
        XCTAssertEqual(items(#"{"type":"summary","summary":"x"}"#), [])
    }

    func testMessageTextJoinsTextPartsAndSkipsOthers() {
        let msg: [String: Any] = ["content": [["type": "text", "text": "a"], ["type": "tool_use", "name": "Read"], ["type": "text", "text": "b"]]]
        XCTAssertEqual(ClaudeTranscriptLine.messageText(msg), "ab")
        XCTAssertEqual(ClaudeTranscriptLine.messageText(["content": "plain"]), "plain")
    }

    // MARK: - ClaudeSessionLocator

    func testTS5707_resolvesTranscriptFromPidFile() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let sessions = root.appendingPathComponent("sessions"), projects = root.appendingPathComponent("projects")
        let proj = projects.appendingPathComponent("-Users-x-repo")
        try FileManager.default.createDirectory(at: sessions, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: proj, withIntermediateDirectories: true)
        try Data(#"{"pid":4242,"sessionId":"abc-123","cwd":"/Users/x/repo"}"#.utf8).write(to: sessions.appendingPathComponent("4242.json"))
        let transcript = proj.appendingPathComponent("abc-123.jsonl")
        try Data().write(to: transcript)

        let got = ClaudeSessionLocator.transcriptURL(pid: 4242, sessionsDir: sessions, projectsDir: projects)
        XCTAssertEqual(got?.standardizedFileURL.path, transcript.standardizedFileURL.path)
    }

    func testTS5708_missingPidFileOrTranscriptResolvesNil() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let sessions = root.appendingPathComponent("sessions"), projects = root.appendingPathComponent("projects")
        try FileManager.default.createDirectory(at: sessions, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: projects, withIntermediateDirectories: true)
        XCTAssertNil(ClaudeSessionLocator.transcriptURL(pid: 1, sessionsDir: sessions, projectsDir: projects))
        try Data(#"{"pid":2,"sessionId":"gone"}"#.utf8).write(to: sessions.appendingPathComponent("2.json"))
        XCTAssertNil(ClaudeSessionLocator.transcriptURL(pid: 2, sessionsDir: sessions, projectsDir: projects))
        XCTAssertNil(ClaudeSessionLocator.transcriptURL(pid: 0, sessionsDir: sessions, projectsDir: projects))
    }

    // MARK: - Offset tail

    func testTS5709_readsOnlyLinesAfterOffset() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jsonl")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("{\"a\":1}\n".utf8).write(to: url)
        let first = try XCTUnwrap(AgentHistoryScanner.readJSONLLines(from: url, fromOffset: 0))
        XCTAssertEqual(first.lines.count, 1)

        let handle = try FileHandle(forWritingTo: url)
        handle.seekToEndOfFile(); handle.write(Data("{\"b\":2}\n{\"c\":3}\n".utf8)); try handle.close()
        let next = try XCTUnwrap(AgentHistoryScanner.readJSONLLines(from: url, fromOffset: first.endOffset))
        XCTAssertEqual(next.lines.map { String(decoding: $0, as: UTF8.self) }, ["{\"b\":2}", "{\"c\":3}"])
        XCTAssertEqual(next.endOffset, try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int)
    }

    func testTS5710_partialTrailingLineIsHeldBack() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jsonl")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("{\"a\":1}\n{\"b\":".utf8).write(to: url)
        let got = try XCTUnwrap(AgentHistoryScanner.readJSONLLines(from: url, fromOffset: 0))
        XCTAssertEqual(got.lines.count, 1)
        XCTAssertEqual(got.endOffset, 8) // stops right after the first newline
    }
}
