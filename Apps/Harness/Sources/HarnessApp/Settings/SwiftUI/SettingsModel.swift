import SwiftUI
import HarnessCore
import HarnessSettings

/// Observable bridge between HarnessSettings (value type) and SwiftUI views.
/// Reads from SessionCoordinator on every snapshot notification; writes through
/// the same coordinator so the live surfaces update exactly as the AppKit VC did.
@Observable @MainActor
final class SettingsModel {
    var settings: HarnessSettings = SessionCoordinator.shared.settings
    var keepSessions: Bool = SessionCoordinator.shared.snapshot.keepSessionsOnQuit

    @ObservationIgnored
    nonisolated(unsafe) private var snapshotObserver: Any?

    init() {
        snapshotObserver = NotificationCenter.default.addObserver(
            forName: NotificationBus.shared.snapshotChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.settings = SessionCoordinator.shared.settings
                self.keepSessions = SessionCoordinator.shared.snapshot.keepSessionsOnQuit
            }
        }
    }

    deinit {
        if let snapshotObserver {
            NotificationCenter.default.removeObserver(snapshotObserver)
        }
    }

    /// Write a single HarnessSettings field and persist to disk.
    func update<T>(_ keyPath: WritableKeyPath<HarnessSettings, T>, _ value: T) {
        SessionCoordinator.shared.settings[keyPath: keyPath] = value
        try? SessionCoordinator.shared.settings.save()
        settings = SessionCoordinator.shared.settings
    }

    func setKeepSessions(_ keep: Bool) {
        SessionCoordinator.shared.requestDaemon(.setKeepSessionsOnQuit(keep))
        keepSessions = keep
    }
}
