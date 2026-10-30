# Motion Design

## Duration: The 100/300/500 Rule

| Duration | Use Case | Examples |
|----------|----------|----------|
| 100-150ms | Instant feedback | Button press, toggle, color change |
| 200-300ms | State changes | Menu open, tooltip, hover states |
| 300-500ms | Layout changes | Accordion, modal, drawer |
| 500-800ms | Entrance animations | Page load, hero reveals |

Exit animations: ~75% of enter duration.

## Easing

Don't use `ease`. Use specific curves:

| Curve | Use For | CSS |
|-------|---------|-----|
| ease-out | Elements entering | `cubic-bezier(0.16, 1, 0.3, 1)` |
| ease-in | Elements leaving | `cubic-bezier(0.7, 0, 0.84, 0)` |
| ease-in-out | State toggles | `cubic-bezier(0.65, 0, 0.35, 1)` |

Exponential curves for micro-interactions:
```css
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
```

**Avoid bounce and elastic curves** — they feel dated and amateurish.

## Only Animate transform and opacity

Everything else causes layout recalculation. For height animations, use `grid-template-rows: 0fr → 1fr`.

## Staggered Animations

```css
animation-delay: calc(var(--i, 0) * 50ms);
```
Cap total stagger time. 10 items × 50ms = 500ms max.

## Reduced Motion (NOT optional)

```css
@media (prefers-reduced-motion: reduce) {
  .card { animation: fade-in 200ms ease-out; }
}
```

Preserve functional animations (progress bars, spinners) — just remove spatial movement.

## Perceived Performance

- 80ms threshold: anything under feels instant
- Optimistic UI: update immediately, sync later
- Ease-in toward task completion compresses perceived time
- Brief delays for complex operations signal "real work"
