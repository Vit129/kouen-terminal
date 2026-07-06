import Carbon
import KouenCore
import KouenTerminalKit

/// Watches PTY output for password prompt patterns and toggles macOS Secure Input
/// so keystrokes are hidden from screen capture while a password prompt is visible.
///
/// Tracks active surfaces by SurfaceID so teardown works via onRetire without
/// needing the surface view reference. Each surface contributes at most 1 to the
/// ref-count — repeated prompt matches on the same surface just reset the 30s timer.
@MainActor
final class SecureInputMonitor {
    static let shared = SecureInputMonitor()

    // ponytail: ref-count so N panes each contribute exactly 1; EnableSecureEventInput
    // is not itself ref-counted by the OS, so we must be.
    private var active: Set<SurfaceID> = []
    private var timers: [SurfaceID: DispatchWorkItem] = [:]

    // Substrings covering sudo, ssh, gpg, git, and VT conceal-mode (ESC[8m).
    private let patterns: [String] = ["assword", "assphrase", "Enter PIN", "sudo:", "\u{1b}[8m"]

    private init() {}

    func observeSurface(_ host: TerminalHostView) {
        let id = host.surfaceID
        let surface = host.surfaceView
        // Guard against double-install: a second call would overwrite onRawOutput
        // (losing the first listener) and double-chain onCommandFinished, causing
        // release(id) to fire twice per OSC 133 — corrupting the active set.
        guard surface.onRawOutput == nil else { return }

        surface.onRawOutput = { [weak self] data in
            guard let self,
                  let text = String(data: data, encoding: .utf8),
                  self.patterns.contains(where: { text.contains($0) }) else { return }
            if self.active.insert(id).inserted { EnableSecureEventInput() }
            self.armTimer(for: id)
        }

        // Chain onto the existing onCommandFinished set by TerminalHostView.configureNative()
        // so shell prompt return (OSC 133 C) immediately releases secure input.
        let prev = surface.onCommandFinished
        surface.onCommandFinished = { [weak self] duration, code in
            prev?(duration, code)
            self?.release(id)
        }
    }

    /// Call from onRetire to ensure secure input is released when a pane closes.
    func release(_ surfaceID: SurfaceID) {
        timers.removeValue(forKey: surfaceID)?.cancel()
        guard active.remove(surfaceID) != nil else { return }
        if active.isEmpty { DisableSecureEventInput() }
    }

    private func armTimer(for id: SurfaceID) {
        timers[id]?.cancel()
        // ponytail: 30s safety valve — if OSC 133 never fires (non-shell-integration prompt),
        // secure input auto-releases. Upgrade path: make the timeout user-configurable.
        let work = DispatchWorkItem { [weak self] in self?.release(id) }
        timers[id] = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: work)
    }
}
