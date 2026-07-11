import Foundation
import KouenIPC

/// A scheduled agent launch, addressable via `kouen-mcp`. Fires by spawning a session
/// in `repoPath`, launching `agent`, then typing `prompt` into it — same mechanism a
/// human or `kouenSpawnAgent` uses. `intervalMinutes == 0` disables auto-fire (manual
/// / run-now only). Connection to `agent-memory/plans` is deliberately not modeled
/// here — the `prompt` field is free text, and a prompt like "ทำต่อ p40" relies on the
/// launched agent's own CLAUDE.md continuation convention, not on Kouen understanding
/// plan files.
public struct KouenAutomation: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var repoPath: String
    public var workspaceID: UUID?
    public var agent: String
    public var prompt: String
    public var intervalMinutes: Int
    public var enabled: Bool
    public var lastRunAt: Date?
    public var lastRunStatus: String?
    public var nextRunAt: Date?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(), repoPath: String, workspaceID: UUID? = nil, agent: String,
        prompt: String, intervalMinutes: Int, enabled: Bool = true,
        lastRunAt: Date? = nil, lastRunStatus: String? = nil, nextRunAt: Date? = nil,
        createdAt: Date = Date(), updatedAt: Date = Date()
    ) {
        self.id = id
        self.repoPath = repoPath
        self.workspaceID = workspaceID
        self.agent = agent
        self.prompt = prompt
        self.intervalMinutes = intervalMinutes
        self.enabled = enabled
        self.lastRunAt = lastRunAt
        self.lastRunStatus = lastRunStatus
        self.nextRunAt = nextRunAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Daemon-owned Automation storage, mirroring `TaskStore`'s persistence shape.
public final class AutomationStore: @unchecked Sendable {
    private var automations: [KouenAutomation] = []
    private let lock = NSLock()
    private let url: URL

    public init(url: URL = KouenPaths.automationsURL) {
        self.url = url
        self.automations = Self.loadFromDisk(at: url)
    }

    public func list() -> [KouenAutomation] {
        lock.lock(); defer { lock.unlock() }
        return automations
    }

    public func get(id: UUID) -> KouenAutomation? {
        lock.lock(); defer { lock.unlock() }
        return automations.first { $0.id == id }
    }

    /// Enabled automations whose `nextRunAt` has passed. `intervalMinutes == 0`
    /// automations never appear here (manual/run-now only).
    public func dueAutomations(asOf now: Date) -> [KouenAutomation] {
        lock.lock(); defer { lock.unlock() }
        return automations.filter {
            $0.enabled && $0.intervalMinutes > 0 && ($0.nextRunAt.map { $0 <= now } ?? false)
        }
    }

    @discardableResult
    public func create(
        repoPath: String, workspaceID: UUID?, agent: String, prompt: String, intervalMinutes: Int
    ) -> KouenAutomation {
        lock.lock()
        var automation = KouenAutomation(
            repoPath: repoPath, workspaceID: workspaceID, agent: agent, prompt: prompt,
            intervalMinutes: intervalMinutes
        )
        if intervalMinutes > 0 { automation.nextRunAt = Date() }
        automations.append(automation)
        let toSave = automations
        lock.unlock()
        save(toSave)
        return automation
    }

    @discardableResult
    public func update(
        id: UUID, repoPath: String?, agent: String?, prompt: String?, intervalMinutes: Int?
    ) -> KouenAutomation? {
        lock.lock()
        guard let index = automations.firstIndex(where: { $0.id == id }) else {
            lock.unlock()
            return nil
        }
        if let repoPath { automations[index].repoPath = repoPath }
        if let agent { automations[index].agent = agent }
        if let prompt { automations[index].prompt = prompt }
        if let intervalMinutes {
            automations[index].intervalMinutes = intervalMinutes
            automations[index].nextRunAt = intervalMinutes > 0 ? Date() : nil
        }
        automations[index].updatedAt = Date()
        let updated = automations[index]
        let toSave = automations
        lock.unlock()
        save(toSave)
        return updated
    }

    @discardableResult
    public func setEnabled(id: UUID, enabled: Bool) -> KouenAutomation? {
        lock.lock()
        guard let index = automations.firstIndex(where: { $0.id == id }) else {
            lock.unlock()
            return nil
        }
        automations[index].enabled = enabled
        if enabled, automations[index].intervalMinutes > 0 {
            automations[index].nextRunAt = Date()
        }
        automations[index].updatedAt = Date()
        let updated = automations[index]
        let toSave = automations
        lock.unlock()
        save(toSave)
        return updated
    }

    @discardableResult
    public func delete(id: UUID) -> Bool {
        lock.lock()
        guard let index = automations.firstIndex(where: { $0.id == id }) else {
            lock.unlock()
            return false
        }
        automations.remove(at: index)
        let toSave = automations
        lock.unlock()
        save(toSave)
        return true
    }

    /// Records a fire attempt and reschedules `nextRunAt` (or clears it for
    /// run-once/manual automations).
    @discardableResult
    public func recordRun(id: UUID, status: String, at now: Date = Date()) -> KouenAutomation? {
        lock.lock()
        guard let index = automations.firstIndex(where: { $0.id == id }) else {
            lock.unlock()
            return nil
        }
        automations[index].lastRunAt = now
        automations[index].lastRunStatus = status
        automations[index].updatedAt = now
        let interval = automations[index].intervalMinutes
        automations[index].nextRunAt = interval > 0 ? now.addingTimeInterval(TimeInterval(interval * 60)) : nil
        let updated = automations[index]
        let toSave = automations
        lock.unlock()
        save(toSave)
        return updated
    }

    private static func loadFromDisk(at url: URL) -> [KouenAutomation] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let automations = try? decoder.decode([KouenAutomation].self, from: data) else {
            KouenPaths.backupCorruptFile(at: url, label: "KouenDaemon")
            return []
        }
        return automations
    }

    private func save(_ snapshot: [KouenAutomation]) {
        try? KouenPaths.ensureDirectories()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(snapshot) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
