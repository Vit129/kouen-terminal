import Foundation
import XCTest
@testable import KouenCore

final class DefaultTerminalLaunchRequestTests: XCTestCase {
    func testShellQuotingLeavesSafePathsBareAndQuotesUnsafePaths() {
        XCTAssertEqual(ShellQuoting.quote("/tmp/plain-file"), "/tmp/plain-file")
        XCTAssertEqual(ShellQuoting.quote("/tmp/My Folder/it's final.command"), "'/tmp/My Folder/it'\\''s final.command'")
    }

    func testSSHURLBuildsCommandWithUserAndPort() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "ssh://robert@example.com:2222")!))

        XCTAssertEqual(request.command, "ssh -p 2222 robert@example.com")
        XCTAssertEqual(request.title, "ssh example.com")
    }

    func testTelnetURLBuildsCommandWithPort() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "telnet://example.com:2323")!))

        XCTAssertEqual(request.command, "telnet example.com 2323")
        XCTAssertEqual(request.title, "telnet example.com")
    }

    func testManPageURLBuildsCommand() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "x-man-page://3/printf")!))

        XCTAssertEqual(request.command, "man 3 printf")
        XCTAssertEqual(request.title, "man printf")
    }

    func testDirectoryFileURLOpensAsCWD() throws {
        let url = URL(fileURLWithPath: "/tmp/Kouen Folder", isDirectory: true)
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: url, fileIsDirectory: { _ in true }))

        XCTAssertNil(request.command)
        XCTAssertEqual(request.cwd, "/tmp/Kouen Folder")
        XCTAssertEqual(request.title, "Kouen Folder")
    }

    func testCommandFileURLRunsQuotedPathInParentDirectory() throws {
        let url = URL(fileURLWithPath: "/tmp/Kouen Folder/run me.command")
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: url, fileIsDirectory: { _ in false }))

        XCTAssertEqual(request.command, "'/tmp/Kouen Folder/run me.command'")
        XCTAssertEqual(request.cwd, "/tmp/Kouen Folder")
        XCTAssertEqual(request.title, "run me.command")
    }
}
