import AppKit
import XCTest
@testable import HarnessTerminalKit

/// Paste protection confirms multi-line text in a sheet. A pane without a window has nowhere to
/// show that sheet, so the paste must be refused rather than delivered unconfirmed.
@MainActor
final class PasteProtectionTests: XCTestCase {
    func testUnsafePasteWithoutWindowIsRefusedWithNotice() {
        let view = HarnessTerminalSurfaceView()
        var sent: [Data] = []
        var notices: [String] = []
        view.onInput = { sent.append($0) }
        view.onNotice = { notices.append($0) }

        view.testingPasteText("echo safe\nrm -rf ~/scratch\n")

        XCTAssertTrue(sent.isEmpty)
        XCTAssertEqual(notices.count, 1)
    }

    func testSafePasteWithoutWindowIsDelivered() {
        let view = HarnessTerminalSurfaceView()
        var sent = Data()
        var notices: [String] = []
        view.onInput = { sent.append($0) }
        view.onNotice = { notices.append($0) }

        view.testingPasteText("echo safe")

        XCTAssertEqual(String(decoding: sent, as: UTF8.self), "echo safe")
        XCTAssertTrue(notices.isEmpty)
    }

    func testBracketedPasteNeedsNoConfirmation() {
        let view = HarnessTerminalSurfaceView()
        view.receive(Data("\u{1b}[?2004h".utf8))
        view.testingWaitForEmulatorIdle()
        var sent = Data()
        view.onInput = { sent.append($0) }

        view.testingPasteText("a\nb")

        XCTAssertEqual(String(decoding: sent, as: UTF8.self), "\u{1b}[200~a\rb\u{1b}[201~")
    }
}
