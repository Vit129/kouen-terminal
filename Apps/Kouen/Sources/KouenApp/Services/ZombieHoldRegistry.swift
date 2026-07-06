import Foundation

/// Keeps a strong reference to AppKit objects that were logically freed but may still
/// receive deferred callbacks (layout(), resetCursorRects(), display-link, tracking areas).
/// Replaces the scattered `retired* + asyncAfter` arrays across the codebase (RL-040/041).
///
/// Usage:  ZombieHoldRegistry.shared.hold(view)          // default 1.5s
///         ZombieHoldRegistry.shared.hold(pill, duration: 0.5)  // RL-041: keyUp cycle
@MainActor
final class ZombieHoldRegistry {
    static let shared = ZombieHoldRegistry()
    private init() {}

    private var held: [ObjectIdentifier: AnyObject] = [:]

    func hold(_ object: AnyObject, duration: TimeInterval = 1.5) {
        let id = ObjectIdentifier(object)
        held[id] = object
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.held.removeValue(forKey: id)
        }
    }
}
