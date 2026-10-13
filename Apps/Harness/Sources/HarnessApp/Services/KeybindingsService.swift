import Foundation
import HarnessCore

/// App-side cache of the user's key tables. Loaded from
/// `~/Library/Application Support/Harness/keybindings.json` on launch (with
/// defaults from `KeyTableSet.defaults` merged in), saved on every mutation.
@MainActor
final class KeybindingsService {
    static let shared = KeybindingsService()

    /// Posted whenever `tables` changes: an editor edit, `bind-key`, or a reload of the file.
    static let didChange = Notification.Name("HarnessKeybindingsDidChange")

    private(set) var tables: KeyTableSet {
        didSet {
            if tables != oldValue { NotificationCenter.default.post(name: Self.didChange, object: self) }
        }
    }

    private init() {
        tables = KeybindingsStore.load()
    }

    /// Apply an edit and save it. Memory only changes once the file is written.
    func edit(_ change: (inout KeyTableSet) -> Void) throws {
        var next = tables
        change(&next)
        guard next != tables else { return }
        try KeybindingsStore.save(next)
        tables = next
    }

    func reload() {
        tables = KeybindingsStore.load()
    }

    func lookup(table: KeyTableID, spec: KeySpec) -> Binding? {
        tables.table(table)?.lookup(spec)
    }

    func bindings(in table: KeyTableID) -> [Binding] {
        tables.table(table)?.bindings ?? []
    }

    /// Bind a key. Parses the textual spec (`C-a`, `Up`, …) here so callers
    /// (the `:` prompt, hooks, `bind-key` CLI) all share the same parser.
    func bind(table: KeyTableID, specRaw: String, command: Command, repeatable: Bool = false) throws {
        guard let spec = KeySpec.parse(specRaw) else {
            throw CommandExecutionError.unsupportedInThisContext("invalid key spec: \(specRaw)")
        }
        tables.setBinding(table: table, binding: Binding(spec: spec, command: command, repeatable: repeatable))
        try KeybindingsStore.save(tables)
    }

    func unbind(table: KeyTableID, specRaw: String) throws {
        guard let spec = KeySpec.parse(specRaw) else {
            throw CommandExecutionError.unsupportedInThisContext("invalid key spec: \(specRaw)")
        }
        tables.removeBinding(table: table, spec: spec)
        try KeybindingsStore.save(tables)
    }

    /// Human-readable dump of one or all tables (used by `list-keys` /
    /// `display-message`). Returns a single string with one binding per line.
    func summary(table: KeyTableID? = nil) -> String {
        let chosen = table.map { [$0] } ?? tables.tableList.map(\.id)
        var lines: [String] = []
        for id in chosen {
            guard let table = tables.table(id), !table.bindings.isEmpty else { continue }
            lines.append("[\(id.rawValue)]")
            for binding in table.bindings {
                let note = binding.note.map { " — \($0)" } ?? ""
                lines.append("  \(binding.spec.description.padding(toLength: 16, withPad: " ", startingAt: 0))\(binding.command.shortDescription)\(note)")
            }
        }
        return lines.joined(separator: "\n")
    }
}
