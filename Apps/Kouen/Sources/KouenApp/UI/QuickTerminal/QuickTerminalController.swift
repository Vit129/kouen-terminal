import AppKit
import KouenCore

/// Visor-style terminal panel that slides down from the top of the screen on ⌥Space.
/// Press ⌥Space again or Esc to hide.
///
/// Phase 10: panel mechanism + keybinding only. Embedding a real PTY surface is a
/// follow-up (requires daemon surface allocation from a non-window context).
@MainActor
final class QuickTerminalController {
    static let shared = QuickTerminalController()

    private var panel: NSPanel?
    private var globalMonitor: Any?
    // ponytail: local monitor catches ⌥Space when Kouen itself is key;
    // global monitor catches it from every other app. Both are needed.
    private var localMonitor: Any?
    private var isVisible = false

    private init() {}

    // MARK: - Install

    /// Call once from AppDelegate.applicationDidFinishLaunching.
    func install() {
        // NSEvent.addGlobalMonitorForEvents requires Accessibility permission.
        // Without it the call silently returns nil — we check and warn once.
        if !AXIsProcessTrusted() {
            NSLog("QuickTerminal: Accessibility permission not granted — ⌥Space hotkey requires it.")
            // Non-fatal: local monitor still works while Kouen is in front.
        }

        // RL-040 pattern: capture self as nonisolated(unsafe) to avoid the
        // Swift task-executor check inserted by the @MainActor @Sendable thunk.
        // Both NSEvent monitors always fire on the main thread; this is safe.
        nonisolated(unsafe) let this = self

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if Self.isOptionSpace(event) {
                DispatchQueue.main.async { this.toggle() }
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if Self.isOptionSpace(event) {
                DispatchQueue.main.async { this.toggle() }
                return nil // swallow
            }
            // Esc hides the panel when it is key.
            if event.keyCode == 53 /* Escape */, this.isVisible,
               event.window === this.panel {
                DispatchQueue.main.async { this.hide() }
                return nil
            }
            return event
        }
    }

    // MARK: - Toggle

    func toggle() {
        isVisible ? hide() : show()
    }

    // MARK: - Show / Hide

    private func show() {
        let panel = makePanel()
        self.panel = panel

        // Prefer the screen the mouse cursor is on; fall back to main.
        let screen = screenForMouse() ?? NSScreen.main ?? NSScreen.screens[0]
        let targetFrame = panelFrame(for: screen)

        // Slide in from just above the top edge.
        var startFrame = targetFrame
        startFrame.origin.y = screen.frame.maxY

        panel.setFrame(startFrame, display: false)
        panel.alphaValue = 1
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)

        KouenMotion.animate(KouenDesign.Motion.standard, timing: KouenDesign.Motion.standardEase) { _ in
            panel.animator().setFrame(targetFrame, display: true)
        }
        isVisible = true
    }

    private func hide() {
        guard let panel else { return }
        let screen = screenForMouse() ?? NSScreen.main ?? NSScreen.screens[0]

        var offFrame = panel.frame
        offFrame.origin.y = screen.frame.maxY

        KouenMotion.animate(KouenDesign.Motion.fast, timing: KouenDesign.Motion.standardEase) { _ in
            panel.animator().setFrame(offFrame, display: true)
        } completion: { [weak self] in
            panel.orderOut(nil)
            self?.isVisible = false
        }
    }

    // MARK: - Panel construction (lazy — built once, reused)

    private func makePanel() -> NSPanel {
        if let p = panel { return p }

        let screen = screenForMouse() ?? NSScreen.main ?? NSScreen.screens[0]
        let frame = panelFrame(for: screen)

        let p = NSPanel(
            contentRect: frame,
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.isFloatingPanel = true
        p.level = .floating
        p.title = "Quick Terminal"
        // Visible on every Space and in full-screen apps.
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.isRestorable = false

        // Placeholder content: real PTY embedding is Phase 10 follow-up.
        let label = NSTextField(
            labelWithString: "Quick Terminal  ·  ⌥Space to toggle  ·  Esc to hide"
        )
        label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false

        if let cv = p.contentView {
            cv.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cv.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cv.centerYAnchor),
            ])
        }

        // Close button hides instead of deallocating the panel.
        p.delegate = QuickTerminalPanelDelegate.shared

        return p
    }

    // MARK: - Geometry

    private func panelFrame(for screen: NSScreen) -> NSRect {
        let w = screen.visibleFrame.width * 0.6
        let h: CGFloat = 400
        let x = screen.visibleFrame.midX - w / 2
        // Top of the visible frame (below menu bar).
        let y = screen.visibleFrame.maxY - h
        return NSRect(x: x, y: y, width: w, height: h)
    }

    /// Screen whose frame contains the current mouse cursor location.
    private func screenForMouse() -> NSScreen? {
        let loc = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(loc, $0.frame, false) }
    }

    // MARK: - Hotkey matching

    private static func isOptionSpace(_ event: NSEvent) -> Bool {
        let mask: NSEvent.ModifierFlags = [.command, .control, .option, .shift]
        let mods = event.modifierFlags.intersection(mask)
        return mods == .option && event.keyCode == 49 // Space
    }
}

// MARK: - Panel delegate (intercepts close → hide)

/// Catches the panel's close button so it hides rather than destroys the panel.
@MainActor
private final class QuickTerminalPanelDelegate: NSObject, NSWindowDelegate {
    static let shared = QuickTerminalPanelDelegate()
    private override init() { super.init() }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        QuickTerminalController.shared.toggle()
        return false // prevent dealloc
    }
}
