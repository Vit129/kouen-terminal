import Dispatch
import HarnessCore

/// Watches the OS memory-pressure signal (DISPATCH_SOURCE_TYPE_MEMORYPRESSURE) and, on
/// `.warning`/`.critical`, broadcasts `NotificationBus.shared.memoryPressure` so renderer
/// surfaces purge their glyph atlas, shaped-run, and inline-image caches. Those caches never
/// shrink on their own over a long session, so this is the only proactive release point.
@MainActor
final class MemoryPressureMonitor {
    static let shared = MemoryPressureMonitor()

    private var source: DispatchSourceMemoryPressure?

    private init() {}

    func start() {
        guard source == nil else { return }
        let source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
        source.setEventHandler {
            NotificationBus.shared.postMemoryPressure()
        }
        source.resume()
        self.source = source
    }
}
