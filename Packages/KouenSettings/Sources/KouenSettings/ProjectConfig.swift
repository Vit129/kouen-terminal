import Foundation

/// Per-repository configuration read from `kouen.json` at the repo root.
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

    /// Reads `kouen.json` from the given directory, returning nil if not found or unparseable.
    /// Personal override: `~/.config/kouen/projects/<repo-folder-name>.json` takes precedence.
    public static func load(from directory: String) -> ProjectConfig? {
        // Check personal override first
        let repoName = (directory as NSString).lastPathComponent
        let overridePath = NSHomeDirectory() + "/.config/kouen/projects/\(repoName).json"
        if FileManager.default.fileExists(atPath: overridePath),
           let data = FileManager.default.contents(atPath: overridePath),
           let config = try? JSONDecoder().decode(ProjectConfig.self, from: data) {
            return config
        }
        // Fall back to repo-local kouen.json
        let path = (directory as NSString).appendingPathComponent("kouen.json")
        guard FileManager.default.fileExists(atPath: path),
              let data = FileManager.default.contents(atPath: path)
        else { return nil }
        return try? JSONDecoder().decode(ProjectConfig.self, from: data)
    }
}
