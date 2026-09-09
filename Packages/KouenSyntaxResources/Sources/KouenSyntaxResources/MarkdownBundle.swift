import Foundation

public enum MarkdownBundle {
    public static func resourceURL(filename: String) -> URL? {
        let ext = (filename as NSString).pathExtension
        let name = (filename as NSString).deletingPathExtension
        return Bundle.module.url(
            forResource: name,
            withExtension: ext.isEmpty ? nil : ext,
            subdirectory: "Markdown"
        )
    }

    public static func resourceURL(named name: String, withExtension ext: String) -> URL? {
        Bundle.module.url(
            forResource: name,
            withExtension: ext,
            subdirectory: "Markdown"
        )
    }

    public static func scriptString(filename: String) -> String? {
        guard let url = resourceURL(filename: filename) else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
