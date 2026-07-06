import AppKit
import KouenCore

@MainActor
private final class SearchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
final class CommandHistorySearchController: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSWindowDelegate {
    static let shared = CommandHistorySearchController()

    private var window: NSPanel?
    private let searchField = NSTextField()
    private let tableView = NSTableView()
    private let scrollView = NSScrollView()
    private let emptyLabel = NSTextField(labelWithString: "No matching commands")
    private var filteredEntries: [String] = []

    private override init() {
        super.init()
    }

    func present() {
        let panel = window ?? build()
        window = panel
        guard let keyWindow = NSApp.keyWindow else { return }
        let frame = keyWindow.frame
        let size = NSSize(width: 520, height: 260)
        panel.setFrame(
            NSRect(
                x: frame.midX - size.width / 2,
                y: frame.minY + 64,
                width: size.width,
                height: size.height
            ),
            display: false
        )
        searchField.stringValue = ""
        rebuildFilteredEntries()
        tableView.reloadData()
        selectFirstRow()

        panel.alphaValue = 0
        panel.orderFront(nil)
        panel.makeKey()
        panel.makeFirstResponder(searchField)
        KouenMotion.animate(KouenDesign.Motion.fast, timing: KouenDesign.Motion.entrance) { _ in
            panel.animator().alphaValue = 1
        }
    }

    func dismiss() {
        guard let window else { return }
        KouenMotion.animate(KouenDesign.Motion.fast, timing: KouenDesign.Motion.exit) { _ in
            window.animator().alphaValue = 0
        } completion: {
            window.orderOut(nil)
        }
    }

    // MARK: - NSTextFieldDelegate

    func controlTextDidChange(_ obj: Notification) {
        rebuildFilteredEntries()
        tableView.reloadData()
        selectFirstRow()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
        switch selector {
        case #selector(NSResponder.moveDown(_:)):
            moveSelection(by: 1)
            return true
        case #selector(NSResponder.moveUp(_:)):
            moveSelection(by: -1)
            return true
        case #selector(NSResponder.insertNewline(_:)):
            activate()
            return true
        case #selector(NSResponder.cancelOperation(_:)):
            dismiss()
            return true
        default:
            return false
        }
    }

    // MARK: - NSWindowDelegate

    func windowDidResignKey(_ notification: Notification) {
        dismiss()
    }

    // MARK: - Actions

    @objc private func tableClick() {
        activate()
    }

    private func activate() {
        let row = tableView.selectedRow
        guard row >= 0, row < filteredEntries.count else { return }
        let selectedText = filteredEntries[row]
        dismiss()
        CommandPromptController.shared.presentSeeded(text: selectedText)
    }

    private func rebuildFilteredEntries() {
        let query = searchField.stringValue.trimmingCharacters(in: .whitespaces)
        var uniqueHistory: [String] = []
        var seen = Set<String>()
        for entry in CommandPromptController.shared.historyEntries.reversed() {
            if seen.insert(entry).inserted {
                uniqueHistory.append(entry)
            }
        }

        if query.isEmpty {
            filteredEntries = uniqueHistory
        } else {
            filteredEntries = uniqueHistory.filter { entry in
                matches(query: query, in: entry)
            }
        }
        emptyLabel.isHidden = !filteredEntries.isEmpty
    }

    private func matches(query: String, in string: String) -> Bool {
        if query.isEmpty { return true }
        let lowerQ = Array(query.lowercased())
        let lowerS = Array(string.lowercased())
        var qIdx = 0
        var sIdx = 0
        while qIdx < lowerQ.count && sIdx < lowerS.count {
            if lowerS[sIdx] == lowerQ[qIdx] {
                qIdx += 1
            }
            sIdx += 1
        }
        return qIdx == lowerQ.count
    }

    private func selectFirstRow() {
        if !filteredEntries.isEmpty {
            tableView.selectRowIndexes([0], byExtendingSelection: false)
            tableView.scrollRowToVisible(0)
        } else {
            tableView.selectRowIndexes([], byExtendingSelection: false)
        }
    }

    private func moveSelection(by offset: Int) {
        guard !filteredEntries.isEmpty else { return }
        let current = tableView.selectedRow
        let count = filteredEntries.count
        let next: Int
        if current < 0 {
            next = offset > 0 ? 0 : count - 1
        } else {
            next = (current + offset + count) % count
        }
        tableView.selectRowIndexes([next], byExtendingSelection: false)
        tableView.scrollRowToVisible(next)
    }

    // MARK: - NSTableViewDataSource & NSTableViewDelegate

    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredEntries.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 32
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return HistoryRowView()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row >= 0, row < filteredEntries.count else { return nil }
        let command = filteredEntries[row]
        return HistoryItemView(command: command, query: searchField.stringValue)
    }

    // MARK: - UI Builder

    private func build() -> NSPanel {
        let panel = SearchPanel(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 260),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.delegate = self

        let overlay = KouenOverlayBackground()
        overlay.frame = NSRect(x: 0, y: 0, width: 520, height: 260)
        let content = overlay.contentView

        let c = KouenChrome.current

        searchField.placeholderAttributedString = NSAttributedString(
            string: "Search command history...",
            attributes: [
                .foregroundColor: c.textTertiary,
                .font: NSFont.systemFont(ofSize: 13),
            ]
        )
        searchField.font = .systemFont(ofSize: 13)
        searchField.textColor = c.textPrimary
        searchField.isBordered = false
        searchField.drawsBackground = false
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false

        let separator = NSView()
        separator.wantsLayer = true
        separator.layer?.backgroundColor = c.border.cgColor
        separator.translatesAutoresizingMaskIntoConstraints = false

        let column = NSTableColumn(identifier: .init("history"))
        tableView.addTableColumn(column)
        tableView.headerView = nil
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.intercellSpacing = .zero
        tableView.selectionHighlightStyle = .none
        tableView.target = self
        tableView.action = #selector(tableClick)
        tableView.doubleAction = #selector(tableClick)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.documentView = tableView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsets = NSEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)

        emptyLabel.font = .systemFont(ofSize: 12)
        emptyLabel.textColor = c.textTertiary
        emptyLabel.alignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.isHidden = true

        content.addSubview(searchField)
        content.addSubview(separator)
        content.addSubview(scrollView)
        content.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: content.topAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 24),

            separator.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            scrollView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: content.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])

        panel.contentView = overlay
        return panel
    }
}

@MainActor
final class HistoryRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        guard isSelected else { return }
        let rect = bounds.insetBy(dx: KouenDesign.Spacing.md, dy: 2)
        let path = NSBezierPath(roundedRect: rect, xRadius: KouenDesign.Radius.control, yRadius: KouenDesign.Radius.control)
        let c = KouenChrome.current
        c.accent.withAlphaComponent(c.isDark ? 0.16 : 0.13).setFill()
        path.fill()
    }
}

@MainActor
private final class HistoryItemView: NSView {
    init(command: String, query: String) {
        super.init(frame: .zero)
        let c = KouenChrome.current

        let icon = NSImageView()
        icon.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 11, weight: .regular))
        icon.contentTintColor = c.textTertiary
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)

        let title = NSTextField(labelWithString: command)
        title.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        title.textColor = c.textPrimary
        title.lineBreakMode = .byTruncatingTail
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        if !query.isEmpty {
            title.attributedStringValue = highlight(command, query: query, primary: c.textPrimary, accent: c.accent)
        }

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: KouenDesign.Spacing.xl),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 14),

            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: KouenDesign.Spacing.md),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KouenDesign.Spacing.xl),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func highlight(_ text: String, query: String, primary: NSColor, accent: NSColor) -> NSAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: primary,
        ]
        let result = NSMutableAttributedString(string: text, attributes: attrs)
        let lowerText = text.lowercased()
        let lowerQuery = query.lowercased()
        var textIdx = lowerText.startIndex
        for q in lowerQuery {
            guard textIdx < lowerText.endIndex else { break }
            if let found = lowerText[textIdx...].firstIndex(of: q) {
                let nsRange = NSRange(found ... found, in: text)
                result.addAttributes([
                    .foregroundColor: accent,
                    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold),
                ], range: nsRange)
                textIdx = lowerText.index(after: found)
            }
        }
        return result
    }
}
