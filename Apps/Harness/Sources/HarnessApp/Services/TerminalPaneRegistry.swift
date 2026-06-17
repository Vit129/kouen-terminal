import Foundation
import HarnessCore
import HarnessTerminalKit

@MainActor
final class TerminalPaneRegistry {
    private var hosts: [SurfaceID: TerminalHostView] = [:]

    func register(_ host: TerminalHostView) {
        hosts[host.surfaceID] = host
    }

    func host(for surfaceID: SurfaceID) -> TerminalHostView? {
        hosts[surfaceID]
    }

    func removeHost(for surfaceID: SurfaceID) {
        if let host = hosts.removeValue(forKey: surfaceID) {
            host.resignIfFirstResponder()
            host.removeFromSuperview()
        }
    }

    func allHosts() -> [TerminalHostView] {
        Array(hosts.values)
    }

    func prune(keeping surfaceIDs: Set<SurfaceID>) {
        let removed = hosts.keys.filter { !surfaceIDs.contains($0) }
        for id in removed {
            if let host = hosts.removeValue(forKey: id) {
                // Ensure the surface resigns first responder before dealloc — a zombie
                // first responder crashes on the next key event (CASE-037).
                host.resignIfFirstResponder()
                host.removeFromSuperview()
            }
        }
    }
}
