# Typography

## Classic Typography Principles

### Vertical Rhythm

Your line-height should be the base unit for ALL vertical spacing. If body text has `line-height: 1.5` on `16px` type (= 24px), spacing values should be multiples of 24px.

### Modular Scale & Hierarchy

Use fewer sizes with more contrast. A 5-size system covers most needs:

| Role | Typical Ratio | Use Case |
|------|---------------|----------|
| xs | 0.75rem | Captions, legal |
| sm | 0.875rem | Secondary UI, metadata |
| base | 1rem | Body text |
| lg | 1.25-1.5rem | Subheadings, lead text |
| xl+ | 2-4rem | Headlines, hero text |

Popular ratios: 1.25 (major third), 1.333 (perfect fourth), 1.5 (perfect fifth).

### Readability & Measure

Use `ch` units for character-based measure (`max-width: 65ch`). Line-height scales inversely with line length. Increase line-height for light text on dark backgrounds (+0.05-0.1).

## Font Selection & Pairing

### Choosing Distinctive Fonts

Avoid the invisible defaults: Inter, Roboto, Open Sans, Lato, Montserrat.

**Selection process:**
1. Write down 3 concrete words for the brand voice (not "modern" or "elegant")
2. Imagine the font as a physical object the brand could ship
3. Browse font catalogs with that physical object in mind — reject the first "designy" thing
4. Avoid defaults from previous projects

**Fonts to always reject (training-data defaults):**
Fraunces, Newsreader, Lora, Crimson (all variants), Playfair Display, Cormorant, Syne, IBM Plex (all), Space Mono/Grotesk, Inter, DM Sans/Serif, Outfit, Plus Jakarta Sans, Instrument Sans/Serif

**Font sources:** Google Fonts, Pangram Pangram, Future Fonts, Adobe Fonts, ABC Dinamo, Klim Type Foundry, Velvetyne.

### Pairing Principles

You often don't need a second font. One well-chosen family in multiple weights creates cleaner hierarchy. When pairing, contrast on multiple axes: Serif + Sans, Geometric + Humanist, Condensed + Wide. Never pair fonts that are similar but not identical.

### Web Font Loading

```css
@font-face {
  font-family: 'CustomFont';
  src: url('font.woff2') format('woff2');
  font-display: swap;
}

/* Match fallback metrics to minimize shift */
@font-face {
  font-family: 'CustomFont-Fallback';
  src: local('Arial');
  size-adjust: 105%;
  ascent-override: 90%;
  descent-override: 20%;
  line-gap-override: 10%;
}

body {
  font-family: 'CustomFont', 'CustomFont-Fallback', sans-serif;
}
```

## Modern Web Typography

### Fluid Type

Use `clamp(min, preferred, max)` for headings on marketing/content pages. Use fixed `rem` scales for app UIs and dashboards.

### OpenType Features

```css
.data-table { font-variant-numeric: tabular-nums; }
.recipe-amount { font-variant-numeric: diagonal-fractions; }
abbr { font-variant-caps: all-small-caps; }
code { font-variant-ligatures: none; }
body { font-kerning: normal; }
```

## Accessibility

- Never disable zoom (`user-scalable=no`)
- Use rem/em for font sizes, never px for body text
- Minimum 16px body text
- Text links need 44px+ tap targets
