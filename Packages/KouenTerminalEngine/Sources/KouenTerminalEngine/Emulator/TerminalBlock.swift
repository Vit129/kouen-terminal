import Foundation

/// A shell command + its output, delimited by OSC 133 `C` (output start, carrying the exact
/// command text) and `D` (output end + exit code). Lines are absolute buffer-line indices in
/// the same `[history ++ viewport]` space as `TerminalEmulator.promptRows`/`mark(atBufferLine:)`,
/// and index `TerminalEmulator.captureLines(fromLine:toLine:)` (physical rows, matching this
/// addressing — request `joinWrapped: false` if reconstructing text another way).
public struct TerminalBlock: Equatable {
    public let id: Int
    public let command: String
    /// Absolute buffer line of the OSC 133 `A` prompt row this block belongs to.
    public let promptLine: Int
    /// Absolute buffer line of the first output row (where `C` fired).
    public let outputStartLine: Int
    /// Absolute buffer line where output ended (where `D` fired) — nil while the command is
    /// still running.
    public var outputEndLine: Int?
    public var exitCode: Int?
    public let startedAt: Date
    public var finishedAt: Date?
}

/// Per-pane store of `TerminalBlock`s, populated as OSC 133 `C`/`D` boundaries are parsed.
/// Deliberately decoupled from `HistoryLine`/scrollback storage — a block must remain queryable
/// (for Re-run / future MCP block access) after its lines have scrolled out of history and been
/// evicted by `dropHistoryHead`. Forward-only: blocks start applying once shell integration is
/// live in a pane, no retroactive scrollback rescan.
final class TerminalBlockStore {
    private(set) var blocks: [TerminalBlock] = []
    private var nextID = 0
    private let cap: Int

    init(cap: Int = 500) {
        self.cap = cap
    }

    /// OSC 133 `C` — output about to start. `command` is the exact typed command line (decoded
    /// from the shell's preexec hook), not a screen-scrape guess.
    func begin(command: String, promptLine: Int, outputStartLine: Int, startedAt: Date) {
        let block = TerminalBlock(
            id: nextID, command: command, promptLine: promptLine, outputStartLine: outputStartLine,
            outputEndLine: nil, exitCode: nil, startedAt: startedAt, finishedAt: nil
        )
        nextID += 1
        blocks.append(block)
        if blocks.count > cap {
            blocks.removeFirst(blocks.count - cap)
        }
    }

    /// OSC 133 `D` — the most recently started (still-open) block finished.
    func finish(outputEndLine: Int, exitCode: Int?, finishedAt: Date) {
        guard let last = blocks.indices.last, blocks[last].outputEndLine == nil else { return }
        blocks[last].outputEndLine = outputEndLine
        blocks[last].exitCode = exitCode
        blocks[last].finishedAt = finishedAt
    }

    /// The block whose prompt is at `line`, if any.
    func block(atPromptLine line: Int) -> TerminalBlock? {
        blocks.last(where: { $0.promptLine == line })
    }

    /// The most recently finished block (`outputEndLine != nil`), newest first — what
    /// `kouenGetLastBlock` (F3) reads.
    var lastFinishedBlock: TerminalBlock? {
        blocks.last(where: { $0.outputEndLine != nil })
    }

    func block(id: Int) -> TerminalBlock? {
        blocks.first(where: { $0.id == id })
    }
}
