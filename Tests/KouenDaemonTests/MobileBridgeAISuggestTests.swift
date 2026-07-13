import XCTest
@testable import KouenDaemonCore

/// P37 Phase G3 (AI command suggestion via `claude` CLI subprocess). Drives the pure/cheap-guard
/// pieces of `MobileBridgeServer.runClaudeSuggest` directly — same "static, no live socket
/// needed" shape `MobileBridgeFilePreviewTests`/`MobileBridgeBrowserTests` already establish.
///
/// Deliberately NOT tested here (would need a real or faked `claude` binary, out of scope for a
/// fast unit test): successful subprocess output parsing, and the 20s timeout-kills-process path.
final class MobileBridgeAISuggestTests: XCTestCase {
    /// Regression guard for a finding from an Opus-model code review (not hit live): the CLI is
    /// asked for a single command but nothing enforces that server-side, and the reply is sent
    /// to the client as literal terminal input — an unstripped embedded newline would auto-submit
    /// an unreviewed second command the instant the user taps the suggestion (LF triggers
    /// accept-line in bash/zsh, same as CR).
    func testFirstLineStripsEmbeddedNewlines_soAMultiLineReplyCannotAutoSubmitASecondCommand() {
        XCTAssertEqual(MobileBridgeServer.firstLine(of: "rm -rf /\ntouch pwned"), "rm -rf /")
    }

    func testFirstLineHandlesCRLFAndTrailingNewline() {
        XCTAssertEqual(MobileBridgeServer.firstLine(of: "git status\r\n"), "git status")
    }

    func testFirstLineOfSingleLineTextIsUnchanged() {
        XCTAssertEqual(MobileBridgeServer.firstLine(of: "ls -la"), "ls -la")
    }

    func testFirstLineOfEmptyTextIsEmpty() {
        XCTAssertEqual(MobileBridgeServer.firstLine(of: ""), "")
    }

    func testPromptTemplateWrapsCommandBufferAndCwd() {
        let prompt = MobileBridgeServer.buildSuggestPrompt(commandBuffer: "ls .a", cwd: "/Users/vit")
        XCTAssertTrue(prompt.contains("ls .a"))
        XCTAssertTrue(prompt.contains("/Users/vit"))
        XCTAssertTrue(prompt.contains("ONLY the command"), "must instruct the CLI not to add free-form chat/explanation")
    }

    func testPromptTemplateDoesNotSilentlyDropEmptyCommandBuffer() {
        // Not a validation guard (that lives client-side — the toolbar button itself refuses to
        // send an empty commandBuffer) — just confirms the template doesn't crash/mangle on it.
        let prompt = MobileBridgeServer.buildSuggestPrompt(commandBuffer: "", cwd: "/tmp")
        XCTAssertTrue(prompt.contains("cwd=/tmp"))
    }

    func testCwdGuardFailsFastOnMissingDirectory_beforeTouchingClaudePathAtAll() {
        let missing = "/tmp/kouen-ai-suggest-test-\(UUID().uuidString)"
        let result = MobileBridgeServer.runClaudeSuggest(commandBuffer: "ls", cwd: missing)
        switch result {
        case .success:
            XCTFail("expected failure for a cwd that does not exist")
        case let .failure(error):
            XCTAssertEqual(error, MobileBridgeServer.StringError("working directory not found"))
        }
    }
}
