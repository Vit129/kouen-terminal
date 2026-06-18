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
        // Keep alive long enough for ALL pending AppKit events to drain.
        // 100ms wasn't enough — key events can queue across multiple run loop iterations
        // during rapid rebuilds (initial launch, session switch). 500ms covers worst case.
        retired.append(host)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.retired.removeAll { $0 === host }
        }
    }
}
