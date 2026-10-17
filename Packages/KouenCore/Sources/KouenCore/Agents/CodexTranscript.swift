import Foundation

/// Parses one line of a Codex session rollout transcript (`rollout-*.jsonl`).
public enum CodexTranscriptLine {
    /// Extracts user-visible items from one step of Codex's rollout transcript.
    public static func items(from line: Data) -> [TranscriptItem] {
        guard let json = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { return [] }
        let type = json["type"] as? String ?? ""
        let lineID = (json["id"] as? String) ?? (json["ordinal"].map { "\($0)" }) ?? UUID().uuidString
        let payload = json["payload"] as? [String: Any]
        let itemType = (payload?["type"] as? String) ?? type

        var result: [TranscriptItem] = []

        if itemType == "message" || type == "message" {
            let role = ((payload?["role"] ?? json["role"]) as? String)?.lowercased() ?? ""
            if role == "user" || role == "assistant" {
                let contentObj = payload?["content"] ?? json["content"]
                let text = extractText(contentObj)
                if !text.isEmpty {
                    if role == "user" {
                        if !isCodexBoilerplate(text) && !text.hasPrefix("<environment_context>") {
                            result.append(TranscriptItem(id: "\(lineID)#user", role: .user, text: text))
                        }
                    } else {
                        result.append(TranscriptItem(id: "\(lineID)#assistant", role: .assistant, text: text))
                    }
                }
            }
        } else if itemType == "custom_tool_call" || itemType == "function_call" {
            let name = (payload?["name"] as? String) ?? (json["name"] as? String) ?? "exec"
            var target: String?
            if let args = (payload?["arguments"] as? String) ?? (json["arguments"] as? String),
               let argsData = args.data(using: .utf8),
               let argsObj = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any] {
                for key in ["path", "file_path", "workdir", "command", "cmd"] {
                    if let val = argsObj[key] as? String, !val.isEmpty {
                        target = (key == "command" || key == "cmd") ? String(val.prefix(120)) : (val as NSString).lastPathComponent
                        break
                    }
                }
            }
            result.append(TranscriptItem(id: "\(lineID)#tool", role: .tool, text: "", toolName: name, toolTarget: target))
        }

        return result
    }

    /// Extracts model and usage metrics from Codex rollout lines.
    public static func meta(from lines: [Data]) -> (model: String?, mode: String?, usage: AgentUsage?) {
        var model: String?, mode: String?, usage: AgentUsage?

        for line in lines {
            guard let json = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { continue }
            let type = json["type"] as? String ?? ""
            let payload = json["payload"] as? [String: Any]

            if type == "session_meta" || type == "turn_context" {
                if let m = (payload?["model"] as? String) ?? (json["model"] as? String) {
                    model = m
                }
            }

            // Extract usage from token_count event or usage payload
            if (type == "event_msg" && payload?["type"] as? String == "token_count") || type == "token_count" {
                let info = (payload?["info"] as? [String: Any]) ?? (json["info"] as? [String: Any])
                let usageDict = (info?["last_token_usage"] as? [String: Any])
                    ?? (info?["total_token_usage"] as? [String: Any])
                    ?? (payload?["usage"] as? [String: Any])
                    ?? (json["usage"] as? [String: Any])
                if let u = usageDict {
                    var agUsage = AgentUsage()
                    agUsage.inputTokens = u["input_tokens"] as? Int
                    agUsage.cacheReadTokens = (u["cached_input_tokens"] ?? u["cache_read_input_tokens"]) as? Int
                    agUsage.cacheWriteTokens = u["cache_write_input_tokens"] as? Int
                    agUsage.outputTokens = u["output_tokens"] as? Int
                    agUsage.thinkingTokens = (u["reasoning_output_tokens"] ?? u["thinking_tokens"]) as? Int
                    usage = agUsage
                }
            } else if let u = (payload?["usage"] as? [String: Any]) ?? (json["usage"] as? [String: Any]) {
                var agUsage = AgentUsage()
                agUsage.inputTokens = u["input_tokens"] as? Int
                agUsage.cacheReadTokens = (u["cached_input_tokens"] ?? u["cache_read_input_tokens"]) as? Int
                agUsage.cacheWriteTokens = u["cache_write_input_tokens"] as? Int
                agUsage.outputTokens = u["output_tokens"] as? Int
                agUsage.thinkingTokens = (u["reasoning_output_tokens"] ?? u["thinking_tokens"]) as? Int
                usage = agUsage
            }
        }

        return (model, mode, usage)
    }

    private static func extractText(_ content: Any?) -> String {
        if let str = content as? String { return str.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard let items = content as? [[String: Any]] else { return "" }
        var out = ""
        for item in items {
            if let text = (item["text"] ?? item["input_text"]) as? String { out += text }
        }
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isCodexBoilerplate(_ text: String) -> Bool {
        text.hasPrefix("# AGENTS.md instructions for") || text.contains("<INSTRUCTIONS>")
    }
}

/// Resolves active Codex sessions and their rollout transcript files.
public enum CodexSessionLocator {
    /// Maps a running surface / PID to its active Codex session transcript file.
    public static func transcriptURL(
        pid: Int32,
        surfaceCwd: String? = nil,
        home: URL = FileManager.default.homeDirectoryForCurrentUser
    ) -> URL? {
        let codexDir = home.appendingPathComponent(".codex/sessions")
        guard FileManager.default.fileExists(atPath: codexDir.path) else { return nil }

        // Find rollout-*.jsonl files modified recently
        let opt = FileManager.DirectoryEnumerationOptions.skipsHiddenFiles
        guard let enumerator = FileManager.default.enumerator(at: codexDir, includingPropertiesForKeys: [.contentModificationDateKey], options: opt) else {
            return nil
        }

        var candidateURLs: [(url: URL, date: Date)] = []
        let now = Date()

        for case let fileURL as URL in enumerator {
            guard fileURL.lastPathComponent.hasPrefix("rollout-") && fileURL.pathExtension == "jsonl" else { continue }
            if let mtime = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate {
                // Consider files within the last 24 hours
                if now.timeIntervalSince(mtime) < 86400 {
                    candidateURLs.append((fileURL, mtime))
                }
            }
        }

        // Sort latest first
        candidateURLs.sort { $0.date > $1.date }

        guard let standardizedCwd = surfaceCwd.flatMap({ raw -> String? in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return URL(fileURLWithPath: trimmed).standardizedFileURL.path
        }) else {
            return candidateURLs.first?.url
        }

        // Find candidate matching surfaceCwd in its first line (session_meta)
        for (url, _) in candidateURLs {
            if let handle = try? FileHandle(forReadingFrom: url) {
                defer { try? handle.close() }
                let data = handle.readData(ofLength: 4096)
                if let firstLine = String(data: data, encoding: .utf8)?.split(separator: "\n").first,
                   let json = try? JSONSerialization.jsonObject(with: Data(firstLine.utf8)) as? [String: Any],
                   let payload = json["payload"] as? [String: Any],
                   let cwd = payload["cwd"] as? String {
                    let standardized = URL(fileURLWithPath: cwd).standardizedFileURL.path
                    if standardized == standardizedCwd || standardized.hasPrefix(standardizedCwd + "/") {
                        return url
                    }
                }
            }
        }

        // Do not fall back to an unrelated project session if surfaceCwd was explicitly specified
        return nil
    }
}
