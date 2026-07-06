import XCTest
@testable import KouenApp

/// The commit-diff popover (shared by History's click-a-commit and the worktree diff-vs-main
/// button) rendered an empty white box: real diff text reached `presentCommitDetail`, the
/// popover chrome showed, but the text never appeared. Root cause — `makeDiffScrollView` built
/// a bare `NSTextView()` (zero frame, empty `autoresizingMask`) and explicitly set
/// `translatesAutoresizingMaskIntoConstraints = false` on it, which killed the only sizing
/// mechanism the view had (autoresizing-mask-derived constraints) without providing the
/// AutoLayout constraints that would've been the alternative — only a width constraint existed,
/// nothing pinning height/top/leading, so the text view had no defined size and never laid out.
/// `NSTextView.scrollableTextView()` leaves `translatesAutoresizingMaskIntoConstraints = true`
/// with `autoresizingMask = [.width, .height]`, the classic NSClipView/NSScrollView "just
/// resize with the container" mechanism scroll views actually rely on. Verified against a bare
/// `NSTextView()` directly (not assumed): both report identical `isVerticallyResizable` and
/// `textContainer.widthTracksTextView` — those were NOT the differentiator, despite looking like
/// the obvious culprits. This asserts the property that actually distinguishes them.
@MainActor
final class GitPanelViewDiffPopoverTests: XCTestCase {
    func testTextStorageContainsTheDiffText() {
        let (_, textView, _) = GitPanelView.makeDiffScrollView("diff --git a/x b/x\n+added line")
        XCTAssertEqual(textView.textStorage?.string, "diff --git a/x b/x\n+added line")
    }

    func testTextViewKeepsAutoresizingMaskDrivenSizing() {
        let (scroll, textView, _) = GitPanelView.makeDiffScrollView("some diff text")
        XCTAssertTrue(scroll.documentView === textView, "scrollableTextView() must wire documentView to the same text view we configure")
        XCTAssertTrue(
            textView.translatesAutoresizingMaskIntoConstraints,
            "this must stay true — false was the actual bug: it disabled the view's only sizing mechanism (autoresizing mask) without replacement constraints, so the view stayed at its zero-size default frame and nothing ever rendered"
        )
        XCTAssertTrue(textView.autoresizingMask.contains(.height), "without .height in the mask the text view never grows to fill the clip view — this is what actually made the popover render as an empty box")
    }

    func testFileHeaderIsDetectedForNavBar() {
        let (_, _, fileRanges) = GitPanelView.makeDiffScrollView("diff --git a/foo.swift b/foo.swift\n@@ -1 +1 @@\n+x")
        XCTAssertEqual(fileRanges.map(\.name), ["foo.swift"])
    }

    func testEmptyTextProducesNoFileRangesButStillAValidTextView() {
        let (_, textView, fileRanges) = GitPanelView.makeDiffScrollView("")
        XCTAssertEqual(textView.textStorage?.string, "")
        XCTAssertTrue(fileRanges.isEmpty)
    }
}
