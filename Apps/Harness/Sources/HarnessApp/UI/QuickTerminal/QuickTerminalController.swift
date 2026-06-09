import AppKit
import HarnessCore
import HarnessTerminalKit

/// Owns the quick terminal: a Quake-style dropdown panel hosting a dedicated daemon-backed terminal
/// surface, summoned by a global hotkey. Mirrors `NotchPanelController`'s singleton lifecycle and the
/// `display-popup` surface-creation path (`Phase67UI.presentPopup`).
@MainActor
final class QuickTerminalController: NSObject {
    static let shared = QuickTerminalController()

    private var panel: QuickTerminalPanel?
    private var host: TerminalHostView?
    private var started = false
    private lazy var hotkey = QuickTerminalHotkey { [weak self] in self?.toggle() }

    private override init() { super.init() }

    /// Install the global hotkey at launch (iff enabled). Idempotent.
    func start() {
        guard !started else { return }
        started = true
        rebuildFromSettings()
    }

    /// (Re)register or tear down the global hotkey to match settings. Safe to call on every settings
    /// change — the settings pane calls this alongside `PrefixKeymap.rebuildFromSettings()`.
    func rebuildFromSettings() {
        let settings = SessionCoordinator.shared.settings
        if settings.quickTerminalEnabled {
            hotkey.register(spec: settings.quickTerminalHotkey)
        } else {
            hotkey.unregister()
            hide()
        }
    }

    /// Show if hidden, hide if visible — the action the global hotkey fires.
    func toggle() {
        guard SessionCoordinator.shared.settings.quickTerminalEnabled else { return }
        if let panel, panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    private func show() {
        guard let panel = ensurePanel() else { return }
        panel.setFrame(Self.topFrame(for: NSScreen.main ?? NSScreen.screens.first), display: true)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        host?.focusTerminal()
    }

    private func hide() {
        panel?.orderOut(nil)
    }

    /// Create the panel + its dedicated surface on first use; reuse them thereafter. Returns nil if
    /// the daemon can't mint a surface, so a later toggle can retry.
    private func ensurePanel() -> QuickTerminalPanel? {
        if let panel { return panel }
        let coordinator = SessionCoordinator.shared
        let cwd = coordinator.settings.defaultCWD
        guard case let .surfaceID(sid)? = coordinator.requestDaemon(
                  .createSurface(cwd: cwd, shell: coordinator.settings.defaultShell)),
              let uuid = SurfaceID(uuidString: sid)
        else { return nil }
        let host = coordinator.terminalHost(for: uuid, cwd: cwd)
        self.host = host

        let frame = Self.topFrame(for: NSScreen.main ?? NSScreen.screens.first)
        let panel = QuickTerminalPanel(contentRect: frame)
        host.translatesAutoresizingMaskIntoConstraints = false
        let container = NSView(frame: NSRect(origin: .zero, size: frame.size))
        container.addSubview(host)
        NSLayoutConstraint.activate([
            host.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            host.topAnchor.constraint(equalTo: container.topAnchor),
            host.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        panel.contentView = container
        self.panel = panel
        return panel
    }

    /// A dropdown band spanning the top ~40% of the screen's visible area (below the menu bar).
    private static func topFrame(for screen: NSScreen?) -> NSRect {
        let vf = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
        let height = (vf.height * 0.4).rounded()
        return NSRect(x: vf.minX, y: vf.maxY - height, width: vf.width, height: height)
    }
}
