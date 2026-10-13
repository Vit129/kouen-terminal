/// The theme colors and font fields Settings' Revert restores. Every other setting saves as it
/// changes and is left alone.
public struct ThemeAndFontSnapshot: Sendable {
    private let source: HarnessSettings

    public init(_ settings: HarnessSettings) {
        source = settings
    }

    public func restore(into settings: inout HarnessSettings) {
        settings.appearanceMode = source.appearanceMode
        settings.systemLightThemeName = source.systemLightThemeName
        settings.systemDarkThemeName = source.systemDarkThemeName
        settings.customBackgroundHex = source.customBackgroundHex
        settings.customForegroundHex = source.customForegroundHex
        settings.customCursorHex = source.customCursorHex
        settings.selectionBackgroundHex = source.selectionBackgroundHex
        settings.selectionForegroundHex = source.selectionForegroundHex
        settings.boldColorHex = source.boldColorHex
        settings.cursorTextHex = source.cursorTextHex
        settings.paletteHex = source.paletteHex
        settings.dividerHex = source.dividerHex
        settings.statusLineHex = source.statusLineHex
        settings.fontFamily = source.fontFamily
        settings.fontFallbackFamilies = source.fontFallbackFamilies
        settings.fontFeatures = source.fontFeatures
        settings.fontSize = source.fontSize
        settings.lineHeight = source.lineHeight
        settings.cellWidth = source.cellWidth
        settings.ligatures = source.ligatures
        settings.textRendering = source.textRendering
    }

    /// Whether `settings` already has every field this snapshot restores.
    public func matches(_ settings: HarnessSettings) -> Bool {
        var restored = settings
        restore(into: &restored)
        return restored == settings
    }
}
