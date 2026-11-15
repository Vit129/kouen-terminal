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
    private var scanGenerations: [SurfaceID: UUID] = [:]

    /// Scans run here, off main: only a focused pane's chunks are scanned, and each
    /// surface keeps its own carry-over so a prompt split across two chunks still matches.
    private let scanQueue: DispatchQueue
    private let enable: @MainActor () -> Void
    private let disable: @MainActor () -> Void
    // Touched only on `scanQueue`.
    nonisolated(unsafe) private var scanners: [SurfaceID: SecureInputPromptScanner] = [:]

    init(
        scanQueue: DispatchQueue = DispatchQueue(label: "com.vit129.kouen.secure-input-scan", qos: .userInitiated),
        enable: @escaping @MainActor () -> Void = { EnableSecureEventInput() },
        disable: @escaping @MainActor () -> Void = { DisableSecureEventInput() }
    ) {
        self.scanQueue = scanQueue
        self.enable = enable
        self.disable = disable
    }

    func observeSurface(_ host: TerminalHostView) {
        let id = host.surfaceID
        let surface = host.surfaceView
        // Guard against double-install: a second call would overwrite onRawOutput
        // (losing the first listener) and double-chain onCommandFinished, causing
        // release(id) to fire twice per OSC 133 — corrupting the active set.
        guard surface.onRawOutput == nil else { return }

        surface.onRawOutput = { [weak self, weak surface] data in
            // Secure Input is system-wide: only the pane the user is typing into may arm it.
            guard let self else { return }
            self.scanOutput(data, for: id) { [weak surface] in
                surface.map { $0.window?.isKeyWindow == true && $0.window?.firstResponder === $0 } ?? false
            }
        }

        // Chain onto the existing onCommandFinished set by TerminalHostView.configureNative()
        // so shell prompt return (OSC 133 C) immediately releases secure input.
        let prev = surface.onCommandFinished
        surface.onCommandFinished = { [weak self] duration, code in
            prev?(duration, code)
            self?.release(id)
        }
    }

    func scanOutput(_ data: Data, for id: SurfaceID, isFocused: @escaping @MainActor @Sendable () -> Bool) {
        let focused = isFocused()
        let generation = scanGenerations[id] ?? UUID()
        scanGenerations[id] = generation
        scanQueue.async {
            var scanner = self.scanners[id] ?? SecureInputPromptScanner()
            let hit = scanner.feed(data, focused: focused)
            self.scanners[id] = scanner
            guard hit else { return }
            DispatchQueue.main.async {
                MainActor.assumeIsolated {
                    // Release/retirement invalidates queued results; focus may have changed
                    // while scanning even when this surface's generation is still current.
                    guard self.scanGenerations[id] == generation, isFocused() else { return }
                    if self.active.insert(id).inserted { self.enable() }
                    self.armTimer(for: id)
                }
            }
        }
    }

    /// Call from onRetire to ensure secure input is released when a pane closes.
    func release(_ surfaceID: SurfaceID) {
        scanGenerations.removeValue(forKey: surfaceID)
        timers.removeValue(forKey: surfaceID)?.cancel()
        scanQueue.async { self.scanners[surfaceID] = nil }
        guard active.remove(surfaceID) != nil else { return }
        if active.isEmpty { disable() }
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
