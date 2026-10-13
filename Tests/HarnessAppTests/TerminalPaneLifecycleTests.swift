import AppKit
@testable import HarnessCore
import HarnessTerminalKit
import XCTest
@testable import HarnessApp

@MainActor
final class TerminalPaneLifecycleTests: XCTestCase {
    @MainActor
    private final class Service {
        let process = Process()
        let home = URL(fileURLWithPath: "/tmp/hpl-" + String(UUID().uuidString.prefix(8)))
        var client: DaemonClient { DaemonClient(endpoint: endpoint) }
        var endpoint: Endpoint { .unix(path: home.appendingPathComponent("harness.sock").path) }

        func start() async throws {
            guard let products = ProcessInfo.processInfo.environment["HARNESS_TEST_PRODUCTS"] else {
                throw XCTSkip("Set HARNESS_TEST_PRODUCTS to run the real session-host lifecycle regression.")
            }
            process.executableURL = URL(fileURLWithPath: products).appendingPathComponent("HarnessSessionHost")
            var environment = ProcessInfo.processInfo.environment
            environment["HARNESS_HOME"] = home.path
            for key in ["HARNESS_SERVER", "HARNESS_SOCK", "HARNESS_SESSION", "HARNESS_TAB", "HARNESS_SURFACE"] {
                environment.removeValue(forKey: key)
            }
            process.environment = environment
            process.standardInput = FileHandle.nullDevice
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            try process.run()
            try await TerminalPaneLifecycleTests.wait("Session host must become ready") {
                guard case let .daemonStats(stats) = try? self.client.request(.daemonStats, timeout: 0.2) else { return false }
                return stats.isReadyForClient
            }
        }

        func stop() {
            guard process.isRunning else { return }
            _ = try? client.request(.shutdownDaemon(requireEmpty: false), timeout: 5)
            let deadline = Date().addingTimeInterval(5)
            while process.isRunning, Date() < deadline { Thread.sleep(forTimeInterval: 0.01) }
            if process.isRunning { process.terminate() }
            process.waitUntilExit()
            try? FileManager.default.removeItem(at: home)
        }

        func surface() throws -> PaneLeaf {
            guard case let .surfaceID(value) = try client.request(.createSurface(cwd: home.path, shell: "/bin/sh")),
                  let id = UUID(uuidString: value) else { throw DaemonClientError.unexpectedResponse }
            return PaneLeaf(surfaceID: id)
        }

        func attached(to surface: SurfaceID) throws -> Bool {
            guard case let .clients(clients) = try client.request(.listClients) else { throw DaemonClientError.unexpectedResponse }
            return clients.contains { $0.attachedSurfaceIDs.contains(surface.uuidString) }
        }
    }

    private final class Delegate: TerminalHostDelegate {
        var messages: [String] = []
        func terminalHostDidChangeTitle(_ title: String, surfaceID: SurfaceID) {}
        func terminalHostDidChangeWorkingDirectory(_ path: String, surfaceID: SurfaceID) {}
        func terminalHostDidChangeFocus(_ focused: Bool, surfaceID: SurfaceID) {}
        func terminalHostDidRingBell(surfaceID: SurfaceID) {}
        func terminalHostDidRequestDesktopNotification(title: String, body: String, surfaceID: SurfaceID) {}
        func terminalHostDidClose(surfaceID: SurfaceID) {}
        func terminalHostShowMessage(_ message: String, surfaceID: SurfaceID) { messages.append(message) }
    }

    private static func wait(_ description: String, _ condition: () throws -> Bool) async throws {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if try condition() { return }
            try await Task.sleep(for: .milliseconds(20))
        }
        XCTFail(description)
        throw DaemonClientError.timeout
    }

    func testClosingPaneReleasesConnectionWhileItsActualContentFinishesAnimating() async throws {
        _ = NSApplication.shared
        let service = Service()
        defer { service.stop() }
        try await service.start()
        let first = try service.surface(), closing = try service.surface()
        let registry = TerminalPaneRegistry(), delegate = Delegate()
        let container = PaneContainerView(tabID: UUID(), owner: DaemonSidebar.localID,
            node: .branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(closing)),
            cwd: service.home.path) { leaf in
                let host = TerminalHostView(surfaceID: leaf.surfaceID, workingDirectory: service.home.path,
                    endpoint: service.endpoint)
                host.hostDelegate = delegate
                registry.register(host)
                return host
            }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 960, height: 640),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = container
        defer { registry.prune(keeping: []); window.contentView = nil; window.close() }
        container.layoutSubtreeIfNeeded()
        let survivor = try XCTUnwrap(registry.host(for: first.surfaceID))
        let retired = try XCTUnwrap(registry.host(for: closing.surfaceID))
        let native = try XCTUnwrap(retired.subviews.compactMap { $0 as? HarnessTerminalSurfaceView }.first)
        let queuedResize = native.onResize
        try await Self.wait("Both terminal views must attach") { try service.attached(to: first.surfaceID) && service.attached(to: closing.surfaceID) }

        registry.prune(keeping: [first.surfaceID])
        // Hold the actual closing view exactly as the visual transition does.
        // Removing a registry reference must release IO without waiting for deinit.
        try await Self.wait("Registry pruning must release IO before the view leaves its window") { try !service.attached(to: closing.surfaceID) }
        XCTAssertTrue(retired.window === window)
        XCTAssertFalse(retired.isDetachedFromDaemon, "A closed pane must not show a reattach overlay")
        XCTAssertTrue(try service.attached(to: first.surfaceID))
        guard case .ok = try service.client.request(.closeSurface(surfaceID: closing.surfaceID.uuidString)) else {
            return XCTFail("The fixture surface must close")
        }
        container.update(node: .leaf(first), animated: true)
        queuedResize?(108, 31)
        retired.reattachToDaemonSurface()
        try await Task.sleep(for: .milliseconds(350))
        XCTAssertFalse(try service.attached(to: closing.surfaceID), "A retired view must never reconnect or recreate its shell")
        XCTAssertTrue(registry.host(for: first.surfaceID) === survivor)
        XCTAssertTrue(try service.attached(to: first.surfaceID))
        XCTAssertTrue(delegate.messages.isEmpty, "Closing must not emit stale IO errors: \(delegate.messages)")
        container.finishTransition()
    }

    func testResizeAlreadyInFlightWhenSurfaceClosesDrainsOutputWithoutAnError() async throws {
        let service = Service()
        defer { service.stop() }
        try await service.start()
        let surface = try service.surface().surfaceID
        let id = surface.uuidString
        guard case .ok = try service.client.request(.ensureSurface(surfaceID: id, cwd: service.home.path,
            shell: "/bin/sh", rows: 24, cols: 80, scrollbackBytes: 8 << 20)) else {
            return XCTFail("The fixture needs enough retained output to hold the final drain open")
        }
        let live = try service.client.attach(surfaceID: id, acknowledgesOutput: false, onStart: { _ in }, onData: { _, _ in })
        defer { live.cancel() }
        guard case .ok = try service.client.request(.send(surfaceID: id,
            text: "dd if=/dev/zero bs=65536 count=64 2>/dev/null; printf done > ready\n")) else {
            return XCTFail("Fixture output was not accepted")
        }
        try await Self.wait("Fixture must finish producing retained output") {
            FileManager.default.fileExists(atPath: service.home.appendingPathComponent("ready").path)
        }
        live.cancel()
        try await Self.wait("Initial fixture reader must detach") { try !service.attached(to: surface) }

        let socket = try EndpointConnector.connect(service.endpoint)
        defer { close(socket) }
        var budget: Int32 = 4096
        XCTAssertEqual(setsockopt(socket, SOL_SOCKET, SO_RCVBUF, &budget, socklen_t(MemoryLayout<Int32>.size)), 0)
        let deadline = SocketDeadline(timeout: 10)
        try deadline.write(IPCCodec.encode(IPCEnvelope(request: .attachStream(AttachRequest(surfaceID: id)))), to: socket)
        var buffer = Data(), scratch = [UInt8](repeating: 0, count: 65536)
        func readMore() throws -> Bool {
            try deadline.wait(socket, events: Int16(POLLIN))
            let count = read(socket, &scratch, scratch.count)
            if count < 0, errno == EINTR || errno == EAGAIN { return true }
            guard count >= 0 else { throw DaemonClientError.connectionFailed }
            buffer.append(contentsOf: scratch.prefix(count))
            return count > 0
        }
        var attached = false, outputBytes = 0
        while !attached {
            guard try readMore() else { return XCTFail("Missing attach barrier") }
            while let frame = try IPCCodec.decodeReplyOrData(from: &buffer) {
                if case .reply(.attached) = frame { attached = true }
                if case let .output(bytes, _) = frame { outputBytes += bytes.count }
            }
        }
        guard case .ok = try service.client.request(.closeSurface(surfaceID: id)) else { return XCTFail("Fixture must close") }
        try await Self.wait("PTY must retire while its final output is still buffered") { try !service.attached(to: surface) }
        try deadline.write(IPCCodec.encode(IPCEnvelope(request: .resizeSurface(surfaceID: id, rows: 31, cols: 108))), to: socket)
        var errors: [String] = []
        while try readMore() {
            while let frame = try IPCCodec.decodeReplyOrData(from: &buffer) {
                if case let .reply(.error(message)) = frame { errors.append(message) }
                if case let .output(bytes, _) = frame { outputBytes += bytes.count }
            }
        }
        XCTAssertTrue(buffer.isEmpty, "Final output must end on a complete frame")
        XCTAssertGreaterThan(outputBytes, 1 << 20, "The test must exercise a real buffered output drain")
        XCTAssertTrue(errors.isEmpty, "A late resize after normal close must not report Surface not found: \(errors)")
        guard case .error = try service.client.request(.resizeSurface(surfaceID: id, rows: 31, cols: 108)) else {
            return XCTFail("Independent requests for nonexistent surfaces must still fail")
        }
    }
}
