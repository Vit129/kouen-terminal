import Foundation
import HarnessCore

/// `harness board [--watch]` — Kanban-style text view of `BoardModel.classify(...)`,
/// the shared P16 board model. One-shot mode renders the current snapshot as a
/// grouped table; `--watch` re-renders on every snapshot change (tmux/htop-style).
extension HarnessCLI {
    static func printBoard(_ args: [String], client: DaemonClient) throws {
        if args.contains("--watch") {
            try watchBoard(client: client)
            return
        }
        let snap = try snapshot(client)
        let columns = BoardModel.classify(snapshot: snap)
        print(renderBoard(columns), terminator: "")
    }

    /// Subscribes to snapshot-change notifications (same push pattern as
    /// `ControlModeClient.subscribeSnapshot`) and re-renders the board in place
    /// on each update. Runs until the connection ends (e.g. daemon stop) or the
    /// process is interrupted.
    private static func watchBoard(client: DaemonClient) throws {
        let render: @Sendable () -> Void = {
            let snap = try? snapshot(client)
            // Clear screen + move cursor home, then reprint — simplest
            // "redraw in place" approach without a TUI dependency.
            print("\u{1B}[2J\u{1B}[H", terminator: "")
            if let snap {
                print(renderBoard(BoardModel.classify(snapshot: snap)), terminator: "")
            }
        }
        render()

        let semaphore = DispatchSemaphore(value: 0)
        let sub = try client.subscribeSnapshot(label: "board --watch", onRevision: { _ in
            render()
        }, onEnd: {
            semaphore.signal()
        })
        defer { sub.cancel() }
        semaphore.wait()
    }

    /// Renders board columns as a plain-text table: one section per column
    /// (header + card rows), following the style of other `printX` table
    /// renderers in `HarnessCLI+Session.swift`. Empty columns are still shown
    /// with a header and a placeholder row so `--watch` doesn't visually shift.
    static func renderBoard(_ columns: [BoardColumn]) -> String {
        var lines: [String] = []
        for column in columns {
            lines.append("== \(column.name) (\(column.cards.count)) ==")
            if column.cards.isEmpty {
                lines.append("  (none)")
            } else {
                for card in column.cards {
                    lines.append("  " + cardLine(card))
                }
            }
            lines.append("")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func cardLine(_ card: BoardCard) -> String {
        var parts: [String] = [card.title.isEmpty ? "(untitled)" : card.title]
        parts.append(card.cwd)
        if let branch = card.gitBranch, !branch.isEmpty {
            parts.append("⎇ \(branch)")
        }
        if let cmd = card.currentCommand, !cmd.isEmpty {
            parts.append("$ \(cmd)")
        }
        if let kind = card.agentKind {
            parts.append("[\(kind.displayName)]")
        }
        return parts.joined(separator: "  •  ")
    }
}
