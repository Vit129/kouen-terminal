import XCTest
@testable import KouenOnboarding

final class BinaryInstallerDisplayTests: XCTestCase {
    /// Regression: the install screen's Daemon row used to read "Found kouen-cli" — identical to
    /// the CLI row — because the `.found` display hardcoded the CLI name. It must report the
    /// detected binary's own name.
    @MainActor
    func testFoundDisplayUsesDetectedBinaryName() {
        let cli = BinaryInstaller.DetectionStatus.found(
            version: nil, path: URL(fileURLWithPath: "/Applications/Kouen.app/Contents/MacOS/kouen-cli")
        )
        let daemon = BinaryInstaller.DetectionStatus.found(
            version: nil, path: URL(fileURLWithPath: "/Applications/Kouen.app/Contents/MacOS/KouenDaemon")
        )
        XCTAssertEqual(cli.display, "Found kouen-cli")
        XCTAssertEqual(daemon.display, "Found KouenDaemon")
        XCTAssertNotEqual(cli.display, daemon.display)
    }

    @MainActor
    func testFoundDisplayPrefersExplicitVersion() {
        let withVersion = BinaryInstaller.DetectionStatus.found(
            version: "1.3.0", path: URL(fileURLWithPath: "/x/kouen-cli")
        )
        XCTAssertEqual(withVersion.display, "Found 1.3.0")
    }
}
