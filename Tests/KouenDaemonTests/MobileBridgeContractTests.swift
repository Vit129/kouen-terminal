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

    func testResolveAuthorizedCwdRejectsForeignPath() {
        let mockSurfaceLookup: (String) -> String? = { id in
            id == "surface-1" ? "/Users/test/workspace/repo" : nil
        }

        // Exact cwd matches
        let exact = MobileBridgeServer.resolveAuthorizedCwd(
            requestedPath: "/Users/test/workspace/repo",
            surfaceID: "surface-1",
            surfaceLookup: mockSurfaceLookup
        )
        XCTAssertEqual(try? exact.get(), "/Users/test/workspace/repo")

        // Subdirectory matches
        let subpath = MobileBridgeServer.resolveAuthorizedCwd(
            requestedPath: "/Users/test/workspace/repo/subdir",
            surfaceID: "surface-1",
            surfaceLookup: mockSurfaceLookup
        )
        XCTAssertEqual(try? subpath.get(), "/Users/test/workspace/repo/subdir")

        // Foreign path is rejected
        let foreign = MobileBridgeServer.resolveAuthorizedCwd(
            requestedPath: "/etc/passwd",
            surfaceID: "surface-1",
            surfaceLookup: mockSurfaceLookup
        )
        XCTAssertEqual(foreign, .failure(.foreignPathRejected))

        // Relative traversal escaping surface cwd is rejected
        let traversal = MobileBridgeServer.resolveAuthorizedCwd(
            requestedPath: "/Users/test/workspace/repo/../../secret",
            surfaceID: "surface-1",
            surfaceLookup: mockSurfaceLookup
        )
        XCTAssertEqual(traversal, .failure(.foreignPathRejected))

        // Missing surface session
        let missing = MobileBridgeServer.resolveAuthorizedCwd(
            requestedPath: nil,
            surfaceID: "unknown-surface",
            surfaceLookup: mockSurfaceLookup
        )
        XCTAssertEqual(missing, .failure(.missingSessionOrCwd))
    }

    func testEmbeddedPageHTMLHasQuoteEscapedEscFunction() {
        let html = MobileBridgeServer.embeddedPageHTML
        XCTAssertTrue(html.contains("function esc(t)"))
        XCTAssertTrue(html.contains(#"replace(/[&<>"']/g"#))
        XCTAssertTrue(html.contains("&quot;"))
        XCTAssertTrue(html.contains("&#39;"))
    }
}
#endif
