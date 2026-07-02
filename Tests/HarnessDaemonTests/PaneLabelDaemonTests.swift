import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// P32: `IPCRequest.setPaneLabel` — a durable, agent/human-set purpose label on one pane
/// surface, distinct from `title` (OSC/program-driven, gets overwritten by the next shell
/// prompt). Drives the daemon directly (no socket), same style as WorktreeIsolationDaemonTests.
final class PaneLabelDaemonTests: XCTestCase {
    private var root: URL!
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-panelabel-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("HARNESS_HOME", dir.path, 1)
        try HarnessPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        try? FileManager.default.removeItem(at: root)
    }

    func testSetPaneLabelPersistsAndReadsBackViaSnapshot() throws {
        let registry = SurfaceRegistry()
        let (sessionID, surfaceID) = try makeSession(registry, name: "label-sess")

        let setResponse = registry.handle(.setPaneLabel(surfaceID: surfaceID.uuidString, label: "build"))
        guard case .ok = setResponse else { return XCTFail("Expected ok, got \(setResponse)") }

        XCTAssertEqual(try surface(registry, sessionID: sessionID, surfaceID: surfaceID).label, "build")
    }

    func testSetPaneLabelWithNilClearsIt() throws {
        let registry = SurfaceRegistry()
        let (sessionID, surfaceID) = try makeSession(registry, name: "label-clear")

        _ = registry.handle(.setPaneLabel(surfaceID: surfaceID.uuidString, label: "build"))
        _ = registry.handle(.setPaneLabel(surfaceID: surfaceID.uuidString, label: nil))

        XCTAssertNil(try surface(registry, sessionID: sessionID, surfaceID: surfaceID).label)
    }

    func testSetPaneLabelDoesNotAffectTitle() throws {
        let registry = SurfaceRegistry()
        let (sessionID, surfaceID) = try makeSession(registry, name: "label-vs-title")

        _ = registry.handle(.setPaneLabel(surfaceID: surfaceID.uuidString, label: "claude"))

        let updated = try surface(registry, sessionID: sessionID, surfaceID: surfaceID)
        XCTAssertEqual(updated.label, "claude")
        XCTAssertEqual(updated.title, "Shell", "label is a separate field from title — setting it must not touch title")
    }

    func testSetPaneLabelUnknownSurfaceReturnsError() throws {
        let registry = SurfaceRegistry()
        let response = registry.handle(.setPaneLabel(surfaceID: UUID().uuidString, label: "x"))
        guard case .error = response else { return XCTFail("Expected error, got \(response)") }
    }

    // MARK: - Helpers

    private func makeSession(_ registry: SurfaceRegistry, name: String) throws -> (sessionID: UUID, surfaceID: UUID) {
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else {
            throw XCTestError(.failureWhileWaiting)
        }
        let wsID = try XCTUnwrap(snap.workspaces.first?.id)

        let response = registry.handle(.newSession(workspaceID: wsID, cwd: "/tmp", name: name))
        guard case let .sessionID(sessionID) = response else {
            throw XCTestError(.failureWhileWaiting)
        }

        guard case let .snapshot(snap2) = registry.handle(.getSnapshot) else {
            throw XCTestError(.failureWhileWaiting)
        }
        let tab = try XCTUnwrap(snap2.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID })?.tabs.first)
        let surfaceID = try XCTUnwrap(tab.rootPane.surfaceID)
        return (sessionID, surfaceID)
    }

    private func surface(_ registry: SurfaceRegistry, sessionID: UUID, surfaceID: UUID) throws -> PaneSurface {
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else {
            throw XCTestError(.failureWhileWaiting)
        }
        let tab = try XCTUnwrap(snap.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID })?.tabs.first)
        let leaf = try XCTUnwrap(tab.rootPane.allLeaves().first)
        return try XCTUnwrap(leaf.surfaces.first(where: { $0.id == surfaceID }))
    }
}
