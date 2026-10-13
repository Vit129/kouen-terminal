import AppKit
import HarnessCore

extension ChromeAccessibility {
    /// The live macOS display accommodations. Observe
    /// `NSWorkspace.accessibilityDisplayOptionsDidChangeNotification` to follow changes.
    @MainActor
    public static var system: ChromeAccessibility {
        let workspace = NSWorkspace.shared
        return ChromeAccessibility(
            reduceTransparency: workspace.accessibilityDisplayShouldReduceTransparency,
            increaseContrast: workspace.accessibilityDisplayShouldIncreaseContrast
        )
    }
}
