import Foundation

public enum PalettePersistence {
    private static let recentDefaultsKey = "com.vit129.kouen.palette.recent"

    public static func saveRecents(_ recents: [String]) {
        UserDefaults.standard.set(recents, forKey: recentDefaultsKey)
    }

    public static func loadRecents() -> [String] {
        UserDefaults.standard.stringArray(forKey: recentDefaultsKey) ?? []
    }

    public static func loadData(from url: URL) -> Data? {
        try? Data(contentsOf: url)
    }
}
