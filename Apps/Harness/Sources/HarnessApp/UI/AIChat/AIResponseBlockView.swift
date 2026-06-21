import AppKit
import HarnessCore

/// Floating response block that streams AI output inline in the terminal pane.
/// Stacks above `AIQueryInputView`. Supports [▶ Run] for code blocks, [⎘ Copy], [✕ Dismiss].
@MainActor
final class AIResponseBlockView: NSView {

    // MARK: - Callbacks

    /// Called when user clicks [▶ Run] on a fenced code block. Receives the block text.
    var onRun: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Subviews

    private let background: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.90).cgColor
        v.layer?.cornerRadius = 10
        v.layer?.cornerCurve = .continuous
        v.layer?.borderWidth = 1
        v.layer?.borderColor = NSColor.white.withAlphaComponent(0.15).cgColor
        return v
    }()

    private let headerRow: NSStackView = {
        let s = NSStackView()
        s.orientation = .horizontal
        s.spacing = 6
        return s
    }()

    private let agentLabel: NSTextField = {
        let f = NSTextField(labelWithString: "✦ Claude")
        f.font = .monospacedSystemFont(ofSize: 11, weight: .semibold)
        f.textColor = .systemTeal
        return f
    }()

    private let copyButton: NSButton = {
        let b = NSButton(title: "⎘ Copy", target: nil, action: nil)
        b.bezelStyle = .inline
        b.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        b.contentTintColor = NSColor.white.withAlphaComponent(0.55)
        return b
    }()

    private let dismissButton: NSButton = {
        let b = NSButton(title: "✕", target: nil, action: nil)
        b.bezelStyle = .inline
        b.font = .systemFont(ofSize: 11, weight: .regular)
        b.contentTintColor = NSColor.white.withAlphaComponent(0.55)
        return b
    }()

    private let textView: NSTextView = {
        let t = NSTextView()
        t.isEditable = false
        t.isSelectable = true
        t.backgroundColor = .clear
        t.textColor = NSColor.white.withAlphaComponent(0.88)
        t.font = .monospacedSystemFont(ofSize: 12.5, weight: .regular)
        t.textContainerInset = .zero
        t.textContainer?.lineFragmentPadding = 0
        t.textContainer?.widthTracksTextView = true
        return t
    }()

    private let scrollView: NSScrollView = {
        let s = NSScrollView()
        s.hasVerticalScroller = true
        s.autohidesScrollers = true
        s.drawsBackground = false
        return s
    }()

    // MARK: - State

    private var rawText = ""
    private var lastCodeBlock: String?

    // MARK: - Init

    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        scrollView.documentView = textView
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        [background, headerRow, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        headerRow.addArrangedSubview(agentLabel)
        let spacer = NSView(); spacer.translatesAutoresizingMaskIntoConstraints = false
        headerRow.addArrangedSubview(spacer)
        headerRow.addArrangedSubview(copyButton)
        headerRow.addArrangedSubview(dismissButton)

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerRow.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            headerRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            headerRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            scrollView.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: 6),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])

        copyButton.target = self; copyButton.action = #selector(copyAll)
        dismissButton.target = self; dismissButton.action = #selector(dismiss)
    }

    // MARK: - Content

    func configure(agent: AgentKind) {
        let name: String
        switch agent {
        case .claudeCode:  name = "Claude"
        case .codex:       name = "Codex"
        case .antigravity: name = "Gemini"
        case .kiro:        name = "Kiro"
        default:           name = agent.rawValue
        }
        agentLabel.stringValue = "✦ \(name)"
    }

    /// Append streamed text and re-render. Called per `AgentProcessManager.Chunk.text`.
    func appendChunk(_ text: String) {
        rawText += text
        renderText()
    }

    func markDone() {
        // Extract last fenced code block for [▶ Run], wire button if present
        if let block = extractLastCodeBlock(from: rawText) {
            lastCodeBlock = block
            addRunButton()
        }
    }

    func markError(_ message: String) {
        let errorAttr = NSAttributedString(
            string: "\n⚠ \(message)",
            attributes: [.foregroundColor: NSColor.systemRed, .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)]
        )
        textView.textStorage?.append(errorAttr)
    }

    // MARK: - Rendering

    private func renderText() {
        // Simple render: plain text with basic code block highlighting
        let attrStr = NSMutableAttributedString()
        let segments = parseSegments(rawText)
        for segment in segments {
            switch segment {
            case .plain(let s):
                attrStr.append(NSAttributedString(string: s, attributes: [
                    .foregroundColor: NSColor.white.withAlphaComponent(0.88),
                    .font: NSFont.monospacedSystemFont(ofSize: 12.5, weight: .regular),
                ]))
            case .code(let s):
                attrStr.append(NSAttributedString(string: s, attributes: [
                    .foregroundColor: NSColor.systemYellow.withAlphaComponent(0.9),
                    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                    .backgroundColor: NSColor.white.withAlphaComponent(0.06),
                ]))
            }
        }
        textView.textStorage?.setAttributedString(attrStr)
        // Scroll to end
        textView.scrollToEndOfDocument(nil)
    }

    private enum Segment { case plain(String), code(String) }

    private func parseSegments(_ text: String) -> [Segment] {
        var segments: [Segment] = []
        var current = ""
        var inCode = false
        var i = text.startIndex
        while i < text.endIndex {
            if text[i...].hasPrefix("```") {
                if !current.isEmpty { segments.append(inCode ? .code(current) : .plain(current)); current = "" }
                inCode.toggle()
                i = text.index(i, offsetBy: 3, limitedBy: text.endIndex) ?? text.endIndex
                // Skip language tag on opening fence
                if !inCode, let eol = text[i...].firstIndex(of: "\n") { i = text.index(after: eol) }
                continue
            }
            current.append(text[i])
            i = text.index(after: i)
        }
        if !current.isEmpty { segments.append(inCode ? .code(current) : .plain(current)) }
        return segments
    }

    private func extractLastCodeBlock(from text: String) -> String? {
        var blocks: [String] = []
        var inBlock = false
        var buf = ""
        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("```") {
                if inBlock { blocks.append(buf.trimmingCharacters(in: .newlines)); buf = ""; inBlock = false }
                else { inBlock = true }
                continue
            }
            if inBlock { buf += line + "\n" }
        }
        return blocks.last
    }

    private func addRunButton() {
        let runBtn = NSButton(title: "▶ Run", target: self, action: #selector(runCode))
        runBtn.bezelStyle = .inline
        runBtn.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        runBtn.contentTintColor = .systemGreen
        runBtn.translatesAutoresizingMaskIntoConstraints = false
        headerRow.insertArrangedSubview(runBtn, at: headerRow.arrangedSubviews.count - 2)
    }

    // MARK: - Actions

    @objc private func copyAll() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(rawText, forType: .string)
        copyButton.title = "✓ Copied"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.copyButton.title = "⎘ Copy"
        }
    }

    @objc private func runCode() {
        guard let block = lastCodeBlock else { return }
        onRun?(block)
    }

    @objc private func dismiss() {
        onDismiss?()
    }
}
