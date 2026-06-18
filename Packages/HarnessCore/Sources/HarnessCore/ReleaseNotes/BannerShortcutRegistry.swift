import Foundation

/// Single source of truth for shortcuts displayed on the welcome banner.
/// `MainMenuBuilder` reads these to keep menu key equivalents in sync.
public struct BannerShortcut: Codable, Sendable {
    public let key: String
    public let description: String
    /// Whether to show this shortcut on the welcome banner.
    public let showInBanner: Bool

    public init(key: String, description: String, showInBanner: Bool = true) {
        self.key = key
        self.description = description
        self.showInBanner = showInBanner
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        key = try c.decode(String.self, forKey: .key)
        description = try c.decode(String.self, forKey: .description)
        showInBanner = try c.decodeIfPresent(Bool.self, forKey: .showInBanner) ?? true
    }

    private enum CodingKeys: String, CodingKey {
        case key, description, showInBanner
    }
}

public enum BannerShortcutRegistry {
    /// All registered shortcuts. Menu builders and the terminal banner both read from here.
    public static let shortcuts: [BannerShortcut] = [
        .init(key: "⌘⇧N / ⌘⇧W",      description: "new / close session"),
        .init(key: "⌘D / ⌘⇧D",       description: "split right / split down"),
        .init(key: "⌘W / ⌘⇧W",       description: "close pane / close tab"),
        .init(key: "⌘[ / ⌘]",        description: "previous / next pane"),
        .init(key: "⌘⇧[ / ⌘⇧]",     description: "previous / next session"),
        .init(key: "⌘← / ⌘→",       description: "reorder session in tab bar"),
        .init(key: "⌘1 … ⌘9",        description: "switch to session 1–9"),
        .init(key: "⌘P",              description: "fuzzy file search"),
        .init(key: "⌘F",              description: "find in files"),
        .init(key: "⌘B",              description: "browser pane"),
        .init(key: "⌘;",              description: "command prompt · try: find, grep, cd"),
        .init(key: "⌘\\",             description: "toggle sidebar"),
        .init(key: "harness-cli ping", description: "script Harness from any shell"),
    ]

    /// Only shortcuts flagged for the banner.
    public static var bannerShortcuts: [BannerShortcut] {
        shortcuts.filter(\.showInBanner)
    }
}
