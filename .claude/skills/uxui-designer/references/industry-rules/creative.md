# Creative Industry Rules (20 Rules)

## Overview
Creative products split into two modes: showcase surfaces that sell taste and talent (agency sites, portfolios, photography studios, music/gaming platforms) and creation tools where the interface must disappear behind the content being made (photo/video editors, drawing canvases, music production, AI/meme generators). Both modes reject the "professional SaaS" default — corporate minimalism is a named anti-pattern here, not a safe fallback.

---

## Recommended Patterns (5 Rules)

### 1. Portfolio/Case-Study Storytelling Layout
- **Pattern**: Full-bleed hero → project/case-study grid → deep-dive case study with process + outcome → contact
- **Rationale**: Creative agencies and personal portfolios are sold on differentiation and "wow-factor" — a template-feeling layout is the named anti-pattern, so structure should showcase range rather than compress it
- **Requirement**: Case studies are a `must_have` decision rule for creative agencies specifically

### 2. Full-Bleed Gallery with Before/After
- **Pattern**: Full-bleed image galleries, minimal chrome, optional before/after slider for retouching-style work
- **Best For**: Photography studios, portfolio sites
- **Rationale**: "Content is king" — heavy UI chrome competing with the imagery is an explicit anti-pattern

### 3. Immersive Media Player
- **Pattern**: Persistent audio/video player, waveform or 3D visualization, playlist/library management, personalization
- **Best For**: Music streaming, gaming platforms
- **Rationale**: Immersion and performance are named priorities — gaming in particular treats static assets and minimalist chrome as anti-patterns, the opposite of the productivity-tool default

### 4. Creative Tool Canvas with Minimal Chrome
- **Pattern**: Dark editor background, tool panel docked to an edge, large canvas/preview area, non-destructive editing history
- **Best For**: Photo editors, drawing/sketch canvases, music/beat-making DAWs, short-video editors
- **Key Considerations**: Layer management, undo history, filter/effect preview strips, multi-track timelines — the UI's job is to get out of the way of the work
- **Mobile**: Drawing/sketch canvases specifically require pressure-sensitivity and stylus support, not just touch — treat finger-only input as a degraded mode, not the primary target

### 5. Generation & Output Showcase
- **Pattern**: Style/template selection → generation → multiple output variations → fast export/share
- **Best For**: AI photo/avatar generators, generative art platforms, meme/sticker makers
- **Requirement**: Fast turnaround and creator attribution are named `must_have`s — these tools are judged on speed-to-shareable-output

---

## Style Priorities (5 Rules)

### 6. Bold & Expressive Over Corporate Minimalism
- **Priority**: Creative agency and portfolio surfaces should read as a personal statement, not a SaaS template
- **Anti-Pattern Named Explicitly**: "Corporate minimalism" and "hidden portfolio" are flagged as HIGH-severity mistakes for creative agencies — the instinct to play it safe is the wrong instinct in this category
- **Accessibility**: Brutalism (the underlying style for agency work) actually carries a WCAG AAA rating in the source style data — bold and accessible aren't in tension here, but it is explicitly rated wrong for conservative/corporate/critical-accessibility contexts, so don't reuse it outside creative

### 7. Dark Editor Chrome for Creation Tools
- **Priority**: Photo/video editors, drawing canvases, and beat-makers default to dark, OLED-friendly backgrounds so color/content previews read accurately and don't compete with the UI
- **Rule**: A light-mode toggle should exist for accessibility, but dark is the default — "pure white backgrounds" is a named anti-pattern across this whole cluster
- **Accessibility**: `if_light_mode_needed: provide-theme-toggle` is a named decision rule across every editor/canvas row — dark-only with no toggle is a real accessibility gap for users who need high brightness or have light sensitivity to dark UI

### 8. Immersive, Performance-Critical Rendering
- **Priority**: Gaming platforms treat rendering fidelity (WebGL/3D) and frame performance as core to the product, not a progressive enhancement
- **Anti-Pattern**: Minimalist, static-asset design is explicitly wrong here — it reads as broken or low-effort, unlike in productivity software where the same restraint reads as polish

### 9. Monochrome & Minimal for Personal Portfolio/Photography
- **Priority**: Photography studios and personal portfolios lean toward black/white/near-monochrome palettes so the work itself carries the color
- **Contrast**: This is the opposite instinct from creative agencies' "bold primaries" — agencies sell energy, photographers and solo portfolios sell craft and restraint
- **Mobile**: For photography studios with a booking flow, `if_booking: add-calendar-system` is a named decision rule — don't let the monochrome gallery aesthetic crowd out a functional, easy-to-tap booking calendar

### 10. Vibrant High-Energy for Viral/Social Creative Tools
- **Priority**: Meme and sticker makers use bold, high-saturation color specifically because "muted colors + low energy" is a named anti-pattern — the product's job is to produce shareable, attention-grabbing output, and a muted UI undersells that promise

---

## Color Moods (3 Rules)

### 11. Bold Primaries & Artistic Freedom
- **Primary**: #EC4899 (agency pink), #7C3AED (gaming/generative-art purple)
- **Accent**: #0891B2 cyan, #F43F5E rose
- **Use Cases**: Creative agency hero sections, gaming UI accents, generative-art minting flows

### 12. Dark Studio + Neon Accents
- **Primary**: Near-black backgrounds (#0F172A, #0F0F23, #1C1917) across music streaming, photo/video editors, drawing canvases, and beat-makers
- **Accent**: Vibrant single-hue pop — violet #7C3AED for editors, green #22C55E for "play"/waveform states, pink #EC4899 for video editing
- **Rationale**: One saturated accent on a dark field reads as a professional studio tool, not a toy — multiple competing brights would undercut that

### 13. AI Purple + Aurora Gradients
- **Primary**: #7C3AED / #6366F1 AI-purple family
- **Accent**: Pink #EC4899, flowing gradient (8–12s) rather than a static fill
- **Use Cases**: AI photo/avatar generation flows specifically — the slow gradient motion signals "processing/generating" without needing a literal spinner

---

## Typography Personality (3 Rules)

### 14. Bold Expressive Display Type
- **Pairing**: Bebas Neue (heading) + Source Sans 3 (body) for agency/portfolio impact; Syne + Manrope for fashion-forward creative work
- **Rationale**: Display weight and unconventional proportions do the differentiation work that a safe, corporate sans cannot

### 15. Minimal/Elegant for Portfolio & Photography
- **Pairing**: Archivo (heading) + Space Grotesk (body) — the "Minimalist Portfolio" pairing; Outfit + Work Sans as a geometric-modern alternative
- **Rationale**: Restrained, geometric type keeps focus on the imagery rather than competing with it

### 16. Gaming & Music Impact Type
- **Pairing**: Russo One (heading) + Chakra Petch (body) for gaming; Righteous + Poppins for music/entertainment
- **Rationale**: Condensed, high-impact display faces match the energetic, performance-oriented tone these categories are judged on

---

## Key Effects (2 Rules)

### 17. Parallax & Scroll-Triggered Reveals
- **Pattern**: 3–5 layer parallax and scroll-triggered content reveals on portfolio and personal-brand pages
- **Rationale**: Named directly in the source reasoning for portfolio/personal sites — but the same data notes to reduce motion for a minimal-style portfolio, so treat this as a dial, not a default-on

### 18. Waveform, Timeline & Minting Animations
- **Pattern**: Live waveform visualization (music streaming, beat-makers), multi-track timeline scrubbing (video editors), and minting/generation-in-progress animations (generative art, AI generators)
- **Rationale**: These are the moments users are actively watching the tool "work" — the animation communicates system status, not just decoration

---

## Anti-Patterns (2 Rules)

### 19. What to Avoid in Creative

❌ **Corporate Minimalism on Showcase Surfaces**
- **Why**: Named explicitly for creative agencies — a portfolio that looks like a SaaS landing page fails to differentiate, which is the entire point of the purchase decision
- **Instead**: Bold, expressive, storytelling-driven layouts with real case studies front and center

❌ **Heavy Chrome or Slow Loading on Creation/Generation Tools**
- **Why**: Generative art and AI generation platforms name "heavy chrome" and "slow loading" as HIGH-severity anti-patterns — friction between intent and output kills the core value proposition
- **Instead**: Fast, minimal-chrome flows with instant preview and quick export

### 20. Static Assets or Inconsistent Styling
- **Example**: A gaming UI using static images where motion is expected, or an AI-generated-content platform whose output styling is inconsistent from one generation to the next
- **Why**: Both are named anti-patterns — gaming is judged on immersion, AI-generation tools are judged on the reliability/consistency of their aesthetic output
- **Instead**: Commit to WebGL/motion where the category expects it; constrain generation style enough to stay visually consistent

---

*Rules Count: 20*
