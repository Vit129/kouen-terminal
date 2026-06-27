import Foundation
import HarnessCore

public struct FrecencyEntry: Codable, Sendable {
    public let path: String
    public var count: Double
    public var lastVisited: Date
}

@MainActor
public final class FrecencyDirectoryStore: @unchecked Sendable {
    public static let shared = FrecencyDirectoryStore()
    
    public private(set) var entries: [String: FrecencyEntry] = [:]
    private let fileURL: URL
    
    private init() {
        self.fileURL = HarnessPaths.applicationSupport.appendingPathComponent("frecency-dirs.json")
        load()
    }
    
    public func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([FrecencyEntry].self, from: data)
            self.entries = Dictionary(uniqueKeysWithValues: decoded.map { ($0.path, $0) })
        } catch {
            self.entries = [:]
        }
    }
    
    public func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let list = Array(entries.values)
            let data = try encoder.encode(list)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Ignore or log
        }
    }
    
    public func recordVisit(path: String) {
        let cleanPath = (path as NSString).standardizingPath
        guard !cleanPath.isEmpty, cleanPath != "/" else { return }
        
        var entry = entries[cleanPath] ?? FrecencyEntry(path: cleanPath, count: 0, lastVisited: Date())
        entry.count += 1
        entry.lastVisited = Date()
        entries[cleanPath] = entry
        save()
    }
    
    public func ranked() -> [String] {
        let now = Date()
        let scored = entries.values.map { entry -> (path: String, score: Double) in
            let seconds = now.timeIntervalSince(entry.lastVisited)
            let age = max(1.0, seconds)
            let score = entry.count / log(1.0 + age)
            return (entry.path, score)
        }
        return scored.sorted { $0.score > $1.score }.map { $0.path }
    }
}
