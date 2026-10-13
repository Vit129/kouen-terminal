import Foundation
import XCTest
@testable import HarnessCore

final class DefaultTerminalLaunchRequestTests: XCTestCase {
    func testShellQuotingLeavesSafePathsBareAndQuotesUnsafePaths() {
        XCTAssertEqual(ShellQuoting.quote("/tmp/plain-file"), "/tmp/plain-file")
        XCTAssertEqual(ShellQuoting.quote("/tmp/My Folder/it's final.command"), "'/tmp/My Folder/it'\\''s final.command'")
    }

    func testSSHURLBuildsCommandWithUserAndPort() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "ssh://robert@example.com:2222")!))

        XCTAssertEqual(request.command, "ssh -p 2222 -- robert@example.com")
        XCTAssertEqual(request.title, "ssh example.com")
    }

    func testSSHURLWrapsIPv6HostAfterEndOfOptions() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "ssh://[fe80::1]:22")!))

        XCTAssertEqual(request.command, "ssh -p 22 -- '[fe80::1]'")
    }

    func testOptionShapedURLOperandsAreRejected() {
        let hostile = [
            "x-man-page://-Pecho%20pwned/ls",
            "x-man-page://ls/-Pecho",
            "x-man-page://-Popen",
            "x-man-page://ls/a%0Ab",
            "ssh://-oProxyCommand=echo",
            "ssh://-oProxyCommand=echo@example.com",
            "ssh://example.com%20-oProxyCommand=echo",
            "ssh://a%40b@example.com",
            "telnet://-lroot",
            "telnet://exa%20mple.com",
        ]
        for raw in hostile {
            guard let url = URL(string: raw) else { continue }
            XCTAssertNil(DefaultTerminalLaunchRequest.make(for: url), raw)
        }
    }

    func testAcceptedRequestsKeepOperandsAfterEndOfOptions() {
        for raw in ["ssh://example.com", "ssh://me@example.com:2200", "x-man-page://ls", "x-man-page://1/git-log"] {
            let command = DefaultTerminalLaunchRequest.make(for: URL(string: raw)!)?.command ?? ""
            let words = command.split(separator: " ")
            guard let separator = words.firstIndex(of: "--") else { XCTFail(raw); continue }
            XCTAssertFalse(words[(separator + 1)...].contains { $0.hasPrefix("-") || $0.hasPrefix("'-") }, raw)
        }
    }

    func testTelnetURLBuildsCommandWithPort() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "telnet://example.com:2323")!))

        XCTAssertEqual(request.command, "telnet example.com 2323")
        XCTAssertEqual(request.title, "telnet example.com")
    }

    func testManPageURLBuildsCommand() throws {
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: URL(string: "x-man-page://3/printf")!))

        XCTAssertEqual(request.command, "man -- 3 printf")
        XCTAssertEqual(request.title, "man printf")
    }

    func testDirectoryFileURLOpensAsCWD() throws {
        let url = URL(fileURLWithPath: "/tmp/Harness Folder", isDirectory: true)
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: url, fileIsDirectory: { _ in true }))

        XCTAssertNil(request.command)
        XCTAssertEqual(request.cwd, "/tmp/Harness Folder")
        XCTAssertEqual(request.title, "Harness Folder")
    }

    func testCommandFileURLRunsQuotedPathInParentDirectory() throws {
        let url = URL(fileURLWithPath: "/tmp/Harness Folder/run me.command")
        let request = try XCTUnwrap(DefaultTerminalLaunchRequest.make(for: url, fileIsDirectory: { _ in false }))

        XCTAssertEqual(request.command, "'/tmp/Harness Folder/run me.command'")
        XCTAssertEqual(request.cwd, "/tmp/Harness Folder")
        XCTAssertEqual(request.title, "run me.command")
    }
}
