import Foundation

/// User-configured output triggers: when terminal output matches a pattern,
/// fire a notification (notch peek + optional sound).
public struct OutputTrigger: Codable, Sendable {
    public let pattern: String
    public let title: String?
    public let sound: Bool?

    public init(pattern: String, title: String? = nil, sound: Bool? = nil) {
        self.pattern = pattern
        self.title = title
        self.sound = sound
    }
}

public enum OutputTriggerStore {
    nonisolated(unsafe) private static var cached: [OutputTrigger]?

    public static func load() -> [OutputTrigger] {
        if let cached { return cached }
        let file = HarnessPaths.applicationSupport.appendingPathComponent("output-triggers.json")
        guard let data = try? Data(contentsOf: file),
              let triggers = try? JSONDecoder().decode([OutputTrigger].self, from: data),
              !triggers.isEmpty else {
            cached = []
            return []
        }
        cached = triggers
        return triggers
    }

    /// Reset cache (e.g. after settings change)
    public static func reload() { cached = nil }
}
