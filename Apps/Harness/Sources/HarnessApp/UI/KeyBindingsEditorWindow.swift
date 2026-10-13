import AppKit
import HarnessCore

/// Settings ▸ Keys ▸ Edit Key Bindings…: every key-table binding in one searchable list, with
/// record, conflict warnings, add, remove and reset. Edits go through `KeybindingsService`, the
/// same `keybindings.json` that `bind-key` writes, so a change runs on the next keystroke and
/// the CLI, the cheatsheet and Keyboard Shortcuts all show it. Menu items and palette shortcuts
/// keep their own editors and appear here only as conflicts.
@MainActor
final class KeyBindingsEditorWindow: NSObject, NSTableViewDataSource, NSTableViewDelegate,
    NSSearchFieldDelegate, NSComboBoxDelegate, NSWindowDelegate {
    static let shared = KeyBindingsEditorWindow()

    enum Scope: Int, CaseIterable {
        case all, root, prefix, copyMode, copyModeEmacs

        var table: KeyTableID? {
            switch self {
            case .all: return nil
            case .root: return .root
            case .prefix: return .prefix
            case .copyMode: return .copyMode
            case .copyModeEmacs: return .copyModeEmacs
            }
        }

        var title: String {
            switch self {
            case .all: return "All"
            case .root: return "No Prefix"
            case .prefix: return "Prefix"
            case .copyMode: return "Copy Mode (vi)"
            case .copyModeEmacs: return "Copy Mode (emacs)"
            }
        }

        init(table: KeyTableID) {
            self = Self.allCases.first { $0.table == table } ?? .prefix
        }
    }

    private enum Recording: Equatable {
        case add(KeyTableID)
        case change(KeyTableID, KeySpec)

        var table: KeyTableID {
            switch self {
            case let .add(table), let .change(table, _): return table
            }
        }
    }

    private let readTables: () -> KeyTableSet
    private let applyEdit: ((inout KeyTableSet) -> Void) throws -> Void
    private let isPrefixKey: (KeySpec) -> Bool
    private let shadowedByRoot: (KeySpec) -> String?

    private var window: NSWindow?
    private let scopeControl = NSSegmentedControl()
    private let search = NSSearchField()
    private let scopeNote = NSTextField(wrappingLabelWithString: "")
    private let table = NSTableView()
    private let message = NSTextField(wrappingLabelWithString: "")
    private let keyLabel = NSTextField(labelWithString: "")
    private let actionBox = NSComboBox()
    /// The binding the action field edits. Kept apart from the selection so a click that moves
    /// the selection still saves the field against the row it was typed for.
    private var actionTarget: (table: KeyTableID, spec: KeySpec)?
    private let addButton = NSButton()
    private let changeKeyButton = NSButton(title: "Change Key", target: nil, action: nil)
    private let removeButton = NSButton()
    private let resetButton = NSButton(title: "Reset", target: nil, action: nil)
    private let resetTableButton = NSButton(title: "Reset Table…", target: nil, action: nil)

    private(set) var scope: Scope = .prefix
    private(set) var shown: [KeyBindingRow] = []
    private var recording: Recording?
    /// A recorded key that needs Return to confirm, with the warnings already shown.
    private var pendingKey: KeySpec?
    /// A key recorded for a new binding that still needs its action.
    private(set) var pendingAdd: (table: KeyTableID, spec: KeySpec)?
    private var monitor: Any?
    private var observer: NSObjectProtocol?

    init(
        readTables: @escaping () -> KeyTableSet = { KeybindingsService.shared.tables },
        applyEdit: @escaping ((inout KeyTableSet) -> Void) throws -> Void = { try KeybindingsService.shared.edit($0) },
        isPrefixKey: @escaping (KeySpec) -> Bool = { PaletteShortcuts.shared.isPrefixKey($0) },
        shadowedByRoot: @escaping (KeySpec) -> String? = { PaletteShortcuts.shared.shadowed(byRoot: $0) }
    ) {
        self.readTables = readTables
        self.applyEdit = applyEdit
        self.isPrefixKey = isPrefixKey
        self.shadowedByRoot = shadowedByRoot
        super.init()
    }

    func show() {
        let window = window ?? build()
        self.window = window
        if observer == nil {
            observer = NotificationCenter.default.addObserver(
                forName: KeybindingsService.didChange, object: nil, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.reloadUnlessEditing() }
            }
        }
        reload()
        if !window.isVisible { window.center() }
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Rows

    var currentTables: KeyTableSet { readTables() }

    func setScope(_ scope: Scope) {
        self.scope = scope
        scopeControl.selectedSegment = scope.rawValue
        cancelRecording()
        reload()
    }

    func setSearch(_ text: String) {
        search.stringValue = text
        reload()
    }

    private func reloadUnlessEditing() {
        guard table.editedRow < 0, recording == nil else { return }
        reload()
    }

    func reload() {
        let selected = selectedRow.map { ($0.table, $0.spec) }
        let tables = readTables()
        let ids = scope.table.map { [$0] } ?? KeyTableSet.editableTables
        var rows = ids.flatMap { tables.editorRows(in: $0) }
        if let pendingAdd, ids.contains(pendingAdd.table) {
            rows.removeAll { $0.table == pendingAdd.table && $0.spec == pendingAdd.spec }
            rows.insert(KeyBindingRow(
                table: pendingAdd.table, spec: pendingAdd.spec, command: .sequence([]), note: nil,
                repeatable: false, status: .added, defaultCommand: nil
            ), at: 0)
        }
        let needle = search.stringValue.trimmingCharacters(in: .whitespaces).lowercased()
        shown = needle.isEmpty ? rows : rows.filter { row in
            [Self.keyText(row.spec), row.spec.description, isPending(row) ? "" : row.commandText,
             row.note ?? "", Self.statusText(row.status), Scope(table: row.table).title]
                .contains { $0.lowercased().contains(needle) }
        }
        table.reloadData()
        if let selected, let index = shown.firstIndex(where: { $0.table == selected.0 && $0.spec == selected.1 }) {
            table.selectRowIndexes([index], byExtendingSelection: false)
        }
        refreshScopeNote()
        refreshButtons()
    }

    private var selectedRow: KeyBindingRow? {
        shown.indices.contains(table.selectedRow) ? shown[table.selectedRow] : nil
    }

    private func isPending(_ row: KeyBindingRow) -> Bool {
        pendingAdd.map { $0.table == row.table && $0.spec == row.spec } ?? false
    }

    /// Glyph form of a table key. Table specs carry Shift in the character (`M`, `%`), so an
    /// uppercase letter shows ⇧.
    static func keyText(_ spec: KeySpec) -> String {
        var display = spec
        if spec.key.count == 1, spec.key != spec.key.lowercased() {
            display.key = spec.key.lowercased()
            display.modifiers.insert(.shift)
        } else if spec.key.count > 1 {
            display.key = ShortcutRecorderSerializer.canonicalKey(spec.key) ?? spec.key
        }
        return ShortcutRecorderSerializer.glyphString(for: display)
    }

    static func statusText(_ status: KeyBindingRow.Status) -> String {
        switch status {
        case .standard: return "Default"
        case .changed: return "Changed"
        case .added: return "Added"
        case .removed: return "Removed"
        }
    }

    private func refreshScopeNote() {
        let settings = SessionCoordinator.shared.settings
        let prefix = ParsedShortcut.parse(settings.prefixKey)?.displayString ?? settings.prefixKey
        let modeKeys = HarnessOptions.shared.get("mode-keys", scope: .global)?.stringValue ?? "vi"
        switch scope {
        case .all:
            scopeNote.stringValue = "Every key table. No-prefix keys run first, then palette shortcuts, then menus."
        case .root:
            scopeNote.stringValue = "Runs anywhere in Harness without the prefix, before palette shortcuts and menus."
        case .prefix:
            scopeNote.stringValue = settings.effectivePrefixKeyEnabled
                ? "Press \(prefix), then the key. \(prefix) then : always opens the command prompt."
                : "The prefix is off in this experience mode, so these keys wait until it's on."
        case .copyMode, .copyModeEmacs:
            let mode = scope == .copyMode ? "vi" : "emacs"
            let active = modeKeys == mode ? "In use now." : "Used when mode-keys is \(mode)."
            scopeNote.stringValue = "Copy mode keys run copy-mode -X actions. \(active)"
        }
    }

    private func refreshButtons() {
        let row = selectedRow
        let editable = row.map { $0.status != .removed && !isPending($0) } ?? false
        changeKeyButton.isEnabled = editable
        removeButton.isEnabled = editable
        resetButton.isEnabled = row?.isResettable ?? false
        resetTableButton.isEnabled = scope.table != nil
        refreshActionField(row)
        if recording == nil, pendingAdd == nil { describe(row) }
    }

    private func refreshActionField(_ row: KeyBindingRow?) {
        let target = row.map { ($0.table, $0.spec) }
        let sameTarget = target.map { new in actionTarget.map { $0 == new } ?? false } ?? (actionTarget == nil)
        if !sameTarget {
            actionBox.removeAllItems()
            if let row { actionBox.addItems(withObjectValues: Self.suggestions(for: row.table)) }
        }
        actionTarget = target
        guard let row else {
            keyLabel.stringValue = "No key selected"
            actionBox.stringValue = ""
            actionBox.isEnabled = false
            return
        }
        keyLabel.stringValue = "\(Self.keyText(row.spec)) runs"
        actionBox.isEnabled = row.status != .removed
        if !sameTarget || window?.firstResponder !== actionBox.currentEditor() {
            actionBox.stringValue = isPending(row) ? "" : row.commandText
        }
    }

    private func describe(_ row: KeyBindingRow?) {
        guard let row else { return show(message: "", isError: false) }
        switch row.status {
        case .standard: show(message: row.note ?? "", isError: false)
        case .changed:
            show(message: "Default: \(row.defaultCommand?.shortDescription ?? "none"). Reset puts it back.", isError: false)
        case .added: show(message: "Your binding. Reset or Remove deletes it.", isError: false)
        case .removed: show(message: "Unbound. Reset brings back \(row.commandText).", isError: false)
        }
    }

    private func show(message text: String, isError: Bool) {
        message.stringValue = text
        message.textColor = isError ? .systemRed : .secondaryLabelColor
    }

    // MARK: - Recording

    @objc private func addBinding(_ sender: Any?) {
        if let table = scope.table { return startRecording(.add(table)) }
        let menu = NSMenu()
        for scope in Scope.allCases where scope.table != nil {
            let item = NSMenuItem(title: "Add to \(scope.title)", action: #selector(addFromMenu(_:)), keyEquivalent: "")
            item.target = self
            item.tag = scope.rawValue
            menu.addItem(item)
        }
        let anchor = (sender as? NSView) ?? addButton
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: anchor.bounds.height + 4), in: anchor)
    }

    @objc private func addFromMenu(_ item: NSMenuItem) {
        guard let table = Scope(rawValue: item.tag)?.table else { return }
        startRecording(.add(table))
    }

    @objc private func changeKey(_ sender: Any?) {
        guard let row = selectedRow, row.status != .removed, !isPending(row) else { return }
        startRecording(.change(row.table, row.spec))
    }

    func startAdding(to table: KeyTableID) { startRecording(.add(table)) }

    func startChangingKey(table: KeyTableID, spec: KeySpec) { startRecording(.change(table, spec)) }

    private func startRecording(_ intent: Recording) {
        cancelRecording()
        if window?.firstResponder is NSText { window?.makeFirstResponder(table) }
        recording = intent
        pendingKey = nil
        PrefixKeymap.shared.setShortcutRecordingActive(true)
        PaletteShortcuts.shared.setPaused(true, by: self)
        let target: String
        switch intent {
        case let .add(table): target = "a new \(Scope(table: table).title) binding"
        case let .change(table, spec):
            let command = readTables().table(table)?.lookup(spec)?.command.shortDescription ?? Self.keyText(spec)
            target = "“\(command)”"
        }
        show(message: "Press the key for \(target). Esc cancels.", isError: false)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, event.window === self.window else { return event }
            return self.handleRecordingKey(event) ? nil : event
        }
    }

    private func cancelRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        if recording != nil {
            PrefixKeymap.shared.setShortcutRecordingActive(false)
            PaletteShortcuts.shared.setPaused(false, by: self)
        }
        recording = nil
        pendingKey = nil
    }

    /// One key while recording. Returns whether the key was consumed.
    @discardableResult
    func handleRecordingKey(_ event: NSEvent) -> Bool {
        guard let intent = recording else { return false }
        if event.keyCode == 53 { // Escape
            cancelRecording()
            refreshButtons()
            return true
        }
        if event.keyCode == 36 || event.keyCode == 76, let pending = pendingKey { // Return confirms
            finishRecording(intent, spec: pending)
            return true
        }
        guard let spec = PrefixKeymap.makeSpec(from: event) else {
            show(message: "That key can't be bound. Try another.", isError: true)
            return true
        }
        var editing: KeySpec?
        if case let .change(_, current) = intent { editing = current }
        let issues = KeyBindingCheck.issues(
            table: intent.table, spec: spec, editing: editing, in: readTables(),
            isPrefixKey: intent.table == .root && isPrefixKey(spec),
            shadows: intent.table == .root ? shadowedByRoot(spec) : nil
        )
        let key = Self.keyText(spec)
        if let blocking = issues.first(where: \.isBlocking) {
            pendingKey = nil
            show(message: "\(key): \(Self.explain(blocking)) Press another key, or Esc.", isError: true)
            return true
        }
        if issues.isEmpty || spec == editing {
            finishRecording(intent, spec: spec)
            return true
        }
        pendingKey = spec
        let reasons = issues.map(Self.explain).joined(separator: " ")
        show(message: "\(key): \(reasons) Press Return to use it anyway, or another key.", isError: true)
        return true
    }

    static func explain(_ issue: KeyBindingIssue) -> String {
        switch issue {
        case .reservedPromptKey: return "the prefix then : always opens the command prompt."
        case .prefixKey: return "that's the prefix key. Change the prefix in Settings ▸ Keys first."
        case let .replaces(binding):
            return "already runs “\(binding.note ?? binding.command.shortDescription)”, which this replaces."
        case let .shadows(owner): return "is \(owner). This binding would run instead."
        case .swallowsTyping: return "without ⌃, ⌥ or ⌘ this key stops reaching the terminal."
        case .notCopyModeAction: return "copy mode keys only run copy-mode -X actions."
        }
    }

    private func finishRecording(_ intent: Recording, spec: KeySpec) {
        cancelRecording()
        switch intent {
        case let .change(table, from):
            guard spec != from else { return refreshButtons() }
            commit { $0.editorRebind(table, from: from, to: spec) }
            select(table: table, spec: spec)
        case let .add(table):
            pendingAdd = (table, spec)
            if let scopeTable = scope.table, scopeTable != table { setScope(Scope(table: table)) }
            search.stringValue = ""
            reload()
            select(table: table, spec: spec)
            show(message: "Choose or type the action for \(Self.keyText(spec)), then press Return.", isError: false)
            window?.makeFirstResponder(actionBox)
        }
    }

    private func select(table id: KeyTableID, spec: KeySpec) {
        guard let index = shown.firstIndex(where: { $0.table == id && $0.spec == spec }) else { return }
        table.selectRowIndexes([index], byExtendingSelection: false)
        table.scrollRowToVisible(index)
    }

    // MARK: - Editing actions

    /// Save the action typed or chosen for `row`. Returns whether it was saved.
    @discardableResult
    func commitAction(_ text: String, for row: KeyBindingRow) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let pending = isPending(row)
        guard !trimmed.isEmpty else {
            if pending { pendingAdd = nil; reload() }
            return false
        }
        if !pending, trimmed == row.commandText { return false }
        let command: Command
        do {
            command = try CommandParser.parse(trimmed)
        } catch {
            show(message: "Can't use “\(trimmed)”: \(error).", isError: true)
            return false
        }
        if !KeyBindingCheck.issues(table: row.table, command: command).isEmpty {
            show(message: "Copy mode keys only run copy-mode -X actions, such as copy-mode -X cursor-left.", isError: true)
            return false
        }
        pendingAdd = nil
        commit { $0.editorSet(row.table, spec: row.spec, command: command) }
        select(table: row.table, spec: row.spec)
        return true
    }

    @objc private func removeSelected(_ sender: Any?) {
        guard let row = selectedRow, row.status != .removed, !isPending(row) else { return }
        commit { $0.editorRemove(row.table, spec: row.spec) }
    }

    @objc private func resetSelected(_ sender: Any?) {
        guard let row = selectedRow else { return }
        if isPending(row) {
            pendingAdd = nil
            return reload()
        }
        reset(table: row.table, spec: row.spec)
    }

    func reset(table id: KeyTableID, spec: KeySpec) {
        commit { $0.editorReset(id, spec: spec) }
    }

    @objc private func confirmResetTable(_ sender: Any?) {
        guard let id = scope.table, let window else { return }
        let alert = NSAlert()
        alert.messageText = "Reset every \(scope.title) binding?"
        alert.informativeText = "Keys you added are removed and changed keys go back to their defaults."
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window) { [weak self] response in
            guard response == .alertFirstButtonReturn else { return }
            MainActor.assumeIsolated { self?.resetTable(id) }
        }
    }

    func resetTable(_ id: KeyTableID) {
        if pendingAdd?.table == id { pendingAdd = nil }
        commit { $0.editorResetTable(id) }
    }

    private func commit(_ change: (inout KeyTableSet) -> Void) {
        do {
            try applyEdit(change)
        } catch {
            show(message: "Couldn't save keybindings.json: \(error.localizedDescription)", isError: true)
        }
        reload()
    }

    // MARK: - Window

    private func build() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Key Bindings"
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.minSize = NSSize(width: 560, height: 360)
        window.delegate = self

        scopeControl.segmentCount = Scope.allCases.count
        for scope in Scope.allCases { scopeControl.setLabel(scope.title, forSegment: scope.rawValue) }
        scopeControl.selectedSegment = scope.rawValue
        scopeControl.target = self
        scopeControl.action = #selector(scopeChanged)
        scopeControl.setAccessibilityLabel("Key table")

        search.placeholderString = "Search keys and actions"
        search.delegate = self

        scopeNote.font = .systemFont(ofSize: 11)
        scopeNote.textColor = .secondaryLabelColor

        for (id, title, width) in [("key", "Key", 110.0), ("action", "Action", 330.0),
                                   ("table", "Table", 130.0), ("status", "Status", 80.0)] {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(id))
            column.title = title
            column.width = width
            table.addTableColumn(column)
        }
        table.usesAlternatingRowBackgroundColors = true
        table.style = .inset
        table.rowHeight = 24
        table.dataSource = self
        table.delegate = self
        table.target = self
        table.doubleAction = #selector(doubleClicked)
        table.setAccessibilityLabel("Key bindings")

        let scroll = NSScrollView()
        scroll.documentView = table
        scroll.hasVerticalScroller = true

        message.font = .systemFont(ofSize: 12)
        message.textColor = .secondaryLabelColor
        message.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        keyLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)
        actionBox.completes = true
        actionBox.numberOfVisibleItems = 14
        actionBox.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        actionBox.placeholderString = "Action, e.g. split-window -h"
        actionBox.delegate = self
        actionBox.target = self
        actionBox.action = #selector(actionEntered)
        actionBox.setAccessibilityLabel("Action")
        let detail = NSStackView(views: [keyLabel, actionBox])
        detail.orientation = .horizontal
        detail.spacing = 8

        configure(addButton, symbol: "plus", label: "Add Binding", action: #selector(addBinding(_:)))
        configure(removeButton, symbol: "minus", label: "Remove Binding", action: #selector(removeSelected(_:)))
        changeKeyButton.target = self
        changeKeyButton.action = #selector(changeKey(_:))
        resetButton.target = self
        resetButton.action = #selector(resetSelected(_:))
        resetTableButton.target = self
        resetTableButton.action = #selector(confirmResetTable(_:))
        for button in [changeKeyButton, resetButton, resetTableButton] { button.bezelStyle = .rounded }

        let spacer = NSView()
        spacer.setContentHuggingPriority(.init(1), for: .horizontal)
        let buttons = NSStackView(views: [addButton, removeButton, changeKeyButton, resetButton, spacer, resetTableButton])
        buttons.orientation = .horizontal
        buttons.spacing = 8

        let content = NSView()
        for view in [scopeControl, search, scopeNote, scroll, detail, message, buttons] as [NSView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(view)
        }
        NSLayoutConstraint.activate([
            scopeControl.topAnchor.constraint(equalTo: content.topAnchor, constant: 12),
            scopeControl.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            search.centerYAnchor.constraint(equalTo: scopeControl.centerYAnchor),
            search.leadingAnchor.constraint(equalTo: scopeControl.trailingAnchor, constant: 12),
            search.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
            search.widthAnchor.constraint(greaterThanOrEqualToConstant: 140),
            scopeNote.topAnchor.constraint(equalTo: scopeControl.bottomAnchor, constant: 8),
            scopeNote.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 14),
            scopeNote.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -14),
            scroll.topAnchor.constraint(equalTo: scopeNote.bottomAnchor, constant: 8),
            scroll.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            detail.topAnchor.constraint(equalTo: scroll.bottomAnchor, constant: 10),
            detail.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 14),
            detail.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
            message.topAnchor.constraint(equalTo: detail.bottomAnchor, constant: 6),
            message.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 14),
            message.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -14),
            buttons.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 8),
            buttons.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            buttons.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
            buttons.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -12),
        ])
        window.contentView = content
        return window
    }

    private func configure(_ button: NSButton, symbol: String, label: String, action: Selector) {
        button.bezelStyle = .rounded
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
        button.imagePosition = .imageOnly
        button.toolTip = label
        button.target = self
        button.action = action
    }

    @objc private func scopeChanged() {
        setScope(Scope(rawValue: scopeControl.selectedSegment) ?? .all)
    }

    @objc private func doubleClicked() {
        guard let row = shown.indices.contains(table.clickedRow) ? shown[table.clickedRow] : nil else { return }
        let column = table.clickedColumn >= 0 ? table.tableColumns[table.clickedColumn].identifier.rawValue : ""
        if column == "action", row.status != .removed {
            window?.makeFirstResponder(actionBox)
        } else if row.status != .removed, !isPending(row) {
            startRecording(.change(row.table, row.spec))
        }
    }

    func windowWillClose(_ notification: Notification) {
        cancelRecording()
        pendingAdd = nil
    }

    func windowDidResignKey(_ notification: Notification) {
        guard recording != nil else { return }
        cancelRecording()
        refreshButtons()
    }

    func controlTextDidChange(_ obj: Notification) {
        guard obj.object as? NSSearchField === search else { return }
        reload()
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        guard obj.object as? NSComboBox === actionBox else { return }
        commitActionField()
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        guard actionBox.indexOfSelectedItem >= 0,
              let value = actionBox.itemObjectValue(at: actionBox.indexOfSelectedItem) as? String else { return }
        actionBox.stringValue = value
    }

    @objc private func actionEntered() {
        commitActionField()
    }

    private func commitActionField() {
        guard let target = actionTarget,
              let row = shown.first(where: { $0.table == target.table && $0.spec == target.spec })
                ?? readTables().editorRows(in: target.table).first(where: { $0.spec == target.spec }),
              row.status != .removed
        else { return }
        let text = actionBox.stringValue
        if !commitAction(text, for: row), !isPending(row), text.trimmingCharacters(in: .whitespaces).isEmpty {
            actionBox.stringValue = row.commandText
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        refreshButtons()
    }

    func numberOfRows(in tableView: NSTableView) -> Int { shown.count }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier.rawValue, shown.indices.contains(row) else { return nil }
        let entry = shown[row]
        let removed = entry.status == .removed
        switch id {
        case "action":
            let pending = isPending(entry)
            let field = NSTextField(labelWithString: pending ? "Choose an action below" : entry.commandText)
            field.font = pending ? .systemFont(ofSize: 12) : .monospacedSystemFont(ofSize: 12, weight: .regular)
            field.textColor = removed || pending ? .tertiaryLabelColor : .labelColor
            field.lineBreakMode = .byTruncatingTail
            field.toolTip = entry.note
            return field
        case "key":
            let field = NSTextField(labelWithString: Self.keyText(entry.spec))
            field.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
            field.textColor = removed ? .tertiaryLabelColor : .labelColor
            field.toolTip = entry.spec.description
            return field
        case "table":
            let field = NSTextField(labelWithString: Scope(table: entry.table).title)
            field.textColor = .secondaryLabelColor
            return field
        default:
            let field = NSTextField(labelWithString: Self.statusText(entry.status))
            field.textColor = entry.status == .standard ? .tertiaryLabelColor : .secondaryLabelColor
            return field
        }
    }

    /// Commands offered in the action menu: every default action for the table, then for the
    /// command tables every bindable verb from the shared catalog.
    static func suggestions(for table: KeyTableID) -> [String] {
        var seen = Set<String>()
        var items: [String] = []
        func add(_ text: String) { if seen.insert(text).inserted { items.append(text) } }
        let copyTables: Set<KeyTableID> = [.copyMode, .copyModeEmacs]
        let sources: [KeyTableID] = copyTables.contains(table) ? [table] : [.prefix, .root]
        for id in sources {
            for binding in KeyTableSet.defaults.table(id)?.bindings ?? [] { add(binding.command.shortDescription) }
        }
        if !copyTables.contains(table) { CommandParser.knownVerbs.sorted().forEach(add) }
        return items
    }
}
