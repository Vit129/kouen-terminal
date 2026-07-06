import KouenCopyMode
import KouenTerminalEngine
import KouenTerminalRenderer

/// Pure selection resolution logic extracted from `KouenTerminalSurfaceView+SelectionAndLinks`.
/// Resolves raw mouse selection inputs into render regions without touching view state.
enum SelectionResolver {
    /// Raw selection inputs captured on the main thread, in virtual-line space (`historyCount -
    /// scrollOffset + viewportRow`, 0 = oldest retained line — the same coordinate space copy
    /// mode uses). Sendable so the off-main build closure can capture it safely.
    struct RawSelection: Sendable {
        let anchorLine: Int, anchorColumn: Int
        let headLine: Int, headColumn: Int
        let granularity: KouenTerminalSurfaceView.SelectionGranularity
        let rectangular: Bool
    }

    /// Resolve a raw selection into a render region, converting virtual lines to the *current*
    /// viewport's row space. Call ON the emulator queue (inside the build) so `.word` expansion
    /// reads `wordColumnRange` directly without a main-stalling `emulatorSync`.
    static func resolve(
        _ sel: RawSelection?,
        emulator: TerminalEmulator,
        scrollOffset: Int,
        columns: Int,
        wordSeparators: String = " \t"
    ) -> SelectionRegion? {
        guard let sel else { return nil }
        // Virtual line at viewport row 0 — subtract this from a selection endpoint's virtual
        // line to get its row in the current viewport.
        let topLine = emulator.historyCount - scrollOffset
        let anchorRow = sel.anchorLine - topLine
        let headRow = sel.headLine - topLine
        if sel.rectangular {
            return .block(BlockSelection((anchorRow, sel.anchorColumn), (headRow, sel.headColumn)))
        }
        if sel.granularity == .character {
            return .linear(TerminalSelection((anchorRow, sel.anchorColumn), (headRow, sel.headColumn)))
        }
        func unitRange(line: Int, column: Int) -> ClosedRange<Int> {
            switch sel.granularity {
            case .character: return column ... column
            case .line: return 0 ... max(0, columns - 1)
            case .word:
                return emulator.wordColumnRange(line: line, column: column, separators: wordSeparators)
            }
        }
        let lo: (line: Int, column: Int), hi: (line: Int, column: Int)
        if (sel.anchorLine, sel.anchorColumn) <= (sel.headLine, sel.headColumn) {
            lo = (sel.anchorLine, sel.anchorColumn); hi = (sel.headLine, sel.headColumn)
        } else {
            lo = (sel.headLine, sel.headColumn); hi = (sel.anchorLine, sel.anchorColumn)
        }
        let loRange = unitRange(line: lo.line, column: lo.column)
        let hiRange = unitRange(line: hi.line, column: hi.column)
        let loRow = lo.line - topLine
        let hiRow = hi.line - topLine
        if lo.line == hi.line {
            return .linear(TerminalSelection((loRow, min(loRange.lowerBound, hiRange.lowerBound)),
                                             (loRow, max(loRange.upperBound, hiRange.upperBound))))
        }
        return .linear(TerminalSelection((loRow, loRange.lowerBound), (hiRow, hiRange.upperBound)))
    }
}
