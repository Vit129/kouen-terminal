import AppKit
import Foundation

/// Keeps the Mac (and so the network) awake while Kouen runs alongside another AI provider app
/// — Claude Desktop, VS Code, Antigravity, Codex, ChatGPT, … — so a long agent run in any of
/// them isn't cut by idle system sleep. Released as soon as the last provider app quits.
/// Opt out with `defaults write <bundle id> KouenKeepAwakeForAIProviders -bool NO`.
@MainActor
final class AIProviderAwakeService {
    static let shared = AIProviderAwakeService()
    static let assertionKeyPrefix = "ai-provider:"
    static let defaultsKey = "KouenKeepAwakeForAIProviders"

    /// Bundle IDs of the provider apps. Antigravity / Codex / ChatGPT IDs are best-effort,
    /// so `providerNameFragments` backs them up.
    nonisolated static let providerBundleIDs: Set<String> = [
        "com.anthropic.claudefordesktop",
        "com.microsoft.VSCode",
        "com.microsoft.VSCodeInsiders",
        "com.google.antigravity",
        "com.openai.codex",
        "com.openai.chat",
    ]
    nonisolated static let providerNameFragments = ["antigravity", "codex", "chatgpt"]

    private let assertions: ActivityAssertionManager
    private var observers: [NSObjectProtocol] = []

    init(assertions: ActivityAssertionManager = .shared) {
        self.assertions = assertions
    }

    nonisolated static func isProvider(bundleID: String?, name: String?) -> Bool {
        if let bundleID, providerBundleIDs.contains(bundleID) { return true }
        guard let name = name?.lowercased() else { return false }
        return providerNameFragments.contains { name.contains($0) }
    }

    func start() {
        guard observers.isEmpty else { return }
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didLaunchApplicationNotification, NSWorkspace.didTerminateApplicationNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.refresh() }
            })
        }
        refresh()
    }

    func stop() {
        for observer in observers { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
        observers.removeAll()
        refresh(enabled: false)
    }

    func refresh(enabled: Bool = UserDefaults.standard.object(forKey: AIProviderAwakeService.defaultsKey) as? Bool ?? true) {
        let running = enabled ? NSWorkspace.shared.runningApplications.filter {
            $0.processIdentifier != ProcessInfo.processInfo.processIdentifier
                && Self.isProvider(bundleID: $0.bundleIdentifier, name: $0.localizedName)
        } : []
        let key = Self.assertionKeyPrefix + "running"
        if running.isEmpty {
            assertions.endActivity(key: key)
        } else {
            let names = running.compactMap(\.localizedName).sorted().joined(separator: ", ")
            assertions.beginActivity(
                key: key,
                reason: "Kouen keeping Mac awake for AI providers (\(names))",
                options: .idleSystemSleepDisabled
            )
        }
    }
}
