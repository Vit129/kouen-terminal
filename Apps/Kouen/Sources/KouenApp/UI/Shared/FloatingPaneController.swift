import AppKit
import KouenCore
import KouenTerminalKit

/// Floating Terminal — a user-resizable NSPanel hosting a dedicated PTY session.
/// Lives in its own workspace so the main window never renders it.
/// Toggle with ⌘⌥F; frame is persisted across launches.
@MainActor
final class FloatingPaneController {
    static let shared = FloatingPaneController()

    private var panel: NSPanel?
    private var hostView: TerminalHostView?
    private var bootstrapping = false
    nonisolated(unsafe) private var globalMonitor: Any?
    nonisolated(unsafe) private var localMonitor: Any?
    nonisolated(unsafe) private var frameObservers: [NSObjectProtocol] = []

    private static let frameKey = "FloatingPaneFrame"

    private init() {}

    func install() {
        guard globalMonitor == nil else { return }  // guard against double-install
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
        event.keyCode == 3 && // f
        event.modifierFlags.intersection([.option, .command, .shift, .control]) == [.command, .option]
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
        guard case let .workspaceID(wsID)? = await coord.requestDaemon(.newWorkspace(name: "Floating Terminal")) else { return }
        guard case let .sessionID(sgID)? = await coord.requestDaemon(.newSession(
            workspaceID: wsID,
            cwd: coord.settings.defaultCWD,
            name: "Floating Terminal",
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
        if panel == nil {
            guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
            let defaultFrame = NSRect(
                x: screen.frame.midX - 400, y: screen.frame.midY - 250,
                width: 800, height: 500)
            let rawSaved = UserDefaults.standard.string(forKey: Self.frameKey).map { NSRectFromString($0) }
            let frame = (rawSaved.map { $0.width > 100 && $0.height > 100 } == true) ? rawSaved! : defaultFrame

            let p = NSPanel(
                contentRect: frame,
                styleMask: [.titled, .closable, .resizable, .miniaturizable, .nonactivatingPanel],
                backing: .buffered, defer: false
            )
            p.isFloatingPanel = true
            p.level = .floating
            p.title = "Floating Terminal"
            p.isMovable = true
            p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

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
            // Persist frame on every move/resize — store tokens so they can be removed on deinit
            for name in [NSWindow.didMoveNotification, NSWindow.didResizeNotification] {
                let token = NotificationCenter.default.addObserver(forName: name, object: p, queue: .main) { [weak p] _ in
                    guard let p else { return }
                    UserDefaults.standard.set(NSStringFromRect(p.frame), forKey: Self.frameKey)
                }
                frameObservers.append(token)
            }
            panel = p
        }
        panel?.makeKeyAndOrderFront(nil)
        host.focusTerminal()
    }

    deinit {
        if let m = globalMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        frameObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
