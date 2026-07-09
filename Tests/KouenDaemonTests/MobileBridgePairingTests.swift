import Network
import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// P37 Phase A pure-logic tests: A1 lockout accounting (`PairingBox`), the constant-time
/// compare, the at-rest secret hashing (`SHA256Mini` known-answer), `PairedDeviceStore`
/// re-auth/migration/expiry/revoke, and the bind-scope invariant (`allowedBindHosts`).
/// No live listeners/sockets — the WS round-trip is covered by the scripted-client live
/// check (see the P37 plan's verification gates), not by this file.
final class MobileBridgePairingTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-mobile-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    // MARK: - A1: lockout accounting

    func testLockoutTripsOnExactlyTheNthFailureAndOnlyReportsOnce() {
        let box = MobileBridgeServer.PairingBox(maxAttempts: 5)
        box.current = .init(token: "123456", url: "http://x/", expiresAt: .distantFuture)
        for i in 1...4 {
            XCTAssertFalse(box.recordFailure(), "failure \(i) must not report the lockout transition")
            XCTAssertFalse(box.isLockedOut, "not locked out before the limit")
        }
        XCTAssertTrue(box.recordFailure(), "the 5th failure is the transition INTO lockout")
        XCTAssertTrue(box.isLockedOut)
        XCTAssertFalse(box.recordFailure(), "post-lockout failures must not re-report")
        XCTAssertTrue(box.isLockedOut)
    }

    func testTokenRotationResetsLockout() {
        let box = MobileBridgeServer.PairingBox(maxAttempts: 2)
        box.current = .init(token: "111111", url: "http://x/", expiresAt: .distantFuture)
        _ = box.recordFailure()
        _ = box.recordFailure()
        XCTAssertTrue(box.isLockedOut)
        // The pairing loop's next `current = ...` write is the release condition.
        box.current = .init(token: "222222", url: "http://x/", expiresAt: .distantFuture)
        XCTAssertFalse(box.isLockedOut)
    }

    // MARK: - Constant-time compare

    func testConstantTimeEquals() {
        XCTAssertTrue(constantTimeEquals(Array("123456".utf8), Array("123456".utf8)))
        XCTAssertFalse(constantTimeEquals(Array("123456".utf8), Array("123457".utf8)))
        XCTAssertFalse(constantTimeEquals(Array("123456".utf8), Array("12345".utf8)), "length mismatch must fail")
        XCTAssertFalse(constantTimeEquals(Array("123456".utf8), []), "empty guess must fail")
        XCTAssertTrue(constantTimeEquals([], []), "two empties are equal")
    }

    // MARK: - SHA256Mini known-answer (pins the hand-rolled implementation)

    func testSHA256KnownAnswers() {
        // FIPS 180-4 example vectors — if either fails, the at-rest hash is broken and every
        // stored credential with it. Do not weaken these.
        XCTAssertEqual(
            SHA256Mini.hexDigest(Array("abc".utf8)),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        )
        XCTAssertEqual(
            SHA256Mini.hexDigest([]),
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )
        // Multi-block message (>64 bytes) exercises the chunk loop.
        XCTAssertEqual(
            SHA256Mini.hexDigest(Array("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".utf8)),
            "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
        )
    }

    // MARK: - A2: PairedDeviceStore secrets

    func testRegisterAuthenticateAndPlaintextNeverOnDisk() throws {
        let store = PairedDeviceStore()
        store.register(id: "dev-1", label: "Test phone", secret: "s3cret-value")
        XCTAssertTrue(store.authenticate(id: "dev-1", secret: "s3cret-value"))
        XCTAssertFalse(store.authenticate(id: "dev-1", secret: "wrong"))
        XCTAssertFalse(store.authenticate(id: "nope", secret: "s3cret-value"))
        let onDisk = try String(contentsOf: KouenPaths.pairedDevicesURL, encoding: .utf8)
        XCTAssertFalse(onDisk.contains("s3cret-value"), "only the hash may be persisted")
        XCTAssertTrue(onDisk.contains(SHA256Mini.hexDigest(Array("s3cret-value".utf8))))
    }

    func testLegacyRecordsWithoutSecretsStayListedButCannotAuth() throws {
        // A P25-era file: `[PairedDeviceSummary]` shape, no secretHash key at all.
        // (JSONEncoder's default Date coding — seconds since the reference date.)
        let legacy = #"[{"id":"old-1","label":"Legacy phone","pairedAt":773000000}]"#
        try Data(legacy.utf8).write(to: KouenPaths.pairedDevicesURL)
        let store = PairedDeviceStore()
        XCTAssertEqual(store.list().map(\.id), ["old-1"], "legacy device must survive the load")
        XCTAssertFalse(store.authenticate(id: "old-1", secret: "anything"), "no hash → no re-auth")
        // A later register must not disturb the legacy entry.
        store.register(id: "new-1", label: "New phone", secret: "abc")
        XCTAssertEqual(Set(store.list().map(\.id)), ["old-1", "new-1"])
    }

    func testExpiredSecretFailsAuthentication() throws {
        // Craft a record pairedAt > secretLifetime ago, with a correct hash — auth must
        // still fail purely on age.
        let hash = SHA256Mini.hexDigest(Array("still-correct".utf8))
        let old = Date().addingTimeInterval(-PairedDeviceStore.secretLifetime - 60)
        let json = """
        [{"id":"aged-1","label":"Old phone","pairedAt":\(old.timeIntervalSinceReferenceDate),"secretHash":"\(hash)"}]
        """
        try Data(json.utf8).write(to: KouenPaths.pairedDevicesURL)
        let store = PairedDeviceStore()
        XCTAssertFalse(store.authenticate(id: "aged-1", secret: "still-correct"))
    }

    func testRevokeInvalidatesSecret() {
        let store = PairedDeviceStore()
        store.register(id: "dev-r", label: "Phone", secret: "tok")
        XCTAssertTrue(store.authenticate(id: "dev-r", secret: "tok"))
        XCTAssertTrue(store.revoke(id: "dev-r"))
        XCTAssertFalse(store.authenticate(id: "dev-r", secret: "tok"), "revoke must kill the secret")
    }

    func testStoreRoundTripsThroughDisk() {
        let first = PairedDeviceStore()
        first.register(id: "dev-p", label: "Persistent phone", secret: "roundtrip")
        // A second store instance (fresh daemon start) must re-auth from the persisted hash.
        let second = PairedDeviceStore()
        XCTAssertTrue(second.authenticate(id: "dev-p", secret: "roundtrip"))
    }

    // MARK: - Revocation-bypass guard (found via Agy + Opus verification)

    /// Pins `shouldRemoveLiveEntry`: a stale connection's teardown must NOT delete a newer
    /// connection's entry for the same deviceID (the revocation-bypass bug), but a teardown
    /// for the CURRENT entry must still remove it normally. Instantiating `NWConnection`
    /// objects here never calls `.start()`, so no socket/listener is ever touched — pure
    /// object-identity logic, no live networking.
    func testShouldRemoveLiveEntryOnlyMatchesTheCurrentConnection() {
        let endpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: 1)
        let older = NWConnection(to: endpoint, using: .tcp)
        let newer = NWConnection(to: endpoint, using: .tcp)

        // Newer connection already replaced the map entry (as `registerLive` would do) —
        // the older connection's teardown must be a no-op.
        XCTAssertFalse(
            MobileBridgeServer.shouldRemoveLiveEntry(current: newer, torndown: older),
            "a stale connection's teardown must not remove a newer connection's entry"
        )
        // The still-current connection's own teardown must remove it.
        XCTAssertTrue(
            MobileBridgeServer.shouldRemoveLiveEntry(current: newer, torndown: newer),
            "the live connection's own teardown must still remove its entry"
        )
        // No entry at all (already revoked/removed) — also a no-op, not a crash.
        XCTAssertFalse(MobileBridgeServer.shouldRemoveLiveEntry(current: nil, torndown: older))
    }

    // MARK: - Bind-scope invariant (R6 — no-TLS posture depends on this)

    func testAllowedBindHostsNeverIncludesWildcardOrLAN() {
        XCTAssertEqual(MobileBridgeServer.allowedBindHosts(tailscaleIP: nil), ["127.0.0.1"])
        XCTAssertEqual(
            MobileBridgeServer.allowedBindHosts(tailscaleIP: "100.101.102.103"),
            ["127.0.0.1", "100.101.102.103"]
        )
        XCTAssertEqual(
            MobileBridgeServer.allowedBindHosts(tailscaleIP: " 100.64.0.7\n"),
            ["127.0.0.1", "100.64.0.7"], "detected IP arrives with tool whitespace"
        )
        // The invariant proper: wildcard, empty, and non-Tailscale (routable LAN) addresses
        // must all be dropped — the bridge has no TLS; only loopback + WireGuard may carry it.
        XCTAssertEqual(MobileBridgeServer.allowedBindHosts(tailscaleIP: "0.0.0.0"), ["127.0.0.1"])
        XCTAssertEqual(MobileBridgeServer.allowedBindHosts(tailscaleIP: "::"), ["127.0.0.1"])
        XCTAssertEqual(MobileBridgeServer.allowedBindHosts(tailscaleIP: ""), ["127.0.0.1"])
        XCTAssertEqual(MobileBridgeServer.allowedBindHosts(tailscaleIP: "192.168.1.20"), ["127.0.0.1"])
    }
}
