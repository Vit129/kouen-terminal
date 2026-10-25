import Foundation

/// Pure path and workspace group resolution utilities.
/// Resolves project group roots, parent repository boundaries for worktrees, and user-friendly path displays.
public enum ProjectGroupResolver: Sendable {
    public static func shortenPath(_ path: String) -> String {
        if path == "/" { return "/" }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        if path.hasPrefix(home + "/") {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    public static func pathDisplayName(_ path: String) -> String {
        let shortened = shortenPath(path)
        if shortened == "/" || shortened == "~" { return shortened }
        let last = (shortened as NSString).lastPathComponent
        return last.isEmpty ? shortened : last
    }

    public static func projectGroupName(for path: String) -> String {
        projectGroupDisplayName(forRootPath: projectGroupRootPath(for: path))
    }

    public static func projectGroupDisplayName(forRootPath rootPath: String) -> String {
        let trimmed = rootPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Sessions" }
        if trimmed == "Other" || trimmed == "Sessions" { return trimmed }

        let url = URL(fileURLWithPath: trimmed)
        if url.lastPathComponent == ".git" {
            return url.deletingLastPathComponent().lastPathComponent
        }
        return pathDisplayName(trimmed)
    }

    public static func projectGroupRootPath(for path: String) -> String {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Sessions" }

        // If path is inside Kouen's worktree dir, group under the parent repo root
        if let range = trimmed.range(of: "/.kouen-worktrees") {
            let parentRoot = String(trimmed[..<range.lowerBound])
            if !parentRoot.isEmpty { return parentRoot }
        }

        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        let startPath: String
        if manager.fileExists(atPath: trimmed, isDirectory: &isDirectory), !isDirectory.boolValue {
            startPath = (trimmed as NSString).deletingLastPathComponent
        } else {
            startPath = trimmed
        }

        var current = (startPath as NSString).standardizingPath
        while !current.isEmpty {
            let gitPath = (current as NSString).appendingPathComponent(".git")
            if manager.fileExists(atPath: gitPath) {
                return current
            }
            let parent = (current as NSString).deletingLastPathComponent
            if parent == current { break }
            current = parent
        }

        return startPath
    }
}
