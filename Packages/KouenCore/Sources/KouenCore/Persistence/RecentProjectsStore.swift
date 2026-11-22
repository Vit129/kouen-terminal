import Foundation

public enum RecentProjectsStore {
    private static let key = "RecentProjectPaths"
    private static let maximumCount = 10

    public static func load(defaults: UserDefaults = .standard) -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    public static func record(_ path: String, defaults: UserDefaults = .standard) {
        var recents = load(defaults: defaults)
        recents.removeAll { $0 == path }
        recents.insert(path, at: 0)
        if recents.count > maximumCount { recents = Array(recents.prefix(maximumCount)) }
        defaults.set(recents, forKey: key)
    }
}
