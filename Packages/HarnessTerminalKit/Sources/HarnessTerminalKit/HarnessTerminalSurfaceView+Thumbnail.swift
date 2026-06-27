import AppKit

extension HarnessTerminalSurfaceView {
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
