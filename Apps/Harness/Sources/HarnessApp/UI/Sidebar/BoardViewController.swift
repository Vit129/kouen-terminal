import AppKit
import HarnessCore

/// P16 PBI-BOARD-002: "Board" sidebar tab — a horizontal Kanban view over
/// `BoardModel.classify(snapshot:)`. Each column (Needs Attention, Running,
/// Idle, Done, Error) is a vertically-scrolling stack of cards; each card
/// represents one live session/tab. Clicking a card focuses that tab.
///
/// Refreshes the same way `HarnessSidebarPanelViewController` does: observed
/// via `NotificationBus.shared.snapshotChanged`.
@MainActor
final class BoardViewController: NSViewController {
    private let scrollView = NSScrollView()
    private let columnsStack = NSStackView()

    /// Last classification, exposed for tests.
    private(set) var columns: [BoardColumn] = []

    override func loadView() {
        let container = NSView()
        view = container

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.drawsBackground = false
        scrollView.scrollerStyle = .overlay
        scrollView.autohidesScrollers = true

        columnsStack.orientation = .horizontal
        columnsStack.alignment = .top
        columnsStack.distribution = .fill
        columnsStack.spacing = 10
        columnsStack.translatesAutoresizingMaskIntoConstraints = false
        columnsStack.edgeInsets = NSEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)

        let documentView = NSView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.addSubview(columnsStack)
        NSLayoutConstraint.activate([
            columnsStack.topAnchor.constraint(equalTo: documentView.topAnchor),
            columnsStack.bottomAnchor.constraint(equalTo: documentView.bottomAnchor),
            columnsStack.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
            columnsStack.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
        ])

        scrollView.documentView = documentView
        container.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            documentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        HarnessDesign.makeClear(view)
        HarnessDesign.makeClear(scrollView)
        reload()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reload),
            name: NotificationBus.shared.snapshotChanged,
            object: nil
        )
    }

    /// Recomputes columns from the live snapshot and rebuilds the card stacks.
    /// Cheap enough to call on every snapshot change — no diffing needed for a
    /// handful of columns/cards.
    @objc func reload() {
        columns = BoardModel.classify(snapshot: SessionCoordinator.shared.snapshot)

        columnsStack.subviews.forEach { $0.removeFromSuperview() }
        for column in columns {
            columnsStack.addArrangedSubview(makeColumnView(column))
        }
    }

    private func makeColumnView(_ column: BoardColumn) -> NSView {
        let columnView = NSView()
        columnView.translatesAutoresizingMaskIntoConstraints = false

        let header = NSTextField(labelWithString: "\(column.name) (\(column.cards.count))")
        header.font = .systemFont(ofSize: 12, weight: .semibold)
        header.textColor = .secondaryLabelColor
        header.translatesAutoresizingMaskIntoConstraints = false

        let cardsStack = NSStackView()
        cardsStack.orientation = .vertical
        cardsStack.alignment = .leading
        cardsStack.distribution = .fill
        cardsStack.spacing = 6
        cardsStack.translatesAutoresizingMaskIntoConstraints = false

        for card in column.cards {
            cardsStack.addArrangedSubview(makeCardView(card))
        }

        let columnStack = NSStackView(views: [header, cardsStack])
        columnStack.orientation = .vertical
        columnStack.alignment = .leading
        columnStack.spacing = 8
        columnStack.translatesAutoresizingMaskIntoConstraints = false

        columnView.addSubview(columnStack)
        NSLayoutConstraint.activate([
            columnStack.topAnchor.constraint(equalTo: columnView.topAnchor),
            columnStack.leadingAnchor.constraint(equalTo: columnView.leadingAnchor),
            columnStack.trailingAnchor.constraint(equalTo: columnView.trailingAnchor),
            columnView.widthAnchor.constraint(equalToConstant: 220),
            cardsStack.widthAnchor.constraint(equalToConstant: 220),
        ])
        return columnView
    }

    private func makeCardView(_ card: BoardCard) -> NSView {
        let cardView = BoardCardView(card: card)
        cardView.onTap = { [weak self] in
            self?.focus(card: card)
        }
        return cardView
    }

    /// Focuses the workspace/tab represented by `card`, reusing the same
    /// `SessionCoordinator` navigation `SidebarSessionRows`/`selectSessionRow`
    /// use — no new IPC path.
    private func focus(card: BoardCard) {
        let coordinator = SessionCoordinator.shared
        if coordinator.snapshot.activeWorkspaceID != card.workspaceID {
            coordinator.selectWorkspace(card.workspaceID)
        }
        coordinator.selectTab(workspaceID: card.workspaceID, tabID: card.tabID)
    }
}

/// A single Kanban card: title, cwd, branch, current command, and agent chip
/// if present. Click focuses the underlying tab via `onTap`.
@MainActor
final class BoardCardView: NSView {
    var onTap: (() -> Void)?

    init(card: BoardCard) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.cornerRadius = HarnessDesign.Radius.card
        layer?.backgroundColor = NSColor.quaternaryLabelColor.withAlphaComponent(0.12).cgColor

        let titleLabel = NSTextField(labelWithString: card.title.isEmpty ? "(untitled)" : card.title)
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        var metaParts: [String] = [(card.cwd as NSString).lastPathComponent]
        if let branch = card.gitBranch, !branch.isEmpty {
            metaParts.append("⎇ \(branch)")
        }
        let metaLabel = NSTextField(labelWithString: metaParts.joined(separator: "  •  "))
        metaLabel.font = .systemFont(ofSize: 10)
        metaLabel.textColor = .secondaryLabelColor
        metaLabel.lineBreakMode = .byTruncatingTail
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        var stackViews: [NSView] = [titleLabel, metaLabel]
        if let cmd = card.currentCommand, !cmd.isEmpty {
            let cmdLabel = NSTextField(labelWithString: "$ \(cmd)")
            cmdLabel.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
            cmdLabel.textColor = .tertiaryLabelColor
            cmdLabel.lineBreakMode = .byTruncatingTail
            cmdLabel.translatesAutoresizingMaskIntoConstraints = false
            stackViews.append(cmdLabel)
        }
        if let kind = card.agentKind {
            let agentLabel = NSTextField(labelWithString: kind.displayName)
            agentLabel.font = .systemFont(ofSize: 10, weight: .medium)
            agentLabel.textColor = NSColor.fromHex(kind.dotHex) ?? .secondaryLabelColor
            agentLabel.translatesAutoresizingMaskIntoConstraints = false
            stackViews.append(agentLabel)
        }

        let stack = NSStackView(views: stackViews)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])

        addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(handleClick)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    @objc private func handleClick() {
        onTap?()
    }
}
