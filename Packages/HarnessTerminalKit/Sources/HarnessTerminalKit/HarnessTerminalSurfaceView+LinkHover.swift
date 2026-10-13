import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Link hover (⌘-hover affordance)

    private func cellSizePoints() -> (w: CGFloat, h: CGFloat)? {
        guard let renderer else { return nil }
        let scale = window?.backingScaleFactor ?? 2.0
        let w = CGFloat(renderer.cellPixelWidth) / scale
        let h = CGFloat(renderer.cellPixelHeight) / scale
        guard w > 0, h > 0 else { return nil }
        return (w, h)
    }

    /// The view-space rect (bottom-left origin, matching `cell(at:)`'s inverse) covering a grid
    /// `row` and half-open `columns` span.
    func cellRect(row: Int, columns: Range<Int>) -> CGRect? {
        guard let (w, h) = cellSizePoints(), !columns.isEmpty else { return nil }
        let x = gridOriginPointsX + CGFloat(columns.lowerBound) * w
        let y = bounds.height - gridOriginPointsY - CGFloat(row + 1) * h
        return CGRect(x: x, y: y, width: CGFloat(columns.count) * w, height: h)
    }

    func hoveredLinkRect() -> CGRect? {
        guard let link = hoveredLink else { return nil }
        return cellRect(row: link.row, columns: link.columns)
    }

    override public func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self, userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    public override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        updateLinkHover(at: event.locationInWindow, modifiers: event.modifierFlags)
        reportAnyEventMotionIfArmed(event)
    }

    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        clearLinkHover()
        lastReportedMotionCell = nil
    }

    /// DECSET 1003 any-event tracking: report pointer MOTION with no button held. Shift
    /// keeps its standard local-override meaning, and copy mode owns the surface.
    private func reportAnyEventMotionIfArmed(_ event: NSEvent) {
        guard copyMode == nil, inputModes().mouseAny,
              !event.modifierFlags.contains(.shift) else { return }
        guard isInsideGrid(event.locationInWindow) else { lastReportedMotionCell = nil; return }
        guard let pos = cell(at: event.locationInWindow) else { return }
        if let last = lastReportedMotionCell, last == pos { return }
        lastReportedMotionCell = pos
        reportMouse(event, button: .left, kind: .move) // button is ignored for .move (base code 3)
    }

    public override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        // Pressing/releasing ⌘ over a stationary pointer toggles whether the link is "hot".
        if let window {
            updateLinkHover(at: window.mouseLocationOutsideOfEventStream, modifiers: event.modifierFlags)
        }
        reportModifierKeyIfNeeded(event)
    }

    /// Report a modifier key (Shift/Ctrl/Alt/Cmd/CapsLock) as its own key event when a program
    /// enabled the Kitty protocol's "report all keys as escape codes" flag (0b1000). Release events
    /// additionally require "report event types" (0b10). No-op otherwise — modifiers normally emit
    /// nothing on their own.
    private func reportModifierKeyIfNeeded(_ event: NSEvent) {
        let modes = inputModes()
        guard modes.kittyKeyboardFlags & 0b1000 != 0 else { pressedModifierKeyCodes.removeAll(); return }
        guard copyMode == nil, let key = Self.modifierSpecialKey(forKeyCode: event.keyCode) else { return }
        // flagsChanged toggles: if we already recorded this key down, this event is its release.
        let isPress: Bool
        if pressedModifierKeyCodes.contains(event.keyCode) {
            pressedModifierKeyCodes.remove(event.keyCode)
            isPress = false
        } else {
            pressedModifierKeyCodes.insert(event.keyCode)
            isPress = true
        }
        if !isPress, modes.kittyKeyboardFlags & 0b10 == 0 { return } // release needs event-types
        emit(inputEncoder.encode(key, modifiers: [], event: isPress ? .press : .release, modes: modes))
    }

    /// Map a macOS virtual keycode for a modifier key to its Kitty `SpecialKey`. Left/right are
    /// distinguished by keycode (the device-independent modifier flags can't tell them apart).
    private static func modifierSpecialKey(forKeyCode code: UInt16) -> SpecialKey? {
        switch code {
        case 56: return .leftShift       // kVK_Shift
        case 60: return .rightShift      // kVK_RightShift
        case 59: return .leftControl     // kVK_Control
        case 62: return .rightControl    // kVK_RightControl
        case 58: return .leftAlt         // kVK_Option
        case 61: return .rightAlt        // kVK_RightOption
        case 55: return .leftSuper       // kVK_Command
        case 54: return .rightSuper      // kVK_RightCommand
        case 57: return .capsLock        // kVK_CapsLock
        default: return nil
        }
    }

    /// A link is only highlighted while ⌘ is held (matching ⌘-click open) and the program
    /// isn't grabbing the mouse.
    func updateLinkHover(at locationInWindow: NSPoint, modifiers: NSEvent.ModifierFlags) {
        // `cell(at:)` clamps to the grid, so first require the pointer to actually be inside us
        // (⌘ can be pressed while the pointer rests over another pane).
        guard copyMode == nil, modifiers.contains(.command),
              bounds.contains(convert(locationInWindow, from: nil)),
              let pos = cell(at: locationInWindow)
        else { clearLinkHover(); return }
        // Skip the emulator round trip while the pointer stays inside the hovered link, or on
        // a cell already probed, until the content or scroll position changes.
        let probe = (row: pos.row, column: pos.column, scrollOffset: scrollOffset, revision: findContentRevision)
        if let last = linkHoverProbe, last.scrollOffset == probe.scrollOffset, last.revision == probe.revision {
            if last.row == probe.row, last.column == probe.column { return }
            if let current = hoveredLink, current.row == pos.row, current.columns.contains(pos.column) {
                linkHoverProbe = probe
                return
            }
        }
        guard let link = linkRange(atRow: pos.row, column: pos.column) else {
            clearLinkHover()
            linkHoverProbe = probe
            return
        }
        linkHoverProbe = probe
        if let current = hoveredLink, current.row == pos.row, current.columns == link.columns { return }
        hoveredLink = (row: pos.row, columns: link.columns)
        refreshLinkUnderline()
        window?.invalidateCursorRects(for: self)
    }

    func clearLinkHover() {
        linkHoverProbe = nil
        guard hoveredLink != nil else { return }
        hoveredLink = nil
        refreshLinkUnderline()
        window?.invalidateCursorRects(for: self)
    }

    private func refreshLinkUnderline() {
        // Disable implicit animations so the underline snaps to the pointer instead of sliding.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let rect = hoveredLinkRect() {
            let thickness = max(1, (cellSizePoints()?.h ?? 16) * 0.07)
            linkUnderlineLayer.frame = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: thickness)
            linkUnderlineLayer.isHidden = false
        } else {
            linkUnderlineLayer.isHidden = true
        }
        CATransaction.commit()
    }
}
