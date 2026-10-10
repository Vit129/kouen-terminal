#if canImport(Network)
import XCTest
@testable import KouenDaemonCore

final class MobileBridgeGitDiffTests: XCTestCase {
    func testEmptyDiffOutputReturnsEmptyArray() {
        XCTAssertEqual(MobileBridgeServer.parseGitDiffOutput(""), [])
        XCTAssertEqual(MobileBridgeServer.parseGitDiffOutput("   \n\n  "), [])
    }

    func testSplitsHunksPerFile() {
        let sampleDiff = """
        diff --git a/Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift b/Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift
        index 1234567..89abcdef 100644
        --- a/Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift
        +++ b/Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift
        @@ -1204,6 +1204,12 @@ case "readFile":
             case "readFile":
                 handleReadFile(msg, on: conn)
        +    case "gitDiff":
        +        guard let path = msg.worktreePath else {
        +            return sendError("missing worktree", on: conn)
        +        }
        +        handleGitDiff(path, on: conn)
             case "attach":
        diff --git a/Tests/KouenDaemonTests/MobileBridgeGitDiffTests.swift b/Tests/KouenDaemonTests/MobileBridgeGitDiffTests.swift
        new file mode 100644
        index 0000000..abcdef1
        --- /dev/null
        +++ b/Tests/KouenDaemonTests/MobileBridgeGitDiffTests.swift
        @@ -0,0 +1,6 @@
        +import XCTest
        +@testable import KouenDaemonCore
        +
        +final class MobileBridgeGitDiffTests: XCTestCase {
        +    func testSplitsHunksPerFile() throws {
        +}
        """

        let files = MobileBridgeServer.parseGitDiffOutput(sampleDiff)
        XCTAssertEqual(files.count, 2)

        let first = files[0]
        XCTAssertEqual(first.path, "Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift")
        XCTAssertEqual(first.additions, 5)
        XCTAssertEqual(first.deletions, 0)
        XCTAssertTrue(first.uncommitted)
        XCTAssertTrue(first.lines.contains { $0.hasPrefix("@@") })
        XCTAssertTrue(first.lines.contains { $0.contains("case \"gitDiff\":") })

        let second = files[1]
        XCTAssertEqual(second.path, "Tests/KouenDaemonTests/MobileBridgeGitDiffTests.swift")
        XCTAssertEqual(second.additions, 6)
        XCTAssertEqual(second.deletions, 0)
        XCTAssertTrue(second.uncommitted)
        XCTAssertEqual(second.lines.first, "@@ -0,0 +1,6 @@")
    }

    func testAdditionsAndDeletionsCount() {
        let sampleDiff = """
        diff --git a/docs/USAGE.md b/docs/USAGE.md
        index aaa..bbb 100644
        --- a/docs/USAGE.md
        +++ b/docs/USAGE.md
        @@ -88,3 +88,8 @@
        -old line 1
        -old line 2
        +new line 1
        +new line 2
        +new line 3
         context line
        """

        let files = MobileBridgeServer.parseGitDiffOutput(sampleDiff)
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files[0].path, "docs/USAGE.md")
        XCTAssertEqual(files[0].additions, 3)
        XCTAssertEqual(files[0].deletions, 2)
    }

    func testManifestAndServiceWorkerResponses() {
        let manifest = String(data: MobileBridgeServer.manifestResponse, encoding: .utf8) ?? ""
        XCTAssertTrue(manifest.contains("HTTP/1.1 200 OK"))
        XCTAssertTrue(manifest.contains("application/manifest+json"))
        XCTAssertTrue(manifest.contains("Kouen Companion"))

        let sw = String(data: MobileBridgeServer.serviceWorkerResponse, encoding: .utf8) ?? ""
        XCTAssertTrue(sw.contains("HTTP/1.1 200 OK"))
        XCTAssertTrue(sw.contains("application/javascript"))
        XCTAssertTrue(sw.contains("kouen-companion-v1"))

        let icon = String(data: MobileBridgeServer.iconResponse, encoding: .utf8) ?? ""
        XCTAssertTrue(icon.contains("HTTP/1.1 200 OK"))
        XCTAssertTrue(icon.contains("image/svg+xml"))
    }
}
#endif
