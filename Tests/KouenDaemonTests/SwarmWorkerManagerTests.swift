import XCTest
@testable import KouenDaemonCore

/// Records what `SwarmWorkerManager`'s injected closures were called with, for assertions.
/// `@unchecked Sendable` + `NSLock` — same pattern `RealPty`/`SurfaceRegistry` already use for
/// state shared across a sync closure call and the test's own thread.
private final class CallRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _harnessCalls: [(id: UUID, prompt: String, cwd: String, resume: UUID?)] = []
    private var _surfaceCalls: [(surfaceID: String, text: String)] = []
    private var _closeCalls: [String] = []
    private var _cancelCalls: [UUID] = []
    private var _harnessSummaries: [UUID: ClaudeCodeHarness.RunSummary] = [:]

    func recordHarness(id: UUID, prompt: String, cwd: String, resume: UUID? = nil) {
        lock.lock(); _harnessCalls.append((id, prompt, cwd, resume)); lock.unlock()
    }
    /// Lets a test control what `getHarnessRun(id)` reports, to exercise
    /// `SwarmWorkerManager`'s completion-poll loop deterministically.
    func setHarnessSummary(_ id: UUID, _ summary: ClaudeCodeHarness.RunSummary) {
        lock.lock(); _harnessSummaries[id] = summary; lock.unlock()
    }
    func harnessSummary(_ id: UUID) -> ClaudeCodeHarness.RunSummary? {
        lock.lock(); defer { lock.unlock() }; return _harnessSummaries[id]
    }
    func recordSurface(_ surfaceID: String, _ text: String) {
        lock.lock(); _surfaceCalls.append((surfaceID, text)); lock.unlock()
    }
    func recordClose(_ surfaceID: String) {
        lock.lock(); _closeCalls.append(surfaceID); lock.unlock()
    }
    func recordCancel(_ id: UUID) {
        lock.lock(); _cancelCalls.append(id); lock.unlock()
    }

    var harnessCalls: [(id: UUID, prompt: String, cwd: String, resume: UUID?)] { lock.lock(); defer { lock.unlock() }; return _harnessCalls }
    var surfaceCalls: [(surfaceID: String, text: String)] { lock.lock(); defer { lock.unlock() }; return _surfaceCalls }
    var closeCalls: [String] { lock.lock(); defer { lock.unlock() }; return _closeCalls }
    var cancelCalls: [UUID] { lock.lock(); defer { lock.unlock() }; return _cancelCalls }
}

final class SwarmWorkerManagerTests: XCTestCase {
    private func makeManager(
        recorder: CallRecorder,
        surfaceID: String? = "fakeSurfaceID",
        cancelResult: Bool = true,
        harnessRunTimeout: Duration = .seconds(180)
    ) -> SwarmWorkerManager {
        SwarmWorkerManager(
            dagStore: SwarmDAGStore(),
            createPTYSurface: { _ in surfaceID },
            sendToSurface: { sid, text in recorder.recordSurface(sid, text) },
            closeSurface: { sid in recorder.recordClose(sid) },
            startHarnessRun: { id, _, prompt, cwd, resume in
                recorder.recordHarness(id: id, prompt: prompt, cwd: cwd, resume: resume)
                return ClaudeCodeHarness.RunSummary(id: id, state: .running, cwd: cwd, startedAt: Date())
            },
            cancelHarnessRun: { id in
                recorder.recordCancel(id)
                return cancelResult
            },
            getHarnessRun: { id in
                recorder.harnessSummary(id)
            },
            harnessRunTimeout: harnessRunTimeout
        )
    }

    func testSpawnStructuredRecordsWorkingNodeAndCallsHarness() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))

        XCTAssertEqual(node.lane, .structured)
        XCTAssertEqual(node.status, .working)
        XCTAssertNil(node.surfaceID)
        XCTAssertEqual(recorder.harnessCalls.count, 1)
        XCTAssertEqual(recorder.harnessCalls[0].prompt, "hello")
        XCTAssertEqual(recorder.harnessCalls[0].cwd, "/tmp")
        let snapshot = await manager.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 1)
    }

    func testSpawnPTYCreatesSurfaceSendsInitialCommandAndRecordsSpawningNode() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .pty, agentKind: .codex, cwd: nil, initialCommand: "codex\n"))

        XCTAssertEqual(node.lane, .pty)
        XCTAssertEqual(node.status, .spawning)
        XCTAssertEqual(node.surfaceID, "fakeSurfaceID")
        XCTAssertEqual(recorder.surfaceCalls.count, 1)
        XCTAssertEqual(recorder.surfaceCalls[0].surfaceID, "fakeSurfaceID")
        XCTAssertEqual(recorder.surfaceCalls[0].text, "codex\n")
    }

    func testSpawnPTYWhenSurfaceCreationFailsRecordsFailedNode() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder, surfaceID: nil)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .pty, agentKind: .codex, cwd: nil, initialCommand: "codex\n"))

        XCTAssertEqual(node.lane, .pty)
        XCTAssertEqual(node.status, .failed)
        XCTAssertNil(node.surfaceID)
        XCTAssertNotNil(node.summary)
        XCTAssertEqual(recorder.surfaceCalls.count, 0)
    }

    func test_TS0011_sendToPTYWorkerTypesTextAndSetsWorking() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .pty, agentKind: .codex, cwd: nil, initialCommand: "codex\n"))

        let result = await manager.send(taskID: node.id, text: "do the thing")
        XCTAssertTrue(result)
        XCTAssertEqual(recorder.surfaceCalls.count, 2)
        XCTAssertEqual(recorder.surfaceCalls[1].surfaceID, "fakeSurfaceID")
        XCTAssertEqual(recorder.surfaceCalls[1].text, "do the thing")

        let snapshot = await manager.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 1)
        XCTAssertEqual(snapshot.nodes[0].status, .working)
    }

    func test_TS0007_sendToStillRunningStructuredWorkerReturnsFalse() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))

        let result = await manager.send(taskID: node.id, text: "do the thing")
        XCTAssertFalse(result)
        XCTAssertEqual(recorder.harnessCalls.count, 1, "no follow-up run while the first is still running")
    }

    func test_TS0009_sendToUnknownTaskIDReturnsFalse() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let result = await manager.send(taskID: UUID(), text: "do the thing")
        XCTAssertFalse(result)
    }

    func testTerminatePTYWorkerClosesSurfaceAndMarksCancelled() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .pty, agentKind: .codex, cwd: nil, initialCommand: "codex\n"))

        let result = await manager.terminate(taskID: node.id)
        XCTAssertTrue(result)
        XCTAssertEqual(recorder.closeCalls, ["fakeSurfaceID"])

        let snapshot = await manager.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 1)
        XCTAssertEqual(snapshot.nodes[0].status, .cancelled)
    }

    func testTerminateStructuredWorkerCallsCancelHarnessAndMarksCancelledOnSuccess() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder, cancelResult: true)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))

        let result = await manager.terminate(taskID: node.id)
        XCTAssertTrue(result)
        let snapshot = await manager.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 1)
        XCTAssertEqual(snapshot.nodes[0].status, .cancelled)
    }

    func testTerminateStructuredWorkerLeavesStatusAloneWhenCancelHarnessReturnsFalse() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder, cancelResult: false)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))

        let result = await manager.terminate(taskID: node.id)
        XCTAssertFalse(result)
        let snapshot = await manager.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 1)
        XCTAssertEqual(snapshot.nodes[0].status, .working, "an unsuccessful cancel must not overwrite the node's existing status")
    }

    func testTerminateUnknownTaskIDReturnsFalse() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder, cancelResult: false)
        let result = await manager.terminate(taskID: UUID())
        XCTAssertFalse(result)
    }

    /// Regression test for a real bug found during this feature's first live-daemon check
    /// (2026-09-14): a Lane A node sat at `.working` forever because nothing ever synced the
    /// DAG store once the underlying harness run actually finished. `spawn()` fires a
    /// background poll (`pollForCompletion`) that must pick up a terminal state and write it
    /// (plus the run's `resultText`) back into the snapshot.
    func testStructuredWorkerSyncsToSucceededOnceHarnessRunCompletes() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))
        recorder.setHarnessSummary(node.id, ClaudeCodeHarness.RunSummary(
            id: node.id, state: .succeeded, cwd: "/tmp", startedAt: Date(), resultText: "the answer"
        ))

        // The poll loop ticks every 500ms; give it two ticks of headroom rather than pinning
        // to the exact interval.
        try? await Task.sleep(for: .milliseconds(1100))

        let snapshot = await manager.snapshot()
        let updated = snapshot.nodes.first { $0.id == node.id }
        XCTAssertEqual(updated?.status, .succeeded)
        XCTAssertEqual(updated?.summary, "the answer")
    }

    /// Regression test for a real bug found live (2026-09-14): a real headless `copilot`
    /// invocation hung indefinitely with no response (reproduced independently of Kouen,
    /// an external-CLI flakiness issue) — a fleet node stayed `.working` forever with no way
    /// to notice. `pollForCompletion` now has a hard wall-clock ceiling; verified here with a
    /// tiny injected timeout instead of waiting on the real 180s default.
    func testStructuredWorkerTimesOutAndCancelsWhenHarnessRunNeverCompletes() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder, cancelResult: true, harnessRunTimeout: .milliseconds(600))
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))
        // Stays `.running` forever from the fake harness's point of view — simulates the real hang.
        recorder.setHarnessSummary(node.id, ClaudeCodeHarness.RunSummary(id: node.id, state: .running, cwd: "/tmp", startedAt: Date()))

        try? await Task.sleep(for: .milliseconds(1600))

        XCTAssertEqual(recorder.cancelCalls, [node.id])
        let snapshot = await manager.snapshot()
        let updated = snapshot.nodes.first { $0.id == node.id }
        XCTAssertEqual(updated?.status, .failed)
        XCTAssertTrue(updated?.summary?.contains("timed out") ?? false, "summary was: \(String(describing: updated?.summary))")
    }

    // MARK: - Lane A follow-up turns (headless-worker-followup)

    private static let sessionID = UUID(uuidString: "227205dd-b2aa-4c46-af32-b6c4896bb4c4")!

    /// Polls `condition` until true or `timeout` — a wait-for-condition, not a fixed sleep.
    private func waitUntil(timeout: Duration = .seconds(3), _ condition: () async -> Bool) async -> Bool {
        let clock = ContinuousClock(); let end = clock.now + timeout
        while clock.now < end {
            if await condition() { return true }
            try? await Task.sleep(for: .milliseconds(50))
        }
        return false
    }

    private func status(_ manager: SwarmWorkerManager, _ id: UUID) async -> SwarmTaskStatus? {
        await manager.snapshot().nodes.first { $0.id == id }?.status
    }

    /// Spawns a structured worker whose first run has finished with a captured session id.
    private func finishedWorker(_ recorder: CallRecorder, _ manager: SwarmWorkerManager, sessionID: String? = sessionID.uuidString.lowercased()) async -> SwarmTaskNode {
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .codex, cwd: "/repo", initialCommand: "turn 1"))
        var done = ClaudeCodeHarness.RunSummary(id: node.id, state: .succeeded, cwd: "/repo", startedAt: Date(), resultText: "first")
        done.agentSessionID = sessionID
        recorder.setHarnessSummary(node.id, done)
        let synced = await waitUntil { await self.status(manager, node.id) == .succeeded }
        XCTAssertTrue(synced, "first run should sync to succeeded")
        return node
    }

    func test_TS0005_followUpStartsResumedRunWithCapturedSessionID() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await finishedWorker(recorder, manager)

        let sent = await manager.send(taskID: node.id, text: "turn 2")

        XCTAssertTrue(sent)
        XCTAssertEqual(recorder.harnessCalls.count, 2)
        let followUp = recorder.harnessCalls[1]
        XCTAssertEqual(followUp.prompt, "turn 2")
        XCTAssertEqual(followUp.cwd, "/repo")
        XCTAssertEqual(followUp.resume, Self.sessionID)
        XCTAssertNotEqual(followUp.id, node.id, "each turn gets its own harness run id")
        let working = await status(manager, node.id)
        XCTAssertEqual(working, .working)
    }

    func test_TS0006_followUpCompletionSyncsFromTheNewRun() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await finishedWorker(recorder, manager)
        _ = await manager.send(taskID: node.id, text: "turn 2")
        let runID = recorder.harnessCalls[1].id

        recorder.setHarnessSummary(runID, ClaudeCodeHarness.RunSummary(id: runID, state: .failed, cwd: "/repo", startedAt: Date(), resultText: "second"))

        let synced = await waitUntil { await self.status(manager, node.id) == .failed }
        XCTAssertTrue(synced)
        let summary = await manager.snapshot().nodes.first { $0.id == node.id }?.summary
        XCTAssertEqual(summary, "second")
    }

    func test_TS0008_followUpWithoutCapturedSessionIDReturnsFalse() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await finishedWorker(recorder, manager, sessionID: nil)

        let sent = await manager.send(taskID: node.id, text: "turn 2")

        XCTAssertFalse(sent)
        XCTAssertEqual(recorder.harnessCalls.count, 1)
    }

    func test_TS0010_terminateAfterFollowUpCancelsTheCurrentRun() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await finishedWorker(recorder, manager)
        _ = await manager.send(taskID: node.id, text: "turn 2")
        let runID = recorder.harnessCalls[1].id

        let terminated = await manager.terminate(taskID: node.id)

        XCTAssertTrue(terminated)
        XCTAssertEqual(recorder.cancelCalls.last, runID)
        let cancelled = await status(manager, node.id)
        XCTAssertEqual(cancelled, .cancelled)
    }
}
