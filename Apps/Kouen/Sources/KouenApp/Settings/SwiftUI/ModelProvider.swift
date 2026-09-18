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
    case cursor = "Cursor"
    case copilot = "GitHub Copilot"
    case kiro = "Kiro"
    case aider = "Aider"
    case goose = "Goose"
    case openCode = "OpenCode"
    case openClaw = "OpenClaw"
    case pi = "Pi"
    case hermes = "Hermes"

    public var id: String { rawValue }

    public var symbolName: String {
        switch self {
        case .anthropic: return "brain"
        case .azure: return "cloud"
        case .google: return "globe"
        case .openAI: return "sparkle"
        case .openRouter: return "point.3.connected.trianglepath.dotted"
        case .xai: return "xmark.circle"
        case .cursor: return "cursorarrow.click"
        case .copilot: return "chevron.left.forwardslash.chevron.right"
        case .kiro: return "cloud.fill"
        case .aider: return "wrench.and.screwdriver"
        case .goose: return "bird"
        case .openCode: return "chevron.left.slash.chevron.right"
        case .openClaw: return "pawprint"
        case .pi: return "number"
        case .hermes: return "bolt.horizontal"
        }
    }

    /// The `AgentKind` whose real logo (`AgentIconRenderer`, already used in Settings ▸ Agents)
    /// this provider should borrow instead of a generic SF Symbol — `nil` when no agent in
    /// `AgentTable.default` maps naturally to this provider (Azure and OpenRouter broker several
    /// backends themselves, no single brand to borrow). One entry per distinct agent brand in
    /// `AgentTable.default`/Settings ▸ Agents — `.generic` has no identity to match, so it's
    /// left out; wrapper CLIs that only ever consume an *existing* provider's key
    /// (`.gemini`/`.antigravity` → Google, `.grok` → xAI, ...) don't get a second entry of
    /// their own.
    public var agentKindForLogo: AgentKind? {
        switch self {
        case .anthropic: return .claudeCode
        case .openAI: return .codex
        case .google: return .gemini
        case .xai: return .grok
        case .cursor: return .cursor
        case .copilot: return .copilot
        case .kiro: return .kiro
        case .aider: return .aider
        case .goose: return .goose
        case .openCode: return .openCode
        case .openClaw: return .openClaw
        case .pi: return .pi
        case .hermes: return .hermes
        case .azure, .openRouter: return nil
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
        case .cursor: return .cursor
        case .copilot: return .copilot
        case .kiro: return .kiro
        case .aider: return .aider
        case .goose: return .goose
        case .openCode: return .openCode
        case .openClaw: return .openClaw
        case .pi: return .pi
        case .hermes: return .hermes
        case .generic: return nil
        }
    }
}
