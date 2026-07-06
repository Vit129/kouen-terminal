import Foundation

// Ported (near-verbatim) from the Kouen monorepo so the onboarding can render genuine
// composed terminal frames with authentic color, with no dependency on the monorepo:
//   • RGBColor       — Packages/KouenTheme/.../Color/RGBColor.swift
//   • ANSIPalette    — Packages/KouenTerminalRenderer/.../ANSIPalette.swift
//   • CellColorResolver — Packages/KouenTerminalRenderer/.../CellColorResolver.swift
//   • MochaTheme     — inlined Catppuccin Mocha for the onboarding preview

/// A platform-independent 24-bit color with optional alpha.
public struct RGBColor: Equatable, Sendable, Hashable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
    }

    /// Parse `#rgb`, `#rrggbb`, or `#rrggbbaa` (leading `#` optional, case-insensitive).
    public init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.allSatisfy({ $0.isHexDigit }) else { return nil }
        switch s.count {
        case 3:
            let c = Array(s)
            guard let r = UInt8(String([c[0], c[0]]), radix: 16),
                  let g = UInt8(String([c[1], c[1]]), radix: 16),
                  let b = UInt8(String([c[2], c[2]]), radix: 16) else { return nil }
            self.init(red: r, green: g, blue: b)
        case 6:
            guard let v = UInt32(s, radix: 16) else { return nil }
            self.init(red: UInt8((v >> 16) & 0xFF), green: UInt8((v >> 8) & 0xFF), blue: UInt8(v & 0xFF))
        case 8:
            guard let v = UInt32(s, radix: 16) else { return nil }
            self.init(red: UInt8((v >> 24) & 0xFF), green: UInt8((v >> 16) & 0xFF),
                      blue: UInt8((v >> 8) & 0xFF), alpha: UInt8(v & 0xFF))
        default:
            return nil
        }
    }

    /// Linearly mix toward `other` by `fraction` (0 = self, 1 = other), per channel.
    public func blended(toward other: RGBColor, fraction: Double) -> RGBColor {
        let f = min(max(fraction, 0), 1)
        func mix(_ a: UInt8, _ b: UInt8) -> UInt8 { UInt8((Double(a) * (1 - f) + Double(b) * f).rounded()) }
        return RGBColor(red: mix(red, other.red), green: mix(green, other.green),
                        blue: mix(blue, other.blue), alpha: mix(alpha, other.alpha))
    }
}

/// The 256-entry ANSI color table: 0–15 theme base, 16–231 the 6×6×6 cube, 232–255 greys.
public struct ANSIPalette: Equatable, Sendable {
    public let colors: [RGBColor]

    public init(base16: [RGBColor]) {
        var table = [RGBColor](); table.reserveCapacity(256)
        for i in 0 ..< 16 { table.append(i < base16.count ? base16[i] : RGBColor(red: 0, green: 0, blue: 0)) }
        for r in 0 ..< 6 { for g in 0 ..< 6 { for b in 0 ..< 6 {
            table.append(RGBColor(red: Self.cubeLevel(r), green: Self.cubeLevel(g), blue: Self.cubeLevel(b)))
        }}}
        for i in 0 ..< 24 { let v = UInt8(8 + i * 10); table.append(RGBColor(red: v, green: v, blue: v)) }
        colors = table
    }

    public func color(at index: Int) -> RGBColor { colors[min(max(index, 0), 255)] }
    private static func cubeLevel(_ c: Int) -> UInt8 { c == 0 ? 0 : UInt8(55 + c * 40) }
}

public struct ResolvedCellColors: Equatable, Sendable {
    public var foreground: RGBColor
    public var background: RGBColor
}

/// Turns a cell's logical colors + attributes into final RGB, exactly the way mainstream
/// terminals do (base → bold-bright → faint → inverse → conceal).
public struct CellColorResolver: Sendable {
    public let palette: ANSIPalette
    public let defaultForeground: RGBColor
    public let defaultBackground: RGBColor
    public let boldBrightens: Bool
    public let faintFraction: Double

    public init(palette: ANSIPalette, defaultForeground: RGBColor, defaultBackground: RGBColor,
                boldBrightens: Bool = true, faintFraction: Double = 0.5) {
        self.palette = palette
        self.defaultForeground = defaultForeground
        self.defaultBackground = defaultBackground
        self.boldBrightens = boldBrightens
        self.faintFraction = faintFraction
    }

    public func resolve(_ cell: TerminalGridCell) -> ResolvedCellColors {
        var fg: RGBColor
        if boldBrightens, cell.bold, case let .palette(i) = cell.foreground, i < 8 {
            fg = palette.color(at: i + 8)
        } else {
            fg = resolved(cell.foreground, default: defaultForeground)
        }
        var bg = resolved(cell.background, default: defaultBackground)
        if cell.faint { fg = fg.blended(toward: bg, fraction: faintFraction) }
        if cell.inverse { swap(&fg, &bg) }
        if cell.invisible { fg = bg }
        return ResolvedCellColors(foreground: fg, background: bg)
    }

    public func resolved(_ color: TerminalGridColor, default fallback: RGBColor) -> RGBColor {
        switch color {
        case .none: return fallback
        case let .palette(i): return palette.color(at: i)
        case let .rgb(r, g, b): return RGBColor(red: r, green: g, blue: b)
        }
    }
}

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
