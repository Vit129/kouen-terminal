import Foundation

public enum FloatingPanePreferences {
    public static var frame: String? {
        get { UserDefaults.standard.string(forKey: "FloatingPaneFrame") }
        set { UserDefaults.standard.set(newValue, forKey: "FloatingPaneFrame") }
    }
}
