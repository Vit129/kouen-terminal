import AppKit
import HarnessCore

// MARK: - Session rows

@MainActor
final class SessionGroupHeaderRowView: NSView {
    var onAdd: (() -> Void)?
    var onToggleCollapse: (() -> Void)?
    var onOptions: ((NSView) -> Void)?

    private let leftStack = NSStackView()
    private let rightStack = NSStackView()
    private let disclosureImage = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private let boardStatusDot = NSView()
    private let boardStatusLabel = NSTextField(labelWithString: "")
    private let addButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    private let optionsButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    private var isCollapsed = false
    private var isHovered = false
    private var trackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        disclosureImage.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)?
            .withSymbolConfiguration(HarnessDesign.symbolConfig(pointSize: HarnessDesign.IconSize.tiny, weight: .regular))
        disclosureImage.translatesAutoresizingMaskIntoConstraints = false
        disclosureImage.setContentHuggingPriority(.required, for: .horizontal)

        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.alignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        boardStatusDot.wantsLayer = true
        boardStatusDot.layer?.cornerRadius = 3
        boardStatusDot.layer?.cornerCurve = .continuous
        boardStatusDot.translatesAutoresizingMaskIntoConstraints = false

        boardStatusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        boardStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        boardStatusLabel.setContentHuggingPriority(.required, for: .horizontal)
        boardStatusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        addButton.setSymbol("plus", accessibilityDescription: "New session in group", pointSize: 10, weight: .medium)
        addButton.toolTip = "New session in group"
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.target = self
        addButton.action = #selector(addClicked)
        addButton.setContentHuggingPriority(.required, for: .horizontal)
        addButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        optionsButton.setSymbol("ellipsis", accessibilityDescription: "Group options", pointSize: 10, weight: .medium)
        optionsButton.toolTip = "Group options"
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.target = self
        optionsButton.action = #selector(optionsClicked)
        optionsButton.setContentHuggingPriority(.required, for: .horizontal)
        optionsButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        leftStack.orientation = .horizontal
        leftStack.alignment = .centerY
        leftStack.spacing = 6
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.addArrangedSubview(disclosureImage)
        leftStack.addArrangedSubview(label)
        leftStack.addArrangedSubview(boardStatusDot)
        leftStack.addArrangedSubview(boardStatusLabel)

        rightStack.orientation = .horizontal
        rightStack.alignment = .centerY
        rightStack.spacing = 4
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(addButton)
        rightStack.addArrangedSubview(optionsButton)

        addSubview(leftStack)
        addSubview(rightStack)

        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HarnessDesign.horizontalInset - 4),
            leftStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -8),

            rightStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(HarnessDesign.horizontalInset - 4)),
            rightStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            disclosureImage.widthAnchor.constraint(equalToConstant: 10),
            disclosureImage.heightAnchor.constraint(equalToConstant: 10),

            boardStatusDot.widthAnchor.constraint(equalToConstant: 6),
            boardStatusDot.heightAnchor.constraint(equalToConstant: 6),

            addButton.widthAnchor.constraint(equalToConstant: 20),
            addButton.heightAnchor.constraint(equalToConstant: 20),

            optionsButton.widthAnchor.constraint(equalToConstant: 20),
            optionsButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        guard window != nil else { trackingArea = nil; return }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        refresh()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        refresh()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let addFrame = convert(addButton.bounds, from: addButton)
        let optFrame = convert(optionsButton.bounds, from: optionsButton)
        if addFrame.contains(point) || optFrame.contains(point) {
            super.mouseDown(with: event)
        } else {
            onToggleCollapse?()
        }
    }

    func configure(name: String, isCollapsed: Bool, status: BoardColumnKind) {
        label.stringValue = name
        toolTip = name
        self.isCollapsed = isCollapsed
        disclosureImage.image = NSImage(
            systemSymbolName: isCollapsed ? "chevron.right" : "chevron.down",
            accessibilityDescription: isCollapsed ? "Collapsed" : "Expanded"
        )?.withSymbolConfiguration(HarnessDesign.symbolConfig(pointSize: HarnessDesign.IconSize.tiny, weight: .regular))
        disclosureImage.needsDisplay = true

        let dotColor: NSColor
        let statusText: String
        switch status {
        case .needsAttention:
            dotColor = .systemOrange
            statusText = "Needs Attention"
        case .running:
            dotColor = .systemBlue
            statusText = "Running"
        case .done:
            dotColor = .systemGreen
            statusText = "Done"
        case .error:
            dotColor = .systemRed
            statusText = "Error"
        case .idle:
            dotColor = .systemGray
            statusText = "Idle"
        }
        boardStatusDot.layer?.backgroundColor = dotColor.cgColor
        boardStatusLabel.stringValue = statusText

        refresh()
    }

    @objc private func addClicked() {
        onAdd?()
    }

    @objc private func optionsClicked() {
        onOptions?(optionsButton)
    }

    private func refresh() {
        let c = HarnessDesign.chrome
        label.textColor = isHovered ? c.textPrimary : c.textSecondary
        disclosureImage.contentTintColor = isHovered ? c.textPrimary : c.textSecondary
        boardStatusLabel.textColor = isHovered ? c.textSecondary : c.textTertiary
        addButton.alphaValue = isHovered ? 1 : 0
        optionsButton.alphaValue = isHovered ? 1 : 0
    }
}

@MainActor
final class WorktreeRowView: NSView {
    var onContextMenu: (() -> NSMenu?)?
    var onClose: (() -> Void)?

    private let fill = NSView()
    private let textLabel = NSTextField(labelWithString: "")
    private let statusDot = NSView()
    private let statusLabel = NSTextField(labelWithString: "")
    private var cachedAgentKind: AgentKind?
    private let agentIconView = NSImageView()
    private let closeButton = NSButton()
    private var isSelected = false
    private var isHovered = false
    private var trackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true

        fill.wantsLayer = true
        fill.layer?.cornerRadius = HarnessDesign.Radius.card
        fill.layer?.cornerCurve = .continuous
        fill.layer?.borderWidth = 1
        fill.layer?.masksToBounds = false
        fill.translatesAutoresizingMaskIntoConstraints = false

        textLabel.font = .systemFont(ofSize: 12, weight: .regular)
        textLabel.usesSingleLineMode = true
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        statusDot.wantsLayer = true
        statusDot.layer?.cornerRadius = 3
        statusDot.layer?.cornerCurve = .continuous
        statusDot.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.font = .systemFont(ofSize: 10, weight: .medium)
        statusLabel.usesSingleLineMode = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        agentIconView.translatesAutoresizingMaskIntoConstraints = false
        agentIconView.imageScaling = .scaleProportionallyUpOrDown
        agentIconView.isHidden = true

        closeButton.title = "×"
        closeButton.bezelStyle = .accessoryBarAction
        closeButton.isBordered = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
        closeButton.toolTip = "Close session"
        closeButton.alphaValue = 0

        addSubview(fill)
        fill.addSubview(textLabel)
        fill.addSubview(statusDot)
        fill.addSubview(statusLabel)
        fill.addSubview(agentIconView)
        fill.addSubview(closeButton)

        NSLayoutConstraint.activate([
            fill.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            fill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            fill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HarnessDesign.horizontalInset + 8),
            fill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(HarnessDesign.horizontalInset - 4)),

            textLabel.leadingAnchor.constraint(equalTo: fill.leadingAnchor, constant: 8),
            textLabel.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusDot.leadingAnchor, constant: -6),

            statusDot.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            statusDot.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -4),
            statusDot.widthAnchor.constraint(equalToConstant: 6),
            statusDot.heightAnchor.constraint(equalToConstant: 6),

            statusLabel.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4),

            agentIconView.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            agentIconView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4),
            agentIconView.widthAnchor.constraint(equalToConstant: 14),
            agentIconView.heightAnchor.constraint(equalToConstant: 14),

            closeButton.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: fill.trailingAnchor, constant: -6),
            closeButton.widthAnchor.constraint(equalToConstant: 18),
            closeButton.heightAnchor.constraint(equalToConstant: 18),
        ])
    }

    @objc private func closeClicked() {
        onClose?()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        guard window != nil else { trackingArea = nil; return }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    func configure(session: SessionGroup, isSelected: Bool) {
        let tab = session.activeTab ?? session.tabs.first ?? Tab()
        let shortenedCwd = HarnessDesign.shortenPath(tab.cwd)

        let branchText: String
        if let branch = tab.gitBranch, !branch.isEmpty {
            branchText = "⎇ \(branch)  "
        } else {
            branchText = ""
        }

        let attributedString = NSMutableAttributedString()
        let c = HarnessDesign.chrome

        if !branchText.isEmpty {
            let branchAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: isSelected ? c.textPrimary : c.accent,
                .font: NSFont.systemFont(ofSize: 11.5, weight: .medium)
            ]
            attributedString.append(NSAttributedString(string: branchText, attributes: branchAttrs))
        }

        let cwdAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: isSelected ? c.textPrimary : c.textSecondary,
            .font: NSFont.monospacedSystemFont(ofSize: 11.5, weight: .regular)
        ]
        attributedString.append(NSAttributedString(string: shortenedCwd, attributes: cwdAttrs))

        textLabel.attributedStringValue = attributedString
        toolTip = branchText.isEmpty ? shortenedCwd : "\(branchText)\(shortenedCwd)"

        // Status indicator: derive from all tabs in the session
        let status = highestStatus(for: session)
        let (dotColor, labelText) = statusAppearance(for: status, tab: tab)

        // Show agent icon (same as tab bar) when agent detected; fallback to dot+label
        if let kind = tab.effectiveAgentKind {
            if kind != cachedAgentKind {
                agentIconView.image = AgentIconRenderer.templateOrMonogramImage(for: kind, size: 14)
                agentIconView.contentTintColor = NSColor.fromHex(SessionCoordinator.shared.settings.agentColorHex(for: kind))
                cachedAgentKind = kind
            }
            agentIconView.isHidden = false
            statusDot.isHidden = true
            statusLabel.isHidden = true
        } else {
            cachedAgentKind = nil
            agentIconView.isHidden = true
            statusDot.isHidden = false
            statusLabel.isHidden = false
            statusDot.layer?.backgroundColor = dotColor.cgColor
            statusLabel.stringValue = labelText
            statusLabel.textColor = dotColor.withAlphaComponent(0.8)
        }

        setSelected(isSelected)
    }

    private func highestStatus(for session: SessionGroup) -> BoardColumnKind {
        var highest = BoardColumnKind.idle
        for tab in session.tabs {
            let s = BoardModel.columnKind(for: tab)
            if priority(s) > priority(highest) { highest = s }
        }
        return highest
    }

    private func priority(_ s: BoardColumnKind) -> Int {
        switch s {
        case .needsAttention: return 4
        case .running:        return 3
        case .error:          return 2
        case .done:           return 1
        case .idle:           return 0
        }
    }

    private func statusAppearance(for status: BoardColumnKind, tab: Tab) -> (NSColor, String) {
        let color = status.color
        switch status {
        case .needsAttention: return (color, "waiting")
        case .running:
            if let agent = tab.effectiveAgentKind {
                return (color, agent.displayName)
            }
            let cmd = tab.currentCommand ?? ""
            let shortCmd = BoardModel.shellNames.contains(cmd.lowercased()) ? "" : cmd
            return (color, shortCmd.isEmpty ? "running" : shortCmd)
        case .done:    return (color, "done")
        case .error:   return (color, "error")
        case .idle:    return (color, "idle")
        }
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        onContextMenu?()
    }

    private func setSelected(_ selected: Bool) {
        isSelected = selected
        refresh()
    }

    private func refresh() {
        let c = HarnessDesign.chrome
        closeButton.alphaValue = isHovered ? 1 : 0
        let closeColor = c.textSecondary
        closeButton.attributedTitle = NSAttributedString(
            string: "×",
            attributes: [
                .foregroundColor: closeColor,
                .font: NSFont.systemFont(ofSize: 16, weight: .regular),
            ]
        )
        if isSelected {
            let selectedFill = c.accent.withAlphaComponent(c.isDark ? 0.13 : 0.10)
            fill.layer?.backgroundColor = selectedFill.cgColor
            fill.layer?.borderColor = c.focusRing.withAlphaComponent(c.isDark ? 0.48 : 0.52).cgColor
            HarnessDesign.applyShadow(.elevation1, to: fill.layer)
        } else if isHovered {
            fill.layer?.backgroundColor = c.rowHoverFill.cgColor
            fill.layer?.borderColor = NSColor.clear.cgColor
            HarnessDesign.applyShadow(.none, to: fill.layer)
        } else {
            fill.layer?.backgroundColor = NSColor.clear.cgColor
            fill.layer?.borderColor = NSColor.clear.cgColor
            HarnessDesign.applyShadow(.none, to: fill.layer)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        HarnessMotion.animate(HarnessDesign.Motion.microFast) { _ in
            self.refresh()
        }
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        HarnessMotion.animate(HarnessDesign.Motion.microFast) { _ in
            self.refresh()
        }
    }
}

@MainActor
final class SidebarTitlebarHeaderView: NSView {
    override var mouseDownCanMoveWindow: Bool { true }

    override func mouseUp(with event: NSEvent) {
        if event.clickCount >= 2,
           let controller = window?.windowController as? MainWindowController
        {
            controller.toggleVisibleFrameZoom(self)
            return
        }
        super.mouseUp(with: event)
    }
}
