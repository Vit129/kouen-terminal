import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    /// One row of `happy daemon list`.
    struct HappyDaemonSession: Codable, Equatable {
        let happySessionId: String
        let pid: Int32
        let startedBy: String
    }

    /// `happy daemon list` prints a header line and then a JSON array; stale entries (dead
    /// pids) linger in it, so callers must liveness-check `pid`.
    static func parseHappyDaemonList(_ output: String) -> [HappyDaemonSession] {
        guard let start = output.firstIndex(of: "["),
              let data = String(output[start...]).data(using: .utf8),
              let sessions = try? JSONDecoder().decode([HappyDaemonSession].self, from: data)
        else { return [] }
        return sessions
    }

    /// Sessions the phone started: spawned headless by Happy's daemon, so no pane hosts them.
    static func adoptableHappySessions(_ sessions: [HappyDaemonSession], isAlive: (Int32) -> Bool) -> [HappyDaemonSession] {
        sessions.filter { $0.startedBy == "daemon" && isAlive($0.pid) }
    }

    /// Happy may pick a stale npm `claude` (EACCES) and the pane's `claude` is a shell function, so
    /// pin the real binary found on this process's PATH.
    static func happyResumeCommand(_ id: String, path: String = ProcessInfo.processInfo.environment["PATH"] ?? "",
                                   isExecutable: (String) -> Bool = { FileManager.default.isExecutableFile(atPath: $0) }) -> String {
        let claude = path.split(separator: ":").map { "\($0)/claude" }.first(where: isExecutable)
        let prefix = claude.map { "HAPPY_CLAUDE_PATH='\($0.replacingOccurrences(of: "'", with: "'\\''"))' " } ?? ""
        return "\(prefix)happy resume \(id)"
    }

    private static func runHappy(_ arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["happy"] + arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(data: data, encoding: .utf8)
    }

    /// `kouen happy adopt <session-id-prefix> | --all`
    ///
    /// A session started from the Happy phone app is a headless process no Kouen pane hosts.
    /// Adopting stops that process (SIGTERM, never SIGKILL) and resumes the session in a new
    /// tab with `happy resume`, otherwise two processes would share one session id.
    static func handleHappy(_ args: [String], client: DaemonClient) async throws {
        guard args.first == "adopt" else {
            fputs("Usage: kouen-cli happy adopt <happy-session-id-prefix> | --all\n", kouenStderr)
            exit(1)
        }
        let rest = Array(args.dropFirst())
        let prefix = rest.first { !$0.hasPrefix("-") }
        let all = rest.contains("--all")
        guard prefix != nil || all else {
            fputs("Usage: kouen-cli happy adopt <happy-session-id-prefix> | --all\n", kouenStderr)
            exit(1)
        }
        guard let listing = runHappy(["daemon", "list"]) else {
            fputs("happy: `happy` not found on PATH\n", kouenStderr)
            exit(1)
        }
        let isAlive: (Int32) -> Bool = { kill($0, 0) == 0 }
        let targets = adoptableHappySessions(parseHappyDaemonList(listing), isAlive: isAlive)
            .filter { all || $0.happySessionId.hasPrefix(prefix ?? "") }
        guard !targets.isEmpty else {
            fputs("happy: no phone-started session to adopt\n", kouenStderr)
            exit(1)
        }
        for session in targets {
            kill(session.pid, SIGTERM)
            var waited = 0
            while isAlive(session.pid), waited < 30 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                waited += 1
            }
            guard !isAlive(session.pid) else {
                fputs("happy: pid \(session.pid) did not stop; not resuming \(session.happySessionId)\n", kouenStderr)
                continue
            }
            let tabID = try await openTab(running: happyResumeCommand(session.happySessionId), cwd: nil, client: client, label: "happy")
            print(tabID.uuidString)
        }
    }
}
