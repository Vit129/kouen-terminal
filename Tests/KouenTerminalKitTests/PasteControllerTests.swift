import AppKit
import XCTest
@testable import KouenTerminalKit

/// `PasteController.isUnsafePaste` decides whether `deliverPaste` (KouenTerminalSurfaceView+Find.swift)
/// force-wraps a paste in bracketed-paste markers when the shell never announced DECSET 2004
/// support — without this, a multi-line paste runs command-per-line instead of landing as one block.
@MainActor
final class PasteControllerTests: XCTestCase {
    func testSingleLineTextIsSafe() {
        XCTAssertFalse(PasteController.isUnsafePaste("echo hello"))
    }

    func testMultiLineTextIsUnsafe() {
        XCTAssertTrue(PasteController.isUnsafePaste("line1\rline2"))
    }

    func testTabIsSafe() {
        XCTAssertFalse(PasteController.isUnsafePaste("a\tb"))
    }

    func testOtherControlCharactersAreUnsafe() {
        XCTAssertTrue(PasteController.isUnsafePaste("a\u{01}b"))
    }

    func testNormalizedForPasteConvertsLineEndingsToCR() {
        XCTAssertEqual(PasteController.normalizedForPaste("a\r\nb\nc"), "a\rb\rc")
    }
}
