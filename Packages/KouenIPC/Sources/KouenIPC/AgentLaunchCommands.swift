import Foundation

/// Launch and resume configuration for an agent family.
public struct AgentLaunchConfig: Sendable {
    public enum ResumeStyle: Sendable, Equatable {
        /// Subcommand style: e.g. `codex resume <sessionID>`
        case subcommand(String)
        /// Flag style: e.g. `claude --resume <sessionID>` or `agy --conversation <sessionID>`
        case flag(String)
        /// Bare session ID: e.g. `binary <sessionID>`
        case bare
        /// Agent does not support CLI resume via session ID
        case none
    }

    public let binary: String
    public let supportedModes: Set<AgentSessionMode>
    public let cloudFallback: AgentSessionMode
    public let launchFlags: [AgentSessionMode: [String]]
    public let resumeStyle: ResumeStyle
    public let appendModeFlagsOnResume: Bool

    public init(
        binary: String,
        supportedModes: Set<AgentSessionMode> = [.local],
        cloudFallback: AgentSessionMode = .local,
        launchFlags: [AgentSessionMode: [String]] = [:],
        resumeStyle: ResumeStyle = .flag("--resume"),
        appendModeFlagsOnResume: Bool = false
    ) {
        self.binary = binary
        self.supportedModes = supportedModes
        self.cloudFallback = cloudFallback
        self.launchFlags = launchFlags
        self.resumeStyle = resumeStyle
        self.appendModeFlagsOnResume = appendModeFlagsOnResume
    }
}

/// Centralized launch and resume command builder for CLI agents across session modes.
public enum AgentLaunchCommands {
    /// Remote control prefix for vendors that support session name prefixes (e.g. Claude Code).
    public static let remoteControlNamePrefix = "kouen"

    /// Declarative launch and resume configs per agent kind.
    public static let configs: [AgentKind: AgentLaunchConfig] = [
        .claudeCode: AgentLaunchConfig(
            binary: "claude",
            supportedModes: [.local, .remoteControl, .cloud],
            cloudFallback: .remoteControl,
            launchFlags: [
                .cloud: ["--cloud"],
                .remoteControl: ["--remote-control", "--remote-control-session-name-prefix", remoteControlNamePrefix]
            ],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: true
        ),
        .antigravity: AgentLaunchConfig(
            binary: "agy",
            supportedModes: [.local, .remoteControl],
            cloudFallback: .remoteControl,
            launchFlags: [
                .remoteControl: ["--remote-control"]
            ],
            resumeStyle: .flag("--conversation"),
            appendModeFlagsOnResume: true
        ),
        .copilot: AgentLaunchConfig(
            binary: "copilot",
            supportedModes: [.local, .remoteControl],
            cloudFallback: .remoteControl,
            launchFlags: [
                .remoteControl: ["--remote"]
            ],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: true
        ),
        .codex: AgentLaunchConfig(
            binary: "codex",
            supportedModes: [.local, .remoteControl],
            cloudFallback: .remoteControl,
            launchFlags: [:],
            resumeStyle: .subcommand("resume"),
            appendModeFlagsOnResume: false
        ),
        .hermes: AgentLaunchConfig(
            binary: "hermes",
            supportedModes: [.local, .remoteControl],
            cloudFallback: .remoteControl,
            launchFlags: [
                .remoteControl: ["--remote"]
            ],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: true
        ),
        .cursor: AgentLaunchConfig(
            binary: "cursor",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .none,
            appendModeFlagsOnResume: false
        ),
        .gemini: AgentLaunchConfig(
            binary: "gemini",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        ),
        .kiro: AgentLaunchConfig(
            binary: "kiro",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        ),
        .grok: AgentLaunchConfig(
            binary: "grok",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        ),
        .pi: AgentLaunchConfig(
            binary: "pi",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        ),
        .openClaw: AgentLaunchConfig(
            binary: "openclaw",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        ),
        .openCode: AgentLaunchConfig(
            binary: "opencode",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        ),
        .aider: AgentLaunchConfig(
            binary: "aider",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .none,
            appendModeFlagsOnResume: false
        ),
        .goose: AgentLaunchConfig(
            binary: "goose",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .subcommand("resume"),
            appendModeFlagsOnResume: false
        ),
        .generic: AgentLaunchConfig(
            binary: "agent",
            supportedModes: [.local],
            cloudFallback: .local,
            launchFlags: [:],
            resumeStyle: .flag("--resume"),
            appendModeFlagsOnResume: false
        )
    ]

    /// Resolved session mode for an agent kind, falling back to supported modes.
    /// E.g. Antigravity, Copilot, and Codex do not have interactive cloud CLI sessions;
    /// their `.cloud` mode falls back to `.remoteControl`.
    public static func resolveMode(kind: AgentKind, mode: AgentSessionMode) -> AgentSessionMode {
        guard let config = configs[kind] else { return .local }
        if config.supportedModes.contains(mode) {
            return mode
        }
        let fallback = (mode == .cloud) ? config.cloudFallback : .local
        fputs("Kouen: mode '\(mode.rawValue)' is not supported for \(kind.rawValue); falling back to '\(fallback.rawValue)'\n", stderr)
        return fallback
    }

    /// Flags that go right after the binary when starting a fresh session.
    public static func launchFlags(kind: AgentKind, mode: AgentSessionMode) -> [String] {
        let resolved = resolveMode(kind: kind, mode: mode)
        guard let config = configs[kind] else { return [] }
        return config.launchFlags[resolved] ?? []
    }

    /// Primary CLI executable name for this agent kind.
    public static func binaryName(kind: AgentKind) -> String {
        configs[kind]?.binary ?? kind.rawValue
    }

    /// Full shell command string to start a fresh agent session.
    public static func launch(kind: AgentKind, mode: AgentSessionMode, cwd: String? = nil) -> String {
        if kind == .cursor {
            return cwd.map { "cursor \($0)" } ?? "cursor ."
        }
        let binary = binaryName(kind: kind)
        let flags = launchFlags(kind: kind, mode: mode)
        if flags.isEmpty {
            return binary
        }
        return ([binary] + flags).joined(separator: " ")
    }

    /// Convenience overload resolving agent from string.
    public static func launch(agent: String, mode: AgentSessionMode, cwd: String? = nil) -> String {
        let kind = kind(from: agent) ?? .claudeCode
        return launch(kind: kind, mode: mode, cwd: cwd)
    }

    public static func resume(kind: AgentKind, sessionID: String, mode: AgentSessionMode = .local) -> String {
        var resolved = resolveMode(kind: kind, mode: mode)
        if resolved == .cloud {
            resolved = .remoteControl
        }
        guard let config = configs[kind] else {
            return "agent --resume \(sessionID)"
        }
        var base: String
        switch config.resumeStyle {
        case .subcommand(let sub):
            base = "\(config.binary) \(sub) \(sessionID)"
        case .flag(let flag):
            base = "\(config.binary) \(flag) \(sessionID)"
        case .bare:
            base = "\(config.binary) \(sessionID)"
        case .none:
            base = "\(config.binary) \(sessionID)"
        }
        if config.appendModeFlagsOnResume {
            let modeFlags = config.launchFlags[resolved] ?? []
            if !modeFlags.isEmpty {
                base += " " + modeFlags.joined(separator: " ")
            }
        }
        return base
    }

    /// Resolves common agent alias strings into an `AgentKind`.
    public static func kind(from string: String) -> AgentKind? {
        let lower = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        switch lower {
        case "claude", "claude-code", "claudecode", "cc":
            return .claudeCode
        case "codex", "cx":
            return .codex
        case "agy", "antigravity", "ag":
            return .antigravity
        case "copilot", "github-copilot", "gh-copilot", "gh":
            return .copilot
        case "kiro", "kiro-cli":
            return .kiro
        case "gemini":
            return .gemini
        case "cursor":
            return .cursor
        case "hermes":
            return .hermes
        case "openclaw", "claw":
            return .openClaw
        case "opencode":
            return .openCode
        case "aider":
            return .aider
        case "goose":
            return .goose
        case "grok":
            return .grok
        case "pi":
            return .pi
        default:
            return AgentKind(rawValue: lower)
        }
    }
}
