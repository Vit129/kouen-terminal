import AppKit

/// Floating multi-line input panel that sends text to the active PTY on ⌘↩.
///
/// Open with ⌘⇧E. Esc dismisses without sending.
/// Key routing: ⌘↩ is a key equivalent so AppKit delivers it via
/// `performKeyEquivalent` before NSTextView sees it; Esc arrives as
/// `cancelOperation` through NSTextViewDelegate.
@MainActor
final class ComposerPanel: NSPanel, NSTextViewDelegate {
    static let shared = ComposerPanel()
    var onSubmit: ((String) -> Void)?

    private let textView: NSTextView
    private let scrollView = NSScrollView()
    private let hintLabel = NSTextField(labelWithString: "⌘↩ send · Esc dismiss")

    private init() {
        let tv = NSTextView()
        tv.isRichText = false
        tv.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        tv.backgroundColor = NSColor(white: 0.12, alpha: 1)
        tv.textColor = NSColor(white: 0.9, alpha: 1)
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.isAutomaticDashSubstitutionEnabled = false
        self.textView = tv

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 180),
            styleMask: [.titled, .closable, .resizable, .utilityWindow],
            backing: .buffered, defer: false
        )
        self.isFloatingPanel = true
        self.title = "Composer"
        self.backgroundColor = NSColor(white: 0.12, alpha: 0.97)
        self.isMovableByWindowBackground = true
        setup()
    }

    override var canBecomeKey: Bool { true }

    private func setup() {
        textView.delegate = self

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        hintLabel.font = .systemFont(ofSize: 11)
        hintLabel.textColor = .secondaryLabelColor
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let cv = contentView!
        cv.addSubview(scrollView)
        cv.addSubview(hintLabel)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: cv.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: hintLabel.topAnchor, constant: -4),
            hintLabel.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 12),
            hintLabel.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -8),
        ])
    }

    func present(relativeTo window: NSWindow?, initialText: String = "") {
        if let w = window {
            let wf = w.frame
            setFrameOrigin(NSPoint(x: wf.midX - 310, y: wf.midY - 90))
        } else {
            center()
        }
        textView.string = initialText
        makeKeyAndOrderFront(nil)
        makeFirstResponder(textView)
    }

    // MARK: - Key handling

    /// ⌘↩ is a key equivalent — AppKit delivers it here before NSTextView sees it.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command), event.keyCode == 36 /* Return */ {
            submit()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    /// Esc → `cancelOperation` selector via NSTextViewDelegate (same pattern as CommandPromptController).
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            orderOut(nil)
            return true
        }
        return false
    }

    // MARK: - Submit

    private func submit() {
        let text = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { orderOut(nil); return }
        onSubmit?(text)
        orderOut(nil)
    }
}
