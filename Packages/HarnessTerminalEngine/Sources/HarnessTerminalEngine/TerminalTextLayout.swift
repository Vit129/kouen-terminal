/// Literal single-row text using the terminal's pinned clustering and script tailoring.
/// Escape/control scalars are never interpreted as terminal commands.
public struct TerminalTextLayout: Sendable {
    public let cells: [TerminalGridCell]
    public let clusters: [UInt32: String]

    public init(text: String, columns: Int) {
        guard columns > 0, !text.isEmpty else { cells = []; clusters = [:]; return }
        let limit = min(columns, TerminalGeometry.maxDimension)
        // Spare columns let a narrow base become a wide emoji before clipping is decided.
        // The second row catches overflow when the requested width already reaches the cap.
        let screen = TerminalScreen(cols: min(limit + 2, TerminalGeometry.maxDimension), rows: 2)
        for scalar in text.unicodeScalars.prefix(65_536) {
            screen.print(scalar.value)
            if screen.cursorRow > 0 || screen.cursorCol > limit { break }
        }
        let snapshot = screen.snapshot()
        var visible = Array(snapshot.cells.prefix(limit))
        if visible.last?.width == .wide { visible.removeLast() }
        while visible.last == .blank { visible.removeLast() }
        cells = visible
        clusters = snapshot.clusters
    }
}
