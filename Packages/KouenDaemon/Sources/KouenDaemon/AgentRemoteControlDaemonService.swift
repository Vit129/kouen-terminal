import Foundation
import KouenCore
import KouenIPC
import KouenSettings

/// Manages background remote-control companion daemons (e.g. `codex remote-control start`,
/// `agy remote-control start`, `happy daemon start`) that run at most once per daemon lifetime.
public final class AgentRemoteControlDaemonService: @unchecked Sendable {
    public static let shared = AgentRemoteControlDaemonService()

    private let lock = NSLock()
    private var startedAgents: Set<AgentKind> = []
    private var startedHappy = false

    public init() {}

    /// Resolve an executable path checking common locations first, then `which`.
    public static func resolveExecutable(named name: String) -> String? {
        let home = NSHomeDirectory()
        let candidates = [
            home + "/.local/bin/" + name,
            home + "/.volta/bin/" + name,
            "/opt/homebrew/bin/" + name,
            "/usr/local/bin/" + name,
            "/usr/bin/" + name,
        ]
        if let found = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return found
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [name]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0,
                  let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !path.isEmpty, FileManager.default.isExecutableFile(atPath: path)
            else { return nil }
            return path
        } catch {
            return nil
        }
    }

    /// Happy's daemon is worth running whenever `happy` is installed and logged in (its
    /// `~/.happy/access.key` exists), whatever each agent's launch mode is: it lets a phone start
    /// or resume sessions with no pane open, and `remote-control` modes are unaffected.
    static func shouldStartHappyDaemon(happyPath: String?, home: String = NSHomeDirectory()) -> Bool {
        happyPath != nil && FileManager.default.fileExists(atPath: home + "/.happy/access.key")
    }

    /// Starts companion daemons for configured agents if their mode is `.remoteControl`
    /// and their binary exists on this Mac.
    public func startConfiguredDaemons(settings: KouenSettings = .load(), log: (@Sendable (String) -> Void)? = nil) {
        lock.lock()
        defer { lock.unlock() }

        // 1. Codex remote-control daemon
        if settings.sessionMode(for: .codex) == .remoteControl && !startedAgents.contains(.codex) {
            if let bin = Self.resolveExecutable(named: "codex") {
                startedAgents.insert(.codex)
                log?("Starting Codex remote-control daemon (\(bin))")
                spawnDaemon(executable: bin, arguments: ["remote-control", "start"], log: log)
            }
        }

        // 2. Antigravity remote-control daemon
        if settings.sessionMode(for: .antigravity) == .remoteControl && !startedAgents.contains(.antigravity) {
            if let bin = Self.resolveExecutable(named: "agy") {
                startedAgents.insert(.antigravity)
                log?("Starting Antigravity remote-control daemon (\(bin))")
                spawnDaemon(executable: bin, arguments: ["remote-control", "start"], log: log)
            }
        }

        // 3. Happy daemon (`happy daemon start` detaches itself; a no-op if already running)
        let happy = Self.resolveExecutable(named: "happy")
        if !startedHappy, let bin = happy, Self.shouldStartHappyDaemon(happyPath: happy) {
            startedHappy = true
            log?("Starting Happy daemon (\(bin))")
            spawnDaemon(executable: bin, arguments: ["daemon", "start"], environment: Self.happyEnvironment(), log: log)
        }
    }

    /// The Kouen daemon runs under launchd with a bare `PATH` (`/usr/bin:/bin:...`). Phone-started
    /// sessions are spawned by Happy's daemon, which inherits this env, so give it the tool dirs a
    /// login shell would have and pin `HAPPY_CLAUDE_PATH` to the real `claude` (Happy otherwise may
    /// pick a stale npm install or find none).
    static func happyEnvironment(base: [String: String] = ProcessInfo.processInfo.environment,
                                 home: String = NSHomeDirectory(),
                                 claude: String? = resolveExecutable(named: "claude")) -> [String: String] {
        var env = base
        let extra = [home + "/.local/bin", home + "/.volta/bin", "/opt/homebrew/bin", "/usr/local/bin"]
        let existing = (base["PATH"] ?? "").split(separator: ":").map(String.init)
        env["PATH"] = (extra + existing.filter { !extra.contains($0) }).joined(separator: ":")
        if env["HAPPY_CLAUDE_PATH"] == nil, let claude { env["HAPPY_CLAUDE_PATH"] = claude }
        return env
    }

    private func spawnDaemon(executable: String, arguments: [String], environment: [String: String]? = nil,
                             log: (@Sendable (String) -> Void)?) {
        DispatchQueue.global().async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = arguments
            if let environment { process.environment = environment }
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            do {
                try process.run()
                process.waitUntilExit()
                log?("Finished daemon run: \(executable) \(arguments.joined(separator: " ")) exit=\(process.terminationStatus)")
            } catch {
                log?("Failed to spawn daemon \(executable): \(error)")
            }
        }
    }
}
