import AppKit
import HarnessCore
import HarnessTerminalKit

/// Quick Terminal — a fullwidth NSPanel that drops from the menu bar on ⌥Space.
/// Lives in a dedicated "Quick Terminal" workspace so the main window never renders it.
/// Session is created lazily on first show and reused on subsequent toggles.
@MainActor
final class QuickTerminalController {
    static let shared = QuickTerminalController()

    private var panel: NSPanel?
    private var hostView: TerminalHostView?
    private var bootstrapping = false
    nonisolated(unsafe) private var globalMonitor: Any?
    nonisolated(unsafe) private var localMonitor: Any?

    private init() {}

    func install() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            guard Self.isHotkey(event) else { return }
            Task { @MainActor [weak self] in self?.toggle() }
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard Self.isHotkey(event) else { return event }
            Task { @MainActor [weak self] in self?.toggle() }
            return nil
        }
    }

    private static func isHotkey(_ event: NSEvent) -> Bool {
        event.keyCode == 49 && // Space
        event.modifierFlags.intersection([.option, .command, .shift, .control]) == .option
    }

    func toggle() {
        if let panel, panel.isVisible { panel.orderOut(nil); return }
        if let host = hostView { present(host); return }
        guard !bootstrapping else { return }
        bootstrapping = true
        Task { await bootstrap() }
    }

    private func bootstrap() async {
        defer { bootstrapping = false }
        let coord = SessionCoordinator.shared
        guard case let .workspaceID(wsID)? = await coord.requestDaemon(.newWorkspace(name: "Quick Terminal")) else { return }
        guard case let .sessionID(sgID)? = await coord.requestDaemon(.newSession(
            workspaceID: wsID,
            cwd: coord.settings.defaultCWD,
            name: "Quick Terminal",
            shell: coord.settings.defaultShell
        )) else { return }
        await coord.syncFromDaemon()
        guard let sg = coord.snapshot.workspaces.first(where: { $0.id == wsID })?
                .sessions.first(where: { $0.id == sgID }),
              let surfaceID = sg.activeTab?.rootPane.allSurfaceIDs().first else { return }
        let host = coord.terminalHost(for: surfaceID, cwd: coord.settings.defaultCWD)
        hostView = host
        present(host)
    }

    private func present(_ host: TerminalHostView) {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let w = screen.frame.width
        let h = screen.frame.height * 0.42

        if panel == nil {
            let p = NSPanel(
                contentRect: .zero,
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
                backing: .buffered, defer: false
            )
            p.isFloatingPanel = true
            p.level = .floating
            p.titlebarAppearsTransparent = true
            p.titleVisibility = .hidden
            p.isMovable = false
            p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            p.setFrame(NSRect(x: screen.frame.minX, y: screen.frame.maxY - h, width: w, height: h), display: false)
            host.translatesAutoresizingMaskIntoConstraints = false
            p.contentView?.addSubview(host)
            if let cv = p.contentView {
                NSLayoutConstraint.activate([
                    host.topAnchor.constraint(equalTo: cv.topAnchor),
                    host.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
                    host.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
                    host.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
                ])
            }
            panel = p
        }
        panel?.makeKeyAndOrderFront(nil)
        host.focusTerminal()
    }

    deinit {
        if let m = globalMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
    }
}
