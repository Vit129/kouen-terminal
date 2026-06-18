import Foundation
import HarnessCore
import HarnessTerminalKit

@MainActor
final class TerminalPaneRegistry {
    private var hosts: [SurfaceID: TerminalHostView] = [:]

    /// Hosts pending dealloc — held for one run loop cycle so AppKit's in-flight
    /// key events drain before the underlying surface view is freed (RL-040).
    private var retired: [TerminalHostView] = []

    func register(_ host: TerminalHostView) {
        hosts[host.surfaceID] = host
    }

    func host(for surfaceID: SurfaceID) -> TerminalHostView? {
        hosts[surfaceID]
    }

    func removeHost(for surfaceID: SurfaceID) {
        if let host = hosts.removeValue(forKey: surfaceID) {
            retire(host)
        }
    }

    func allHosts() -> [TerminalHostView] {
        Array(hosts.values)
    }

    func prune(keeping surfaceIDs: Set<SurfaceID>) {
        let removed = hosts.keys.filter { !surfaceIDs.contains($0) }
        for id in removed {
            if let host = hosts.removeValue(forKey: id) {
                retire(host)
            }
        }
    }

    private func retire(_ host: TerminalHostView) {
        host.resignIfFirstResponder()
        host.removeFromSuperview()
        // Keep alive long enough for paired keyUp/mouseUp events to drain.
        // A single async tick isn't enough — keyUp arrives in a later event loop iteration.
        retired.append(host)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.retired.removeAll { $0 === host }
        }
    }
}
