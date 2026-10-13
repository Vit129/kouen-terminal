import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - IME preedit

    /// Draw the marked (composing) text over the grid starting at the cursor, and park the
    /// cursor at its end. Combining marks (Thai vowels/tones, accents) are folded onto the base
    /// cell — never given their own column — so composing Thai through the IME renders the same as
    /// committed text, instead of dropping vowels / exploding tone marks.
    /// Per-row fingerprint of the cell-overlay pass (selection + find shading + IME preedit):
    /// what the pass paints on each row, hashed from the overlay GEOMETRY (no cell walks). Two
    /// builds whose fingerprints agree for a row shaded it identically, so the rows whose
    /// fingerprint changed — plus rows that left the overlay — are exactly the extra render
    /// damage the pass needs. A selection drag therefore re-encodes the rows it crossed, not
    /// the grid. Keys exist only for rows the overlay touches now.
    nonisolated static func overlayRowKeys(
        selection: SelectionRegion?,
        findHits: [TerminalSelection],
        preedit: String,
        preeditCursor: (row: Int, column: Int),
        rows: Int, cols: Int
    ) -> [Int: UInt64] {
        var keys: [Int: UInt64] = [:]
        func fold(_ row: Int, _ value: UInt64) {
            guard row >= 0, row < rows else { return }
            let h = keys[row] ?? 0xCBF2_9CE4_8422_2325 // FNV-64 offset basis
            keys[row] = (h ^ value) &* 0x0000_0100_0000_01B3
        }
        // Column extents pack into one word; the tag keeps a selection span from ever colliding
        // with an identical find span (they shade with different colors).
        func pack(_ a: Int, _ b: Int, _ tag: UInt64) -> UInt64 {
            (UInt64(UInt32(bitPattern: Int32(a))) << 34)
                ^ (UInt64(UInt32(bitPattern: Int32(b))) << 3) ^ tag
        }
        switch selection {
        case let .linear(s):
            if s.endRow >= 0, s.startRow < rows {
                for row in max(0, s.startRow) ... min(rows - 1, s.endRow) {
                    let a = row == s.startRow ? s.startColumn : 0
                    let b = row == s.endRow ? s.endColumn : cols - 1
                    fold(row, pack(a, b, 1))
                }
            }
        case let .block(b):
            if b.endRow >= 0, b.startRow < rows {
                for row in max(0, b.startRow) ... min(rows - 1, b.endRow) {
                    fold(row, pack(b.startColumn, b.endColumn, 2))
                }
            }
        case nil:
            break
        }
        for hit in findHits where hit.endRow >= 0 && hit.startRow < rows {
            for row in max(0, hit.startRow) ... min(rows - 1, hit.endRow) {
                let a = row == hit.startRow ? hit.startColumn : 0
                let b = row == hit.endRow ? hit.endColumn : cols - 1
                fold(row, pack(a, b, 3))
            }
        }
        if !preedit.isEmpty {
            var h: UInt64 = 0xCBF2_9CE4_8422_2325
            for byte in preedit.utf8 { h = (h ^ UInt64(byte)) &* 0x0000_0100_0000_01B3 }
            fold(preeditCursor.row, h ^ pack(preeditCursor.column, 0, 4))
        }
        return keys
    }

    nonisolated static func applyPreedit(
        into frame: inout TerminalFrame, text: String, builder: FrameBuilder,
        canvasForeground: HarnessTheme.RGBColor, canvasBackground: HarnessTheme.RGBColor
    ) {
        let row = frame.cursor.row
        let start = frame.cursor.column
        guard row >= 0, row < frame.rows, start >= 0, start < frame.columns else { return }
        let layout = TerminalTextLayout(text: text, columns: frame.columns - start)
        let fg = builder.renderColor(canvasForeground)
        let bg = builder.renderColor(canvasBackground)
        var nextClusterID: UInt32 = 0x7fff_ffff
        for (offset, source) in layout.cells.enumerated() {
            var combining1 = source.combining1
            if source.clusterID != 0, let cluster = layout.clusters[source.clusterID] {
                while frame.clusters[nextClusterID] != nil { nextClusterID -= 1 }
                frame.clusters[nextClusterID] = cluster
                combining1 = nextClusterID | 0x8000_0000
                nextClusterID -= 1
            }
            frame.updateCell(row: row, column: start + offset) { cell in
                cell.codepoint = source.codepoint
                cell.combining0 = source.combining0
                cell.combining1 = combining1
                cell.foreground = fg; cell.background = bg
                cell.underline = .single; cell.underlineColor = fg
                cell.width = source.width
                cell.bold = false; cell.italic = false; cell.blink = false
                cell.strikethrough = false; cell.overline = false
                cell.colorGlyphOpacity = 1
                cell.drawBackground = false
            }
        }
        frame.cursor.column = min(start + layout.cells.count, frame.columns - 1)
    }
}

// MARK: - NSTextInputClient (dead keys + IME)

extension HarnessTerminalSurfaceView: @preconcurrency NSTextInputClient {
    private func plainString(_ obj: Any) -> String {
        if let s = obj as? String { return s }
        if let a = obj as? NSAttributedString { return a.string }
        return ""
    }

    /// Committed text (plain typing, dead-key result, or finished IME composition).
    public func insertText(_ string: Any, replacementRange: NSRange) {
        markedText = ""
        let text = plainString(string)
        guard !text.isEmpty else { scheduleRender(); return }
        // Plain typing reaches the PTY here (via interpretKeyEvents), not in keyDown.
        FrameSignposter.shared.noteKeystroke(source: ObjectIdentifier(self), outputGeneration: outputGeneration)
        emit(inputEncoder.encode(text: text))
        scheduleRender()
    }

    /// In-progress composition shown as preedit over the grid.
    public func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {
        markedText = plainString(string)
        scheduleRender()
    }

    public func unmarkText() {
        markedText = ""
        scheduleRender()
    }

    public func hasMarkedText() -> Bool { !markedText.isEmpty }

    public func markedRange() -> NSRange {
        markedText.isEmpty ? NSRange(location: NSNotFound, length: 0)
            : NSRange(location: 0, length: markedText.utf16.count)
    }

    public func selectedRange() -> NSRange { NSRange(location: 0, length: 0) }

    public func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
        nil
    }

    public func validAttributesForMarkedText() -> [NSAttributedString.Key] { [] }

    /// Anchors UI to the last presented cursor without waiting behind parser work.
    public var cursorRectInScreen: NSRect? {
        guard scrollOffset == 0, copyMode == nil, let renderer, let window,
              let cursor = lastPresentedResult?.frame.cursor else { return nil }
        let cellWidth = CGFloat(renderer.cellPixelWidth) / window.backingScaleFactor
        let cellHeight = CGFloat(renderer.cellPixelHeight) / window.backingScaleFactor
        let rect = NSRect(x: gridOriginPointsX + CGFloat(cursor.column) * cellWidth,
                          y: bounds.height - gridOriginPointsY - CGFloat(cursor.row + 1) * cellHeight,
                          width: cellWidth, height: cellHeight)
        guard bounds.intersects(rect) else { return nil }
        return window.convertToScreen(convert(rect, to: nil))
    }

    /// Where the IME candidate window should anchor: the cursor cell, in screen space.
    public func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
        guard let renderer, let window else { return .zero }
        let scale = window.backingScaleFactor
        let cellW = CGFloat(renderer.cellPixelWidth) / scale
        let cellH = CGFloat(renderer.cellPixelHeight) / scale
        let snapshot = emulatorSync { $0.readGrid() }
        let x = gridOriginPointsX + CGFloat(snapshot.cursor.col) * cellW
        // Convert grid-from-top to AppKit bottom-left origin.
        let yTop = gridOriginPointsY + CGFloat(snapshot.cursor.row) * cellH
        let viewRect = NSRect(x: x, y: bounds.height - yTop - cellH, width: cellW, height: cellH)
        let windowRect = convert(viewRect, to: nil)
        return window.convertToScreen(windowRect)
    }

    public func characterIndex(for point: NSPoint) -> Int { 0 }

    /// Keys the input system classifies as commands (e.g. Return) are already handled in
    /// `keyDown` before reaching the IME, so swallow these silently (no system beep).
    public override func doCommand(by selector: Selector) {}
}
