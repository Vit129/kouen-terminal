import Foundation

public enum HandoffNotePersistence {
    public static func save(_ note: String, to url: URL) -> Bool {
        (try? note.write(to: url, atomically: true, encoding: .utf8)) != nil
    }
}
