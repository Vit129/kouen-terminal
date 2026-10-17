import XCTest
@testable import KouenCore

final class CodexTranscriptTests: XCTestCase {
    private func items(_ json: String) -> [TranscriptItem] {
        CodexTranscriptLine.items(from: Data(json.utf8))
    }

    func testCodexMessageItems() {
        let userLine = #"{"type":"message","ordinal":1,"payload":{"role":"user","content":"How do I build this?"}}"#
        let gotUser = items(userLine)
        XCTAssertEqual(gotUser.count, 1)
        XCTAssertEqual(gotUser.first?.role, .user)
        XCTAssertEqual(gotUser.first?.text, "How do I build this?")

        let assistantLine = #"{"type":"message","ordinal":2,"payload":{"role":"assistant","content":"Use swift build."}}"#
        let gotAssistant = items(assistantLine)
        XCTAssertEqual(gotAssistant.count, 1)
        XCTAssertEqual(gotAssistant.first?.role, .assistant)
        XCTAssertEqual(gotAssistant.first?.text, "Use swift build.")
    }

    func testCodexToolCallItems() {
        let toolLine = #"{"type":"custom_tool_call","ordinal":3,"payload":{"name":"shell","arguments":"{\"command\":\"swift test\"}"}}"#
        let gotTool = items(toolLine)
        XCTAssertEqual(gotTool.count, 1)
        XCTAssertEqual(gotTool.first?.role, .tool)
        XCTAssertEqual(gotTool.first?.toolName, "shell")
        XCTAssertEqual(gotTool.first?.toolTarget, "swift test")
    }

    func testCodexMetaAndUsageExtraction() {
        let lines = [
            #"{"timestamp":"2026-10-16T14:23:33.372Z","type":"turn_context","payload":{"model":"gpt-5.6-terra"}}"#,
            #"{"timestamp":"2026-10-16T14:23:45.628Z","type":"event_msg","payload":{"type":"token_count","info":{"total_token_usage":{"input_tokens":28875,"cached_input_tokens":1792,"cache_write_input_tokens":0,"output_tokens":374,"reasoning_output_tokens":112,"total_tokens":29249}}}}"#
        ].map { Data($0.utf8) }

        let meta = CodexTranscriptLine.meta(from: lines)
        XCTAssertEqual(meta.model, "gpt-5.6-terra")
        XCTAssertNotNil(meta.usage)
        XCTAssertEqual(meta.usage?.inputTokens, 28875)
        XCTAssertEqual(meta.usage?.outputTokens, 374)
        XCTAssertEqual(meta.usage?.cacheReadTokens, 1792)
        XCTAssertEqual(meta.usage?.thinkingTokens, 112)
        XCTAssertEqual(meta.usage?.contextTokens, 30667)
        XCTAssertEqual(meta.usage?.shortSummary, "31k ctx")
    }

    func testParseRealCodexRolloutIfAvailable() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let codexDir = home.appendingPathComponent(".codex/sessions")
        guard FileManager.default.fileExists(atPath: codexDir.path),
              let enumerator = FileManager.default.enumerator(at: codexDir, includingPropertiesForKeys: nil) else {
            return
        }

        var foundRollout = false
        for case let url as URL in enumerator {
            if url.lastPathComponent.hasPrefix("rollout-") && url.pathExtension == "jsonl" {
                foundRollout = true
                if let record = AgentHistoryScanner.parseCodexTranscript(fileURL: url),
                   let usage = record.usage {
                    XCTAssertGreaterThan(usage.contextTokens ?? 0, 0)
                    XCTAssertFalse(usage.shortSummary?.isEmpty ?? true)
                    return
                }
            }
        }
        if foundRollout {
            XCTFail("Found Codex rollout files but none parsed with valid usage")
        }
    }
}
