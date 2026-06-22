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
        // Stop the display link BEFORE removing from superview so AppKit's internal
        // _NSDisplayLinkForwarder cannot dispatch viewDidMoveToWindow on a freed view.
        host.stopSurfaceDisplayLink()
        host.removeFromSuperview()
        // Keep alive long enough for ALL pending AppKit events to drain.
        // 500ms wasn't enough — alternate-screen programs (fzf, zi, vim) trigger rapid
        // rebuild sequences where the display link forwarder schedules a callback in a
        // later run-loop iteration. 1.5s covers the full cadence cycle. (RL-040/041)
        ZombieHoldRegistry.shared.hold(host)
    }
}
