import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// Grouped sessions through the daemon: `newSessionInGroup` IPC, window create/kill
/// propagation across members, and surface lifetime (shared PTYs survive while any
/// member references them; killing a window kills it group-wide). Isolated
/// `HARNESS_HOME`, same pattern as `SurfaceRegistryTests`.
final class GroupedSessionDaemonTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-group-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("HARNESS_HOME", dir.path, 1)
        try HarnessPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    private func sessions(_ registry: SurfaceRegistry) -> [SessionGroup] {
        registry.snapshot.workspaces.flatMap(\.sessions)
    }

    func testGroupedSessionLifecycleThroughIPC() throws {
        try skipUnlessLiveDaemonTests()
        let registry = SurfaceRegistry()
        let original = try XCTUnwrap(sessions(registry).first)
        let originalSurfaces = Set(original.tabs.flatMap { $0.rootPane.allSurfaceIDs().map(\.uuidString) })

        // Group a member with the seeded session: shared window list, same live surfaces.
        guard case let .sessionID(memberID) = registry.handle(.newSessionInGroup(targetSessionID: original.id, name: "mirror")) else {
            return XCTFail("expected sessionID")
        }
        let member = try XCTUnwrap(sessions(registry).first { $0.id == memberID })
        XCTAssertEqual(
            Set(member.tabs.flatMap { $0.rootPane.allSurfaceIDs().map(\.uuidString) }),
            originalSurfaces,
            "the member's windows are linked copies sharing the live PTYs"
        )
        guard case let .surfaces(list) = registry.handle(.listSurfaces) else { return XCTFail() }
        XCTAssertEqual(Set(list.map(\.surfaceID)), originalSurfaces, "no new PTYs were spawned")

        // A window created in the original propagates to the member.
        let wsID = registry.snapshot.activeWorkspaceID!
        _ = registry.handle(.selectSession(workspaceID: wsID, sessionID: original.id))
        guard case let .tabID(newTab) = registry.handle(.newTab(workspaceID: wsID, cwd: nil, shell: nil)) else {
            return XCTFail("expected tabID")
        }
        let memberAfterCreate = try XCTUnwrap(sessions(registry).first { $0.id == memberID })
        XCTAssertEqual(memberAfterCreate.tabs.count, 2, "new window appears in the peer")

        // Killing the new window removes it from BOTH members and closes its PTY.
        let newSurfaces = registry.snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs)
            .first { $0.id == newTab }!.rootPane.allSurfaceIDs().map(\.uuidString)
        _ = registry.handle(.closeTab(tabID: newTab))
        for session in sessions(registry) where session.groupID != nil {
            XCTAssertEqual(session.tabs.count, 1, "window killed group-wide")
        }
        guard case let .surfaces(after) = registry.handle(.listSurfaces) else { return XCTFail() }
        XCTAssertTrue(Set(after.map(\.surfaceID)).isDisjoint(with: Set(newSurfaces)),
                      "the killed window's PTY is gone (no member references it)")
        XCTAssertEqual(Set(after.map(\.surfaceID)), originalSurfaces,
                       "the shared original surfaces survive untouched")
    }

    /// Regression: when a group member splits a shared window locally (layouts diverge),
    /// the extra PTY lives only in that member's copy. Killing the window from the OTHER
    /// member must still reap it — closing only the originating copy's surfaces leaked the
    /// peer's split PTY for the daemon's lifetime.
    func testKillingDivergedGroupWindowReapsPeerOnlySurface() throws {
        try skipUnlessLiveDaemonTests()
        let registry = SurfaceRegistry()
        let original = try XCTUnwrap(sessions(registry).first)
        let wsID = try XCTUnwrap(registry.snapshot.activeWorkspaceID)

        guard case let .sessionID(memberID) = registry.handle(
            .newSessionInGroup(targetSessionID: original.id, name: "mirror")) else {
            return XCTFail("expected sessionID")
        }
        // A shared window in both members (same live surface).
        _ = registry.handle(.selectSession(workspaceID: wsID, sessionID: original.id))
        guard case let .tabID(origTab) = registry.handle(.newTab(workspaceID: wsID, cwd: nil, shell: nil)) else {
            return XCTFail("expected tabID")
        }

        // The shared window's live surface, used to find the member's copy (cloned tabs get
        // fresh tab ids but keep the surface ids).
        let sharedSurfaces = Set(
            try XCTUnwrap(sessions(registry).first { $0.id == original.id }?.tabs.first { $0.id == origTab })
                .rootPane.allSurfaceIDs().map(\.uuidString))
        let memberTab = try XCTUnwrap(
            sessions(registry).first { $0.id == memberID }?.tabs.first {
                !Set($0.rootPane.allSurfaceIDs().map(\.uuidString)).isDisjoint(with: sharedSurfaces)
            })

        // Split the MEMBER's copy of that window — a new PTY that exists only in the peer.
        let memberPane = try XCTUnwrap(memberTab.rootPane.allPaneIDs().first)
        guard case .paneID = registry.handle(
            .newSplit(tabID: memberTab.id, paneID: memberPane, direction: .horizontal, shell: nil)) else {
            return XCTFail("expected split to succeed")
        }
        let peerOnly = Set(
            try XCTUnwrap(sessions(registry).first { $0.id == memberID }?.tabs.first { $0.id == memberTab.id })
                .rootPane.allSurfaceIDs().map(\.uuidString))
        let origAfterSplit = Set(
            try XCTUnwrap(sessions(registry).first { $0.id == original.id }?.tabs.first { $0.id == origTab })
                .rootPane.allSurfaceIDs().map(\.uuidString))
        // Confirm the layouts diverged: the split did NOT propagate to the originating copy.
        XCTAssertEqual(origAfterSplit, sharedSurfaces, "the split must not propagate to the other member")
        let peerExtra = peerOnly.subtracting(sharedSurfaces)
        XCTAssertEqual(peerExtra.count, 1, "the split added a surface to the peer copy only")

        // Kill the window from the ORIGINATING (un-split) member.
        _ = registry.handle(.closeTab(tabID: origTab))
        guard case let .surfaces(after) = registry.handle(.listSurfaces) else { return XCTFail() }
        XCTAssertTrue(Set(after.map(\.surfaceID)).isDisjoint(with: peerExtra),
                      "the peer's split PTY must be reaped when the window is killed group-wide")
    }
}
