import XCTest
@testable import KouenDaemonCore

/// Adapter line-parsing against real captured JSONL output from each CLI, same "no process
/// spawning" style as `ClaudeCodeHarnessTests`. Fixtures captured 2026-09-14 against real local
/// installs (`codex 0.153.2`, `agy` via `~/.local/bin/agy`, `copilot` via `gh copilot --`).
final class HeadlessCLIAdapterTests: XCTestCase {
    // MARK: - CodexAdapter

    func testCodexParsesAgentMessageAsAssistantText() {
        let adapter = CodexAdapter()
        let line = """
        {"type":"item.completed","item":{"id":"item_1","type":"agent_message","text":"hi"}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [.assistantText("hi")])
    }

    func testCodexIgnoresNonAgentMessageItems() {
        let adapter = CodexAdapter()
        let errorItem = """
        {"type":"item.completed","item":{"id":"item_0","type":"error","message":"Skill descriptions were shortened"}}
        """
        XCTAssertEqual(adapter.parseLine(Data(errorItem.utf8)), [])
    }

    func testCodexIgnoresLifecycleLines() {
        let adapter = CodexAdapter()
        for line in [
            #"{"type":"thread.started","thread_id":"01a09ed0-be7c-7be0-a57a-37df757b6bb0"}"#,
            #"{"type":"turn.started"}"#,
            #"{"type":"turn.completed","usage":{"input_tokens":26038,"output_tokens":5}}"#,
        ] {
            XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [], "expected no events for: \(line)")
        }
    }

    /// Real degraded/legacy envelope captured live (2026-09-14): an unrecoverable failure
    /// (model requiring a newer Codex CLI than was installed) emits `{"id","msg":{...}}`
    /// lines instead of `{"type":"item.completed","item":{...}}` — and Codex still exits 0
    /// on this path, so this terminal error line is the ONLY signal that distinguishes a
    /// real failure from success. See `CodexAdapter`'s doc comment for the full transcript.
    func testCodexParsesLegacyTerminalErrorAsFailedResult() {
        let adapter = CodexAdapter()
        let line = """
        {"id":"0","msg":{"type":"error","message":"unexpected status 400 Bad Request: {\\"detail\\":\\"The 'gpt-5.6-terra' model requires a newer version of Codex. Please upgrade to the latest app or CLI and try again.\\"}"}}
        """
        let events = adapter.parseLine(Data(line.utf8))
        XCTAssertEqual(events.count, 1)
        guard case let .result(text, costUSD, isError) = events.first else {
            return XCTFail("expected a .result event, got \(events)")
        }
        XCTAssertTrue(isError)
        XCTAssertNil(costUSD)
        XCTAssertTrue(text?.contains("gpt-5.6-terra") ?? false)
    }

    /// Regression test for a real bug found live (2026-09-14) in the FIRST version of the
    /// legacy-error fix: an empty-`id` error (a session-level notice not tied to any task,
    /// e.g. an unrelated optional MCP tool failing to start) was being treated as terminal
    /// too, flipping the run to `.failed` within the first second — long before the real
    /// outcome (several retries later) was known, and with the wrong message. Must be ignored.
    func testCodexIgnoresErrorWithEmptyTaskID() {
        let adapter = CodexAdapter()
        let line = """
        {"id":"","msg":{"type":"error","message":"MCP client for `computer-use` failed to start: No such file or directory (os error 2)"}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [])
    }

    /// `stream_error` is a retry-in-progress notice, not a terminal failure — Codex retries
    /// automatically and may still succeed, so this must NOT be reported as a `.result`.
    func testCodexIgnoresNonTerminalStreamError() {
        let adapter = CodexAdapter()
        let line = """
        {"id":"0","msg":{"type":"stream_error","message":"stream error: unexpected status 400 Bad Request; retrying 1/5 in 180ms…"}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [])
    }

    /// The legacy envelope's lifecycle lines (`task_started`, no top-level `type`/`item`)
    /// must not accidentally match either decoder and produce a spurious event.
    func testCodexIgnoresLegacyLifecycleLines() {
        let adapter = CodexAdapter()
        let line = #"{"id":"0","msg":{"type":"task_started","model_context_window":null}}"#
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [])
    }

    func testCodexBuildArgumentsMapsProfileToSandboxMode() {
        let adapter = CodexAdapter()
        let readonly = adapter.buildArguments(
            id: UUID(), prompt: "hi", profile: .readonly, model: nil, effort: nil, resumeSessionID: nil
        )
        XCTAssertTrue(readonly.contains("read-only"))
        XCTAssertTrue(readonly.contains("--json"))
        XCTAssertEqual(readonly.last, "hi")

        let edit = adapter.buildArguments(
            id: UUID(), prompt: "hi", profile: .edit, model: nil, effort: nil, resumeSessionID: nil
        )
        XCTAssertTrue(edit.contains("workspace-write"))
    }

    // MARK: - AgyAdapter

    func testAgyParsesResultLineAsFinalResult() {
        let adapter = AgyAdapter()
        let line = """
        {"event":"result","result":{"conversation_id":"37e27586-1d8a-4f47-82b8-0fef06afcf18","status":"SUCCESS","response":"hi\\n","duration_seconds":7.06}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [.result(text: "hi\n", costUSD: nil, isError: false)])
    }

    func testAgyFailedStatusMapsToIsError() {
        let adapter = AgyAdapter()
        let line = """
        {"event":"result","result":{"conversation_id":"x","status":"ERROR","response":null}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [.result(text: nil, costUSD: nil, isError: true)])
    }

    func testAgyIgnoresStepUpdateAndInitLines() {
        let adapter = AgyAdapter()
        for line in [
            #"{"event":"init","conversation_id":"37e27586-1d8a-4f47-82b8-0fef06afcf18","init":{"cwd":"/tmp"}}"#,
            #"{"event":"step_update","step_update":{"conversation_id":"x","step_index":1,"state":"ACTIVE","step_type":"agent_response","text_delta":"hi"}}"#,
        ] {
            XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [], "expected no events for: \(line)")
        }
    }

    func testAgyBuildArgumentsAttachesPromptToPrintFlag() {
        let adapter = AgyAdapter()
        let args = adapter.buildArguments(
            id: UUID(), prompt: "hi", profile: .readonly, model: nil, effort: nil, resumeSessionID: nil
        )
        XCTAssertTrue(args.contains("--print=hi"), "agy's --print must have the prompt attached, not as a separate argument")
        XCTAssertTrue(args.contains("plan"))
    }

    // MARK: - CopilotAdapter

    func testCopilotParsesAssistantMessageAsAssistantText() {
        let adapter = CopilotAdapter()
        let line = """
        {"type":"assistant.message","data":{"messageId":"449e2125-7be4-45c3-ae40-2e303721b538","model":"gpt-5.6-luna","content":"hi","toolRequests":[]}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [.assistantText("hi")])
    }

    func testCopilotIgnoresMessageDelta() {
        let adapter = CopilotAdapter()
        let line = """
        {"type":"assistant.message_delta","data":{"messageId":"449e2125-7be4-45c3-ae40-2e303721b538","deltaContent":"hi"}}
        """
        XCTAssertEqual(adapter.parseLine(Data(line.utf8)), [])
    }

    func testCopilotResultLineMapsExitCodeToIsErrorWithNilText() {
        let adapter = CopilotAdapter()
        let success = """
        {"type":"result","timestamp":"2026-09-14T07:29:37.338Z","sessionId":"d6fd9098-45a2-456e-a728-a1420f88e252","exitCode":0,"usage":{}}
        """
        XCTAssertEqual(adapter.parseLine(Data(success.utf8)), [.result(text: nil, costUSD: nil, isError: false)])

        let failure = """
        {"type":"result","sessionId":"x","exitCode":1,"usage":{}}
        """
        XCTAssertEqual(adapter.parseLine(Data(failure.utf8)), [.result(text: nil, costUSD: nil, isError: true)])
    }

    func testCopilotBuildArgumentsUsesCallerSuppliedSessionID() {
        let adapter = CopilotAdapter()
        let id = UUID()
        let fresh = adapter.buildArguments(id: id, prompt: "hi", profile: .edit, model: nil, effort: nil, resumeSessionID: nil)
        XCTAssertTrue(fresh.contains("--allow-all-tools"))
        guard let sessionIDIndex = fresh.firstIndex(of: "--session-id") else {
            return XCTFail("expected --session-id in arguments")
        }
        XCTAssertEqual(fresh[fresh.index(after: sessionIDIndex)], id.uuidString, "no resumeSessionID falls back to id")

        let resumeID = UUID()
        let resumed = adapter.buildArguments(id: id, prompt: "hi", profile: .edit, model: nil, effort: nil, resumeSessionID: resumeID)
        guard let resumedIndex = resumed.firstIndex(of: "--session-id") else {
            return XCTFail("expected --session-id in arguments")
        }
        XCTAssertEqual(resumed[resumed.index(after: resumedIndex)], resumeID.uuidString, "resumeSessionID takes precedence over id")
    }

    // MARK: - Multi-adapter registry (ClaudeCodeHarness)

    func testHarnessRoutesParseLineToTheRunsOwnAdapter() async {
        // Exercises the engine's per-run adapter lookup added for multi-adapter support —
        // feeding a Codex-shaped line through with `agentKind: .codex` must decode using
        // CodexAdapter's grammar, not the default ClaudeAdapter's.
        let harness = ClaudeCodeHarness()
        var summary = ClaudeCodeHarness.RunSummary(id: UUID(), state: .running, cwd: "/tmp", startedAt: Date())
        let line = """
        {"type":"item.completed","item":{"id":"item_1","type":"agent_message","text":"hi from codex"}}
        """
        await harness.parseLine(Data(line.utf8), into: &summary, agentKind: .codex)
        XCTAssertEqual(summary.lastAssistantText, "hi from codex")
    }
}
