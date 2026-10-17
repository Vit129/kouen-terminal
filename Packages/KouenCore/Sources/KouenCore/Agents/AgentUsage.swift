import Foundation

/// Token counts, context window utilization, and cost metrics for an AI agent turn or session.
public struct AgentUsage: Codable, Sendable, Equatable {
    public var inputTokens: Int?
    public var outputTokens: Int?
    public var cacheReadTokens: Int?
    public var cacheWriteTokens: Int?
    public var thinkingTokens: Int?
    public var totalCostUSD: Double?

    public init(
        inputTokens: Int? = nil,
        outputTokens: Int? = nil,
        cacheReadTokens: Int? = nil,
        cacheWriteTokens: Int? = nil,
        thinkingTokens: Int? = nil,
        totalCostUSD: Double? = nil
    ) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheReadTokens = cacheReadTokens
        self.cacheWriteTokens = cacheWriteTokens
        self.thinkingTokens = thinkingTokens
        self.totalCostUSD = totalCostUSD
    }

    private enum CodingKeys: String, CodingKey {
        case inputTokens, outputTokens, cacheReadTokens, cacheWriteTokens, thinkingTokens, totalCostUSD, contextTokens, shortSummary
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inputTokens = try container.decodeIfPresent(Int.self, forKey: .inputTokens)
        self.outputTokens = try container.decodeIfPresent(Int.self, forKey: .outputTokens)
        self.cacheReadTokens = try container.decodeIfPresent(Int.self, forKey: .cacheReadTokens)
        self.cacheWriteTokens = try container.decodeIfPresent(Int.self, forKey: .cacheWriteTokens)
        self.thinkingTokens = try container.decodeIfPresent(Int.self, forKey: .thinkingTokens)
        self.totalCostUSD = try container.decodeIfPresent(Double.self, forKey: .totalCostUSD)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(inputTokens, forKey: .inputTokens)
        try container.encodeIfPresent(outputTokens, forKey: .outputTokens)
        try container.encodeIfPresent(cacheReadTokens, forKey: .cacheReadTokens)
        try container.encodeIfPresent(cacheWriteTokens, forKey: .cacheWriteTokens)
        try container.encodeIfPresent(thinkingTokens, forKey: .thinkingTokens)
        try container.encodeIfPresent(totalCostUSD, forKey: .totalCostUSD)
        try container.encodeIfPresent(contextTokens, forKey: .contextTokens)
        try container.encodeIfPresent(shortSummary, forKey: .shortSummary)
    }

    /// Estimated context tokens in the current prompt (input + cache read).
    public var contextTokens: Int? {
        let inp = inputTokens ?? 0
        let cache = cacheReadTokens ?? 0
        let total = inp + cache
        return total > 0 ? total : nil
    }

    /// Short human-readable summary, e.g. "28.7k ctx" or "$0.04".
    public var shortSummary: String? {
        if let cost = totalCostUSD, cost > 0.0001 {
            return String(format: "$%.2f", cost)
        }
        if let ctx = contextTokens {
            return formatTokens(ctx) + " ctx"
        }
        if let out = outputTokens {
            return formatTokens(out) + " out"
        }
        return nil
    }

    private func formatTokens(_ n: Int) -> String {
        if n >= 1_000_000 {
            let val = Double(n) / 1_000_000.0
            return String(format: val >= 10 ? "%.0fM" : "%.1fM", val)
        }
        if n >= 1_000 {
            let val = Double(n) / 1_000.0
            return String(format: val >= 10 ? "%.0fk" : "%.1fk", val)
        }
        return "\(n)"
    }
}
