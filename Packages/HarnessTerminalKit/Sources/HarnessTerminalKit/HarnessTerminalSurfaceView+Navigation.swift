import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Scrollback

    /// Scroll the viewport by whole `lines` (positive = back into history) — keyboard paging and
    /// programmatic scrolls. Routed through the continuous path so a fractional rest position is
    /// preserved (a page-up while half a line into a scroll stays half a line offset).
    func scrollBy(lines: Int) {
        scrollByContinuous(lines: CGFloat(lines))
    }

    /// Smooth scroll: advance the continuous position `P = scrollOffset - scrollFraction` by
    /// `delta` lines (positive = back into history), clamped to `[0, historyCount]`. The integer
    /// offset is `ceil(P)` — the frame one line further back — and the fraction is the upward
    /// translate that slides it to the exact position. An offset change rebuilds via the existing
    /// shift path; a fraction-only change re-presents the cached frame with a new uniform (the
    /// near-free tick that makes trackpad scrolling pixel-smooth). Clamping to 0 lands exactly on
    /// the live view (fraction 0 — byte-identical frame).
    func scrollByContinuous(lines delta: CGFloat) {
        guard delta != 0 else { return }
        // Mirror read on the off-main pipeline (see `historyCountMirror`): a precise trackpad
        // fires this at event rate, and a `queue.sync` here would stall every wheel event behind
        // an in-flight parse.
        let historyCount = historyCountMirror
        var position = CGFloat(scrollOffset) - scrollFraction + delta
        position = max(0, min(CGFloat(historyCount), position))
        // Snap float dust onto whole lines: P fractionally ABOVE an integer would ceil to the
        // next offset with fraction ≈ 1 — render-identical, but every line-based consumer
        // (hit-test, prompt jump, scrollbar) would report one line further back for that tick.
        let nearest = position.rounded()
        if abs(position - nearest) < 0.0005 { position = nearest }
        // Inline images don't ride the smooth-scroll translate (image quads draw window-relative,
        // outside the scrollPx uniform); quantize to whole lines while any are visible so they
        // never sit misaligned mid-cell.
        if lastPresentedResult.map({ !$0.frame.images.isEmpty }) == true {
            position = position.rounded()
        }
        let newOffset = Int(position.rounded(.up))
        let newFraction = CGFloat(newOffset) - position
        guard newOffset != scrollOffset || newFraction != scrollFraction else { return }
        let offsetChanged = newOffset != scrollOffset
        scrollOffset = newOffset
        scrollFraction = newFraction
        // Selection is content-anchored (absolute buffer lines) — scrolling moves the viewport
        // over it, never clears it (#161).
        notifyScrollChanged(historyCount: historyCount)
        if offsetChanged {
            scheduleRender()
        } else if !repaintLastFrame() {
            // Fraction-only tick: the frame is unchanged, only the translate moved. The repaint
            // applies the new uniform over the cached instances; fall back to a build only when
            // there is no presentable cached frame (e.g. generation just changed).
            scheduleRender()
        }
    }

    /// Jump back to the live bottom (e.g. on typing).
    func snapToBottom() {
        guard scrollOffset != 0 || scrollFraction != 0 else { return }
        scrollOffset = 0
        scrollFraction = 0
        notifyScrollChanged(historyCount: emulatorSync { $0.historyCount })
        scheduleRender()
    }

    /// Tell the host the scroll position changed so it can flash the transient scrollbar.
    func notifyScrollChanged(historyCount: Int) {
        onScrollChanged?(historyCount - scrollOffset, historyCount + rows, rows)
    }

    // MARK: - Jump to prompt (OSC 133)

    /// Scroll so the nearest shell-prompt row *above* the current top-of-viewport line sits at the
    /// top. No-op without shell-integration marks or when already above the first prompt.
    public func jumpToPreviousPrompt() {
        let (prompts, historyCount) = emulatorSync { ($0.promptRows, $0.historyCount) }
        guard !prompts.isEmpty else { return }
        let topVisible = historyCount - scrollOffset   // buffer index of the top row
        guard let target = prompts.last(where: { $0 < topVisible }) else { return }
        scrollToBufferLine(target)
    }

    /// Scroll so the nearest shell-prompt row *below* the current top-of-viewport line sits at the
    /// top. No-op without marks or when already at/after the last prompt.
    public func jumpToNextPrompt() {
        let (prompts, historyCount) = emulatorSync { ($0.promptRows, $0.historyCount) }
        guard !prompts.isEmpty else { return }
        let topVisible = historyCount - scrollOffset
        guard let target = prompts.first(where: { $0 > topVisible }) else { return }
        scrollToBufferLine(target)
    }

    /// Select exactly the output delimited by OSC 133 C/D, excluding prompt and input.
    public func selectLastCommandOutput() {
        guard let command = emulatorSync({ $0.lastCompletedCommand }) else { return }
        selectCommandOutput(command)
    }

    public func jumpToPreviousFailedCommand() {
        let target = emulatorSync { emulator -> Int? in
            let top = emulator.historyCount - scrollOffset
            return emulator.commandRegions.last { command in
                guard let position = command.prompt.position, let status = command.exitCode else { return false }
                return status != 0 && position.line < top
            }?.prompt.position?.line
        }
        if let target { scrollToBufferLine(target) }
    }

    public func jumpToNextFailedCommand() {
        let target = emulatorSync { emulator -> Int? in
            let top = emulator.historyCount - scrollOffset
            return emulator.commandRegions.first { command in
                guard let position = command.prompt.position, let status = command.exitCode else { return false }
                return status != 0 && position.line > top
            }?.prompt.position?.line
        }
        if let target { scrollToBufferLine(target) }
    }

    private nonisolated static func commandSelection(_ range: TerminalTextRange, columns: Int) -> TerminalSelection {
        let end = range.end.column == 0
            ? (range.end.line - 1, max(0, columns - 1))
            : (range.end.line, range.end.column - 1)
        return TerminalSelection((range.start.line, range.start.column), end)
    }

    private func selectCommandOutput(_ command: TerminalCommandRegion) {
        let anchors = emulatorSync { emulator -> (TerminalTextAnchor, TerminalTextAnchor)? in
            guard let range = command.outputRange else { return nil }
            let selection = Self.commandSelection(range, columns: emulator.cols)
            return (emulator.makeTextAnchor(line: selection.startRow, column: selection.startColumn),
                    emulator.makeTextAnchor(line: selection.endRow, column: selection.endColumn))
        }
        guard let anchors else { return }
        selectionGranularity = .character
        selectionRectangular = false
        selectionStartAnchor = anchors.0
        selectionEndAnchor = anchors.1
        let top = viewportTopBufferLine
        if let start = anchors.0.position, let end = anchors.1.position,
           start.line < top || end.line >= top + rows { scrollToBufferLine(start.line) }
        scheduleRender()
    }

    private func copyCommandText(_ command: TerminalCommandRegion, range: KeyPath<TerminalCommandRegion, TerminalTextRange?>) {
        let text = emulatorSync { emulator -> String? in
            guard let range = command[keyPath: range] else { return nil }
            return Self.selectedText(Self.commandSelection(range, columns: emulator.cols), emulator: emulator)
        }
        guard let text, !text.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        onCopy?(text)
    }

    @objc func copyContextCommand(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? TerminalCommandRegion else { return }
        copyCommandText(command, range: \.inputRange)
    }

    @objc func copyContextCommandOutput(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? TerminalCommandRegion else { return }
        copyCommandText(command, range: \.outputRange)
    }

    @objc func selectContextCommandOutput(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? TerminalCommandRegion else { return }
        selectCommandOutput(command)
    }

    @objc func findContextCommandOutput(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? TerminalCommandRegion else { return }
        beginCommandFind(command)
    }

    @objc func previousFailedCommand(_ sender: NSMenuItem) { jumpToPreviousFailedCommand() }
    @objc func nextFailedCommand(_ sender: NSMenuItem) { jumpToNextFailedCommand() }

    // MARK: - Output trigger scanning

    /// Apply trigger rules (from settings; reload-on-save re-pushes). Existing highlights are
    /// kept (they describe past output); the scan high-water stays put so rule changes apply
    /// to new output without rescanning history.
    public func applyTriggerRules(_ rules: [TriggerRule]) {
        triggerScanner = TriggerScanner(rules: rules)
    }

    func testingTriggerHighlightMatches() -> [TerminalBufferMatch] { triggerHighlightMatches }

    /// Scan the lines completed since the last batch (the cursor moved past them). Runs on
    /// the emulator's confinement domain right after `feed`. Replay batches never scan — a
    /// reopen must not re-fire notifications for historical output (#168's lesson) — but they
    /// advance the high-water so the restored content isn't backfilled later. Alt-screen
    /// content is skipped the same way (full-screen TUIs redraw in place; no stable lines).
    nonisolated static func scanTriggers(
        emulator: TerminalEmulator, scanner: TriggerScanner, state: TriggerScanState,
        replay: Bool, now: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) -> (highlights: [TerminalBufferMatch], notifications: [(ruleIndex: Int, lineText: String)]) {
        let cursorLine = emulator.historyCount + emulator.cursorRow
        if replay || emulator.isAlternateScreenActive {
            state.nextLine = cursorLine
            return ([], [])
        }
        guard cursorLine > state.nextLine else {
            // Clear/RIS/alt-screen exit can shrink the buffer — clamp so the next batch
            // scans from the live position instead of waiting to re-reach the old line.
            state.nextLine = min(state.nextLine, cursorLine)
            return ([], [])
        }
        // Rate budget: out of budget for this window → skip (advance the high-water so the
        // skipped flood is never backfilled), resume when the window rolls.
        if now &- state.windowStartNanos > triggerScanWindowNanos {
            state.windowStartNanos = now
            state.spentNanos = 0
        }
        guard state.spentNanos < triggerScanBudgetNanos else {
            state.nextLine = cursorLine
            return ([], [])
        }
        // Batch budget: only the NEWEST `triggerScanBatchLimit` completed lines scan; a
        // flood's backlog is skipped deliberately (triggers watch recent output — an
        // unbounded scan would tax the drain path exactly when it's busiest).
        let to = cursorLine // exclusive: the cursor's line is still being written
        let from = max(state.nextLine, to - triggerScanBatchLimit)
        state.nextLine = to
        var highlights: [TerminalBufferMatch] = []
        var notifications: [(ruleIndex: Int, lineText: String)] = []
        for line in from ..< to {
            let text = TriggerScanner.scanText(cells: emulator.bufferLine(line))
            guard !text.isEmpty else { continue }
            for match in scanner.scan(text) {
                switch scanner.rules[match.ruleIndex].action {
                case .highlight:
                    highlights.append(TerminalBufferMatch(
                        bufferLine: line,
                        columns: match.columns.lowerBound ..< (match.columns.upperBound + 1)
                    ))
                case .notify:
                    let last = state.lastNotifyNanos[match.ruleIndex]
                    if last == nil || now &- last! >= triggerNotifyCooldownNanos {
                        state.lastNotifyNanos[match.ruleIndex] = now
                        notifications.append((match.ruleIndex, text))
                    }
                }
            }
        }
        state.spentNanos &+= DispatchTime.now().uptimeNanoseconds &- now
        return (highlights, notifications)
    }

    /// Land a batch's scan results on main: bounded-FIFO the highlight spans (repaint), fire
    /// the notify callback per cooled-down rule.
    func consumeTriggerResults(
        _ results: (highlights: [TerminalBufferMatch], notifications: [(ruleIndex: Int, lineText: String)]),
        scanner: TriggerScanner
    ) {
        if !results.highlights.isEmpty {
            triggerHighlightMatches.append(contentsOf: results.highlights)
            if triggerHighlightMatches.count > Self.maxTriggerHighlights {
                triggerHighlightMatches.removeFirst(triggerHighlightMatches.count - Self.maxTriggerHighlights)
            }
            scheduleRender()
        }
        for n in results.notifications {
            onTriggerMatched?(scanner.rules[n.ruleIndex], n.lineText)
        }
    }

    /// Set the scrollback offset so virtual buffer line `index` is the top viewport row.
    public func scrollToBufferLine(_ index: Int) {
        let historyCount = emulatorSync { $0.historyCount }
        let target = max(0, min(historyCount, historyCount - index))
        guard target != scrollOffset || scrollFraction != 0 else { return }
        scrollOffset = target
        scrollFraction = 0 // prompt jumps anchor on a whole line
        notifyScrollChanged(historyCount: historyCount)
        scheduleRender()
    }

    // MARK: - Scroll wheel

    public override func scrollWheel(with event: NSEvent) {
        if event.scrollingDeltaY != 0 { clearLinkHover() }
        // In copy mode, the wheel moves the copy-mode cursor through scrollback.
        if copyMode != nil, let renderer, event.scrollingDeltaY != 0 {
            let scale = window?.backingScaleFactor ?? 2.0
            let cellH = max(1, CGFloat(renderer.cellPixelHeight) / scale)
            let lines = consumeWheelLines(event, cellHeight: cellH)
            guard lines != 0 else { return }
            let action: CopyModeAction = lines > 0 ? .cursorUp : .cursorDown
            for _ in 0 ..< abs(lines) { handleCopyModeAction(action) }
            return
        }
        if isMouseReporting(event) {
            guard let renderer else { return }
            let scale = window?.backingScaleFactor ?? 2.0
            // One wheel report per *line* of travel (cell-height accumulated, remainder carried),
            // not per NSEvent — a trackpad fires a ~120Hz stream of tiny deltas plus momentum
            // events, and reporting each one flooded TUIs (Claude Code) with wheel events, making
            // scroll feel hair-trigger. Accumulate fractional wheel movement until it reaches a full cell.
            let cellH = max(1, CGFloat(renderer.cellPixelHeight) / scale)
            let lines = consumeWheelLines(event, cellHeight: cellH)
            if lines != 0 {
                let button: MouseButton = lines > 0 ? .wheelUp : .wheelDown
                for _ in 0 ..< min(abs(lines), 32) { reportMouse(event, button: button, kind: .press) }
            }
            // Horizontal wheel: buttons 66/67, one report per cell-width column.
            let cellW = max(1, CGFloat(renderer.cellPixelWidth) / scale)
            let cols = consumeWheelColumns(event, cellWidth: cellW)
            if cols != 0 {
                let button: MouseButton = cols > 0 ? .wheelLeft : .wheelRight
                for _ in 0 ..< min(abs(cols), 32) { reportMouse(event, button: button, kind: .press) }
            }
            return
        }
        // Local scrollback: positive deltaY (content moves down) scrolls back into history.
        guard event.scrollingDeltaY != 0, let renderer else { return }
        let scale = window?.backingScaleFactor ?? 2.0
        let cellH = max(1, CGFloat(renderer.cellPixelHeight) / scale)
        // The alternate screen has no scrollback — synthesize arrow keys instead (DECSET
        // 1007 "alternate scroll", on by default) so the wheel scrolls less/man/vim when
        // the program didn't enable mouse reporting (that case already returned above).
        // Arrow synthesis is inherently line-based, so it keeps the whole-line accumulator;
        // local scrollback below scrolls by the continuous (pixel-smooth) delta instead.
        let onAltScreen = inputAltScreenActive()
        let modes = inputModes()
        if onAltScreen, modes.alternateScroll {
            let lines = consumeWheelLines(event, cellHeight: cellH)
            guard lines != 0 else { return }
            let key: SpecialKey = lines > 0 ? .up : .down
            let perLine = inputEncoder.encode(key, modifiers: [], modes: modes)
            guard !perLine.isEmpty else { return }
            // Cap one event's burst (don't flood the PTY on a violent fling) but carry
            // the excess back into the remainder so momentum isn't silently truncated.
            let send = min(abs(lines), 32)
            let excess = abs(lines) - send
            if excess > 0 { wheelLineRemainder += CGFloat(lines > 0 ? excess : -excess) }
            var bytes: [UInt8] = []
            bytes.reserveCapacity(perLine.count * send)
            for _ in 0 ..< send { bytes.append(contentsOf: perLine) }
            emit(bytes)
            return
        }
        scrollByContinuous(lines: continuousWheelLines(event, cellHeight: cellH))
    }

    /// Continuous (sub-line) wheel delta in lines for local-scrollback smooth scrolling. Precise
    /// (trackpad) deltas are pixel-based; the fraction itself is the carry, so no remainder
    /// accumulator is needed. Non-precise mouse wheels keep the classic whole-notch step
    /// (clamped to a full tick like `consumeWheelLines`) — a clicky wheel jumping 3 lines per
    /// notch is the expected feel; only the trackpad scrolls by pixels.
    private func continuousWheelLines(_ event: NSEvent, cellHeight: CGFloat) -> CGFloat {
        let delta = event.scrollingDeltaY
        if event.hasPreciseScrollingDeltas { return delta / cellHeight * scrollMultiplier }
        let ticks = delta > 0 ? max(delta, 1) : min(delta, -1)
        return ticks * Self.mouseWheelLinesPerTick * scrollMultiplier
    }

    /// Convert a wheel/trackpad event into a signed whole-line scroll count, carrying the
    /// sub-line remainder across events. Precise (trackpad) deltas are pixel-based, so dividing
    /// by the cell height maps a line's worth of finger travel to one line *and* lets small
    /// movements accumulate — the old `max(1, …rounded())` forced a full line per event, which
    /// made trackpad scrolling feel hair-trigger. Non-precise mouse wheels report in line units,
    /// scaled to the classic 3-line notch.
    private func consumeWheelLines(_ event: NSEvent, cellHeight: CGFloat) -> Int {
        let delta = event.scrollingDeltaY
        if event.hasPreciseScrollingDeltas {
            wheelLineRemainder += delta / cellHeight * scrollMultiplier
        } else {
            // macOS simulates acceleration on non-precise wheels by ramping the delta from 0.1
            // upward — a slow single notch would otherwise accumulate 0.3 lines and do nothing
            // until the fourth click. Clamp a notch to at least one full tick.
            let ticks = delta > 0 ? max(delta, 1) : min(delta, -1)
            wheelLineRemainder += ticks * Self.mouseWheelLinesPerTick * scrollMultiplier
        }
        let whole = wheelLineRemainder < 0 ? wheelLineRemainder.rounded(.up) : wheelLineRemainder.rounded(.down)
        wheelLineRemainder -= whole
        return Int(whole)
    }

    /// Horizontal counterpart of `consumeWheelLines` for mouse-reported wheel-left/right: precise
    /// deltas accumulate by cell width (remainder carried); non-precise ticks map 1:1 to columns.
    private func consumeWheelColumns(_ event: NSEvent, cellWidth: CGFloat) -> Int {
        let delta = event.scrollingDeltaX
        guard delta != 0 else { return 0 }
        if event.hasPreciseScrollingDeltas {
            wheelColumnRemainder += delta / cellWidth
            let whole = wheelColumnRemainder < 0 ? wheelColumnRemainder.rounded(.up) : wheelColumnRemainder.rounded(.down)
            wheelColumnRemainder -= whole
            return Int(whole)
        }
        return Int(delta.rounded())
    }
}
