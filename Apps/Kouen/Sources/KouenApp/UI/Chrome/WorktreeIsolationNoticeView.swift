import AppKit

/// Non-blocking strip shown over the top-right of the terminal area when the active tab is on a
/// feature branch in a folder other tabs share. Offers — never performs — worktree isolation.
@MainActor
final class WorktreeIsolationNoticeView: NSView {
    var onIsolate: (() -> Void)?
    var onDismiss: (() -> Void)?

    private let label = NSTextField(labelWithString: "")
    private let isolateButton = NSButton(title: "Isolate into worktree", target: nil, action: nil)
    private let dismissButton = NSButton(title: "", target: nil, action: nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.borderWidth = 1
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.lineBreakMode = .byTruncatingMiddle
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        isolateButton.bezelStyle = .rounded
        isolateButton.controlSize = .small
        isolateButton.target = self
        isolateButton.action = #selector(isolateClicked)
        isolateButton.toolTip = "Switches the shared folder back to the base branch and moves this tab into its own worktree"

        dismissButton.bezelStyle = .inline
        dismissButton.isBordered = false
        dismissButton.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Dismiss")
        dismissButton.target = self
        dismissButton.action = #selector(dismissClicked)

        let stack = NSStackView(views: [label, isolateButton, dismissButton])
        stack.orientation = .horizontal
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 6, left: 12, bottom: 6, right: 10)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        setAccessibilityIdentifier("worktree-isolation-notice")
        isolateButton.setAccessibilityIdentifier("worktree-isolation-notice-isolate")
        dismissButton.setAccessibilityIdentifier("worktree-isolation-notice-dismiss")
    }

    func configure(message: String) {
        label.stringValue = message
        applyChrome()
    }

    func applyChrome() {
        let chrome = KouenDesign.chrome
        label.textColor = chrome.textPrimary
        dismissButton.contentTintColor = chrome.textSecondary
        layer?.backgroundColor = chrome.surfaceElevated.cgColor
        layer?.borderColor = chrome.border.cgColor
    }

    @objc private func isolateClicked() {
        isolateButton.isEnabled = false
        onIsolate?()
    }

    @objc private func dismissClicked() { onDismiss?() }

    /// Re-arms the button after a failed isolate so the user can retry.
    func resetAction() { isolateButton.isEnabled = true }
}
