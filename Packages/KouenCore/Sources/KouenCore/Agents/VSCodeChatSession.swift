import Foundation

/// One Copilot Chat session from VS Code's own store
/// (`~/Library/Application Support/Code/User/workspaceStorage/<hash>/chatSessions/`). That store
/// is separate from the Copilot CLI's `session-store.db` — neither tool sees the other's
/// sessions — so History reads it directly. View/handoff only: the CLI can't resume these.
///
/// Two on-disk formats, both seen live (2026-09-28): legacy `<id>.json` (the whole session
/// object) and newer `<id>.jsonl`, an append-only patch log — `kind 0` = initial object,
/// `kind 1` = set the value at key path `k`, `kind 2` = append `v`'s items to the array at `k`.
struct VSCodeChatSession: Equatable {
    struct Request: Equatable {
        var prompt: String
        var response: String
        var timestamp: Date?
    }

    var sessionID: String
    var title: String?
    var requests: [Request]
    var lastMessageDate: Date?

    static func parse(_ data: Data, isJSONL: Bool) -> VSCodeChatSession? {
        let root: [String: Any]?
        if isJSONL {
            root = replayPatchLog(data)
        } else {
            root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        }
        guard let root, let sessionID = root["sessionId"] as? String else { return nil }

        let requests = (root["requests"] as? [[String: Any]] ?? []).compactMap { raw -> Request? in
            let prompt = ((raw["message"] as? [String: Any])?["text"] as? String ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !prompt.isEmpty else { return nil }
            // Plain markdown chunks carry no `kind`; thinking, tool calls, references etc. do.
            let response = (raw["response"] as? [[String: Any]] ?? [])
                .filter { $0["kind"] == nil }
                .compactMap { $0["value"] as? String }
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return Request(prompt: prompt, response: response, timestamp: date(raw["timestamp"]))
        }
        let title = (root["customTitle"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        return VSCodeChatSession(
            sessionID: sessionID, title: title, requests: requests,
            lastMessageDate: date(root["lastMessageDate"]) ?? requests.last?.timestamp
        )
    }

    /// Rebuilds the session object from the `.jsonl` patch log. Unknown kinds and paths that
    /// don't resolve are skipped rather than failing the whole session.
    private static func replayPatchLog(_ data: Data) -> [String: Any]? {
        var root: Any?
        for line in String(decoding: data, as: UTF8.self).split(separator: "\n") {
            guard let entry = (try? JSONSerialization.jsonObject(with: Data(line.utf8))) as? [String: Any],
                  let kind = entry["kind"] as? Int else { continue }
            let path = entry["k"] as? [Any] ?? []
            switch kind {
            case 0: root = entry["v"]
            case 1: root = apply(root, path: path[...]) { _ in entry["v"] }
            case 2: root = apply(root, path: path[...]) { ($0 as? [Any] ?? []) + (entry["v"] as? [Any] ?? []) }
            default: continue
            }
        }
        return root as? [String: Any]
    }

    /// Value-type rewrite of `node` with `change` applied at `path` (string keys / int indices).
    private static func apply(_ node: Any?, path: ArraySlice<Any>, _ change: (Any?) -> Any?) -> Any? {
        guard let head = path.first else { return change(node) }
        let rest = path.dropFirst()
        if let key = head as? String, var dict = node as? [String: Any] {
            dict[key] = apply(dict[key], path: rest, change)
            return dict
        }
        if let index = head as? Int, var array = node as? [Any], array.indices.contains(index) {
            array[index] = apply(array[index], path: rest, change) as Any
            return array
        }
        return node
    }

    /// VS Code stores epoch milliseconds.
    private static func date(_ value: Any?) -> Date? {
        (value as? Double).map { Date(timeIntervalSince1970: $0 / 1000) }
    }
}
