import XCTest
@testable import HarnessCore

final class IPCReadOnlyTests: XCTestCase {
    func testViewersMayReadAndKeepTheirStreamAlive() {
        let permitted: [IPCRequest] = [
            .ping, .getSnapshot, .capturePane(surfaceID: "p", includeScrollback: true),
            .acknowledgeOutput(surfaceID: "p", token: UUID(), sequence: 1),
            .resizeSurface(surfaceID: "p", rows: 24, cols: 80), .detachSurface(surfaceID: "p"),
            .subscribeSurfaceOutputReadOnly(surfaceID: "p", label: nil),
            .attachStream(AttachRequest(surfaceID: "p", readOnly: true)),
            .presentClient(kind: "client", version: "1", uid: 501, tunnel: true),
        ]
        for request in permitted {
            XCTAssertTrue(request.permittedOnReadOnlyConnection, "\(request)")
        }
    }

    func testViewersMayNotTypeTakeControlOrUpgradeTheirRole() {
        let refused: [IPCRequest] = [
            .sendData(surfaceID: "p", data: Data("x".utf8)), .send(surfaceID: "p", text: "x"),
            .sendKeys(surfaceID: "p", keys: ["Enter"]), .pasteBuffer(surfaceID: "p", name: nil, bracketed: true),
            .takeSurface(surfaceID: "p", clientID: nil), .setSurfaceSizeMode(.smallest),
            .subscribeSurfaceOutput(surfaceID: "p", label: nil),
            .attachStream(AttachRequest(surfaceID: "p", readOnly: false)),
            .killPane(paneID: UUID()), .closeTab(tabID: UUID()), .shutdownDaemon(requireEmpty: false),
        ]
        for request in refused {
            XCTAssertFalse(request.permittedOnReadOnlyConnection, "\(request)")
        }
    }

    func testSocketPeerReadsTheKernelRecordNotAClaim() throws {
        var descriptors: [Int32] = [-1, -1]
        #if canImport(Darwin)
        let streamType = SOCK_STREAM
        #else
        let streamType = Int32(SOCK_STREAM.rawValue)
        #endif
        XCTAssertEqual(socketpair(AF_UNIX, streamType, 0, &descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        XCTAssertEqual(SocketPeer.pid(descriptors[0]), getpid())
        XCTAssertFalse(SocketPeer.isSSHForward(descriptors[0]), "the test runner is not an SSH daemon")
        XCTAssertNil(SocketPeer.pid(-1))
    }
}
