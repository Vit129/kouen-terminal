import AppKit
import HarnessCore
import HarnessTerminalKit

// NSTextField subclass: image paste (⌘V) → save to disk, insert path as text.
// File URL paste → insert path. Anything else → normal text paste via field editor.
@MainActor
private final class AIInputTextField: NSTextField {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.modifierFlags.contains(.command),
              event.charactersIgnoringModifiers == "v" else {
            return super.performKeyEquivalent(with: event)
        }
        let pb = NSPasteboard.general
        if let path = PasteController.writePastedImage(from: pb) {
            insertAtCursor(path); return true
        }
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL],
           let url = urls.first {
            insertAtCursor(url.path); return true
        }
        return super.performKeyEquivalent(with: event)
    }

    private func insertAtCursor(_ text: String) {
        if let ed = currentEditor() as? NSTextView {
            ed.insertText(text, replacementRange: ed.selectedRange())
        } else {
            stringValue += text
        }
    }
}

/// Bottom-pinned floating input bar for the inline terminal AI chat (⌘I).
/// Shows a text field with agent name pill, submit on Return, dismiss on Esc.
@MainActor
final class AIQueryInputView: NSView {

    // MARK: - Callbacks

    var onSubmit: ((String) -> Void)?
    var onDismiss: (() -> Void)?
    var onAgentChanged: ((AgentKind) -> Void)?
    var onModelChanged: ((String?) -> Void)?
    var onEffortChanged: ((String?) -> Void)?

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

    private let pillStack: NSStackView = {
        let s = NSStackView()
        s.orientation = .horizontal
        s.spacing = 5
        s.alignment = .centerY
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let agentPill: NSButton = {
        let b = NSButton(title: "✦ Claude", target: nil, action: nil)
        b.bezelStyle = .recessed
        b.isBordered = false
        b.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        b.contentTintColor = .systemTeal
        b.wantsLayer = true
        b.layer?.backgroundColor = NSColor.systemTeal.withAlphaComponent(0.12).cgColor
        b.layer?.cornerRadius = 4
        return b
    }()

    private let modelPill: NSButton = {
        let b = NSButton(title: "", target: nil, action: nil)
        b.bezelStyle = .recessed
        b.isBordered = false
        b.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        b.contentTintColor = NSColor.white.withAlphaComponent(0.55)
        b.wantsLayer = true
        b.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.07).cgColor
        b.layer?.cornerRadius = 4
        return b
    }()

    private let effortPill: NSButton = {
        let b = NSButton(title: "", target: nil, action: nil)
        b.bezelStyle = .recessed
        b.isBordered = false
        b.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        b.contentTintColor = NSColor.white.withAlphaComponent(0.45)
        b.wantsLayer = true
        b.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.05).cgColor
        b.layer?.cornerRadius = 4
        return b
    }()

    private var currentAgent: AgentKind = .claudeCode
    private var currentModel: String?
    private var currentEffort: String?

    private let field: NSTextField = {
        let f = AIInputTextField()
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

        background.translatesAutoresizingMaskIntoConstraints = false
        field.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        addSubview(pillStack)
        addSubview(field)
        addSubview(hintLabel)

        pillStack.addArrangedSubview(agentPill)
        pillStack.addArrangedSubview(modelPill)
        pillStack.addArrangedSubview(effortPill)

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),

            pillStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            pillStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),

            field.leadingAnchor.constraint(equalTo: pillStack.trailingAnchor, constant: 8),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            field.centerYAnchor.constraint(equalTo: pillStack.centerYAnchor),

            hintLabel.leadingAnchor.constraint(equalTo: pillStack.leadingAnchor),
            hintLabel.topAnchor.constraint(equalTo: pillStack.bottomAnchor, constant: 4),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])

        field.delegate = self
        agentPill.target = self
        agentPill.action = #selector(agentPillClicked(_:))
        modelPill.target = self
        modelPill.action = #selector(modelPillClicked(_:))
        effortPill.target = self
        effortPill.action = #selector(effortPillClicked(_:))

        // Accept image and file drags — converts to path text, not inline rendering.
        registerForDraggedTypes([.fileURL, .png, .tiff,
                                 NSPasteboard.PasteboardType("public.image")])
    }

    // MARK: - Agent Picker

    @objc private func agentPillClicked(_ sender: NSButton) {
        let menu = NSMenu()
        let agents: [(AgentKind, String)] = [
            (.claudeCode, "Claude"),
            (.codex, "Codex"),
            (.antigravity, "Gemini"),
            (.kiro, "Kiro"),
        ]
        for (kind, label) in agents {
            let item = NSMenuItem(title: "✦ \(label)", action: #selector(agentSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = kind
            item.state = (kind == currentAgent) ? .on : .off
            menu.addItem(item)
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
    }

    @objc private func agentSelected(_ item: NSMenuItem) {
        guard let kind = item.representedObject as? AgentKind else { return }
        currentAgent = kind
        configure(agent: kind)
        onAgentChanged?(kind)
        // Reset model/effort after agent switch
        onModelChanged?(currentModel)
        onEffortChanged?(currentEffort)
    }

    // MARK: - Model Picker

    @objc private func modelPillClicked(_ sender: NSButton) {
        let models = AgentCatalog.agents[currentAgent]?.models ?? []
        guard !models.isEmpty else { return }
        let menu = NSMenu()
        for model in models {
            let item = NSMenuItem(title: shortModelName(model), action: #selector(modelSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = model
            item.state = (model == currentModel) ? .on : .off
            menu.addItem(item)
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
    }

    @objc private func modelSelected(_ item: NSMenuItem) {
        guard let model = item.representedObject as? String else { return }
        updateModel(model)
        onModelChanged?(model)
    }

    // MARK: - Effort Picker

    @objc private func effortPillClicked(_ sender: NSButton) {
        guard let levels = AgentCatalog.agents[currentAgent]?.effortLevels, !levels.isEmpty else { return }
        let menu = NSMenu()
        // "auto" option to clear effort (use agent default)
        let autoItem = NSMenuItem(title: "auto (default)", action: #selector(effortSelected(_:)), keyEquivalent: "")
        autoItem.target = self
        autoItem.representedObject = Optional<String>.none as AnyObject
        autoItem.state = (currentEffort == nil) ? .on : .off
        menu.addItem(autoItem)
        menu.addItem(.separator())
        for level in levels {
            let item = NSMenuItem(title: level, action: #selector(effortSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = level
            item.state = (level == currentEffort) ? .on : .off
            menu.addItem(item)
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
    }

    @objc private func effortSelected(_ item: NSMenuItem) {
        let effort = item.representedObject as? String
        updateEffort(effort)
        onEffortChanged?(effort)
    }

    // MARK: - Configuration

    func configure(agent: AgentKind, model: String? = nil, effort: String? = nil) {
        currentAgent = agent
        agentPill.title = "✦ \(agent.displayName) ▾"

        // Reset model to passed value (or first available)
        let catalog = AgentCatalog.agents[agent]
        let resolvedModel = model ?? catalog?.models.first
        currentModel = resolvedModel
        modelPill.title = resolvedModel.map { shortModelName($0) + " ▾" } ?? ""
        modelPill.isHidden = catalog?.models.isEmpty ?? true

        // Effort: only shown when agent supports it
        let resolvedEffort = effort ?? catalog?.defaultEffort
        currentEffort = resolvedEffort
        effortPill.title = resolvedEffort.map { $0 + " ▾" } ?? ""
        effortPill.isHidden = catalog?.effortLevels == nil
    }

    func updateModel(_ model: String?) {
        currentModel = model
        modelPill.title = model.map { shortModelName($0) + " ▾" } ?? ""
    }

    func updateEffort(_ effort: String?) {
        currentEffort = effort
        effortPill.title = effort.map { $0 + " ▾" } ?? ""
    }

    // Strips provider prefix: "claude-opus-4.8" → "opus-4.8", "gemini-2.5-pro" → "2.5-pro"
    private func shortModelName(_ model: String) -> String {
        let prefixes = ["claude-", "gemini-", "gpt-"]
        for prefix in prefixes {
            if model.hasPrefix(prefix) { return String(model.dropFirst(prefix.count)) }
        }
        return model
    }

    func focus() {
        field.stringValue = ""
        window?.makeFirstResponder(field)
    }

    func prefill(_ text: String) {
        field.stringValue = text
        field.currentEditor()?.selectAll(nil)
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

// MARK: - Drag destination (image / file → insert path)

extension AIQueryInputView {
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pb = sender.draggingPasteboard
        let hasImage = PasteController.pngImageData(from: pb) != nil
        let hasFile = pb.canReadObject(forClasses: [NSURL.self],
                                       options: [.urlReadingFileURLsOnly: true])
        return (hasImage || hasFile) ? .copy : []
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pb = sender.draggingPasteboard
        if let path = PasteController.writePastedImage(from: pb) {
            insertIntoField(path); return true
        }
        if let urls = pb.readObjects(forClasses: [NSURL.self],
                                     options: [.urlReadingFileURLsOnly: true]) as? [URL],
           let url = urls.first {
            insertIntoField(url.path); return true
        }
        return false
    }

    private func insertIntoField(_ text: String) {
        if let ed = field.currentEditor() as? NSTextView {
            ed.insertText(text, replacementRange: ed.selectedRange())
        } else {
            field.stringValue += text
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
