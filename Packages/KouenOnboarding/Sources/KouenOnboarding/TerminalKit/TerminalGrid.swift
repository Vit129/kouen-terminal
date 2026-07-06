import Foundation

// Ported (trimmed) from Packages/KouenTerminalEngine/.../Model/TerminalGridModel.swift.
// Image placements and OSC color-query roles are dropped — the onboarding only needs
// text cells + cursor.

/// A cell color. `none` = surface default; `palette` = ANSI 0–255; `rgb` = truecolor.
public enum TerminalGridColor: Equatable, Sendable {
    case none
    case palette(Int)
    case rgb(r: UInt8, g: UInt8, b: UInt8)
}

public enum TerminalGridUnderline: Equatable, Sendable {
    case none, single, double, curly, dotted, dashed
}

/// Column footprint of a cell. `wide` leads a double-width glyph; `spacerTail` is its
/// reserved empty trailing column.
public enum TerminalCellWidth: Equatable, Sendable {
    case normal, wide, spacerTail
}

/// A single grid cell: one glyph plus its full SGR attribute set.
public struct TerminalGridCell: Equatable, Sendable {
    public var codepoint: UInt32
    public var foreground: TerminalGridColor
    public var background: TerminalGridColor
    public var underlineColor: TerminalGridColor
    public var bold: Bool
    public var faint: Bool
    public var italic: Bool
    public var underline: TerminalGridUnderline
    public var blink: Bool
    public var inverse: Bool
    public var invisible: Bool
    public var strikethrough: Bool
    public var overline: Bool
    public var width: TerminalCellWidth

    public init(
        codepoint: UInt32 = 0,
        foreground: TerminalGridColor = .none,
        background: TerminalGridColor = .none,
        underlineColor: TerminalGridColor = .none,
        bold: Bool = false,
        faint: Bool = false,
        italic: Bool = false,
        underline: TerminalGridUnderline = .none,
        blink: Bool = false,
        inverse: Bool = false,
        invisible: Bool = false,
        strikethrough: Bool = false,
        overline: Bool = false,
        width: TerminalCellWidth = .normal
    ) {
        self.codepoint = codepoint
        self.foreground = foreground
        self.background = background
        self.underlineColor = underlineColor
        self.bold = bold
        self.faint = faint
        self.italic = italic
        self.underline = underline
        self.blink = blink
        self.inverse = inverse
        self.invisible = invisible
        self.strikethrough = strikethrough
        self.overline = overline
        self.width = width
    }

    public static let blank = TerminalGridCell()
}

public enum TerminalCursorShape: Sendable, Equatable {
    case `default`, block, underline, bar
}

public struct TerminalCursor: Equatable, Sendable {
    public var row: Int
    public var col: Int
    public var visible: Bool
    public var shape: TerminalCursorShape
    public var blinking: Bool?

    public init(row: Int = 0, col: Int = 0, visible: Bool = true,
                shape: TerminalCursorShape = .default, blinking: Bool? = nil) {
        self.row = row; self.col = col; self.visible = visible; self.shape = shape; self.blinking = blinking
    }
}

/// An immutable snapshot of a screen: a `cols × rows` row-major cell array plus the cursor.
public struct TerminalGridSnapshot: Equatable, Sendable {
    public let cols: Int
    public let rows: Int
    public let cells: [TerminalGridCell]
    public let cursor: TerminalCursor

    public init(cols: Int, rows: Int, cells: [TerminalGridCell], cursor: TerminalCursor) {
        self.cols = cols; self.rows = rows; self.cells = cells; self.cursor = cursor
    }

    public func cell(row: Int, col: Int) -> TerminalGridCell? {
        guard row >= 0, row < rows, col >= 0, col < cols else { return nil }
        return cells[row * cols + col]
    }
}
