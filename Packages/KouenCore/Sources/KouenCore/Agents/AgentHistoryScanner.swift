import Foundation
import KouenIPC

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

    private struct FileCacheEntry: Sendable {
        let mtime: Date
        let size: Int
        let record: AgentSessionRecord
    }

    private var cachedRecords: [AgentSessionRecord] = []
    private var fileCache: [String: FileCacheEntry] = [:]
    private var lastScanAt: Date = .distantPast

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

        var results: [AgentSessionRecord] = []
        results.append(contentsOf: await claudeTask)
        results.append(contentsOf: await antigravityTask)
        results.append(contentsOf: await codexTask)

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
        for line in lines.suffix(20) {
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
                if turns.count >= 4 { turns.removeFirst() }
                turns.append(AgentHistoryTurn(role: turnRole, content: String(trimmed.prefix(300))))
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
            let transcriptURL = brainDir.appendingPathComponent(folder)
                .appendingPathComponent(".system_generated/logs/transcript.jsonl")
            let path = transcriptURL.path
            guard FileManager.default.fileExists(atPath: path) else { continue }

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
        for line in lines.suffix(20) {
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
                    if turns.count >= 4 { turns.removeFirst() }
                    turns.append(AgentHistoryTurn(role: turnRole(role), content: String(displayContent.prefix(300))))
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

    private var codexCache: (mtime: Date, size: Int, records: [AgentSessionRecord])?

    public func scanCodex() async -> [AgentSessionRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let codexIndexURL = home.appendingPathComponent(".codex/session_index.jsonl")
        guard FileManager.default.fileExists(atPath: codexIndexURL.path) else { return [] }

        if let rv = try? codexIndexURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
           let mtime = rv.contentModificationDate,
           let size = rv.fileSize,
           let cached = codexCache,
           cached.mtime == mtime && cached.size == size {
            return cached.records
        }

        guard let data = try? Data(contentsOf: codexIndexURL),
              let string = String(data: data, encoding: .utf8) else { return [] }

        var records: [AgentSessionRecord] = []
        let lines = string.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackIso = ISO8601DateFormatter()

        for line in lines {
            guard let objData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: objData) as? [String: Any],
                  let id = json["id"] as? String else { continue }

            let threadName = json["thread_name"] as? String ?? "Codex Session"
            let updatedAtStr = json["updated_at"] as? String ?? ""
            let date = isoFormatter.date(from: updatedAtStr) ?? fallbackIso.date(from: updatedAtStr) ?? Date()

            records.append(AgentSessionRecord(
                id: id,
                agentKind: .codex,
                title: threadName,
                projectPath: home.path,
                projectName: "Codex",
                gitBranch: nil,
                modelName: "Codex",
                messageCount: 1,
                updatedAt: date,
                firstPrompt: threadName,
                latestTurns: [AgentHistoryTurn(role: "YOU", content: threadName)],
                transcriptPath: codexIndexURL.path,
                worktreeAvailable: true
            ))
        }
        if let rv = try? codexIndexURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
           let mtime = rv.contentModificationDate,
           let size = rv.fileSize {
            codexCache = (mtime: mtime, size: size, records: records)
        }
        return records
    }
}
