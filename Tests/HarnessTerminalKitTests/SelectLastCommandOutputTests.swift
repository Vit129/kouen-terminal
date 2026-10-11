import Foundation
import XCTest
@testable import HarnessTerminalKit

/// Command actions follow OSC 133 boundaries rather than guessing from prompt rows.
@MainActor
final class SelectLastCommandOutputTests: XCTestCase {
    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    private func settle(_ view: HarnessTerminalSurfaceView) async {
        view.testingWaitForEmulatorIdle()
        await drainMainQueue()
    }

    func testSelectsTheLastFinishedCommandsOutput() async {
        let view = HarnessTerminalSurfaceView()
        view.receive("\u{1b}]133;A\u{07}$ \u{1b}]133;B\u{07}make test\r\n\u{1b}]133;C\u{07}")
        view.receive("building things\r\nall tests green\r\n")
        view.receive("\u{1b}]133;D;0\u{07}\u{1b}]133;A\u{07}$ ")
        await settle(view)

        view.selectLastCommandOutput()
        XCTAssertEqual(view.testingSelectionText(), "building things\nall tests green")
    }

    func testNoOpWithoutCommandBoundaries() async {
        let view = HarnessTerminalSurfaceView()
        view.receive("no shell integration here\r\n")
        await settle(view)
        view.selectLastCommandOutput()
        XCTAssertNil(view.testingSelectionText())

        view.receive("\u{1b}]133;D;0\u{07}\u{1b}]133;A\u{07}$ ")
        await settle(view)
        view.selectLastCommandOutput() // Prompt marks alone do not define command output.
        XCTAssertNil(view.testingSelectionText())
    }

    func testNoOpWhenTheCommandPrintedNothing() async {
        let view = HarnessTerminalSurfaceView()
        view.receive("\u{1b}]133;A\u{07}$ \u{1b}]133;B\u{07}true\r\n\u{1b}]133;C\u{07}")
        view.receive("\u{1b}]133;D;0\u{07}\u{1b}]133;A\u{07}$ ")
        await settle(view)
        view.selectLastCommandOutput()
        XCTAssertNil(view.testingSelectionText())
    }

    func testScrollsToRevealOffscreenOutput() async {
        let view = HarnessTerminalSurfaceView()
        view.receive("\u{1b}]133;A\u{07}$ \u{1b}]133;B\u{07}seq\r\n\u{1b}]133;C\u{07}")
        view.receive((1 ... 5).map { "line \($0)" }.joined(separator: "\r\n") + "\r\n")
        view.receive("\u{1b}]133;D;0\u{07}\u{1b}]133;A\u{07}$ ")
        // Push the bracketed output far above the viewport.
        for i in 0 ..< 80 { view.receive("filler \(i)\r\n") }
        await settle(view)

        view.selectLastCommandOutput()
        // Later output without command markers must not become part of this command.
        XCTAssertEqual(view.testingSelectionText(),
                       (1 ... 5).map { "line \($0)" }.joined(separator: "\n"))
    }
    func testWrappedPromptAndInputAreExcludedFromOutput() async {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 10, rows: 12)
        view.receive("\u{1b}]133;A\u{07}long multiline prompt\r\n$ \u{1b}]133;B\u{07}printf long-command\r\n\u{1b}]133;C\u{07}")
        view.receive("abcdefghijklmnopqrstuv\u{1b}]133;D;0\u{07}\r\n\u{1b}]133;A\u{07}$ ")
        await settle(view)
        view.selectLastCommandOutput()
        XCTAssertEqual(view.testingSelectionText(), "abcdefghijklmnopqrstuv")
    }

    func testOutputWithoutTrailingNewlineExcludesFollowingPrompt() async {
        let view = HarnessTerminalSurfaceView()
        view.receive("\u{1b}]133;A\u{07}$ \u{1b}]133;B\u{07}printf hello\r\n\u{1b}]133;C\u{07}hello\u{1b}]133;D;0\u{07}\u{1b}]133;A\u{07}$ ")
        await settle(view)
        view.selectLastCommandOutput()
        XCTAssertEqual(view.testingSelectionText(), "hello")
    }

    func testCommandOutputBoundariesSurviveReflow() async {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 12, rows: 12)
        view.receive("\u{1b}]133;A\u{07}$ \u{1b}]133;B\u{07}printf output\r\n\u{1b}]133;C\u{07}some long output to reflow\u{1b}]133;D;0\u{07}\r\n\u{1b}]133;A\u{07}$ ")
        await settle(view)
        view.testingResizeGrid(cols: 8, rows: 12)
        view.selectLastCommandOutput()
        XCTAssertEqual(view.testingSelectionText(), "some long output to reflow")
        view.testingResizeGrid(cols: 30, rows: 12)
        XCTAssertEqual(view.testingSelectionText(), "some long output to reflow")
    }

    func testFailedCommandNavigationSkipsSuccessfulCommands() async {
        let view = HarnessTerminalSurfaceView()
        for status in [1, 0, 2] {
            view.receive("\u{1b}]133;A\u{07}$ \u{1b}]133;B\u{07}command\r\n\u{1b}]133;C\u{07}output\r\n\u{1b}]133;D;\(status)\u{07}")
        }
        view.receive("\u{1b}]133;A\u{07}$ ")
        for i in 0..<80 { view.receive("filler \(i)\r\n") }
        await settle(view)
        view.jumpToPreviousFailedCommand()
        let lastFailureOffset = view.testingScrollPosition.offset
        XCTAssertGreaterThan(lastFailureOffset, 0)
        view.jumpToPreviousFailedCommand()
        XCTAssertGreaterThan(view.testingScrollPosition.offset, lastFailureOffset)
        view.jumpToNextFailedCommand()
        XCTAssertEqual(view.testingScrollPosition.offset, lastFailureOffset)
    }

}
