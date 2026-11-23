import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// End-to-end IPC for the Claude Code Harness (M10): a real `DaemonServer` on a temp
/// socket, driven by a real `DaemonClient` — same pattern as `DaemonRoundTripTests`.
/// `kouenCCRun`/`kouenCCStatus` (kouen-mcp) call through `DaemonClientActor` onto the
/// exact same socket protocol these tests exercise directly via `IPCRequest`, so this
/// proves the real MCP wiring without needing kouen-mcp's own process-arg-parsing glue
/// (which is a thin, compiler-checked string/dictionary extraction layer).
///
/// Live-daemon-gated like `DaemonRoundTripTests`: binds a real socket (fragile inside the
/// XCTest runner). The start/run test spawns a subprocess that emits a Claude JSONL result.
/// Run with `KOUEN_LIVE_DAEMON_TESTS=1 swift test --filter ClaudeCodeHarnessIPCTests`.
final class ClaudeCodeHarnessIPCTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?
    private var server: DaemonServer!

    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = URL(fileURLWithPath: "/tmp/hrt-cc-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()

        let adapters = ClaudeCodeHarness.defaultAdapters.filter { $0.agentKind != .claudeCode }
        server = DaemonServer(
            enableVersionBanner: false,
            claudeCodeHarness: ClaudeCodeHarness(adapters: adapters + [FixtureClaudeAdapter()])
        )
        try server.start()
        try waitForDaemonReady()
    }

    override func tearDownWithError() throws {
        server?.stop()
        server = nil
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    private func waitForDaemonReady() throws {
        let client = DaemonClient()
        for _ in 0 ..< 50 {
            if case .pong = (try? client.request(.ping, timeout: 0.4)) { return }
            usleep(100_000)
        }
        XCTFail("daemon did not become ready")
    }

    func testListIsEmptyBeforeAnyRunStarted() throws {
        let client = DaemonClient()
        guard case let .ccRuns(runs) = try client.request(.ccRunList) else {
            return XCTFail("Expected .ccRuns from ccRunList")
        }
        XCTAssertTrue(runs.isEmpty)
    }

    func testGetUnknownRunReturnsNilInfo() throws {
        let client = DaemonClient()
        guard case let .ccRunInfo(summary) = try client.request(.ccRunGet(id: UUID())) else {
            return XCTFail("Expected .ccRunInfo from ccRunGet")
        }
        XCTAssertNil(summary)
    }

    func testCancelUnknownRunReturnsError() throws {
        let client = DaemonClient()
        guard case .error = try client.request(.ccRunCancel(id: UUID())) else {
            return XCTFail("Expected .error from ccRunCancel on an unknown id")
        }
    }

    /// Spawns the fixture via the full MCP-shaped request, polls status, and checks the
    /// terminal result decoded by the production Claude JSONL parser.
    func testStartRunReachesTerminalStateWithResult() throws {
        let client = DaemonClient()
        let id = UUID()
        guard case .ccRunInfo = try client.request(.ccRunStart(
            id: id, prompt: "Reply with exactly the word: pong", cwd: "/tmp",
            profile: "readonly", model: nil, effort: nil
        )) else {
            return XCTFail("Expected .ccRunInfo from ccRunStart")
        }

        var finalSummary: ClaudeRunSummary?
        for _ in 0 ..< 300 { // up to 30s
            guard case let .ccRunInfo(summary?) = try client.request(.ccRunGet(id: id)) else {
                return XCTFail("Expected .ccRunInfo(non-nil) from ccRunGet for a started run")
            }
            if summary.state != "running" {
                finalSummary = summary
                break
            }
            usleep(100_000)
        }

        guard let finalSummary else {
            return XCTFail("Run did not reach a terminal state within 30s")
        }
        XCTAssertEqual(finalSummary.state, "succeeded")
        XCTAssertEqual(finalSummary.resultText, "pong")
        XCTAssertEqual(finalSummary.totalCostUSD, 0)

        guard case let .ccRuns(runs) = try client.request(.ccRunList) else {
            return XCTFail("Expected .ccRuns from ccRunList")
        }
        XCTAssertTrue(runs.contains { $0.id == id }, "completed run should still be listed")
    }

    func testSwarmSpawnStructuredRejectsUnsupportedAgentWithHelpfulError() throws {
        let client = DaemonClient()
        guard case let .error(message) = try client.request(
            .swarmSpawn(lane: "structured", agentKindRaw: "cursor", cwd: nil, initialCommand: "hello", role: nil)
        ) else {
            return XCTFail("Expected .error when spawning structured swarm worker with unsupported agent")
        }
        XCTAssertTrue(message.contains("headless: true has no adapter for 'cursor'"))
        XCTAssertTrue(message.contains("claude-code"))
    }
}

private struct FixtureClaudeAdapter: HeadlessCLIAdapter {
    let agentKind: AgentKind = .claudeCode
    let binaryName = "sh"
    let candidateBinaryPaths = ["/bin/sh"]

    func probeCommand(shellPath: String) -> String { "command -v sh" }

    func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String] {
        ["-c", #"""
        printf '%s\n' '{"type":"result","is_error":false,"result":"pong","total_cost_usd":0}'
        """#]
    }

    func parseLine(_ lineData: Data) -> [HeadlessRunEvent] {
        ClaudeAdapter().parseLine(lineData)
    }
}
