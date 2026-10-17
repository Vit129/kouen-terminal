#if canImport(Network)
import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

final class MobileBridgeContractTests: XCTestCase {
    /// `.panel-bg`/`.toast` set `display:flex`, which beats the UA `[hidden]` rule — without this
    /// override the empty sheet and toast show on every load.
    /// Claude Code emits CSI with private `<`/`>`/`=` params (kitty keyboard, modifyOtherKeys);
    /// the old `[0-9;?]` class let `[<u`, `[>5u`, `[>4;2m` leak into the transcript.
    func testStripANSIMatchesFullCSIGrammar() {
        XCTAssertTrue(MobileBridgeServer.embeddedPageHTML.contains(#"/\x1b\[[0-?]*[ -\/]*[@-~]/g"#))
    }

    /// TS-5711: the client reads `transcript.reset`, `transcript.items[].{id,role,text,toolName,toolTarget}`.
    func testTS5711_transcriptPushShapeMatchesClient() throws {
        let push = MobileBridgeServer.TranscriptPush(transcript: .init(reset: true, items: [
            TranscriptItem(id: "a#0", role: .assistant, text: "hi"),
            TranscriptItem(id: "a#1", role: .tool, text: "", toolName: "Edit", toolTarget: "x.swift"),
        ]))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(push)) as? [String: Any])
        let body = try XCTUnwrap(json["transcript"] as? [String: Any])
        XCTAssertEqual(body["reset"] as? Bool, true)
        let items = try XCTUnwrap(body["items"] as? [[String: Any]])
        XCTAssertEqual(items[0]["role"] as? String, "assistant")
        XCTAssertEqual(items[0]["text"] as? String, "hi")
        XCTAssertEqual(items[1]["role"] as? String, "tool")
        XCTAssertEqual(items[1]["toolName"] as? String, "Edit")
        XCTAssertEqual(items[1]["toolTarget"] as? String, "x.swift")
        XCTAssertEqual(items[1]["id"] as? String, "a#1")
    }

    // The page's liveness check: `{"ping":N}` must decode (else the daemon answers
    // "unrecognized control message" and every ping times out into a reconnect loop).
    func testPingControlMessageDecodesAndPageAnswersPong() throws {
        let msg = try JSONDecoder().decode(MobileBridgeServer.ControlMessage.self, from: Data(#"{"ping":7}"#.utf8))
        XCTAssertEqual(msg.ping, 7)
        XCTAssertNil(msg.attach)
        XCTAssertTrue(MobileBridgeServer.embeddedPageHTML.contains("if (msg.pong !== undefined) { onPong(); return; }"))
    }

    func testPageCSSKeepsHiddenElementsHidden() {
        XCTAssertTrue(MobileBridgeServer.embeddedPageHTML.contains("[hidden]{display:none !important}"))
    }

    func testPageCarriesTheSidebarBrandIconsAndTints() throws {
        let page = MobileBridgeServer.embeddedPageHTML
        XCTAssertTrue(page.contains("const AGENT_ICONS = {"))
        let json = MobileBridgeServer.agentIconsJS.dropFirst("const AGENT_ICONS = ".count).dropLast()
        let map = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: [String: String]])
        for kind in ["claude-code", "codex", "antigravity", "copilot"] {
            XCTAssertTrue(map[kind]?["svg"]?.hasPrefix("<svg viewBox=") == true, kind)
        }
        XCTAssertEqual(map["antigravity"]?["c"], "#3186ff")
        XCTAssertNil(map["generic"]?["svg"])
        XCTAssertTrue(page.contains("--bg:#000000"))
    }

    func testPageCSSIncludesTheTextWrapRules() {
        XCTAssertTrue(MobileBridgeServer.embeddedPageHTML.contains(".msg,.bot,.tool,.ask{overflow-wrap:break-word"))
        XCTAssertFalse(MobileBridgeServer.embeddedPageHTML.contains("textWrapCSS"))
    }

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

    /// `runPairingLoop` calls `runProcess` from one never-ending GCD block, so its autorelease
    /// pool never drains: pipe fds must be closed by `runProcess` itself, not by deallocation.
    /// Leaked 4 fds per Tailscale re-check (30s) until the daemon hit EMFILE (2026-10-15).
    func testRunProcessClosesPipeFDsWithoutAutoreleaseDrain() throws {
        func openFDs() throws -> Int { try FileManager.default.contentsOfDirectory(atPath: "/dev/fd").count }
        let before = try openFDs()
        for _ in 0..<50 {
            _ = MobileBridgeServer.runProcess(
                executableURL: URL(fileURLWithPath: "/bin/echo"), arguments: ["x"], timeoutSeconds: 5)
        }
        XCTAssertLessThan(try openFDs() - before, 10, "runProcess leaked pipe fds")
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

    func testRunProcessKeepsTheLastLineOfOutput() {
        // gh prints the PR URL last; losing the final chunk drops it.
        let res = MobileBridgeServer.runProcess(
            executableURL: URL(fileURLWithPath: "/bin/sh"),
            arguments: ["-c", "head -c 200000 /dev/zero | tr '\\0' x; echo; echo https://github.com/o/r/pull/7"],
            timeoutSeconds: 10
        )
        XCTAssertEqual(res.status, 0)
        XCTAssertTrue(res.stdout.hasSuffix("https://github.com/o/r/pull/7\n"))
    }

    func testServeStatusMustProxyTheBridgePort() {
        let ours = #"{"Web":{"mac.ts.net:443":{"Handlers":{"/":{"Proxy":"http://127.0.0.1:8080"}}}}}"#
        let other = #"{"Web":{"mac.ts.net:443":{"Handlers":{"/":{"Proxy":"http://127.0.0.1:3000"}}}}}"#
        XCTAssertTrue(MobileBridgeServer.serveStatusProxiesPort(ours, port: 8080))
        XCTAssertFalse(MobileBridgeServer.serveStatusProxiesPort(other, port: 8080))
        XCTAssertFalse(MobileBridgeServer.serveStatusProxiesPort(#"{"TCP":{"443":{}}}"#, port: 8080))
        XCTAssertFalse(MobileBridgeServer.serveStatusProxiesPort("{}", port: 8080))
    }

    func testDiffContentLinesThatLookLikeHeadersAreCounted() {
        let diff = """
        diff --git a/notes.sql b/notes.sql
        --- a/notes.sql
        +++ b/notes.sql
        @@ -1,2 +1,2 @@
        --- a/old comment
        +++ b/new comment
         keep
        """
        let files = MobileBridgeServer.parseGitDiffOutput(diff)
        XCTAssertEqual(files.map(\.path), ["notes.sql"])
        XCTAssertEqual(files.first?.additions, 1)
        XCTAssertEqual(files.first?.deletions, 1)
    }

    func testSymlinkInsideSessionCwdCannotEscapeIt() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let cwd = root.appendingPathComponent("repo"), outside = root.appendingPathComponent("secret")
        try FileManager.default.createDirectory(at: cwd, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createSymbolicLink(at: cwd.appendingPathComponent("link"), withDestinationURL: outside)

        let escaped = MobileBridgeServer.resolveAuthorizedCwd(
            requestedPath: cwd.appendingPathComponent("link").path, surfaceID: "s", surfaceLookup: { _ in cwd.path })
        XCTAssertEqual(escaped, .failure(.foreignPathRejected))
        let inside = MobileBridgeServer.resolveAuthorizedCwd(requestedPath: cwd.path, surfaceID: "s", surfaceLookup: { _ in cwd.path })
        XCTAssertNotNil(try? inside.get())
    }

    func testReadFileIsLimitedToSessionCwdAndAgyBrain() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let cwd = root.appendingPathComponent("repo"), brain = root.appendingPathComponent("brain")
        try FileManager.default.createDirectory(at: cwd, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: brain, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        func check(_ p: String) -> String? {
            MobileBridgeServer.authorizedReadPath(p, surfaceID: "s", surfaceLookup: { _ in cwd.path }, extraRoots: [brain.path])
        }

        XCTAssertNotNil(check(cwd.appendingPathComponent("index.html").path))
        XCTAssertNotNil(check(brain.appendingPathComponent("conv/showcase.md").path))
        XCTAssertNil(check(NSHomeDirectory() + "/.ssh/id_ed25519"))
        XCTAssertNil(check(brain.path + "/../repo-sibling/x"))
        XCTAssertNil(check("/etc/passwd"))
    }

    func testEmbeddedPageHTMLHasUsageChipAndModal() {
        let html = MobileBridgeServer.embeddedPageHTML
        XCTAssertTrue(html.contains(#"id="usage-chip""#))
        XCTAssertTrue(html.contains("openUsage()"))
        XCTAssertTrue(html.contains("Token & Cost Breakdown") || html.contains("Token &amp; Cost Breakdown"))
    }

    func testTranscriptPushIncludesUsage() throws {
        var usage = AgentUsage()
        usage.inputTokens = 1200
        usage.cacheReadTokens = 800
        usage.outputTokens = 150
        let push = MobileBridgeServer.TranscriptPush(transcript: .init(reset: false, items: [], usage: usage))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(push)) as? [String: Any])
        let body = try XCTUnwrap(json["transcript"] as? [String: Any])
        let usageObj = try XCTUnwrap(body["usage"] as? [String: Any])
        XCTAssertEqual(usageObj["inputTokens"] as? Int, 1200)
        XCTAssertEqual(usageObj["cacheReadTokens"] as? Int, 800)
        XCTAssertEqual(usageObj["contextTokens"] as? Int, 2000)
        XCTAssertEqual(usageObj["shortSummary"] as? String, "2.0k ctx")
    }
}
#endif
