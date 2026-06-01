import SwiftUI
import AppKit

/// Renders a `ComposedFrame` (produced by the genuine ported `GridCompositor`) into a
/// SwiftUI `Canvas` with the onboarding Catppuccin Mocha color. One monospaced glyph per cell,
/// background fills for non-default cells, a block cursor at the active position.
///
/// The frame is composed upstream and only changes when the demo data changes, so the
/// heavy glyph pass runs rarely; the cursor blink is the only periodic redraw.
struct ComposedTerminalView: View {
    let frame: ComposedFrame
    var fontSize: CGFloat = 12.5
    var resolver: CellColorResolver = MochaTheme.resolver
    var cornerRadius: CGFloat = ImmersivePalette.Radius.overlay

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var metrics: CellMetrics { CellMetrics(fontSize: fontSize) }
    private var pixelWidth: CGFloat { CGFloat(frame.cols) * metrics.width }
    private var pixelHeight: CGFloat { CGFloat(frame.rows) * metrics.height }

    var body: some View {
        Group {
            if reduceMotion {
                canvas(cursorOn: true)
            } else {
                TimelineView(.periodic(from: .now, by: 0.53)) { ctx in
                    let on = Int(ctx.date.timeIntervalSinceReferenceDate / 0.53) % 2 == 0
                    canvas(cursorOn: on)
                }
            }
        }
        .frame(width: pixelWidth, height: pixelHeight)
        .background(swiftColor(MochaTheme.background))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityElement()
        .accessibilityLabel("Harness terminal preview")
    }

    private func canvas(cursorOn: Bool) -> some View {
        let frame = self.frame
        let metrics = self.metrics
        let resolver = self.resolver
        return Canvas(opaque: false, rendersAsynchronously: false) { ctx, _ in
            // Resolve each unique (glyph, color, style) once per pass; many cells share styling.
            var textCache: [TextKey: GraphicsContext.ResolvedText] = [:]
            let cw = metrics.width, ch = metrics.height

            for row in 0 ..< frame.rows {
                for col in 0 ..< frame.cols {
                    let cell = frame.cells[row * frame.cols + col]
                    let colors = resolver.resolve(cell.asGridCell)
                    let x = CGFloat(col) * cw
                    let y = CGFloat(row) * ch
                    let rect = CGRect(x: x, y: y, width: cw, height: ch)

                    if colors.background != MochaTheme.background {
                        ctx.fill(Path(rect), with: .color(swiftColor(colors.background)))
                    }

                    let scalar = cell.scalar
                    if scalar.value != 0x20, !cell.invisible {
                        drawGlyph(scalar, in: ctx, at: CGPoint(x: x, y: y),
                                  fg: colors.foreground, cell: cell, metrics: metrics, cache: &textCache)
                    }

                    if cell.underline != .none {
                        let uy = y + ch - 1.5
                        ctx.stroke(Path { $0.move(to: CGPoint(x: x, y: uy)); $0.addLine(to: CGPoint(x: x + cw, y: uy)) },
                                   with: .color(swiftColor(colors.foreground)), lineWidth: 1)
                    }
                    if cell.strikethrough {
                        let sy = y + ch * 0.55
                        ctx.stroke(Path { $0.move(to: CGPoint(x: x, y: sy)); $0.addLine(to: CGPoint(x: x + cw, y: sy)) },
                                   with: .color(swiftColor(colors.foreground)), lineWidth: 1)
                    }
                }
            }

            // Block cursor: invert the cell (cursor color block + glyph painted in the bg color).
            if cursorOn, let cur = frame.cursor, cur.x >= 0, cur.x < frame.cols, cur.y >= 0, cur.y < frame.rows {
                let x = CGFloat(cur.x) * cw, y = CGFloat(cur.y) * ch
                let rect = CGRect(x: x, y: y, width: cw, height: ch)
                ctx.fill(Path(rect), with: .color(swiftColor(MochaTheme.cursor)))
                let cell = frame.cells[cur.y * frame.cols + cur.x]
                let scalar = cell.scalar
                if scalar.value != 0x20 {
                    drawGlyph(scalar, in: ctx, at: CGPoint(x: x, y: y),
                              fg: MochaTheme.background, cell: cell, metrics: metrics, cache: &textCache)
                }
            }
        }
    }

    private func drawGlyph(
        _ scalar: Unicode.Scalar,
        in ctx: GraphicsContext,
        at origin: CGPoint,
        fg: RGBColor,
        cell: ComposedCell,
        metrics: CellMetrics,
        cache: inout [TextKey: GraphicsContext.ResolvedText]
    ) {
        let key = TextKey(codepoint: scalar.value, fg: fg, bold: cell.bold, italic: cell.italic, dim: cell.dim)
        let resolved: GraphicsContext.ResolvedText
        if let cached = cache[key] {
            resolved = cached
        } else {
            var text = Text(String(scalar))
                .font(.system(size: fontSize, weight: cell.bold ? .bold : .regular, design: .monospaced))
                .foregroundColor(swiftColor(fg))
            if cell.italic { text = text.italic() }
            let r = ctx.resolve(text)
            cache[key] = r
            resolved = r
        }
        // Center the glyph horizontally in its cell column for crisp grid alignment.
        let size = resolved.measure(in: CGSize(width: metrics.width * 2, height: metrics.height))
        let gx = origin.x + (metrics.width - size.width) / 2
        let gy = origin.y + (metrics.height - size.height) / 2
        ctx.draw(resolved, at: CGPoint(x: gx, y: gy), anchor: .topLeading)
    }

    private func swiftColor(_ c: RGBColor) -> Color {
        Color(.sRGB,
              red: Double(c.red) / 255.0,
              green: Double(c.green) / 255.0,
              blue: Double(c.blue) / 255.0,
              opacity: Double(c.alpha) / 255.0)
    }
}

/// Cached monospaced cell metrics for a given point size.
private struct CellMetrics {
    let width: CGFloat
    let height: CGFloat

    init(fontSize: CGFloat) {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let advance = ("0" as NSString).size(withAttributes: [.font: font]).width
        width = max(1, advance.rounded())
        height = max(1, (font.ascender - font.descender + font.leading).rounded() + 2)
    }
}

private struct TextKey: Hashable {
    let codepoint: UInt32
    let fg: RGBColor
    let bold: Bool
    let italic: Bool
    let dim: Bool
}
