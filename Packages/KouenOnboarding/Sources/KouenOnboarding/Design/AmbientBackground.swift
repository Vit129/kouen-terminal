import SwiftUI

/// A moving monochrome glass field: visible drift, soft refraction bands, and fine grain.
/// It stays calm, but no longer reads as a static black dimmer.
struct AmbientBackground: View {
    var reduceMotion: Bool = false

    var body: some View {
        ZStack {
            if reduceMotion {
                Canvas { ctx, size in Self.drawField(ctx, size, t: 0) }
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    Canvas { ctx, size in
                        Self.drawField(ctx, size, t: timeline.date.timeIntervalSinceReferenceDate)
                    }
                }
            }

            Canvas { ctx, size in Self.drawGrain(ctx, size) }
                .blendMode(.softLight)
                .opacity(0.34)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private static func drawField(_ ctx: GraphicsContext, _ size: CGSize, t: TimeInterval) {
        let rect = CGRect(origin: .zero, size: size)
        ctx.fill(Rectangle().path(in: rect), with: .color(grey(0x09)))

        let base = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [grey(0x30), grey(0x16), grey(0x08)]),
            startPoint: CGPoint(x: size.width * 0.04, y: size.height * 0.05),
            endPoint: CGPoint(x: size.width * 0.94, y: size.height * 0.92)
        )
        ctx.fill(Rectangle().path(in: rect), with: base)

        let blobs: [(phase: Double, center: CGPoint, amp: CGSize, radius: CGFloat, alpha: Double)] = [
            (0.0, CGPoint(x: size.width * 0.26, y: size.height * 0.25), CGSize(width: size.width * 0.18, height: size.height * 0.10), size.width * 0.48, 0.34),
            (1.4, CGPoint(x: size.width * 0.72, y: size.height * 0.34), CGSize(width: size.width * 0.14, height: size.height * 0.16), size.width * 0.44, 0.24),
            (3.0, CGPoint(x: size.width * 0.44, y: size.height * 0.78), CGSize(width: size.width * 0.22, height: size.height * 0.10), size.width * 0.56, 0.22),
        ]

        for blob in blobs {
            let x = blob.center.x + cos(t * 0.075 + blob.phase) * blob.amp.width
            let y = blob.center.y + sin(t * 0.058 + blob.phase) * blob.amp.height
            let blobRect = CGRect(x: x - blob.radius, y: y - blob.radius, width: blob.radius * 2, height: blob.radius * 2)
            let shading = GraphicsContext.Shading.radialGradient(
                Gradient(colors: [.white.opacity(blob.alpha), .white.opacity(blob.alpha * 0.18), .clear]),
                center: CGPoint(x: x, y: y),
                startRadius: 0,
                endRadius: blob.radius
            )
            ctx.fill(Ellipse().path(in: blobRect), with: shading)
        }

        for i in 0..<3 {
            let phase = t * 0.045 + Double(i) * 1.9
            let x = size.width * (0.12 + 0.18 * CGFloat(i)) + cos(phase) * size.width * 0.08
            let band = CGRect(x: x, y: -size.height * 0.2, width: size.width * 0.18, height: size.height * 1.4)
            var transform = CGAffineTransform(translationX: band.midX, y: band.midY)
            transform = transform.rotated(by: -0.45)
            transform = transform.translatedBy(x: -band.midX, y: -band.midY)
            let path = Path(CGPath(rect: band, transform: &transform))
            ctx.fill(path, with: .linearGradient(
                Gradient(colors: [.clear, .white.opacity(0.055), .clear]),
                startPoint: CGPoint(x: band.minX, y: band.minY),
                endPoint: CGPoint(x: band.maxX, y: band.maxY)
            ))
        }

        let vignette = GraphicsContext.Shading.radialGradient(
            Gradient(colors: [.clear, .black.opacity(0.55)]),
            center: CGPoint(x: size.width * 0.5, y: size.height * 0.48),
            startRadius: min(size.width, size.height) * 0.26,
            endRadius: max(size.width, size.height) * 0.78
        )
        ctx.fill(Rectangle().path(in: rect), with: vignette)
    }

    private static func drawGrain(_ ctx: GraphicsContext, _ size: CGSize) {
        let spacing: CGFloat = 5
        var seed: UInt64 = 0x9E3779B97F4A7C15
        func rand() -> Double {
            seed ^= seed << 13
            seed ^= seed >> 7
            seed ^= seed << 17
            return Double(seed % 1000) / 1000.0
        }

        var y: CGFloat = 0
        while y < size.height {
            var x: CGFloat = 0
            while x < size.width {
                let r = rand()
                if r > 0.62 {
                    ctx.fill(Rectangle().path(in: CGRect(x: x, y: y, width: 1, height: 1)),
                             with: .color(.white.opacity(0.010 + r * 0.020)))
                }
                x += spacing
            }
            y += spacing
        }
    }

    private static func grey(_ value: UInt8) -> Color {
        Color(.sRGB,
              red: Double(value) / 255.0,
              green: Double(value) / 255.0,
              blue: Double(value) / 255.0,
              opacity: 1)
    }
}
