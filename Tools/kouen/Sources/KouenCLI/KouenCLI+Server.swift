#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore

extension KouenCLI {
    static func handleKillServer(_ args: [String]) {
        if flagValue(args, flag: "--host") != nil {
            fputs("kill-server: operates on the local daemon only — run it on the host (ssh <host> kouen-cli kill-server)\n", kouenStderr)
            exit(64)
        }
        let raw = (try? String(contentsOf: KouenPaths.daemonPIDURL, encoding: .utf8)) ?? ""
        guard let pid = Int32(raw.trimmingCharacters(in: .whitespacesAndNewlines)), pid > 0 else {
            fputs("kill-server: no daemon.pid — is the daemon running? (try: kouen-cli ping)\n", kouenStderr)
            exit(1)
        }
        // PID-reuse guard: after an unclean shutdown the recorded PID can belong to an
        // unrelated process — never signal anything that isn't a live KouenDaemon.
        guard isLiveKouenDaemon(pid) else {
            fputs("kill-server: pid \(pid) from daemon.pid is not a running KouenDaemon (stale file?) — nothing to signal\n", kouenStderr)
            exit(1)
        }
        guard kill(pid, SIGTERM) == 0 else {
            fputs("kill-server: kill(\(pid)) failed: \(String(cString: strerror(errno)))\n", kouenStderr)
            exit(1)
        }
        print("sent SIGTERM to KouenDaemon (pid \(pid))")
        #if os(macOS)
        print("note: launchd KeepAlive restarts it (sessions restore from layout.json);")
        print("      to stop it for good: launchctl bootout gui/$(id -u)/\(KouenPaths.launchAgentLabel)")
        #endif
    }

    static func isLiveKouenDaemon(_ pid: Int32) -> Bool {
        guard kill(pid, 0) == 0 || errno == EPERM else { return false }
        #if canImport(Darwin)
        var buffer = [UInt8](repeating: 0, count: Int(MAXPATHLEN))
        let length = buffer.withUnsafeMutableBufferPointer { ptr -> Int32 in
            proc_pidpath(pid, ptr.baseAddress, UInt32(MAXPATHLEN))
        }
        guard length > 0 else { return false }
        let path = String(decoding: buffer.prefix(Int(length)), as: UTF8.self)
        #else
        var buffer = [CChar](repeating: 0, count: 4096)
        let len = readlink("/proc/\(pid)/exe", &buffer, buffer.count - 1)
        guard len > 0 else { return false }
        let path = String(decoding: buffer[0 ..< len].map { UInt8(bitPattern: $0) }, as: UTF8.self)
        #endif
        return (path as NSString).lastPathComponent.contains("KouenDaemon")
    }

    static func handleStartServer(_ args: [String], client: DaemonClient) {
        if case .pong? = try? client.request(.ping, timeout: 1) {
            print("daemon already running")
            return
        }
        if flagValue(args, flag: "--host") != nil {
            fputs("start-server: cannot start a remote daemon — start it on the host (systemd/launchctl or kouen-cli install)\n", kouenStderr)
            exit(1)
        }
        #if os(macOS)
        let kick = Process()
        kick.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        kick.arguments = ["kickstart", "gui/\(getuid())/\(KouenPaths.launchAgentLabel)"]
        try? kick.run()
        kick.waitUntilExit()
        if case .pong? = try? client.request(.ping, timeout: 3) {
            print("daemon started")
            return
        }
        fputs("start-server: could not start the daemon — run 'kouen-cli install' (LaunchAgent) or open Kouen.app\n", kouenStderr)
        exit(1)
        #else
        fputs("start-server: start KouenDaemon directly (e.g. via systemd) on this platform\n", kouenStderr)
        exit(1)
        #endif
    }

    static func handleDetachClient(_ args: [String], client: DaemonClient) throws {
        guard let raw = flagValue(args, flag: "--client"), let id = UUID(uuidString: raw) else {
            fputs("Usage: kouen-cli detach-client --client <uuid>\n", kouenStderr)
            exit(1)
        }
        _ = try checkedRequest(client, .detachClient(clientID: id))
    }

    static func handleStopServer(_ args: [String], client: DaemonClient) {
        // Wait up to 2 seconds for daemon to respond, then kill it
        let deadline = Date().addingTimeInterval(2)
        while Date() < deadline {
            if case .pong? = try? client.request(.ping, timeout: 0.1) {
                print("daemon is running; sending SIGTERM...")
                sleep(1) // Let daemon finish pending IPC before killing
                break
            }
            usleep(50_000)
        }
        handleKillServer(args)
    }

    static func printDaemonStats(_ args: [String], client: DaemonClient) throws {
        let response = try checkedRequest(client, .daemonStats)
        guard case let .daemonStats(stats) = response else { throw DaemonClientError.unexpectedResponse }
        try emit(stats, args) {
            print("pid: \(stats.pid)")
            print("version: \(stats.version ?? "?") (\(stats.build.map(String.init) ?? "pre-handshake"))")
            print(String(format: "uptime: %.0fs", stats.uptimeSeconds))
            print("surfaces: \(stats.surfaceCount)")
            print("scrollback: \(stats.totalScrollbackBytes) bytes")
            print("clients: \(stats.clientCount)")
            print("subscribers: \(stats.subscriberCount)")
            print("snapshot-revision: \(stats.snapshotRevision)")
        }
    }

    static func printClients(_ args: [String], client: DaemonClient) throws {
        let response = try checkedRequest(client, .listClients)
        guard case let .clients(items) = response else { throw DaemonClientError.unexpectedResponse }
        try emit(items, args) {
            for item in items {
                let attached = item.attachedSurfaceIDs.isEmpty ? "-" : item.attachedSurfaceIDs.joined(separator: ",")
                print("\(item.id.uuidString)\t\(item.label)\t\(attached)\t\(item.connectedAt)")
            }
        }
    }

    static func handleRemote(_ args: [String]) throws -> Int32 {
        let store = RemoteHostStore()
        let sub = args.count > 1 ? args[1] : "list"
        switch sub {
        case "list":
            let hosts = store.load()
            if hosts.isEmpty {
                print("No remote hosts. Add one with: kouen-cli remote add --name <name> --ssh <user@host>")
            }
            for h in hosts {
                let live = SSHTunnelManager.shared.isConnected(h.name) ? " [connected]" : ""
                print("\(h.name)\t\(h.sshTarget)\t\(h.remoteSocketPath)\(live)")
            }
            return 0
        case "add":
            guard let name = flagValue(args, flag: "--name"), let ssh = flagValue(args, flag: "--ssh") else {
                fputs("Usage: kouen-cli remote add --name <name> --ssh <user@host> "
                    + "--socket <remote-path> | --detect [--ssh-arg <arg> ...]\n", kouenStderr)
                return 64
            }
            var sshArgs: [String] = []
            var i = 0
            while i < args.count {
                if args[i] == "--ssh-arg" {
                    guard i + 1 < args.count else {
                        fputs("kouen-cli remote add: --ssh-arg requires a value "
                            + "(e.g. --ssh-arg -p --ssh-arg 2222).\n", kouenStderr)
                        return 64
                    }
                    sshArgs.append(args[i + 1]); i += 2
                } else { i += 1 }
            }
            let socketPath: String
            if let explicit = flagValue(args, flag: "--socket") {
                socketPath = explicit
            } else if args.contains("--detect") {
                do {
                    socketPath = try SSHTunnelManager.detectSocketPath(sshTarget: ssh, sshArgs: sshArgs)
                } catch {
                    fputs("kouen-cli remote add: socket auto-detect failed (\(error)); "
                        + "pass --socket <remote-path> instead.\n", kouenStderr)
                    return 1
                }
            } else {
                fputs("kouen-cli remote add: pass --socket <remote-path>, or --detect to auto-detect it "
                    + "via `kouen-cli socket-path` on the remote.\n", kouenStderr)
                return 64
            }
            let result = store.upsert(RemoteHost(name: name, sshTarget: ssh, remoteSocketPath: socketPath, sshArgs: sshArgs))
            guard result.saved else {
                fputs("kouen-cli remote add: failed to write \(KouenPaths.remoteHostsURL.path) "
                    + "(check disk space and permissions).\n", kouenStderr)
                return 1
            }
            print("Added remote '\(name)' -> \(ssh) (\(socketPath))")
            return 0
        case "remove":
            guard let name = flagValue(args, flag: "--name") else {
                fputs("Usage: kouen-cli remote remove --name <name>\n", kouenStderr)
                return 64
            }
            let result = store.remove(name: name)
            SSHTunnelManager.shared.stop(host: name)
            guard result.saved else {
                fputs("kouen-cli remote remove: failed to write \(KouenPaths.remoteHostsURL.path) "
                    + "(check disk space and permissions).\n", kouenStderr)
                return 1
            }
            print("Removed remote '\(name)'")
            return 0
        default:
            fputs("Usage: kouen-cli remote <list|add|remove> ...\n", kouenStderr)
            return 64
        }
    }

    static func runDaemonForeground() -> Never {
        guard let daemon = locateDaemonBinary() else {
            fputs("kouen-cli daemon: KouenDaemon binary not found "
                + "(set KOUEN_DAEMON_PATH or run `kouen-cli install`).\n", kouenStderr)
            exit(1)
        }
        let path = daemon.path
        var argv: [UnsafeMutablePointer<CChar>?] = [strdup(path), nil]
        defer { argv.forEach { $0.map { free($0) } } } // unreachable on success (execv replaces us)
        execv(path, &argv)
        fputs("kouen-cli daemon: exec failed for \(path)\n", kouenStderr)
        exit(1)
    }

    static func handleAttach(_ args: [String]) throws -> Int32 {
        guard let surface = flagValue(args, flag: "--surface") else {
            fputs("Usage: kouen-cli attach --surface <id> [--detach-keys <bytes>] [--host <name>]\n", kouenStderr)
            return 64
        }
        var configuration = AttachClient.Configuration()
        switch resolveDetachSequence(args) {
        case .parsed(let seq): configuration.detachSequence = seq
        case .absent: break  // flag absent — keep the default
        case .invalid(let message): fputs(message, kouenStderr); return 64
        }
        let endpoint = try resolveEndpoint(args)
        return try AttachClient.run(surfaceID: surface, configuration: configuration, endpoint: endpoint)
    }

    #if canImport(KouenTerminalKit)
    /// Renders a whole tab (split layout) into the terminal via the compositor.
    static func handleAttachWindow(_ args: [String]) throws -> Int32 {
        let selector: WindowAttachClient.TabSelector
        if let tabID = flagValue(args, flag: "--tab") ?? flagValue(args, flag: "--window") {
            selector = .id(tabID)
        } else if let session = flagValue(args, flag: "--session") {
            selector = .session(session)
        } else {
            selector = .active
        }
        var configuration = WindowAttachClient.Configuration()
        switch resolveDetachSequence(args) {
        case .parsed(let seq):
            configuration.detachSequence = seq
            configuration.detachSequenceExplicit = true  // user opted into a custom escape sequence
        case .absent: break  // flag absent — keep the prefix-bound default detach
        case .invalid(let message): fputs(message, kouenStderr); return 64
        }
        return try WindowAttachClient.run(tab: selector, configuration: configuration)
    }
    #endif

    /// `record --surface <id> --output <file> [--display]` — record a surface's
    /// output to a JSON Lines file (see `RecordingEvent`); `--display` also mirrors
    /// the output to this terminal. Stops on Ctrl-C or when the surface closes.
    static func handleRecord(_ args: [String], client: DaemonClient) -> Int32 {
        guard let surface = flagValue(args, flag: "--surface"),
              let output = flagValue(args, flag: "--output") else {
            fputs("Usage: kouen-cli record --surface <uuid> --output <file> [--display]\n", kouenStderr)
            return 64
        }
        return RecordClient.run(
            client: client, surfaceID: surface, outputPath: output,
            display: args.contains("--display")
        )
    }

    /// `replay <file> [--speed <n>] [--no-timing]` — play a recording back to this
    /// terminal. `--speed` scales the recorded timing (2 = twice as fast),
    /// `--no-timing` dumps everything instantly. Ctrl-C stops cleanly.
    static func handleReplay(_ args: [String]) -> Int32 {
        guard let file = positionalArgs(args, skippingValuesFor: ["--speed"]).first else {
            fputs("Usage: kouen-cli replay <file> [--speed <n>] [--no-timing]\n", kouenStderr)
            return 64
        }
        let speed = Double(flagValue(args, flag: "--speed") ?? "1") ?? .nan
        guard speed > 0 else {
            fputs("kouen-cli replay: --speed must be a positive number\n", kouenStderr)
            return 64
        }
        return ReplayClient.run(path: file, speed: speed, honorTiming: !args.contains("--no-timing"))
    }
}
