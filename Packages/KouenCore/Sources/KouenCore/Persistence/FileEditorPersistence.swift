import Foundation

public enum FileEditorPersistence {
    public static func saveState(visible: Bool, paths: [String], activePath: String?) {
        UserDefaults.standard.set(visible, forKey: "kouen.fileEditorVisible")
        UserDefaults.standard.set(paths, forKey: "kouen.fileEditorPaths")
        if let activePath {
            UserDefaults.standard.set(activePath, forKey: "kouen.fileEditorActivePath")
        } else {
            UserDefaults.standard.removeObject(forKey: "kouen.fileEditorActivePath")
        }
    }

    public static func loadState() -> (visible: Bool, paths: [String], activePath: String?) {
        (UserDefaults.standard.bool(forKey: "kouen.fileEditorVisible"),
         UserDefaults.standard.stringArray(forKey: "kouen.fileEditorPaths") ?? [],
         UserDefaults.standard.string(forKey: "kouen.fileEditorActivePath"))
    }

    public static func load(from url: URL) -> Data? {
        try? Data(contentsOf: url)
    }

    public static func save(_ text: String, to path: String) {
        try? text.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
