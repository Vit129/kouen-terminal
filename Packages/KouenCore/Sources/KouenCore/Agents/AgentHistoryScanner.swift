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
        worktreeAvailable: Bool
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
    private var fileCache: [String: FileCacheEntry] = [:]
    private var lastScanAt: Date = .distantPast
    #if canImport(SQLite3)
    private var copilotCache: (mtime: Date, size: Int, records: [AgentSessionRecord])?
    #endif

    public init() {}

    /// Returns cached records if fresh (< 5s), otherwise rescans.
    public func getOrScan(force: Bool = false) async -> [AgentSessionRecord] {
        if !force && !cachedRecords.isEmpty && Date().timeIntervalSince(lastScanAt) < 5.0 {
            return cachedRecords
        }
        return await scanAll()
    }

    /// Scans all supported agent transcripts on disk concurrently with mtime caching.
    public func scanAll() async -> [AgentSessionRecord] {
        async let claudeTask = scanClaude()
        async let antigravityTask = scanAntigravity()
        async let codexTask = scanCodex()
        async let copilotTask = scanCopilot()

        var results: [AgentSessionRecord] = []
        results.append(contentsOf: await claudeTask)
        results.append(contentsOf: await antigravityTask)
        results.append(contentsOf: await codexTask)
        results.append(contentsOf: await copilotTask)

        results.sort { $0.updatedAt > $1.updatedAt }
        cachedRecords = results
        lastScanAt = Date()
        return results
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
                    records.append(cached.record)
                    continue
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

        let finalCwd = cwd ?? FileManager.default.homeDirectoryForCurrentUser.path
        let projectName = (finalCwd as NSString).lastPathComponent
        let title = firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) ?? "Claude Session \(sessionID.prefix(8))"
        let modDate = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? timestamp ?? Date()

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

    // MARK: - Antigravity Scanner

    public func scanAntigravity() async -> [AgentSessionRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let brainDir = home.appendingPathComponent(".gemini/antigravity-cli/brain")
        guard FileManager.default.fileExists(atPath: brainDir.path) else { return [] }

        var records: [AgentSessionRecord] = []
        guard let sessionFolders = try? FileManager.default.contentsOfDirectory(atPath: brainDir.path) else {
            return []
        }

        for folder in sessionFolders {
            if folder.hasPrefix(".") { continue }
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
                records.append(cached.record)
                continue
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

    private func parseAntigravityTranscript(sessionID: String, fileURL: URL) -> AgentSessionRecord? {
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

            if !content.isEmpty {
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

        let homePath = FileManager.default.homeDirectoryForCurrentUser.path
        let finalPath = projectPath ?? homePath
        let projectName = (finalPath as NSString).lastPathComponent
        let title = firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) ?? "\(AgentKind.antigravity.displayName) Session \(sessionID.prefix(8))"
        let modDate = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()

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
                records.append(cached.record)
                continue
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

        for line in lines {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any],
                  let payload = json["payload"] as? [String: Any] else { continue }

            let type = json["type"] as? String ?? ""

            if type == "session_meta" {
                if sessionID == nil { sessionID = payload["session_id"] as? String ?? payload["id"] as? String }
                if cwd == nil { cwd = payload["cwd"] as? String }
                continue
            }

            guard type == "response_item", payload["type"] as? String == "message" else { continue }
            let role = (payload["role"] as? String)?.lowercased() ?? ""
            guard role == "user" || role == "assistant" else { continue }

            let text = extractText(payload["content"])
            guard !text.isEmpty else { continue }
            if role == "user" && isCodexBoilerplatePrompt(text) { continue }

            messageCount += 1
            if firstPrompt == nil && role == "user" { firstPrompt = text }

            let turnRole = (role == "user") ? "YOU" : "AGENT"
            if turns.count >= Self.maxLatestTurns { turns.removeFirst() }
            turns.append(AgentHistoryTurn(role: turnRole, content: String(text.prefix(Self.turnContentLimit))))
        }

        guard messageCount > 0 else { return nil }

        let finalCwd = cwd ?? FileManager.default.homeDirectoryForCurrentUser.path
        let projectName = (finalCwd as NSString).lastPathComponent
        let title = firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty })
            ?? "Codex Session \((sessionID ?? fileURL.deletingPathExtension().lastPathComponent).prefix(8))"
        let modDate = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()

        return AgentSessionRecord(
            id: sessionID ?? fileURL.deletingPathExtension().lastPathComponent,
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

        let records = Self.readCopilotSessions(dbPath: dbURL.path)
        copilotCache = (mtime: mtime, size: size, records: records)
        return records
    }

    /// Synchronous SQLite read, isolated in its own function (never handed an `OpaquePointer`
    /// across an `await` boundary) so it stays simple under Swift 6 strict concurrency.
    private static func readCopilotSessions(dbPath: String) -> [AgentSessionRecord] {
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

            let (firstPrompt, turns, messageCount) = readCopilotTurns(db: db, sessionID: id)
            guard messageCount > 0 || !(summary ?? "").isEmpty else { continue }

            let finalPath = (cwd?.isEmpty == false ? cwd : repository) ?? home.path
            let projectName = (finalPath as NSString).lastPathComponent
            let title = (summary?.isEmpty == false ? summary : nil)
                ?? firstPrompt?.components(separatedBy: .newlines).first(where: { !$0.isEmpty })
                ?? "Copilot Session \(id.prefix(8))"

            records.append(AgentSessionRecord(
                id: id,
                agentKind: .copilot,
                title: String(title.prefix(120)),
                projectPath: finalPath,
                projectName: projectName.isEmpty ? "Home" : projectName,
                gitBranch: (branch?.isEmpty == false) ? branch : nil,
                modelName: nil,
                messageCount: messageCount,
                updatedAt: parseDate(updatedAtStr) ?? Date(),
                firstPrompt: firstPrompt ?? "",
                latestTurns: turns,
                transcriptPath: dbPath,
                worktreeAvailable: FileManager.default.fileExists(atPath: finalPath)
            ))
        }
        return records
    }

    private static var home: URL { FileManager.default.homeDirectoryForCurrentUser }

    /// Returns (firstPrompt, latestTurns, messageCount) for one session's `turns` rows.
    private static func readCopilotTurns(db: OpaquePointer, sessionID: String) -> (String?, [AgentHistoryTurn], Int) {
        var stmt: OpaquePointer?
        let sql = "SELECT user_message, assistant_response FROM turns WHERE session_id = ? ORDER BY turn_index ASC"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return (nil, [], 0) }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, sessionID, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

        var firstPrompt: String?
        var allTurns: [AgentHistoryTurn] = []
        var messageCount = 0

        while sqlite3_step(stmt) == SQLITE_ROW {
            let userMsg = sqlite3_column_text(stmt, 0).map { String(cString: $0) }?.trimmingCharacters(in: .whitespacesAndNewlines)
            let assistantMsg = sqlite3_column_text(stmt, 1).map { String(cString: $0) }?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let userMsg, !userMsg.isEmpty {
                if firstPrompt == nil { firstPrompt = userMsg }
                allTurns.append(AgentHistoryTurn(role: "YOU", content: String(userMsg.prefix(turnContentLimit))))
                messageCount += 1
            }
            if let assistantMsg, !assistantMsg.isEmpty {
                allTurns.append(AgentHistoryTurn(role: "AGENT", content: String(assistantMsg.prefix(turnContentLimit))))
                messageCount += 1
            }
        }
        let latest = Array(allTurns.suffix(maxLatestTurns))
        return (firstPrompt, latest, messageCount)
    }
    #else
    public func scanCopilot() async -> [AgentSessionRecord] { [] }
    #endif
}
