import XCTest
@testable import KouenDaemonCore

/// Records what `SwarmWorkerManager`'s injected closures were called with, for assertions.
/// `@unchecked Sendable` + `NSLock` — same pattern `RealPty`/`SurfaceRegistry` already use for
/// state shared across a sync closure call and the test's own thread.
private final class CallRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _harnessCalls: [(id: UUID, prompt: String, cwd: String)] = []
    private var _surfaceCalls: [(surfaceID: String, text: String)] = []
    private var _closeCalls: [String] = []
    private var _cancelCalls: [UUID] = []

    func recordHarness(id: UUID, prompt: String, cwd: String) {
        lock.lock(); _harnessCalls.append((id, prompt, cwd)); lock.unlock()
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

    var harnessCalls: [(id: UUID, prompt: String, cwd: String)] { lock.lock(); defer { lock.unlock() }; return _harnessCalls }
    var surfaceCalls: [(surfaceID: String, text: String)] { lock.lock(); defer { lock.unlock() }; return _surfaceCalls }
    var closeCalls: [String] { lock.lock(); defer { lock.unlock() }; return _closeCalls }
}

final class SwarmWorkerManagerTests: XCTestCase {
    private func makeManager(
        recorder: CallRecorder,
        surfaceID: String? = "fakeSurfaceID",
        cancelResult: Bool = true
    ) -> SwarmWorkerManager {
        SwarmWorkerManager(
            dagStore: SwarmDAGStore(),
            createPTYSurface: { _ in surfaceID },
            sendToSurface: { sid, text in recorder.recordSurface(sid, text) },
            closeSurface: { sid in recorder.recordClose(sid) },
            startHarnessRun: { id, _, prompt, cwd in
                recorder.recordHarness(id: id, prompt: prompt, cwd: cwd)
                return ClaudeCodeHarness.RunSummary(id: id, state: .running, cwd: cwd, startedAt: Date())
            },
            cancelHarnessRun: { id in
                recorder.recordCancel(id)
                return cancelResult
            }
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

    func testSendToPTYWorkerTypesTextAndSetsWorking() async {
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

    func testSendToStructuredWorkerReturnsFalse() async {
        let recorder = CallRecorder()
        let manager = makeManager(recorder: recorder)
        let node = await manager.spawn(SwarmSpawnSpec(lane: .structured, agentKind: .claudeCode, cwd: "/tmp", initialCommand: "hello"))

        let result = await manager.send(taskID: node.id, text: "do the thing")
        XCTAssertFalse(result)
    }

    func testSendToUnknownTaskIDReturnsFalse() async {
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
}
