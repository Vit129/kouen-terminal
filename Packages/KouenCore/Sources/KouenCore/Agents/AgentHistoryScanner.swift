import Foundation
import KouenIPC
#if canImport(SQLite3)
import SQLite3
#endif

/// A turn snippet in an agent session history.
public struct AgentHistoryTurn: Sendable, Equatable, Codable {
    public let role: String // "YOU" or "AGENT"
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

/// Where a session is actually running, learned from a live CLI listing (`claude agents
/// --json` today; a per-vendor equivalent could feed the same field later) rather than
/// inferred from an on-disk transcript. `.local` is the default for every other scanner in
/// this file — a plain transcript is silent about where its session is running right now.
public enum AgentSessionPlacement: String, Sendable, Equatable, Codable {
    case local
    /// Running on this machine, and currently steerable from the Claude Desktop/mobile app or
    /// claude.ai/code (`claude --remote-control`).
    case remoteControl = "remote-control"
    /// Running in an Anthropic cloud container (`claude --cloud`) — its transcript lives there,
    /// not on this disk, so `scanClaude()`'s JSONL walk can never see it on its own.
    case cloud
    /// Running locally, detached from any terminal (`claude --bg`).
    case background
    /// Copilot Chat inside VS Code — its own store, which the Copilot CLI can't resume. View
    /// and handoff only.
    case vscode
}

/// A parsed agent session record from local transcripts.
public struct AgentSessionRecord: Identifiable, Sendable, Equatable {
    public let id: String
    public let agentKind: AgentKind
    public let title: String
    public let projectPath: String
    public let projectName: String
    public let gitBranch: String?
    public let modelName: String?
    public let messageCount: Int
    public let updatedAt: Date
    public let firstPrompt: String
    public let latestTurns: [AgentHistoryTurn]
    public let transcriptPath: String
    public let worktreeAvailable: Bool
    /// `.local` unless a live CLI listing (`scanClaudeAgentsCLI`) matched this record by id or
    /// supplied it outright — see `AgentSessionPlacement`.
    public let placement: AgentSessionPlacement
    /// Live status string from that same listing (e.g. `"busy"`/`"idle"`), `nil` for a
    /// transcript-only record with no live counterpart found.
    public let liveStatus: String?
    /// When set, History resume uses this verbatim instead of `agentKind.resumeCommand(...)` —
    /// needed for `.cloud`/`.background` placements, where a plain `--resume` either can't
    /// reach the session or races its live process for the session lock.
    public let resumeCommandOverride: String?

    public init(
        id: String,
        agentKind: AgentKind,
        title: String,
        projectPath: String,
        projectName: String,
        gitBranch: String? = nil,
        modelName: String? = nil,
        messageCount: Int,
        updatedAt: Date,
        firstPrompt: String,
        latestTurns: [AgentHistoryTurn] = [],
        transcriptPath: String,
        worktreeAvailable: Bool,
        placement: AgentSessionPlacement = .local,
        liveStatus: String? = nil,
        resumeCommandOverride: String? = nil
    ) {
        self.id = id
        self.agentKind = agentKind
        self.title = title
        self.projectPath = projectPath
        self.projectName = projectName
        self.gitBranch = gitBranch
        self.modelName = modelName
        self.messageCount = messageCount
        self.updatedAt = updatedAt
        self.firstPrompt = firstPrompt
        self.latestTurns = latestTurns
        self.transcriptPath = transcriptPath
        self.worktreeAvailable = worktreeAvailable
        self.placement = placement
        self.liveStatus = liveStatus
        self.resumeCommandOverride = resumeCommandOverride
    }

    /// The command History resume should type into a fresh pane: `resumeCommandOverride` when
    /// set, else the ordinary per-agent-kind resume command.
    public func effectiveResumeCommand(mode: AgentSessionMode = .local) -> String {
        resumeCommandOverride ?? AgentLaunchCommands.resume(kind: agentKind, sessionID: id, mode: mode)
    }

    @inlinable
    public func effectiveResumeCommand(claudeMode: ClaudeSessionMode) -> String {
        effectiveResumeCommand(mode: claudeMode)
    }

    /// Copies this record with a live placement/status attached, deriving the matching resume
    /// override. Used by `scanAll()` to enrich a transcript-derived record once a `claude
    /// agents --json` row matches it by session id.
    func withLivePlacement(_ placement: AgentSessionPlacement, status: String?) -> AgentSessionRecord {
        AgentSessionRecord(
            id: id, agentKind: agentKind, title: title, projectPath: projectPath, projectName: projectName,
            gitBranch: gitBranch, modelName: modelName, messageCount: messageCount, updatedAt: updatedAt,
            firstPrompt: firstPrompt, latestTurns: latestTurns, transcriptPath: transcriptPath,
            worktreeAvailable: worktreeAvailable, placement: placement, liveStatus: status,
            resumeCommandOverride: AgentSessionRecord.resumeOverride(placement: placement, sessionID: id)
        )
    }

    /// `nil` for `.local`/`.remoteControl` — both resolve through the ordinary
    /// `agentKind.resumeCommand`/`ClaudeSessionMode` path already.
    fileprivate static func resumeOverride(placement: AgentSessionPlacement, sessionID: String) -> String? {
        switch placement {
        // `--teleport`, not `--cloud <id>`: attaching to an existing cloud session with
        // `--cloud` only works together with `-p` (it posts one message and exits). Teleport
        // pulls the session and its branch into this pane, which is what a resume should do.
        case .cloud: return "claude --teleport \(sessionID)"
        // `claude attach <id>` per `claude --help`: "<id> is the short id that `claude --bg`
        // prints and `claude agents` lists" — assumed to be the same `sessionId` this scanner
        // reads from `claude agents --json`, since that's the only id field the listing has.
        // Not verified against a real `--bg` session (none available to test against here).
        case .background: return "claude attach \(sessionID)"
        case .local, .remoteControl, .vscode: return nil
        }
    }
}

/// One row from `claude agents --json`. Sendable value copied out of the actor-isolated scan.
struct LiveClaudeAgentEntry: Sendable {
    let sessionId: String
    let kind: String
    let cwd: String?
    let name: String?
    let status: String?
    let startedAt: Date?

    /// `nil` for `"interactive"` (and any future/unrecognized kind) — a plain local session is
    /// already fully covered by `scanClaude()`'s transcript walk, so merging it in here would
    /// only risk a duplicate row if id-matching ever missed.
    var placement: AgentSessionPlacement? {
        switch kind {
        case "cloud": return .cloud
        case "background": return .background
        case "remote-control": return .remoteControl
        default: return nil
        }
    }

    /// Builds a standalone record for a live session with no matching local transcript — the
    /// normal case for `.cloud` (the transcript lives in the cloud container, not on this
    /// disk) and possible for `.background`/`.remote-control` right after launch, before the
    /// first transcript write lands.
    func makeSyntheticRecord(placement: AgentSessionPlacement) -> AgentSessionRecord {
        let resolvedCwd = cwd?.isEmpty == false ? cwd! : FileManager.default.homeDirectoryForCurrentUser.path
        let projectName = (resolvedCwd as NSString).lastPathComponent
        let resolvedTitle = (name?.isEmpty == false ? name! : nil) ?? "Claude Session \(sessionId.prefix(8))"
        return AgentSessionRecord(
            id: sessionId,
            agentKind: .claudeCode,
            title: String(resolvedTitle.prefix(120)),
            projectPath: resolvedCwd,
            projectName: projectName.isEmpty ? "Home" : projectName,
            // Unknown from this source — `claude agents --json` reports process/liveness
            // state, not transcript contents. `0` (not the file-based scanners' real count) is
            // the honest value here, not a stand-in for "empty conversation".
            messageCount: 0,
            updatedAt: startedAt ?? Date(),
            firstPrompt: "",
            transcriptPath: placement == .cloud ? "cloud://\(sessionId)" : "",
            worktreeAvailable: FileManager.default.fileExists(atPath: resolvedCwd),
            placement: placement,
            liveStatus: status,
            resumeCommandOverride: AgentSessionRecord.resumeOverride(placement: placement, sessionID: sessionId)
        )
    }
}

/// Background actor that scans local JSONL transcripts from Claude Code,
/// Antigravity CLI, and Codex CLI to provide a unified history view.
public actor AgentHistoryScanner {
    public static let shared = AgentHistoryScanner()

    /// How many trailing lines/events of a transcript to scan for the "latest turns" preview.
    static let turnScanWindow = 60
    /// How many of the most recent turns to keep once found.
    static let maxLatestTurns = 10
    /// Max characters kept per turn — enough to actually convey what happened, not just a
    /// fragment (the card preview clips visually with lineLimit; this only bounds memory/copy size).
    static let turnContentLimit = 800

    private struct FileCacheEntry: Sendable {
        let mtime: Date
        let size: Int
        let record: AgentSessionRecord
    }

    /// Finds the first file matching `name` anywhere under `directory`, without assuming a
    /// fixed nesting depth — used so a vendor's on-disk layout change (CLI vs IDE build, a
    /// future schema bump) doesn't silently stop this scanner from finding sessions.
    static func findFile(named name: String, under directory: URL) -> URL? {
        // No .skipsHiddenFiles: the real data lives under dot-prefixed dirs like
        // `.system_generated/logs/` — skipping hidden entries would miss it entirely.
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey]
        ) else { return nil }
        for case let url as URL in enumerator where url.lastPathComponent == name {
            return url
        }
        return nil
    }

    /// Same rationale as `findFile` above — recursively collects every file under `directory`
    /// whose name matches `predicate`, without assuming a fixed nesting depth.
    static func findFiles(matching predicate: (String) -> Bool, under directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey]
        ) else { return [] }
        var results: [URL] = []
        for case let url as URL in enumerator where predicate(url.lastPathComponent) {
            results.append(url)
        }
        return results
    }

    private var cachedRecords: [AgentSessionRecord] = []
    private let cloudSessionStore: ClaudeCloudSessionStore
    private var fileCache: [String: FileCacheEntry] = [:]
    private var lastScanAt: Date = .distantPast
    private let ftsIndex: AgentHistoryFTSIndex
    #if canImport(SQLite3)
    private var copilotCache: (mtime: Date, size: Int, records: [AgentSessionRecord])?
    #endif

    public init(ftsIndex: AgentHistoryFTSIndex = .shared) {
        self.cloudSessionStore = ClaudeCloudSessionStore()
        self.ftsIndex = ftsIndex
    }

    /// Returns cached records if fresh (< 5s), otherwise rescans.
    public func getOrScan(force: Bool = false) async -> [AgentSessionRecord] {
        if !force && !cachedRecords.isEmpty && Date().timeIntervalSince(lastScanAt) < 5.0 {
            return cachedRecords
        }
        return await scanAll()
    }

    /// Scans all supported agent transcripts on disk concurrently with mtime caching, then
    /// enriches/extends the Claude Code rows with live placement from `claude agents --json`
    /// (cloud/background/remote-control) — see `mergeLivePlacements`.
    public func scanAll() async -> [AgentSessionRecord] {
        async let claudeTask = scanClaude()
        async let antigravityTask = scanAntigravity()
        async let codexTask = scanCodex()
        async let copilotTask = scanCopilot()
        async let vscodeTask = scanVSCodeCopilotChat()
        async let liveClaudeTask = scanClaudeAgentsCLI()

        var results: [AgentSessionRecord] = []
        results.append(contentsOf: await claudeTask)
        results.append(contentsOf: await antigravityTask)
        results.append(contentsOf: await codexTask)
        results.append(contentsOf: await copilotTask)
        results.append(contentsOf: await vscodeTask)

        // Cloud sessions stay listed after their pane closes: remember every cloud row the live
        // scan sees and add the ones that aren't live right now as offline rows.
        let live = await liveClaudeTask
        let remembered = cloudSessionStore.remember(live)
        results = Self.mergeLivePlacements(
            results, live: live + ClaudeCloudSessionStore.offlineRows(remembered, excluding: live)
        )

        results.sort { $0.updatedAt > $1.updatedAt }
        cachedRecords = results
        lastScanAt = Date()
        return results
    }

    /// Matches `live` rows onto `records` by session id, enriching the match in place; a
    /// `.cloud`/`.background`/`.remote-control` row with no local transcript match (the normal
    /// case for `.cloud`) becomes a new synthetic record instead. Order among unmatched
    /// entries doesn't matter — `scanAll()` re-sorts by `updatedAt` right after.
    static func mergeLivePlacements(_ records: [AgentSessionRecord], live: [LiveClaudeAgentEntry]) -> [AgentSessionRecord] {
        guard !live.isEmpty else { return records }
        // Built by hand rather than `Dictionary(uniqueKeysWithValues:)`, which traps on a
        // duplicate key — cross-scanner id collisions should never happen (each agent kind
        // draws ids from its own UUID/db-key namespace) but this must never crash on one.
        var byID: [String: AgentSessionRecord] = [:]
        var order: [String] = []
        for record in records {
            if byID[record.id] == nil { order.append(record.id) }
            byID[record.id] = record
        }

        for entry in live {
            guard let placement = entry.placement else { continue }
            if let existing = byID[entry.sessionId] {
                byID[entry.sessionId] = existing.withLivePlacement(placement, status: entry.status)
            } else {
                byID[entry.sessionId] = entry.makeSyntheticRecord(placement: placement)
                order.append(entry.sessionId)
            }
        }
        return order.compactMap { byID[$0] }
    }

    // MARK: - Claude Code Scanner

    public func scanClaude() async -> [AgentSessionRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let claudeProjectsDir = home.appendingPathComponent(".claude/projects")
        guard FileManager.default.fileExists(atPath: claudeProjectsDir.path) else { return [] }

        var records: [AgentSessionRecord] = []
        guard let projectFolders = try? FileManager.default.contentsOfDirectory(atPath: claudeProjectsDir.path) else {
            return []
        }

        for folder in projectFolders {
            if folder.hasPrefix(".") { continue }
            let folderURL = claudeProjectsDir.appendingPathComponent(folder)
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: folderURL.path) else { continue }

            for file in files where file.hasSuffix(".jsonl") {
                let fileURL = folderURL.appendingPathComponent(file)
                let path = fileURL.path

                if let rv = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                   let mtime = rv.contentModificationDate,
                   let size = rv.fileSize,
                   let cached = fileCache[path],
                   cached.mtime == mtime && cached.size == size {
                    if !ftsIndex.needsReindex(sessionID: cached.record.id, mtime: mtime, fileSize: size) {
                        records.append(cached.record)
                        continue
                    }
                }

                if let record = parseClaudeTranscript(fileURL: fileURL) {
                    if let rv = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                       let mtime = rv.contentModificationDate,
                       let size = rv.fileSize {
                        fileCache[path] = FileCacheEntry(mtime: mtime, size: size, record: record)
                    }
                    records.append(record)
                }
            }
        }
        return records
    }

    private func parseClaudeTranscript(fileURL: URL) -> AgentSessionRecord? {
        guard let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe),
              let string = String(data: data, encoding: .utf8) else { return nil }

        let sessionID = fileURL.deletingPathExtension().lastPathComponent
        let lines = string.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !lines.isEmpty else { return nil }

        var cwd: String?
        var gitBranch: String?
        var modelName: String?
        var firstPrompt: String?
        var timestamp: Date?
        var turns: [AgentHistoryTurn] = []

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackIso = ISO8601DateFormatter()

        let messageCount = lines.count

        // 1. Scan prefix for metadata, model name, and first prompt
        for line in lines.prefix(40) {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any] else {
                continue
            }

            if cwd == nil, let c = json["cwd"] as? String { cwd = c }
            if gitBranch == nil, let b = json["gitBranch"] as? String { gitBranch = b }

            if let tsStr = json["timestamp"] as? String, timestamp == nil {
                timestamp = isoFormatter.date(from: tsStr) ?? fallbackIso.date(from: tsStr)
            }

            if let msg = json["message"] as? [String: Any] {
                if modelName == nil, let m = msg["model"] as? String {
                    modelName = m
                }
                let role = (msg["role"] as? String)?.lowercased() ?? ""
                if role == "user" && firstPrompt == nil {
                    var textContent = ""
                    if let contentStr = msg["content"] as? String {
                        textContent = contentStr
                    } else if let contentArr = msg["content"] as? [[String: Any]] {
                        for item in contentArr {
                            if let text = item["text"] as? String {
                                textContent += text
                            }
                        }
                    }
                    let trimmed = textContent.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        firstPrompt = trimmed
                    }
                }
            }
            if cwd != nil && firstPrompt != nil { break }
        }

        // 2. Scan suffix for latest turns
        for line in lines.suffix(Self.turnScanWindow) {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any],
                  let msg = json["message"] as? [String: Any] else {
                continue
            }

            let role = (msg["role"] as? String)?.lowercased() ?? ""
            var textContent = ""
            if let contentStr = msg["content"] as? String {
                textContent = contentStr
            } else if let contentArr = msg["content"] as? [[String: Any]] {
                for item in contentArr {
                    if let text = item["text"] as? String {
                        textContent += text
                    }
                }
            }

            let trimmed = textContent.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let turnRole = (role == "user") ? "YOU" : "AGENT"
                if turns.count >= Self.maxLatestTurns { turns.removeFirst() }
                turns.append(AgentHistoryTurn(role: turnRole, content: String(trimmed.prefix(Self.turnContentLimit))))
            }
        }

        var fullTranscriptParts: [String] = []
        var filesEdited: Set<String> = []
        var toolsCalled: Set<String> = []

        // Extract full conversation text, tools, and edited files across all lines
        for line in lines {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any],
                  let msg = json["message"] as? [String: Any] else {
                continue
            }
            if let contentStr = msg["content"] as? String {
                let clean = contentStr.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty { fullTranscriptParts.append(clean) }
            } else if let contentArr = msg["content"] as? [[String: Any]] {
                for item in contentArr {
                    if let type = item["type"] as? String {
                        if type == "text", let text = item["text"] as? String {
                            let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !clean.isEmpty { fullTranscriptParts.append(clean) }
                        } else if type == "tool_use" {
                            if let name = item["name"] as? String, !name.isEmpty {
                                toolsCalled.insert(name)
                            }
                            if let input = item["input"] as? [String: Any] {
                                for key in ["file_path", "path", "filePath", "TargetFile"] {
                                    if let pathStr = input[key] as? String, !pathStr.isEmpty {
                                        filesEdited.insert((pathStr as NSString).lastPathComponent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        let finalCwd = cwd ?? FileManager.default.homeDirectoryForCurrentUser.path
        let projectName = (finalCwd as NSString).lastPathComponent
        let title = firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) ?? "Claude Session \(sessionID.prefix(8))"
        let modDate = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? timestamp ?? Date()
        let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? string.utf8.count

        ftsIndex.indexSession(
            sessionID: sessionID,
            title: title,
            firstPrompt: firstPrompt ?? "",
            fullTranscript: fullTranscriptParts.joined(separator: "\n"),
            gitBranch: gitBranch,
            repoName: projectName,
            agentName: AgentKind.claudeCode.displayName,
            filesEdited: filesEdited.joined(separator: " "),
            toolsCalled: toolsCalled.joined(separator: " "),
            transcriptPath: fileURL.path,
            mtime: modDate,
            fileSize: fileSize
        )

        return AgentSessionRecord(
            id: sessionID,
            agentKind: .claudeCode,
            title: String(title.prefix(120)),
            projectPath: finalCwd,
            projectName: projectName.isEmpty ? "Home" : projectName,
            gitBranch: gitBranch,
            modelName: modelName,
            messageCount: messageCount,
            updatedAt: modDate,
            firstPrompt: firstPrompt ?? "",
            latestTurns: turns,
            transcriptPath: fileURL.path,
            worktreeAvailable: FileManager.default.fileExists(atPath: finalCwd)
        )
    }

    // MARK: - Live Claude Agents CLI ("claude agents --json")

    /// Resolve `claude`'s path the same way `MobileBridgeServer.cachedClaudePath` and
    /// `GitHubCLIClient.cachedGhPath` already do: common install locations first (found via
    /// live-testing — the curl-installer default `~/.local/bin` isn't on a launchd-spawned
    /// process's PATH, so a bare `which` fallback alone would miss it), then `which claude`.
    /// Last resort is a login zsh's `whence -p claude`: the GUI app is launched with a minimal
    /// PATH, so npm/nvm installs are only reachable through the user's own shell profile, and
    /// `claude` is often a zsh *function* there, which `whence -p` sees through to the real
    /// binary (same probe `ClaudeAdapter.probeCommand` uses). Duplicated rather than shared
    /// because `KouenCore` can't depend on `KouenDaemon`, where the daemon's copy lives.
    private static let cachedClaudePath: String? = {
        let home = NSHomeDirectory()
        let paths = [
            home + "/.local/bin/claude",
            home + "/.claude/local/claude",   // `claude migrate-installer` location
            "/opt/homebrew/bin/claude",
            "/usr/local/bin/claude",
        ]
        if let found = paths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            return found
        }
        if let path = AgentHistoryScanner.firstOutputLine(of: "/usr/bin/which", ["claude"]) { return path }
        if FileManager.default.fileExists(atPath: "/bin/zsh") {
            return AgentHistoryScanner.firstOutputLine(of: "/bin/zsh", ["-lic", "whence -p claude"])
        }
        return nil
    }()

    /// First stdout line of a short probe command, only if it names an existing file.
    private static func firstOutputLine(of executable: String, _ arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        process.standardInput = FileHandle.nullDevice
        // A login shell sources the user's whole profile; never let a slow/odd rc wedge the scan.
        let timeoutWork = DispatchWorkItem { if process.isRunning { process.terminate() } }
        DispatchQueue.global().asyncAfter(deadline: .now() + AgentHistoryScanner.liveListTimeout, execute: timeoutWork)
        defer { timeoutWork.cancel() }
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0,
                  let path = String(data: data, encoding: .utf8)?
                      .split(separator: "\n").last.map({ $0.trimmingCharacters(in: .whitespaces) }),
                  !path.isEmpty, FileManager.default.fileExists(atPath: path)
            else { return nil }
            return path
        } catch {
            return nil
        }
    }

    /// Ceiling on the `claude agents --json` call — it's normally near-instant (a local query
    /// against the CLI's own session registry), but must never be allowed to wedge this actor
    /// if `claude` hangs (e.g. a stuck auth/network check for a cloud session).
    private static let liveListTimeout: TimeInterval = 5

    /// Live sessions `claude` itself currently knows about — interactive, background, cloud,
    /// and remote-control-enabled. Best-effort: `[]` (never throws) if `claude` isn't
    /// installed, isn't logged in, prints something this can't parse, or times out. Callers
    /// merge this into the transcript-derived records rather than trusting it alone, since it
    /// has no prompt/turn content — only enough to say *where* a session is running.
    ///
    /// Not `public`: `LiveClaudeAgentEntry` is internal, and nothing outside `scanAll()` (same
    /// file) needs this directly — everything else consumes the merged `AgentSessionRecord`.
    func scanClaudeAgentsCLI() async -> [LiveClaudeAgentEntry] {
        guard let claudePath = Self.cachedClaudePath else { return [] }
        return Self.runClaudeAgentsJSON(claudePath: claudePath)
    }

    private static func runClaudeAgentsJSON(claudePath: String) -> [LiveClaudeAgentEntry] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: claudePath)
        process.arguments = ["agents", "--json"]
        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = FileHandle.nullDevice

        let timeoutFlag = TimeoutFlag()
        let timeoutWork = DispatchWorkItem {
            guard process.isRunning else { return }
            timeoutFlag.markFired()
            process.terminate()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.liveListTimeout, execute: timeoutWork)

        do {
            try process.run()
            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            timeoutWork.cancel()
            guard !timeoutFlag.didFire, process.terminationStatus == 0 else { return [] }
            return parseLiveAgentsJSON(data)
        } catch {
            timeoutWork.cancel()
            return []
        }
    }

    /// Boxes the "did our own timeout fire" flag — mirrors `VerificationRunner.TimeoutFlag`
    /// (same rationale: `DispatchWorkItem.isCancelled` can't answer this on its own).
    private final class TimeoutFlag: @unchecked Sendable {
        private let lock = NSLock()
        private var fired = false
        func markFired() { lock.lock(); fired = true; lock.unlock() }
        var didFire: Bool { lock.lock(); defer { lock.unlock() }; return fired }
    }

    /// `claude agents --json` prints an array of `{pid?, cwd?, kind, startedAt?, sessionId,
    /// name?, status?}`. Only `kind`/`sessionId` are treated as required — everything else is
    /// read defensively so an unrecognized/future field shape degrades to a sparser record
    /// instead of dropping the whole row.
    static func parseLiveAgentsJSON(_ data: Data) -> [LiveClaudeAgentEntry] {
        guard let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return array.compactMap { obj in
            guard let sessionId = obj["sessionId"] as? String, let kind = obj["kind"] as? String else { return nil }
            let startedAt = (obj["startedAt"] as? Double).map { Date(timeIntervalSince1970: $0 / 1000) }
            return LiveClaudeAgentEntry(
                sessionId: sessionId,
                kind: kind,
                cwd: obj["cwd"] as? String,
                name: obj["name"] as? String,
                status: obj["status"] as? String,
                startedAt: startedAt
            )
        }
    }

    // MARK: - Antigravity Scanner

    public func scanAntigravity() async -> [AgentSessionRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let brainDir = home.appendingPathComponent(".gemini/antigravity-cli/brain")
        guard FileManager.default.fileExists(atPath: brainDir.path) else { return [] }

        var records: [AgentSessionRecord] = []
        guard let sessionFolders = try? FileManager.default.contentsOfDirectory(atPath: brainDir.path) else {
            return []
        }
        // Subagent conversations get their own brain folder too; listing them would show one
        // piece of work as several sessions.
        let subagentIDs = Self.antigravitySubagentIDs(
            dbPath: home.appendingPathComponent(".gemini/antigravity-cli/conversation_summaries.db").path
        )

        for folder in sessionFolders {
            if folder.hasPrefix(".") || subagentIDs.contains(folder) { continue }
            let sessionDir = brainDir.appendingPathComponent(folder)
            // Don't hardcode the exact sub-depth to the transcript — Antigravity's on-disk
            // layout has moved before (see the newer `conversations/*.db` SQLite format this
            // scanner doesn't read yet) and CLI vs IDE builds aren't guaranteed to nest it
            // identically. Discover the file by name anywhere under the session folder instead.
            guard let transcriptURL = Self.findFile(named: "transcript.jsonl", under: sessionDir) else { continue }
            let path = transcriptURL.path

            if let rv = try? transcriptURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
               let mtime = rv.contentModificationDate,
               let size = rv.fileSize,
               let cached = fileCache[path],
               cached.mtime == mtime && cached.size == size {
                if !ftsIndex.needsReindex(sessionID: cached.record.id, mtime: mtime, fileSize: size) {
                    records.append(cached.record)
                    continue
                }
            }

            if let record = parseAntigravityTranscript(sessionID: folder, fileURL: transcriptURL) {
                if let rv = try? transcriptURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                   let mtime = rv.contentModificationDate,
                   let size = rv.fileSize {
                    fileCache[path] = FileCacheEntry(mtime: mtime, size: size, record: record)
                }
                records.append(record)
            }
        }
        return records
    }

    func parseAntigravityTranscript(sessionID: String, fileURL: URL) -> AgentSessionRecord? {
        guard let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe),
              let string = String(data: data, encoding: .utf8) else { return nil }

        let lines = string.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !lines.isEmpty else { return nil }

        var firstPrompt: String?
        var modelName: String?
        var projectPath: String?
        var turns: [AgentHistoryTurn] = []

        let messageCount = lines.count

        // 1. Scan prefix for first prompt, model, and project path
        for line in lines.prefix(40) {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any] else {
                continue
            }

            let type = json["type"] as? String ?? ""
            let content = json["content"] as? String ?? ""

            // Parse first user request
            if type == "USER_INPUT" && firstPrompt == nil {
                var clean = content
                if let rangeStart = clean.range(of: "<USER_REQUEST>"),
                   let rangeEnd = clean.range(of: "</USER_REQUEST>") {
                    clean = String(clean[rangeStart.upperBound..<rangeEnd.lowerBound])
                }
                firstPrompt = clean.trimmingCharacters(in: .whitespacesAndNewlines)

                // Detect model change if present
                if let modelRange = content.range(of: "Model Selection` from None to ") {
                    let sub = content[modelRange.upperBound...]
                    if let end = sub.firstIndex(of: ".") {
                        modelName = String(sub[..<end])
                    }
                }
            }

            // Detect project path from tool calls or file paths
            if projectPath == nil {
                if let toolCalls = json["tool_calls"] as? [[String: Any]] {
                    for tc in toolCalls {
                        if let params = tc["parameters"] as? [String: Any] {
                            if let cwd = params["Cwd"] as? String { projectPath = cwd; break }
                            if let dir = params["SearchDirectory"] as? String { projectPath = dir; break }
                            if let file = (params["TargetFile"] ?? params["AbsolutePath"]) as? String {
                                projectPath = (file as NSString).deletingLastPathComponent
                                break
                            }
                        }
                    }
                }
            }
            if firstPrompt != nil && projectPath != nil { break }
        }

        // 2. Scan suffix for latest turns
        for line in lines.suffix(Self.turnScanWindow) {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any] else {
                continue
            }

            let type = json["type"] as? String ?? ""
            let content = json["content"] as? String ?? ""

            // Only the real conversation — GENERIC (tool output), SYSTEM_MESSAGE and CHECKPOINT
            // entries would otherwise show up (and get handed off) as "AGENT" turns.
            if !content.isEmpty, type == "USER_INPUT" || type == "PLANNER_RESPONSE" {
                let role = (type == "USER_INPUT") ? "YOU" : "AGENT"
                var displayContent = content
                if let rangeStart = displayContent.range(of: "<USER_REQUEST>"),
                   let rangeEnd = displayContent.range(of: "</USER_REQUEST>") {
                    displayContent = String(displayContent[rangeStart.upperBound..<rangeEnd.lowerBound])
                }
                displayContent = displayContent.trimmingCharacters(in: .whitespacesAndNewlines)
                if !displayContent.isEmpty {
                    if turns.count >= Self.maxLatestTurns { turns.removeFirst() }
                    turns.append(AgentHistoryTurn(role: turnRole(role), content: String(displayContent.prefix(Self.turnContentLimit))))
                }
            }
        }

        var fullTranscriptParts: [String] = []
        var filesEdited: Set<String> = []
        var toolsCalled: Set<String> = []

        for line in lines {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any] else {
                continue
            }
            let type = json["type"] as? String ?? ""
            let content = json["content"] as? String ?? ""
            if !content.isEmpty, type == "USER_INPUT" || type == "PLANNER_RESPONSE" {
                var clean = content
                if let rangeStart = clean.range(of: "<USER_REQUEST>"),
                   let rangeEnd = clean.range(of: "</USER_REQUEST>") {
                    clean = String(clean[rangeStart.upperBound..<rangeEnd.lowerBound])
                }
                let trimmed = clean.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { fullTranscriptParts.append(trimmed) }
            }
            if let toolCalls = json["tool_calls"] as? [[String: Any]] {
                for tc in toolCalls {
                    if let name = tc["name"] as? String, !name.isEmpty {
                        toolsCalled.insert(name)
                    }
                    if let params = tc["parameters"] as? [String: Any] {
                        for key in ["TargetFile", "AbsolutePath", "file_path", "path"] {
                            if let f = params[key] as? String, !f.isEmpty {
                                filesEdited.insert((f as NSString).lastPathComponent)
                            }
                        }
                    }
                }
            }
        }

        let homePath = FileManager.default.homeDirectoryForCurrentUser.path
        let finalPath = projectPath ?? homePath
        let projectName = (finalPath as NSString).lastPathComponent
        let title = firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) ?? "\(AgentKind.antigravity.displayName) Session \(sessionID.prefix(8))"
        let modDate = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
        let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? string.utf8.count

        ftsIndex.indexSession(
            sessionID: sessionID,
            title: title,
            firstPrompt: firstPrompt ?? "",
            fullTranscript: fullTranscriptParts.joined(separator: "\n"),
            gitBranch: nil,
            repoName: projectName,
            agentName: AgentKind.antigravity.displayName,
            filesEdited: filesEdited.joined(separator: " "),
            toolsCalled: toolsCalled.joined(separator: " "),
            transcriptPath: fileURL.path,
            mtime: modDate,
            fileSize: fileSize
        )

        return AgentSessionRecord(
            id: sessionID,
            agentKind: .antigravity,
            title: String(title.prefix(120)),
            projectPath: finalPath,
            projectName: projectName.isEmpty ? "Home" : projectName,
            gitBranch: nil,
            modelName: modelName ?? "Gemini",
            messageCount: messageCount,
            updatedAt: modDate,
            firstPrompt: firstPrompt ?? "",
            latestTurns: turns,
            transcriptPath: fileURL.path,
            worktreeAvailable: FileManager.default.fileExists(atPath: finalPath)
        )
    }

    private func turnRole(_ role: String) -> String {
        return role == "YOU" ? "YOU" : "AGENT"
    }

    // MARK: - Codex Scanner

    /// Codex's own `session_index.jsonl` only carries a thread name (title) per session, no
    /// actual messages — the real conversation lives in `~/.codex/sessions/**/rollout-*.jsonl`.
    /// Walk that tree directly (recursively, not a hardcoded `YYYY/MM/DD` depth — Codex has
    /// changed this layout before and both the CLI and the desktop app share the same root).
    public func scanCodex() async -> [AgentSessionRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let sessionsDir = home.appendingPathComponent(".codex/sessions")
        guard FileManager.default.fileExists(atPath: sessionsDir.path) else { return [] }

        let rolloutFiles = Self.findFiles(
            matching: { $0.hasPrefix("rollout-") && $0.hasSuffix(".jsonl") },
            under: sessionsDir
        )

        var records: [AgentSessionRecord] = []
        for fileURL in rolloutFiles {
            let path = fileURL.path

            if let rv = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
               let mtime = rv.contentModificationDate,
               let size = rv.fileSize,
               let cached = fileCache[path],
               cached.mtime == mtime && cached.size == size {
                if !ftsIndex.needsReindex(sessionID: cached.record.id, mtime: mtime, fileSize: size) {
                    records.append(cached.record)
                    continue
                }
            }

            if let record = parseCodexTranscript(fileURL: fileURL) {
                if let rv = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                   let mtime = rv.contentModificationDate,
                   let size = rv.fileSize {
                    fileCache[path] = FileCacheEntry(mtime: mtime, size: size, record: record)
                }
                records.append(record)
            }
        }
        return records
    }

    /// A Codex `AGENTS.md`/environment prelude gets injected as the first `user`-role message
    /// in every rollout — never the actual thing the person asked. Recognize and skip it so
    /// `firstPrompt`/`title` reflect the real request instead of boilerplate instructions.
    private func isCodexBoilerplatePrompt(_ text: String) -> Bool {
        text.hasPrefix("# AGENTS.md instructions for") || text.contains("<INSTRUCTIONS>")
    }

    private func parseCodexTranscript(fileURL: URL) -> AgentSessionRecord? {
        guard let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe),
              let string = String(data: data, encoding: .utf8) else { return nil }

        let lines = string.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !lines.isEmpty else { return nil }

        var sessionID: String?
        var cwd: String?
        var firstPrompt: String?
        var turns: [AgentHistoryTurn] = []
        var messageCount = 0

        func extractText(_ content: Any?) -> String {
            guard let items = content as? [[String: Any]] else { return "" }
            var out = ""
            for item in items {
                if let text = item["text"] as? String { out += text }
            }
            return out.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var fullTranscriptParts: [String] = []
        var filesEdited: Set<String> = []
        var toolsCalled: Set<String> = []

        for line in lines {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any],
                  let payload = json["payload"] as? [String: Any] else { continue }

            let type = json["type"] as? String ?? ""

            if type == "session_meta" {
                // Subagent threads (`source: {subagent: …}`) belong to their parent session.
                if (payload["source"] as? [String: Any])?["subagent"] != nil { return nil }
                if sessionID == nil { sessionID = payload["session_id"] as? String ?? payload["id"] as? String }
                if cwd == nil { cwd = payload["cwd"] as? String }
                continue
            }

            if type == "response_item", payload["type"] as? String == "function_call" {
                if let name = payload["name"] as? String, !name.isEmpty {
                    toolsCalled.insert(name)
                }
                if let args = payload["arguments"] as? String {
                    if let argsData = args.data(using: .utf8),
                       let argsObj = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any] {
                        for key in ["path", "file_path", "workdir"] {
                            if let p = argsObj[key] as? String, !p.isEmpty {
                                filesEdited.insert((p as NSString).lastPathComponent)
                            }
                        }
                    }
                }
            }

            guard type == "response_item", payload["type"] as? String == "message" else { continue }
            let role = (payload["role"] as? String)?.lowercased() ?? ""
            guard role == "user" || role == "assistant" else { continue }

            let text = extractText(payload["content"])
            guard !text.isEmpty else { continue }
            if role == "user" && isCodexBoilerplatePrompt(text) { continue }

            fullTranscriptParts.append(text)
            messageCount += 1
            if firstPrompt == nil && role == "user" { firstPrompt = text }

            let turnRole = (role == "user") ? "YOU" : "AGENT"
            if turns.count >= Self.maxLatestTurns { turns.removeFirst() }
            turns.append(AgentHistoryTurn(role: turnRole, content: String(text.prefix(Self.turnContentLimit))))
        }

        guard messageCount > 0 else { return nil }

        let finalCwd = cwd ?? FileManager.default.homeDirectoryForCurrentUser.path
        let projectName = (finalCwd as NSString).lastPathComponent
        let resolvedID = sessionID ?? fileURL.deletingPathExtension().lastPathComponent
        let title = firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty })
            ?? "Codex Session \(resolvedID.prefix(8))"
        let modDate = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
        let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? string.utf8.count

        ftsIndex.indexSession(
            sessionID: resolvedID,
            title: title,
            firstPrompt: firstPrompt ?? "",
            fullTranscript: fullTranscriptParts.joined(separator: "\n"),
            gitBranch: nil,
            repoName: projectName,
            agentName: AgentKind.codex.displayName,
            filesEdited: filesEdited.joined(separator: " "),
            toolsCalled: toolsCalled.joined(separator: " "),
            transcriptPath: fileURL.path,
            mtime: modDate,
            fileSize: fileSize
        )

        return AgentSessionRecord(
            id: resolvedID,
            agentKind: .codex,
            title: String(title.prefix(120)),
            projectPath: finalCwd,
            projectName: projectName.isEmpty ? "Home" : projectName,
            gitBranch: nil,
            modelName: nil,
            messageCount: messageCount,
            updatedAt: modDate,
            firstPrompt: firstPrompt ?? "",
            latestTurns: turns,
            transcriptPath: fileURL.path,
            worktreeAvailable: FileManager.default.fileExists(atPath: finalCwd)
        )
    }

    #if canImport(SQLite3)
    /// Ids of Antigravity subagent conversations (`parent_conversation_id` set).
    static func antigravitySubagentIDs(dbPath: String) -> Set<String> {
        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let db else {
            sqlite3_close(db)
            return []
        }
        defer { sqlite3_close(db) }
        var stmt: OpaquePointer?
        let sql = "SELECT conversation_id FROM conversation_summaries WHERE parent_conversation_id != ''"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        var ids: Set<String> = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let c = sqlite3_column_text(stmt, 0) { ids.insert(String(cString: c)) }
        }
        return ids
    }
    #else
    static func antigravitySubagentIDs(dbPath: String) -> Set<String> { [] }
    #endif

    // MARK: - VS Code Copilot Chat Scanner

    /// Copilot Chat sessions from VS Code's workspace storage — see `VSCodeChatSession`.
    public func scanVSCodeCopilotChat() async -> [AgentSessionRecord] {
        let fm = FileManager.default
        let storage = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Code/User/workspaceStorage")
        guard let workspaces = try? fm.contentsOfDirectory(atPath: storage.path) else { return [] }

        var records: [AgentSessionRecord] = []
        for workspace in workspaces {
            let dir = storage.appendingPathComponent(workspace)
            guard let files = try? fm.contentsOfDirectory(atPath: dir.appendingPathComponent("chatSessions").path),
                  !files.isEmpty else { continue }
            let projectPath = Self.vscodeWorkspacePath(dir.appendingPathComponent("workspace.json"))
            for file in files where file.hasSuffix(".json") || file.hasSuffix(".jsonl") {
                let url = dir.appendingPathComponent("chatSessions").appendingPathComponent(file)
                guard let rv = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                      let mtime = rv.contentModificationDate, let size = rv.fileSize else { continue }
                if let cached = fileCache[url.path], cached.mtime == mtime, cached.size == size {
                    if !ftsIndex.needsReindex(sessionID: cached.record.id, mtime: mtime, fileSize: size) {
                        records.append(cached.record)
                        continue
                    }
                }
                guard let data = try? Data(contentsOf: url, options: .mappedIfSafe),
                      let session = VSCodeChatSession.parse(data, isJSONL: file.hasSuffix(".jsonl")),
                      let record = Self.vscodeRecord(session, projectPath: projectPath, transcriptPath: url.path, fallbackDate: mtime, fileSize: size, ftsIndex: ftsIndex)
                else { continue }
                fileCache[url.path] = FileCacheEntry(mtime: mtime, size: size, record: record)
                records.append(record)
            }
        }
        return records
    }

    /// `workspace.json` holds `folder` (a `file://` dir) or `workspace` (a `.code-workspace`
    /// file — its directory is used). Falls back to home when neither resolves.
    static func vscodeWorkspacePath(_ workspaceJSON: URL) -> String {
        let json = (try? Data(contentsOf: workspaceJSON))
            .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: String] } ?? [:]
        if let folder = json["folder"].flatMap(URL.init(string:)), folder.isFileURL { return folder.path }
        if let file = json["workspace"].flatMap(URL.init(string:)), file.isFileURL {
            return file.deletingLastPathComponent().path
        }
        return FileManager.default.homeDirectoryForCurrentUser.path
    }

    static func vscodeRecord(
        _ session: VSCodeChatSession,
        projectPath: String,
        transcriptPath: String,
        fallbackDate: Date,
        fileSize: Int = 0,
        ftsIndex: AgentHistoryFTSIndex? = nil
    ) -> AgentSessionRecord? {
        guard let first = session.requests.first else { return nil }
        var turns: [AgentHistoryTurn] = []
        var fullTranscriptParts: [String] = []

        for request in session.requests {
            fullTranscriptParts.append(request.prompt)
            turns.append(AgentHistoryTurn(role: "YOU", content: String(request.prompt.prefix(turnContentLimit))))
            if !request.response.isEmpty {
                fullTranscriptParts.append(request.response)
                turns.append(AgentHistoryTurn(role: "AGENT", content: String(request.response.prefix(turnContentLimit))))
            }
        }
        let title = session.title
            ?? first.prompt.components(separatedBy: .newlines).first(where: { !$0.isEmpty })
            ?? "VS Code Chat \(session.sessionID.prefix(8))"
        let modDate = session.lastMessageDate ?? fallbackDate
        let repoName = URL(fileURLWithPath: projectPath).lastPathComponent

        ftsIndex?.indexSession(
            sessionID: session.sessionID,
            title: title,
            firstPrompt: first.prompt,
            fullTranscript: fullTranscriptParts.joined(separator: "\n"),
            gitBranch: nil,
            repoName: repoName,
            agentName: AgentKind.copilot.displayName,
            filesEdited: "",
            toolsCalled: "",
            transcriptPath: transcriptPath,
            mtime: modDate,
            fileSize: fileSize
        )

        return AgentSessionRecord(
            id: session.sessionID,
            agentKind: .copilot,
            title: String(title.prefix(120)),
            projectPath: projectPath,
            projectName: repoName,
            messageCount: turns.count,
            updatedAt: modDate,
            firstPrompt: first.prompt,
            latestTurns: Array(turns.suffix(maxLatestTurns)),
            transcriptPath: transcriptPath,
            worktreeAvailable: false,
            placement: .vscode
        )
    }

    // MARK: - Copilot Scanner

    #if canImport(SQLite3)
    /// GitHub Copilot CLI keeps its own conversation history in a SQLite db
    /// (`~/.copilot/session-store.db`, `sessions` + `turns` tables) — not JSONL like the other
    /// three agents. Root path is shared by the CLI and any desktop wrapper on this machine
    /// (no separate desktop transcript store was found), so no CLI/desktop split is needed here.
    public func scanCopilot() async -> [AgentSessionRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dbURL = home.appendingPathComponent(".copilot/session-store.db")
        guard FileManager.default.fileExists(atPath: dbURL.path) else { return [] }

        guard let rv = try? dbURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
              let mtime = rv.contentModificationDate,
              let size = rv.fileSize else { return [] }

        if let cached = copilotCache, cached.mtime == mtime && cached.size == size {
            return cached.records
        }

        let records = Self.readCopilotSessions(dbPath: dbURL.path, ftsIndex: ftsIndex)
        copilotCache = (mtime: mtime, size: size, records: records)
        return records
    }

    /// Synchronous SQLite read, isolated in its own function (never handed an `OpaquePointer`
    /// across an `await` boundary) so it stays simple under Swift 6 strict concurrency.
    private static func readCopilotSessions(dbPath: String, ftsIndex: AgentHistoryFTSIndex? = nil) -> [AgentSessionRecord] {
        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let db else {
            sqlite3_close(db)
            return []
        }
        defer { sqlite3_close(db) }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackIso = ISO8601DateFormatter()
        func parseDate(_ s: String?) -> Date? {
            guard let s, !s.isEmpty else { return nil }
            return isoFormatter.date(from: s) ?? fallbackIso.date(from: s)
        }

        var records: [AgentSessionRecord] = []
        var sessionStmt: OpaquePointer?
        let sessionSQL = "SELECT id, cwd, repository, branch, summary, updated_at FROM sessions ORDER BY updated_at DESC"
        guard sqlite3_prepare_v2(db, sessionSQL, -1, &sessionStmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(sessionStmt) }

        while sqlite3_step(sessionStmt) == SQLITE_ROW {
            guard let idCStr = sqlite3_column_text(sessionStmt, 0) else { continue }
            let id = String(cString: idCStr)
            let cwd = sqlite3_column_text(sessionStmt, 1).map { String(cString: $0) }
            let repository = sqlite3_column_text(sessionStmt, 2).map { String(cString: $0) }
            let branch = sqlite3_column_text(sessionStmt, 3).map { String(cString: $0) }
            let summary = sqlite3_column_text(sessionStmt, 4).map { String(cString: $0) }
            let updatedAtStr = sqlite3_column_text(sessionStmt, 5).map { String(cString: $0) }

            let (firstPrompt, turns, fullTranscript, messageCount) = readCopilotTurns(db: db, sessionID: id)
            guard messageCount > 0 || !(summary ?? "").isEmpty else { continue }

            let finalPath = (cwd?.isEmpty == false ? cwd : repository) ?? home.path
            let projectName = (finalPath as NSString).lastPathComponent
            let title = (summary?.isEmpty == false ? summary : nil)
                ?? firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty })
                ?? "Copilot Session \(id.prefix(8))"
            let modDate = parseDate(updatedAtStr) ?? Date()

            ftsIndex?.indexSession(
                sessionID: id,
                title: title,
                firstPrompt: firstPrompt ?? "",
                fullTranscript: fullTranscript,
                gitBranch: branch,
                repoName: projectName,
                agentName: AgentKind.copilot.displayName,
                filesEdited: "",
                toolsCalled: "",
                transcriptPath: dbPath,
                mtime: modDate,
                fileSize: 0
            )

            records.append(AgentSessionRecord(
                id: id,
                agentKind: .copilot,
                title: String(title.prefix(120)),
                projectPath: finalPath,
                projectName: projectName.isEmpty ? "Home" : projectName,
                gitBranch: (branch?.isEmpty == false) ? branch : nil,
                modelName: nil,
                messageCount: messageCount,
                updatedAt: modDate,
                firstPrompt: firstPrompt ?? "",
                latestTurns: turns,
                transcriptPath: dbPath,
                worktreeAvailable: FileManager.default.fileExists(atPath: finalPath)
            ))
        }
        return records
    }

    private static var home: URL { FileManager.default.homeDirectoryForCurrentUser }

    /// Returns (firstPrompt, latestTurns, fullTranscript, messageCount) for one session's `turns` rows.
    private static func readCopilotTurns(db: OpaquePointer, sessionID: String) -> (String?, [AgentHistoryTurn], String, Int) {
        var stmt: OpaquePointer?
        let sql = "SELECT user_message, assistant_response FROM turns WHERE session_id = ? ORDER BY turn_index ASC"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return (nil, [], "", 0) }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

        var firstPrompt: String?
        var allTurns: [AgentHistoryTurn] = []
        var fullTranscriptParts: [String] = []
        var messageCount = 0

        while sqlite3_step(stmt) == SQLITE_ROW {
            let userMsg = sqlite3_column_text(stmt, 0).map { String(cString: $0) }?.trimmingCharacters(in: .whitespacesAndNewlines)
            let assistantMsg = sqlite3_column_text(stmt, 1).map { String(cString: $0) }?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let userMsg, !userMsg.isEmpty {
                if firstPrompt == nil { firstPrompt = userMsg }
                fullTranscriptParts.append(userMsg)
                allTurns.append(AgentHistoryTurn(role: "YOU", content: String(userMsg.prefix(turnContentLimit))))
                messageCount += 1
            }
            if let assistantMsg, !assistantMsg.isEmpty {
                fullTranscriptParts.append(assistantMsg)
                allTurns.append(AgentHistoryTurn(role: "AGENT", content: String(assistantMsg.prefix(turnContentLimit))))
                messageCount += 1
            }
        }
        let latest = Array(allTurns.suffix(maxLatestTurns))
        return (firstPrompt, latest, fullTranscriptParts.joined(separator: "\n"), messageCount)
    }
    #else
    public func scanCopilot() async -> [AgentSessionRecord] { [] }
    #endif
}
