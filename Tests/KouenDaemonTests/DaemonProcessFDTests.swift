#if os(macOS)
import XCTest
import KouenCore
@testable import KouenDaemonCore

final class DaemonProcessFDTests: XCTestCase {
    private let repetitions = 12
    private var testHome: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let home = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-process-fds-\(UUID().uuidString)")
        testHome = home
        setenv("KOUEN_HOME", home.path, 1)
        try KouenPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let testHome { try FileManager.default.removeItem(at: testHome) }
    }

    private func openFDs() throws -> Int {
        try FileManager.default.contentsOfDirectory(atPath: "/dev/fd").count
    }

    func test_TS_2311_BE_IT_mobileBridgeCaptureClosesFDs() throws {
        let echo = URL(fileURLWithPath: "/bin/echo")
        _ = MobileBridgeServer.runProcess(executableURL: echo, arguments: ["warmup"], timeoutSeconds: 5)
        let before = try openFDs()
        try autoreleasepool {
            for _ in 0..<repetitions {
                let success = MobileBridgeServer.runProcess(executableURL: echo, arguments: ["ok"], timeoutSeconds: 5)
                XCTAssertEqual(success.stdout, "ok\n")
                let failure = MobileBridgeServer.runProcess(
                    executableURL: URL(fileURLWithPath: "/no-such-executable"),
                    arguments: [], timeoutSeconds: 5)
                XCTAssertEqual(failure.status, -1)
                let timeout = MobileBridgeServer.runProcess(
                    executableURL: URL(fileURLWithPath: "/bin/sleep"),
                    arguments: ["2"], timeoutSeconds: 0.03)
                XCTAssertTrue(timeout.timedOut)
            }
            XCTAssertLessThanOrEqual(try openFDs(), before)
        }
    }

    func test_TS_2312_BE_IT_catalogAndExecutableLookupCloseFDs() throws {
        let script = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-models-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: script) }
        try Data("#!/bin/sh\nprintf 'demo-high\\tDemo (High)\\n'\n".utf8).write(to: script)
        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: script.path)
        _ = AgyModelCatalog.load(executable: script.path)
        _ = AgentRemoteControlDaemonService.resolveExecutable(named: script.path)
        let before = try openFDs()
        try autoreleasepool {
            for _ in 0..<repetitions {
                XCTAssertEqual(AgyModelCatalog.load(executable: script.path)?.efforts, ["high"])
                XCTAssertNil(AgyModelCatalog.load(executable: script.path + "-missing"))
                XCTAssertEqual(AgentRemoteControlDaemonService.resolveExecutable(named: script.path), script.path)
                XCTAssertNil(AgentRemoteControlDaemonService.resolveExecutable(named: script.path + "-missing"))
            }
            XCTAssertLessThanOrEqual(try openFDs(), before)
        }
    }

    func test_TS_2313_BE_IT_headlessProbeAndStreamingCloseFDs() async throws {
        let harness = ClaudeCodeHarness(adapters: [ShellAdapter()])
        let cwd = FileManager.default.temporaryDirectory.path
        func run(cwd: String, prompt: String = "") async -> ClaudeCodeHarness.RunSummary {
            await harness.start(
                id: UUID(), prompt: prompt, cwd: cwd, profile: .readonly,
                model: nil, effort: nil, resumeSessionID: nil)
        }

        let clock = ContinuousClock()
        func waitForCompletion(id: UUID) async -> ClaudeCodeHarness.RunSummary? {
            let deadline = clock.now + .seconds(5)
            while clock.now < deadline {
                if let result = await harness.get(id: id), result.exitCode != nil { return result }
                try? await Task.sleep(for: .milliseconds(5))
            }
            return nil
        }

        let warmup = await run(cwd: cwd)
        let completed = await waitForCompletion(id: warmup.id)
        XCTAssertEqual(completed?.resultText, "complete")
        let before = try openFDs()
        for _ in 0..<repetitions {
            let probe = await harness.runProbe(shellPath: "/bin/sh", command: "printf probe")
            XCTAssertEqual(probe, "probe")
            let missing = await harness.runProbe(shellPath: "/no-such-shell", command: "printf probe")
            XCTAssertNil(missing)
            let runResult = await run(cwd: cwd)
            let result = await waitForCompletion(id: runResult.id)
            XCTAssertEqual(result?.exitCode, 0)
            XCTAssertEqual(result?.resultText, "complete")
            let failed = await run(cwd: cwd + "/\(UUID())")
            XCTAssertEqual(failed.state, .failed)
            let cancellable = await run(cwd: cwd, prompt: "wait")
            let cancelled = await harness.cancel(id: cancellable.id)
            XCTAssertTrue(cancelled)
            let cancelledResult = await waitForCompletion(id: cancellable.id)
            XCTAssertEqual(cancelledResult?.state, .cancelled)
        }
        let inherited = await run(cwd: cwd, prompt: "inherited")
        let inheritedResult = await waitForCompletion(id: inherited.id)
        XCTAssertEqual(inheritedResult?.resultText, "complete")
        XCTAssertLessThanOrEqual(try openFDs(), before)
    }

    func test_TS_2315_BE_IT_headlessCancelKillsTermIgnoringChild() async throws {
        let harness = ClaudeCodeHarness(adapters: [ShellAdapter()])
        let id = UUID()
        let run = await harness.start(
            id: id, prompt: "ignore-term", cwd: try XCTUnwrap(testHome).path,
            profile: .readonly, model: nil, effort: nil, resumeSessionID: nil)
        XCTAssertEqual(run.state, .running)

        let readyDeadline = ContinuousClock.now + .seconds(5)
        var ready = false
        while ContinuousClock.now < readyDeadline {
            if await harness.get(id: id)?.lastAssistantText == "ready" {
                ready = true
                break
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertTrue(ready, "Child must install its TERM trap before cancellation")
        let cancelled = await harness.cancel(id: id)
        XCTAssertTrue(cancelled)

        let exitDeadline = ContinuousClock.now + .seconds(5)
        while ContinuousClock.now < exitDeadline {
            if let result = await harness.get(id: id), let code = result.exitCode {
                XCTAssertEqual(result.state, .cancelled)
                XCTAssertEqual(code, SIGKILL)
                return
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Cancelled child did not exit")
    }

    func test_TS_2314_BE_IT_surfaceHookAndPanePipeCloseFDs() async throws {
        try skipUnlessLiveDaemonTests()
        let registry = SurfaceRegistry()
        defer { registry.stopMonitoring() }
        guard case let .surfaces(surfaces) = registry.handle(.listSurfaces),
              let surface = surfaces.first else {
            return XCTFail("Expected a surface")
        }
        let before = try openFDs()
        for _ in 0..<repetitions {
            guard case .ok = registry.handle(.pipePane(surfaceID: surface.surfaceID, shellCommand: "exec /bin/cat >/dev/null")),
                  case .ok = registry.handle(.pipePane(surfaceID: surface.surfaceID, shellCommand: nil)) else {
                return XCTFail("Expected to start and stop pipe-pane")
            }
        }
        for index in 0..<repetitions {
            let command = "printf '\\377\(index)'"
            registry.runShellForHook(command, captureToBuffer: true)
            let expected = Data([255] + Array(String(index).utf8))
            let deadline = ContinuousClock.now + .seconds(5)
            var captured = false
            while ContinuousClock.now < deadline {
                if case let .buffer(buffer) = registry.handle(.getBuffer(name: nil)), buffer.data == expected {
                    captured = true
                    break
                }
                try? await Task.sleep(for: .milliseconds(5))
            }
            XCTAssertTrue(captured, "hook capture did not deliver iteration \(index)")
        }
        XCTAssertLessThanOrEqual(try openFDs(), before)
    }
}

private struct ShellAdapter: HeadlessCLIAdapter {
    let agentKind: AgentKind = .claudeCode
    let binaryName = "sh"
    let candidateBinaryPaths = ["/bin/sh"]

    func probeCommand(shellPath: String) -> String { "printf /bin/sh" }

    func buildArguments(
        id: UUID, prompt: String, profile: ClaudeCodeHarness.Profile,
        model: String?, effort: String?, resumeSessionID: UUID?
    ) -> [String] {
        if prompt == "ignore-term" {
            return ["-c", "trap '' TERM; printf 'ready\\n'; exec /bin/sleep 8"]
        }
        if prompt == "wait" { return ["-c", "exec /bin/sleep 30"] }
        if prompt == "inherited" { return ["-c", "/bin/sleep 6 & printf 'complete\\n'"] }
        return ["-c", "/bin/dd if=/dev/zero bs=65536 count=4 >&2; printf 'complete\\n'"]
    }

    func parseLine(_ lineData: Data) -> [HeadlessRunEvent] {
        let text = String(decoding: lineData, as: UTF8.self)
        if text == "ready" { return [.assistantText(text)] }
        return [.result(text: text, costUSD: nil, isError: false)]
    }
}
#endif
