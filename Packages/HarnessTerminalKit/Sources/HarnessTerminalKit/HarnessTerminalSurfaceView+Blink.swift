import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Cursor blink

    // Cursor blink updates the fragment overlay uniform and extras, retaining all glyph rows.
    // Pinned by `testCursorBlinkReusesAllRowsWithPixelParity`.
    //
    // The timer exists only while a blink can actually show: focused (first responder in the
    // key window), un-occluded, and in a window. Focus + occlusion transitions re-enter here,
    // so an unfocused/covered pane costs ZERO runloop wakeups instead of ticking forever just
    // to early-out (20 background panes used to wake the main runloop ~40×/s for nothing).
    func restartBlinkTimer() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        // Solid on stop: the unfocused hollow cursor renders steady, and a pane must never
        // strand mid-off-beat (invisible cursor) when its timer goes away.
        cursorBlinkVisible = true
        guard cursorBlinkEnabled, effectivelyFocused, !scheduler.isOccluded else { return }
        let timer = Timer(timeInterval: 0.53, repeats: true) { [weak self] _ in
            guard let self else { return }
            MainActor.assumeIsolated {
                self.advanceCursorBlink()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        blinkTimer = timer
    }

    /// Test seam: whether the blink timer is currently scheduled (the idle-efficiency
    /// contract — no timer while unfocused or occluded).
    func testingBlinkTimerIsScheduled() -> Bool { blinkTimer != nil }
    func testingAdvanceCursorBlink() { advanceCursorBlink() }

    private func advanceCursorBlink() {
        // A timer callback already queued when focus changes must not toggle.
        guard effectivelyFocused else { return }
        cursorBlinkVisible.toggle()
        if !repaintCursorBlink() { scheduleRender() }
    }

    private func repaintCursorBlink() -> Bool {
        // A cached blink cannot replace newer output or overlays awaiting submission.
        // Rebuild current state through the scheduler while either pipeline stage is busy.
        guard pendingDrawableFrame == nil, !drawableRequestInFlight else { return false }
        guard var result = lastPresentedResult, result.generation == renderGeneration,
              result.cursorCanBlink, !scheduler.isOccluded else { return false }
        result.frame.cursor.visible = cursorBlinkVisible
        result.damage = lastPresentedResultIsRendererCoherent
            ? TerminalDamage(rows: [], full: false) : TerminalDamage(full: true)
        result.scrollShift = 0
        result.frameBuildNanos = 0
        enqueueDrawableFrame(result)
        return true
    }

    /// Reset the cursor to solid after activity (typing/output), matching common terminals.
    func wakeCursor() {
        guard cursorBlinkEnabled else { return }
        if !cursorBlinkVisible {
            cursorBlinkVisible = true
            scheduleRender()
        }
    }

    // MARK: - SGR text blink (blinking cells)

    /// Start/stop the text-blink phase driver. Called with every presented frame's blink
    /// state and on occlusion changes: the timer exists only while blinking content is
    /// actually visible (no idle wakeups for the overwhelmingly common no-blink case), and
    /// parking always lands on the VISIBLE phase so text can never strand invisible.
    /// Each tick flips the renderer's phase and schedules a render; only rows containing
    /// blink cells re-encode (the renderer dirties exactly its `hasBlink` rows on a phase
    /// mismatch), so a tick costs O(blink rows) — same shape as a cursor blink toggle.
    func updateTextBlinkTimer(frameHasBlink: Bool) {
        lastFrameHadBlink = frameHasBlink
        let shouldRun = frameHasBlink && !scheduler.isOccluded
        if shouldRun {
            guard textBlinkTimer == nil else { return }
            let timer = Timer(timeInterval: 0.53, repeats: true) { [weak self] _ in
                guard let self else { return }
                MainActor.assumeIsolated {
                    self.textBlinkHidden.toggle()
                    self.renderExecutor?.sync { $0.textBlinkHidden = self.textBlinkHidden }
                    self.scheduleRender()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            textBlinkTimer = timer
        } else if textBlinkTimer != nil {
            textBlinkTimer?.invalidate()
            textBlinkTimer = nil
            if textBlinkHidden {
                textBlinkHidden = false
                renderExecutor?.sync { $0.textBlinkHidden = false }
                scheduleRender()
            }
        }
    }
}
