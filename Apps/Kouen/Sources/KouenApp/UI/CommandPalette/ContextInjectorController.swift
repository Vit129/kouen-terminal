import AppKit
import KouenCore
import KouenIPC

/// Quick Context Injector (⌘K) — P46 Phase 2's last item. A single-line HUD anchored above the
/// terminal window, same `NSPanel` shape as `CommandPromptController`'s `:` prompt, but instead
/// of dispatching an ex-command it resolves `@`-mention tokens (`@diff`, `@file:<path>`, `@last`,
/// `@error`, `@pane:<id>`, `@graph:<symbol>`, `@issue` — `ContextResolutionEngine`, already built
/// in Phase 2 for `kouen context inject`/`kouenContextResolve`) and types the resolved text
/// straight into the active terminal, as if the human had pasted it themselves.
@MainActor
final class ContextInjectorController: NSObject, NSTextFieldDelegate {
    static let shared = ContextInjectorController()

    private var window: NSPanel?
    private let field = NSTextField()

    private override init() { super.init() }

    func present() {
        let panel = window ?? build()
        window = panel
        // Same anchor-under-mainWindow reasoning as `CommandPromptController.present()`: an
        // `NSPanel` never takes main-window status, so `keyWindow` would drift to this panel
        // itself on a second open.
        let anchor = NSApp.mainWindow
            ?? NSApp.windows.first(where: { $0 !== panel && $0.isVisible && !($0 is NSPanel) })
        guard let anchor else { return }
        let frame = anchor.frame
        let size = NSSize(width: 560, height: 36)
        panel.setFrame(
            NSRect(x: frame.midX - size.width / 2, y: frame.minY + 64, width: size.width, height: size.height),
            display: false
        )
        field.stringValue = ""
        panel.alphaValue = 0
        panel.orderFront(nil)
        panel.makeKey()
        panel.makeFirstResponder(field)
        KouenMotion.animate(KouenDesign.Motion.fast, timing: KouenDesign.Motion.entrance) { _ in
            panel.animator().alphaValue = 1
        }
    }

    @objc func dismiss() {
        guard let window else { return }
        KouenMotion.animate(KouenDesign.Motion.fast, timing: KouenDesign.Motion.exit) { _ in
            window.animator().alphaValue = 0
        } completion: {
            window.orderOut(nil)
        }
    }

    // MARK: NSTextFieldDelegate

    func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
        switch selector {
        case #selector(NSResponder.cancelOperation(_:)):
            dismiss()
            return true
        case #selector(NSResponder.insertNewline(_:)):
            commit()
            return true
        default:
            return false
        }
    }

    private func commit() {
        let raw = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { dismiss(); return }
        // Dismiss first so the resolved text lands in the terminal with no overlay on top of it.
        dismiss()
        Task { @MainActor in
            await inject(raw)
        }
    }

    private func inject(_ raw: String) async {
        let coord = SessionCoordinator.shared
        guard let surfaceID = coord.activeSurfaceID else {
            DisplayMessage.show("context inject: no active terminal")
            return
        }
        let cwd = coord.snapshot.activeWorkspace?.activeTab?.cwd ?? FileManager.default.currentDirectoryPath
        let resolved = await ContextResolutionEngine().resolveTemplate(
            raw, cwd: cwd, daemonClient: DaemonClient(), activeSurfaceID: surfaceID.uuidString
        )
        // `.human`: this IS the human's own input, just assembled via the injector instead of
        // typed keystroke-by-keystroke — same origin as a paste (P46 Pillar 6's origin lock).
        _ = await coord.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(resolved.utf8), origin: .human))
    }

    private func build() -> NSPanel {
        let panel = ContextInjectorPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 36),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.becomesKeyOnlyIfNeeded = false

        let overlay = KouenOverlayBackground()
        overlay.frame = NSRect(x: 0, y: 0, width: 560, height: 36)

        let prompt = NSTextField(labelWithString: "@")
        prompt.font = KouenDesign.Typography.kbd
        prompt.textColor = KouenChrome.current.accent

        field.placeholderString = "@diff, @file:<path>, @last, @error, @pane:<id>, @graph:<symbol>, @issue…"
        field.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        field.textColor = KouenChrome.current.textPrimary
        field.bezelStyle = .roundedBezel
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.delegate = self

        let closeButton = NSButton()
        closeButton.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close")?
            .withSymbolConfiguration(.init(pointSize: 10, weight: .semibold))
        closeButton.isBordered = false
        closeButton.contentTintColor = KouenChrome.current.textTertiary
        closeButton.target = self
        closeButton.action = #selector(dismiss)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView(views: [prompt, field])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false
        overlay.contentView.addSubview(stack)
        overlay.contentView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: overlay.contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: overlay.contentView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: overlay.contentView.trailingAnchor, constant: -10),
            closeButton.centerYAnchor.constraint(equalTo: overlay.contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 16),
        ])

        panel.contentView = overlay
        return panel
    }
}

private final class ContextInjectorPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}
