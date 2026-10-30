# Reasoning Engine: 4-Stage Design System Generation

## Overview
The reasoning engine analyzes product requirements and generates complete design systems through 4 interconnected stages.

---

## Stage 1: Multi-Domain Search

### Purpose
Parallel analysis of project requirements across 5 dimensions simultaneously.

### Five Search Domains

1. **Category Search**
   - Input: Product type (SaaS, fintech, healthcare, e-commerce, etc.)
   - Query: Industry vertical + product category
   - Output: Recommended design patterns for that category

2. **Style Search**
   - Input: Visual mood/aesthetic preference
   - Query: Minimalism, Swiss style, brutalism, glassmorphism, etc.
   - Output: 67 UI style options ranked by relevance

3. **Color Search**
   - Input: Brand personality + industry norms
   - Query: Industry + mood + target audience
   - Output: Top 5 color palettes from 161 available options

4. **Pattern Search**
   - Input: Component needs (navigation, cards, forms, etc.)
   - Query: Component type + style + tech stack
   - Output: Recommended layout patterns + component structures

5. **Typography Search**
   - Input: Brand voice + accessibility requirements
   - Query: Industry + personality + readability needs
   - Output: Top 3 font pairings from 57 combinations

### Output
A 5-tuple: (category_pattern, style, color_palette, pattern_set, typography)

---

## Stage 2: Intelligent Matching

### Purpose
Apply domain expertise to filter anti-patterns and validate recommendation coherence.

### 161 Industry Rules

Each of 8 sectors (Tech, Finance, Healthcare, E-commerce, Services, Creative, Lifestyle, Emerging Tech) includes:
- **Recommended Patterns**: What works in this category
- **Style Priorities**: Primary vs. secondary style emphasis
- **Color Moods**: Emotional/psychological alignment
- **Typography Personality**: Voice/character fit
- **Key Effects**: Animations, transitions, micro-interactions
- **Anti-Patterns**: What to avoid (common mistakes)

### BM25 Ranking
- **Input**: Stage 1 recommendations + current project context
- **Process**: Rank matches against 161 rules using BM25 (information retrieval algorithm)
- **Filter**: Remove low-scoring anti-patterns
- **Output**: Validated, industry-coherent design recommendations

---

## Stage 3: Complete Output

### Deliverables

1. **Pattern Recommendations**
   - Landing page layout (hero, features, CTA, footer)
   - Navigation structure (top bar, sidebar, mobile patterns)
   - Card layouts (content, e-commerce, profile)
   - Form patterns (input, validation, error states)
   - Modals, popovers, tooltips

2. **Color System**
   - Primary palette (brand colors)
   - Semantic colors (success, warning, error, info)
   - Neutrals (backgrounds, text, borders)
   - Dark mode variants (if needed)

3. **Typography Scale**
   - Font pairing (headline + body)
   - Size scale (h1–h6, p, caption, code)
   - Line heights + letter spacing
   - Weight hierarchy

4. **Animation Effects**
   - Entrance/exit animations
   - Micro-interactions (hover, focus, loading)
   - Transition timings (standard, slow, fast)
   - Easing functions (ease-in, ease-out, cubic-bezier)

5. **Delivery Checklist**
   - Design tokens (CSS custom properties, Tailwind config)
   - Component library structure
   - Accessibility requirements (WCAG AA)
   - Responsive breakpoints (mobile, tablet, desktop)
   - Asset requirements (icons, illustrations)

---

## Stage 4: Quality Validation

### Accessibility Check (WCAG AA)
- Color contrast ratios (4.5:1 for text)
- Focus indicators (visible, keyboard-navigable)
- Semantic HTML structure
- Alt text requirements
- Aria labels & roles

### Responsive Verification
- Breakpoints: 320px (mobile), 768px (tablet), 1024px (desktop)
- Touch targets (minimum 44×44px)
- Text reflow (no horizontal scroll)
- Image scaling (responsive, lazy-loaded)

### Output
- ✅ Pass/Fail checklist
- ⚠️ Warnings (recommendations for improvement)
- 🔗 Links to WCAG 2.1 guidelines

---

## Example Flow

### Input
```
Project: Fintech dashboard for retail investors
Industry: Finance
Target Stack: React + Tailwind
Tone: Professional but approachable
```

### Stage 1: Multi-Domain Search
```
Category → Finance/Investment
Style → Clean, Trusting, Data-forward
Color → Blues, Greens (trust, growth)
Pattern → Data tables, charts, cards
Typography → Professional serif + clean sans-serif
```

### Stage 2: Intelligent Matching
```
Apply Finance rules:
✓ Recommend: Blue primary (trust), green accents (growth)
✓ Recommend: Data-heavy table layouts, chart components
✗ Filter: Avoid bold, playful styles (breaks trust)
✗ Filter: Avoid serif-only typography (readability at small sizes)
```

### Stage 3: Complete Output
```
Design System:
- Pattern: Card + Table + Chart layout
- Colors: Palette #142 (Fintech professional)
- Typography: Source Sans Pro (headline) + Lato (body)
- Animations: Smooth transitions (400ms), data state changes
- Checklist: WCAG AA, Responsive (320/768/1024), Icons (30), Light/Dark modes
```

### Stage 4: Validation
```
✅ WCAG AA pass
✅ Responsive verified
⚠️ Recommendation: Add skip-to-content link for keyboard users
```

---

## Integration

This reasoning engine powers:
- **Direct Invocation**: `@design-system --project "..." --industry "..."`
- **UI Designer Integration**: `ui-designer` calls for system-level recommendations
- **Design Token Generation**: Output → Tailwind config, CSS custom properties
- **Component Library Scaffolding**: Pattern templates → component boilerplate

---

