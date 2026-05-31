import XCTest
@testable import HarnessCore

final class ShellCompletionInstallerTests: XCTestCase {
    private func makeHome() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-comp-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }

    private func read(_ url: URL) -> String {
        (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    // MARK: - fish: native drop-in, no rc edit

    func testFishInstallsDropInAndWiresNoRc() throws {
        let home = try makeHome()
        let result = try ShellCompletionInstaller.install(for: .fish, homeOverride: home)
        XCTAssertNil(result.rcPath, "fish auto-loads from its completions dir; no rc wiring")
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.scriptPath.path))
        XCTAssertTrue(read(result.scriptPath).contains("complete -c harness-cli"))
        // No shell rc files were created for fish.
        XCTAssertFalse(FileManager.default.fileExists(atPath: home.appendingPathComponent(".zshrc").path))
    }

    // MARK: - zsh/bash: guarded, idempotent, backed-up rc wiring

    func testZshWiresRcWithGuardedSourceBlock() throws {
        let home = try makeHome()
        let result = try ShellCompletionInstaller.install(for: .zsh, homeOverride: home)
        XCTAssertEqual(result.shell, .zsh)
        XCTAssertFalse(result.alreadyWired)
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.scriptPath.path))
        let rc = read(home.appendingPathComponent(".zshrc"))
        XCTAssertTrue(rc.contains("Harness CLI completions"), "guarded marker block present")
        XCTAssertTrue(rc.contains(result.scriptPath.path), "rc sources the installed script")
        XCTAssertTrue(rc.contains("compinit"), "zsh block bootstraps compinit when needed")
    }

    func testReinstallIsIdempotentNoDuplicateBlock() throws {
        let home = try makeHome()
        _ = try ShellCompletionInstaller.install(for: .zsh, homeOverride: home)
        let again = try ShellCompletionInstaller.install(for: .zsh, homeOverride: home)
        XCTAssertTrue(again.alreadyWired, "second install must not append a second block")
        let rc = read(home.appendingPathComponent(".zshrc"))
        let occurrences = rc.components(separatedBy: "# >>> Harness CLI completions >>>").count - 1
        XCTAssertEqual(occurrences, 1, "exactly one completion block")
    }

    func testBashWiresRcAndBacksUpExistingFile() throws {
        let home = try makeHome()
        let rcURL = home.appendingPathComponent(".bashrc")
        try "echo existing-user-content\n".write(to: rcURL, atomically: true, encoding: .utf8)
        let result = try ShellCompletionInstaller.install(for: .bash, homeOverride: home)
        XCTAssertNotNil(result.rcBackedUp, "an existing rc is backed up before editing")
        let rc = read(rcURL)
        XCTAssertTrue(rc.contains("echo existing-user-content"), "user content preserved")
        XCTAssertTrue(rc.contains("source \"\(result.scriptPath.path)\""), "bash sources the script directly")
        XCTAssertEqual(read(result.rcBackedUp!), "echo existing-user-content\n")
    }

    // MARK: - login-shell convenience

    func testInstallForLoginShellZshWiresRcAndDropsFish() throws {
        let home = try makeHome()
        let lines = try ShellCompletionInstaller.installForLoginShell(shellPath: "/bin/zsh", homeOverride: home)
        XCTAssertTrue(lines.contains { $0.hasPrefix("fish-completion:") }, "fish drop-in always laid down")
        XCTAssertTrue(lines.contains { $0.hasPrefix("zsh-completion:") }, "zsh login wired")
        XCTAssertTrue(read(home.appendingPathComponent(".zshrc")).contains("Harness CLI completions"))
        // The fish drop-in exists and is inert without fish.
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: home.appendingPathComponent(".config/fish/completions/harness-cli.fish").path))
    }

    func testInstallForLoginShellFishTouchesNoRc() throws {
        let home = try makeHome()
        let lines = try ShellCompletionInstaller.installForLoginShell(shellPath: "/opt/homebrew/bin/fish", homeOverride: home)
        XCTAssertEqual(lines.count, 1, "fish login: only the fish drop-in, no rc wiring")
        XCTAssertTrue(lines[0].hasPrefix("fish-completion:"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: home.appendingPathComponent(".zshrc").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: home.appendingPathComponent(".bashrc").path))
    }
}
