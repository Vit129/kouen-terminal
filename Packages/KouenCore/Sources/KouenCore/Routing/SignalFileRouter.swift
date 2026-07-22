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
}
