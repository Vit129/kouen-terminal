import Foundation
import KouenCore

/// Drives the Automations timer (P41) — checks every 60s for due Automations and
/// fires them. Mirrors `AgentScanner`'s weak-registry-calls-a-plain-method pattern;
/// all state lives in `SurfaceRegistry.automationStore`, this class only owns the timer.
public final class AutomationScheduler: @unchecked Sendable {
    public static let shared = AutomationScheduler()
    private var timer: DispatchSourceTimer?
    private weak var registry: SurfaceRegistry?
    private let queue = DispatchQueue(label: "com.vit129.kouen.automation-scheduler")

    public func start(registry: SurfaceRegistry) {
        self.registry = registry
        timer?.cancel()
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + 10, repeating: 60)
        t.setEventHandler { [weak self] in self?.registry?.tickAutomations() }
        t.resume()
        timer = t
    }

    /// Stop the timer (orderly daemon shutdown / between tests). Safe to call repeatedly.
    public func stop() {
        timer?.cancel()
        timer = nil
    }
}
