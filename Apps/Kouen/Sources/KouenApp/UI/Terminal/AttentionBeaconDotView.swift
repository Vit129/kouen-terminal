import AppKit
import SwiftUI

/// An animated breathing amber beacon for tabs waiting on user attention/approval.
/// Runs entirely on the CoreAnimation render server via `CALayer` (scale + opacity animations),
/// completely off the SwiftUI ViewGraph to guarantee 0% CPU overhead during continuous animation.
struct AttentionBeaconDotView: NSViewRepresentable {
    let isWaiting: Bool
    let color: NSColor

    func makeNSView(context: Context) -> BeaconView {
        BeaconView()
    }

    func updateNSView(_ view: BeaconView, context: Context) {
        view.apply(isWaiting: isWaiting, color: color)
    }

    final class BeaconView: NSView {
        private static let pulseScaleKey = "beacon-scale-pulse"
        private static let pulseOpacityKey = "beacon-opacity-pulse"

        private let halo = CALayer()
        private let dot = CALayer()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.masksToBounds = false

            // Outer pulsing halo (centered on 6x6 footprint: 16x16 with offset -5, -5)
            halo.frame = CGRect(x: -5, y: -5, width: 16, height: 16)
            halo.cornerRadius = 8
            halo.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.45).cgColor
            layer?.addSublayer(halo)

            // Inner solid 6x6 status dot
            dot.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
            dot.cornerRadius = 3
            dot.backgroundColor = NSColor.systemOrange.cgColor
            layer?.addSublayer(dot)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func apply(isWaiting: Bool, color: NSColor) {
            dot.backgroundColor = color.cgColor
            halo.backgroundColor = color.withAlphaComponent(0.40).cgColor
            halo.isHidden = !isWaiting

            let shouldAnimate = isWaiting && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            guard shouldAnimate else {
                halo.removeAnimation(forKey: Self.pulseScaleKey)
                halo.removeAnimation(forKey: Self.pulseOpacityKey)
                return
            }

            if halo.animation(forKey: Self.pulseScaleKey) == nil {
                let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
                scaleAnim.fromValue = 0.85
                scaleAnim.toValue = 1.60
                scaleAnim.duration = 1.1
                scaleAnim.autoreverses = true
                scaleAnim.repeatCount = .infinity
                scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                halo.add(scaleAnim, forKey: Self.pulseScaleKey)
            }

            if halo.animation(forKey: Self.pulseOpacityKey) == nil {
                let opacityAnim = CABasicAnimation(keyPath: "opacity")
                opacityAnim.fromValue = 0.80
                opacityAnim.toValue = 0.15
                opacityAnim.duration = 1.1
                opacityAnim.autoreverses = true
                opacityAnim.repeatCount = .infinity
                opacityAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                halo.add(opacityAnim, forKey: Self.pulseOpacityKey)
            }
        }
    }
}
