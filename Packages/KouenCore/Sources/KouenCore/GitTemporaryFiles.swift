import Foundation

public enum GitTemporaryFiles {
    public static func createDirectory(atPath path: String) {
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
    }

    public static func write(_ contents: String, to path: String) throws {
        try contents.write(toFile: path, atomically: true, encoding: .utf8)
    }

    public static func removeItem(atPath path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}
