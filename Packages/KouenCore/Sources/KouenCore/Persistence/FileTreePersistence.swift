import Foundation

public enum FileTreePersistence {
    public static func copyItem(at source: URL, to destination: URL) throws {
        try FileManager.default.copyItem(at: source, to: destination)
    }
}
