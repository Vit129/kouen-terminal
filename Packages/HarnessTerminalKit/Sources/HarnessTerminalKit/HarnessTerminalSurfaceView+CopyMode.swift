import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Copy mode

    /// Enter copy mode, seeding the cursor at the live terminal cursor. The view's own
    /// emulator holds the scrollback, so no daemon text capture is needed.
    public func enterCopyMode() {
        guard copyMode == nil else { return }
        copyModeTables = KeybindingsStore.load()
        copyModeSearchEntry = nil
        copyMode = emulatorSync { emulator in
            let live = emulator.readGrid()
            let cursorLine = emulator.historyCount + live.cursor.row
            return CopyModeReducer.initialState(grid: emulator, cursorLine: cursorLine, cursorColumn: live.cursor.col)
        }
        scrollOffset = 0
        scrollFraction = 0 // copy mode is line-based; don't carry a smooth-scroll fraction in
        wheelLineRemainder = 0 // don't carry a sub-line wheel remainder across the mode boundary
        wheelColumnRemainder = 0
        notifyScrollChanged(historyCount: emulatorSync { $0.historyCount })
        scheduleRender()
    }

    /// Exit copy mode and return to the live bottom.
    public func exitCopyMode() {
        guard copyMode != nil else { return }
        copyMode = nil
        copyModeSearchEntry = nil
        scrollOffset = 0
        scrollFraction = 0
        wheelLineRemainder = 0
        wheelColumnRemainder = 0
        notifyScrollChanged(historyCount: emulatorSync { $0.historyCount })
        scheduleRender()
    }

    /// Run a copy-mode action from outside the view (the `:` prompt, `send-keys -X`,
    /// `copy-mode -X`). No-op when not in copy mode.
    public func performCopyModeAction(_ action: CopyModeAction) {
        guard copyMode != nil else { return }
        handleCopyModeAction(action)
    }

    func handleCopyModeKey(_ event: NSEvent) {
        // A pending jump-to-char (`f`/`F`/`t`/`T`) consumes the very next keystroke as its target.
        if let kind = copyModeJumpEntry {
            copyModeJumpEntry = nil
            let chars = event.charactersIgnoringModifiers ?? ""
            if chars.unicodeScalars.first?.value != 0x1B, let ch = chars.first { // Escape cancels
                handleCopyModeAction(.jump(kind, String(ch)))
            } else {
                scheduleRender()
            }
            return
        }
        // Interactive search-query entry captures raw keys until Enter / Escape.
        if copyModeSearchEntry != nil {
            handleSearchEntryKey(event)
            return
        }
        guard let spec = Self.copyModeKeySpec(from: event),
              let table = copyModeTables?.table(KeyTableID.copyMode(modeKeys: copyModeKeys)),
              case let .copyModeCommand(action) = table.lookup(spec)?.command
        else { return } // unbound keys are swallowed (copy mode is modal)
        handleCopyModeAction(action)
    }

    func handleCopyModeAction(_ action: CopyModeAction) {
        guard let state = copyMode else { return }
        let separators = copyModeWordSeparators
        let (next, effect) = emulatorSync { CopyModeReducer.reduce(state, action, grid: $0, wordSeparators: separators) }
        copyMode = next
        switch effect {
        case .none:
            scheduleRender()
        case let .copy(text):
            writeCopyModeSelection(text)
            scheduleRender()
        case let .copyAndCancel(text):
            writeCopyModeSelection(text)
            exitCopyMode()
        case let .pipe(text, command):
            copyModePipe(text: text, command: command)
            exitCopyMode()
        case .paste:
            exitCopyMode()
            paste(nil) // paste the most-recent buffer (mirrored to the system pasteboard on yank)
        case .cancel:
            exitCopyMode()
        case .beginSearchEntry:
            copyModeSearchEntry = ""
            scheduleRender()
        case let .beginJumpEntry(kind):
            copyModeJumpEntry = kind
            scheduleRender()
        }
    }

    private func handleSearchEntryKey(_ event: NSEvent) {
        let chars = event.charactersIgnoringModifiers ?? ""
        let scalar = chars.unicodeScalars.first?.value ?? 0
        switch scalar {
        case 0x1B: // Escape — abandon the search
            copyModeSearchEntry = nil
            scheduleRender()
        case 0x0D, 0x03: // Enter — commit
            let query = copyModeSearchEntry ?? ""
            copyModeSearchEntry = nil
            if let state = copyMode, !query.isEmpty {
                copyMode = emulatorSync {
                    CopyModeReducer.applySearch(state, query: query, reverse: state.search.reverse, grid: $0)
                }
            }
            scheduleRender()
        case 0x7F, 0x08: // Backspace
            if var q = copyModeSearchEntry, !q.isEmpty { q.removeLast(); copyModeSearchEntry = q }
            scheduleRender()
        default:
            if scalar >= 0x20, !chars.isEmpty { copyModeSearchEntry = (copyModeSearchEntry ?? "") + chars }
            scheduleRender()
        }
    }

    private func writeCopyModeSelection(_ text: String) {
        guard !text.isEmpty else { return }
        let region = copyModeSelectionRegion()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let accepted = pasteboard.setString(text, forType: .string)
        onCopy?(text) // mirror into the daemon paste buffer
        if CopyConfirmation.fadesSelection(pasteboardAccepted: accepted) {
            fadeSelection(region: region)
        }
    }

    private func copyModeSelectionRegion() -> SelectionRegion? {
        guard let cm = copyMode else { return nil }
        return cm.viewportSelection(rows: rows, columns: columns).map { vs in
            switch vs.kind {
            case .linear:
                return .linear(TerminalSelection((vs.startRow, vs.startColumn), (vs.endRow, vs.endColumn)))
            case .block:
                return .block(BlockSelection((vs.startRow, vs.startColumn), (vs.endRow, vs.endColumn)))
            }
        }
    }

    /// Brief confirmation that the pasteboard accepted the selection. A failed write never gets here.
    func fadeSelection(region: SelectionRegion?) {
        selectionFadeView?.removeFromSuperview()
        guard let region, let rect = selectionFadeRect(region), rect.width > 0, rect.height > 0 else { return }
        let overlay = NSView(frame: rect)
        overlay.wantsLayer = true
        overlay.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.28).cgColor
        overlay.layer?.cornerRadius = 2
        addSubview(overlay)
        selectionFadeView = overlay
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : 0.22
            overlay.animator().alphaValue = 0
        }, completionHandler: { [weak overlay] in
            DispatchQueue.main.async { [weak overlay] in overlay?.removeFromSuperview() }
        })
    }

    private func selectionFadeRect(_ region: SelectionRegion) -> CGRect? {
        switch region {
        case let .linear(sel):
            return unionCellRects(startRow: sel.startRow, endRow: sel.endRow) { row in
                let columns: Range<Int>
                if sel.startRow == sel.endRow {
                    columns = sel.startColumn ..< (sel.endColumn + 1)
                } else if row == sel.startRow {
                    columns = sel.startColumn ..< self.columns
                } else if row == sel.endRow {
                    columns = 0 ..< (sel.endColumn + 1)
                } else {
                    columns = 0 ..< self.columns
                }
                return cellRect(row: row, columns: columns)
            }
        case let .block(blk):
            let columns = blk.startColumn ..< (blk.endColumn + 1)
            return unionCellRects(startRow: blk.startRow, endRow: blk.endRow) { row in
                cellRect(row: row, columns: columns)
            }
        }
    }

    private func unionCellRects(startRow: Int, endRow: Int, _ rect: (Int) -> CGRect?) -> CGRect? {
        let lo = max(0, min(startRow, endRow))
        let hi = min(rows - 1, max(startRow, endRow))
        guard lo <= hi else { return nil }
        var union: CGRect?
        for row in lo ... hi {
            guard let piece = rect(row) else { continue }
            union = union?.union(piece) ?? piece
        }
        return union
    }

    /// `copy-pipe`: feed the selected text to a shell command's stdin (detached), like tmux.
    private func copyModePipe(text: String, command: String) {
        guard !text.isEmpty, !command.isEmpty else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        let pipe = Pipe()
        process.standardInput = pipe
        // Don't let the child inherit the GUI app's stdout/stderr (it would leak app fds and
        // could block on a full inherited pipe); discard its output like tmux's copy-pipe.
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        // Reap the child so it can't linger as a zombie across many copy-pipe invocations.
        process.terminationHandler = { _ in }
        guard (try? process.run()) != nil else { return }
        // Write off the main thread so a large selection into a slow/non-draining command can't
        // block the UI; a closed pipe (child already exited) throws and is ignored.
        let data = Data(text.utf8)
        let writer = pipe.fileHandleForWriting
        DispatchQueue.global(qos: .utility).async {
            try? writer.write(contentsOf: data)
            try? writer.close()
        }
    }

    /// Convert an `NSEvent` to a `KeySpec` for copy-mode table lookup (mirrors the prefix
    /// keymap's mapping; kept local so the live-input path is untouched).
    private static func copyModeKeySpec(from event: NSEvent) -> KeySpec? {
        guard let chars = event.charactersIgnoringModifiers else { return nil }
        let key: String
        if chars.count == 1, let scalar = chars.unicodeScalars.first {
            switch scalar.value {
            case 0x1B: key = "Escape"
            case 0x09, 0x19: key = "Tab"  // 0x19 = NSBackTabCharacter (Shift-Tab)
            case 0x0D, 0x03: key = "Enter"
            case 0x7F: key = "Backspace"
            case 0x20: key = "Space"
            case 0xF700: key = "Up"
            case 0xF701: key = "Down"
            case 0xF702: key = "Left"
            case 0xF703: key = "Right"
            case 0xF729: key = "Home"
            case 0xF72B: key = "End"
            case 0xF72C: key = "PageUp"
            case 0xF72D: key = "PageDown"
            default: key = chars
            }
        } else {
            key = chars
        }
        var modifiers: KeySpec.Modifiers = []
        let mask = event.modifierFlags
        if mask.contains(.control) { modifiers.insert(.control) }
        if mask.contains(.option) { modifiers.insert(.option) }
        if mask.contains(.command) { modifiers.insert(.command) }
        if mask.contains(.shift), key.count > 1 { modifiers.insert(.shift) }
        return KeySpec(key: key, modifiers: modifiers)
    }

    nonisolated static func applyCopyModeStatus(
        into frame: inout TerminalFrame, text: String, builder: FrameBuilder,
        selectionBackground: HarnessTheme.RGBColor?, canvasForeground: HarnessTheme.RGBColor, canvasBackground: HarnessTheme.RGBColor
    ) {
        let row = frame.rows - 1
        guard row >= 0, frame.columns > 0 else { return }
        let bandBg = builder.renderColor(selectionBackground ?? canvasForeground)
        let bandFg = builder.renderColor(canvasBackground)
        let layout = TerminalTextLayout(text: text, columns: frame.columns)
        var nextClusterID: UInt32 = 0x7fff_ffff
        for col in 0 ..< frame.columns {
            let source = col < layout.cells.count ? layout.cells[col] : .blank
            var combining1 = source.combining1
            if source.clusterID != 0, let cluster = layout.clusters[source.clusterID] {
                while frame.clusters[nextClusterID] != nil { nextClusterID -= 1 }
                frame.clusters[nextClusterID] = cluster
                combining1 = nextClusterID | 0x8000_0000
                nextClusterID -= 1
            }
            frame.updateCell(row: row, column: col) { cell in
                cell.codepoint = source.codepoint == 0 && source.width != .spacerTail ? 0x20 : source.codepoint
                cell.foreground = bandFg; cell.background = bandBg
                cell.drawBackground = true; cell.underlineColor = bandFg
                cell.bold = false; cell.italic = false; cell.underline = .none; cell.blink = false
                cell.strikethrough = false; cell.overline = false; cell.colorGlyphOpacity = 1
                cell.width = source.width
                cell.combining0 = source.combining0; cell.combining1 = combining1
            }
        }
    }
}
