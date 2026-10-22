import AppKit
import Foundation

/// Keeps the Mac (and so the network) awake while Kouen runs alongside another AI provider app
/// — Claude Desktop, VS Code, Antigravity, Codex, ChatGPT, … — so a long agent run in any of
/// them isn't cut by idle system sleep. Released as soon as the last provider app quits.
/// Opt out with `defaults write <bundle id> KouenKeepAwakeForAIProviders -bool NO`.
///
/// Idle-sleep assertions don't stop lid-close sleep. With the root helper installed
/// (`Scripts/closed-lid-helper.sh install`) and `KouenClosedLidAwake` set to YES (opt-in),
/// Kouen also sets `pmset disablesleep` while a provider is running, and restores it on
/// last-provider-quit / Kouen quit.
@MainActor
final class AIProviderAwakeService {
    static let shared = AIProviderAwakeService()
    static let assertionKeyPrefix = "ai-provider:"
    static let defaultsKey = "KouenKeepAwakeForAIProviders"
    static let closedLidDefaultsKey = "KouenClosedLidAwake"
    nonisolated static let helperPath = "/Library/PrivilegedHelperTools/kouen-pmset"

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
    /// Runs `helper on|off` through passwordless sudo; true on success. Injected for tests.
    private let helperRunner: (String) -> Bool
    private var observers: [NSObjectProtocol] = []
    private(set) var closedLidHeld = false

    init(
        assertions: ActivityAssertionManager = .shared,
        helperRunner: @escaping (String) -> Bool = AIProviderAwakeService.runHelper
    ) {
        self.assertions = assertions
        self.helperRunner = helperRunner
    }

    /// `sudo -n` never prompts: without the installed sudoers rule it just fails.
    nonisolated static func runHelper(_ arg: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["-n", helperPath, arg]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do { try process.run() } catch { return false }
        process.waitUntilExit()
        return process.terminationStatus == 0
    }

    private static var closedLidOptedIn: Bool {
        UserDefaults.standard.bool(forKey: closedLidDefaultsKey)
            && FileManager.default.isExecutableFile(atPath: helperPath)
    }

    /// Idempotent. `closedLidHeld` flips only when the helper reports success, so a failed
    /// `off` is retried on the next refresh instead of being forgotten.
    func setClosedLid(_ on: Bool) {
        guard on != closedLidHeld else { return }
        if helperRunner(on ? "on" : "off") { closedLidHeld = on }
    }

    nonisolated static func isProvider(bundleID: String?, name: String?) -> Bool {
        if let bundleID, providerBundleIDs.contains(bundleID) { return true }
        guard let name = name?.lowercased() else { return false }
        return providerNameFragments.contains { name.contains($0) }
    }

    func start() {
        guard observers.isEmpty else { return }
        // A crash can leave disablesleep on; reset it once, only for users who opted in.
        if Self.closedLidOptedIn { _ = helperRunner("off") }
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
        setClosedLid(false)
    }

    func refresh(enabled: Bool = UserDefaults.standard.object(forKey: AIProviderAwakeService.defaultsKey) as? Bool ?? true) {
        let running = enabled ? NSWorkspace.shared.runningApplications.filter {
            $0.processIdentifier != ProcessInfo.processInfo.processIdentifier
                && Self.isProvider(bundleID: $0.bundleIdentifier, name: $0.localizedName)
        } : []
        setClosedLid(!running.isEmpty && Self.closedLidOptedIn)
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
