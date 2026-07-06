import XCTest
@testable import KouenCore

final class KouenPathsTests: XCTestCase {
    private var previousHome: String?

    override func setUp() {
        super.setUp()
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
    }

    override func tearDown() {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        super.tearDown()
    }

    func testKouenHomeOverrideRootsAllPaths() {
        setenv("KOUEN_HOME", "/tmp/kouen-paths-test", 1)
        XCTAssertEqual(KouenPaths.applicationSupport.path, "/tmp/kouen-paths-test")
        XCTAssertEqual(KouenPaths.socketURL.path, "/tmp/kouen-paths-test/kouen.sock")
        XCTAssertEqual(KouenPaths.snapshotURL.path, "/tmp/kouen-paths-test/sessions/layout.json")
        XCTAssertEqual(KouenPaths.settingsURL.lastPathComponent, "settings.json")
    }

    func testKouenHomeExpandsTilde() {
        setenv("KOUEN_HOME", "~/.kouen-paths-test", 1)
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        XCTAssertEqual(KouenPaths.applicationSupport.path, "\(home)/.kouen-paths-test")
    }

    func testValidatedSocketPathAcceptsShortHome() throws {
        setenv("KOUEN_HOME", "/tmp/kouen-sock-test", 1)
        XCTAssertEqual(try KouenPaths.validatedSocketPath(), "/tmp/kouen-sock-test/kouen.sock")
    }

    func testValidatedSocketPathRejectsOverlongHome() {
        // A KOUEN_HOME deep enough to push kouen.sock past sun_path (104) must fail clearly,
        // not silently truncate and connect/bind to the wrong socket.
        let deep = "/tmp/" + String(repeating: "x", count: 120)
        setenv("KOUEN_HOME", deep, 1)
        XCTAssertGreaterThanOrEqual(KouenPaths.socketURL.path.utf8.count, KouenPaths.maxSocketPathLength)
        XCTAssertThrowsError(try KouenPaths.validatedSocketPath()) { error in
            guard case KouenPathsError.socketPathTooLong = error else {
                return XCTFail("expected socketPathTooLong, got \(error)")
            }
        }
    }

    func testWithoutOverrideFallsBackToPlatformDefaultDataHome() {
        unsetenv("KOUEN_HOME")
        let path = KouenPaths.applicationSupport.path
        XCTAssertFalse(path.isEmpty)
        #if canImport(Glibc)
        XCTAssertTrue(path.hasSuffix("/.local/share/kouen"), "expected an XDG kouen data path, got \(path)")
        #else
        XCTAssertTrue(path.hasSuffix("/Kouen"), "expected an Application Support/Kouen path, got \(path)")
        #endif
    }

    func testEnsureDirectoriesCreatesOwnerOnlyHome() throws {
        let dir = URL(fileURLWithPath: "/tmp/kouen-perms-\(UUID().uuidString.prefix(8))", isDirectory: true)
        setenv("KOUEN_HOME", dir.path, 1)
        defer { try? FileManager.default.removeItem(at: dir) }
        try KouenPaths.ensureDirectories()
        // The Kouen home holds the control socket, session layout, and shell-running hooks;
        // it (and the subdirs we own) must be 0o700 so no other local user can read or tamper.
        for url in [KouenPaths.applicationSupport, KouenPaths.sessionsDirectory, KouenPaths.logsDirectory] {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let perms = (attrs[.posixPermissions] as? NSNumber)?.intValue
            XCTAssertEqual(perms, 0o700, "expected 0o700 on \(url.lastPathComponent), got \(perms.map { String($0, radix: 8) } ?? "nil")")
        }
    }

    func testEnsureDirectoriesTightensPreexistingLoosePermissions() throws {
        let dir = URL(fileURLWithPath: "/tmp/kouen-perms-\(UUID().uuidString.prefix(8))", isDirectory: true)
        setenv("KOUEN_HOME", dir.path, 1)
        defer { try? FileManager.default.removeItem(at: dir) }
        // Simulate a home created by an older build under the default 0o755 umask.
        try FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
        try KouenPaths.ensureDirectories()
        let attrs = try FileManager.default.attributesOfItem(atPath: dir.path)
        XCTAssertEqual((attrs[.posixPermissions] as? NSNumber)?.intValue, 0o700)
    }

    // MARK: - Config-file persistence helpers

    func testBackupCorruptFileMovesAsideAndReplacesStaleBackup() throws {
        let dir = URL(fileURLWithPath: "/tmp/kouen-corrupt-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("config.json")
        let backup = file.appendingPathExtension("corrupt")

        try Data("first".utf8).write(to: file)
        XCTAssertTrue(KouenPaths.backupCorruptFile(at: file, label: "Test"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path), "original moved aside")
        XCTAssertEqual(try String(contentsOf: backup, encoding: .utf8), "first")

        // A second corruption replaces the stale backup rather than failing on the existing one.
        try Data("second".utf8).write(to: file)
        XCTAssertTrue(KouenPaths.backupCorruptFile(at: file, label: "Test"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        XCTAssertEqual(try String(contentsOf: backup, encoding: .utf8), "second")
    }

    func testBackupCorruptFileReturnsFalseWhenSourceMissing() {
        // No file to move → the move fails; the helper must report false (not a misleading success)
        // and must not crash.
        let missing = URL(fileURLWithPath: "/tmp/kouen-missing-\(UUID().uuidString.prefix(8)).json")
        XCTAssertFalse(KouenPaths.backupCorruptFile(at: missing, label: "Test"))
    }

    func testAtomicWriteRoundTrips() throws {
        let dir = URL(fileURLWithPath: "/tmp/kouen-write-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("out.json")
        XCTAssertTrue(KouenPaths.atomicWrite(Data("payload".utf8), to: file, label: "Test"))
        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), "payload")
    }
}
