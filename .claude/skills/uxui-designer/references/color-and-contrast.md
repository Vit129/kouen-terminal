# Color & Contrast

## Color Spaces: Use OKLCH

Stop using HSL. Use OKLCH — it's perceptually uniform. `oklch(lightness chroma hue)` where lightness is 0-100%, chroma ~0-0.4, hue 0-360. Reduce chroma as you approach white or black.

## Building Functional Palettes

### Tinted Neutrals

Pure gray is dead. Add chroma 0.005-0.015 to all neutrals, hued toward your brand color. The hue comes from THIS project's brand, not a formula.

### Palette Structure

| Role | Purpose | Example |
|------|---------|---------|
| **Primary** | Brand, CTAs, key actions | 1 color, 3-5 shades |
| **Neutral** | Text, backgrounds, borders | 9-11 shade scale |
| **Semantic** | Success, error, warning, info | 4 colors, 2-3 shades each |
| **Surface** | Cards, modals, overlays | 2-3 elevation levels |

### The 60-30-10 Rule

About visual weight, not pixel count:
- 60%: Neutral backgrounds, white space
- 30%: Secondary — text, borders, inactive states
- 10%: Accent — CTAs, highlights, focus states

## Contrast & Accessibility

| Content Type | AA Minimum | AAA Target |
|--------------|------------|------------|
| Body text | 4.5:1 | 7:1 |
| Large text (18px+) | 3:1 | 4.5:1 |
| UI components, icons | 3:1 | 4.5:1 |

### Dangerous Combinations
- Light gray text on white (#1 fail)
- Gray text on colored backgrounds — use darker shade of background instead
- Red on green (8% of men can't distinguish)
- Blue on red (vibrates visually)

## Dark Mode

Dark mode is NOT inverted light mode:

| Light Mode | Dark Mode |
|------------|-----------|
| Shadows for depth | Lighter surfaces for depth |
| Dark text on light | Light text on dark (reduce weight) |
| Vibrant accents | Desaturate slightly |
| White backgrounds | Never pure black — use dark gray (oklch 12-18%) |

### Token Hierarchy

Two layers: primitive tokens (`--blue-500`) and semantic tokens (`--color-primary: var(--blue-500)`). For dark mode, only redefine semantic layer.

## Alpha Is A Design Smell

Heavy transparency usually means incomplete palette. Define explicit overlay colors instead.
