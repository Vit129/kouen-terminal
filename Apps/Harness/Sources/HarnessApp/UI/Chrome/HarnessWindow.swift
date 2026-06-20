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
    /// RL-040: `nonisolated` bypasses the Swift 6.3 `@objc` thunk actor-isolation check
    /// (`swift_task_isCurrentExecutorWithFlagsImpl`) which dereferences corrupted task/view
    /// metadata when the runtime context is partially torn down during dealloc cascades.
    /// `sendEvent` is always called on the main thread by AppKit.
    nonisolated override func sendEvent(_ event: NSEvent) {
        // Guard: if this window is closing (contentView removed), drop all events.
        guard self.contentView != nil else { return }
        // Guard keyboard events: if the first responder's view has no window, skip.
        switch event.type {
        case .keyDown, .keyUp:
            if let responder = self.firstResponder as? NSView, responder.window == nil {
                return
            }
        case .mouseMoved, .mouseEntered, .mouseExited:
            // Mouse tracking events can target views removed mid-flight.
            guard self.contentView?.window != nil else { return }
        default:
            break
        }
        nonisolated(unsafe) let ev = event
        super.sendEvent(ev)
    }

    /// RL-040: Hold a strong reference during close so AppKit's event routing does not
    /// hit a deallocated window between `close()` and the next runloop drain.
    private nonisolated(unsafe) static var retiredWindows: [HarnessWindow] = []

    nonisolated override func close() {
        Self.retiredWindows.append(self)
        super.close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Self.retiredWindows.removeAll { $0 === self }
        }
    }
}
