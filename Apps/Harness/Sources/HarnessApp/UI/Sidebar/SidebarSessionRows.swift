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

    func configure(name: String, count: Int, isCollapsed: Bool, status: BoardColumnKind) {
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
        boardStatusLabel.stringValue = "\(count) \(count == 1 ? "worktree" : "worktrees")"
        boardStatusLabel.toolTip = statusText

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
    private let agentStatusDot = NSView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let prBadge = SidebarBadgeView()
    private let notificationBadge = SidebarBadgeView()
    private let metaLabel = NSTextField(labelWithString: "")
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

        agentStatusDot.wantsLayer = true
        agentStatusDot.layer?.cornerRadius = 3
        agentStatusDot.layer?.cornerCurve = .continuous
        agentStatusDot.translatesAutoresizingMaskIntoConstraints = false
        agentStatusDot.setContentHuggingPriority(.required, for: .horizontal)
        agentStatusDot.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.usesSingleLineMode = true
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        prBadge.configure(text: "#42 ✓", color: HarnessDesign.chrome.accent)
        prBadge.isHidden = true

        notificationBadge.configure(text: "", color: HarnessDesign.chrome.danger)
        notificationBadge.isHidden = true

        metaLabel.font = .systemFont(ofSize: 10, weight: .regular)
        metaLabel.usesSingleLineMode = true
        metaLabel.lineBreakMode = .byTruncatingMiddle
        metaLabel.alphaValue = 0.7
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        closeButton.title = "×"
        closeButton.bezelStyle = .accessoryBarAction
        closeButton.isBordered = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
        closeButton.toolTip = "Close session"
        closeButton.alphaValue = 0

        addSubview(fill)
        fill.addSubview(agentStatusDot)
        fill.addSubview(titleLabel)
        fill.addSubview(prBadge)
        fill.addSubview(notificationBadge)
        fill.addSubview(metaLabel)
        fill.addSubview(closeButton)

        NSLayoutConstraint.activate([
            fill.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            fill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            fill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HarnessDesign.horizontalInset + 8),
            fill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(HarnessDesign.horizontalInset - 4)),

            agentStatusDot.leadingAnchor.constraint(equalTo: fill.leadingAnchor, constant: 8),
            agentStatusDot.topAnchor.constraint(equalTo: fill.topAnchor, constant: 13),
            agentStatusDot.widthAnchor.constraint(equalToConstant: 6),
            agentStatusDot.heightAnchor.constraint(equalToConstant: 6),

            titleLabel.leadingAnchor.constraint(equalTo: agentStatusDot.trailingAnchor, constant: 7),
            titleLabel.topAnchor.constraint(equalTo: fill.topAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: prBadge.leadingAnchor, constant: -6),

            prBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            prBadge.trailingAnchor.constraint(equalTo: notificationBadge.leadingAnchor, constant: -4),

            notificationBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            notificationBadge.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4),

            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            metaLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -6),

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
        let c = HarnessDesign.chrome

        let title = session.name.isEmpty ? HarnessDesign.pathDisplayName(tab.cwd) : session.name
        titleLabel.stringValue = title
        titleLabel.textColor = isSelected ? c.textPrimary : c.textSecondary

        let branch = tab.gitBranch?.trimmingCharacters(in: .whitespacesAndNewlines)
        let branchName: String
        if let branch, !branch.isEmpty {
            branchName = branch
        } else {
            branchName = "no branch"
        }
        let shortenedCwd = HarnessDesign.shortenPath(tab.cwd)
        metaLabel.stringValue = "\(branchName) · \(shortenedCwd)"
        metaLabel.textColor = isSelected ? c.textPrimary : c.textSecondary
        toolTip = "\(title)\n\(metaLabel.stringValue)"

        let waitingCount = session.tabs.filter { $0.status == .waiting }.count
        notificationBadge.configure(text: "\(waitingCount)", color: c.danger)
        notificationBadge.isHidden = waitingCount == 0

        let (dotColor, dotTooltip) = agentDotAppearance(for: session)
        agentStatusDot.layer?.backgroundColor = dotColor.cgColor
        agentStatusDot.toolTip = dotTooltip

        setSelected(isSelected)
    }

    private func agentDotAppearance(for session: SessionGroup) -> (NSColor, String) {
        let tabsWithAgents = session.tabs.filter { $0.effectiveAgentKind != nil }
        guard !tabsWithAgents.isEmpty else {
            return (HarnessDesign.chrome.idleStatus, "No agent")
        }
        if tabsWithAgents.contains(where: { $0.agent?.activity == .working }) {
            return (.systemGreen, "Agent active")
        }
        return (.systemYellow, "Agent idle")
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
private final class SidebarBadgeView: NSView {
    private let label = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = HarnessDesign.Radius.badge
        layer?.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        label.font = .monospacedDigitSystemFont(ofSize: 9, weight: .bold)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 16),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String, color: NSColor) {
        label.stringValue = text
        label.textColor = color
        layer?.backgroundColor = color.withAlphaComponent(0.16).cgColor
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
