import AppKit
import HarnessCore

/// Resize the surviving cards at display cadence. Their terminal views stay mounted,
/// so text is repainted at its real pixel size and PTY resize votes coalesce normally.
/// The actual entering/closing pane sits underneath; no blank ghost or scaled text.
@MainActor
final class PaneTransitions: NSObject {
    private weak var container: PaneContainerView?
    private let before: [SurfaceID: NSRect]
    private let after: [SurfaceID: NSRect]
    private let revealed: [PaneIslandView]
    private var link: CADisplayLink?
    private var started: CFTimeInterval = 0

    init?(container: PaneContainerView, from before: [SurfaceID: NSRect], to after: [SurfaceID: NSRect]) {
        let added = Set(after.keys).subtracting(before.keys)
        let removed = Set(before.keys).subtracting(after.keys)
        guard container.window != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
              added.count + removed.count == 1,
              after.contains(where: { id, frame in before[id].map { $0 != frame } == true }) else { return nil }
        self.container = container
        self.before = before
        self.after = after
        revealed = container.retainedIslands.filter { added.contains($0.surfaceID) || removed.contains($0.surfaceID) }
    }

    func start() {
        started = CACurrentMediaTime()
        apply(progress: 0)
        guard let container else { return }
        let link = container.displayLink(target: self, selector: #selector(tick))
        if let rate = container.window?.screen?.maximumFramesPerSecond, rate > 60 {
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: Float(rate), preferred: Float(rate))
        }
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    @objc private func tick() {
        guard let container, container.window != nil else { cancel(); return }
        let progress = min(1, (CACurrentMediaTime() - started) / HarnessDesign.Motion.standard)
        apply(progress: progress)
        if progress >= 1 { container.finishTransition() }
    }

    func apply(progress: Double) {
        guard let container else { return }
        let progress = min(1, max(0, progress))
        let eased = CGFloat(1 - pow(1 - progress, 3))
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (id, target) in after {
            guard let source = before[id], source != target, let island = container.island(for: id) else { continue }
            island.frame = NSRect(
                x: source.minX + (target.minX - source.minX) * eased,
                y: source.minY + (target.minY - source.minY) * eased,
                width: source.width + (target.width - source.width) * eased,
                height: source.height + (target.height - source.height) * eased
            )
            island.layoutSubtreeIfNeeded()
        }
        // A translucent terminal cannot simply overlap another: the underlying
        // text and backgrounds would composite twice. Reveal only uncovered pixels.
        for island in revealed {
            let occupied = CGMutablePath()
            for id in after.keys where before[id] != nil {
                guard let survivor = container.island(for: id), survivor.frame.intersects(island.frame) else { continue }
                let rect = island.convert(survivor.bounds, from: survivor)
                let radius = survivor.layer?.cornerRadius ?? 0
                occupied.addRoundedRect(in: rect, cornerWidth: radius, cornerHeight: radius)
            }
            island.setTransitionMask(CGPath(rect: island.bounds, transform: nil).subtracting(occupied))
        }
        container.updateGapFill()
        CATransaction.commit()
    }

    func finish() { cancel(); apply(progress: 1); revealed.forEach { $0.setTransitionMask(nil) } }
    func cancel() {
        link?.invalidate(); link = nil
        revealed.forEach { $0.setTransitionMask(nil) }
    }
}
