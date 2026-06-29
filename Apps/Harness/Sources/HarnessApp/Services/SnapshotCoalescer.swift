import Foundation

/// Coalesces rapid main-thread signals into one callback per display frame (~33ms).
/// Mirrors cmux's NotificationBurstCoalescer: snapshot storms (0.5–2/s bursts) collapse
/// into a single model refresh, matching Zed/WezTerm's "dirty flag + one-pass" pattern.
@MainActor
final class SnapshotCoalescer {
    private var pending = false
    private var action: (@MainActor () -> Void)?

    func signal(_ action: @escaping @MainActor () -> Void) {
        self.action = action
        guard !pending else { return }
        pending = true
        DispatchQueue.main.async { [weak self] in
            self?.flush()
        }
    }

    func flushNow() {
        pending = false
        action?()
        action = nil
    }

    private func flush() {
        pending = false
        guard let action else { return }
        self.action = nil
        action()
    }
}
