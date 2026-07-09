import XCTest
import KouenCore
@testable import KouenApp

/// Pins `DaemonLauncher.daemonIsStale`: a build mismatch alone must not force a restart when
/// `install-graceful.sh` already decided to preserve the running daemon (matching IPC protocol +
/// live surfaces to protect). Without this guard the app would restart the very daemon
/// install-graceful.sh just kept alive, defeating its whole point on every UI-only release.
final class DaemonLauncherTests: XCTestCase {
    private let mismatchedBuild = KouenVersion.build + 1

    private func stats(
        build: Int?,
        protocolVersion: Int?,
        surfaceCount: Int
    ) -> DaemonStats {
        DaemonStats(
            pid: 1,
            uptimeSeconds: 5,
            surfaceCount: surfaceCount,
            totalScrollbackBytes: 0,
            clientCount: 0,
            subscriberCount: 0,
            snapshotRevision: 0,
            version: nil,
            build: build,
            protocolVersion: protocolVersion
        )
    }

    func testBuildMismatchProtocolMatchWithLiveSurfacesIsPreserved() {
        let s = stats(build: mismatchedBuild, protocolVersion: ipcProtocolVersion, surfaceCount: 3)
        XCTAssertFalse(DaemonLauncher.shared.daemonIsStale(s))
    }

    func testBuildMismatchProtocolMismatchIsStale() {
        let s = stats(build: mismatchedBuild, protocolVersion: ipcProtocolVersion - 1, surfaceCount: 3)
        XCTAssertTrue(DaemonLauncher.shared.daemonIsStale(s))
    }

    func testBuildMismatchProtocolMatchNoSurfacesIsStale() {
        let s = stats(build: mismatchedBuild, protocolVersion: ipcProtocolVersion, surfaceCount: 0)
        XCTAssertTrue(DaemonLauncher.shared.daemonIsStale(s))
    }

    func testBuildMismatchNilProtocolIsStale() {
        let s = stats(build: mismatchedBuild, protocolVersion: nil, surfaceCount: 3)
        XCTAssertTrue(DaemonLauncher.shared.daemonIsStale(s))
    }

    /// The preserve guard lives strictly inside the build-mismatch branch. Regardless of what
    /// `bundledDaemonIsNewer` decides for a build match, that decision must not depend on
    /// protocol/surface fields — proving the guard didn't leak outside the stale branch.
    func testBuildMatchIgnoresProtocolAndSurfaceFields() {
        let plain = stats(build: KouenVersion.build, protocolVersion: nil, surfaceCount: 0)
        var preserveLooking = plain
        preserveLooking.protocolVersion = ipcProtocolVersion
        preserveLooking.surfaceCount = 3
        XCTAssertEqual(
            DaemonLauncher.shared.daemonIsStale(plain),
            DaemonLauncher.shared.daemonIsStale(preserveLooking)
        )
    }
}
