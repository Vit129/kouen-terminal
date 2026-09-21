import AppKit
import KouenCore

/// Fast Turn Diff Reviewer (⌘⌥D) — P46 Phase 3's last item. A compact popup showing only what
/// the agent changed in its most recent checkpoint (`CheckpointManager`, Phase 3's shadow-ref
/// snapshots), with `y` to accept/dismiss or `r` to roll the working tree back to it
/// (`kouen undo step`'s same `CheckpointManager.restore`).
@MainActor
final class TurnDiffReviewerController: NSObject {
    static let shared = TurnDiffReviewerController()

    private var window: NSPanel?
    private let textView = NSTextView()
    private let hintLabel = NSTextField(labelWithString: "")
    private var cwd: String?
    private var session: String?

    private override init() { super.init() }

    func present() {
        let coord = SessionCoordinator.shared
        guard let surfaceID = coord.activeSurfaceID else {
            DisplayMessage.show("turn diff: no active terminal")
            return
        }
        let tabCwd = coord.snapshot.activeWorkspace?.activeTab?.cwd ?? FileManager.default.currentDirectoryPath
        let mgr = CheckpointManager()
        guard let last = mgr.list(cwd: tabCwd, session: surfaceID.uuidString).last else {
            DisplayMessage.show("turn diff: no checkpoint yet for this tab")
            return
        }
        cwd = tabCwd
        session = surfaceID.uuidString

        let diff = mgr.fullDiff(last, cwd: tabCwd)
        textView.string = diff.isEmpty ? "(no textual diff — binary files only, or the change is empty)" : diff
        hintLabel.stringValue = "Turn \(last.turn) · y accept · r revert to this checkpoint · esc close"

        let panel = window ?? build()
        window = panel
        guard let anchor = NSApp.mainWindow else { return }
        let frame = anchor.frame
        let size = NSSize(width: min(760, frame.width - 80), height: min(480, frame.height - 160))
        panel.setFrame(
            NSRect(x: frame.midX - size.width / 2, y: frame.midY - size.height / 2, width: size.width, height: size.height),
            display: false
        )
        panel.alphaValue = 0
        panel.orderFront(nil)
        panel.makeKey()
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

    func revertAndDismiss() {
        guard let cwd, let session else { dismiss(); return }
        let reverted = CheckpointManager().restore(cwd: cwd, session: session)
        dismiss()
        DisplayMessage.show(reverted ? "Reverted to the last checkpoint." : "turn diff: nothing to revert to")
    }

    private func build() -> NSPanel {
        let panel = TurnDiffPanel(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 480),
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
        panel.reviewer = self

        let overlay = KouenOverlayBackground()
        overlay.frame = NSRect(x: 0, y: 0, width: 760, height: 480)

        let titleLabel = NSTextField(labelWithString: "Turn Diff")
        titleLabel.font = KouenDesign.Typography.kbd
        titleLabel.textColor = KouenChrome.current.accent

        hintLabel.font = .systemFont(ofSize: 11)
        hintLabel.textColor = KouenChrome.current.textTertiary

        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = KouenChrome.current.textPrimary
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 4, height: 4)

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.documentView = textView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true

        let headerStack = NSStackView(views: [titleLabel, hintLabel])
        headerStack.orientation = .horizontal
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        overlay.contentView.addSubview(headerStack)
        overlay.contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: overlay.contentView.topAnchor, constant: 10),
            headerStack.leadingAnchor.constraint(equalTo: overlay.contentView.leadingAnchor, constant: 14),
            headerStack.trailingAnchor.constraint(lessThanOrEqualTo: overlay.contentView.trailingAnchor, constant: -14),

            scrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: overlay.contentView.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: overlay.contentView.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: overlay.contentView.bottomAnchor, constant: -10),
        ])

        panel.contentView = overlay
        return panel
    }
}

/// Routes `y`/`r`/esc regardless of first-responder (the diff text view would otherwise eat
/// plain-character key presses meant for the reviewer's own shortcuts).
private final class TurnDiffPanel: NSPanel {
    weak var reviewer: TurnDiffReviewerController?
    override var canBecomeKey: Bool { true }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            reviewer?.dismiss()
            return
        }
        switch event.charactersIgnoringModifiers?.lowercased() {
        case "y":
            reviewer?.dismiss()
        case "r":
            reviewer?.revertAndDismiss()
        default:
            super.keyDown(with: event)
        }
    }
}
