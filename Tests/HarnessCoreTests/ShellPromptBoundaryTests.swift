import Foundation
import XCTest
@testable import HarnessCore

final class ShellPromptBoundaryTests: XCTestCase {
    private func run(_ shell: ShellIntegration.Shell, commands: String) throws -> String {
        let candidates = ["/opt/homebrew/bin/", "/usr/local/bin/", "/usr/bin/", "/bin/"]
        guard let executable = candidates.map({ $0 + shell.rawValue }).first(where: FileManager.default.isExecutableFile(atPath:)) else {
            throw XCTSkip("\(shell.rawValue) is not installed")
        }
        let script = FileManager.default.temporaryDirectory.appendingPathComponent("harness-prompt-\(UUID().uuidString)")
        try ShellIntegration.script(for: shell).write(to: script, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: script) }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = shell == .fish ? ["--no-config", "-ic", commands] : ["-c", commands]
        var environment = ProcessInfo.processInfo.environment
        environment["HARNESS"] = "1"
        environment["TERM"] = "xterm-256color"
        environment["HARNESS_TEST_SCRIPT"] = script.path
        process.environment = environment
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)
        return String(decoding: data, as: UTF8.self)
    }

    func testZshPromptRedrawRetainsInputBoundaryWithoutDuplicatingMarkers() throws {
        let output = try run(.zsh, commands: #"""
        PS1='first> '
        source "$HARNESS_TEST_SCRIPT"
        source "$HARNESS_TEST_SCRIPT"
        __harness_precmd
        print -Pn -- "$PS1"
        print -Pn -- "$PS1"
        PS1=$'line1\nsecond> '
        __harness_precmd
        print -Pn -- "$PS1"
        """#)
        XCTAssertEqual(output.components(separatedBy: "\u{1b}]133;A\u{7}").count - 1, 3)
        XCTAssertEqual(output.components(separatedBy: "\u{1b}]133;B\u{7}").count - 1, 3)
        XCTAssertTrue(output.contains("line1\nsecond> \u{1b}]133;B\u{7}"))
    }

    func testBashWrapsDynamicallyReplacedPromptAfterExistingHooks() throws {
        let output = try run(.bash, commands: #"""
        PS1='old> '
        PROMPT_COMMAND=('PS1="dynamic> "')
        source "$HARNESS_TEST_SCRIPT"
        source "$HARNESS_TEST_SCRIPT"
        for hook in "${PROMPT_COMMAND[@]}"; do eval "$hook"; done
        printf '%b' "${PS1//\\[/}"
        for hook in "${PROMPT_COMMAND[@]}"; do eval "$hook"; done
        printf '%b' "${PS1//\\[/}"
        """#)
        XCTAssertEqual(output.components(separatedBy: "133;A").count - 1, 2)
        XCTAssertEqual(output.components(separatedBy: "133;B").count - 1, 2)
        XCTAssertEqual(output.components(separatedBy: "dynamic> ").count - 1, 2)
    }

    func testBashStringPromptHookKeepsItsOutputAndFreshPrompt() throws {
        let output = try run(.bash, commands: #"""
        PS1='old> '
        PROMPT_COMMAND='printf "USER_HOOK"; PS1="fresh> "'
        source "$HARNESS_TEST_SCRIPT"
        source "$HARNESS_TEST_SCRIPT"
        eval "$PROMPT_COMMAND"
        printf '%b' "$PS1"
        """#)
        XCTAssertEqual(output.components(separatedBy: "USER_HOOK").count - 1, 1)
        XCTAssertEqual(output.components(separatedBy: "133;B").count - 1, 1)
        XCTAssertTrue(output.contains("fresh> "))
    }

    func testPromptHooksPreserveFailureStatus() throws {
        let bash = try run(.bash, commands: #"""
        source "$HARNESS_TEST_SCRIPT"
        false
        __harness_wrap_prompt
        printf 'PRESERVED=%s' "$?"
        """#)
        let zsh = try run(.zsh, commands: #"""
        source "$HARNESS_TEST_SCRIPT"
        false
        __harness_precmd
        printf 'PRESERVED=%s' "$?"
        """#)
        XCTAssertTrue(bash.contains("PRESERVED=1"))
        XCTAssertTrue(zsh.contains("PRESERVED=1"))
    }

    func testFishPreservesUserPromptAndRefreshesAfterThemeReplacement() throws {
        let output = try run(.fish, commands: #"""
        function fish_prompt; printf 'first> '; end
        source "$HARNESS_TEST_SCRIPT"
        source "$HARNESS_TEST_SCRIPT"
        emit fish_prompt
        fish_prompt
        function fish_prompt; printf 'second> '; end
        emit fish_prompt
        fish_prompt
        """#)
        XCTAssertTrue(output.contains("first> \u{1b}]133;B\u{7}"))
        XCTAssertTrue(output.contains("second> \u{1b}]133;B\u{7}"))
        XCTAssertEqual(output.components(separatedBy: "133;B").count - 1, 2)
    }
}
