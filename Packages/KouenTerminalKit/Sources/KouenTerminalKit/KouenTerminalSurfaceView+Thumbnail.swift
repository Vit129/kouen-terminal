import AppKit
import KouenTerminalEngine

extension KouenTerminalSurfaceView {
    /// Buffer line indices where OSC 133 prompts start — used by block overlay for tinting.
    public var promptRows: [Int] { emulatorSync { $0.promptRows } }
    /// The block (exact command, output line range, exit code) whose prompt is at `line`, or
    /// nil if that shell doesn't emit OSC 133 `C` yet (e.g. bash) or the block hasn't started.
    public func block(atPromptLine line: Int) -> TerminalBlock? { emulatorSync { $0.block(atPromptLine: line) } }
    /// Plain-text lines for a physical-row range (inclusive) — a `TerminalBlock`'s
    /// `outputStartLine...outputEndLine`, for Copy Output Only.
    public func text(fromLine start: Int, toLine end: Int) -> String {
        emulatorSync { $0.captureLines(fromLine: start, toLine: end) }.joined(separator: "\n")
    }
    /// Copy arbitrary text to the system clipboard (block actions that don't copy the live
    /// selection — Copy Output Only / Copy Command Only).
    public func copyText(_ text: String) {
        guard !text.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    /// Send raw text bytes to the PTY (equivalent to the user typing the string).
    public func sendText(_ text: String) { emit(Array(text.utf8)) }

    /// Capture the current rendered frame as a scaled thumbnail.
    /// Returns nil when the view has no window (off-screen / inactive tab).
    public func renderThumbnail(size: NSSize) -> NSImage? {
        guard window != nil, bounds.width > 0, bounds.height > 0 else { return nil }
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        cacheDisplay(in: bounds, to: rep)
        let thumb = NSImage(size: size)
        thumb.lockFocus()
        rep.draw(in: NSRect(origin: .zero, size: size))
        thumb.unlockFocus()
        return thumb
    }
}
