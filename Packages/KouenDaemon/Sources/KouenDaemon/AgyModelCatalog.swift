import Foundation

/// agy's `/model` choices, read from `agy models` instead of a hand-copied list so a model agy adds
/// shows up on the phone without a Kouen release. Cached for a while: the call hits the network.
public enum AgyModelCatalog {
    public struct Catalog: Equatable, Sendable {
        /// (base name for `/model`, display label), in `agy models` order.
        public var models: [[String]]
        public var efforts: [String]
    }

    private static let effortOrder = ["low", "medium", "high", "xhigh", "max"]
    private static let lock = NSLock()
    nonisolated(unsafe) private static var cached: (catalog: Catalog, at: Date)?
    private static let ttl: TimeInterval = 6 * 3600

    /// `agy models` prints `gemini-3.8-flash-high<TAB>Gemini 3.8 Flash (High)` per model×effort.
    /// Folds those into base names (what `/model` takes) plus the set of efforts seen.
    public static func parse(_ output: String) -> Catalog {
        var models: [[String]] = [], seen = Set<String>(), efforts = Set<String>()
        for line in output.split(separator: "\n") {
            let cols = line.split(separator: "\t", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard cols.count == 2, !cols[0].isEmpty else { continue }
            var id = cols[0], label = cols[1]
            if let effort = effortOrder.first(where: { id.hasSuffix("-" + $0) }) {
                efforts.insert(effort)
                id.removeLast(effort.count + 1)
                if let paren = label.range(of: " (", options: .backwards) { label = String(label[..<paren.lowerBound]) }
            }
            if seen.insert(id).inserted { models.append([id, label]) }
        }
        return Catalog(models: models, efforts: effortOrder.filter(efforts.contains))
    }

    /// The cached catalog, refreshed by running `agy models` when stale. Blocks (call off the
    /// main thread); nil when agy isn't installed or prints nothing usable.
    public static func current() -> Catalog? {
        lock.lock(); defer { lock.unlock() }
        if let cached, Date().timeIntervalSince(cached.at) < ttl { return cached.catalog }
        guard let bin = AgentRemoteControlDaemonService.resolveExecutable(named: "agy") else { return cached?.catalog }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: bin)
        process.arguments = ["models"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return cached?.catalog }
        // It fetches over the network; a hang must not wedge the bridge thread waiting on it.
        DispatchQueue.global().asyncAfter(deadline: .now() + 15) { if process.isRunning { process.terminate() } }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let catalog = parse(String(decoding: data, as: UTF8.self))
        guard !catalog.models.isEmpty else { return cached?.catalog }
        cached = (catalog, Date())
        return catalog
    }
}
