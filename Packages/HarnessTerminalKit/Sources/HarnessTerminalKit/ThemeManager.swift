import Foundation
import HarnessTheme

@MainActor
public enum ThemeManager {
    public static let defaultThemeName = HarnessThemeCatalog.defaultThemeName

    /// Dropdown entry representing the user's standard terminal baseline.
    /// Terminal output no longer consumes named theme palettes; themes are for
    /// Harness chrome only, so tools such as Claude Code keep their native colors.
    public static let defaultDisplayName = "Default"
    public static let defaultBaselineBackgroundHex = "#000000"
    public static let defaultBaselineForegroundHex = "#ffffff"
    /// Muted ANSI-16 defaults. Used for terminal *output* when theme→output
    /// recoloring is off (the default), so ANSI tools start from the same muted baseline
    /// instead of the hotter legacy xterm primaries.
    public static let defaultBaselinePaletteHex = [
        "#1d1f21", "#cc6666", "#b5bd68", "#f0c674",
        "#81a2be", "#b294bb", "#8abeb7", "#c5c8c6",
        "#666666", "#d54e53", "#b9ca4a", "#e7c547",
        "#7aa6da", "#c397d8", "#70c0b1", "#eaeaea",
    ]

    public static let featuredThemes = [
        HarnessThemeCatalog.defaultThemeName,
        "Catppuccin Mocha",
        "Dracula",
        "Tokyo Night",
        "Nord",
        "One Dark",
        "Gruvbox Dark",
        "Solarized Dark",
        "Monokai",
        "GitHub Dark",
    ]


    public static func backgroundHex(themeName: String) -> String? {
        if themeName == defaultDisplayName { return defaultBaselineBackgroundHex }
        return themed(themeName)?.backgroundHex
    }

    public static func foregroundHex(themeName: String) -> String? {
        if themeName == defaultDisplayName { return defaultBaselineForegroundHex }
        return themed(themeName)?.foregroundHex
    }

    public static func cursorHex(themeName: String) -> String? {
        if themeName == defaultDisplayName { return defaultBaselineForegroundHex }
        return themed(themeName)?.cursorHex
            ?? themed(themeName)?.foregroundHex
    }

    /// The background/foreground/cursor that define the shared canvas. The
    /// terminal surface and the app chrome (sidebar/tabs/status) both resolve
    /// through this so the canvas can never drift between regions.
    public struct ResolvedCanvas: Sendable, Equatable {
        public let backgroundHex: String
        public let foregroundHex: String
        public let cursorHex: String
    }

    /// Single source of truth for the canvas colors. Resolution order:
    /// explicit custom hex > named theme preset > black/white baseline.
    public static func resolvedCanvas(
        themeName: String,
        customBackgroundHex: String?,
        customForegroundHex: String?,
        customCursorHex: String?
    ) -> ResolvedCanvas {
        let bg = customBackgroundHex ?? backgroundHex(themeName: themeName) ?? defaultBaselineBackgroundHex
        let fg = customForegroundHex ?? foregroundHex(themeName: themeName) ?? defaultBaselineForegroundHex
        let cursor = customCursorHex ?? cursorHex(themeName: themeName) ?? fg
        return ResolvedCanvas(backgroundHex: bg, foregroundHex: fg, cursorHex: cursor)
    }

    public static func cursorTextHex(themeName: String) -> String? {
        if themeName == defaultDisplayName { return defaultBaselineBackgroundHex }
        return themed(themeName)?.cursorTextHex
            ?? themed(themeName)?.backgroundHex
    }

    public static func selectionBackgroundHex(themeName: String) -> String? {
        themed(themeName)?.selectionBackgroundHex
    }

    public static func selectionForegroundHex(themeName: String) -> String? {
        themed(themeName)?.selectionForegroundHex
    }

    /// Bold color is rarely set in themes; fall back to bright-white (palette 15) then
    /// the foreground so the preview swatch in Settings never reads as "missing".
    public static func boldHex(themeName: String) -> String? {
        guard let theme = themed(themeName) else { return nil }
        return theme.paletteHex[15] ?? theme.foregroundHex
    }

    /// 16 ANSI palette colors for settings preview swatches only. TerminalHostView
    /// does not apply these values to the renderer.
    public static func paletteHex(themeName: String) -> [String?] {
        if themeName == defaultDisplayName { return defaultBaselinePaletteHex }
        guard let theme = themed(themeName) else { return Array(repeating: nil, count: 16) }
        return theme.paletteHex
    }

    /// The complete editable color set a named theme contributes. Selecting a
    /// theme seeds these into `HarnessSettings`, after which the user may edit
    /// any of them — the theme is a starting preset, not a live override.
    public struct ThemePreset: Sendable, Equatable {
        public let backgroundHex: String?
        public let foregroundHex: String?
        public let cursorHex: String?
        public let cursorTextHex: String?
        public let selectionBackgroundHex: String?
        public let selectionForegroundHex: String?
        public let boldHex: String?
        public let paletteHex: [String?]
    }

    public static func presetColors(themeName: String) -> ThemePreset {
        ThemePreset(
            backgroundHex: backgroundHex(themeName: themeName),
            foregroundHex: foregroundHex(themeName: themeName),
            cursorHex: cursorHex(themeName: themeName),
            cursorTextHex: cursorTextHex(themeName: themeName),
            selectionBackgroundHex: selectionBackgroundHex(themeName: themeName),
            selectionForegroundHex: selectionForegroundHex(themeName: themeName),
            boldHex: boldHex(themeName: themeName),
            paletteHex: paletteHex(themeName: themeName)
        )
    }

    public static func allThemeNames() -> [String] {
        [defaultDisplayName]
            + featuredThemes
            + HarnessThemeCatalog.allThemes.map(\.name)
                .filter { !featuredThemes.contains($0) && $0 != defaultDisplayName }
    }

    private static func themed(_ name: String) -> HarnessThemeDefinition? {
        let resolved = (name == defaultDisplayName) ? defaultThemeName : name
        return HarnessThemeCatalog.theme(named: resolved) ?? HarnessThemeCatalog.theme(named: defaultThemeName)
    }
}
