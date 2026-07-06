import SwiftUI

/// Builds a believable 3-pane Kouen tab (claude-code · zsh · logs) and composes it through
/// the genuine ported `GridCompositor` — real split geometry (`PaneRectSolver`), real box-drawing
/// junctions, real `pane-border-status` labels, and a real `StyledSegment` status line. The cell
/// contents are canned, but the composed frame is produced exactly the way `kouen attach` does.
enum DemoSession {
    /// Compose one frame. `tick` advances the light streaming animation (logs + agent output).
    static func compose(tick: Int) -> ComposedFrame {
        let cols = 104
        let rows = 30
        let statusRows = 1
        let paneAreaRows = rows - statusRows

        // Split tree: left = claude-code (active); right column = zsh over logs.
        let p0 = PaneLeaf(), p1 = PaneLeaf(), p2 = PaneLeaf()
        let tree: PaneNode = .branch(
            direction: .horizontal, ratio: 0.55,
            first: .leaf(p0),
            second: .branch(direction: .vertical, ratio: 0.5, first: .leaf(p1), second: .leaf(p2))
        )

        let rects = PaneRectSolver.solve(tree, cols: cols, rows: paneAreaRows,
                                         border: true, paneBorderStatus: .top)
        func rect(_ id: PaneID) -> PaneRect { rects.first { $0.paneID == id } ?? rects[0] }

        let r0 = rect(p0.id), r1 = rect(p1.id), r2 = rect(p2.id)

        let panes: [CompositorPane] = [
            CompositorPane(rect: r0, grid: claudeGrid(cols: r0.cols, rows: r0.rows, tick: tick),
                           isActive: true, borderLabel: " 0  claude-code "),
            CompositorPane(rect: r1, grid: zshGrid(cols: r1.cols, rows: r1.rows),
                           isActive: false, borderLabel: " 1  zsh "),
            CompositorPane(rect: r2, grid: logsGrid(cols: r2.cols, rows: r2.rows, tick: tick),
                           isActive: false, borderLabel: " 2  logs "),
        ]

        let compositor = GridCompositor(cols: cols, rows: rows)
        return compositor.compose(panes: panes, statusLines: [statusLine(cols: cols)])
    }

    // MARK: - Panes

    private static func claudeGrid(cols: Int, rows: Int, tick: Int) -> TerminalGridSnapshot {
        var g = GridCanvas(cols: cols, rows: rows)
        let magenta = TerminalGridColor.palette(5)
        let blue = TerminalGridColor.palette(4)
        let green = TerminalGridColor.palette(2)
        let red = TerminalGridColor.palette(1)
        let yellow = TerminalGridColor.palette(3)

        var r = 0
        g.put(r, 0, "● Refactoring auth middleware", fg: magenta, bold: true); r += 2
        g.put(r, 0, "> ", fg: green, bold: true)
        g.put(r, 2, "add rate limiting to the login route"); r += 2
        g.put(r, 0, "I'll add a token-bucket limiter and guard the", faint: true); r += 1
        g.put(r, 0, "POST /login handler before it hits the DB.", faint: true); r += 2
        g.put(r, 0, "⏺ ", fg: blue, bold: true)
        g.put(r, 2, "Edit  ", fg: blue, bold: true)
        g.put(r, 8, "src/server/auth.ts"); r += 1
        g.put(r, 3, "12   export async function login(req) {", faint: true); r += 1
        g.put(r, 0, "  13 - ", fg: red)
        g.put(r, 7, "const user = await find(req.body)", fg: red); r += 1
        g.put(r, 0, "  13 + ", fg: green)
        g.put(r, 7, "await limiter.consume(req.ip)", fg: green); r += 1
        g.put(r, 0, "  14 + ", fg: green)
        g.put(r, 7, "const user = await find(req.body)", fg: green); r += 1
        g.put(r, 3, "15     return sign(user)", faint: true); r += 2
        g.put(r, 0, "⏺ ", fg: blue, bold: true)
        g.put(r, 2, "Bash  ", fg: blue, bold: true)
        g.put(r, 8, "npm test -- auth", faint: true); r += 1

        if tick % 3 == 0 {
            g.put(r, 2, "running…", fg: yellow)
        } else {
            g.put(r, 2, "✔ ", fg: green, bold: true)
            g.put(r, 4, "14 passing", fg: green)
        }
        r += 2

        // Blinking prompt cursor on the next input line.
        g.put(r, 0, "> ", fg: green, bold: true)
        g.cursor = TerminalCursor(row: r, col: 2, visible: true, shape: .block)
        return g.snapshot()
    }

    private static func zshGrid(cols: Int, rows: Int) -> TerminalGridSnapshot {
        var g = GridCanvas(cols: cols, rows: rows)
        let green = TerminalGridColor.palette(2)
        let blue = TerminalGridColor.palette(4)
        let subtle = TerminalGridColor.palette(8)

        var r = 0
        g.put(r, 0, "~/app ", fg: blue, bold: true)
        g.put(r, 6, "❯ ", fg: green, bold: true)
        g.put(r, 8, "kouen-cli list-surfaces"); r += 2
        g.put(r, 0, "SURFACE   TAB     AGENT         STATUS", fg: subtle, bold: true); r += 1
        g.put(r, 0, "s-3f2a    main    claude-code   ")
        g.put(r, 30, "● ", fg: green); g.put(r, 32, "running", fg: green); r += 1
        g.put(r, 0, "s-91c4    main    zsh           idle", faint: true); r += 1
        g.put(r, 0, "s-1188    logs    —             idle", faint: true); r += 2
        g.put(r, 0, "~/app ", fg: blue, bold: true)
        g.put(r, 6, "❯ ", fg: green, bold: true)
        return g.snapshot()
    }

    private static func logsGrid(cols: Int, rows: Int, tick: Int) -> TerminalGridSnapshot {
        var g = GridCanvas(cols: cols, rows: rows)
        let green = TerminalGridColor.palette(2)
        let yellow = TerminalGridColor.palette(3)
        let blue = TerminalGridColor.palette(4)
        let subtle = TerminalGridColor.palette(8)

        let streaming = [
            "✓ auth/login.test.ts (8)",
            "✓ auth/limiter.test.ts (6)",
            "✓ server/routes.test.ts (11)",
            "✓ db/pool.test.ts (4)",
        ]
        var r = 0
        g.put(r, 0, "RUN ", fg: blue, bold: true)
        g.put(r, 4, "v1.6.0 ", faint: true)
        g.put(r, 11, "tests/", fg: subtle); r += 2

        let shown = 1 + (tick % streaming.count)
        for i in 0 ..< shown {
            g.put(r, 0, "✓ ", fg: green, bold: true)
            g.put(r, 2, String(streaming[i].dropFirst(2)))
            r += 1
        }
        r += 1
        g.put(r, 0, "↺ ", fg: yellow, bold: true)
        g.put(r, 2, "watching for changes…", faint: true)
        return g.snapshot()
    }

    // MARK: - Status line

    /// A full-width dark status bar mirroring Kouen's default: a blue session chip, the
    /// window list, and a right-aligned path/branch/clock — built from real `StyledSegment`s.
    private static func statusLine(cols: Int) -> [StyledSegment] {
        let bar = FormatColor.rgb(r: 0x31, g: 0x32, b: 0x44)     // Catppuccin surface0
        let chip = FormatColor.palette(4)                        // blue
        let dark = FormatColor.rgb(r: 0x1e, g: 0x1e, b: 0x2e)    // base
        let text = FormatColor.rgb(r: 0xcd, g: 0xd6, b: 0xf4)

        var segs: [StyledSegment] = []
        func push(_ s: String, fg: FormatColor? = text, bg: FormatColor? = bar, bold: Bool = false) {
            segs.append(StyledSegment(text: s, fg: fg, bg: bg, bold: bold))
        }

        push(" kouen ", fg: dark, bg: chip, bold: true)
        push("  0:claude-code", fg: text, bold: true)
        push("*  1:zsh  2:logs", fg: FormatColor.rgb(r: 0x7f, g: 0x84, b: 0x9c))

        let right = "~/app   feature/agents   16:35 "
        let used = segs.reduce(0) { $0 + $1.text.count }
        let spacer = max(1, cols - used - right.count)
        push(String(repeating: " ", count: spacer))
        push(right, fg: FormatColor.rgb(r: 0xa6, g: 0xad, b: 0xc8))
        return segs
    }
}

/// A tiny helper for authoring canned pane grids: a `cols × rows` cell buffer you write
/// styled text runs into. ASCII/box content only (normal width), which is all the demo uses.
struct GridCanvas {
    let cols: Int
    let rows: Int
    private var cells: [TerminalGridCell]
    var cursor = TerminalCursor(visible: false)

    init(cols: Int, rows: Int) {
        self.cols = max(0, cols)
        self.rows = max(0, rows)
        cells = [TerminalGridCell](repeating: .blank, count: self.cols * self.rows)
    }

    /// Write `text` at (`row`, `col`), clamped to the grid. Returns the next free column.
    @discardableResult
    mutating func put(
        _ row: Int, _ col: Int, _ text: String,
        fg: TerminalGridColor = .none, bg: TerminalGridColor = .none,
        bold: Bool = false, italic: Bool = false, faint: Bool = false, underline: Bool = false
    ) -> Int {
        guard row >= 0, row < rows else { return col }
        var x = col
        for scalar in text.unicodeScalars {
            guard x >= 0, x < cols else { break }
            cells[row * cols + x] = TerminalGridCell(
                codepoint: scalar.value, foreground: fg, background: bg,
                bold: bold, faint: faint, italic: italic,
                underline: underline ? .single : .none
            )
            x += 1
        }
        return x
    }

    func snapshot() -> TerminalGridSnapshot {
        TerminalGridSnapshot(cols: cols, rows: rows, cells: cells, cursor: cursor)
    }
}

/// A self-animating Kouen terminal preview: recomposes a fresh frame from `DemoSession`
/// on a slow tick (static under Reduce Motion). The block cursor blink lives in
/// `ComposedTerminalView`, so the per-frame work here is just the occasional recompose.
struct DemoTerminalView: View {
    var fontSize: CGFloat = 12.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            ComposedTerminalView(frame: DemoSession.compose(tick: 1), fontSize: fontSize)
        } else {
            TimelineView(.periodic(from: .now, by: 1.25)) { ctx in
                let tick = Int(ctx.date.timeIntervalSinceReferenceDate / 1.25)
                ComposedTerminalView(frame: DemoSession.compose(tick: tick), fontSize: fontSize)
            }
        }
    }
}
