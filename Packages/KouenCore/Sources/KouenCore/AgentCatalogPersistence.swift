import Foundation

public enum AgentCatalogPersistence {
    public static func createStarterIfNeeded(at url: URL, contents: @autoclosure () -> String) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? contents().write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
