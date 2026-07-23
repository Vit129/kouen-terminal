import Foundation

/// Detects a repo's primary tech stack from on-disk signal files, so a freshly spawned
/// agent gets a stack-appropriate hint instead of no context at all. Read-only, single-shot —
/// no caching, no process spawn; callers (e.g. `kouenSpawnAgent`) run this once per spawn.
public enum SignalFileRouter {
    public struct DetectedProfile: Sendable, Equatable {
        public let stack: String
        public let hint: String
    }

    /// Best-effort stack guess for `cwd`, checked in the same signal-file order as
    /// `~/.claude/rules/routing.md`'s Cross-Project Stack Detection table. Returns `nil`
    /// when nothing recognizable is present — callers should fall back to no hint.
    public static func detectProfile(at cwd: String) -> DetectedProfile? {
        let fm = FileManager.default

        func exists(_ name: String) -> Bool {
            fm.fileExists(atPath: (cwd as NSString).appendingPathComponent(name))
        }
        func directoryContains(where predicate: (String) -> Bool) -> Bool {
            (try? fm.contentsOfDirectory(atPath: cwd))?.contains(where: predicate) ?? false
        }

        if exists("Package.swift") || directoryContains(where: { $0.hasSuffix(".xcodeproj") }) {
            return DetectedProfile(
                stack: "swift",
                hint: "Swift project (Package.swift/.xcodeproj) — match existing Swift 6 concurrency conventions."
            )
        }
        if directoryContains(where: { $0.hasPrefix("build.gradle") || $0.hasPrefix("settings.gradle") }) {
            return DetectedProfile(stack: "android", hint: "Android project (build.gradle) — Kotlin/Jetpack Compose conventions.")
        }
        if exists("package.json") {
            return detectNodeProfile(cwd: cwd, fm: fm)
        }
        if exists("requirements.txt") || exists("pyproject.toml") {
            return DetectedProfile(stack: "python", hint: "Python project (requirements.txt/pyproject.toml).")
        }
        return nil
    }

    private static func detectNodeProfile(cwd: String, fm: FileManager) -> DetectedProfile {
        let path = (cwd as NSString).appendingPathComponent("package.json")
        guard let data = fm.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return DetectedProfile(stack: "node", hint: "Node.js project (package.json present, unreadable dependencies).")
        }
        let deps = (json["dependencies"] as? [String: Any] ?? [:])
            .merging(json["devDependencies"] as? [String: Any] ?? [:]) { existing, _ in existing }
        let names = Set(deps.keys)

        if names.contains("next") {
            return DetectedProfile(
                stack: "nextjs",
                hint: "Next.js project — App Router conventions, server/client component boundaries."
            )
        }
        if names.contains("react") || names.contains("react-dom") {
            return DetectedProfile(stack: "react", hint: "React project — component/hook conventions.")
        }
        if names.contains("vue") {
            return DetectedProfile(stack: "vue", hint: "Vue project.")
        }
        if names.contains("express") || names.contains("fastify") || names.contains("@nestjs/core") {
            return DetectedProfile(stack: "node-backend", hint: "Node backend project (Express/Fastify/Nest).")
        }
        return DetectedProfile(stack: "node", hint: "Node.js/TypeScript project.")
    }

    /// Ordered build/test commands for the stack detected at `cwd`, run in sequence by a
    /// caller that stops at the first failure. Empty means "skip validate" — either no
    /// stack was recognized, or the stack has no command wired yet (never treat empty as
    /// a failure).
    public static func validationSteps(at cwd: String) -> [[String]] {
        guard let profile = detectProfile(at: cwd) else { return [] }
        let fm = FileManager.default
        func exists(_ name: String) -> Bool {
            fm.fileExists(atPath: (cwd as NSString).appendingPathComponent(name))
        }

        switch profile.stack {
        case "swift":
            return [["swift", "build"], ["swift", "test"]]
        case "python":
            return [["python3", "-m", "pytest", "-q"]]
        case "node", "nextjs", "react", "vue", "node-backend":
            guard hasTestScript(cwd: cwd, fm: fm) else { return [] }
            if exists("bun.lockb") { return [["bun", "test"]] }
            if exists("pnpm-lock.yaml") { return [["pnpm", "test"]] }
            if exists("yarn.lock") { return [["yarn", "test"]] }
            return [["npm", "test"]]
        default:
            return []
        }
    }

    private static func hasTestScript(cwd: String, fm: FileManager) -> Bool {
        guard let data = fm.contents(atPath: (cwd as NSString).appendingPathComponent("package.json")),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let scripts = json["scripts"] as? [String: Any]
        else { return false }
        return scripts["test"] != nil
    }

    public struct HandoffInfo: Sendable, Equatable {
        public let note: String
        public let suggestedSkills: String?
    }

    /// Reads `agent-memory/HANDOFF.md` at `cwd` (written by the `handoff` skill's
    /// From/To/Suggested-skills/Note convention) — reused rather than a second handoff-doc
    /// format. Returns full, untruncated text: the two callers have different needs, so
    /// truncation for display is each caller's own concern, not this shared reader's.
    /// - `GitPanelView` truncates `note` for its merge-confirm NSAlert (a human glance, not a
    ///   full read).
    /// - `kouenSpawnAgent` surfaces both fields as-is in the spawn result for the calling agent
    ///   to fold into a new agent's first prompt (the same non-auto-typed pattern
    ///   `detectProfile`'s stack hint already uses there) — a continuing agent needs the full
    ///   note, not a preview, and `suggestedSkills` is the one field the `handoff` skill wrote
    ///   specifically so the next agent doesn't have to re-derive routing.
    ///
    /// `nil` when absent or `Note:` is empty — most tasks don't warrant a handoff write.
    public static func handoffInfo(at cwd: String) -> HandoffInfo? {
        let path = (cwd as NSString).appendingPathComponent("agent-memory/HANDOFF.md")
        guard let content = try? String(contentsOfFile: path, encoding: .utf8),
              let noteRange = content.range(of: "Note:")
        else { return nil }
        let note = content[noteRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !note.isEmpty else { return nil }

        var suggestedSkills: String?
        if let range = content.range(of: "Suggested skills:") {
            let rest = content[range.upperBound...]
            let lineEnd = rest.firstIndex(of: "\n") ?? rest.endIndex
            let value = rest[..<lineEnd].trimmingCharacters(in: .whitespaces)
            suggestedSkills = value.isEmpty ? nil : value
        }

        return HandoffInfo(note: note, suggestedSkills: suggestedSkills)
    }
}
