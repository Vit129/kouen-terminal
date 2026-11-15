import Foundation
import KouenCore

/// Owns one long-lived daemon subscription and re-creates it when it ends on its own (daemon
/// restart, dropped socket). A subscription we drop deliberately (`reset()`, e.g. an endpoint
/// switch) also fires its `onEnd`; the generation check makes that stale end a no-op instead of
/// clearing and re-creating the replacement.
@MainActor
final class ResubscribingSlot<Subscription> {
    typealias Maker = @MainActor (@escaping @Sendable () -> Void) throws -> Subscription

    private(set) var current: Subscription?
    private var generation = 0

    /// Creates the subscription if none exists. `make` receives the `onEnd` to hand to the transport.
    func ensure(_ make: @escaping Maker) {
        guard current == nil else { return }
        let owner = generation
        do {
            current = try make { [weak self] in
                Task { @MainActor in
                    guard let self, self.generation == owner, self.current != nil else { return }
                    self.current = nil
                    self.ensure(make)
                }
            }
        } catch {
            fputs("Kouen: failed to subscribe to daemon channel: \(error)\n", kouenStderr)
        }
    }

    /// Drops the current subscription; its pending `onEnd` is now stale.
    func reset() {
        generation += 1
        current = nil
    }
}
