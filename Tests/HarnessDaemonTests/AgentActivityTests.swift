import XCTest
import HarnessCore
@testable import HarnessDaemonCore

final class AgentActivityTests: XCTestCase {
    func testRestoredGenerationIsReconciledBeforeWaitingForItsReusedPIDToExit() throws {
        let home = FileManager.default.temporaryDirectory.appendingPathComponent("hactivity-generation-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: home) }
        #if os(macOS)
        let protection = try HistoryProtection(keyMaterial: Data(repeating: 78, count: 32))
        #else
        let protection = HistoryProtection.system()
        #endif
        let store = ActivityStore(url: home.appendingPathComponent("activity.sqlite"), protection: protection)
        let hostID = UUID(), pid = ProcessInfo.processInfo.processIdentifier
        let current = try XCTUnwrap(ProcessScan.generation(pid))
        let run = AgentRun(hostID: hostID, surfaceID: UUID().uuidString,
            processGeneration: current + "-previous", pid: pid, provider: .codex)
        try store.save(run)
        let service = AgentActivityService(store: store, hostID: hostID)
        defer { try? service.suspend() }
        XCTAssertTrue(waitUntil { (try? store.run(run.id)?.process) == .exited })
        XCTAssertNil(service.currentRun(surfaceID: run.surfaceID))
        XCTAssertEqual(ProcessScan.generation(pid), current, "reconciliation must never signal the reused process")
    }

    func testAuthoritativeProfilePromotesTheObservedExecutionWithoutDuplicatingIt() throws {
        let home = FileManager.default.temporaryDirectory.appendingPathComponent("hactivity-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: home) }
        #if os(macOS)
        let protection = try HistoryProtection(keyMaterial: Data(repeating: 76, count: 32))
        #else
        let protection = HistoryProtection.system()
        #endif
        let store = ActivityStore(url: home.appendingPathComponent("activity.sqlite"), protection: protection)
        let service = AgentActivityService(store: store, hostID: UUID())
        defer { try? service.suspend() }
        let surface = UUID().uuidString, now = Date(), pid = ProcessInfo.processInfo.processIdentifier
        let generation = try XCTUnwrap(ProcessScan.generation(pid))
        service.observe(surfaceID: surface, paneID: nil, snapshot: AgentSnapshot(kind: .claudeCode, executable: "claude", pid: pid), at: now)
        service.drain()
        let initial = try XCTUnwrap(service.currentRun(surfaceID: surface))
        service.observeOSC(surfaceID: surface, state: "working", message: nil, sequence: 10); service.drain()
        let observation = try ProviderHookAdapter.parse(Data(#"{"hook_event_name":"Stop","session_id":"conversation","prompt_id":"turn"}"#.utf8), contract: .claude202610, at: now.addingTimeInterval(1))
        let report = HookReport(surfaceID: surface, senderPID: pid, profile: "work", observation: observation)
        let run = try service.report(report, paneID: nil, generation: generation, pid: pid, sequence: 20)
        XCTAssertEqual(run.id, initial.id); XCTAssertEqual(run.profile, "work"); XCTAssertEqual(run.profileSource, .hook)
        XCTAssertEqual(run.turn, .completed); XCTAssertEqual(run.process, .running)
        XCTAssertEqual(try store.list(activeOnly: true).runs.count, 1)
        _ = try service.report(report, paneID: nil, generation: generation, pid: pid, sequence: 20)
        XCTAssertEqual(try store.events(runID: run.id).filter { $0.kind == .turnCompleted }.count, 1)
        var conflicting = report; conflicting.profile = "different"
        XCTAssertThrowsError(try service.report(conflicting, paneID: nil, generation: generation, pid: pid, sequence: 21))
        XCTAssertEqual(try store.list(activeOnly: true).runs.count, 1)
        XCTAssertEqual(service.currentRun(surfaceID: surface)?.id, initial.id)
    }
    func testProcessExitIsRecordedAfterPaneObservationStops() throws {
        let home = FileManager.default.temporaryDirectory.appendingPathComponent("hactivity-exit-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: home) }
        #if os(macOS)
        let protection = try HistoryProtection(keyMaterial: Data(repeating: 77, count: 32))
        #else
        let protection = HistoryProtection.system()
        #endif
        let store = ActivityStore(url: home.appendingPathComponent("activity.sqlite"), protection: protection)
        let service = AgentActivityService(store: store, hostID: UUID())
        defer { try? service.suspend() }
        let process = Process(); process.executableURL = URL(fileURLWithPath: "/bin/sh")
        let input = Pipe()
        process.standardInput = input
        process.arguments = ["-c", "read -r gate; exit 7"]; try process.run()
        defer { try? input.fileHandleForWriting.close(); if process.isRunning { process.terminate(); process.waitUntilExit() } }
        let surface = UUID().uuidString
        service.observe(surfaceID: surface, paneID: nil, snapshot: AgentSnapshot(kind: .codex, executable: "codex", pid: process.processIdentifier))
        service.drain(); let run = try XCTUnwrap(service.currentRun(surfaceID: surface))
        let generation = try XCTUnwrap(ProcessScan.generation(process.processIdentifier))
        let observation = try ProviderHookAdapter.parse(Data(#"{"hook_event_name":"Stop","session_id":"later-conversation","turn_id":"later-turn","message":"Final hook status"}"#.utf8), contract: .codex202610)
        let updated = try service.report(HookReport(surfaceID: surface, senderPID: process.processIdentifier, profile: "work", observation: observation),
            paneID: nil, generation: generation, pid: process.processIdentifier, sequence: 20)
        XCTAssertEqual(updated.id, run.id)
        XCTAssertEqual(updated.profile, "work")
        XCTAssertEqual(updated.lastTurnID, "later-turn")
        XCTAssertEqual(updated.message, "Final hook status")
        try input.fileHandleForWriting.write(contentsOf: Data("exit\n".utf8))
        // No more pane scans, OSC events or hooks are delivered.
        process.waitUntilExit()
        let deadline = Date().addingTimeInterval(4)
        while service.currentRun(surfaceID: surface) != nil && Date() < deadline { Thread.sleep(forTimeInterval: 0.02) }
        XCTAssertNil(service.currentRun(surfaceID: surface))
        XCTAssertEqual(try store.run(run.id)?.process, .exited)
        let exited = try XCTUnwrap(store.run(run.id))
        XCTAssertEqual(exited.profile, updated.profile)
        XCTAssertEqual(exited.profileSource, updated.profileSource)
        XCTAssertEqual(exited.conversationID, updated.conversationID)
        XCTAssertEqual(exited.lastTurnID, updated.lastTurnID)
        XCTAssertEqual(exited.message, updated.message)
        XCTAssertEqual(exited.turn, updated.turn)
        XCTAssertEqual(try store.events(runID: run.id).filter { $0.kind == .processExited }.count, 1)
    }

}
