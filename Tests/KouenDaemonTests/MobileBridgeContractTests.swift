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
        let ack = MobileBridgeServer.FileAttachedAck(path: "/tmp/uploads/test.png", name: "test.png")
        let data = try JSONEncoder().encode(ack)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["ok"] as? String, "fileAttached")
        XCTAssertEqual(json["path"] as? String, "/tmp/uploads/test.png")
        XCTAssertEqual(json["name"] as? String, "test.png")
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

    func testEmbeddedPageHTMLSubmitsWithCarriageReturnAndSendsAttachedPaths() {
        let html = MobileBridgeServer.embeddedPageHTML
        XCTAssertTrue(html.contains(#"encode(ans + '\r')"#))
        XCTAssertTrue(html.contains(#"encode(toSend + '\r')"#))
        XCTAssertTrue(html.contains("readyPaths"))
    }

    func testEmbeddedPageHTMLOneTapPRHasNoModalSheet() {
        let html = MobileBridgeServer.embeddedPageHTML
        XCTAssertFalse(html.contains(#"id="sheet""#))
        XCTAssertFalse(html.contains(#"id="pr-title""#))
        XCTAssertTrue(html.contains(#"ws.send(JSON.stringify({ createDraftPR: { title: cur.name || "Draft PR", path: cur.cwd } }))"#))
    }

    func testEmbeddedPageHTMLPreviewUsesRealBrowserMirrorAndNoMockupCaptions() {
        let html = MobileBridgeServer.embeddedPageHTML
        XCTAssertFalse(html.contains("docs/companion-mockup.html"))
        XCTAssertFalse(html.contains("Renders straight from your workspace"))
        XCTAssertFalse(html.contains("claude.ai/artifact/…"))
        XCTAssertTrue(html.contains("browserNavigate"))
        XCTAssertTrue(html.contains("browserScreenshot"))
        XCTAssertTrue(html.contains("browserFrame"))
        XCTAssertTrue(html.contains("pv-frame"))
        XCTAssertTrue(html.contains("readFile"))
    }

    func testRunProcessSuccessAndOutputs() {
        let res = MobileBridgeServer.runProcess(
            executableURL: URL(fileURLWithPath: "/bin/echo"),
            arguments: ["hello", "world"],
            timeoutSeconds: 5
        )
        XCTAssertEqual(res.status, 0)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "hello world")
        XCTAssertFalse(res.timedOut)
    }

    func testRunProcessTimeoutKillsSubprocess() {
        let start = Date()
        let res = MobileBridgeServer.runProcess(
            executableURL: URL(fileURLWithPath: "/bin/sleep"),
            arguments: ["5"],
            timeoutSeconds: 0.1
        )
        let duration = Date().timeIntervalSince(start)
        XCTAssertTrue(res.timedOut)
        XCTAssertLessThan(duration, 2.0)
    }

    func testParseGitDiffHandlesRenamesAndSpaces() {
        let sampleDiff = """
        diff --git a/old path/old file.txt b/new path/new file.txt
        similarity index 100%
        rename from old path/old file.txt
        rename to new path/new file.txt
        --- a/old path/old file.txt
        +++ b/new path/new file.txt
        @@ -1,2 +1,3 @@
         unchanged
        +added line
        """
        let files = MobileBridgeServer.parseGitDiffOutput(sampleDiff)
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.path, "new path/new file.txt")
        XCTAssertEqual(files.first?.additions, 1)
        XCTAssertEqual(files.first?.deletions, 0)
    }

    func testBuildPairingURLGeneratesHTTPSWhenServeIsActive() {
        let httpsURL = MobileBridgeServer.buildPairingURL(
            host: "100.94.236.66",
            pageURLPort: 7777,
            wsPort: 7777,
            token: "123456",
            magicDNSName: "supavits-macbook-pro.tail454c08.ts.net",
            isServeActive: true
        )
        XCTAssertEqual(httpsURL, "https://supavits-macbook-pro.tail454c08.ts.net/?token=123456")

        let httpFallback = MobileBridgeServer.buildPairingURL(
            host: "100.94.236.66",
            pageURLPort: 7777,
            wsPort: 7777,
            token: "123456",
            magicDNSName: "supavits-macbook-pro.tail454c08.ts.net",
            isServeActive: false
        )
        XCTAssertEqual(httpFallback, "http://100.94.236.66:7777/?token=123456&wsport=7777")
    }

    func testEmbeddedPageHTMLHasNoGoogleFontsAndUsesSystemFonts() {
        let html = MobileBridgeServer.embeddedPageHTML
        XCTAssertFalse(html.contains("fonts.googleapis.com"))
        XCTAssertFalse(html.contains("fonts.gstatic.com"))
        XCTAssertTrue(html.contains("-apple-system"))
        XCTAssertTrue(html.contains("scheduleGitDiff"))
        XCTAssertTrue(html.contains("65536"))
    }
}
#endif
