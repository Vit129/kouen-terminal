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

        // When a specific surface cwd was requested, never fall back to an unrelated project session
        if standardizedCwd != nil {
            return nil
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
