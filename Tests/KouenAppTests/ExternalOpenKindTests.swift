import Foundation
import XCTest
@testable import KouenApp

/// The `.kouentheme`-vs-terminal routing decision that `AppDelegate` makes before opening an
/// external URL. Theme files must take the theme-import branch; everything else (folders, scripts,
/// ssh/man URLs) must keep routing to the terminal opener.
final class ExternalOpenKindTests: XCTestCase {
    func testKouenThemeFileRoutesToTheme() {
        let url = URL(fileURLWithPath: "/tmp/Cool Theme.kouentheme")
        XCTAssertEqual(ExternalOpenKind(for: url), .theme)
    }

    func testThemeExtensionIsCaseInsensitive() {
        let url = URL(fileURLWithPath: "/tmp/Cool.KOUENTHEME")
        XCTAssertEqual(ExternalOpenKind(for: url), .theme)
    }

    func testCommandFileStaysTerminal() {
        let url = URL(fileURLWithPath: "/tmp/deploy.command")
        XCTAssertEqual(ExternalOpenKind(for: url), .terminal)
    }

    func testToolAndShellScriptsStayTerminal() {
        XCTAssertEqual(ExternalOpenKind(for: URL(fileURLWithPath: "/tmp/build.tool")), .terminal)
        XCTAssertEqual(ExternalOpenKind(for: URL(fileURLWithPath: "/tmp/run.sh")), .terminal)
    }

    func testDirectoryStaysTerminal() {
        let url = URL(fileURLWithPath: "/Users/me/Projects", isDirectory: true)
        XCTAssertEqual(ExternalOpenKind(for: url), .terminal)
    }

    func testNonFileURLStaysTerminal() {
        // ssh/telnet/man-page URLs arrive as non-file URLs and must never be treated as themes,
        // even if a path component coincidentally ends in the extension.
        let url = URL(string: "ssh://host/x.kouentheme")!
        XCTAssertEqual(ExternalOpenKind(for: url), .terminal)
    }

    func testExtensionlessFileStaysTerminal() {
        let url = URL(fileURLWithPath: "/usr/local/bin/some-executable")
        XCTAssertEqual(ExternalOpenKind(for: url), .terminal)
    }
}
