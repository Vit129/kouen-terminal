import AppKit

/// Custom NSWindow subclass that guards against RL-040 zombie view crashes.
///
/// On macOS 26 / Swift 6.3, the `@MainActor` `@objc` thunk for NSView overrides
/// performs `swift_task_isCurrentExecutorWithFlagsImpl` which dereferences `self`
/// metadata. If the view is freed (zombie), this crashes with EXC_BAD_ACCESS before
/// any Swift `guard window != nil` can run.
///
/// This window drops events targeted at views that have lost their window reference,
/// preventing keyboard/mouse-driven crashes. For layout/display-driven crashes
/// (layout(), resetCursorRects(), hitTest()), the retire-hold pattern in
/// `TerminalPaneRegistry` and `ContentAreaViewController` handles those by preventing
/// premature deallocation.
@MainActor
final class HarnessWindow: NSWindow {
    override func sendEvent(_ event: NSEvent) {
        // Guard keyboard events: if the first responder's view has no window, skip.
        switch event.type {
        case .keyDown, .keyUp:
            if let responder = firstResponder as? NSView, responder.window == nil {
                return
            }
        case .mouseMoved, .mouseEntered, .mouseExited:
            // Mouse tracking events can target views removed mid-flight.
            // locationInWindow → hitTest on freed view. If our contentView is gone, bail.
            guard contentView?.window != nil else { return }
        default:
            break
        }
        super.sendEvent(event)
    }
}
