import AppKit

/// Floating ghost-text banner that shows an AI-suggested shell command above the terminal
/// input line. Appears on ⌥Space, dismisses on Tab/Return (accept) or Esc (cancel).
@MainActor
final class InlineAICompletionView: NSView {
    // MARK: - Public interface

    /// The suggested command to display. Set to `nil` to hide the banner.
    var suggestion: String? {
        didSet { updateVisibility() }
    }

    /// Called when the user accepts the suggestion (Tab or Return). Receives the command string.
    var onAccept: ((String) -> Void)?

    /// Called when the user dismisses the suggestion (Esc) or it auto-dismisses.
    var onDismiss: (() -> Void)?

    // MARK: - Subviews

    private let background: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.82).cgColor
        v.layer?.cornerRadius = 8
        v.layer?.cornerCurve = .continuous
        v.layer?.borderWidth = 1
        v.layer?.borderColor = NSColor.white.withAlphaComponent(0.15).cgColor
        return v
    }()

    private let prefixLabel: NSTextField = {
        let f = NSTextField(labelWithString: "⌥ ")
        f.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        f.textColor = NSColor.white.withAlphaComponent(0.45)
        return f
    }()

    private let suggestionLabel: NSTextField = {
        let f = NSTextField(labelWithString: "")
        f.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        f.textColor = NSColor.white.withAlphaComponent(0.75)
        f.lineBreakMode = .byTruncatingTail
        f.maximumNumberOfLines = 1
        return f
    }()

    private let hintLabel: NSTextField = {
        let f = NSTextField(labelWithString: "Tab to accept · Esc to dismiss")
        f.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        f.textColor = NSColor.white.withAlphaComponent(0.35)
        return f
    }()

    // MARK: - Auto-dismiss

    private var dismissTimer: Timer?
    private static let autoDismissInterval: TimeInterval = 8

    // MARK: - Init

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        isHidden = true
        wantsLayer = true

        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)

        for label in [prefixLabel, suggestionLabel, hintLabel] as [NSTextField] {
            label.translatesAutoresizingMaskIntoConstraints = false
            background.addSubview(label)
        }

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),

            prefixLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 10),
            prefixLabel.centerYAnchor.constraint(equalTo: suggestionLabel.centerYAnchor),

            suggestionLabel.leadingAnchor.constraint(equalTo: prefixLabel.trailingAnchor, constant: 2),
            suggestionLabel.trailingAnchor.constraint(lessThanOrEqualTo: background.trailingAnchor, constant: -10),
            suggestionLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: 8),

            hintLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 10),
            hintLabel.topAnchor.constraint(equalTo: suggestionLabel.bottomAnchor, constant: 4),
            hintLabel.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -8),
            hintLabel.trailingAnchor.constraint(lessThanOrEqualTo: background.trailingAnchor, constant: -10),
        ])
    }

    // MARK: - Visibility

    private func updateVisibility() {
        if let text = suggestion, !text.isEmpty {
            suggestionLabel.stringValue = text
            isHidden = false
            scheduleAutoDismiss()
        } else {
            isHidden = true
            cancelAutoDismiss()
        }
    }

    private func scheduleAutoDismiss() {
        cancelAutoDismiss()
        dismissTimer = Timer.scheduledTimer(
            withTimeInterval: Self.autoDismissInterval,
            repeats: false
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }
    }

    private func cancelAutoDismiss() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }

    // MARK: - Key handling

    /// Returns true if the event was consumed by this overlay.
    func handleKeyDown(with event: NSEvent) -> Bool {
        guard !isHidden, suggestion != nil else { return false }
        switch event.keyCode {
        case 36, 48: // Return (36), Tab (48)
            accept()
            return true
        case 53: // Escape
            dismiss()
            return true
        default:
            // Any other key dismisses the overlay so normal typing is not blocked.
            dismiss()
            return false
        }
    }

    // MARK: - Accept / dismiss

    private func accept() {
        guard let cmd = suggestion else { return }
        cancelAutoDismiss()
        suggestion = nil
        onAccept?(cmd)
    }

    private func dismiss() {
        cancelAutoDismiss()
        suggestion = nil
        onDismiss?()
    }
}
