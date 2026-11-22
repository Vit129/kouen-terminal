import Foundation

public enum ProjectDirectoryPersistence {
    public static func defaults(suiteName: String) -> UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    public static func data(_ defaults: UserDefaults, forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    public static func stringArray(_ defaults: UserDefaults, forKey key: String) -> [String]? {
        defaults.stringArray(forKey: key)
    }

    public static func set(_ defaults: UserDefaults, _ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    public static var isExpanded: Bool {
        get { UserDefaults.standard.bool(forKey: "ProjectDirectoryTreeExpanded") }
        set { UserDefaults.standard.set(newValue, forKey: "ProjectDirectoryTreeExpanded") }
    }

    public static var hasExpandedPreference: Bool {
        UserDefaults.standard.object(forKey: "ProjectDirectoryTreeExpanded") != nil
    }
}
