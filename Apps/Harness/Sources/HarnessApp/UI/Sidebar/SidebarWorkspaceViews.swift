import AppKit
import HarnessCore
import SwiftUI

// MARK: - Workspace switcher

@MainActor
final class WorkspaceSwitcherPanelView: NSView {
    private let workspaces: [Workspace]
    private let activeWorkspaceID: WorkspaceID?
    private let onSelect: (WorkspaceID) -> Void
    private let onNew: () -> Void
    private let onDelete: (Workspace, NSView) -> Void
    let preferredHeight: CGFloat

    init(
        workspaces: [Workspace],
        activeWorkspaceID: WorkspaceID?,
        onSelect: @escaping (WorkspaceID) -> Void,
        onNew: @escaping () -> Void,
        onDelete: @escaping (Workspace, NSView) -> Void
    ) {
        self.workspaces = workspaces
        self.activeWorkspaceID = activeWorkspaceID
        self.onSelect = onSelect
        self.onNew = onNew
        self.onDelete = onDelete
        self.preferredHeight = max(84, CGFloat(37 * workspaces.count + 50))
        super.init(frame: .zero)

        wantsLayer = true
        layer?.cornerRadius = HarnessDesign.Radius.overlay
        layer?.cornerCurve = .continuous
        // Shadow needs to escape the bounds, so the rounded fill lives on a masked
        // sublayer instead of clipping the whole view.
        layer?.masksToBounds = false
        let c = HarnessDesign.chrome
        layer?.backgroundColor = (c.sidebarBackground.blended(withFraction: c.isDark ? 0.06 : 0.04, of: c.textPrimary) ?? c.sidebarBackground).cgColor
        layer?.borderWidth = 1
        layer?.borderColor = c.textPrimary.withAlphaComponent(c.isDark ? 0.11 : 0.14).cgColor
        HarnessDesign.applyShadow(.overlay, to: layer)

        setupContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupContent() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = 3
        stack.edgeInsets = NSEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        stack.translatesAutoresizingMaskIntoConstraints = false

        for workspace in workspaces {
            let isLast = workspaces.count == 1
            let row = WorkspaceSwitcherRow(
                title: workspace.name,
                count: workspace.sessions.count,
                isActive: workspace.id == activeWorkspaceID,
                symbol: "square.stack.3d.up",
                canDelete: !isLast
            )
            row.onClick = { [onSelect] in onSelect(workspace.id) }
            row.onMoreClick = { [weak row, onDelete] in
                guard let row else { return }
                onDelete(workspace, row)
            }
            stack.addArrangedSubview(row)
        }

        let divider = NSView()
        divider.wantsLayer = true
        divider.layer?.backgroundColor = HarnessDesign.chrome.textPrimary.withAlphaComponent(0.08).cgColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.addArrangedSubview(divider)

        let newRow = WorkspaceSwitcherRow(
            title: "New Workspace...",
            count: nil,
            isActive: false,
            symbol: "folder.badge.plus"
        )
        newRow.onClick = onNew
        stack.addArrangedSubview(newRow)

        // Scrollable so a long workspace list stays on-screen when the caller clamps
        // the dropdown height (see clampedDropdownHeight).
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.scrollerStyle = .overlay
        scroll.documentView = stack
        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor),
        ])
    }
}

/// A row is a plain NSView, not an NSButton: NSButton's bezel `alignmentRectInsets`
/// offset it inside the stack view, which left the selected row floating off to one
/// side. A view fills the row width cleanly and we drive the click ourselves.
@MainActor
private final class WorkspaceSwitcherRow: NSView {
    var onClick: (() -> Void)?
    var onMoreClick: (() -> Void)?

    private let icon = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let moreButton = NSButton()
    private var trackingArea: NSTrackingArea?
    private var isHovered = false { didSet { applyChrome() } }
    private let active: Bool
    private let canDelete: Bool

    init(title: String, count: Int?, isActive: Bool, symbol: String, canDelete: Bool = true) {
        active = isActive
        self.canDelete = canDelete
        // `count` retained on the init signature so call sites don't have to
        // change; the visual badge has been removed for a cleaner row.
        _ = count
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false

        let iconConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        icon.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
            .withSymbolConfiguration(iconConfig)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleProportionallyUpOrDown

        titleLabel.stringValue = title
        titleLabel.font = HarnessDesign.Typography.sidebarLabel
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toolTip = title

        // Close button: always visible X
        let moreConfig = NSImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        moreButton.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close session")?
            .withSymbolConfiguration(moreConfig)
        moreButton.imagePosition = .imageOnly
        moreButton.bezelStyle = .accessoryBarAction
        moreButton.isBordered = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.target = self
        moreButton.action = #selector(moreClicked)
        moreButton.alphaValue = 1
        moreButton.isHidden = false

        addSubview(icon)
        addSubview(titleLabel)
        addSubview(moreButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 34),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 15),
            icon.heightAnchor.constraint(equalToConstant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -6),
            moreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            moreButton.widthAnchor.constraint(equalToConstant: 22),
            moreButton.heightAnchor.constraint(equalToConstant: 22),
        ])
        applyChrome()
    }

    @objc private func moreClicked() {
        onMoreClick?()
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

    override func mouseEntered(with event: NSEvent) { isHovered = true }
    override func mouseExited(with event: NSEvent) { isHovered = false }

    // Capture the press (without forwarding) so this view receives the matching
    // mouseUp; the selection fires on up if the cursor is still inside the row.
    override func mouseDown(with event: NSEvent) {}

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if bounds.contains(point) { onClick?() }
    }

    private func applyChrome() {
        let c = HarnessDesign.chrome
        let selectedFill = c.accent.withAlphaComponent(c.isDark ? 0.14 : 0.11)
        layer?.backgroundColor = active
            ? selectedFill.cgColor
            : (isHovered ? c.textPrimary.withAlphaComponent(0.06).cgColor : NSColor.clear.cgColor)
        layer?.borderWidth = 0
        icon.contentTintColor = active ? c.accent : c.textTertiary
        titleLabel.textColor = active || isHovered ? c.textPrimary : c.textSecondary
        moreButton.contentTintColor = c.textSecondary
        // Close button always visible
    }
}

// MARK: - Workspace pill

@Observable @MainActor
final class WorkspacePillModel {
    var name: String = ""
    // ponytail: toggled by applyChromeColors so the hosted SwiftUI body re-runs and
    // picks up the fresh HarnessDesign.chrome (static — not @Observable itself).
    var chromeEpoch: Int = 0
}

struct WorkspacePillView: View {
    let model: WorkspacePillModel
    let onClick: () -> Void
    let onMoreClick: () -> Void
    @State private var isHovered = false

    var body: some View {
        let _ = model.chromeEpoch
        let c = HarnessDesign.chrome
        let fg = Color(nsColor: isHovered ? c.textPrimary : c.textSecondary)
        let trail = Color(nsColor: isHovered ? c.textSecondary : c.textTertiary)
        HStack(spacing: 0) {
            Button(action: onClick) {
                HStack(spacing: 8) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(fg)
                        .frame(width: 16, height: 16)
                    Text(model.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(fg)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Button(action: onMoreClick) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(trail)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .help("Workspace actions")
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(trail)
                .frame(width: 12, height: 12)
                .padding(.leading, 2)
                .padding(.trailing, 10)
                .allowsHitTesting(false)
        }
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color(nsColor: isHovered
                    ? c.textPrimary.withAlphaComponent(c.isDark ? 0.11 : 0.12)
                    : c.surfaceElevated))
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(
                            Color(nsColor: isHovered
                                ? c.focusRing.withAlphaComponent(c.isDark ? 0.45 : 0.50)
                                : c.borderStrong),
                            lineWidth: 1
                        )
                )
        )
        .onHover { isHovered = $0 }
        .help(model.name)
    }
}
