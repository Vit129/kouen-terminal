import Foundation

public enum CommandHistoryPersistence {
    private static var historyURL: URL {
        KouenPaths.applicationSupport.appendingPathComponent("command-history.json")
    }

    public static func load() -> [String]? {
        guard let data = try? Data(contentsOf: historyURL),
              let saved = try? JSONDecoder().decode([String].self, from: data) else { return nil }
        return saved
    }

    public static func save(_ history: [String]) {
        try? KouenPaths.ensureDirectories()
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: historyURL, options: .atomic)
        }
    }
}
