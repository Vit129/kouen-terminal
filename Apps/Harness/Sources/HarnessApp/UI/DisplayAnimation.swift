import AppKit

/// Drives a manual animation at the display's refresh rate (up to 120 Hz on ProMotion) for
/// work Core Animation cannot interpolate, such as split-view divider positions.
@MainActor
final class DisplayAnimation: NSObject {
    static var reducesMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }

    private let duration: TimeInterval
    private let step: (Double) -> Void
    private let completion: () -> Void
    private var link: CADisplayLink?
    private var started: CFTimeInterval = 0

    /// `step` receives linear progress from 0 to 1, and is always called with 1 before `completion`.
    init(duration: TimeInterval, step: @escaping (Double) -> Void, completion: @escaping () -> Void = {}) {
        self.duration = duration
        self.step = step
        self.completion = completion
    }

    func start(on view: NSView) {
        started = CACurrentMediaTime()
        step(0)
        let link = view.displayLink(target: self, selector: #selector(tick))
        if let rate = view.window?.screen?.maximumFramesPerSecond, rate > 60 {
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: Float(rate), preferred: Float(rate))
        }
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    /// Stops without calling `step` or `completion` again.
    func cancel() {
        link?.invalidate()
        link = nil
    }

    var isRunning: Bool { link != nil }

    @objc private func tick() {
        let progress = duration > 0 ? min(1, (CACurrentMediaTime() - started) / duration) : 1
        step(progress)
        guard progress >= 1 else { return }
        cancel()
        completion()
    }
}
