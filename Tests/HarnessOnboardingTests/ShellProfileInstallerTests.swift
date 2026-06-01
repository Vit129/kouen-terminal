import XCTest
@testable import HarnessOnboarding

final class ShellProfileInstallerTests: XCTestCase {
    private func makeHome() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-onboarding-shell-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }

    private func read(_ url: URL) -> String {
        (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    func testFishPathLineQuotesApplicationSupportPathAsOneArgument() {
        let bin = URL(fileURLWithPath: "/Users/test/Library/Application Support/Harness/bin")
        XCTAssertEqual(
            ShellProfileInstaller.pathLine(for: .fish, binDirectory: bin),
            "set -gx PATH '/Users/test/Library/Application Support/Harness/bin' $PATH"
        )
    }

    func testBashAndZshPathLinesKeepPathInsideQuotes() {
        let bin = URL(fileURLWithPath: "/Users/test/Library/Application Support/Harness/bin")
        XCTAssertEqual(
            ShellProfileInstaller.pathLine(for: .zsh, binDirectory: bin),
            "export PATH=\"/Users/test/Library/Application Support/Harness/bin:$PATH\""
        )
        XCTAssertEqual(
            ShellProfileInstaller.pathLine(for: .bash, binDirectory: bin),
            "export PATH=\"/Users/test/Library/Application Support/Harness/bin:$PATH\""
        )
    }

    func testInstallAppendsOneMarkedBlockAndIsIdempotent() throws {
        let home = try makeHome()
        let bin = home.appendingPathComponent("Library/Application Support/Harness/bin")
        let first = try ShellProfileInstaller.install(.zsh, home: home, binDirectory: bin)
        XCTAssertFalse(first.alreadyConfigured)
        XCTAssertNil(first.backupURL)

        let rc = home.appendingPathComponent(".zshrc")
        let afterFirst = read(rc)
        XCTAssertTrue(afterFirst.contains("# >>> Harness CLI PATH >>>"))
        XCTAssertTrue(afterFirst.contains(bin.path))

        let second = try ShellProfileInstaller.install(.zsh, home: home, binDirectory: bin)
        XCTAssertTrue(second.alreadyConfigured)
        XCTAssertNil(second.backupURL)
        XCTAssertEqual(read(rc), afterFirst)
    }

    func testExistingProfileIsBackedUpBeforeEdit() throws {
        let home = try makeHome()
        let rc = home.appendingPathComponent(".bash_profile")
        try "alias ll='ls -la'\n".write(to: rc, atomically: true, encoding: .utf8)

        let result = try ShellProfileInstaller.install(.bash, home: home)
        XCTAssertNotNil(result.backupURL)
        XCTAssertEqual(read(result.backupURL!), "alias ll='ls -la'\n")
        XCTAssertTrue(read(rc).contains("alias ll='ls -la'"))
        XCTAssertTrue(read(rc).contains("Harness CLI PATH"))
    }

    func testExistingMarkedBlockIsReplacedNotDuplicated() throws {
        let home = try makeHome()
        let rc = home.appendingPathComponent(".config/fish/config.fish")
        try FileManager.default.createDirectory(at: rc.deletingLastPathComponent(), withIntermediateDirectories: true)
        try """
        # >>> Harness CLI PATH >>>
        set -gx PATH '/old/Harness/bin' $PATH
        # <<< Harness CLI PATH <<<
        """.write(to: rc, atomically: true, encoding: .utf8)

        let bin = URL(fileURLWithPath: "/Users/test/Library/Application Support/Harness/bin")
        _ = try ShellProfileInstaller.install(.fish, home: home, binDirectory: bin)
        let content = read(rc)
        XCTAssertFalse(content.contains("/old/Harness/bin"))
        XCTAssertTrue(content.contains("'/Users/test/Library/Application Support/Harness/bin'"))
        XCTAssertEqual(content.components(separatedBy: "# >>> Harness CLI PATH >>>").count - 1, 1)
    }
}
