import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// A read-only attach is a viewer for the life of its connection: every request that would type,
/// paste, take control or upgrade the role gets a truthful refusal, and nothing reaches the child.
final class ReadOnlyConnectionTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?
    private var server: DaemonServer!

    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        let dir = URL(fileURLWithPath: "/tmp/hro-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("HARNESS_HOME", dir.path, 1)
        try HarnessPaths.ensureDirectories()
        server = DaemonServer()
        try server.start()
        let ready = waitUntil(timeout: 10) {
            if case .pong = (try? DaemonClient().request(.ping, timeout: 0.4)) { return true }
            return false
        }
        if !ready { XCTFail("daemon did not become ready") }
    }

    override func tearDownWithError() throws {
        server?.stop()
        server = nil
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func testViewerConnectionRefusesEveryWriteAndKeepsItsRole() throws {
        guard case let .snapshot(state) = try DaemonClient().request(.getSnapshot),
              let surface = state.workspaces.flatMap(\.sessions).flatMap(\.tabs).first?.rootPane.allSurfaceIDs().first
        else { return XCTFail("no surface") }
        let id = surface.uuidString
        let secret = "HARNESS_VIEWER_\(UUID().uuidString.prefix(8))"

        let viewer = try RawConnection()
        defer { viewer.close() }
        try viewer.send(.attachStream(AttachRequest(surfaceID: id, label: "viewer", readOnly: true, history: false, inputErrors: true)))
        guard case .attached = try viewer.nextReply() else { return XCTFail("read-only attach failed") }

        let writes: [IPCRequest] = [
            .sendData(surfaceID: id, data: Data("printf '\(secret)\\n'\n".utf8)),
            .send(surfaceID: id, text: "printf '\(secret)\\n'\n"),
            .sendKeys(surfaceID: id, keys: ["printf", "Space", secret, "Enter"]),
            .pasteBuffer(surfaceID: id, name: nil, bracketed: false),
            .takeSurface(surfaceID: id, clientID: nil),
            .subscribeSurfaceOutput(surfaceID: id, label: "upgrade"),
            .attachStream(AttachRequest(surfaceID: id, label: "upgrade", readOnly: false, history: false)),
        ]
        for request in writes {
            try viewer.send(request)
            guard case let .error(message)? = try viewer.nextReply() else { return XCTFail("no refusal for \(request)") }
            XCTAssertEqual(message, IPCRequest.readOnlyRefusal, "\(request)")
        }
        try viewer.sendInput(surfaceID: id, Data("printf '\(secret)\\n'\n".utf8))
        guard case let .inputRejected(rejection)? = try viewer.nextReply() else { return XCTFail("input frame was not refused") }
        XCTAssertEqual(rejection, IPCRequest.readOnlyRefusal)

        try viewer.send(.resizeSurface(surfaceID: id, rows: 24, cols: 80))
        guard case .ok? = try viewer.nextReply() else { return XCTFail("a viewer still reports a size, which never votes") }
        try viewer.send(.ping)
        guard case .pong? = try viewer.nextReply() else { return XCTFail("viewer ping failed") }

        usleep(400_000)
        guard case let .text(replay) = try DaemonClient().request(.replayScrollback(surfaceID: id, fromSequence: nil)) else {
            return XCTFail("no replay")
        }
        XCTAssertFalse(replay.contains(secret), "nothing from the viewer reached the child")
    }
}

/// One socket driven frame by frame, so every reply belongs to the connection under test.
private final class RawConnection {
    let fd: Int32
    private var buffer = Data()

    init() throws {
        fd = try EndpointConnector.connect(.unix(path: HarnessPaths.socketURL.path))
    }

    func send(_ request: IPCRequest) throws {
        try write(IPCCodec.encode(IPCEnvelope(request: request)))
    }

    func sendInput(surfaceID: String, _ payload: Data) throws {
        try write(IPCCodec.encodeInputFrame(surfaceID: surfaceID, payload: payload))
    }

    /// The next reply, skipping terminal output and pushed ownership notices.
    func nextReply(timeout: TimeInterval = 5) throws -> IPCResponse? {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            while let frame = try IPCCodec.decodeReplyOrData(from: &buffer) {
                guard case let .reply(response) = frame else { continue }
                switch response {
                case .sizeOwnership, .terminalResize, .snapshotChanged, .clientDirective, .data: continue
                default: return response
                }
            }
            var poller = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
            guard poll(&poller, 1, 100) >= 0 else { return nil }
            guard poller.revents & Int16(POLLIN) != 0 else { continue }
            var chunk = [UInt8](repeating: 0, count: 65_536)
            let count = read(fd, &chunk, chunk.count)
            if count < 0, errno == EAGAIN || errno == EINTR { continue }
            guard count > 0 else { return nil }
            buffer.append(contentsOf: chunk.prefix(count))
        }
        return nil
    }

    func close() { Darwin.close(fd) }

    private func write(_ data: Data) throws {
        try data.withUnsafeBytes { raw in
            var offset = 0
            while offset < raw.count {
                let written = Darwin.write(fd, raw.baseAddress! + offset, raw.count - offset)
                if written < 0, errno == EINTR || errno == EAGAIN { continue }
                guard written > 0 else { throw POSIXError(.EPIPE) }
                offset += written
            }
        }
    }
}
