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
            .withSymbolConfiguration(HarnessDesign.symbolConfig(pointSize: HarnessDesign.IconSize.tiny, weight: .semibold))
        disclosureImage.translatesAutoresizingMaskIntoConstraints = false
        disclosureImage.imageScaling = .scaleProportionallyUpOrDown
        disclosureImage.setContentHuggingPriority(.required, for: .horizontal)

        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.alignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

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
        leftStack.spacing = 4
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.addArrangedSubview(disclosureImage)
        leftStack.addArrangedSubview(label)

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

            disclosureImage.widthAnchor.constraint(equalToConstant: 16),
            disclosureImage.heightAnchor.constraint(equalToConstant: 12),

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
        if addButton.frame.contains(point) || optionsButton.frame.contains(point) {
            super.mouseDown(with: event)
        } else {
            onToggleCollapse?()
        }
    }

    func configure(name: String, isCollapsed: Bool) {
        label.stringValue = name
        toolTip = name
        let changed = self.isCollapsed != isCollapsed
        self.isCollapsed = isCollapsed
        let rotation: CGFloat = isCollapsed ? 0 : -90
        if changed {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = HarnessDesign.Motion.standard
                context.timingFunction = HarnessDesign.Motion.standardEase
                disclosureImage.animator().frameCenterRotation = rotation
            }
        } else {
            disclosureImage.frameCenterRotation = rotation
        }
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
        addButton.alphaValue = isHovered ? 1 : 0
        optionsButton.alphaValue = isHovered ? 1 : 0
    }
}

@MainActor
final class SessionCardRowView: NSView {
    var onContextMenu: (() -> NSMenu?)?
    var onClose: (() -> Void)?
    var onToggleExpand: (() -> Void)?

    private let fill = NSView()
    private let expandButton = NSButton()
    private let titleLabel = NSTextField(labelWithString: "")
    private let metaLabel = NSTextField(labelWithString: "")
    private let agentChip = AgentChipView()
    private let closeButton = NSButton()
    private let stateIndicator = NSView()
    private var isSelected = false
    private var isHovered = false
    private var trackingArea: NSTrackingArea?

    var isExpanded: Bool = false {
        didSet {
            let angle: CGFloat = isExpanded ? 90 : 0
            expandButton.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)?
                .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 9, weight: .semibold))
            if #available(macOS 14, *) {
                expandButton.contentTintColor = HarnessDesign.chrome.textSecondary
            }
            // rotate via layer transform
            expandButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            let rotation = CATransform3DMakeRotation(angle * .pi / 180, 0, 0, 1)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            expandButton.layer?.transform = rotation
            CATransaction.commit()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true

        fill.wantsLayer = true
        fill.layer?.cornerRadius = HarnessDesign.cornerRadius
        fill.layer?.cornerCurve = .continuous
        fill.layer?.borderWidth = 1
        fill.layer?.masksToBounds = false
        fill.translatesAutoresizingMaskIntoConstraints = false

        expandButton.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 9, weight: .semibold))
        expandButton.isBordered = false
        expandButton.imagePosition = .imageOnly
        expandButton.wantsLayer = true
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.target = self
        expandButton.action = #selector(expandClicked)
        expandButton.alphaValue = 0   // hidden at rest, shown on hover

        titleLabel.font = HarnessDesign.Typography.sidebarLabel
        titleLabel.usesSingleLineMode = true
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // The agent chip now carries the full tool name; let the title truncate to
        // make room rather than squeezing the chip.
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        metaLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        metaLabel.usesSingleLineMode = true
        metaLabel.lineBreakMode = .byTruncatingTail
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        agentChip.translatesAutoresizingMaskIntoConstraints = false
        agentChip.isHidden = true

        closeButton.title = "×"
        closeButton.bezelStyle = .accessoryBarAction
        closeButton.isBordered = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
        closeButton.toolTip = "Close session"
        closeButton.alphaValue = 0

        stateIndicator.wantsLayer = true
        stateIndicator.layer?.cornerRadius = 3
        stateIndicator.layer?.cornerCurve = .continuous
        stateIndicator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(fill)
        fill.addSubview(expandButton)
        fill.addSubview(titleLabel)
        fill.addSubview(metaLabel)
        fill.addSubview(agentChip)
        fill.addSubview(closeButton)
        fill.addSubview(stateIndicator)

        NSLayoutConstraint.activate([
            fill.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            fill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            fill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HarnessDesign.horizontalInset - 4),
            fill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(HarnessDesign.horizontalInset - 4)),

            expandButton.leadingAnchor.constraint(equalTo: fill.leadingAnchor, constant: 4),
            expandButton.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            expandButton.widthAnchor.constraint(equalToConstant: 14),
            expandButton.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: expandButton.trailingAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: fill.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: agentChip.leadingAnchor, constant: -6),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -6),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: stateIndicator.leadingAnchor, constant: -6),

            agentChip.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -6),
            agentChip.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            agentChip.heightAnchor.constraint(equalToConstant: 18),
            agentChip.widthAnchor.constraint(lessThanOrEqualToConstant: 140),

            closeButton.topAnchor.constraint(equalTo: fill.topAnchor, constant: 7),
            closeButton.trailingAnchor.constraint(equalTo: fill.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            closeButton.heightAnchor.constraint(equalToConstant: 22),

            stateIndicator.centerYAnchor.constraint(equalTo: fill.centerYAnchor),
            stateIndicator.trailingAnchor.constraint(equalTo: fill.trailingAnchor, constant: -12),
            stateIndicator.widthAnchor.constraint(equalToConstant: 6),
            stateIndicator.heightAnchor.constraint(equalToConstant: 6),

            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            metaLabel.trailingAnchor.constraint(lessThanOrEqualTo: fill.trailingAnchor, constant: -20),
            metaLabel.trailingAnchor.constraint(lessThanOrEqualTo: stateIndicator.leadingAnchor, constant: -6),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: fill.bottomAnchor, constant: -6),
        ])
    }

    @objc private func closeClicked() {
        onClose?()
    }

    @objc private func expandClicked() {
        onToggleExpand?()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
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
        let folder = HarnessDesign.shortenPath(tab.cwd)
        let folderName = HarnessDesign.pathDisplayName(tab.cwd)
        let displayedAgentKind = session.tabs.lazy.compactMap { $0.agent?.kind ?? AgentTitleInference.kind(from: $0.title) }.first
        let defaultTitle = displayedAgentKind?.displayName ?? folderName
        // Mirror the tab bar: title always tracks the active tab's live cwd/agent rather
        // than a custom name that goes stale once the session cd's elsewhere.
        titleLabel.stringValue = defaultTitle
        toolTip = displayedAgentKind != nil ? "\(defaultTitle) — \(folder)" : folder

        var metaParts: [String] = []
        metaParts.append(String(session.id.uuidString.replacingOccurrences(of: "-", with: "").prefix(7)).lowercased())
        var repoWithBranch = folderName
        if let branch = tab.gitBranch, !branch.isEmpty {
            repoWithBranch += " (⎇ \(branch))"
        }
        metaParts.append(repoWithBranch)

        if !tab.title.isEmpty {
            metaParts.append(tab.title)
        }
        if session.tabs.count > 1 {
            metaParts.append("\(session.tabs.count) tabs")
        }
        metaParts.append(folder)
        metaLabel.stringValue = metaParts.joined(separator: "  •  ")

        if let kind = displayedAgentKind {
            agentChip.configure(kind: kind, hex: SessionCoordinator.shared.settings.agentColorHex(for: kind))
            agentChip.isHidden = false
        } else {
            agentChip.isHidden = true
        }

        let indicatorColor: NSColor
        if let exitStatus = tab.exitStatus {
            if exitStatus == 0 {
                indicatorColor = NSColor.systemGreen
            } else {
                indicatorColor = NSColor.systemRed
            }
        } else if let cmd = tab.currentCommand, !cmd.isEmpty {
            let shellNames = ["zsh", "bash", "sh", "fish", "csh", "tcsh", "login"]
            let lowerCmd = cmd.lowercased()
            let isShell = shellNames.contains(lowerCmd)
            if !isShell {
                indicatorColor = NSColor.systemBlue
            } else {
                indicatorColor = NSColor.systemGray.withAlphaComponent(0.4)
            }
        } else {
            indicatorColor = NSColor.systemGray.withAlphaComponent(0.4)
        }
        stateIndicator.layer?.backgroundColor = indicatorColor.cgColor

        setSelected(isSelected)
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
        metaLabel.textColor = c.textTertiary
        closeButton.alphaValue = isHovered ? 1 : 0
        expandButton.alphaValue = isHovered || isExpanded ? 1 : 0
        if #available(macOS 14, *) { expandButton.contentTintColor = c.textSecondary }
        stateIndicator.alphaValue = isHovered ? 0 : 1
        let closeColor = c.textSecondary
        closeButton.attributedTitle = NSAttributedString(
            string: "×",
            attributes: [
                .foregroundColor: closeColor,
                .font: NSFont.systemFont(ofSize: 20, weight: .regular),
            ]
        )
        if isSelected {
            // Selected row: theme-tinted fill + accent rim + resting elevation. The
            // fill is the accent at low alpha (legible on every theme) so the active
            // session reads instantly even at a glance.
            let selectedFill = c.accent.withAlphaComponent(c.isDark ? 0.13 : 0.10)
            fill.layer?.backgroundColor = selectedFill.cgColor
            fill.layer?.borderColor = c.focusRing.withAlphaComponent(c.isDark ? 0.48 : 0.52).cgColor
            HarnessDesign.applyShadow(.elevation1, to: fill.layer)
            titleLabel.textColor = c.textPrimary
            metaLabel.textColor = c.textSecondary
        } else if isHovered {
            fill.layer?.backgroundColor = c.rowHoverFill.cgColor
            fill.layer?.borderColor = NSColor.clear.cgColor
            HarnessDesign.applyShadow(.none, to: fill.layer)
            titleLabel.textColor = c.textPrimary
        } else {
            fill.layer?.backgroundColor = NSColor.clear.cgColor
            fill.layer?.borderColor = NSColor.clear.cgColor
            HarnessDesign.applyShadow(.none, to: fill.layer)
            titleLabel.textColor = c.textSecondary
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        // Cross-fade the hover state so cursor flicks across the list don't strobe.
        HarnessMotion.animate(HarnessDesign.Motion.microFast) { _ in
            refresh()
        }
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        HarnessMotion.animate(HarnessDesign.Motion.microFast) { _ in
            refresh()
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

// MARK: - Tab sub-row (shown when session is expanded)

@MainActor
final class SessionTabRowView: NSView {
    var onTap: (() -> Void)?

    private let dot = NSView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let metaLabel = NSTextField(labelWithString: "")
    private var trackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true

        dot.wantsLayer = true
        dot.layer?.cornerRadius = 3
        dot.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 11.5, weight: .regular)
        titleLabel.usesSingleLineMode = true
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        metaLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        metaLabel.usesSingleLineMode = true
        metaLabel.lineBreakMode = .byTruncatingMiddle
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(dot)
        addSubview(titleLabel)
        addSubview(metaLabel)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),

            titleLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            metaLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4),
        ])

        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(click)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(tab: Tab) {
        let c = HarnessDesign.chrome

        // Board status dot
        let column = BoardModel.classify(snapshot: SessionCoordinator.shared.snapshot)
            .first { $0.cards.contains { $0.tabID == tab.id } }?.kind
        switch column {
        case .needsAttention: dot.layer?.backgroundColor = NSColor.systemOrange.cgColor
        case .running:        dot.layer?.backgroundColor = NSColor.systemBlue.cgColor
        case .error:          dot.layer?.backgroundColor = NSColor.systemRed.cgColor
        case .done:           dot.layer?.backgroundColor = NSColor.systemGreen.cgColor
        default:              dot.layer?.backgroundColor = c.textTertiary.withAlphaComponent(0.4).cgColor
        }

        // Title: command or folder name
        let cmd = tab.currentCommand ?? ""
        let isShell = ["zsh", "bash", "sh", "fish"].contains(cmd.lowercased())
        titleLabel.stringValue = (!cmd.isEmpty && !isShell) ? cmd : HarnessDesign.pathDisplayName(tab.cwd)
        titleLabel.textColor = c.textPrimary

        // Meta: full branch + full CWD (not truncated in source — let label handle it)
        var meta = tab.cwd
        if let branch = tab.gitBranch, !branch.isEmpty {
            meta = "⎇ \(branch)  \(tab.cwd)"
        }
        metaLabel.stringValue = meta
        metaLabel.textColor = c.textTertiary
    }

    @objc private func handleClick() { onTap?() }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let t = trackingArea { removeTrackingArea(t) }
        let a = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(a)
        trackingArea = a
    }

    override func mouseEntered(with event: NSEvent) {
        layer?.backgroundColor = HarnessDesign.chrome.textPrimary.withAlphaComponent(0.06).cgColor
    }
    override func mouseExited(with event: NSEvent) {
        layer?.backgroundColor = .clear
    }
}
