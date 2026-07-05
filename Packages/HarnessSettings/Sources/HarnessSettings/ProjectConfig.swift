import Foundation

/// Per-repository configuration read from `harness.json` at the repo root.
/// Teams commit this file to share project setup (agent auto-start, run scripts, etc.).
public struct ProjectConfig: Codable, Sendable, Equatable {
    /// Command to run once when a new session is created at this repo.
    public var setupScript: String?
    /// Repeatable command launched by ⌘R in a dedicated RUN surface.
    public var runScript: String?
    /// Command to run before archiving/closing a session.
    public var archiveScript: String?
    /// Workspace name to auto-assign sessions created at this repo.
    public var workspace: String?
    /// Environment variables injected into the session's shell.
    public var env: [String: String]?
    /// Agent identifier hint for status tracking (e.g. "claude-code", "codex").
    public var agent: String?
    /// Default base ref for worktree creation (e.g. "origin/main").
    public var baseRef: String?
    /// When true, agent-detected sessions auto-get their own worktree for branch isolation.
    public var isolateAgents: Bool?

    public init(
        setupScript: String? = nil,
        runScript: String? = nil,
        archiveScript: String? = nil,
        workspace: String? = nil,
        env: [String: String]? = nil,
        agent: String? = nil,
        baseRef: String? = nil,
        isolateAgents: Bool? = nil
    ) {
        self.setupScript = setupScript
        self.runScript = runScript
        self.archiveScript = archiveScript
        self.workspace = workspace
        self.env = env
        self.agent = agent
        self.baseRef = baseRef
        self.isolateAgents = isolateAgents
    }

    /// Reads `kouen.json` (or the pre-rename `harness.json`) from the given directory,
    /// returning nil if not found or unparseable.
    /// Personal override: `~/.config/kouen/projects/<repo-folder-name>.json` takes precedence,
    /// falling back to the pre-rename `~/.config/harness/projects/...` if the new one isn't there.
    public static func load(from directory: String) -> ProjectConfig? {
        // Check personal override first: new path, then the pre-rename path.
        let repoName = (directory as NSString).lastPathComponent
        let overridePath = NSHomeDirectory() + "/.config/kouen/projects/\(repoName).json"
        let legacyOverridePath = NSHomeDirectory() + "/.config/harness/projects/\(repoName).json"
        for candidate in [overridePath, legacyOverridePath] {
            if FileManager.default.fileExists(atPath: candidate),
               let data = FileManager.default.contents(atPath: candidate),
               let config = try? JSONDecoder().decode(ProjectConfig.self, from: data) {
                return config
            }
        }
        // Fall back to repo-local kouen.json, then the pre-rename harness.json — teams may
        // already have the latter committed, so it keeps working unmoved.
        let path = (directory as NSString).appendingPathComponent("kouen.json")
        let legacyPath = (directory as NSString).appendingPathComponent("harness.json")
        for candidate in [path, legacyPath] {
            if FileManager.default.fileExists(atPath: candidate),
               let data = FileManager.default.contents(atPath: candidate) {
                return try? JSONDecoder().decode(ProjectConfig.self, from: data)
            }
        }
        return nil
    }
}
