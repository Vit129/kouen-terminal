import Foundation

// Ported (near-verbatim) from Packages/KouenCore/.../Format/FormatStyledSegment.swift.
// The single intermediate the status-line renderer consumes.

/// A renderer-agnostic color for `#[fg=…,bg=…]` style spans. `none` = surface default.
public enum FormatColor: Equatable, Sendable {
    case none
    case palette(Int)
    case rgb(r: UInt8, g: UInt8, b: UInt8)
}

/// One run of status text plus the style established by the `#[…]` directives in effect.
public struct StyledSegment: Equatable, Sendable {
    public var text: String
    public var fg: FormatColor?
    public var bg: FormatColor?
    public var bold: Bool
    public var italic: Bool
    public var underline: Bool
    public var reverse: Bool
    public var dim: Bool

    public init(text: String, fg: FormatColor? = nil, bg: FormatColor? = nil,
                bold: Bool = false, italic: Bool = false, underline: Bool = false,
                reverse: Bool = false, dim: Bool = false) {
        self.text = text; self.fg = fg; self.bg = bg
        self.bold = bold; self.italic = italic; self.underline = underline
        self.reverse = reverse; self.dim = dim
    }
}
