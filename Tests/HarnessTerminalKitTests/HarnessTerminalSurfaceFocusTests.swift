import AppKit
import Metal
import XCTest
@testable import HarnessTerminalKit

final class HarnessTerminalSurfaceFocusTests: XCTestCase {
    @MainActor
    func testCursorBlinkDoesNotReplacePendingOutput() throws {
        try assertCursorBlinkPreservesPendingFrame(selection: false)
    }

    @MainActor
    func testCursorBlinkDoesNotReplacePendingSelectionAtSameOutputGeneration() throws {
        try assertCursorBlinkPreservesPendingFrame(selection: true)
    }

    @MainActor
    private func assertCursorBlinkPreservesPendingFrame(selection: Bool) throws {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("Metal unavailable") }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480),
                              styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.contentView = nil; window.close() }
        let view = HarnessTerminalSurfaceView()
        view.testingSetSelectionColors(background: .init(red: 180, green: 80, blue: 30), foreground: nil)
        window.contentView = view
        view.layoutSubtreeIfNeeded()
        view.testingSetWindowIsKey(true)
        view.receive("before output")
        view.testingWaitForEmulatorIdle()
        view.testingForceRender()
        drainRenderPipeline(view)
        let before = try XCTUnwrap(view.testingLastPresentedFrame)
        XCTAssertTrue(view.testingBlinkTimerIsScheduled())

        let gate = DispatchSemaphore(value: 0)
        view.testingDrawableAcquisitionQueue.async { gate.wait() }
        defer { gate.signal() }
        let generation = view.outputGeneration
        if selection {
            view.testingSetSelection(anchor: (0, 0), head: (0, 2))
        } else {
            view.receive("\rnewer output")
            view.testingWaitForEmulatorIdle()
        }
        view.testingForceRender()
        XCTAssertTrue(view.testingDrawableRequestInFlight)
        if selection { XCTAssertEqual(view.outputGeneration, generation) }
        view.testingAdvanceCursorBlink()
        XCTAssertTrue(view.testingRenderPending, "busy blink requests current state rather than enqueueing its stale cache")
        gate.signal()
        drainRenderPipeline(view)

        let submitted = try XCTUnwrap(view.testingLastPresentedFrame)
        if selection {
            XCTAssertNotEqual(submitted.cell(row: 0, column: 0)?.background,
                              before.cell(row: 0, column: 0)?.background,
                              "the pending selection must survive a blink without more user input")
        } else {
            XCTAssertEqual(submitted.cell(row: 0, column: 0)?.codepoint, Unicode.Scalar("n").value,
                           "the pending output must survive a blink without another output chunk")
        }
    }

    /// Clearing a pane's `.waiting` notification on focus hangs off `onBecameFocused`. It must
    /// fire when the surface becomes *effectively* focused — first responder × key window, the
    /// AppKit path a click-into / ⌘-Tab-back takes (not just the programmatic `focusTerminal()`
    /// used by tab switches) — and fire exactly once per transition (the `lastReportedFocus`
    /// guard), so the downstream daemon round-trip never fires on a no-op re-focus.
    @MainActor
    func testOnBecameFocusedFiresOncePerFocusInTransition() {
        let view = HarnessTerminalSurfaceView()
        var fires = 0
        view.onBecameFocused = { fires += 1 }

        // First responder alone, window not key → not effectively focused → no fire.
        _ = view.becomeFirstResponder()
        XCTAssertEqual(fires, 0, "first responder without a key window is not focus-in")

        // Window becomes key while first responder → effectively focused → fires once.
        view.testingSetWindowIsKey(true)
        XCTAssertEqual(fires, 1, "becoming effectively focused fires onBecameFocused")

        // Re-asserting the same state must not re-fire (lastReportedFocus guard).
        view.testingSetWindowIsKey(true)
        _ = view.becomeFirstResponder()
        XCTAssertEqual(fires, 1, "no transition → no extra fire")

        // Lose key (focus-out) then regain it (a second focus-in) → fires again, still once.
        view.testingSetWindowIsKey(false)
        XCTAssertEqual(fires, 1, "focus-out does not fire onBecameFocused")
        view.testingSetWindowIsKey(true)
        XCTAssertEqual(fires, 2, "the next focus-in fires again")
    }

    /// Idle-efficiency contract: the cursor-blink timer exists only while the blink can show
    /// (effectively focused + un-occluded). Unfocused panes used to keep a 0.53 s repeating
    /// timer alive forever just to early-out in the tick — 20 panes ≈ 40 main-runloop
    /// wakeups/s for nothing.
    @MainActor
    func testBlinkTimerScheduledOnlyWhileEffectivelyFocused() {
        let view = HarnessTerminalSurfaceView()
        XCTAssertFalse(view.testingBlinkTimerIsScheduled(), "no focus → no timer")

        // First responder alone (window not key) is not effective focus.
        _ = view.becomeFirstResponder()
        XCTAssertFalse(view.testingBlinkTimerIsScheduled(), "non-key window must not arm the timer")

        view.testingSetWindowIsKey(true)
        XCTAssertTrue(view.testingBlinkTimerIsScheduled(), "focus-in arms the blink timer")

        view.testingSetWindowIsKey(false)
        XCTAssertFalse(view.testingBlinkTimerIsScheduled(), "focus-out stops the timer (no idle wakeups)")

        view.testingSetWindowIsKey(true)
        XCTAssertTrue(view.testingBlinkTimerIsScheduled())
        _ = view.resignFirstResponder()
        XCTAssertFalse(view.testingBlinkTimerIsScheduled(), "resigning first responder stops the timer")
    }

    /// Occlusion (covered window / minimized / other Space) also parks the blink timer; the
    /// cursor is left solid so the pane re-shows correct content the instant it's visible.
    @MainActor
    func testBlinkTimerParksWhileOccluded() {
        let view = HarnessTerminalSurfaceView()
        _ = view.becomeFirstResponder()
        view.testingSetWindowIsKey(true)
        XCTAssertTrue(view.testingBlinkTimerIsScheduled())

        view.testingSetWindowOccluded(true)
        XCTAssertFalse(view.testingBlinkTimerIsScheduled(), "an occluded pane has nothing to blink")

        view.testingSetWindowOccluded(false)
        XCTAssertTrue(view.testingBlinkTimerIsScheduled(), "re-arms when visible again")
    }
}
