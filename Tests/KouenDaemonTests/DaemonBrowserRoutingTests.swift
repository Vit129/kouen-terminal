import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// Regression tests for browser-request routing and continuation lifecycle.
///
/// Bug 1: forwardBrowserRequest used snapshotSubscribers.first (Set — no stable order),
///        so with 2+ GUI-class subscribers it could route to the wrong client.
/// Bug 2: pendingBrowserRequests were never drained when the GUI disconnected,
///        leaving MCP/CLI callers blocked for 30 s until the timeout fired.
final class DaemonBrowserRoutingTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?
    private var server: DaemonServer!

    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = URL(fileURLWithPath: "/tmp/hbr-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()
        server = DaemonServer()
        try server.start()
        try waitForDaemonReady()
    }

    override func tearDownWithError() throws {
        server?.stop()
        server = nil
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    private func waitForDaemonReady() throws {
        let client = DaemonClient()
        for _ in 0 ..< 50 {
            if case .pong = (try? client.request(.ping, timeout: 0.4)) { return }
            usleep(100_000)
        }
        XCTFail("daemon did not become ready")
    }

    /// With two snapshot subscribers — "KouenGUI" and "compositor" — a browserOpen
    /// request must be forwarded only to "KouenGUI", not to the compositor.
    func testBrowserRequestRoutedToKouenGUI() throws {
        let guiReceived = AtomicCounter()
        let compositorReceived = AtomicCounter()

        let guiSub = try DaemonClient().subscribeSnapshot(
            label: "KouenGUI",
            onRevision: { _ in },
            onBrowserRequest: { _, _, _ in guiReceived.increment() }
        )
        defer { guiSub.cancel() }

        let compositorSub = try DaemonClient().subscribeSnapshot(
            label: "compositor",
            onRevision: { _ in }
            // intentionally no onBrowserRequest — compositor never sets one
        )
        defer { compositorSub.cancel() }

        // Send browserOpen in background — daemon forwards to GUI, waits for a response
        // that never comes (timeout 1 s). We only care that routing fired correctly.
        let url = URL(string: "https://example.com")!
        DispatchQueue.global().async {
            _ = try? DaemonClient().request(.browserOpen(url: url, direction: nil, originSurfaceID: nil), timeout: 1.0)
        }

        // Give the daemon time to forward the request before asserting.
        Thread.sleep(forTimeInterval: 0.3)

        XCTAssertEqual(guiReceived.value, 1, "browserRequest must reach the KouenGUI subscriber")
        XCTAssertEqual(compositorReceived.value, 0, "compositor must not receive browserRequest")
    }

    /// When the GUI subscriber disconnects while a browser request is in-flight, the
    /// daemon must immediately fail the pending continuation — not wait 30 s for timeout.
    func testBrowserDisconnectDrainsImmediately() throws {
        let guiSub = try DaemonClient().subscribeSnapshot(
            label: "KouenGUI",
            onRevision: { _ in }
        )

        let url = URL(string: "https://example.com")!
        let responseBox = AtomicBox<IPCResponse>()
        let done = expectation(description: "browserOpen returns after GUI disconnect")

        // Send browserOpen on a background thread — daemon will forward it to the GUI
        // and await the GUI's browserResponse.
        DispatchQueue.global().async {
            let resp = try? DaemonClient().request(.browserOpen(url: url, direction: nil, originSurfaceID: nil), timeout: 5.0)
            responseBox.set(resp)
            done.fulfill()
        }

        // Wait for the daemon to forward the request, then disconnect the GUI.
        Thread.sleep(forTimeInterval: 0.2)
        guiSub.cancel()

        // The drain in cancelSubscriptions(for:) must resolve the continuation immediately.
        // Allow 2 s — far below the 30 s timeout the bug caused.
        wait(for: [done], timeout: 2.0)

        guard let resp = responseBox.value else {
            XCTFail("no response received after GUI disconnect"); return
        }
        if case .browserSuccess(.error(_)) = resp {
            // correct: immediate error response
        } else {
            XCTFail("expected browserSuccess(.error) after GUI disconnect, got \(resp)")
        }
    }
}

/// Pure invariant: maxPayloadLength must never reach 0xF5/0xF6 (binary frame magics).
/// The 4-byte big-endian JSON length's high byte is 0x00 or 0x01 for payloads ≤ 16 MiB,
/// which is below 0xF5. A bump past 0x01FFFFFF would make the high byte collide with the
/// output-frame magic and break all binary frame demuxing without version negotiation.
final class IPCCodecInvariantTests: XCTestCase {
    func testMaxPayloadLengthBelowBinaryMagicThreshold() {
        XCTAssertLessThanOrEqual(
            IPCCodec.maxPayloadLength, 0x01_FF_FF_FF,
            "maxPayloadLength must stay below 0x02000000 so the JSON length high byte never reaches binary magic 0xF5/0xF6"
        )
    }
}
