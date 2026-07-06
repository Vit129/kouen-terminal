import XCTest
@testable import KouenCore

final class DaemonSessionServiceTests: XCTestCase {
    func testDefaultsToLocalEndpoint() {
        XCTAssertEqual(DaemonSessionService().endpoint, .localControlSocket)
    }

    func testSwitchEndpointUpdatesTarget() {
        let service = DaemonSessionService()
        let remote = Endpoint.unix(path: "/tmp/kouen-remote.sock")
        service.switchEndpoint(remote)
        XCTAssertEqual(service.endpoint, remote)
        service.switchEndpoint(.localControlSocket)
        XCTAssertEqual(service.endpoint, .localControlSocket)
    }
}
