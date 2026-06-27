import AppKit

extension HarnessTerminalSurfaceView {
    /// Buffer line indices where OSC 133 prompts start — used by block overlay for tinting.
    public var promptRows: [Int] { emulatorSync { $0.promptRows } }
    /// Text content of the current selection, or nil if nothing is selected.
    public var selectionString: String? { selectionTextIfAny() }
    /// Copy the current selection to the system clipboard (no-op if nothing selected).
    public func copyBlock() { copySelection() }
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
