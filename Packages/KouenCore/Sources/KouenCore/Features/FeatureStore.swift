import Foundation

/// Thread-safe storage for `KouenFeature` instances, mirroring `AutomationStore`'s persistence architecture.
public final class FeatureStore: @unchecked Sendable {
    public static let shared = FeatureStore()
    private var features: [KouenFeature] = []
    private let lock = NSLock()
    private let url: URL

    public init(url: URL = KouenPaths.featuresURL) {
        self.url = url
        self.features = Self.loadFromDisk(at: url)
    }

    public func list(repoPath: String? = nil) -> [KouenFeature] {
        lock.lock(); defer { lock.unlock() }
        if let repoPath {
            return features.filter { $0.repoPath == repoPath }
        }
        return features
    }

    public func get(slug: String) -> KouenFeature? {
        lock.lock(); defer { lock.unlock() }
        return features.first { $0.slug == slug }
    }

    public func get(id: UUID) -> KouenFeature? {
        lock.lock(); defer { lock.unlock() }
        return features.first { $0.id == id }
    }

    public func find(branch: String, repoPath: String? = nil) -> KouenFeature? {
        lock.lock(); defer { lock.unlock() }
        return features.first { feature in
            if let repoPath, feature.repoPath != repoPath {
                return false
            }
            return feature.branch == branch
        }
    }

    @discardableResult
    public func create(
        slug: String,
        repoPath: String,
        branch: String? = nil,
        baseBranch: String? = nil,
        worktreePath: String? = nil,
        phase: FeaturePhase = .interview
    ) -> KouenFeature {
        lock.lock()
        // If an existing feature with this slug exists, update or replace
        if let index = features.firstIndex(where: { $0.slug == slug }) {
            var existing = features[index]
            existing.repoPath = repoPath
            if let branch { existing.branch = branch }
            if let baseBranch { existing.baseBranch = baseBranch }
            if let worktreePath { existing.worktreePath = worktreePath }
            existing.phase = phase
            existing.updatedAt = Date()
            features[index] = existing
            let toSave = features
            lock.unlock()
            save(toSave)
            KouenFeatureMarkdownSync.ensurePlanFilesExist(for: existing)
            return existing
        }

        let feature = KouenFeature(
            slug: slug,
            repoPath: repoPath,
            phase: phase,
            worktreePath: worktreePath,
            branch: branch,
            baseBranch: baseBranch
        )
        features.append(feature)
        let toSave = features
        lock.unlock()
        save(toSave)
        KouenFeatureMarkdownSync.ensurePlanFilesExist(for: feature)
        return feature
    }

    @discardableResult
    public func updatePhase(slug: String, phase: FeaturePhase) -> KouenFeature? {
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return nil
        }
        features[index].phase = phase
        features[index].updatedAt = Date()
        let updated = features[index]
        let toSave = features
        lock.unlock()
        save(toSave)
        KouenFeatureMarkdownSync.syncPhase(slug: slug, repoPath: updated.repoPath, phase: phase)
        return updated
    }

    @discardableResult
    public func approveGate(slug: String, gate: Int, approver: String, notes: String? = nil) -> KouenFeature? {
        // 1-3 are the SDLC gates (Architect/Scenario/Seam); 4 is Merge Review (P46 Pillar 6),
        // approved separately from the SDLC phase — a feature can sit in `.dev` for a while
        // with several PRs, each gated by its own Gate 4 approval.
        guard (1...4).contains(gate) else { return nil }
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return nil
        }
        var feature = features[index]
        // Remove prior entry for same gate if any
        feature.gates.removeAll { $0.gate == gate }
        feature.gates.append(GateApproval(gate: gate, approver: approver, approved: true, notes: notes))
        feature.updatedAt = Date()
        features[index] = feature
        let toSave = features
        lock.unlock()
        save(toSave)
        KouenFeatureMarkdownSync.syncGateApproval(slug: slug, repoPath: feature.repoPath, gate: gate, approver: approver, notes: notes)
        return feature
    }

    @discardableResult
    public func setWorktree(slug: String, worktreePath: String?) -> KouenFeature? {
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return nil
        }
        features[index].worktreePath = worktreePath
        features[index].updatedAt = Date()
        let updated = features[index]
        let toSave = features
        lock.unlock()
        save(toSave)
        return updated
    }

    @discardableResult
    public func setSuperseded(slug: String, supersededBy: String) -> KouenFeature? {
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return nil
        }
        features[index].supersededBy = supersededBy
        features[index].updatedAt = Date()
        let updated = features[index]
        let toSave = features
        lock.unlock()
        save(toSave)
        return updated
    }

    @discardableResult
    public func addTask(slug: String, task: FeatureTask) -> KouenFeature? {
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return nil
        }
        features[index].tasks.append(task)
        features[index].updatedAt = Date()
        let updated = features[index]
        let toSave = features
        lock.unlock()
        save(toSave)
        return updated
    }

    @discardableResult
    public func updateTaskDone(slug: String, taskId: UUID, done: Bool) -> KouenFeature? {
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return nil
        }
        if let taskIdx = features[index].tasks.firstIndex(where: { $0.id == taskId }) {
            features[index].tasks[taskIdx].done = done
            features[index].updatedAt = Date()
        }
        let updated = features[index]
        let toSave = features
        lock.unlock()
        save(toSave)
        return updated
    }

    @discardableResult
    public func delete(slug: String) -> Bool {
        lock.lock()
        guard let index = features.firstIndex(where: { $0.slug == slug }) else {
            lock.unlock()
            return false
        }
        features.remove(at: index)
        let toSave = features
        lock.unlock()
        save(toSave)
        return true
    }

    /// Detects features in `repoPath` that have overlapping artifact paths where another active feature
    /// has advanced further or is newer. Marks older stalled features as superseded if appropriate.
    public func detectStaleOrSuperseded(repoPath: String) -> [KouenFeature] {
        lock.lock()
        let active = features.filter { $0.repoPath == repoPath && $0.phase != .completed }
        var newlySuperseded: [KouenFeature] = []

        for (i, older) in active.enumerated() {
            guard older.supersededBy == nil else { continue }
            let olderArtifacts = Set(older.tasks.flatMap(\.artifacts))
            guard !olderArtifacts.isEmpty else { continue }

            for (j, newer) in active.enumerated() where i != j {
                let newerArtifacts = Set(newer.tasks.flatMap(\.artifacts))
                let overlap = olderArtifacts.intersection(newerArtifacts)
                if !overlap.isEmpty && newer.updatedAt > older.updatedAt {
                    // older is superseded by newer
                    if let idx = features.firstIndex(where: { $0.id == older.id }) {
                        features[idx].supersededBy = newer.slug
                        features[idx].updatedAt = Date()
                        newlySuperseded.append(features[idx])
                    }
                    break
                }
            }
        }
        let toSave = features
        lock.unlock()
        if !newlySuperseded.isEmpty {
            save(toSave)
        }
        return newlySuperseded
    }

    private static func loadFromDisk(at url: URL) -> [KouenFeature] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let items = try? decoder.decode([KouenFeature].self, from: data) else {
            KouenPaths.backupCorruptFile(at: url, label: "FeatureStore")
            return []
        }
        return items
    }

    private func save(_ snapshot: [KouenFeature]) {
        try? KouenPaths.ensureDirectories()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(snapshot) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
