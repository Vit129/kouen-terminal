#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation

/// Runs in the daemon. Walks the descendant process tree of each pane's shell
/// to find a known agent CLI. Cheap (one `proc_listpids` + a few `proc_pidpath`
/// calls per surface, ~1.5s cadence). Configurable via `agents.json` so users
/// can teach it new tools without recompiling.
public enum AgentDetector {
    /// Process-table snapshot updated on each scan.
    nonisolated(unsafe) private static var lastSurfaceSnapshots: [String: AgentSnapshot] = [:]
    private static let snapshotsLock = NSLock()

    /// PID of the shell that owns each surface (set by the daemon when it
    /// spawns the PTY). We walk the PID tree starting here.
    nonisolated(unsafe) private static var surfaceRoots: [String: Int32] = [:]
    private static let rootsLock = NSLock()

    /// Manually inject a hint (used by kouen-cli hooks that know which agent
    /// is starting). Hints take precedence over the proc-tree scan.
    nonisolated(unsafe) private static var hints: [String: AgentSnapshot] = [:]
    private static let hintsLock = NSLock()

    nonisolated(unsafe) private static var lastOutputAt: [String: Date] = [:]
    private static let outputLock = NSLock()

    /// Subagents detected in the last scan per surface, proc-scan and hook-pushed alike.
    /// Kept separate from `lastSurfaceSnapshots` so single-snapshot consumers (`snapshot(forSurfaceKey:)`,
    /// hints, the `agentInfo` IPC response) are untouched by this addition.
    nonisolated(unsafe) private static var lastSubagents: [String: [AgentSnapshot]] = [:]
    private static let subagentsLock = NSLock()

    /// Claude Code `PreToolUse`(Task)/`SubagentStop` hook push — the in-process case proc-scan
    /// structurally cannot see (no child PID exists). `pid: 0` sentinel — there is no real
    /// process to report, only presence. One hint per surface per kind; a real proc-scan match
    /// of the same kind takes precedence (see `mergedSubagents`).
    /// ponytail: a second concurrent Task call of the same kind overwrites rather than counts —
    /// acceptable for v1 (presence, not a precise count), would need a ref-count to fix.
    nonisolated(unsafe) private static var subagentHints: [String: AgentSnapshot] = [:]
    private static let subagentHintsLock = NSLock()

    public static func registerRootPID(_ pid: Int32, forSurfaceKey key: String) {
        rootsLock.lock()
        surfaceRoots[key] = pid
        rootsLock.unlock()
    }

    public static func unregisterRootPID(forSurfaceKey key: String) {
        rootsLock.lock()
        surfaceRoots.removeValue(forKey: key)
        rootsLock.unlock()

        snapshotsLock.lock()
        lastSurfaceSnapshots.removeValue(forKey: key)
        snapshotsLock.unlock()

        hintsLock.lock()
        hints.removeValue(forKey: key)
        hintsLock.unlock()

        outputLock.lock()
        lastOutputAt.removeValue(forKey: key)
        outputLock.unlock()

        subagentsLock.lock()
        lastSubagents.removeValue(forKey: key)
        subagentsLock.unlock()

        subagentHintsLock.lock()
        subagentHints.removeValue(forKey: key)
        subagentHintsLock.unlock()
    }

    public static func registerHint(_ snapshot: AgentSnapshot, forSurfaceKey key: String) {
        hintsLock.lock()
        hints[key] = snapshot
        hintsLock.unlock()
    }

    /// Push from `kouen-cli notify --subagent start` (Claude Code's `PreToolUse`(Task) hook).
    public static func registerSubagentHint(kind: AgentKind, forSurfaceKey key: String) {
        subagentHintsLock.lock()
        subagentHints[key] = AgentSnapshot(kind: kind, executable: kind.rawValue, pid: 0, activity: .idle)
        subagentHintsLock.unlock()
    }

    /// Push from `kouen-cli notify --subagent stop` (Claude Code's `SubagentStop` hook).
    public static func clearSubagentHint(forSurfaceKey key: String) {
        subagentHintsLock.lock()
        subagentHints.removeValue(forKey: key)
        subagentHintsLock.unlock()
    }

    /// The current effective subagent list for `key`: the last proc-scanned set, plus the
    /// hint entry if present and not already covered by a same-kind proc-scan match (a real
    /// pid is more informative than the hint's `pid: 0` sentinel). Used both by `scan()` and
    /// for the immediate apply on hint push (so the badge doesn't wait for the next scan tick).
    public static func mergedSubagents(forSurfaceKey key: String) -> [AgentSnapshot] {
        subagentsLock.lock()
        var result = lastSubagents[key] ?? []
        subagentsLock.unlock()

        subagentHintsLock.lock()
        let hint = subagentHints[key]
        subagentHintsLock.unlock()

        if let hint, !result.contains(where: { $0.kind == hint.kind }) {
            result.append(hint)
        }
        return result
    }

    public static func snapshot(forSurfaceKey key: String) -> AgentSnapshot? {
        snapshotsLock.lock()
        let stored = lastSurfaceSnapshots[key]
        snapshotsLock.unlock()
        if let stored { return stored }
        hintsLock.lock()
        let hint = hints[key]
        hintsLock.unlock()
        return hint
    }

    /// Directly override the agent activity for a surface from an OSC 26 report.
    /// If `kind` is provided and no scan snapshot exists yet, seeds a hint snapshot.
    public static func setActivity(_ activity: AgentActivity, kind: AgentKind? = nil, forSurfaceKey key: String) {
        let now = Date()
        if activity == .working {
            outputLock.lock()
            lastOutputAt[key] = now
            outputLock.unlock()
        }
        snapshotsLock.lock()
        let hasSnapshot = lastSurfaceSnapshots[key] != nil
        if hasSnapshot {
            lastSurfaceSnapshots[key]!.activity = activity
            lastSurfaceSnapshots[key]!.lastActivityAt = now
            if let kind { lastSurfaceSnapshots[key]!.kind = kind }
        }
        snapshotsLock.unlock()

        if !hasSnapshot, let kind {
            hintsLock.lock()
            hints[key] = AgentSnapshot(kind: kind, executable: kind.rawValue, pid: 0,
                                       activity: activity, lastActivityAt: now)
            hintsLock.unlock()
        }
    }

    public static func recordActivity(forSurfaceKey key: String) {
        let now = Date()
        outputLock.lock()
        lastOutputAt[key] = now
        outputLock.unlock()

        snapshotsLock.lock()
        if var snap = lastSurfaceSnapshots[key] {
            snap.activity = .working
            snap.lastActivityAt = now
            lastSurfaceSnapshots[key] = snap
        }
        snapshotsLock.unlock()
    }

    /// How long after the last PTY output an agent still counts as `.working`. Deliberately
    /// generous: agents go quiet for long stretches mid-task (API first-token latency, extended
    /// thinking, silent tool runs), and a tight window made the working indicator drop out while
    /// Claude was merely thinking. The cost is a short working linger after the final answer —
    /// and hook-equipped agents cancel even that, because their stop hook marks the tab `waiting`
    /// (the UI treats a waiting tab as not-working regardless of this window).
    public static let workingWindow: TimeInterval = 15

    /// Result of one surface's detection: the pane's primary agent (shallowest match — the
    /// user-launched process, never a nested Task-style subagent) plus any other agent-kind
    /// processes found deeper in the tree. Subagent `activity` is always `.idle` — the shared
    /// PTY makes attributing output bytes to a specific descendant impossible; presence/kind/age
    /// is the only thing detection can honestly report.
    public struct AgentDetection: Equatable, Sendable {
        public var primary: AgentSnapshot?
        public var subagents: [AgentSnapshot]

        public init(primary: AgentSnapshot? = nil, subagents: [AgentSnapshot] = []) {
            self.primary = primary
            self.subagents = subagents
        }
    }

    /// Run a scan of every surface's child process tree. The daemon calls this on an adaptive
    /// cadence (30s idle baseline, ~5s while an agent is active — see `AgentScanner`). Returns
    /// the surfaces whose agent detection changed (so the caller can post a single batched IPC
    /// update).
    @discardableResult
    public static func scan(
        table: AgentTable = .default,
        workingWindow: TimeInterval = AgentDetector.workingWindow
    ) -> [String: AgentDetection] {
        rootsLock.lock()
        let roots = surfaceRoots
        rootsLock.unlock()
        // Build the process table once per scan rather than once per surface.
        // With N surfaces this reduces proc_listpids + N×P proc_pidinfo calls to
        // proc_listpids + P proc_pidinfo calls — O(P) total instead of O(N×P).
        let allPIDs = ProcessScan.livePIDs()
        var parentMap: [Int32: Int32] = [:]
        parentMap.reserveCapacity(allPIDs.count)
        for pid in allPIDs { parentMap[pid] = ProcessScan.parentPID(pid) }
        var changes: [String: AgentDetection] = [:]
        for (key, rootPID) in roots {
            let detected = detectAll(pid: rootPID, table: table, allPIDs: allPIDs, parentMap: parentMap)
            outputLock.lock()
            let lastOutput = lastOutputAt[key]
            outputLock.unlock()

            snapshotsLock.lock()
            let prior = lastSurfaceSnapshots[key]
            var resolvedPrimary = detected.primary
            if var r = resolvedPrimary {
                if let lastOutput, Date().timeIntervalSince(lastOutput) <= workingWindow {
                    r.activity = .working
                    r.lastActivityAt = lastOutput
                } else {
                    r.activity = .idle
                    if let prior,
                       prior.kind == r.kind,
                       prior.executable == r.executable,
                       prior.pid == r.pid
                    {
                        r.lastActivityAt = prior.lastActivityAt
                    }
                }
                resolvedPrimary = r
            }

            subagentsLock.lock()
            let priorSubagents = lastSubagents[key] ?? []
            var resolvedSubagents = detected.subagents.map { sub -> AgentSnapshot in
                var r = sub
                if let match = priorSubagents.first(where: { $0.pid == sub.pid && $0.kind == sub.kind }) {
                    r.lastActivityAt = match.lastActivityAt
                }
                return r
            }
            // Merge in the hook-pushed hint (if any) not already covered by a real proc-scan
            // match of the same kind — a real pid is more informative than the hint's sentinel.
            subagentHintsLock.lock()
            if let hint = subagentHints[key], !resolvedSubagents.contains(where: { $0.kind == hint.kind }) {
                resolvedSubagents.append(hint)
            }
            subagentHintsLock.unlock()
            lastSubagents[key] = resolvedSubagents
            subagentsLock.unlock()

            let resolved = AgentDetection(primary: resolvedPrimary, subagents: resolvedSubagents)
            let priorDetection = AgentDetection(primary: prior, subagents: priorSubagents)
            if resolved != priorDetection {
                changes[key] = resolved
            }
            lastSurfaceSnapshots[key] = resolvedPrimary
            snapshotsLock.unlock()
        }
        return changes
    }

    /// Walks descendants of `pid` looking for processes whose resolved binary, argv[0], or
    /// wrapper-launched executable matches any agent in `table`. The shallowest match becomes
    /// `primary` (the user-launched agent always wins over a nested Task-style subagent);
    /// everything else becomes `subagents`, tagged with the nearest matched ancestor's pid.
    public static func detect(pid: Int32, table: AgentTable) -> AgentSnapshot? {
        let allPIDs = ProcessScan.livePIDs()
        var parentMap: [Int32: Int32] = [:]
        parentMap.reserveCapacity(allPIDs.count)
        for p in allPIDs { parentMap[p] = ProcessScan.parentPID(p) }
        return detectAll(pid: pid, table: table, allPIDs: allPIDs, parentMap: parentMap).primary
    }

    struct RawMatch {
        let pid: Int32
        let depth: Int
        let kind: AgentKind
        let executable: String
        let source: MatchSource
    }

    /// Fast variant used by `scan()` — reuses a pre-built parent map so the
    /// process table is only fetched once per scan cycle across all surfaces.
    private static func detectAll(pid: Int32, table: AgentTable,
                                  allPIDs: [Int32], parentMap: [Int32: Int32]) -> AgentDetection {
        var matches: [RawMatch] = []
        for (descendant, depth) in descendantPIDsWithDepth(of: pid, allPIDs: allPIDs, parentMap: parentMap) {
            guard let path = pidPath(descendant) else { continue }
            let arguments = processArguments(descendant) ?? []
            for entry in table.entries {
                guard let source = entry.matchSource(resolvedExecutable: path, arguments: arguments) else { continue }
                matches.append(RawMatch(pid: descendant, depth: depth, kind: entry.kind, executable: path, source: source))
            }
        }
        return resolveDetection(from: matches, parentMap: parentMap)
    }

    /// Pure grouping logic, split out from the real-process walk above so it's testable with
    /// synthetic `RawMatch`/`parentMap` data — no real subprocess tree required. Applies the
    /// wrapper-collapse rule, then picks the shallowest surviving match as `primary` (the
    /// user-launched agent, never a nested Task-style subagent) and tags every other survivor
    /// with its nearest matched ancestor as `parentPID`.
    static func resolveDetection(from matches: [RawMatch], parentMap: [Int32: Int32]) -> AgentDetection {
        guard !matches.isEmpty else { return AgentDetection() }

        // Wrapper collapse: a wrapper process (e.g. `bun` in `bun run claude`) isn't a second
        // agent when its own launch target is among the matches — drop it so `bun run claude`
        // reports one agent, not a phantom parent+child pair.
        var survivors: [RawMatch] = []
        for match in matches {
            if match.source == .wrapperLaunch {
                let launchesAMatch = matches.contains { other in
                    other.pid != match.pid && other.kind == match.kind
                        && isAncestor(match.pid, of: other.pid, parentMap: parentMap)
                }
                if launchesAMatch { continue }
            }
            survivors.append(match)
        }
        guard !survivors.isEmpty else { return AgentDetection() }

        // Primary = shallowest surviving match (the user-launched agent), deterministic tie-break
        // on lower pid so repeated scans of an unchanged tree never flap between two matches.
        let primaryMatch = survivors.min { a, b in
            a.depth != b.depth ? a.depth < b.depth : a.pid < b.pid
        }!
        let primary = AgentSnapshot(kind: primaryMatch.kind, executable: primaryMatch.executable,
                                    pid: primaryMatch.pid, activity: .idle)

        let survivorPIDs = Set(survivors.map { $0.pid })
        let subagents = survivors
            .filter { $0.pid != primaryMatch.pid }
            .map { match -> AgentSnapshot in
                let parent = nearestAncestor(of: match.pid, in: survivorPIDs, parentMap: parentMap) ?? primaryMatch.pid
                return AgentSnapshot(kind: match.kind, executable: match.executable, pid: match.pid,
                                     activity: .idle, parentPID: parent)
            }
        return AgentDetection(primary: primary, subagents: subagents)
    }

    /// True if `ancestor` is a proper ancestor of `pid` in the process tree (depth-capped at 32,
    /// matching every other tree walk in this file).
    private static func isAncestor(_ ancestor: Int32, of pid: Int32, parentMap: [Int32: Int32]) -> Bool {
        var cursor = pid
        var depth = 0
        while let parent = parentMap[cursor], parent != 0, depth < 32 {
            if parent == ancestor { return true }
            cursor = parent
            depth += 1
        }
        return false
    }

    /// Nearest ancestor of `pid` that is itself in `candidates` — used to attach a subagent's
    /// `parentPID` to the closest OTHER matched agent process above it, not necessarily the root.
    private static func nearestAncestor(of pid: Int32, in candidates: Set<Int32>, parentMap: [Int32: Int32]) -> Int32? {
        var cursor = pid
        var depth = 0
        while let parent = parentMap[cursor], parent != 0, depth < 32 {
            if candidates.contains(parent) { return parent }
            cursor = parent
            depth += 1
        }
        return nil
    }

    private static func descendantPIDs(of pid: Int32) -> [Int32] {
        let allPIDs = ProcessScan.livePIDs()
        guard !allPIDs.isEmpty else { return [] }
        var parents: [Int32: Int32] = [:]
        parents.reserveCapacity(allPIDs.count)
        for candidate in allPIDs { parents[candidate] = ProcessScan.parentPID(candidate) }
        return descendantPIDs(of: pid, allPIDs: allPIDs, parentMap: parents)
    }

    /// Shared with `ListeningPortScanner` (P39 G1), which reuses the same pre-built
    /// `allPIDs`/`parentMap` pass rather than re-walking `proc_listpids` per surface.
    static func descendantPIDs(of pid: Int32,
                                       allPIDs: [Int32],
                                       parentMap: [Int32: Int32]) -> [Int32] {
        descendantPIDsWithDepth(of: pid, allPIDs: allPIDs, parentMap: parentMap).map { $0.pid }
    }

    /// Same walk as `descendantPIDs`, but also returns each descendant's hop-count from `pid`
    /// (0 = direct child) so callers can pick the shallowest match deterministically instead of
    /// relying on `proc_listpids`' arbitrary iteration order.
    private static func descendantPIDsWithDepth(of pid: Int32,
                                                 allPIDs: [Int32],
                                                 parentMap: [Int32: Int32]) -> [(pid: Int32, depth: Int)] {
        guard !allPIDs.isEmpty else { return [] }
        var result: [(pid: Int32, depth: Int)] = []
        for candidate in allPIDs where candidate != pid {
            var cursor: Int32 = candidate
            var depth = 0
            while let parent = parentMap[cursor], parent != 0, depth < 32 {
                if parent == pid {
                    result.append((pid: candidate, depth: depth))
                    break
                }
                cursor = parent
                depth += 1
            }
        }
        return result
    }

    private static func pidPath(_ pid: Int32) -> String? {
        #if canImport(Darwin)
        var buffer = [UInt8](repeating: 0, count: Int(MAXPATHLEN))
        let length = buffer.withUnsafeMutableBufferPointer { ptr -> Int32 in
            proc_pidpath(pid, ptr.baseAddress, UInt32(MAXPATHLEN))
        }
        guard length > 0 else { return nil }
        let prefix = buffer.prefix(Int(length))
        return String(decoding: prefix, as: UTF8.self)
        #else
        // /proc/<pid>/exe is a symlink to the running binary. readlink doesn't NUL-terminate, so
        // decode exactly the `len` bytes it wrote.
        var buffer = [CChar](repeating: 0, count: 4096)
        let len = readlink("/proc/\(pid)/exe", &buffer, buffer.count - 1)
        guard len > 0 else { return nil }
        return String(decoding: buffer[0 ..< len].map { UInt8(bitPattern: $0) }, as: UTF8.self)
        #endif
    }

    /// Full argv for `pid`, preserving argv[0] as invoked. Darwin exposes this
    /// via KERN_PROCARGS2 after `exec_path`; Linux uses `/proc/<pid>/cmdline`.
    /// The parser is argc-bounded on Darwin so environment bytes after argv are
    /// never interpreted as command arguments.
    private static func processArguments(_ pid: Int32) -> [String]? {
        #if canImport(Darwin)
        var size = 0
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > MemoryLayout<Int32>.size else { return nil }
        var buffer = [UInt8](repeating: 0, count: size)
        guard buffer.withUnsafeMutableBufferPointer({ ptr -> Int32 in
            sysctl(&mib, 3, ptr.baseAddress, &size, nil, 0)
        }) == 0 else { return nil }

        let argc: Int32 = buffer.withUnsafeBytes { rawPtr in
            rawPtr.loadUnaligned(as: Int32.self)
        }
        var cursor = MemoryLayout<Int32>.size
        while cursor < size, buffer[cursor] != 0 { cursor += 1 } // skip exec_path
        while cursor < size, buffer[cursor] == 0 { cursor += 1 } // skip NUL padding
        var args: [String] = []
        var read: Int32 = 0
        while read < argc, cursor < size {
            let start = cursor
            while cursor < size, buffer[cursor] != 0 { cursor += 1 }
            if cursor > start {
                args.append(String(decoding: buffer[start..<cursor], as: UTF8.self))
            }
            cursor += 1
            read += 1
        }
        return args.isEmpty ? nil : args
        #else
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "/proc/\(pid)/cmdline")),
              !data.isEmpty else { return nil }
        let args = data.split(separator: 0).map { String(decoding: $0, as: UTF8.self) }
        return args.isEmpty ? nil : args
        #endif
    }
}

/// Whether a matched process IS the agent, or merely launched it (a wrapper like `bun`/`node`/
/// `python3`). See `AgentTableEntry.matchSource`.
enum MatchSource: Equatable {
    case ownProcess
    case wrapperLaunch
}

public struct AgentTableEntry: Codable, Sendable {
    public let kind: AgentKind
    public let executables: [String]

    public init(kind: AgentKind, executables: [String]) {
        self.kind = kind
        self.executables = executables.map { $0.lowercased() }
    }

    public func matches(executable: String) -> Bool {
        executables.contains(executable)
    }

    /// True if any of `names` (e.g. resolved binary basename + argv[0] name) matches.
    public func matchesAny(_ names: Set<String>) -> Bool {
        executables.contains { names.contains($0) }
    }

    public func matchesProcess(resolvedExecutable: String, arguments: [String]) -> Bool {
        matchSource(resolvedExecutable: resolvedExecutable, arguments: arguments) != nil
    }

    /// Whether a match came from the process's own identity (resolved binary / argv[0]) or
    /// only from a wrapper's launch target (e.g. `bun run claude` — the wrapper itself isn't
    /// the agent, its launched target is). Lets `AgentDetector.resolveDetection` tell a wrapper
    /// process apart from the agent it launched, so the wrapper doesn't get double-counted
    /// as a second (phantom) agent alongside its own target.
    func matchSource(resolvedExecutable: String, arguments: [String]) -> MatchSource? {
        let (ownNames, wrapperNames) = Self.matchableProcessNames(resolvedExecutable: resolvedExecutable, arguments: arguments)
        if executables.contains(where: ownNames.contains) { return .ownProcess }
        if executables.contains(where: wrapperNames.contains) { return .wrapperLaunch }
        return nil
    }

    /// Builds every basename that can identify a process as an agent: resolved
    /// executable, argv[0], and the launcher target when argv0/resolved is a
    /// known wrapper. Non-wrapper commands do not scan arbitrary arguments, so
    /// `vim hermes-notes.txt` cannot become a false Hermes match. `env` gets
    /// one nested-wrapper pass (`env FOO=1 python3 hermes --tui`) to cover the
    /// common env→runtime shape without turning this into an unbounded parser.
    /// Returns (ownNames, wrapperLaunchNames) separately so callers can distinguish
    /// "this process IS the agent" from "this process launched the agent".
    private static func matchableProcessNames(resolvedExecutable: String, arguments: [String]) -> (own: Set<String>, wrapperLaunch: Set<String>) {
        var ownNames: Set<String> = []
        var wrapperNames: Set<String> = []
        insertProcessName(resolvedExecutable, into: &ownNames)
        let invokedName: String?
        if let invoked = arguments.first {
            insertProcessName(invoked, into: &ownNames)
            invokedName = processName(invoked)
        } else {
            invokedName = nil
        }

        let resolvedName = processName(resolvedExecutable)
        if let wrapperName = [invokedName, resolvedName].compactMap({ $0 }).first(where: isWrapperExecutable),
           let launchSearchStart = launchArgumentSearchStart(arguments: arguments, wrapperName: wrapperName),
           let launchIndex = firstLaunchArgumentIndex(in: arguments, startIndex: launchSearchStart, wrapperName: wrapperName)
        {
            insertProcessName(arguments[launchIndex], into: &wrapperNames)
            if wrapperName == "env",
               let nestedName = processName(arguments[launchIndex]),
               isWrapperExecutable(nestedName),
               let nestedIndex = firstLaunchArgumentIndex(in: arguments, startIndex: launchIndex + 1, wrapperName: nestedName)
            {
                insertProcessName(arguments[nestedIndex], into: &wrapperNames)
            }
        }

        return (ownNames, wrapperNames)
    }

    /// Returns where wrapper-target scanning should begin. When argv[0] is the
    /// wrapper, scan after it; when only the resolved executable is the wrapper,
    /// argv[0] may be the launcher target name and must remain searchable.
    private static func launchArgumentSearchStart(arguments: [String], wrapperName: String) -> Int? {
        guard let argv0 = arguments.first else { return nil }
        return processName(argv0) == wrapperName ? 1 : 0
    }

    /// Finds the first argv element that represents the wrapper's launched
    /// executable, skipping known wrapper flags and their operands.
    private static func firstLaunchArgumentIndex(in arguments: [String], startIndex: Int, wrapperName: String) -> Int? {
        var index = startIndex
        while index < arguments.count {
            let argument = arguments[index]
            if shouldSkipLauncherSubcommand(argument, at: index, startIndex: startIndex, wrapperName: wrapperName) {
                index += 1
                continue
            }
            if wrapperName == "env", isEnvironmentAssignment(argument) {
                index += 1
                continue
            }
            if argument == "--" {
                let next = index + 1
                return next < arguments.count ? next : nil
            }
            if argument.hasPrefix("-") {
                switch optionBehavior(argument, wrapperName: wrapperName) {
                case .keepScanning:
                    index += 1
                case .skipValue:
                    index += 2
                case .matchValue:
                    let next = index + 1
                    return next < arguments.count ? next : nil
                case .stopScanning:
                    return nil
                }
                continue
            }
            return index
        }
        return nil
    }

    private static func shouldSkipLauncherSubcommand(_ argument: String, at index: Int, startIndex: Int, wrapperName: String) -> Bool {
        index == startIndex && ["bun", "deno"].contains(wrapperName) && argument == "run"
    }

    private enum WrapperOptionBehavior {
        case keepScanning
        case skipValue
        case matchValue
        case stopScanning
    }

    /// Classifies wrapper flags by how they affect executable discovery. `-c`
    /// and eval-style flags stop the scan because their next value is code, not
    /// an executable argv token; any spawned child is detected by the descendant
    /// process walk instead.
    private static func optionBehavior(_ option: String, wrapperName: String) -> WrapperOptionBehavior {
        if option.contains("=") { return .keepScanning }
        switch wrapperName {
        case "env":
            return ["-u", "--unset", "-C", "--chdir", "-S", "--split-string"].contains(option) ? .skipValue : .keepScanning
        case "node", "bun", "deno":
            if ["-e", "--eval"].contains(option) { return .stopScanning }
            return ["-r", "--require", "--loader", "--import"].contains(option) ? .skipValue : .keepScanning
        case "bash", "sh", "zsh", "fish":
            if option == "-c" { return .stopScanning }
            return option == "-o" ? .skipValue : .keepScanning
        default:
            guard isPythonExecutable(wrapperName) else { return .keepScanning }
            if option == "-m" { return .matchValue }
            if option == "-c" { return .stopScanning }
            return ["-W", "-X"].contains(option) ? .skipValue : .keepScanning
        }
    }

    private static func isEnvironmentAssignment(_ argument: String) -> Bool {
        guard let equals = argument.firstIndex(of: "=") else { return false }
        return equals != argument.startIndex
    }

    private static func isWrapperExecutable(_ name: String) -> Bool {
        isPythonExecutable(name) || ["node", "deno", "bun", "bash", "sh", "zsh", "fish", "env", "tsx"].contains(name)
    }

    private static func isPythonExecutable(_ name: String) -> Bool {
        name == "python" || name == "python3" || name.hasPrefix("python3.")
    }

    private static func insertProcessName(_ raw: String, into names: inout Set<String>) {
        guard let name = processName(raw) else { return }
        names.insert(name)
    }

    private static func processName(_ raw: String) -> String? {
        let name = (raw as NSString).lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return name.isEmpty || name == "." || name == "/" ? nil : name
    }
}

public struct AgentTable: Codable, Sendable {
    public let entries: [AgentTableEntry]

    public init(entries: [AgentTableEntry]) {
        self.entries = entries
    }

    public static let `default` = AgentTable(entries: [
        AgentTableEntry(kind: .codex, executables: ["codex", "codex-cli"]),
        AgentTableEntry(kind: .claudeCode, executables: ["claude", "claude-code", "claude-cli"]),
        AgentTableEntry(kind: .cursor, executables: ["cursor-agent", "cursor", "cursor-cli"]),
        AgentTableEntry(kind: .grok, executables: ["grok", "grok-build", "grok-cli"]),
        AgentTableEntry(kind: .pi, executables: ["pi", "pi-cli"]),
        AgentTableEntry(kind: .hermes, executables: ["hermes"]),
        AgentTableEntry(kind: .openClaw, executables: ["openclaw", "openclaude"]),
        AgentTableEntry(kind: .openCode, executables: ["opencode"]),
        AgentTableEntry(kind: .aider, executables: ["aider"]),
        AgentTableEntry(kind: .gemini, executables: ["gemini", "gemini-cli"]),
        AgentTableEntry(kind: .goose, executables: ["goose"]),
        AgentTableEntry(kind: .antigravity, executables: ["antigravity", "antigravity-cli", "agy"]),
        AgentTableEntry(kind: .kiro, executables: ["kiro", "kiro-cli"]),
    ])

    public static func loadFromDisk() -> AgentTable {
        let path = KouenPaths.applicationSupport.appendingPathComponent("agents.json")
        guard FileManager.default.fileExists(atPath: path.path),
              let data = try? Data(contentsOf: path),
              let table = try? JSONDecoder().decode(AgentTable.self, from: data)
        else { return .default }
        return table
    }
}
