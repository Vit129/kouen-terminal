# Spatial Design

## Spacing Systems

Use 4pt base, not 8pt. Scale: 4, 8, 12, 16, 24, 32, 48, 64, 96px. Name tokens semantically (`--space-sm`, `--space-lg`), not by value. Use `gap` instead of margins for sibling spacing.

## Grid Systems

### The Self-Adjusting Grid

`repeat(auto-fit, minmax(280px, 1fr))` for responsive grids without breakpoints. For complex layouts, use named grid areas and redefine at breakpoints.

## Visual Hierarchy

### The Squint Test

Blur your eyes. Can you identify: the most important element, the second most important, clear groupings? If everything looks the same weight, you have a hierarchy problem.

### Hierarchy Through Multiple Dimensions

| Tool | Strong | Weak |
|------|--------|------|
| Size | 3:1+ ratio | <2:1 ratio |
| Weight | Bold vs Regular | Medium vs Regular |
| Color | High contrast | Similar tones |
| Position | Top/left (primary) | Bottom/right |
| Space | Surrounded by whitespace | Crowded |

Best hierarchy uses 2-3 dimensions at once.

### Cards Are Not Required

Use cards only when content is truly distinct and actionable, items need visual comparison, or content needs clear interaction boundaries. Never nest cards inside cards.

## Container Queries

```css
.card-container { container-type: inline-size; }

@container (min-width: 400px) {
  .card { grid-template-columns: 120px 1fr; }
}
```

## Optical Adjustments

- Text at `margin-left: 0` looks indented — use negative margin (-0.05em) to optically align
- Play icons need to shift right, arrows shift toward their direction
- Touch targets: 44px minimum, use padding or pseudo-elements to expand

## Depth & Elevation

Semantic z-index scale: dropdown(100) → sticky(200) → modal-backdrop(300) → modal(400) → toast(500) → tooltip(600). Shadows should be subtle.
