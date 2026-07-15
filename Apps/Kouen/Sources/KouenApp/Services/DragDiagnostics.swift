import Foundation
import KouenCore

/// Opt-in diagnostics for the P27 pane-drag hang/jitter/no-drop reports (2026-07-15) — the bug
/// is intermittent (reported after long uptime, with many panes and agents running, no fixed
/// repro), so this captures real timing data the next time it happens instead of guessing a fix
/// blind. Off by default; enable with `KOUEN_DEBUG_DRAG=1`. Unified logging (`log stream`/`log
/// show`) does not capture this app's `NSLog` output at all in a dev-signed build (confirmed
/// empty over a 5-minute window), hence a plain file instead.
@MainActor
enum DragDiagnostics {
    static let isEnabled = ProcessInfo.processInfo.environment["KOUEN_DEBUG_DRAG"] == "1"

    private static let logURL = KouenPaths.logsDirectory.appendingPathComponent("drag-diagnostics.log")
    private static var stallTimer: DispatchSourceTimer?

    static func log(_ message: String) {
        guard isEnabled else { return }
        let line = "[\(Date())] \(message)\n"
        guard let data = line.data(using: .utf8) else { return }
        try? FileManager.default.createDirectory(at: KouenPaths.logsDirectory, withIntermediateDirectories: true)
        if let handle = try? FileHandle(forWritingTo: logURL) {
            defer { try? handle.close() }
            handle.seekToEndOfFile()
            handle.write(data)
        } else {
            try? data.write(to: logURL)
        }
    }

    /// Pings the main thread every 100ms while a drag is active. A ping landing more than
    /// 150ms late means something else blocked the main run loop during the drag — a direct
    /// signal for the "freeze/jitter" reports, independent of any guess about the cause.
    static func startStallMonitor() {
        guard isEnabled else { return }
        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timer.schedule(deadline: .now() + .milliseconds(100), repeating: .milliseconds(100))
        timer.setEventHandler {
            let scheduledAt = Date()
            Task { @MainActor in
                let delayMs = Date().timeIntervalSince(scheduledAt) * 1000
                if delayMs > 150 {
                    log("MAIN THREAD STALL during drag: \(Int(delayMs))ms")
                }
            }
        }
        timer.resume()
        stallTimer = timer
    }

    static func stopStallMonitor() {
        stallTimer?.cancel()
        stallTimer = nil
    }
}
