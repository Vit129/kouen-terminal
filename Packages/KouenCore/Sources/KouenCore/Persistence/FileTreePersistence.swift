import Foundation

public enum FileTreePersistence {
    public static func copyItem(at source: URL, to destination: URL) throws {
        try FileManager.default.copyItem(at: source, to: destination)
    }

    public static func trashItem(at url: URL) throws {
        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
    }

    public static func createFile(atPath path: String) -> Bool {
        FileManager.default.createFile(atPath: path, contents: nil)
    }

    public static func createDirectory(atPath path: String) throws {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
    }

    public static func moveItem(at source: URL, to destination: URL) throws {
        try FileManager.default.moveItem(at: source, to: destination)
    }

    public static func copyItem(atPath source: String, toPath destination: String) throws {
        try FileManager.default.copyItem(atPath: source, toPath: destination)
    }
}
