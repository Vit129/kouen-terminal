import AppKit
import QuartzCore

/// GPU-driven notch shape animation via CAShapeLayer + CABasicAnimation path morphing.
///
/// Replaces SwiftUI AnimatableFrameAttribute (fires per display frame on the main thread)
/// with a render-server-side path animation — the same model Zed (GPUI) and Otty (Metal)
/// use: layout is computed once on state change; paint runs entirely on the GPU.
///
/// Shadow: NotchPanel.hasShadow = true lets WindowServer cast shadow from opaque pixels.
/// The mask zeroes alpha outside the notch shape, so shadow follows the animated outline
/// automatically — no separate shadow layer needed.
@MainActor
final class NotchMaskAnimator {
    private let mask = CAShapeLayer()
    private var lastRect: CGRect = .null

    func install(on hostingView: NSView) {
        hostingView.wantsLayer = true
        hostingView.layer?.mask = mask
    }

    /// Animate (or snap) the mask to `rect`. Idempotent: no-op if rect is unchanged.
    func update(to rect: CGRect, topRadius: CGFloat, bottomRadius: CGFloat,
                isOpening: Bool, reduceMotion: Bool, animated: Bool) {
        guard rect != lastRect else { return }
        lastRect = rect

        let target = NotchShape.cgPath(in: rect, topRadius: topRadius, bottomRadius: bottomRadius)
        let from = mask.presentation()?.path ?? mask.path
        mask.path = target

        guard animated, let from else { return }

        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = from
        anim.toValue = target

        if reduceMotion {
            anim.duration = 0.12
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        } else if isOpening {
            // Approximates .spring(response: 0.38, dampingFraction: 0.8) — fast, slight ease-back
            anim.duration = 0.40
            anim.timingFunction = CAMediaTimingFunction(controlPoints: 0.22, 0.97, 0.09, 1.0)
        } else {
            // Approximates .spring(response: 0.45, dampingFraction: 1.0) — overdamped, no bounce
            anim.duration = 0.32
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }

        mask.add(anim, forKey: "notch-shape")
    }
}
