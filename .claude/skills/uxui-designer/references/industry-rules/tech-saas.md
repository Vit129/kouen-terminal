# Tech & SaaS Industry Rules (20 Rules)

## Overview
Tech & SaaS products prioritize clarity, efficiency, and data visualization. Users expect fast interactions, predictable patterns, and accessibility.

---

## Recommended Patterns (5 Rules)

### 1. Dashboard-First Layout
- **Pattern**: KPI cards → charts (line, bar, pie) → data tables with sorting/filtering
- **Rationale**: Users need immediate insight into key metrics
- **Best For**: Analytics, project management, monitoring tools
- **Accessibility**: Tables must have proper `<thead>`, semantic markup

### 2. Sidebar Navigation (Primary)
- **Pattern**: Persistent left sidebar, collapsible on mobile
- **Rationale**: SaaS products have 5–20+ features; horizontal nav insufficient
- **Current Item**: Highlight with left border, background color

### 3. Modal Dialogs for Settings & Config
- **Pattern**: Modal for non-critical changes; don't use modals for confirming destructive actions (use a page instead)
- **Accessibility**: Role="dialog", aria-labelledby, aria-describedby; trap focus, provide escape hatch

### 4. Tabbed Interfaces for Related Content
- **Pattern**: Horizontal tabs for feature variations (All, Assigned, Archived, etc.)
- **Rationale**: Reduces cognitive load, keeps users in same view
- **Mobile**: Scroll horizontally or collapse to dropdown

### 5. Breadcrumb Navigation
- **Pattern**: Root > Parent > Current (always clickable); current page not clickable
- **Rationale**: Users need orientation in deep hierarchies
- **Example**: `Dashboard / Reports / Q4 Analytics`

---

## Style Priorities (5 Rules)

### 6. Minimalism & Clarity
- **Priority**: Remove visual noise; emphasize content
- **Colors**: 2–3 colors max; neutral backgrounds

### 7. Professional & Trustworthy
- **Priority**: Convey competence, reliability, security
- **Colors**: Blues, teals, grays (avoid playful pastels)
- **No Gradients**: Use flat colors for clarity

### 8. Flat Design (No Skeuomorphism)
- **Priority**: Digital-native, not mimicking physical objects
- **Icons**: Clean line icons (24px–32px), not filled blobs

### 9. Dark Mode Support
- **Priority**: Essential for developer tools, monitoring platforms
- **Contrast**: Ensure 4.5:1 on both light & dark
- **Inversion**: Not simple light↔dark swap; adjust hue, saturation
- **Background**: Dark gray (#1a1a1a–#2a2a2a), not pure black

### 10. Dense Information Display
- **Priority**: Power users prefer density; casual users prefer spacious UI
- **Padding**: Compact spacing (8px, not 16px) in tables & lists
- **Font Size**: 12–13px for body, 14px for inputs

---

## Color Moods (3 Rules)

### 11. Trust & Stability (Blues)
- **Primary**: #2563eb, #0ea5e9, #0284c7
- **Use Cases**: Primary CTA, headers, trusted sections
- **Avoid**: Bright, vibrant blues (feels less professional)

### 12. Growth & Success (Greens)
- **Accent**: #10b981, #16a34a, #059669
- **Example**: "Revenue Up 12%" in green

### 13. Caution & Urgency (Reds/Oranges)
- **Alert**: #ef4444, #f97316, #dc2626
- **Contrast**: Must meet 4.5:1 on white background

---

## Typography Personality (4 Rules)

### 14. Sans-Serif + Monospace Combination
- **Headline/Body**: Inter, Source Sans Pro, or Roboto (clean, modern)
- **Code**: JetBrains Mono, Fira Code, or Monaco (monospace)
- **Rationale**: Matches tech aesthetic; monospace signals "code"

### 15. Clear Hierarchy
- **h1**: 28–32px, bold (700); **h2**: 20–24px, bold (700); **h3**: 16–18px, bold (600)
- **Body**: 14–16px, regular (400), max 75 characters per line

### 16. Readability Over Personality
- **Priority**: Speed of comprehension > Brand expression
- **Contrast**: 4.5:1 minimum (WCAG AA)
- **No Decorative Fonts**: Avoid handwriting, display fonts in body

### 17. Consistent Font Weights
- **Regular (400)**: Body, navigation, default state
- **Medium (500)**: Labels, buttons
- **Bold (700)**: Headers, highlights

---

## Key Effects (2 Rules)

### 18. Smooth Transitions on Interaction
- **Duration**: 150–200ms for quick feedback (hover, focus)
- **Focus**: Outline (3px solid, 4:1 contrast), no outline removal

### 19. Loading States & Skeletons
- **Skeleton Screens**: Match exact layout/height/width of content
- **Duration**: Skeleton shows 200–500ms minimum (avoids flash)

---

## Anti-Patterns (2 Rules)

### 20. What to Avoid in Tech & SaaS

❌ **Excessive Animations**: Auto-play videos, scroll triggers, parallax
- **Instead**: Static content, animation on user interaction

❌ **Playful, Casual Tone**
- **Example**: Don't use playful illustrations or puns in error messages
- **Instead**: Direct, helpful language ("Check your connection" not "Oops!")

❌ **Auto-Save Without Indication**
- **Instead**: Show save status ("Saving..." → "✓ Saved")

❌ **Truncated Data Without Tooltip**
- **Instead**: Title attribute or hover popover

❌ **Poor Keyboard Navigation**
- **Why**: Power users expect keyboard shortcuts (Cmd+K for search, J/K for navigation)

---

*Rules Count: 20*
