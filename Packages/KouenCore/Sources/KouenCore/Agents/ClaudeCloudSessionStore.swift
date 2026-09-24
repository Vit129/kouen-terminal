import Foundation

/// Remembers the Claude Code cloud sessions `claude agents --json` has reported on this Mac.
///
/// `claude agents --json` only lists sessions with a live client *on this machine*, so a
/// `claude --cloud` session drops out of it as soon as its pane closes — while the session itself
/// keeps running in the cloud. Its transcript never touches this disk either, so without this
/// store it would vanish from History entirely. Every cloud row the live scan sees is upserted
/// here and shown in History until it ages out.
///
/// Limitation: the Claude CLI has no non-interactive way to list the account's cloud sessions,
/// so a session started from the phone or claude.ai/code (with no client ever on this Mac)
/// can't be discovered here. `claude --teleport` (interactive picker) is the supported path.
struct ClaudeCloudSessionStore {
    struct Entry: Codable, Equatable, Sendable {
        let sessionId: String
        var cwd: String?
        var name: String?
        let firstSeen: Date
        var lastSeen: Date
    }

    /// Entries not seen for this long are dropped.
    static let maxAge: TimeInterval = 30 * 24 * 60 * 60
    /// Hard cap, oldest `lastSeen` dropped first.
    static let maxEntries = 200

    let fileURL: URL

    init(fileURL: URL = KouenPaths.applicationSupport.appendingPathComponent("claude-cloud-sessions.json")) {
        self.fileURL = fileURL
    }

    func load() -> [Entry] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Entry].self, from: data)) ?? []
    }

    /// Upserts every `.cloud` row in `live`, prunes, saves (only when something changed), and
    /// returns the full remembered set.
    @discardableResult
    func remember(_ live: [LiveClaudeAgentEntry], now: Date = Date()) -> [Entry] {
        let original = load()
        var byID = Dictionary(original.map { ($0.sessionId, $0) }, uniquingKeysWith: { a, _ in a })
        for row in live where row.placement == .cloud {
            if var existing = byID[row.sessionId] {
                existing.lastSeen = now
                if let cwd = row.cwd, !cwd.isEmpty { existing.cwd = cwd }
                if let name = row.name, !name.isEmpty { existing.name = name }
                byID[row.sessionId] = existing
            } else {
                byID[row.sessionId] = Entry(
                    sessionId: row.sessionId, cwd: row.cwd, name: row.name,
                    firstSeen: row.startedAt ?? now, lastSeen: now
                )
            }
        }
        let kept = byID.values
            .filter { now.timeIntervalSince($0.lastSeen) <= Self.maxAge }
            .sorted { $0.lastSeen > $1.lastSeen }
            .prefix(Self.maxEntries)
        let result = Array(kept)
        if result != original { save(result) }
        return result
    }

    private func save(_ entries: [Entry]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(entries) else { return }
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Remembered sessions that aren't in the current live scan, as offline `cloud` rows
    /// (`status` nil), so `mergeLivePlacements` can show them next to the live ones.
    static func offlineRows(_ remembered: [Entry], excluding live: [LiveClaudeAgentEntry]) -> [LiveClaudeAgentEntry] {
        let liveIDs = Set(live.map(\.sessionId))
        return remembered.filter { !liveIDs.contains($0.sessionId) }.map {
            LiveClaudeAgentEntry(
                sessionId: $0.sessionId, kind: "cloud", cwd: $0.cwd, name: $0.name,
                status: nil, startedAt: $0.lastSeen
            )
        }
    }
}
