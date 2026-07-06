import AppKit
import QuartzCore

/// Lightweight visual effects helpers (shadows, etc.) that match the Kouen
/// "elevation" language. Used by glass cards, buttons, and future step content.
/// No dependency on the main app — values tuned for the dark terminal glass.
enum ImmersiveEffects {
    /// Applies a soft, layered shadow suitable for elevated glass cards on a
    /// dark desktop. Matches the "elevation2" feel from KouenDesign.
    static func applyCardShadow(to layer: CALayer?) {
        guard let layer else { return }
        layer.shadowColor = NSColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowPath = nil   // let the system derive from bounds + corner radius
    }

    /// Subtle rim / keyline shadow used on the main immersive panel itself.
    static func applyPanelShadow(to layer: CALayer?) {
        guard let layer else { return }
        layer.shadowColor = NSColor.black.cgColor
        layer.shadowOpacity = 0.45
        layer.shadowRadius = 32
        layer.shadowOffset = CGSize(width: 0, height: 22)
    }
}