import AppKit
import HarnessCore

/// Chat panel UI for the agent sidebar tab. Shows message list + input field.
@MainActor
final class AgentChatPanelView: NSView {
    private let scrollView = NSScrollView()
    private let messageStack = NSStackView()
    private let inputContainer = NSView()
    private let inputField = NSTextField()
    private let sendButton = NSButton()
    private let statusLabel = NSTextField(labelWithString: "")
    private let approvalBar = NSStackView()
    private let approveButton = NSButton(title: "Allow", target: nil, action: nil)
    private let rejectButton = NSButton(title: "Reject", target: nil, action: nil)
    private let approvalLabel = NSTextField(labelWithString: "")

    private var session: ACPSession?
    private var agentPicker: NSPopUpButton?

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        wantsLayer = true

        // Message scroll area
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        messageStack.orientation = .vertical
        messageStack.alignment = .leading
        messageStack.spacing = 8
        messageStack.translatesAutoresizingMaskIntoConstraints = false

        let clipView = NSClipView()
        clipView.translatesAutoresizingMaskIntoConstraints = false
        clipView.documentView = messageStack
        clipView.drawsBackground = false
        scrollView.contentView = clipView
        addSubview(scrollView)

        // Input area
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputContainer)

        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.placeholderString = "Ask the agent..."
        inputField.bezelStyle = .roundedBezel
        inputField.font = .systemFont(ofSize: 13)
        inputField.delegate = self
        inputContainer.addSubview(inputField)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.image = NSImage(systemSymbolName: "arrow.up.circle.fill", accessibilityDescription: "Send")
        sendButton.bezelStyle = .inline
        sendButton.isBordered = false
        sendButton.target = self
        sendButton.action = #selector(sendMessage)
        inputContainer.addSubview(sendButton)

        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabelColor
        addSubview(statusLabel)

        // Approval bar (hidden by default)
        approvalBar.translatesAutoresizingMaskIntoConstraints = false
        approvalBar.orientation = .vertical
        approvalBar.spacing = 6
        approvalBar.isHidden = true
        approvalLabel.font = .systemFont(ofSize: 12, weight: .medium)
        approvalLabel.lineBreakMode = .byTruncatingTail
        approveButton.target = self
        approveButton.action = #selector(approvePermission)
        rejectButton.target = self
        rejectButton.action = #selector(rejectPermission)
        let buttonRow = NSStackView(views: [approveButton, rejectButton])
        buttonRow.spacing = 8
        approvalBar.addArrangedSubview(approvalLabel)
        approvalBar.addArrangedSubview(buttonRow)
        addSubview(approvalBar)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: approvalBar.topAnchor, constant: -4),

            approvalBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            approvalBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            approvalBar.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -4),

            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -4),

            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            inputContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            inputContainer.heightAnchor.constraint(equalToConstant: 30),

            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -4),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 24),
            sendButton.heightAnchor.constraint(equalToConstant: 24),

            messageStack.leadingAnchor.constraint(equalTo: clipView.leadingAnchor, constant: 8),
            messageStack.trailingAnchor.constraint(equalTo: clipView.trailingAnchor, constant: -8),
            messageStack.topAnchor.constraint(equalTo: clipView.topAnchor, constant: 8),
        ])
    }

    // MARK: - Session Binding

    func bind(session: ACPSession) {
        self.session = session
        session.onUpdate = { [weak self] in self?.refreshUI() }
        refreshUI()
    }

    private func refreshUI() {
        rebuildMessages()
        updateStatus()
        updateApprovalBar()
        scrollToBottom()
    }

    private func rebuildMessages() {
        // Remove all existing message views
        messageStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let session else { return }
        for msg in session.messages {
            let view = createMessageView(msg)
            messageStack.addArrangedSubview(view)
        }
    }

    private func createMessageView(_ message: ACPChatMessage) -> NSView {
        let label = NSTextField(wrappingLabelWithString: message.text)
        label.isEditable = false
        label.isSelectable = true
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false

        switch message.role {
        case .user:
            label.textColor = .labelColor
            label.font = .systemFont(ofSize: 13, weight: .medium)
        case .assistant:
            label.textColor = .labelColor
        case .thought:
            label.textColor = .secondaryLabelColor
            label.font = NSFontManager.shared.convert(.systemFont(ofSize: 12), toHaveTrait: .italicFontMask)
        case .toolCall:
            let icon = toolIcon(for: message.toolKind ?? "other")
            label.stringValue = "\(icon) \(message.text)"
            label.textColor = .tertiaryLabelColor
            label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        }
        return label
    }

    private func toolIcon(for kind: String) -> String {
        switch kind {
        case "read": return "📖"
        case "edit": return "✏️"
        case "delete": return "🗑"
        case "execute": return "⚡️"
        case "search": return "🔍"
        case "think": return "💭"
        default: return "🔧"
        }
    }

    private func updateStatus() {
        guard let session else {
            statusLabel.stringValue = ""
            return
        }
        switch session.status {
        case .disconnected: statusLabel.stringValue = "Disconnected"
        case .connecting: statusLabel.stringValue = "Connecting..."
        case .ready: statusLabel.stringValue = ""
        case .streaming: statusLabel.stringValue = "Agent is thinking..."
        case .waitingForApproval: statusLabel.stringValue = "Waiting for approval"
        case .error(let msg): statusLabel.stringValue = "Error: \(msg)"
        }
        if case .ready = session.status {
            inputField.isEnabled = true
        } else if case .disconnected = session.status {
            inputField.isEnabled = false
        } else {
            inputField.isEnabled = false
        }
    }

    private func updateApprovalBar() {
        guard let session else { approvalBar.isHidden = true; return }
        if case let .waitingForApproval(req) = session.status {
            approvalBar.isHidden = false
            approvalLabel.stringValue = "🔒 \(req.toolCallTitle) (\(req.toolCallKind))"
        } else {
            approvalBar.isHidden = true
        }
    }

    private func scrollToBottom() {
        if let docView = scrollView.documentView {
            let point = NSPoint(x: 0, y: docView.bounds.height)
            scrollView.contentView.scroll(to: point)
        }
    }

    // MARK: - Actions

    @objc private func sendMessage() {
        let text = inputField.stringValue
        guard !text.isEmpty, let session else { return }
        inputField.stringValue = ""
        Task { await session.sendMessage(text) }
    }

    @objc private func approvePermission() {
        guard let session, case let .waitingForApproval(req) = session.status else { return }
        let allowOption = req.options.first(where: { $0.kind == "allow_once" })
            ?? req.options.first(where: { $0.kind == "allow_always" })
        guard let opt = allowOption else { return }
        Task { await session.respondToPermission(optionId: opt.id) }
    }

    @objc private func rejectPermission() {
        guard let session else { return }
        Task { await session.rejectPermission() }
    }
}

// MARK: - NSTextFieldDelegate

extension AgentChatPanelView: NSTextFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            sendMessage()
            return true
        }
        return false
    }
}
