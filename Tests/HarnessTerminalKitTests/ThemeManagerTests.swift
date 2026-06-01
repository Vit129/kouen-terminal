import XCTest
import HarnessTheme
@testable import HarnessTerminalKit

final class ThemeManagerTests: XCTestCase {
    @MainActor
    func testDefaultBaselinePaletteMatchesMutedANSI16() {
        XCTAssertEqual(ThemeManager.defaultBaselinePaletteHex, [
            "#1d1f21", "#cc6666", "#b5bd68", "#f0c674",
            "#81a2be", "#b294bb", "#8abeb7", "#c5c8c6",
            "#666666", "#d54e53", "#b9ca4a", "#e7c547",
            "#7aa6da", "#c397d8", "#70c0b1", "#eaeaea",
        ])
        XCTAssertEqual(
            ThemeManager.paletteHex(themeName: ThemeManager.defaultDisplayName),
            ThemeManager.defaultBaselinePaletteHex
        )
    }

    @MainActor
    func testDefaultBaselineIsShippedTheme() {
        let theme = HarnessThemeCatalog.theme(named: ThemeManager.defaultThemeName)

        XCTAssertEqual(ThemeManager.defaultThemeName, "Harness Default")
        XCTAssertEqual(theme?.paletteHex, ThemeManager.defaultBaselinePaletteHex)
        XCTAssertEqual(ThemeManager.paletteHex(themeName: ThemeManager.defaultDisplayName), theme?.paletteHex)
    }
}
