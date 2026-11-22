import Foundation

public enum SidebarPinnedReposPersistence {
    public static func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: "kouen.sidebar.pinnedRepos") ?? []
    }

    public static func save(_ paths: [String]) {
        UserDefaults.standard.set(paths, forKey: "kouen.sidebar.pinnedRepos")
    }
}
