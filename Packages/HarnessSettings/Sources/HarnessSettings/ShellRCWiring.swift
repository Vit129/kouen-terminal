import Foundation

/// Idempotently wires a guarded block into a shell rc file (`.zshrc`/`.bashrc`/…). Shared by
/// `ShellIntegration` (OSC 133 prompts) and `ShellCompletionInstaller` (completions) so the
/// "append a marked, backed-up, no-duplicate block" logic lives in exactly one place.
public enum ShellRCWiring {
    public struct Result: Sendable, Equatable {
        public let rcPath: URL
        /// True when the marker was already present and nothing was appended this run.
        public let alreadyWired: Bool
        /// Backup taken before the first edit, if the rc already existed.
        public let backedUp: URL?
    }

    /// Append `body` wrapped in `begin`/`end` marker lines to `rc`, creating the rc's directory and
    /// backing up an existing rc first. A no-op (returns `alreadyWired: true`) when `begin` is
    /// already present, so re-running is safe.
    @discardableResult
    public static func wire(into rc: URL, begin: String, end: String, body: String) throws -> Result {
        try FileManager.default.createDirectory(
            at: rc.deletingLastPathComponent(), withIntermediateDirectories: true)
        let existing = (try? String(contentsOf: rc, encoding: .utf8)) ?? ""
        if existing.contains(begin) {
            return Result(rcPath: rc, alreadyWired: true, backedUp: nil)
        }
        var backedUp: URL?
        if FileManager.default.fileExists(atPath: rc.path) {
            let backup = rc.appendingPathExtension("harness-bak-\(UUID().uuidString.prefix(8))")
            try FileManager.default.copyItem(at: rc, to: backup)
            backedUp = backup
        }
        let block = "\n\(begin)\n\(body)\n\(end)\n"
        let updated = existing.isEmpty ? String(block.dropFirst()) : existing + block
        try Data(updated.utf8).write(to: rc, options: .atomic)
        return Result(rcPath: rc, alreadyWired: false, backedUp: backedUp)
    }
}
