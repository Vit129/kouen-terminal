import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore
import UniformTypeIdentifiers

extension HarnessTerminalSurfaceView {
    // MARK: - Selection & copy

    /// Raw selection inputs, captured on the main thread WITHOUT resolving the per-granularity
    /// column expansion. The off-main render path resolves the region on the emulator queue (see
    /// `resolveSelectionRegion`) so a `.word` selection never drives `currentSelectionRegion`'s
    /// `emulatorSync` — which, off the queue, `queue.sync`s the MAIN thread behind an in-flight
    /// output feed on every build while the word selection is held (the stall the off-main pipeline
    /// exists to avoid). `Sendable` so the `@Sendable` build closure can capture it.
    struct RawSelection: Sendable {
        let anchor: TerminalTextAnchor
        let head: TerminalTextAnchor
        let granularity: SelectionGranularity
        let rectangular: Bool
    }

    var currentRawSelection: RawSelection? {
        guard let anchor = selectionStartAnchor, let head = selectionEndAnchor else { return nil }
        return RawSelection(anchor: anchor, head: head,
                            granularity: selectionGranularity, rectangular: selectionRectangular)
    }

    /// Buffer line index of viewport row 0 — the rebase term between the absolute selection
    /// coordinates and viewport rows. Mirror read on the off-main pipeline (same discipline as
    /// `scrollByContinuous`): mouse handlers must never `queue.sync` behind a busy parse.
    var viewportTopBufferLine: Int {
        historyCountMirror
            - scrollOffset
    }

    /// Resolve a raw selection into a render region in VIEWPORT rows. PURE — call it ON the
    /// emulator queue (inside the build) so the `.word` expansion reads `wordColumnRange`
    /// directly instead of through a main-stalling `emulatorSync`. Anchors are absolute buffer
    /// lines; rows that rebase outside the viewport simply don't shade (the overlay pass
    /// ignores out-of-range rows), so a partially scrolled-away selection renders its visible
    /// band and nothing else.
    nonisolated static func resolveSelectionRegion(
        _ sel: RawSelection?, emulator: TerminalEmulator, scrollOffset: Int, columns: Int
    ) -> SelectionRegion? {
        guard let sel else { return nil }
        guard let absolute = resolveAbsoluteSelectionRegion(sel, emulator: emulator, columns: columns) else {
            return nil
        }
        let top = emulator.historyCount - scrollOffset
        switch absolute {
        case let .linear(s):
            return .linear(TerminalSelection((s.startRow - top, s.startColumn),
                                             (s.endRow - top, s.endColumn)))
        case let .block(b):
            return .block(BlockSelection((b.startRow - top, b.startColumn),
                                         (b.endRow - top, b.endColumn)))
        }
    }

    /// The selection region in ABSOLUTE buffer-line space: endpoints ordered, granularity
    /// expansion applied. Evicted anchors invalidate the selection rather than selecting
    /// unrelated retained text. Shared
    /// by rendering (rebased to viewport rows above) and extraction (read via `bufferLine`).
    nonisolated static func resolveAbsoluteSelectionRegion(
        _ sel: RawSelection, emulator: TerminalEmulator, columns: Int
    ) -> SelectionRegion? {
        let maxLine = max(0, emulator.bufferLineCount - 1)
        guard let start = sel.anchor.position, let end = sel.head.position else { return nil }
        let a = (line: min(max(0, start.line), maxLine), column: start.column)
        let h = (line: min(max(0, end.line), maxLine), column: end.column)
        if sel.rectangular {
            return .block(BlockSelection((a.line, a.column), (h.line, h.column)))
        }
        if sel.granularity == .character {
            return .linear(TerminalSelection((a.line, a.column), (h.line, h.column)))
        }
        // Per-line column extent: the whole row for `.line` (triple-click's LOGICAL-line span
        // across soft wraps is handled at mouse-down by anchoring across the wrapped lines —
        // see `logicalLineBufferRowSpan`), the whitespace-delimited word for `.word` (shared
        // with copy mode), else the single column.
        func unitRange(line: Int, column: Int) -> ClosedRange<Int> {
            switch sel.granularity {
            case .character: return column ... column
            case .line: return 0 ... max(0, columns - 1)
            case .word: return emulator.wordColumnRange(line: line, column: column)
            }
        }
        let lo: (line: Int, column: Int), hi: (line: Int, column: Int)
        if (a.line, a.column) <= (h.line, h.column) { lo = a; hi = h } else { lo = h; hi = a }
        let loRange = unitRange(line: lo.line, column: lo.column)
        let hiRange = unitRange(line: hi.line, column: hi.column)
        if lo.line == hi.line {
            let start = (lo.line, min(loRange.lowerBound, hiRange.lowerBound))
            return .linear(TerminalSelection(start, (lo.line, max(loRange.upperBound, hiRange.upperBound))))
        }
        return .linear(TerminalSelection((lo.line, loRange.lowerBound), (hi.line, hiRange.upperBound)))
    }

    /// The active selection region in viewport rows (nil when nothing is selected), resolved
    /// through the worker build's resolver. Copy actions read this; guards that only need
    /// "is something selected"
    /// must check `selectionAnchor` instead — this getter can `emulatorSync`.
    var currentSelectionRegion: SelectionRegion? {
        guard let raw = currentRawSelection else { return nil }
        return emulatorSync {
            Self.resolveSelectionRegion(raw, emulator: $0, scrollOffset: scrollOffset, columns: columns)
        }
    }

    func clearSelection() {
        selectionGranularity = .character
        selectionRectangular = false
        guard selectionStartAnchor != nil || selectionEndAnchor != nil else { return }
        selectionStartAnchor = nil
        selectionEndAnchor = nil
        scheduleRender()
    }

    /// Map a window-space point to a grid cell, accounting for padding + backing scale.
    /// AppKit view coordinates are bottom-left origin, so the row is measured from the top.
    func cell(at locationInWindow: NSPoint) -> (row: Int, column: Int)? {
        guard let renderer, columns > 0, rows > 0 else { return nil }
        let scale = window?.backingScaleFactor ?? 2.0
        let cellW = CGFloat(renderer.cellPixelWidth) / scale
        let cellH = CGFloat(renderer.cellPixelHeight) / scale
        guard cellW > 0, cellH > 0 else { return nil }
        let p = convert(locationInWindow, from: nil)
        let x = p.x - gridOriginPointsX
        // The smooth-scroll translate slides content UP by `scrollFraction` of a cell, so what's
        // visually under the pointer is the content that fraction further down — add it back so
        // clicks/selections land on the row the user sees, not the untranslated grid slot.
        let yFromTop = bounds.height - p.y - gridOriginPointsY + scrollFraction * cellH
        let col = Int((x / cellW).rounded(.down))
        let row = Int((yFromTop / cellH).rounded(.down))
        return (max(0, min(rows - 1, row)), max(0, min(columns - 1, col)))
    }

    /// Whether a window-space point is over the grid itself rather than the padding around it.
    func isInsideGrid(_ locationInWindow: NSPoint) -> Bool {
        guard let renderer, columns > 0, rows > 0 else { return false }
        let scale = window?.backingScaleFactor ?? 2.0
        let cellW = CGFloat(renderer.cellPixelWidth) / scale
        let cellH = CGFloat(renderer.cellPixelHeight) / scale
        let p = convert(locationInWindow, from: nil)
        let x = p.x - gridOriginPointsX
        let yFromTop = bounds.height - p.y - gridOriginPointsY + scrollFraction * cellH
        return x >= 0 && yFromTop >= 0 && x < CGFloat(columns) * cellW && yFromTop < CGFloat(rows) * cellH
    }

    /// Report a press only when it lands on the grid, not the padding around it.
    private func reportPressIfOnGrid(_ event: NSEvent, button: MouseButton) {
        lastReportedDrag = nil
        guard isInsideGrid(event.locationInWindow) else {
            unreportedMouseButtons.insert(event.buttonNumber)
            return
        }
        unreportedMouseButtons.remove(event.buttonNumber)
        reportMouse(event, button: button, kind: .press)
    }

    private func reportReleaseIfPressed(_ event: NSEvent, button: MouseButton) {
        lastReportedDrag = nil
        if unreportedMouseButtons.remove(event.buttonNumber) != nil { return }
        reportMouse(event, button: button, kind: .release)
    }

    /// Mouse goes to the program when it enabled tracking — unless Shift is held, which
    /// always forces local selection (the standard terminal override).
    func isMouseReporting(_ event: NSEvent) -> Bool {
        inputModes().mouseTrackingEnabled && !event.modifierFlags.contains(.shift)
    }

    private func mouseModifiers(_ event: NSEvent) -> KeyModifiers {
        var mods: KeyModifiers = []
        let flags = event.modifierFlags
        if flags.contains(.shift) { mods.insert(.shift) }
        if flags.contains(.option) { mods.insert(.option) }
        if flags.contains(.control) { mods.insert(.control) }
        return mods
    }

    func reportMouse(_ event: NSEvent, button: MouseButton, kind: MouseEventKind) {
        guard let pos = cell(at: event.locationInWindow) else { return }
        let modes = inputModes()
        emit(inputEncoder.encodeMouse(
            button: button, kind: kind,
            column: pos.column, row: pos.row,
            pixelPosition: modes.mouseSGRPixel ? textAreaPixelPosition(of: event) : nil,
            modifiers: mouseModifiers(event), modes: modes
        ))
    }

    /// Pointer position within the text area in DEVICE pixels (0-based) — the coordinate
    /// space of SGR-pixel mouse reporting (DECSET 1016), consistent with the engine's
    /// `CSI 14 t` report (grid cells × renderer cell pixel size). Clamped into the grid box.
    private func textAreaPixelPosition(of event: NSEvent) -> (x: Int, y: Int)? {
        guard let renderer, columns > 0, rows > 0 else { return nil }
        let scale = window?.backingScaleFactor ?? 2.0
        let cellH = CGFloat(renderer.cellPixelHeight) / scale
        let p = convert(event.locationInWindow, from: nil)
        // Same mapping as `cell(at:)`, kept un-rounded: points from the grid origin, with the
        // smooth-scroll translate added back so the reported pixel matches what's on screen.
        let xPoints = p.x - gridOriginPointsX
        let yPointsFromTop = bounds.height - p.y - gridOriginPointsY + scrollFraction * cellH
        let maxX = columns * renderer.cellPixelWidth - 1
        let maxY = rows * renderer.cellPixelHeight - 1
        let x = min(max(0, Int((xPoints * scale).rounded(.down))), max(0, maxX))
        let y = min(max(0, Int((yPointsFromTop * scale).rounded(.down))), max(0, maxY))
        return (x: x, y: y)
    }

    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        // A press starts a drag-coded sequence; forget the hover-motion dedupe cell so the
        // first post-release move back into it isn't swallowed as a duplicate.
        lastReportedMotionCell = nil
        if copyMode != nil { return } // copy mode is keyboard-driven; ignore clicks
        // ⌘-click opens an OSC 8 hyperlink or an auto-detected URL.
        // ⌘ overrides mouse reporting, the same way Shift overrides it for selection.
        if event.modifierFlags.contains(.command), let pos = cell(at: event.locationInWindow),
           let url = linkURL(atRow: pos.row, column: pos.column) {
            openLink(url)
            return
        }
        if isMouseReporting(event) {
            reportPressIfOnGrid(event, button: .left)
            return
        }
        guard let pos = cell(at: event.locationInWindow) else { return }
        // Click count picks the selection unit (1 = char, 2 = word, 3 = line); Option = rectangle.
        switch event.clickCount {
        case 2: selectionGranularity = .word
        case let n where n >= 3: selectionGranularity = .line
        default: selectionGranularity = .character
        }
        selectionRectangular = event.modifierFlags.contains(.option)
        if event.clickCount >= 3, !selectionRectangular {
            // Triple-click selects the whole LOGICAL line across soft wraps,
            // not just the display row. Anchor across the wrapped buffer lines; `.line` granularity
            // then fills each to full width and the multi-row linear region covers the logical line.
            let span = logicalLineBufferRowSpan(at: pos.row)
            selectionAnchor = (line: span.lowerBound, column: 0)
            selectionHead = (line: span.upperBound, column: max(0, columns - 1))
        } else {
            let line = viewportTopBufferLine + pos.row
            selectionAnchor = (line: line, column: pos.column)
            selectionHead = (line: line, column: pos.column)
        }
        scheduleRender()
    }

    /// The buffer-line span of the logical (soft-wrapped) line at viewport `row` — the lines a
    /// triple-click selects. Absolute (content-anchored), and no longer clamped to the viewport:
    /// the off-screen tail of a wrapped line is part of the selection too.
    private func logicalLineBufferRowSpan(at row: Int) -> ClosedRange<Int> {
        emulatorSync { emu in
            let base = emu.historyCount - scrollOffset // buffer-line index of viewport row 0
            return emu.logicalLineRowSpan(virtualLine: base + row)
        }
    }

    /// The clickable URL at a grid cell (OSC 8 hyperlink first, else an auto-detected URL).
    private func linkURL(atRow row: Int, column col: Int) -> String? {
        linkRange(atRow: row, column: col)?.url
    }

    /// The clickable link at a grid cell *and* its column span — an OSC 8 hyperlink (the run of
    /// adjacent cells sharing its id) first, else an auto-detected URL in the row text. The row is
    /// built one character per cell so `column`/the returned range map directly to grid columns.
    func linkRange(atRow row: Int, column col: Int) -> (url: String, columns: Range<Int>)? {
        testingLinkProbeCount += 1
        return emulatorSync { emulator in
            guard row >= 0, row < emulator.rows, col >= 0 else { return nil }
            // One row, not a full viewport snapshot: this runs on every ⌘-hover cell change.
            let top = emulator.historyCount - max(0, min(scrollOffset, emulator.historyCount))
            let cells = emulator.bufferLine(top + row)
            guard col < cells.count else { return nil }
            let cell = cells[col]
            if cell.hyperlinkID != 0, let url = emulator.hyperlinkURL(id: cell.hyperlinkID) {
                var lo = col, hi = col
                while lo > 0, cells[lo - 1].hyperlinkID == cell.hyperlinkID { lo -= 1 }
                while hi + 1 < cells.count, cells[hi + 1].hyperlinkID == cell.hyperlinkID { hi += 1 }
                return (url, lo ..< (hi + 1))
            }
            var line = ""
            line.reserveCapacity(cells.count)
            for cell in cells {
                guard cell.width != .spacerTail else { line.append(" "); continue }
                line.unicodeScalars.append(cell.codepoint == 0 ? " " : (Unicode.Scalar(cell.codepoint) ?? " "))
            }
            return URLDetection.match(in: line, at: col)
        }
    }

    /// Open a clicked link, restricted to safe schemes so terminal output can't trigger a
    /// surprising handler (e.g. a custom app scheme) on ⌘-click. Plain `file:` OSC 8 links
    /// remain blocked; auto-detected `path:line(:col)` tokens use `harness-file://`, which
    /// validates that the target is an existing local regular file and opens it in the user's
    /// plain-text editor instead of LaunchServices' default execute handler.
    private func openLink(_ string: String) {
        if let target = URLDetection.FileLocationTarget(urlString: string) {
            let cwd = emulatorSync { $0.workingDirectory }
            guard let fileURL = Self.resolveSafeLocalFileURL(target, workingDirectory: cwd),
                  let editorURL = NSWorkspace.shared.urlForApplication(toOpen: .plainText) else {
                return
            }
            NSWorkspace.shared.open(
                [fileURL],
                withApplicationAt: editorURL,
                configuration: NSWorkspace.OpenConfiguration()
            )
            return
        }
        guard let url = URL(string: string), let scheme = url.scheme?.lowercased(),
              ["http", "https", "mailto", "ftp", "ftps"].contains(scheme) else { return }
        NSWorkspace.shared.open(url)
    }

    private nonisolated static let blockedExecutableExtensions: Set<String> = [
        "action", "app", "bin", "command", "csh", "dmg", "exe", "fish", "ksh",
        "MSI", "msi", "mpkg", "osax", "pkg", "run", "scpt", "scptd",
        "sh", "terminal", "tool", "workflow", "zsh",
    ]

    /// Resolves a `FileLocationTarget` to a verified local regular file URL suitable for opening
    /// in a text editor, or `nil` if the path does not exist, escapes a relative root, or points
    /// at a directory, bundle, package, or launchable/executable script extension.
    public nonisolated static func resolveSafeLocalFileURL(
        _ target: URLDetection.FileLocationTarget,
        workingDirectory: String?
    ) -> URL? {
        let raw = target.path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty, !raw.contains("\0") else { return nil }

        let candidateURL: URL
        var requiredRootURL: URL?
        if raw.hasPrefix("~/") {
            let expanded = (raw as NSString).expandingTildeInPath
            candidateURL = URL(fileURLWithPath: expanded)
        } else if raw.hasPrefix("/") {
            candidateURL = URL(fileURLWithPath: raw)
        } else {
            let components = raw.split(separator: "/", omittingEmptySubsequences: false)
            if components.contains("..") { return nil }
            guard let workingDirectory, !workingDirectory.isEmpty else { return nil }
            let base = Self.directoryPath(fromWorkingDirectory: workingDirectory)
            guard base.hasPrefix("/") else { return nil }
            let root = URL(fileURLWithPath: base, isDirectory: true)
                .standardizedFileURL
                .resolvingSymlinksInPath()
            requiredRootURL = root
            candidateURL = root.appendingPathComponent(raw)
        }

        let resolved = candidateURL.standardizedFileURL.resolvingSymlinksInPath()
        if let root = requiredRootURL {
            let rootPrefix = root.path.hasSuffix("/") ? root.path : root.path + "/"
            guard resolved.path.hasPrefix(rootPrefix) else { return nil }
        }

        let ext = resolved.pathExtension.lowercased()
        if blockedExecutableExtensions.contains(ext) {
            return nil
        }

        guard let values = try? resolved.resourceValues(
            forKeys: [.isRegularFileKey, .isDirectoryKey, .isPackageKey, .isApplicationKey]
        ),
        values.isRegularFile == true,
        values.isDirectory != true,
        values.isPackage != true,
        values.isApplication != true else {
            return nil
        }

        return resolved
    }

    private nonisolated static func directoryPath(fromWorkingDirectory raw: String) -> String {
        if raw.hasPrefix("file://"), let url = URL(string: raw), url.isFileURL {
            return url.path
        }
        return raw
    }

    public override func mouseDragged(with event: NSEvent) {
        if copyMode != nil { return }
        if isMouseReporting(event) {
            // Only report motion when the app asked for drag / any-motion tracking.
            let modes = inputModes()
            guard modes.mouseDrag || modes.mouseAny, !unreportedMouseButtons.contains(event.buttonNumber),
                  let pos = cell(at: event.locationInWindow) else { return }
            let at = modes.mouseSGRPixel ? textAreaPixelPosition(of: event) ?? (pos.column, pos.row) : (pos.column, pos.row)
            if let last = lastReportedDrag, last == at { return }
            lastReportedDrag = at
            reportMouse(event, button: .left, kind: .drag)
            return
        }
        guard selectionAnchor != nil, let pos = cell(at: event.locationInWindow) else { return }
        selectionHead = (line: viewportTopBufferLine + pos.row, column: pos.column)
        scheduleRender()
    }

    public override func mouseUp(with event: NSEvent) {
        if copyMode != nil { return }
        if isMouseReporting(event) {
            reportReleaseIfPressed(event, button: .left)
            return
        }
        // A single-cell *character* click with no drag clears; a word/line click (or any drag)
        // makes a real selection that copy-on-select copies.
        if let a = selectionAnchor, let h = selectionHead, a == h, selectionGranularity == .character {
            clearSelection()
            return
        }
        if copyOnSelect { copySelection() }
    }

    public override func rightMouseDown(with event: NSEvent) {
        if isMouseReporting(event) { reportPressIfOnGrid(event, button: .right) }
        else { super.rightMouseDown(with: event) }
    }

    public override func rightMouseUp(with event: NSEvent) {
        if isMouseReporting(event) { reportReleaseIfPressed(event, button: .right) }
        else { super.rightMouseUp(with: event) }
    }

    public override func otherMouseDown(with event: NSEvent) {
        if isMouseReporting(event) {
            reportPressIfOnGrid(event, button: .middle)
        } else if event.buttonNumber == 2 {
            // Middle-click pastes the current selection (the X11 primary-paste
            // convention), falling back to the clipboard. Routed through pasteText so
            // bracketed paste and paste protection apply exactly like ⌘V.
            if let text = selectionTextIfAny() ?? NSPasteboard.general.string(forType: .string),
               !text.isEmpty {
                pasteText(text)
            }
        } else {
            super.otherMouseDown(with: event)
        }
    }

    public override func otherMouseUp(with event: NSEvent) {
        if isMouseReporting(event) { reportReleaseIfPressed(event, button: .middle) }
        else { super.otherMouseUp(with: event) }
    }
}
