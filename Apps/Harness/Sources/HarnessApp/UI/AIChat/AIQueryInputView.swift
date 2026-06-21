import AppKit
import HarnessCore

/// Bottom-pinned floating input bar for the inline terminal AI chat (⌘I).
/// Shows a text field with agent name pill, submit on Return, dismiss on Esc.
@MainActor
final class AIQueryInputView: NSView {

    // MARK: - Callbacks

    var onSubmit: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Subviews

    private let background: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.88).cgColor
        v.layer?.cornerRadius = 10
        v.layer?.cornerCurve = .continuous
        v.layer?.borderWidth = 1
        v.layer?.borderColor = NSColor.white.withAlphaComponent(0.18).cgColor
        return v
    }()

    private let agentPill: NSTextField = {
        let f = NSTextField(labelWithString: "✦ Claude")
        f.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        f.textColor = .systemTeal
        f.wantsLayer = true
        f.layer?.backgroundColor = NSColor.systemTeal.withAlphaComponent(0.12).cgColor
        f.layer?.cornerRadius = 4
        return f
    }()

    private let field: NSTextField = {
        let f = NSTextField()
        f.placeholderString = "Ask AI about this terminal…"
        f.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        f.textColor = .white
        f.backgroundColor = .clear
        f.isBordered = false
        f.focusRingType = .none
        f.cell?.wraps = false
        f.cell?.isScrollable = true
        return f
    }()

    private let hintLabel: NSTextField = {
        let f = NSTextField(labelWithString: "Return to send · Esc to dismiss")
        f.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        f.textColor = NSColor.white.withAlphaComponent(0.35)
        return f
    }()

    // MARK: - Init

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        [background, agentPill, field, hintLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),

            agentPill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            agentPill.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),

            field.leadingAnchor.constraint(equalTo: agentPill.trailingAnchor, constant: 8),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            field.centerYAnchor.constraint(equalTo: agentPill.centerYAnchor),

            hintLabel.leadingAnchor.constraint(equalTo: agentPill.leadingAnchor),
            hintLabel.topAnchor.constraint(equalTo: agentPill.bottomAnchor, constant: 4),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])

        field.delegate = self
    }

    // MARK: - Configuration

    func configure(agent: AgentKind) {
        let name: String
        switch agent {
        case .claudeCode:  name = "Claude"
        case .codex:       name = "Codex"
        case .antigravity: name = "Gemini"
        case .kiro:        name = "Kiro"
        default:           name = agent.rawValue
        }
        agentPill.stringValue = "✦ \(name)"
    }

    func focus() {
        field.stringValue = ""
        window?.makeFirstResponder(field)
    }

    // MARK: - Key handling

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Esc
            onDismiss?()
        } else {
            super.keyDown(with: event)
        }
    }
}

// MARK: - NSTextFieldDelegate

extension AIQueryInputView: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
        if selector == #selector(NSResponder.insertNewline(_:)) {
            let text = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return true }
            onSubmit?(text)
            field.stringValue = ""
            return true
        }
        if selector == #selector(NSResponder.cancelOperation(_:)) {
            onDismiss?()
            return true
        }
        return false
    }
}
