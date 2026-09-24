import Foundation
import KouenCore
import KouenIPC
import KouenSettings

/// Manages background remote-control companion daemons (e.g. `codex remote-control start`,
/// `agy remote-control start`) that run at most once per daemon lifetime.
public final class AgentRemoteControlDaemonService: @unchecked Sendable {
    public static let shared = AgentRemoteControlDaemonService()

    private let lock = NSLock()
    private var startedAgents: Set<AgentKind> = []

    public init() {}

    /// Resolve an executable path checking common locations first, then `which`.
    public static func resolveExecutable(named name: String) -> String? {
        let home = NSHomeDirectory()
        let candidates = [
            home + "/.local/bin/" + name,
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
    }

    private func spawnDaemon(executable: String, arguments: [String], log: (@Sendable (String) -> Void)?) {
        DispatchQueue.global().async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = arguments
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
