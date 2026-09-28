import XCTest
@testable import KouenCore

/// Fixture shapes copied from real VS Code Copilot Chat files (2026-09-28), trimmed.
final class VSCodeChatSessionTests: XCTestCase {
    func testReplaysJSONLPatchLog() throws {
        let log = [
            #"{"kind":0,"v":{"sessionId":"s1","requests":[],"responderUsername":""}}"#,
            #"{"kind":1,"k":["responderUsername"],"v":"GitHub Copilot"}"#,
            #"{"kind":2,"k":["requests"],"v":[{"requestId":"r1","timestamp":1789968274783,"message":{"text":"fix the login test"},"response":[]}]}"#,
            #"{"kind":2,"k":["requests",0,"response"],"v":[{"kind":"thinking","value":"hidden reasoning"},{"value":"Done — "},{"kind":"toolInvocationSerialized","invocationMessage":"Using tool"},{"value":"updated the spec."}]}"#,
            #"{"kind":1,"k":["customTitle"],"v":"Login test fix"}"#,
            #"{"kind":9,"k":["ignored"],"v":1}"#,
            "not json",
        ].joined(separator: "\n")

        let session = try XCTUnwrap(VSCodeChatSession.parse(Data(log.utf8), isJSONL: true))

        XCTAssertEqual(session.sessionID, "s1")
        XCTAssertEqual(session.title, "Login test fix")
        XCTAssertEqual(session.requests, [.init(
            prompt: "fix the login test", response: "Done — updated the spec.",
            timestamp: Date(timeIntervalSince1970: 1789968274.783)
        )], "thinking/tool items are dropped; markdown chunks are joined")
    }

    func testParsesLegacyJSONAndSkipsEmptyPrompts() throws {
        let json = #"{"sessionId":"s2","lastMessageDate":1757663662784,"requests":[{"message":{"text":"  "},"response":[]},{"timestamp":1757583934455,"message":{"text":"hi"},"response":[{"value":"hello"},{"kind":"inlineReference"}]}]}"#

        let session = try XCTUnwrap(VSCodeChatSession.parse(Data(json.utf8), isJSONL: false))

        XCTAssertNil(session.title)
        XCTAssertEqual(session.requests.map(\.prompt), ["hi"])
        XCTAssertEqual(session.requests.first?.response, "hello")
        XCTAssertEqual(session.lastMessageDate, Date(timeIntervalSince1970: 1757663662.784))
    }

    func testRecordIsViewOnlyCopilotAndNilWithoutRequests() throws {
        let empty = VSCodeChatSession(sessionID: "e", title: nil, requests: [], lastMessageDate: nil)
        XCTAssertNil(AgentHistoryScanner.vscodeRecord(empty, projectPath: "/p", transcriptPath: "/t", fallbackDate: Date()))

        let session = VSCodeChatSession(sessionID: "s", title: nil, requests: [.init(prompt: "first line\nmore", response: "ok", timestamp: nil)], lastMessageDate: nil)
        let record = try XCTUnwrap(AgentHistoryScanner.vscodeRecord(session, projectPath: "/work/app", transcriptPath: "/t", fallbackDate: Date()))
        XCTAssertEqual(record.agentKind, .copilot)
        XCTAssertEqual(record.placement, .vscode)
        XCTAssertEqual(record.title, "first line")
        XCTAssertEqual(record.projectName, "app")
        XCTAssertEqual(record.latestTurns.map(\.content), ["first line\nmore", "ok"])
    }

    /// Reads this machine's real stores. Opt-in: `KOUEN_LIVE_HISTORY=1 swift test --filter …`.
    func testLiveScanCounts() async throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["KOUEN_LIVE_HISTORY"] == "1")
        let scanner = AgentHistoryScanner()
        let vscode = await scanner.scanVSCodeCopilotChat()
        let agy = await scanner.scanAntigravity()
        let codex = await scanner.scanCodex()
        print("LIVE vscode=\(vscode.count) agy=\(agy.count) codex=\(codex.count)")
        print("LIVE vscode sample: \(vscode.prefix(3).map { "\($0.title) @ \($0.projectName)" })")
    }
}
