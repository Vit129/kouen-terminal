import AppKit
import XCTest
@testable import KouenTerminalKit

/// When a keystroke is routed through `interpretKeyEvents` (e.g. while `hasMarkedText()` is
/// true) instead of `_keyDown`'s direct `specialKey` path, unhandled navigation selectors land
/// in `doCommandBy(_:)`. Before this fix the view had no `moveLeft(_:)`/`moveRight(_:)` etc., so
/// NSResponder's default handling silently swallowed them — the arrow never reached the PTY.
@MainActor
final class DoCommandByArrowForwardingTests: XCTestCase {
    func testMoveLeftForwardsLeftArrowToPTY() {
        let view = KouenTerminalSurfaceView(offMainParserFramePipeline: true)
        var received: [UInt8] = []
        view.onInput = { received = [UInt8]($0) }

        view.doCommandBy(#selector(NSResponder.moveLeft(_:)))

        XCTAssertEqual(received, [0x1B, 0x5B, 0x44], "moveLeft should emit ESC[D (cursor left)")
    }

    func testMoveRightForwardsRightArrowToPTY() {
        let view = KouenTerminalSurfaceView(offMainParserFramePipeline: true)
        var received: [UInt8] = []
        view.onInput = { received = [UInt8]($0) }

        view.doCommandBy(#selector(NSResponder.moveRight(_:)))

        XCTAssertEqual(received, [0x1B, 0x5B, 0x43], "moveRight should emit ESC[C (cursor right)")
    }

    func testUnrelatedSelectorIsANoOp() {
        let view = KouenTerminalSurfaceView(offMainParserFramePipeline: true)
        var callCount = 0
        view.onInput = { _ in callCount += 1 }

        view.doCommandBy(#selector(NSResponder.deleteBackward(_:)))

        XCTAssertEqual(callCount, 0, "selectors this view doesn't own should stay a no-op")
    }
}
