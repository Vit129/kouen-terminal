import Foundation

/// In-memory + UserDefaults MRU list for recently opened files.
/// Used by `:recent` workbench command.
@MainActor
final class WorkbenchMRU {
    static let shared = WorkbenchMRU()
    private static let defaultsKey = "KouenWorkbenchRecentFiles"
    private static let maxEntries = 20

    private(set) var entries: [String] = []

    private init() {
        entries = UserDefaults.standard.stringArray(forKey: Self.defaultsKey) ?? []
    }

    func add(_ path: String) {
        guard !path.isEmpty else { return }
        entries.removeAll { $0 == path }
        entries.insert(path, at: 0)
        if entries.count > Self.maxEntries { entries = Array(entries.prefix(Self.maxEntries)) }
        UserDefaults.standard.set(entries, forKey: Self.defaultsKey)
    }
}
