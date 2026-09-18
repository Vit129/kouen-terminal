import Foundation
import KouenCore

/// Built-in model providers Kouen's own AI features (chat sidebar, inline completion) can be
/// pointed at — generalizes the old single `KouenSettings.claudeAPIKey` field. Mirrors
/// `IssueTrackerType`'s shape (`Apps/Kouen/Sources/KouenApp/UI/Issues/IssueModels.swift`).
public enum ModelProvider: String, CaseIterable, Identifiable, Sendable, Codable {
    case anthropic = "Anthropic"
    case azure = "Azure"
    case google = "Google"
    case openAI = "OpenAI"
    case openRouter = "OpenRouter"
    case xai = "xAI"
    case ollama = "Ollama"

    public var id: String { rawValue }

    public var symbolName: String {
        switch self {
        case .anthropic: return "brain"
        case .azure: return "cloud"
        case .google: return "globe"
        case .openAI: return "sparkle"
        case .openRouter: return "point.3.connected.trianglepath.dotted"
        case .xai: return "xmark.circle"
        case .ollama: return "cpu"
        }
    }

    /// The `AgentKind` whose real logo (`AgentIconRenderer`, already used in Settings ▸ Agents)
    /// this provider should borrow instead of a generic SF Symbol — `nil` when no agent in
    /// `AgentTable.default` maps naturally to this provider (Azure, OpenRouter, Ollama broker
    /// several backends themselves, no single brand to borrow).
    public var agentKindForLogo: AgentKind? {
        switch self {
        case .anthropic: return .claudeCode
        case .openAI: return .codex
        case .google: return .gemini
        case .xai: return .grok
        case .azure, .openRouter, .ollama: return nil
        }
    }
}

/// A user-added provider outside the built-in list — a self-hosted or unlisted endpoint,
/// identified by base URL rather than a known provider name. Non-secret metadata only; the
/// key itself lives in `ModelKeyStore`'s Keychain entry keyed by `id`.
public struct CustomModelEndpoint: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var name: String
    public var baseURL: String

    public init(id: String = UUID().uuidString, name: String, baseURL: String) {
        self.id = id
        self.name = name
        self.baseURL = baseURL
    }
}

extension AgentKind {
    /// The `ModelProvider` most likely to hold this agent's API key, for the Phase 6.3
    /// cross-link ("Installed, needs key" → "Add API Key" opens Manage Models pre-scoped to
    /// this provider). `nil` when an agent has no single obvious provider (e.g. it brokers
    /// several backends itself) — the cross-link button is simply hidden in that case.
    public var suggestedModelProvider: ModelProvider? {
        switch self {
        case .claudeCode: return .anthropic
        case .codex: return .openAI
        case .gemini, .antigravity: return .google
        case .grok: return .xai
        default: return nil
        }
    }
}
