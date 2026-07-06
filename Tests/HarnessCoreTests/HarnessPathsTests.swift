import XCTest
@testable import HarnessCore

final class HarnessPathsTests: XCTestCase {
    private var previousHome: String?
    private var previousKouenHome: String?

    override func setUp() {
        super.setUp()
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        previousKouenHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        unsetenv("KOUEN_HOME") // tests opt in explicitly; don't inherit the live shell's value
    }

    override func tearDown() {
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        if let previousKouenHome { setenv("KOUEN_HOME", previousKouenHome, 1) } else { unsetenv("KOUEN_HOME") }
        super.tearDown()
    }

    /// `KOUEN_HOME` is the current name; `HARNESS_HOME` is read as a fallback so an existing
    /// shell profile or CI config keeps working unmodified after the rename.
    func testKouenHomeTakesPrecedenceOverHarnessHome() {
        setenv("HARNESS_HOME", "/tmp/harness-home-should-be-ignored", 1)
        setenv("KOUEN_HOME", "/tmp/kouen-home-test", 1)
        XCTAssertEqual(HarnessPaths.applicationSupport.path, "/tmp/kouen-home-test")
    }

    func testHarnessHomeStillWorksWhenKouenHomeIsUnset() {
        unsetenv("KOUEN_HOME")
        setenv("HARNESS_HOME", "/tmp/harness-home-fallback-test", 1)
        XCTAssertEqual(HarnessPaths.applicationSupport.path, "/tmp/harness-home-fallback-test")
    }

    // MARK: - Data root name resolution (Harness -> Kouen, read-fallback)
    //
    // Deliberately a read fallback, not a physical move — see resolveDataRootName's doc comment.
    // Testing the pure function directly (rather than `applicationSupport` end-to-end) sidesteps
    // `overrideRoot`, which every other test in this file sets — that's how the previous version
    // of this logic shipped a migration branch the suite could never actually exercise.

    func testDataRootUsesNewNameWhenOnlyNewExists() {
        let name = HarnessPaths.resolveDataRootName(
            base: "/unused", newName: "Kouen", legacyName: "Harness",
            fileExistsAtPath: { $0 == "/unused/Kouen" })
        XCTAssertEqual(name, "Kouen")
    }

    func testDataRootFallsBackToLegacyNameWhenOnlyLegacyExists() {
        let name = HarnessPaths.resolveDataRootName(
            base: "/unused", newName: "Kouen", legacyName: "Harness",
            fileExistsAtPath: { $0 == "/unused/Harness" })
        XCTAssertEqual(name, "Harness", "an un-migrated upgrade keeps reading its existing directory")
    }

    func testDataRootPrefersNewNameWhenBothExist() {
        let name = HarnessPaths.resolveDataRootName(
            base: "/unused", newName: "Kouen", legacyName: "Harness",
            fileExistsAtPath: { $0 == "/unused/Kouen" || $0 == "/unused/Harness" })
        XCTAssertEqual(name, "Kouen")
    }

    func testDataRootUsesNewNameWhenNeitherExists() {
        let name = HarnessPaths.resolveDataRootName(
            base: "/unused", newName: "Kouen", legacyName: "Harness",
            fileExistsAtPath: { _ in false })
        XCTAssertEqual(name, "Kouen", "a fresh install has nothing to preserve")
    }

    /// Same logic against the real filesystem (default `fileExistsAtPath`, not a stub) — proves
    /// the actual `FileManager.fileExists` wiring behaves the same as the stubbed unit tests above.
    func testDataRootResolutionAgainstRealDiskFallsBackToLegacyDirectory() throws {
        let tempBase = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-approot-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempBase, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempBase) }
        let legacyDir = tempBase.appendingPathComponent("Harness", isDirectory: true)
        try FileManager.default.createDirectory(at: legacyDir, withIntermediateDirectories: true)

        let resolved = HarnessPaths.resolveDataRootName(
            base: tempBase.path, newName: "Kouen", legacyName: "Harness")
        XCTAssertEqual(resolved, "Harness")
    }

    func testHarnessHomeOverrideRootsAllPaths() {
        setenv("HARNESS_HOME", "/tmp/harness-paths-test", 1)
        XCTAssertEqual(HarnessPaths.applicationSupport.path, "/tmp/harness-paths-test")
        XCTAssertEqual(HarnessPaths.socketURL.path, "/tmp/harness-paths-test/kouen.sock")
        XCTAssertEqual(HarnessPaths.snapshotURL.path, "/tmp/harness-paths-test/sessions/layout.json")
        XCTAssertEqual(HarnessPaths.settingsURL.lastPathComponent, "settings.json")
    }

    func testHarnessHomeExpandsTilde() {
        setenv("HARNESS_HOME", "~/.harness-paths-test", 1)
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        XCTAssertEqual(HarnessPaths.applicationSupport.path, "\(home)/.harness-paths-test")
    }

    func testValidatedSocketPathAcceptsShortHome() throws {
        setenv("HARNESS_HOME", "/tmp/harness-sock-test", 1)
        XCTAssertEqual(try HarnessPaths.validatedSocketPath(), "/tmp/harness-sock-test/kouen.sock")
    }

    func testValidatedSocketPathRejectsOverlongHome() {
        // A HARNESS_HOME deep enough to push kouen.sock past sun_path (104) must fail clearly,
        // not silently truncate and connect/bind to the wrong socket.
        let deep = "/tmp/" + String(repeating: "x", count: 120)
        setenv("HARNESS_HOME", deep, 1)
        XCTAssertGreaterThanOrEqual(HarnessPaths.socketURL.path.utf8.count, HarnessPaths.maxSocketPathLength)
        XCTAssertThrowsError(try HarnessPaths.validatedSocketPath()) { error in
            guard case HarnessPathsError.socketPathTooLong = error else {
                return XCTFail("expected socketPathTooLong, got \(error)")
            }
        }
    }

    /// Without an override, the real machine's own state decides Kouen vs. the pre-rename
    /// Harness (see `resolveDataRootName`) — a fresh machine gets Kouen, an unmigrated upgrade
    /// keeps Harness. Either is correct; only a third answer (or an unrelated path) is a bug.
    func testWithoutOverrideFallsBackToPlatformDefaultDataHome() {
        unsetenv("HARNESS_HOME")
        let path = HarnessPaths.applicationSupport.path
        XCTAssertFalse(path.isEmpty)
        #if canImport(Glibc)
        XCTAssertTrue(
            path.hasSuffix("/.local/share/kouen") || path.hasSuffix("/.local/share/harness"),
            "expected an XDG kouen or harness data path, got \(path)")
        #else
        XCTAssertTrue(
            path.hasSuffix("/Kouen") || path.hasSuffix("/Harness"),
            "expected an Application Support/Kouen or /Harness path, got \(path)")
        #endif
    }

    func testEnsureDirectoriesCreatesOwnerOnlyHome() throws {
        let dir = URL(fileURLWithPath: "/tmp/harness-perms-\(UUID().uuidString.prefix(8))", isDirectory: true)
        setenv("HARNESS_HOME", dir.path, 1)
        defer { try? FileManager.default.removeItem(at: dir) }
        try HarnessPaths.ensureDirectories()
        // The Harness home holds the control socket, session layout, and shell-running hooks;
        // it (and the subdirs we own) must be 0o700 so no other local user can read or tamper.
        for url in [HarnessPaths.applicationSupport, HarnessPaths.sessionsDirectory, HarnessPaths.logsDirectory] {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let perms = (attrs[.posixPermissions] as? NSNumber)?.intValue
            XCTAssertEqual(perms, 0o700, "expected 0o700 on \(url.lastPathComponent), got \(perms.map { String($0, radix: 8) } ?? "nil")")
        }
    }

    func testEnsureDirectoriesTightensPreexistingLoosePermissions() throws {
        let dir = URL(fileURLWithPath: "/tmp/harness-perms-\(UUID().uuidString.prefix(8))", isDirectory: true)
        setenv("HARNESS_HOME", dir.path, 1)
        defer { try? FileManager.default.removeItem(at: dir) }
        // Simulate a home created by an older build under the default 0o755 umask.
        try FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
        try HarnessPaths.ensureDirectories()
        let attrs = try FileManager.default.attributesOfItem(atPath: dir.path)
        XCTAssertEqual((attrs[.posixPermissions] as? NSNumber)?.intValue, 0o700)
    }

    // MARK: - Config-file persistence helpers

    func testBackupCorruptFileMovesAsideAndReplacesStaleBackup() throws {
        let dir = URL(fileURLWithPath: "/tmp/harness-corrupt-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("config.json")
        let backup = file.appendingPathExtension("corrupt")

        try Data("first".utf8).write(to: file)
        XCTAssertTrue(HarnessPaths.backupCorruptFile(at: file, label: "Test"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path), "original moved aside")
        XCTAssertEqual(try String(contentsOf: backup, encoding: .utf8), "first")

        // A second corruption replaces the stale backup rather than failing on the existing one.
        try Data("second".utf8).write(to: file)
        XCTAssertTrue(HarnessPaths.backupCorruptFile(at: file, label: "Test"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        XCTAssertEqual(try String(contentsOf: backup, encoding: .utf8), "second")
    }

    func testBackupCorruptFileReturnsFalseWhenSourceMissing() {
        // No file to move → the move fails; the helper must report false (not a misleading success)
        // and must not crash.
        let missing = URL(fileURLWithPath: "/tmp/harness-missing-\(UUID().uuidString.prefix(8)).json")
        XCTAssertFalse(HarnessPaths.backupCorruptFile(at: missing, label: "Test"))
    }

    func testAtomicWriteRoundTrips() throws {
        let dir = URL(fileURLWithPath: "/tmp/harness-write-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("out.json")
        XCTAssertTrue(HarnessPaths.atomicWrite(Data("payload".utf8), to: file, label: "Test"))
        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), "payload")
    }
}
