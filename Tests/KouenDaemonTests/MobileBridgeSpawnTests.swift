import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// Regression guard for the mobile "+" ghost-session bug: tapping "+" on the phone bridge used
/// to `.createSurface`, which spins a raw PTY that never joins the `SessionEditor` tree — so the
/// new session showed up nowhere (Mac app list, `.listSurfaces`, the bridge's own switcher) and
/// could never be reselected. The fix routes `handleSpawn` through `.newTab` instead.
///
/// This drives `MobileBridgeServer.resolveSpawnedSurfaceID` — the exact resolution `handleSpawn`
/// now uses — against a live `SurfaceRegistry` (same `.handle(...)` calls the loopback
/// `DaemonClient` would make) and asserts the surface it hands back to attach to is a real tab
/// visible in `.listSurfaces`. Reverting the helper to `.createSurface` makes this fail: that
/// surface is absent from `.listSurfaces`. Uses `SurfaceRegistry()` (real PTYs), so it is gated
/// behind `KOUEN_LIVE_DAEMON_TESTS=1` like the other daemon integration tests.
final class MobileBridgeSpawnTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-mobile-spawn-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func testMobileSpawnCreatesSurfaceVisibleInListSurfaces() throws {
        try skipUnlessLiveDaemonTests()
        let registry = SurfaceRegistry()

        let surfaceID = try XCTUnwrap(
            MobileBridgeServer.resolveSpawnedSurfaceID(cwd: nil) { registry.handle($0) },
            "a mobile spawn must resolve a surface to attach to"
        )

        guard case let .surfaces(list) = registry.handle(.listSurfaces) else {
            return XCTFail("expected .surfaces from .listSurfaces")
        }
        XCTAssertTrue(
            list.map(\.surfaceID).contains(surfaceID),
            "a mobile-spawned surface must be a real, persistent tab visible in .listSurfaces "
                + "(the ghost-session guard: .createSurface would be invisible here)"
        )
    }

    /// Documents *why* the old code was broken: a `.createSurface` PTY is intentionally invisible
    /// to `.listSurfaces` because it never joins `editor`. Pins the contrast the fix depends on —
    /// if `.createSurface` ever started registering into the tree, `handleSpawn`'s choice would no
    /// longer matter and this test would flag that behavioral shift.
    func testCreateSurfaceIsInvisibleToListSurfaces() throws {
        try skipUnlessLiveDaemonTests()
        let registry = SurfaceRegistry()

        guard case let .surfaceID(ghostID) = registry.handle(.createSurface(cwd: nil, shell: nil)) else {
            return XCTFail("expected .surfaceID from .createSurface")
        }
        guard case let .surfaces(list) = registry.handle(.listSurfaces) else {
            return XCTFail("expected .surfaces from .listSurfaces")
        }
        XCTAssertFalse(
            list.map(\.surfaceID).contains(ghostID),
            "a .createSurface PTY never joins the session tree, so it must not appear in .listSurfaces"
        )
    }
}
