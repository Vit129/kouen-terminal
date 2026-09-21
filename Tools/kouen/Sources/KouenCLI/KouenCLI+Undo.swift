import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    /// `kouen undo [step | list] [--tab/--surface <id>]`
    ///
    /// Reverts (or lists) the shadow checkpoints `CheckpointManager` snapshots automatically on
    /// every Stop-hook "turn finished" (P46 Phase 3) — a safety net for "the agent just wrote
    /// 2-3 turns of code and made it worse," without touching the real index or `git stash`.
    static func handleUndo(_ args: [String], client: DaemonClient) throws {
        let knownSubs: Set<String> = ["step", "list"]
        let sub = args.first.flatMap { knownSubs.contains($0) ? $0 : nil }
        let rest = sub != nil ? Array(args.dropFirst()) : args
        let target = flagValue(rest, flag: "--tab") ?? flagValue(rest, flag: "--surface")

        let snap = try snapshot(client)
        guard let tab = resolveUndoTarget(in: snap, target: target) else {
            if let target {
                fputs("undo: no tab matching '\(target)'\n", kouenStderr)
            } else {
                fputs("undo: no active tab (pass --tab/--surface <id>)\n", kouenStderr)
            }
            exit(1)
        }
        guard let surfaceID = tab.rootPane.surfaceID?.uuidString ?? tab.rootPane.allSurfaceIDs().first?.uuidString else {
            fputs("undo: tab has no surface\n", kouenStderr)
            exit(1)
        }

        let mgr = CheckpointManager()
        switch sub ?? "step" {
        case "list":
            let checkpoints = mgr.list(cwd: tab.cwd, session: surfaceID)
            guard !checkpoints.isEmpty else {
                print("No checkpoints for this tab yet.")
                return
            }
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for cp in checkpoints {
                let statLine = cp.diffStat
                    .split(separator: "\n")
                    .last.map(String.init)?
                    .trimmingCharacters(in: .whitespaces) ?? "(no diff)"
                print("[\(cp.turn)] \(df.string(from: cp.createdAt))  \(statLine)")
            }
        default: // "step"
            guard mgr.restore(cwd: tab.cwd, session: surfaceID) else {
                fputs("undo: no checkpoint to revert to for this tab\n", kouenStderr)
                exit(1)
            }
            print("Reverted working tree in '\(tab.cwd)' to the last checkpoint.")
        }
    }

    private static func resolveUndoTarget(in snap: SessionSnapshot, target: String?) -> Tab? {
        guard let target else { return snap.activeWorkspace?.activeTab }
        let lower = target.lowercased()
        let allTabs = snap.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }
        return allTabs.first {
            $0.id.uuidString.lowercased().hasPrefix(lower)
                || ($0.rootPane.surfaceID?.uuidString.lowercased().hasPrefix(lower) ?? false)
        }
    }
}
