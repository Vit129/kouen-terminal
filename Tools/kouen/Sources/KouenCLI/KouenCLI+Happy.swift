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

    /// `flavor` and `path` of a Happy session from `~/.happy/sessions.json` (plaintext metadata).
    static func happyLocalSession(_ id: String, sessionsJSON: Data) -> (flavor: String, path: String)? {
        guard let root = (try? JSONSerialization.jsonObject(with: sessionsJSON)) as? [String: Any],
              let sessions = root["sessions"] as? [String: Any],
              let meta = (sessions[id] as? [String: Any])?["metadata"] as? [String: Any],
              let flavor = meta["flavor"] as? String, let path = meta["path"] as? String
        else { return nil }
        return (flavor, path)
    }

    /// `happy agy` is a one-shot `agy --print` driver, so the phone session is just an agy
    /// conversation; agy's own cache records the latest one per cwd.
    static func agyResumeCommand(path: String, cacheJSON: Data) -> String? {
        guard let map = (try? JSONSerialization.jsonObject(with: cacheJSON)) as? [String: String],
              let id = map[path] else { return nil }
        return "agy --conversation \(id)"
    }

    /// One Copilot `session-state/<id>/workspace.yaml`, reduced to what adopt needs.
    struct CopilotSessionInfo: Equatable {
        let id: String, cwd: String, clientName: String, updatedAt: String
    }

    static func parseCopilotWorkspace(_ yaml: String) -> CopilotSessionInfo? {
        var f: [String: String] = [:]
        for line in yaml.split(separator: "\n") {
            guard let c = line.firstIndex(of: ":") else { continue }
            f[String(line[..<c])] = line[line.index(after: c)...].trimmingCharacters(in: .whitespaces)
        }
        guard let id = f["id"], let cwd = f["cwd"] else { return nil }
        return CopilotSessionInfo(id: id, cwd: cwd, clientName: f["client_name"] ?? "", updatedAt: f["updated_at"] ?? "")
    }

    /// `happy acp -- copilot` tags the Copilot session `client_name: happy-cli`; ACP session ids
    /// are not stored in Happy's metadata, so take the most recently updated one for the cwd.
    /// ponytail: two Happy copilot sessions in one cwd resolve to the newer; upgrade = match by start time.
    static func copilotResumeCommand(path: String, sessions: [CopilotSessionInfo]) -> String? {
        sessions.filter { $0.clientName == "happy-cli" && $0.cwd == path }
            .max { $0.updatedAt < $1.updatedAt }
            .map { "copilot --resume \($0.id)" }
    }

    /// Resume command for a phone-started Happy session, by agent flavor. `happy resume` only
    /// knows claude/codex; agy and copilot resume natively in the pane. `nil` = cannot resume.
    static func adoptResumeCommand(id: String, flavor: String, path: String,
                                   agyCache: Data?, copilotSessions: [CopilotSessionInfo]) -> String? {
        switch flavor {
        case "agy": return agyCache.flatMap { agyResumeCommand(path: path, cacheJSON: $0) }
        case "acp": return copilotResumeCommand(path: path, sessions: copilotSessions)
        default: return happyResumeCommand(id)
        }
    }

    private static func loadCopilotSessions(home: String = NSHomeDirectory()) -> [CopilotSessionInfo] {
        let root = home + "/.copilot/session-state"
        let dirs = (try? FileManager.default.contentsOfDirectory(atPath: root)) ?? []
        return dirs.compactMap { d in
            (try? String(contentsOfFile: "\(root)/\(d)/workspace.yaml", encoding: .utf8)).flatMap(parseCopilotWorkspace)
        }
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
        let home = NSHomeDirectory()
        let sessionsJSON = FileManager.default.contents(atPath: home + "/.happy/sessions.json") ?? Data()
        let agyCache = FileManager.default.contents(atPath: home + "/.gemini/antigravity-cli/cache/last_conversations.json")
        let copilotSessions = loadCopilotSessions(home: home)
        for session in targets {
            let local = happyLocalSession(session.happySessionId, sessionsJSON: sessionsJSON)
            let flavor = local?.flavor ?? "claude"
            let path = local?.path ?? ""
            guard let command = adoptResumeCommand(id: session.happySessionId, flavor: flavor, path: path,
                                                   agyCache: agyCache, copilotSessions: copilotSessions) else {
                fputs("happy: no \(flavor) conversation found to resume for \(session.happySessionId); leaving it running\n", kouenStderr)
                continue
            }
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
            let tabID = try await openTab(running: command, cwd: path.isEmpty ? nil : path, client: client, label: "happy")
            print(tabID.uuidString)
        }
    }
}
