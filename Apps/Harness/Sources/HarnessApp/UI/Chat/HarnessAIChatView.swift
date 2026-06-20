import AppKit
import HarnessCore

/// Sidebar chat panel that sends messages to Claude via `ClaudeDirectClient`.
/// Context injected automatically: active pane's last 80 lines, git branch, cwd.
@MainActor
final class HarnessAIChatView: NSView {

    // MARK: - Subviews

    private let scrollView = NSScrollView()
    private let contentStack = NSStackView()
    private let inputContainer = NSView()
    private let inputField = NSTextField()
    private let sendButton = NSButton()
    private let statusLabel = NSTextField(labelWithString: "")
    private let emptyLabel = NSTextField(labelWithString: "Ask Claude anything about your terminal session.")

    // MARK: - State

    private var messages: [ClaudeDirectClient.Message] = []
    private var isStreaming = false
    private var currentBubble: NSTextView?

    // MARK: - Init

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        wantsLayer = true

        setupScrollView()
        setupInputArea()
        setupEmptyLabel()
        applyTheme()
    }

    // MARK: - Layout

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        addSubview(scrollView)

        contentStack.orientation = .vertical
        contentStack.alignment = .left
        contentStack.spacing = 8
        contentStack.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentStack
    }

    private func setupEmptyLabel() {
        emptyLabel.isEditable = false
        emptyLabel.isBezeled = false
        emptyLabel.drawsBackground = false
        emptyLabel.font = .systemFont(ofSize: 12)
        emptyLabel.textColor = .tertiaryLabelColor
        emptyLabel.maximumNumberOfLines = 0
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyLabel)
    }

    private func setupInputArea() {
        inputContainer.wantsLayer = true
        inputContainer.layer?.cornerRadius = 8
        inputContainer.layer?.cornerCurve = .continuous
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputContainer)

        inputField.placeholderString = "Message Claude…"
        inputField.isBezeled = false
        inputField.drawsBackground = false
        inputField.font = .systemFont(ofSize: 13)
        inputField.focusRingType = .none
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.target = self
        inputField.action = #selector(sendMessage)
        inputContainer.addSubview(inputField)

        sendButton.image = NSImage(systemSymbolName: "arrow.up.circle.fill", accessibilityDescription: "Send")
        sendButton.bezelStyle = .regularSquare
        sendButton.isBordered = false
        sendButton.target = self
        sendButton.action = #selector(sendMessage)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(sendButton)

        statusLabel.isEditable = false
        statusLabel.isBezeled = false
        statusLabel.drawsBackground = false
        statusLabel.font = .systemFont(ofSize: 10)
        statusLabel.textColor = .tertiaryLabelColor
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            inputContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            inputContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 10),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -4),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -6),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 24),
            sendButton.heightAnchor.constraint(equalToConstant: 24),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -2),

            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -4),
            statusLabel.heightAnchor.constraint(equalToConstant: 14),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            emptyLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),
        ])
    }

    func applyTheme() {
        inputContainer.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        inputContainer.layer?.borderWidth = 1
        inputContainer.layer?.borderColor = NSColor.separatorColor.cgColor
    }

    // MARK: - Sending

    @objc private func sendMessage() {
        let text = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }

        inputField.stringValue = ""
        messages.append(.init(role: "user", content: text))
        addBubble(text: text, isUser: true)
        emptyLabel.isHidden = true

        Task { await fetchResponse() }
    }

    private func fetchResponse() async {
        let settings = SessionCoordinator.shared.settings
        guard let client = ClaudeDirectClient(settings: settings) else {
            addBubble(text: "⚠️ No Claude API key set. Add it in Settings → Agents.", isUser: false)
            return
        }

        isStreaming = true
        statusLabel.stringValue = "Claude is thinking…"
        let bubble = addBubble(text: "", isUser: false)
        currentBubble = bubble

        let systemPrompt = buildSystemPrompt()
        var fullReply = ""

        await client.stream(
            messages: messages,
            systemPrompt: systemPrompt,
            maxTokens: 4096
        ) { [weak self] event in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch event {
                case .text(let chunk):
                    fullReply += chunk
                    bubble.string = fullReply
                    self.scrollToBottom()
                case .done:
                    self.finishStreaming(reply: fullReply)
                case .error(let msg):
                    bubble.string = "⚠️ \(msg)"
                    self.finishStreaming(reply: msg)
                }
            }
        }
    }

    private func finishStreaming(reply: String) {
        isStreaming = false
        statusLabel.stringValue = ""
        messages.append(.init(role: "assistant", content: reply))
        currentBubble = nil
    }

    // MARK: - Bubble factory

    @discardableResult
    private func addBubble(text: String, isUser: Bool) -> NSTextView {
        let bubble = NSTextView()
        bubble.string = text
        bubble.isEditable = false
        bubble.isSelectable = true
        bubble.drawsBackground = true
        bubble.backgroundColor = isUser
            ? NSColor.controlAccentColor.withAlphaComponent(0.12)
            : NSColor.controlBackgroundColor
        bubble.textColor = .labelColor
        bubble.font = .systemFont(ofSize: 12.5)
        bubble.textContainerInset = NSSize(width: 8, height: 6)
        bubble.wantsLayer = true
        bubble.layer?.cornerRadius = 8
        bubble.layer?.cornerCurve = .continuous
        bubble.isAutomaticLinkDetectionEnabled = true
        bubble.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(bubble)
        bubble.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -24).isActive = true

        scrollToBottom()
        return bubble
    }

    private func scrollToBottom() {
        guard let doc = scrollView.documentView else { return }
        let pt = NSPoint(x: 0, y: max(0, doc.frame.height - scrollView.contentView.bounds.height))
        scrollView.contentView.scroll(to: pt)
    }

    // MARK: - Context

    private func buildSystemPrompt() -> String {
        let snapshot = SessionCoordinator.shared.snapshot
        let activeTab = snapshot.activeWorkspace?.activeTab
        let branch = activeTab?.gitBranch.flatMap { $0.isEmpty ? nil : $0 } ?? "unknown"
        let cwd = activeTab?.cwd ?? "unknown"

        var lines = [
            "You are Claude, an AI assistant embedded in Harness Terminal.",
            "Current working directory: \(cwd)",
            "Git branch: \(branch)",
        ]
        if let tab = activeTab, let surfaceID = tab.activePaneID?.uuidString {
            lines.append("Active pane surface ID: \(surfaceID)")
        }
        lines.append("Answer concisely. Use markdown for code blocks.")
        return lines.joined(separator: "\n")
    }

    // MARK: - Public

    /// Called when the user switches sessions so context resets.
    func resetContext() {
        messages = []
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.isHidden = false
        statusLabel.stringValue = ""
    }
}
