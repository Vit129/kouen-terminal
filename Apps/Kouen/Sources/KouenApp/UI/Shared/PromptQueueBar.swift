import AppKit

/// Floating status strip shown when there are queued commands for the active surface.
/// Anchors to the bottom-right of the main window. Disappears when the queue drains.
@MainActor
final class PromptQueueBar: NSPanel {
    static let shared = PromptQueueBar()
    private let label = NSTextField(labelWithString: "")
    private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)

    private init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 32),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        backgroundColor = NSColor.black.withAlphaComponent(0.8)
        level = .floating
        setup()
    }

    private func setup() {
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        cancelButton.target = self
        cancelButton.action = #selector(didCancel)
        cancelButton.bezelStyle = .inline
        cancelButton.controlSize = .small

        let stack = NSStackView(views: [label, cancelButton])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 4, left: 10, bottom: 4, right: 8)
        stack.translatesAutoresizingMaskIntoConstraints = false

        guard let cv = contentView else { return }
        cv.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cv.topAnchor),
            stack.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
        ])
    }

    @objc private func didCancel() {
        SessionCoordinator.shared.cancelQueue()
    }

    func update(count: Int, anchoredTo window: NSWindow?) {
        if count == 0 { orderOut(nil); return }
        label.stringValue = "Queue: \(count)"
        if let w = window {
            let wf = w.frame
            setFrameOrigin(NSPoint(x: wf.maxX - 230, y: wf.minY + 8))
        }
        orderFront(nil)
    }
}
