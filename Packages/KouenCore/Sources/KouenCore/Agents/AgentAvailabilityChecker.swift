import Foundation

/// Answers "is this agent CLI installed on this machine at all", distinct from `AgentDetector`
/// (which only finds agents already running inside a pane's live process tree). Runs on demand
/// from Settings, not on a scan cadence — install state changes rarely enough that polling it
/// like `AgentDetector.scan()` would be wasted work.
public enum AgentAvailabilityChecker {
    public enum Availability: Equatable, Sendable {
        /// Executable found on PATH, and a native config/auth file for it exists too.
        case installedAuthenticated(path: String)
        /// Executable found on PATH, but no native config/auth file was found — likely needs
        /// an API key or a first-run login before it will work.
        case installedNeedsKey(path: String)
        /// No known executable name for this agent was found on PATH.
        case notInstalled
    }

    /// Checks every entry in `table` (default: `AgentTable.default`) and returns each kind's
    /// availability. One `which`-equivalent PATH resolution per known executable name, first
    /// match wins.
    public static func checkAll(table: AgentTable = .default) -> [AgentKind: Availability] {
        var result: [AgentKind: Availability] = [:]
        for entry in table.entries {
            result[entry.kind] = check(entry: entry)
        }
        return result
    }

    public static func check(kind: AgentKind, table: AgentTable = .default) -> Availability {
        guard let entry = table.entries.first(where: { $0.kind == kind }) else { return .notInstalled }
        return check(entry: entry)
    }

    private static func check(entry: AgentTableEntry) -> Availability {
        guard let path = resolveOnPath(entry.executables) else { return .notInstalled }
        return hasNativeConfig(for: entry.kind) ? .installedAuthenticated(path: path) : .installedNeedsKey(path: path)
    }

    /// Searches `PATH` directories in order for the first executable, regular file matching any
    /// of `names`. Pure Foundation/POSIX — no subprocess spawn (no `which` shell-out) needed.
    private static func resolveOnPath(_ names: [String]) -> String? {
        guard !names.isEmpty else { return nil }
        let pathVar = ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin:/bin:/usr/local/bin"
        let directories = pathVar.split(separator: ":").map(String.init)
        for directory in directories {
            for name in names {
                let candidate = (directory as NSString).appendingPathComponent(name)
                if FileManager.default.isExecutableFile(atPath: candidate) {
                    return candidate
                }
            }
        }
        return nil
    }

    /// Best-effort check for a native config/auth file each CLI is known to write on first
    /// login. Absence doesn't prove "never authenticated" (some agents only use env vars), so
    /// this is a heuristic hint for the UI, not a hard guarantee.
    private static func hasNativeConfig(for kind: AgentKind) -> Bool {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let candidates: [String]
        switch kind {
        case .claudeCode:
            candidates = [".claude/.credentials.json", ".claude.json"]
        case .codex:
            candidates = [".codex/auth.json"]
        case .gemini, .antigravity:
            candidates = [".gemini/antigravity-cli/brain", ".config/gcloud/application_default_credentials.json"]
        case .cursor:
            candidates = [".cursor/config.json"]
        default:
            return true // No known config-file convention: don't flag a false "needs key".
        }
        return candidates.contains { FileManager.default.fileExists(atPath: home.appendingPathComponent($0).path) }
    }
}
