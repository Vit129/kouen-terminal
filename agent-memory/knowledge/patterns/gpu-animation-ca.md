# GPU Animation Pattern — Layout Once, GPU Paints

## Principle

Zed (GPUI / Rust), Otty (Metal), WezTerm, cmux all converge on the same model:

> **Layout runs once when state changes. Paint runs entirely on the GPU/render server.**

SwiftUI's `.animation(.spring, value:)` on `.frame()` violates this:
`AnimatableFrameAttribute.updateValue()` fires 60–120× per second on the **main thread**
for the duration of every animation. Under rapid state updates, the spring never converges
→ CPU stays pegged indefinitely.

## CA Mask Pattern (Harness Notch)

Replace SwiftUI frame animation with `CAShapeLayer` mask + `CABasicAnimation` path morph.

```swift
// NotchMaskAnimator.swift
final class NotchMaskAnimator {
    private let mask = CAShapeLayer()

    func install(on hostingView: NSView) {
        hostingView.wantsLayer = true
        hostingView.layer?.mask = mask
    }

    func update(to rect: CGRect, topRadius: CGFloat, bottomRadius: CGFloat,
                isOpening: Bool, reduceMotion: Bool, animated: Bool) {
        guard rect != lastRect else { return }  // idempotent
        let target = NotchShape.cgPath(in: rect, ...)
        let from = mask.presentation()?.path ?? mask.path   // interrupt-safe
        mask.path = target
        guard animated, let from else { return }

        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = from
        anim.toValue = target
        anim.duration = isOpening ? 0.40 : 0.32
        anim.timingFunction = isOpening
            ? CAMediaTimingFunction(controlPoints: 0.22, 0.97, 0.09, 1.0)
            : CAMediaTimingFunction(name: .easeInEaseOut)
        mask.add(anim, forKey: "notch-shape")
    }
}
```

**Key points:**
- `CABasicAnimation` on `CAShapeLayer.path` requires the same path structure (element count)
  for morphing. `NotchShape.cgPath` always emits 9 elements (move, 2 lines, quadCurve,
  line, quadCurve, line, quadCurve, close) — morph works across all states.
- `mask.presentation()?.path` captures the in-flight visual position for seamless interrupts.
- `CASpringAnimation` on "path" is NOT officially supported (scalar-only spring) — use
  `CABasicAnimation` with a spring-approximating bezier timing function instead.

## Shadow via System Window Shadow

With `hasShadow = true` on a transparent `NSPanel`, WindowServer casts shadow from opaque pixels.
CA mask zeroes alpha outside the notch shape → shadow follows the animated mask outline
automatically. No shadow sublayer needed.

```swift
// NotchPanel.swift
hasShadow = true  // system shadow follows mask alpha
```

## Burst Coalescing (cmux NotificationBurstCoalescer)

Rapid notification storms → one callback per runloop turn:

```swift
final class SnapshotCoalescer {
    func signal(_ action: @escaping @MainActor () -> Void) {
        self.action = action
        guard !pending else { return }
        pending = true
        DispatchQueue.main.async { [weak self] in self?.flush() }
    }
}
```

## Equality Guard (Zed layout phase)

Prevent `@Published` fires when the value is unchanged:

```swift
func updateGeometry(_ geometry: NotchLayoutMetrics) {
    guard geometry != self.geometry else { return }
    self.geometry = geometry
}
```

## Combine → CA Bridge

`@Published` vars are the source of truth; Combine drives the CA update:

```swift
maskObserver = Publishers.CombineLatest(model.$presentation, model.$openContentHeight)
    .receive(on: RunLoop.main)
    .dropFirst()
    .sink { [weak self] _, _ in self?.updateNotchMask(animated: true) }
```

SwiftUI content transitions (opacity, offset) still animate via `withAnimation` in the
ViewModel — layout is instant, transitions are lightweight CA-backed and cheap.

## Layer Coordinate System

`NSHostingView.isFlipped = true` → its backing layer also has `geometryFlipped = true`
(AppKit sets this automatically). Layer y = 0 is at the **top** of the view.

Notch mask rect: `CGRect(x: (panelW - notchW) / 2, y: 0, width: notchW, height: notchH)`

## When to Use This Pattern

- Any overlay/HUD panel driven by frequent data updates (snapshot cadence > 1/s)
- Any SwiftUI `.animation()` on `.frame()` that is observed to peg CPU via `sample`
- Panels where shape (not just opacity/transform) needs to animate

## References

- cmux `NotificationBurstCoalescer.swift`, `PanelTitleUpdateCoalescingSettings.swift`
- Zed GPUI: layout() / paint() phase separation
- Otty: Metal GPU rendering, no NSHostingView
- WezTerm issue #7230: async-io thread 100+ events/s when idle (same bug class)
