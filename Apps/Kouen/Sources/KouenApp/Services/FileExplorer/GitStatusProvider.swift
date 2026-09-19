import Foundation
import KouenCore

/// Runs `git status --porcelain -z` for a given directory and returns a flat
/// map of relative path → `GitStatusType`. Results are empty (not an error)
/// when the directory is not inside a git repository.
///
/// Declared as an `actor` so it is safe to call concurrently from multiple
/// SwiftUI `.task` closures (e.g. when switching sessions quickly).
public actor GitStatusProvider {

    /// Caps how long one `status(rootPath:)` call can block a `loadRoot()` — profiled
    /// 2026-09-19: with several tabs' file trees each spawning their own `git status`
    /// around the same moment (e.g. right when the sidebar becomes visible), `sample`
    /// showed one of these subprocesses stuck in `waitUntilExit()` for the entire
    /// sampling window, competing with the sidebar-toggle animation for CPU the whole
    /// time. There was no bound on that wait before — one slow/contended call could
    /// stall its tab's file tree (and starve other work) indefinitely.
    nonisolated static let statusTimeout: Duration = .seconds(3)

    public init() {}

    /// Fetch git status for `rootPath`. Never throws — returns an empty dict on
    /// any failure (non-git directory, git not found, process error, or timeout).
    public func status(rootPath: String) async -> [String: GitStatusType] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", rootPath, "status", "--porcelain", "-z"]

        let stdoutPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = FileHandle.nullDevice   // suppress — non-git dirs exit non-zero

        do {
            try process.run()
        } catch {
            return [:]
        }
        // Drain on a GCD thread, not `Task.detached`: `readDataToEndOfFile()` blocks
        // synchronously until the pipe closes, and Task.detached still runs on Swift's
        // shared cooperative pool. Under bursty concurrent calls that pool can saturate
        // with these blocking reads, so a queued-but-never-run one leaves its process's
        // pipe undrained — if that process then writes enough to fill the kernel pipe
        // buffer, its `write()` blocks forever and the process never exits. GCD's pool
        // auto-scales instead of sharing Swift concurrency's fixed thread budget.
        //
        // Raced against a timeout: if the read hasn't finished by then, `terminate()`
        // the process so its pipe closes — the abandoned read-task closure then drains
        // whatever partial output exists and exits quickly on its own GCD thread rather
        // than blocking forever; we don't wait for it.
        let data: Data? = await withTaskGroup(of: Data?.self) { group in
            group.addTask {
                await withCheckedContinuation { (continuation: CheckedContinuation<Data, Never>) in
                    DispatchQueue.global(qos: .utility).async {
                        continuation.resume(returning: stdoutPipe.fileHandleForReading.readDataToEndOfFile())
                    }
                }
            }
            group.addTask {
                try? await Task.sleep(for: Self.statusTimeout)
                return nil
            }
            let first = await group.next() ?? nil
            if first == nil {
                process.terminate()
            }
            group.cancelAll()
            return first
        }

        guard let data else { return [:] }
        process.waitUntilExit()
        return parse(data)
    }

    // MARK: - Private

    /// Parse `git status --porcelain -z` output.
    ///
    /// Format: NUL-separated entries, each `"XY path"` where X = index status,
    /// Y = working-tree status. We map on the **working-tree** column (Y) so
    /// unstaged changes are visible immediately without staging.
    private func parse(_ data: Data) -> [String: GitStatusType] {
        guard let raw = String(data: data, encoding: .utf8) else { return [:] }
        var result: [String: GitStatusType] = [:]

        // Split on NUL; filter empty strings that appear after trailing NUL.
        // Renames are encoded as two fields: "R  new-path\0old-path\0".
        let entries = raw.split(separator: "\0", omittingEmptySubsequences: true)
        var entryIndex = 0
        while entryIndex < entries.count {
            let entry = entries[entryIndex]
            entryIndex += 1
            // Each entry is at least "XY " (3 chars) followed by the path.
            guard entry.count > 3 else { continue }
            let xy = entry.prefix(2)
            let path = String(entry.dropFirst(3))

            // Use the index status (X) when the working-tree column (Y) is blank
            // (e.g. fully-staged additions). Untracked files have "??" in both.
            let workingTree = xy.last ?? " "
            let indexStatus = xy.first ?? " "
            let effective  = workingTree == " " ? indexStatus : workingTree

            let status: GitStatusType
            switch effective {
            case "M":          status = .modified
            case "A":          status = .added
            case "D":          status = .deleted
            case "R":
                status = .renamed
                if entryIndex < entries.count {
                    entryIndex += 1
                }
            case "?":          status = .untracked
            default:           status = .unmodified
            }
            result[path] = status
        }
        return result
    }
}
