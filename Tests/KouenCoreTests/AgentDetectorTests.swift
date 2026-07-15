#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import XCTest
@testable import KouenCore

final class AgentDetectorTests: XCTestCase {
    func testActivityTracksRecentOutputAndDecaysAfterQuietWindow() throws {
        let surfaceKey = UUID().uuidString
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process.arguments = ["5"]
        try process.run()
        defer {
            if process.isRunning { process.terminate() }
            AgentDetector.unregisterRootPID(forSurfaceKey: surfaceKey)
        }

        AgentDetector.registerRootPID(getpid(), forSurfaceKey: surfaceKey)
        let table = AgentTable(entries: [
            AgentTableEntry(kind: .generic, executables: ["sleep"]),
        ])

        // Short window so the decay assertion doesn't sleep through the real
        // (deliberately generous) `AgentDetector.workingWindow`.
        let window: TimeInterval = 1

        _ = AgentDetector.scan(table: table, workingWindow: window)
        XCTAssertEqual(AgentDetector.snapshot(forSurfaceKey: surfaceKey)?.activity, .idle)
        XCTAssertTrue(AgentDetector.scan(table: table, workingWindow: window).isEmpty)

        AgentDetector.recordActivity(forSurfaceKey: surfaceKey)
        _ = AgentDetector.scan(table: table, workingWindow: window)
        XCTAssertEqual(AgentDetector.snapshot(forSurfaceKey: surfaceKey)?.activity, .working)
        XCTAssertTrue(AgentDetector.scan(table: table, workingWindow: window).isEmpty)

        Thread.sleep(forTimeInterval: 1.2)
        _ = AgentDetector.scan(table: table, workingWindow: window)
        XCTAssertEqual(AgentDetector.snapshot(forSurfaceKey: surfaceKey)?.activity, .idle)
        XCTAssertTrue(AgentDetector.scan(table: table, workingWindow: window).isEmpty)
    }

    /// Regression: native Claude Code installs symlink `claude` to a version-numbered
    /// binary (e.g. .../versions/2.1.152), so `proc_pidpath`'s lastPathComponent is the
    /// version, not "claude". Detection must still match via argv[0] — that's what
    /// `matchesAny` is for.
    func testEntryMatchesAnyFindsAgentByInvocationName() {
        let entry = AgentTableEntry(kind: .claudeCode, executables: ["claude", "claude-code"])
        // Real-world: proc_pidpath -> .../versions/2.1.152, argv[0] basename -> "claude".
        let candidates: Set<String> = ["2.1.152", "claude"]
        XCTAssertTrue(entry.matchesAny(candidates))

        // Nothing in the set matches → no false positive.
        XCTAssertFalse(entry.matchesAny(["node", "2.1.152", "cli.js"]))

        // The default table's claudeCode entry has the same coverage.
        let defaultEntry = AgentTable.default.entries.first { $0.kind == .claudeCode }
        XCTAssertNotNil(defaultEntry)
        XCTAssertTrue(defaultEntry?.matchesAny(["2.1.152", "claude"]) ?? false)
    }

    func testDefaultTableResolvesOpenCodeExecutable() throws {
        let entry = try XCTUnwrap(AgentTable.default.entries.first { $0.matches(executable: "opencode") })
        XCTAssertEqual(entry.kind, .openCode)
        XCTAssertTrue(entry.matchesAny(["opencode"]))
    }

    func testHermesPythonScriptTUILaunchMatchesScriptArgument() throws {
        let entry = try XCTUnwrap(AgentTable.default.entries.first { $0.kind == .hermes })
        XCTAssertTrue(entry.matchesProcess(
            resolvedExecutable: "/Users/me/.hermes/hermes-agent/venv/bin/python3",
            arguments: [
                "/Users/me/.hermes/hermes-agent/venv/bin/python3",
                "/Users/me/.local/bin/hermes",
                "--tui",
            ]
        ))
        XCTAssertFalse(entry.matchesProcess(
            resolvedExecutable: "/Users/me/.hermes/hermes-agent/venv/bin/python3",
            arguments: [
                "/Users/me/.hermes/hermes-agent/venv/bin/python3",
                "/Users/me/project/not-hermes.py",
                "--provider",
                "hermes",
            ]
        ))
        XCTAssertFalse(entry.matchesProcess(
            resolvedExecutable: "/usr/bin/python3",
            arguments: [
                "/usr/bin/python3",
                "/Users/me/project/tool.py",
                "/tmp/hermes",
            ]
        ))
        XCTAssertFalse(entry.matchesProcess(
            resolvedExecutable: "/usr/bin/vim",
            arguments: [
                "vim",
                "/tmp/hermes",
            ]
        ))
    }

    func testWrapperLaunchMatchingSkipsInterpreterOptions() {
        let entry = AgentTableEntry(kind: .hermes, executables: ["hermes"])
        XCTAssertTrue(entry.matchesProcess(
            resolvedExecutable: "/usr/bin/env",
            arguments: [
                "/usr/bin/env",
                "HERMES_TUI=1",
                "python3",
                "/Users/me/.local/bin/hermes",
                "--tui",
            ]
        ))
        XCTAssertFalse(entry.matchesProcess(
            resolvedExecutable: "/usr/bin/python3",
            arguments: [
                "/usr/bin/python3",
                "-c",
                "print('hello')",
                "/tmp/hermes",
            ]
        ))
        XCTAssertTrue(entry.matchesProcess(
            resolvedExecutable: "/usr/bin/python3",
            arguments: [
                "/usr/bin/python3",
                "-m",
                "hermes",
                "--tui",
            ]
        ))
        XCTAssertFalse(entry.matchesProcess(
            resolvedExecutable: "/usr/bin/python3",
            arguments: [
                "/usr/bin/python3",
                "-m",
                "pytest",
                "/tmp/hermes",
            ]
        ))
    }

    func testJavaScriptWrappersCanLaunchHermesTUI() {
        let entry = AgentTableEntry(kind: .hermes, executables: ["hermes"])
        XCTAssertTrue(entry.matchesProcess(
            resolvedExecutable: "/usr/local/bin/deno",
            arguments: [
                "/usr/local/bin/deno",
                "run",
                "--allow-read",
                "/Users/me/.local/bin/hermes",
                "--tui",
            ]
        ))
        XCTAssertTrue(entry.matchesProcess(
            resolvedExecutable: "/opt/homebrew/bin/bun",
            arguments: [
                "/opt/homebrew/bin/bun",
                "run",
                "/Users/me/.local/bin/hermes",
                "--tui",
            ]
        ))
    }

    /// Title-based fallback for when the daemon proc-tree scan can't see the
    /// agent (the case the user reported: Claude Code shown as raw text in
    /// the sidebar instead of a chip).
    func testTitleInferenceRecognizesClaudeCodeWithLeadingGlyphs() {
        XCTAssertEqual(AgentTitleInference.kind(from: "* Claude Code"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "✱ Claude Code"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "✻ Claude"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "✶ Claude"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "  Claude Code"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "Claude Code"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "Claude"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "Claude-Code v2.1"), .claudeCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "claude: working…"), .claudeCode)
    }

    func testTitleInferenceRecognizesOtherAgents() {
        XCTAssertEqual(AgentTitleInference.kind(from: "Codex"), .codex)
        XCTAssertEqual(AgentTitleInference.kind(from: "• Codex"), .codex)
        XCTAssertEqual(AgentTitleInference.kind(from: "Cursor Agent"), .cursor)
        XCTAssertEqual(AgentTitleInference.kind(from: "Cursor — main.swift"), .cursor)
        XCTAssertEqual(AgentTitleInference.kind(from: "Aider"), .aider)
        XCTAssertEqual(AgentTitleInference.kind(from: "Gemini-CLI"), .gemini)
        XCTAssertEqual(AgentTitleInference.kind(from: "goose run"), .goose)
        XCTAssertEqual(AgentTitleInference.kind(from: "Hermes"), .hermes)
        XCTAssertEqual(AgentTitleInference.kind(from: "Hermes Agent"), .hermes)
        XCTAssertEqual(AgentTitleInference.kind(from: "Hermes TUI"), .hermes)
        XCTAssertEqual(AgentTitleInference.kind(from: "Grok"), .grok)
        XCTAssertEqual(AgentTitleInference.kind(from: "✱ Grok"), .grok)
        XCTAssertEqual(AgentTitleInference.kind(from: "Grok Build"), .grok)
        XCTAssertEqual(AgentTitleInference.kind(from: "OpenCode"), .openCode)
        XCTAssertEqual(AgentTitleInference.kind(from: "opencode session"), .openCode)
    }

    /// Grok Build is detected by its binary names (`grok`, `grok-build`, `grok-cli`).
    func testEntryMatchesGrokExecutables() throws {
        let entry = try XCTUnwrap(AgentTable.default.entries.first { $0.kind == .grok })
        XCTAssertTrue(entry.matchesAny(["grok"]))
        XCTAssertTrue(entry.matchesAny(["grok-build"]))
        XCTAssertTrue(entry.matchesAny(["grok-cli"]))
        XCTAssertFalse(entry.matchesAny(["grokking", "node"]))
    }

    /// Inference must NOT match partial words inside chatty shell titles —
    /// otherwise `vim claude.txt` or "agenda.md" would light up the wrong chip.
    func testTitleInferenceRejectsPartialAndGenericMatches() {
        XCTAssertNil(AgentTitleInference.kind(from: "vim claude.txt"))
        XCTAssertNil(AgentTitleInference.kind(from: "claudette"))
        XCTAssertNil(AgentTitleInference.kind(from: "cursors and selections"))
        XCTAssertNil(AgentTitleInference.kind(from: "agenda.md"))
        XCTAssertNil(AgentTitleInference.kind(from: "pip install requests"))
        XCTAssertNil(AgentTitleInference.kind(from: ""))
        XCTAssertNil(AgentTitleInference.kind(from: "   "))
        XCTAssertNil(AgentTitleInference.kind(from: "Shell"))
    }

    // MARK: - resolveDetection (P38 Phase B — subagent grouping, pure logic, no real processes)

    /// A parent Claude Code process spawns a nested child Claude Code process (e.g. a Task-tool
    /// subprocess shell-out). Primary must be the shallower (user-launched) one; the deeper match
    /// becomes a subagent tagged with the primary's pid as its parent.
    func testResolveDetectionNestedSameKindPicksShallowerAsPrimary() {
        let matches: [AgentDetector.RawMatch] = [
            .init(pid: 200, depth: 1, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
            .init(pid: 100, depth: 0, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
        ]
        let parentMap: [Int32: Int32] = [200: 100]
        let result = AgentDetector.resolveDetection(from: matches, parentMap: parentMap)

        XCTAssertEqual(result.primary?.pid, 100)
        XCTAssertEqual(result.subagents.count, 1)
        XCTAssertEqual(result.subagents.first?.pid, 200)
        XCTAssertEqual(result.subagents.first?.parentPID, 100)
    }

    /// `bun run claude` — the wrapper (`bun`, depth 0) and its launch target (`claude`, depth 1,
    /// a child of bun) both match the claudeCode entry. The wrapper must be collapsed away so this
    /// reports ONE agent, not a phantom wrapper+target pair.
    func testResolveDetectionCollapsesWrapperLaunchingItsOwnTarget() {
        let matches: [AgentDetector.RawMatch] = [
            .init(pid: 10, depth: 0, kind: .claudeCode, executable: "/usr/bin/bun", source: .wrapperLaunch),
            .init(pid: 11, depth: 1, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
        ]
        let parentMap: [Int32: Int32] = [11: 10]
        let result = AgentDetector.resolveDetection(from: matches, parentMap: parentMap)

        XCTAssertEqual(result.primary?.pid, 11)
        XCTAssertTrue(result.subagents.isEmpty)
    }

    /// Two same-depth matches must resolve deterministically regardless of input order — lower
    /// pid wins the tie-break, so a re-scan of an unchanged tree never flaps between them.
    func testResolveDetectionTieBreaksOnLowerPIDDeterministically() {
        let ascending: [AgentDetector.RawMatch] = [
            .init(pid: 50, depth: 0, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
            .init(pid: 60, depth: 0, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
        ]
        let descending: [AgentDetector.RawMatch] = ascending.reversed()

        XCTAssertEqual(AgentDetector.resolveDetection(from: ascending, parentMap: [:]).primary?.pid, 50)
        XCTAssertEqual(AgentDetector.resolveDetection(from: descending, parentMap: [:]).primary?.pid, 50)
    }

    /// A subagent's `parentPID` should point at the nearest OTHER matched ancestor, not
    /// necessarily the root primary — e.g. primary → subagent A → subagent B should tag B's
    /// parent as A, not primary.
    func testResolveDetectionTagsNearestMatchedAncestorNotRoot() {
        let matches: [AgentDetector.RawMatch] = [
            .init(pid: 1, depth: 0, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
            .init(pid: 2, depth: 1, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
            .init(pid: 3, depth: 2, kind: .claudeCode, executable: "/usr/bin/claude", source: .ownProcess),
        ]
        // Chain: 1 (unmatched intermediate shell) -> not present; 2's parent is 1, 3's parent is 2.
        let parentMap: [Int32: Int32] = [2: 1, 3: 2]
        let result = AgentDetector.resolveDetection(from: matches, parentMap: parentMap)

        XCTAssertEqual(result.primary?.pid, 1)
        let subagentB = result.subagents.first { $0.pid == 3 }
        XCTAssertEqual(subagentB?.parentPID, 2)
    }

    func testResolveDetectionEmptyInputReturnsEmptyDetection() {
        let result = AgentDetector.resolveDetection(from: [], parentMap: [:])
        XCTAssertNil(result.primary)
        XCTAssertTrue(result.subagents.isEmpty)
    }
}
