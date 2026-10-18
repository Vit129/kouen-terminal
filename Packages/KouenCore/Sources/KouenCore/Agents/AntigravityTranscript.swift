import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
#if canImport(SQLite3)
import SQLite3
#endif

/// Parses one line of an Antigravity session transcript (`transcript.jsonl`).
public enum AntigravityTranscriptLine {
    /// Extracts user-visible items from one step of Antigravity's transcript.
    /// Maps `USER_INPUT` to user items and `PLANNER_RESPONSE` to assistant and tool items.
    /// Skips `SYSTEM_MESSAGE`, `CHECKPOINT`, `GENERIC` (raw tool results), and empty errors.
    public static func items(from line: Data) -> [TranscriptItem] {
        guard let json = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { return [] }
        let type = json["type"] as? String ?? ""
        let stepIndex = json["step_index"] as? Int ?? 0

        var result: [TranscriptItem] = []

        if type == "USER_INPUT" {
            let content = json["content"] as? String ?? ""
            var clean = content
            if let rangeStart = clean.range(of: "<USER_REQUEST>"),
               let rangeEnd = clean.range(of: "</USER_REQUEST>") {
                clean = String(clean[rangeStart.upperBound..<rangeEnd.lowerBound])
            }
            clean = clean.trimmingCharacters(in: .whitespacesAndNewlines)
            if !clean.isEmpty && !clean.hasPrefix("<SYSTEM_MESSAGE>") {
                result.append(TranscriptItem(id: "\(stepIndex)#user", role: .user, text: clean))
            }
        } else if type == "PLANNER_RESPONSE" {
            if let toolCalls = json["tool_calls"] as? [[String: Any]] {
                for (idx, tc) in toolCalls.enumerated() {
                    let name = tc["name"] as? String ?? "Tool"
                    var target: String?
                    let params = (tc["args"] as? [String: Any]) ?? (tc["parameters"] as? [String: Any])
                    if let params {
                        for key in ["TargetFile", "AbsolutePath", "file_path", "path"] {
                            if let f = params[key] as? String, !f.isEmpty {
                                let stripped = f.trimmingCharacters(in: CharacterSet(charactersIn: "\"'\n\r\t "))
                                target = (stripped as NSString).lastPathComponent
                                break
                            }
                        }
                        if target == nil {
                            for key in ["CommandLine", "query", "command", "Url"] {
                                if let val = params[key] as? String, !val.isEmpty {
                                    let stripped = val.trimmingCharacters(in: CharacterSet(charactersIn: "\"'\n\r\t "))
                                    target = String(stripped.prefix(120))
                                    break
                                }
                            }
                        }
                    }
                    result.append(TranscriptItem(id: "\(stepIndex)#tool#\(idx)", role: .tool, text: "", toolName: name, toolTarget: target))
                }
            }
            if let content = json["content"] as? String {
                let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    result.append(TranscriptItem(id: "\(stepIndex)#assistant", role: .assistant, text: trimmed))
                }
            }
        }
        return result
    }

    /// Extracts model name and token usage from Antigravity steps.
    public static func meta(from lines: [Data]) -> (model: String?, mode: String?, usage: AgentUsage?) {
        var model: String?, mode: String?, usage: AgentUsage?
        for line in lines {
            guard let json = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { continue }
            let content = json["content"] as? String ?? ""
            let prefixes = ["Model Selection` from None to ", "Model Selection` to "]
            for prefix in prefixes {
                if let modelRange = content.range(of: prefix) {
                    let sub = content[modelRange.upperBound...]
                    let delimiters: [Character] = [" ", "`", "\n", "\r", "\t"]
                    let endIdx = delimiters.compactMap { sub.firstIndex(of: $0) }.min() ?? sub.endIndex
                    var extracted = String(sub[..<endIdx]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if extracted.hasSuffix(".") { extracted.removeLast() }
                    let isClean = !extracted.isEmpty && extracted.count < 40 && !extracted.contains("\"") && !extracted.contains(")") && !extracted.contains("(") && !extracted.contains("{") && !extracted.contains(";") && !extracted.contains("=")
                    if isClean {
                        model = extracted
                    }
                    break
                }
            }
            if let inputTokens = json["input_tokens"] as? Int,
               let outputTokens = json["output_tokens"] as? Int {
                var u = AgentUsage()
                u.inputTokens = inputTokens
                u.outputTokens = outputTokens
                u.cacheReadTokens = json["cache_read_tokens"] as? Int
                usage = u
            }
        }
        return (model, mode, usage)
    }
}

/// Resolves an active Antigravity session and its transcript file across CLI, IDE, and Desktop surfaces.
public enum AntigravitySessionLocator {
    /// Maps a running surface / PID to its active Antigravity session transcript file.
    public static func transcriptURL(
        pid: Int32,
        surfaceCwd: String? = nil,
        home: URL = FileManager.default.homeDirectoryForCurrentUser
    ) -> URL? {
        // Search candidates: CLI/IDE first, Desktop 2.0 second
        let candidateBases: [(brain: URL, db: URL)] = [
            (
                home.appendingPathComponent(".gemini/antigravity-cli/brain"),
                home.appendingPathComponent(".gemini/antigravity-cli/conversation_summaries.db")
            ),
            (
                home.appendingPathComponent(".gemini/antigravity/brain"),
                home.appendingPathComponent(".gemini/antigravity/conversation_summaries.db")
            )
        ]

        for (brainDir, dbURL) in candidateBases {
            guard FileManager.default.fileExists(atPath: brainDir.path) else { continue }
            if let convID = resolveActiveConversationID(surfaceCwd: surfaceCwd, dbURL: dbURL, brainDir: brainDir) {
                let path1 = brainDir.appendingPathComponent(convID)
                    .appendingPathComponent(".system_generated/logs/transcript.jsonl")
                if FileManager.default.fileExists(atPath: path1.path) { return path1 }

                let path2 = brainDir.appendingPathComponent(convID).appendingPathComponent("transcript.jsonl")
                if FileManager.default.fileExists(atPath: path2.path) { return path2 }
            }
        }
        return nil
    }

    private static func resolveActiveConversationID(
        surfaceCwd: String?,
        dbURL: URL,
        brainDir: URL
    ) -> String? {
        let standardizedCwd = surfaceCwd.flatMap { raw -> String? in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return URL(fileURLWithPath: trimmed).standardizedFileURL.path
        }

        #if canImport(SQLite3)
        if FileManager.default.fileExists(atPath: dbURL.path) {
            var db: OpaquePointer?
            if sqlite3_open_v2(dbURL.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK, let db {
                defer { sqlite3_close(db) }
                sqlite3_busy_timeout(db, 1000)

                var stmt: OpaquePointer?
                let sql = """
                SELECT conversation_id, workspace_uris
                FROM conversation_summaries
                WHERE parent_conversation_id = '' OR parent_conversation_id IS NULL
                ORDER BY last_modified_time DESC
                LIMIT 25;
                """
                if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK, let stmt {
                    defer { sqlite3_finalize(stmt) }

                    var fallbackID: String?

                    while sqlite3_step(stmt) == SQLITE_ROW {
                        guard let convCStr = sqlite3_column_text(stmt, 0) else { continue }
                        let convID = String(cString: convCStr)
                        if fallbackID == nil { fallbackID = convID }

                        if let stdCwd = standardizedCwd {
                            if let wsCStr = sqlite3_column_text(stmt, 1) {
                                let wsStr = String(cString: wsCStr)
                                if matchesWorkspace(wsStr: wsStr, stdCwd: stdCwd) {
                                    return convID
                                }
                            }
                        }
                    }
                    if standardizedCwd == nil, let fallback = fallbackID { return fallback }
                }
            }
        }
        #endif

        // The agy CLI keeps no conversation_summaries.db, so nothing records a conversation's
        // workspace: match the newest transcript whose most-mentioned project root is this cwd.
        if let stdCwd = standardizedCwd {
            if FileManager.default.fileExists(atPath: dbURL.path) { return nil }
            return newestConversation(in: brainDir, dominatedBy: stdCwd)
        }

        // Fallback only when surfaceCwd was nil: directory mtime walk in brainDir
        guard let folders = try? FileManager.default.contentsOfDirectory(atPath: brainDir.path) else { return nil }
        var latestFolder: String?
        var latestDate = Date.distantPast
        for folder in folders where !folder.hasPrefix(".") {
            let sessionDir = brainDir.appendingPathComponent(folder)
            if let mtime = (try? sessionDir.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate {
                if mtime > latestDate {
                    latestDate = mtime
                    latestFolder = folder
                }
            }
        }
        return latestFolder
    }

    private static let dominantProjectRootRegex: NSRegularExpression? = try? NSRegularExpression(
        pattern: #"/(?:Users|home)/[^/"\\\s]+/(?:Git/[^/"\\\s]+/[^/"\\\s]+|\.[A-Za-z0-9_-]+)"#
    )

    /// ponytail: a heuristic (path mentions in the transcript), checked over the 10 newest
    /// conversations; replace with agy's own workspace record if the CLI ever writes one.
    static func newestConversation(in brainDir: URL, dominatedBy stdCwd: String) -> String? {
        guard let folders = try? FileManager.default.contentsOfDirectory(atPath: brainDir.path) else { return nil }
        let dated: [(id: String, url: URL, mtime: Date)] = folders.compactMap { id in
            guard !id.hasPrefix(".") else { return nil }
            let url = brainDir.appendingPathComponent(id).appendingPathComponent(".system_generated/logs/transcript.jsonl")
            guard let mtime = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate else { return nil }
            return (id, url, mtime)
        }
        for candidate in dated.sorted(by: { $0.mtime > $1.mtime }).prefix(10) {
            // agy reads its own skills/config under ~/.gemini in every conversation; that is not a workspace.
            let ignore = stdCwd.contains("/.gemini") ? nil : "/.gemini"
            guard let handle = try? FileHandle(forReadingFrom: candidate.url) else { continue }
            defer { try? handle.close() }
            let data = handle.readData(ofLength: 65536)
            guard let text = String(data: data, encoding: .utf8),
                  let root = dominantProjectRoot(in: text, ignoringSuffix: ignore) else { continue }
            if root == stdCwd || stdCwd.hasPrefix(root + "/") || root.hasPrefix(stdCwd + "/") {
                return candidate.id
            }
        }
        return nil
    }

    /// The most-mentioned project root (`~/Git/<group>/<repo>` or a `~/.<dir>`) in `text`.
    static func dominantProjectRoot(in text: String, ignoringSuffix ignore: String? = nil) -> String? {
        guard let regex = dominantProjectRootRegex else { return nil }
        var counts: [String: Int] = [:]
        let ns = text as NSString
        for match in regex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            let root = ns.substring(with: match.range)
            if let ignore, root.hasSuffix(ignore) { continue }
            counts[root, default: 0] += 1
        }
        return counts.max { $0.value < $1.value }?.key
    }

    /// Checks if a JSON workspace_uris string matches target stdCwd on exact path boundary.
    public static func matchesWorkspace(wsStr: String, stdCwd: String) -> Bool {
        guard let data = wsStr.data(using: .utf8),
              let list = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return false
        }
        for uri in list {
            let path: String
            if uri.hasPrefix("file://") {
                path = URL(string: uri)?.standardizedFileURL.path ?? String(uri.dropFirst(7))
            } else {
                path = URL(fileURLWithPath: uri).standardizedFileURL.path
            }
            if path == stdCwd || path.hasPrefix(stdCwd + "/") {
                return true
            }
        }
        return false
    }
}
