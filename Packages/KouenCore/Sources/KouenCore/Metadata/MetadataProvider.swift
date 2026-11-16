import Foundation

public protocol MetadataProvider: Sendable {
    func refresh(tab: Tab) -> Tab
}

public struct GitMetadataProvider: MetadataProvider {
    public init() {}

    public func refresh(tab: Tab) -> Tab {
        var updated = tab
        let probePath = tab.worktreePath ?? tab.cwd
        let result = Self.query(at: probePath, arguments: ["--abbrev-ref", "HEAD"])
        if !result.unavailable { updated.gitBranch = result.value }
        return updated
    }

    /// Resolves the root without allowing an unresponsive repository to block indefinitely.
    public static func topLevel(at path: String) -> String? {
        query(at: path, arguments: ["--show-toplevel"]).value
    }

    private static func query(at path: String, arguments: [String]) -> (value: String?, unavailable: Bool) {
        let result = ProcessRunner.run(
            executable: "/usr/bin/env",
            arguments: ["GIT_OPTIONAL_LOCKS=0", "/usr/bin/git", "-C", path, "rev-parse"] + arguments,
            timeout: 3
        )
        let unavailable = result.isTimedOut || result.stdoutWasTruncated || result.stderrWasTruncated || result.exitCode == -1
        guard result.isSuccess else { return (nil, unavailable) }
        let value = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        return (value.isEmpty ? nil : value, false)
    }

}

public struct CwdMetadataProvider: MetadataProvider {
    public init() {}

    public func refresh(tab: Tab) -> Tab {
        tab
    }
}
