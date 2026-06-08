# AppKit + Metal Patterns

## Metal Surface Lifecycle (CASE-003)

Terminal uses Metal/CADisplayLink for rendering. When a pane tree is rebuilt (removeFromSuperview + re-add in same window), the Metal surface goes black.

**Fix:** Override `viewDidMoveToSuperview()` in `HarnessTerminalSurfaceView`: if `window != nil`, stop+start display link + scheduleRender.

**Why:** Metal's CADisplayLink doesn't survive a superview detach/reattach cycle. The display link loses its target and stops firing. Explicitly restarting it on reattach restores rendering.

## Overlay Above Metal (CASE-004)

Metal CALayer composites above all sibling layers regardless of `zPosition`. Standard `addSubview(positioned:above:)` doesn't work.

**Workaround:** Use `HitTestPassthroughView` with `layer?.zPosition = 1000`. Works for small overlays (split buttons, pills) but a full-frame overlay blocks Metal render.

**Pattern:** Keep overlays as small hit-test-passthrough views with high zPosition. Never cover the full Metal surface.

## NSFont Italic (CASE-010)

NSFont has no `.italicSystemFont` (unlike UIFont).

**Fix:** `NSFontManager.shared.convert(.systemFont(ofSize:), toHaveTrait: .italicFontMask)`
