import Foundation

public enum FileEditorPersistence {
    public static func load(from url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    public static func save(_ text: String, to path: String) {
        try? text.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
