import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// Integration tests for Automation IPC (P41) via SurfaceRegistry.handle() directly,
/// same pattern as TaskIPCDaemonTests — no socket, real KOUEN_HOME sandbox.
final class AutomationIPCDaemonTests: XCTestCase {
    private var root: URL!
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-automation-daemon-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        try? FileManager.default.removeItem(at: root)
    }

    func testCreateListGetUpdatePauseResumeDeleteRoundTripViaIPC() throws {
        let registry = SurfaceRegistry()

        guard case let .automationInfo(created?) = registry.handle(.automationCreate(
            repoPath: root.path, workspaceID: nil, agent: "claude", prompt: "ทำต่อ p40", intervalMinutes: 60
        )) else {
            return XCTFail("Expected .automationInfo from automationCreate")
        }
        XCTAssertEqual(created.prompt, "ทำต่อ p40")
        XCTAssertTrue(created.enabled)

        guard case let .automations(list) = registry.handle(.automationList) else {
            return XCTFail("Expected .automations from automationList")
        }
        XCTAssertEqual(list.count, 1)

        guard case let .automationInfo(fetched?) = registry.handle(.automationGet(id: created.id)) else {
            return XCTFail("Expected .automationInfo from automationGet")
        }
        XCTAssertEqual(fetched.id, created.id)

        guard case let .automationInfo(updated?) = registry.handle(.automationUpdate(
            id: created.id, repoPath: nil, agent: nil, prompt: "ทำต่อ p41", intervalMinutes: nil
        )) else {
            return XCTFail("Expected .automationInfo from automationUpdate")
        }
        XCTAssertEqual(updated.prompt, "ทำต่อ p41")

        guard case let .automationInfo(paused?) = registry.handle(.automationSetEnabled(id: created.id, enabled: false)) else {
            return XCTFail("Expected .automationInfo from pause")
        }
        XCTAssertFalse(paused.enabled)

        guard case let .automationInfo(resumed?) = registry.handle(.automationSetEnabled(id: created.id, enabled: true)) else {
            return XCTFail("Expected .automationInfo from resume")
        }
        XCTAssertTrue(resumed.enabled)

        guard case .ok = registry.handle(.automationDelete(id: created.id)) else {
            return XCTFail("Expected .ok from automationDelete")
        }
        guard case let .automationInfo(gone) = registry.handle(.automationGet(id: created.id)) else {
            return XCTFail("Expected .automationInfo from automationGet after delete")
        }
        XCTAssertNil(gone)
    }

    func testUpdateAndDeleteOnMissingIDReturnsError() {
        let registry = SurfaceRegistry()
        guard case .error = registry.handle(.automationUpdate(
            id: UUID(), repoPath: nil, agent: nil, prompt: "nope", intervalMinutes: nil
        )) else {
            return XCTFail("Expected .error from automationUpdate on missing id")
        }
        guard case .error = registry.handle(.automationDelete(id: UUID())) else {
            return XCTFail("Expected .error from automationDelete on missing id")
        }
    }

    func testRunNowSpawnsSessionAndRecordsRun() throws {
        let registry = SurfaceRegistry()
        guard case let .automationInfo(created?) = registry.handle(.automationCreate(
            repoPath: root.path, workspaceID: nil, agent: "claude", prompt: "hello", intervalMinutes: 0
        )) else {
            return XCTFail("Expected .automationInfo from automationCreate")
        }

        guard case .ok = registry.handle(.automationRunNow(id: created.id)) else {
            return XCTFail("Expected .ok from automationRunNow")
        }

        guard case let .automationInfo(fired?) = registry.handle(.automationGet(id: created.id)) else {
            return XCTFail("Expected .automationInfo from automationGet after runNow")
        }
        XCTAssertEqual(fired.lastRunStatus, "ok")
        XCTAssertNotNil(fired.lastRunAt)

        guard case let .surfaces(surfaces) = registry.handle(.listSurfaces) else {
            return XCTFail("Expected .surfaces from listSurfaces")
        }
        XCTAssertTrue(surfaces.count >= 1, "runNow should have spawned at least one surface")
    }

    func testRunNowOnMissingIDReturnsError() {
        let registry = SurfaceRegistry()
        guard case .error = registry.handle(.automationRunNow(id: UUID())) else {
            return XCTFail("Expected .error from automationRunNow on missing id")
        }
    }
}
