import Foundation

public protocol MetadataProvider: Sendable {
    func refresh(tab: Tab) -> Tab
}

public struct GitMetadataProvider: MetadataProvider {
    public init() {}

    public func refresh(tab: Tab) -> Tab {
        var updated = tab
        let probePath = tab.worktreePath ?? tab.cwd
        updated.gitBranch = Self.currentBranch(at: probePath)
        return updated
    }

    private static func currentBranch(at path: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "rev-parse", "--abbrev-ref", "HEAD"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let branch = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return branch?.isEmpty == false ? branch : nil
        } catch {
            return nil
        }
    }

    /// The repo root for `path` (`git rev-parse --show-toplevel`), or `nil` outside a git repo.
    /// Used by `kouenProjectsList` to dedupe open tabs down to the repos they actually belong to
    /// — a tab's `cwd` may be a subdirectory or a worktree, not the root itself.
    public static func topLevel(at path: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", path, "rev-parse", "--show-toplevel"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let root = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return root?.isEmpty == false ? root : nil
        } catch {
            return nil
        }
    }
}

public struct CwdMetadataProvider: MetadataProvider {
    public init() {}

    public func refresh(tab: Tab) -> Tab {
        tab
    }
}
