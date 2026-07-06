import AppKit
import XCTest
@testable import KouenTerminalKit

/// Right-click block menu (`appendBlockMenuItems`, `KouenTerminalSurfaceView+Find.swift`) —
/// replaced the ⌘-click floating action bar (dropped for poor discoverability). Output/Command
/// -only copy require a real captured block (OSC 133 `C`, zsh/fish); a pane whose shell only
/// emits A/D (bash) degrades to just Re-run rather than offering actions with nothing precise
/// to act on.
final class BlockContextMenuTests: XCTestCase {
    private func b64(_ s: String) -> String { Data(s.utf8).base64EncodedString() }

    @MainActor
    private func makeView() -> KouenTerminalSurfaceView {
        // Synchronous parsing (off-main pipeline disabled) so `.receive()` is deterministic —
        // no need to wait for a background parse before asserting.
        KouenTerminalSurfaceView(offMainParserFramePipeline: false)
    }

    @MainActor
    func testFullMenuWhenBlockCaptured() {
        let view = makeView()
        view.receive("\u{1b}]133;A\u{07}$ ")
        view.receive("\u{1b}]133;C;\(b64("swift build"))\u{07}\r\nBuild complete!\r\n")
        view.receive("\u{1b}]133;D;0\u{07}")

        let menu = NSMenu()
        view.appendBlockMenuItems(to: menu, promptLine: 0)
        XCTAssertEqual(menu.items.map(\.title), ["Copy Output Only", "Copy Command Only", "Re-run"])
        XCTAssertTrue(menu.items.allSatisfy { $0.representedObject as? Int == 0 })
    }

    @MainActor
    func testOnlyRerunWithoutACapturedBlock() {
        // A shell that only emits A/D (bash, this session) — no command text captured.
        let view = makeView()
        view.receive("\u{1b}]133;A\u{07}$ true\r\n\u{1b}]133;D;0\u{07}")

        let menu = NSMenu()
        view.appendBlockMenuItems(to: menu, promptLine: 0)
        XCTAssertEqual(menu.items.map(\.title), ["Re-run"], "no precise output/command to offer without a captured block")
    }
}
