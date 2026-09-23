import XCTest
import AppKit
@testable import KouenApp

/// Regression guard for the close-tab confirmation dialog: `isDirty` must diff the live
/// buffer against the last-saved/loaded content, not just remember "was ever edited" —
/// editing text and then undoing back to the original content must report clean again,
/// or a close-tab confirmation fires over a no-op edit (the exact bug this guards).
@MainActor
final class SyntaxTextViewDirtyStateTests: XCTestCase {
    func testCleanAfterLoad() {
        let view = SyntaxTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(text: "hello world", fileExtension: "txt")
        XCTAssertFalse(view.isDirty, "freshly loaded content must not be dirty")
    }

    func testDirtyAfterEdit() {
        let view = SyntaxTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(text: "hello world", fileExtension: "txt")
        view.debugSetText("hello world!")
        XCTAssertTrue(view.isDirty, "content differing from the loaded snapshot must be dirty")
    }

    func testCleanAgainAfterUndoingBackToOriginalContent() {
        let view = SyntaxTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(text: "hello world", fileExtension: "txt")
        view.debugSetText("hello world!")
        XCTAssertTrue(view.isDirty)

        view.debugSetText("hello world")
        XCTAssertFalse(view.isDirty, "reverting to the exact loaded content must report clean, not just 'was edited'")
    }

    func testCleanAfterSave() {
        let view = SyntaxTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(text: "hello world", fileExtension: "txt")
        var savedText: String?
        view.onSave = { savedText = $0 }
        view.debugSetText("hello world!")
        XCTAssertTrue(view.isDirty)

        view.saveNow()
        XCTAssertEqual(savedText, "hello world!")
        XCTAssertFalse(view.isDirty, "saving must re-snapshot the saved content")
    }

    func testDiscardRevertsBufferAndClearsDirtyWithoutTouchingDisk() {
        let view = SyntaxTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(text: "hello world", fileExtension: "txt")
        var saveCallCount = 0
        view.onSave = { _ in saveCallCount += 1 }
        view.debugSetText("hello world!")
        XCTAssertTrue(view.isDirty)

        view.discardChanges()
        XCTAssertEqual(view.string, "hello world", "discard must revert to the last-saved/loaded content")
        XCTAssertFalse(view.isDirty)
        XCTAssertEqual(saveCallCount, 0, "discard must never write to disk")
    }
}
