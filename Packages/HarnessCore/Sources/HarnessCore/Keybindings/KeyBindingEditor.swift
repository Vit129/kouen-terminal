import Foundation

/// One line of the key binding editor: a key in a table, what it runs, and how that differs
/// from the shipped default.
public struct KeyBindingRow: Equatable, Sendable {
    public enum Status: Equatable, Sendable {
        /// The shipped default, unchanged.
        case standard
        /// A default key that now runs a different command.
        case changed
        /// A key the user bound that has no default.
        case added
        /// A default the user unbound. Reset brings it back.
        case removed
    }

    public var table: KeyTableID
    public var spec: KeySpec
    /// What the key runs, or for a removed default, what it used to run.
    public var command: Command
    public var note: String?
    public var repeatable: Bool
    public var status: Status
    /// The default command for this key, when one ships.
    public var defaultCommand: Command?

    public init(
        table: KeyTableID, spec: KeySpec, command: Command, note: String?, repeatable: Bool,
        status: Status, defaultCommand: Command?
    ) {
        self.table = table
        self.spec = spec
        self.command = command
        self.note = note
        self.repeatable = repeatable
        self.status = status
        self.defaultCommand = defaultCommand
    }

    public var commandText: String { command.shortDescription }
    public var isResettable: Bool { status != .standard }
}

/// Why a key can't, or shouldn't without confirmation, take a binding in a table.
public enum KeyBindingIssue: Equatable, Sendable {
    /// `:` after the prefix always opens the command prompt, before the table is consulted.
    case reservedPromptKey
    /// The prefix key arms the prefix before the no-prefix table is consulted.
    case prefixKey
    /// Another binding in the same table answers this key and would be replaced.
    case replaces(Binding)
    /// A palette shortcut or menu item uses this key. No-prefix bindings run first.
    case shadows(String)
    /// A no-prefix key without ⌃, ⌥ or ⌘ would stop reaching the terminal.
    case swallowsTyping
    /// Copy mode tables only run `copy-mode -X` actions.
    case notCopyModeAction

    public var isBlocking: Bool {
        switch self {
        case .reservedPromptKey, .prefixKey, .notCopyModeAction: return true
        case .replaces, .shadows, .swallowsTyping: return false
        }
    }
}

public enum KeyBindingCheck {
    /// Problems with putting `spec` in `table`, blocking ones first. `editing` is the key the
    /// binding has now, so moving a binding onto itself is not a conflict. `isPrefixKey` and
    /// `shadows` come from the app, which owns the prefix setting, the palette and the menus.
    public static func issues(
        table: KeyTableID, spec: KeySpec, editing: KeySpec?, in tables: KeyTableSet,
        isPrefixKey: Bool, shadows: String?
    ) -> [KeyBindingIssue] {
        var issues: [KeyBindingIssue] = []
        if table == .prefix, spec.key == ":", spec.modifiers.isEmpty { issues.append(.reservedPromptKey) }
        if table == .root, isPrefixKey { issues.append(.prefixKey) }
        if let other = tables.conflict(in: table, spec: spec, excluding: editing) { issues.append(.replaces(other)) }
        if table == .root {
            if let shadows { issues.append(.shadows(shadows)) }
            if spec.modifiers.isDisjoint(with: [.control, .option, .command]) { issues.append(.swallowsTyping) }
        }
        return issues.filter(\.isBlocking) + issues.filter { !$0.isBlocking }
    }

    /// Problems with running `command` from `table`.
    public static func issues(table: KeyTableID, command: Command) -> [KeyBindingIssue] {
        guard table == .copyMode || table == .copyModeEmacs else { return [] }
        if case .copyModeCommand = command { return [] }
        return [.notCopyModeAction]
    }
}

/// The edits the key binding editor makes. Every edit lands in the same `KeyTableSet` that
/// `bind-key`, `unbind-key`, and `keybindings.json` use, so the editor, the CLI, and the file
/// never disagree. Defaults are passed in so tests can supply their own.
extension KeyTableSet {
    /// The tables the editor offers, in display order.
    public static let editableTables: [KeyTableID] = [.root, .prefix, .copyMode, .copyModeEmacs]

    public func editorRows(in id: KeyTableID, defaults: KeyTableSet = .defaults) -> [KeyBindingRow] {
        let table = table(id) ?? KeyTable(id: id)
        let shipped = defaults.table(id) ?? KeyTable(id: id)
        var rows = table.bindings.map { binding -> KeyBindingRow in
            let standard = shipped.lookup(binding.spec)
            let status: KeyBindingRow.Status = standard.map { $0.command == binding.command ? .standard : .changed } ?? .added
            return KeyBindingRow(
                table: id, spec: binding.spec, command: binding.command,
                note: binding.note ?? standard?.note, repeatable: binding.repeatable,
                status: status, defaultCommand: standard?.command
            )
        }
        for binding in shipped.bindings where table.isDisabled(binding.spec) && table.lookup(binding.spec) == nil {
            rows.append(KeyBindingRow(
                table: id, spec: binding.spec, command: binding.command, note: binding.note,
                repeatable: binding.repeatable, status: .removed, defaultCommand: binding.command
            ))
        }
        return rows
    }

    /// The binding that already answers `spec` in `id`, other than the one at `excluding`.
    public func conflict(in id: KeyTableID, spec: KeySpec, excluding: KeySpec? = nil) -> Binding? {
        guard spec != excluding else { return nil }
        return table(id)?.lookup(spec)
    }

    /// Bind `spec` to `command`, replacing whatever it ran. A note carries over only when the
    /// command is unchanged, so a stale description never labels a new action.
    public mutating func editorSet(_ id: KeyTableID, spec: KeySpec, command: Command, repeatable: Bool? = nil) {
        let existing = table(id)?.lookup(spec)
        let note = existing?.command == command ? existing?.note : nil
        setBinding(table: id, binding: Binding(
            spec: spec, command: command, note: note, repeatable: repeatable ?? existing?.repeatable ?? false
        ))
    }

    /// Move a binding to a new key. Whatever `to` ran is replaced.
    public mutating func editorRebind(_ id: KeyTableID, from: KeySpec, to: KeySpec, defaults: KeyTableSet = .defaults) {
        guard from != to, let binding = table(id)?.lookup(from) else { return }
        editorRemove(id, spec: from, defaults: defaults)
        setBinding(table: id, binding: Binding(spec: to, command: binding.command, note: binding.note, repeatable: binding.repeatable))
    }

    /// Unbind a key. A default stays unbound across launches. A key with no default is simply
    /// dropped, so the file doesn't collect tombstones for keys nothing would restore.
    public mutating func editorRemove(_ id: KeyTableID, spec: KeySpec, defaults: KeyTableSet = .defaults) {
        if defaults.table(id)?.lookup(spec) != nil {
            removeBinding(table: id, spec: spec)
        } else {
            mutateTable(id) { $0.forget(spec: spec) }
        }
    }

    /// Put one key back to its shipped state: the default binding, or unbound if none ships.
    public mutating func editorReset(_ id: KeyTableID, spec: KeySpec, defaults: KeyTableSet = .defaults) {
        if let standard = defaults.table(id)?.lookup(spec) {
            setBinding(table: id, binding: standard)
        } else {
            mutateTable(id) { $0.forget(spec: spec) }
        }
    }

    /// Put a whole table back to its shipped bindings.
    public mutating func editorResetTable(_ id: KeyTableID, defaults: KeyTableSet = .defaults) {
        let shipped = defaults.table(id) ?? KeyTable(id: id)
        if let index = tableList.firstIndex(where: { $0.id == id }) {
            tableList[index] = shipped
        } else {
            tableList.append(shipped)
        }
    }

    private mutating func mutateTable(_ id: KeyTableID, _ change: (inout KeyTable) -> Void) {
        guard let index = tableList.firstIndex(where: { $0.id == id }) else { return }
        change(&tableList[index])
    }
}
