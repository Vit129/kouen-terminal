import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Pasteboard, drag and drop, context menu

    /// Standard responder copy (Edit ▸ Copy / ⌘C via the menu).
    @objc public func copy(_ sender: Any?) {
        copySelection()
    }

    /// Standard responder cut (Edit ▸ Cut / ⌘X). A terminal's scrollback is read-only, so cut
    /// behaves as copy — without this, the Edit-menu Cut item (which targets `cut:`) no-ops.
    @objc public func cut(_ sender: Any?) {
        copySelection()
    }

    /// Standard responder paste (Edit ▸ Paste / ⌘V). Sends the clipboard text to the PTY,
    /// wrapped in bracketed-paste markers when the program enabled DECSET 2004 (so shells and
    /// editors treat it as a literal paste, not typed input). Newlines normalize to CR (the
    /// Enter byte) so multi-line pastes run line by line.
    ///
    /// When the clipboard holds no text but an image (a screenshot) or a copied file, the image is
    /// written to a temp PNG and its shell-quoted path is pasted instead — so programs that accept
    /// image-file paths (Claude Code, etc.) attach it. Mirrors the file-drop path.
    @objc public func paste(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        // Text fast path.
        if let raw = pasteboard.string(forType: .string), !raw.isEmpty {
            pasteText(raw)
            return
        }
        if let upload = uploadForPaste {
            if let png = Self.pngImageData(from: pasteboard) {
                pasteRemotely([(png, "pasted.png")], upload: upload)
            } else {
                pasteRemotely(Self.uploadable(Self.droppedFileURLs(from: pasteboard)), upload: upload)
            }
            return
        }
        // Image on the clipboard → write a temp PNG, paste its quoted path.
        if let path = Self.writePastedImage(from: pasteboard) {
            pasteText(Self.shellQuotedPath(path))
            return
        }
        // A file copied in Finder (⌘C → ⌘V) → paste the quoted path(s), like a drag-drop.
        let text = Self.droppedPathText(for: Self.droppedFileURLs(from: pasteboard))
        if !text.isEmpty { pasteText(text) }
    }

    /// If the pasteboard holds a valid image, write it to the pasted-images directory as a PNG and
    /// return the file path. Prefers raw PNG bytes; converts TIFF / other image reps via a bitmap
    /// rep. Returns nil when there's no usable image. Validation is via `NSBitmapImageRep` (not the
    /// engine's `ImageDecoder`, whose inline-display pixel cap would wrongly reject a high-res
    /// Retina/Pro-Display screenshot — pasting a *path* has no such limit).
    static func writePastedImage(from pasteboard: NSPasteboard) -> String? {
        guard let png = pngImageData(from: pasteboard) else { return nil }
        let dir = HarnessPaths.pastedImagesDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        prunePastedImages(in: dir)
        let stamp = Int(Date().timeIntervalSince1970)
        let url = dir.appendingPathComponent("pasted-\(stamp)-\(UUID().uuidString.prefix(8)).png")
        do { try png.write(to: url); return url.path } catch { return nil }
    }

    /// Best-effort PNG bytes for whatever image the pasteboard carries (screenshot = PNG/TIFF).
    static func pngImageData(from pasteboard: NSPasteboard) -> Data? {
        // A screenshot is already PNG — trust the raw bytes once they parse as an image.
        if let png = pasteboard.data(forType: .png), NSBitmapImageRep(data: png) != nil {
            return png
        }
        // Otherwise re-encode a TIFF / NSImage payload to PNG.
        let tiff = pasteboard.data(forType: .tiff) ?? NSImage(pasteboard: pasteboard)?.tiffRepresentation
        if let tiff, let rep = NSBitmapImageRep(data: tiff) {
            return rep.representation(using: .png, properties: [:])
        }
        return nil
    }

    /// Drop pasted-image files older than a day so the directory can't grow unbounded.
    private static func prunePastedImages(in dir: URL, olderThan maxAge: TimeInterval = 24 * 60 * 60) {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]
        ) else { return }
        let cutoff = Date().addingTimeInterval(-maxAge)
        for url in entries {
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
            if let modified, modified < cutoff { try? fm.removeItem(at: url) }
        }
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        pathDropOperation(for: sender)
    }

    public override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        pathDropOperation(for: sender)
    }

    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let urls = Self.droppedFileURLs(from: sender.draggingPasteboard)
        let text = Self.droppedPathText(for: urls)
        guard !text.isEmpty else { return false }
        window?.makeFirstResponder(self)
        if let upload = uploadForPaste {
            pasteRemotely(Self.uploadable(urls), upload: upload)
        } else {
            pasteText(text)
        }
        return true
    }

    private func pathDropOperation(for sender: NSDraggingInfo) -> NSDragOperation {
        guard
            sender.draggingSourceOperationMask.contains(.copy),
            !Self.droppedFileURLs(from: sender.draggingPasteboard).isEmpty
        else { return [] }
        return .copy
    }

    func pasteText(_ raw: String) {
        let normalized = raw
            .replacingOccurrences(of: "\r\n", with: "\r")
            .replacingOccurrences(of: "\n", with: "\r")
        // Paste protection: confirm risky text when the program hasn't enabled bracketed paste
        // (which would otherwise run embedded newlines as commands the moment they're pasted).
        let bracketed = inputModes().bracketedPaste
        if pasteProtection, !bracketed, Self.isUnsafePaste(normalized) {
            guard let window else {
                onNotice?("Paste blocked: it contains line breaks or control characters, and this pane has no window to confirm it in.")
                return
            }
            confirmPaste(normalized, in: window)
            return
        }
        deliverPaste(normalized)
    }

    private func deliverPaste(_ normalized: String) {
        snapToBottom()
        clearSelection()
        emit(inputEncoder.encodePaste(normalized, modes: inputModes()))
    }

    /// Unsafe = contains a line break (would run as a command without bracketed paste) or another
    /// control character. Newlines are already normalized to `\r` before this check.
    private static func isUnsafePaste(_ text: String) -> Bool {
        text.unicodeScalars.contains { $0.value < 0x20 && $0 != "\t" }
    }

    private func confirmPaste(_ normalized: String, in window: NSWindow) {
        let lineCount = normalized.split(separator: "\r", omittingEmptySubsequences: false).count
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = lineCount > 1 ? "Paste \(lineCount) lines into the terminal?" : "Paste into the terminal?"
        alert.informativeText = "The clipboard contains line breaks or control characters that can run commands immediately. "
            + "Review before pasting."
        alert.addButton(withTitle: "Paste")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window) { [weak self] response in
            guard response == .alertFirstButtonReturn else { return }
            self?.deliverPaste(normalized)
        }
    }

    /// Select the entire visible viewport (Edit ▸ Select All / ⌘A).
    @objc public override func selectAll(_ sender: Any?) {
        guard rows > 0, columns > 0 else { return }
        selectionGranularity = .character
        selectionRectangular = false
        let top = viewportTopBufferLine
        selectionAnchor = (line: top, column: 0)
        selectionHead = (line: top + rows - 1, column: columns - 1)
        scheduleRender()
    }

    /// Right-click context menu (Copy / Paste / Select All). Suppressed while the program is
    /// capturing the mouse (unless Shift forces local handling), matching the selection rules.
    public override func menu(for event: NSEvent) -> NSMenu? {
        guard !isMouseReporting(event) else { return nil }
        let menu = NSMenu()
        let copyItem = NSMenuItem(title: "Copy", action: #selector(copy(_:)), keyEquivalent: "")
        copyItem.target = self
        menu.addItem(copyItem)
        let pasteItem = NSMenuItem(title: "Paste", action: #selector(paste(_:)), keyEquivalent: "")
        pasteItem.target = self
        menu.addItem(pasteItem)
        menu.addItem(.separator())
        let selectAllItem = NSMenuItem(title: "Select All", action: #selector(selectAll(_:)), keyEquivalent: "")
        selectAllItem.target = self
        menu.addItem(selectAllItem)
        if let cell = cell(at: event.locationInWindow) {
            let line = viewportTopBufferLine + cell.row
            typealias CommandContext = (command: TerminalCommandRegion?, hasInput: Bool, hasOutput: Bool, hasFailures: Bool)
            let context = emulatorSync { emulator -> CommandContext in
                let command = emulator.command(atBufferLine: line, column: cell.column)
                return (command, command?.inputRange != nil, command?.outputRange != nil,
                        emulator.commandRegions.contains { ($0.exitCode ?? 0) != 0 })
            }
            if let command = context.command, context.hasInput || context.hasOutput {
                menu.addItem(.separator())
                var actions: [(String, Selector)] = []
                if context.hasInput { actions.append(("Copy Command", #selector(copyContextCommand(_:)))) }
                if context.hasOutput {
                    actions += [("Copy Output", #selector(copyContextCommandOutput(_:))),
                                ("Select Output", #selector(selectContextCommandOutput(_:))),
                                ("Find in Command Output", #selector(findContextCommandOutput(_:)))]
                }
                for (title, action) in actions {
                    let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
                    item.target = self
                    item.representedObject = command
                    menu.addItem(item)
                }
            }
            if context.hasFailures {
                menu.addItem(.separator())
                for (title, action) in [("Previous Failed Command", #selector(previousFailedCommand(_:))),
                                        ("Next Failed Command", #selector(nextFailedCommand(_:)))] {
                    let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
                    item.target = self
                    menu.addItem(item)
                }
            }
        }
        return menu
    }

    func copySelection() {
        guard let text = selectionTextIfAny(), !text.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let accepted = pasteboard.setString(text, forType: .string)
        onCopy?(text)
        if CopyConfirmation.fadesSelection(pasteboardAccepted: accepted) {
            fadeSelection(region: currentSelectionRegion)
        }
    }

    /// The current selection's text, or nil when there is no selection (or it's empty).
    /// Extracted in ABSOLUTE buffer-line space via `bufferLine` — after scrolling (or new
    /// output) the selection can extend beyond the current viewport, where the old
    /// viewport-snapshot read would have come back blank (#161).
    func selectionTextIfAny() -> String? {
        guard let raw = currentRawSelection else { return nil }
        let text = emulatorSync { emu -> String in
            guard let region = Self.resolveAbsoluteSelectionRegion(raw, emulator: emu, columns: columns)
            else { return "" }
            switch region {
            case let .linear(sel): return Self.selectedText(sel, emulator: emu)
            case let .block(blk): return Self.blockSelectedText(blk, emulator: emu)
            }
        }
        return text.isEmpty ? nil : text
    }

    /// Extract the selected text (region rows = absolute buffer lines): per line, the in-range
    /// columns, skipping the trailing spacer of wide chars, trailing whitespace trimmed, rows
    /// joined by \n.
    nonisolated static func selectedText(_ sel: TerminalSelection, emulator: TerminalEmulator) -> String {
        var text = ""
        for row in sel.startRow ... sel.endRow {
            let cells = emulator.bufferLine(row)
            let start = row == sel.startRow ? sel.startColumn : 0
            var end = row == sel.endRow ? sel.endColumn : cells.count - 1
            let continues = row < sel.endRow && emulator.isBufferLineWrapped(row)
            if continues, emulator.wideDeferralGap(atBufferLine: row) > 0 {
                end = min(end, cells.count - 2)
            }
            let segment = rowText(cells: cells, startCol: start, endCol: end,
                                  clusters: emulator.clusters, ending: continues ? .soft : .hard)
            text += segment
            if row < sel.endRow && !continues { text += "\n" }
        }
        return text
    }

    /// Extract a rectangular (block) selection: the same column span on every line, joined by \n.
    private nonisolated static func blockSelectedText(_ blk: BlockSelection, emulator: TerminalEmulator) -> String {
        (blk.startRow ... blk.endRow)
            .map { rowText(cells: emulator.bufferLine($0), startCol: blk.startColumn, endCol: blk.endColumn, clusters: emulator.clusters) }
            .joined(separator: "\n")
    }

    /// One buffer line's text over `[startCol, endCol]` (clamped to the line): drop wide-char
    /// spacer tails, blanks → space, trailing whitespace trimmed.
    private enum TextLineEnding { case soft, hard }

    private nonisolated static func rowText(
        cells: [TerminalGridCell], startCol: Int, endCol: Int, clusters: [UInt32: String], ending: TextLineEnding = .hard
    ) -> String {
        var line = ""
        var col = max(0, startCol)
        let last = min(endCol, cells.count - 1)
        while col <= last {
            let cell = cells[col]
            if cell.width == .spacerTail { col += 1; continue }
            if cell.codepoint != 0 {
                line += cell.resolvedCluster(in: clusters)
            } else {
                line += " "
            }
            col += 1
        }
        if ending == .hard { while line.hasSuffix(" ") { line.removeLast() } }
        return line
    }
}
