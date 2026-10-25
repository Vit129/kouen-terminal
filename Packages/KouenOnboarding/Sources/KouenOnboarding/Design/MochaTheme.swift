import Foundation
import KouenTerminalRenderer
import KouenTheme

/// Catppuccin Mocha — the onboarding preview theme. Background/foreground + the 16 base
/// ANSI colors that feed `ANSIPalette`. The one vivid focal point against the monochrome chrome.
public enum MochaTheme {
    public static let background = RGBColor(hex: "#1e1e2e")!
    public static let foreground = RGBColor(hex: "#cdd6f4")!
    public static let cursor = RGBColor(hex: "#f5e0dc")!

    public static let palette: [RGBColor] = [
        "#45475a", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#bac2de",
        "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#a6adc8",
    ].map { RGBColor(hex: $0)! }

    public static let resolver = CellColorResolver(
        palette: ANSIPalette(base16: palette),
        defaultForeground: foreground,
        defaultBackground: background
    )
}
