# Responsive Design

## Mobile-First

Start with base styles for mobile, use `min-width` queries to layer complexity.

## Breakpoints: Content-Driven

Let content tell you where to break. Three breakpoints usually suffice (640, 768, 1024px). Use `clamp()` for fluid values without breakpoints.

## Detect Input Method, Not Just Screen Size

```css
@media (pointer: fine) { .button { padding: 8px 16px; } }
@media (pointer: coarse) { .button { padding: 12px 20px; } }
@media (hover: hover) { .card:hover { transform: translateY(-2px); } }
@media (hover: none) { .card { /* No hover - use active */ } }
```

Don't rely on hover for functionality.

## Safe Areas

```css
body {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}
```

Enable: `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">`

## Responsive Images

```html
<img src="hero-800.jpg"
  srcset="hero-400.jpg 400w, hero-800.jpg 800w, hero-1200.jpg 1200w"
  sizes="(max-width: 768px) 100vw, 50vw"
  alt="Hero image">
```

Use `<picture>` for art direction (different crops).

## Layout Adaptation

- Navigation: hamburger on mobile → horizontal on tablet → full on desktop
- Tables: transform to cards on mobile
- Progressive disclosure: `<details>/<summary>` for collapsible content

## Testing

Don't trust DevTools alone. Test on real iPhone, real Android, tablet if relevant. Cheap Android phones reveal performance issues simulators miss.
