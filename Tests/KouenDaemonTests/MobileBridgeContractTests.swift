#if canImport(Network)
import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

final class MobileBridgeContractTests: XCTestCase {
    func testDraftPRAckJSONShapeMatchesClientExpectations() throws {
        let ack = MobileBridgeServer.DraftPRAck(url: "https://github.com/Vit129/kouen-terminal/pull/88", number: 88)
        let data = try JSONEncoder().encode(ack)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["ok"] as? String, "draftPRCreated")
        XCTAssertEqual(json["url"] as? String, "https://github.com/Vit129/kouen-terminal/pull/88")
        XCTAssertEqual(json["number"] as? Int, 88)
    }

    func testFileAttachedAckJSONShapeMatchesClientExpectations() throws {
        let ack = MobileBridgeServer.FileAttachedAck(path: "/tmp/uploads/test.png")
        let data = try JSONEncoder().encode(ack)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["ok"] as? String, "fileAttached")
        XCTAssertEqual(json["path"] as? String, "/tmp/uploads/test.png")
    }
}
#endif
