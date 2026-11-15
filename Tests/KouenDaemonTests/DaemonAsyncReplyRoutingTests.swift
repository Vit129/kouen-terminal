import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// [TC-0501][BE-UT] An async reply (browser/runGit/cc*/swarm*) must follow the *connection* that
/// asked, not the raw fd number: if that client disconnects and another one is accepted on the
/// recycled fd, the late reply must be dropped instead of landing on the stranger.
final class DaemonAsyncReplyRoutingTests: XCTestCase {
    private var previousHome: String?
    private var root: URL?
    private var server: DaemonServer!

    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = URL(fileURLWithPath: "/tmp/dar-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()
        server = DaemonServer()
        try server.start()
        let client = DaemonClient()
        var ready = false
        for _ in 0 ..< 50 where !ready {
            if case .pong = (try? client.request(.ping, timeout: 0.4)) { ready = true } else { usleep(100_000) }
        }
        XCTAssertTrue(ready, "daemon did not become ready")
    }

    override func tearDownWithError() throws {
        server?.stop()
        server = nil
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func test_TC0501_BE_UT_asyncReplyIsDroppedWhenAskerDisconnectedAndFDWasReused() throws {
        let gotRequest = expectation(description: "GUI received the forwarded browser request")
        let requestID = AtomicBox<UUID>()
        let gui = try DaemonClient().subscribeSnapshot(
            label: "KouenGUI",
            onRevision: { _ in },
            onBrowserRequest: { id, _, _ in requestID.set(id); gotRequest.fulfill() }
        )
        defer { gui.cancel() }

        // Client A: identify, then ask for something the GUI answers later.
        let a = try connectRaw()
        try send(.identifyClient(label: "client-A", protocolVersion: ipcProtocolVersion), on: a)
        _ = readAvailable(a, timeout: 2)
        try send(.browserOpen(url: URL(string: "https://example.com")!, direction: nil, originSurfaceID: nil), on: a)
        wait(for: [gotRequest], timeout: 3)

        // A goes away; wait until the daemon has fully torn A's fd down (closed + recycled).
        close(a)
        let aGone = expectation(description: "daemon dropped client A")
        DispatchQueue.global().async {
            for _ in 0 ..< 100 {
                if case let .clients(list)? = try? DaemonClient().request(.listClients, timeout: 1),
                   !list.contains(where: { $0.label == "client-A" }) { aGone.fulfill(); return }
                usleep(20_000)
            }
        }
        wait(for: [aGone], timeout: 4)

        // Client B is accepted on the lowest free fd, i.e. A's old number.
        let b = try connectRaw()
        defer { close(b) }
        try send(.identifyClient(label: "client-B", protocolVersion: ipcProtocolVersion), on: b)
        _ = readAvailable(b, timeout: 2)

        // The GUI answers A's request now.
        let id = try XCTUnwrap(requestID.value)
        _ = try DaemonClient().request(.browserResponse(id: id, response: .error("late")), timeout: 2)

        XCTAssertTrue(readAvailable(b, timeout: 0.7).isEmpty, "client B received a frame meant for disconnected client A")
    }

    // MARK: raw socket helpers

    private func connectRaw() throws -> Int32 {
        let fd = makeUnixStreamSocket()
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let path = KouenPaths.socketURL.path
        let capacity = MemoryLayout.size(ofValue: addr.sun_path)
        _ = withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            path.withCString { src in
                ptr.withMemoryRebound(to: CChar.self, capacity: capacity) { strncpy($0, src, capacity - 1) }
            }
        }
        let rc = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size)) }
        }
        guard rc == 0 else { close(fd); throw XCTSkip("cannot connect to test daemon") }
        return fd
    }

    private func send(_ request: IPCRequest, on fd: Int32) throws {
        let data = try IPCCodec.encode(IPCEnvelope(request: request))
        let n = data.withUnsafeBytes { write(fd, $0.baseAddress, data.count) }
        XCTAssertEqual(n, data.count)
    }

    /// Bytes arriving within `timeout` (poll-based wait, returns early once data is read).
    private func readAvailable(_ fd: Int32, timeout: TimeInterval) -> [UInt8] {
        var pfd = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
        guard poll(&pfd, 1, Int32(timeout * 1000)) > 0 else { return [] }
        var buf = [UInt8](repeating: 0, count: 4096)
        let n = read(fd, &buf, buf.count)
        return n > 0 ? Array(buf.prefix(n)) : []
    }
}
