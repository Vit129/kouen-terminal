---
name: uxui-designer
description: >
  Use when: design UI, ออกแบบ UI, UX/UI, create design system, make it look better, polish UI,
  audit design, redesign a page, study a design reference/screenshot/URL, improve colors,
  fix typography, add animations, avoid generic design, recommend colors for industry,
  industry rules, compliance design rules, healthcare design, finance design, ecommerce rules,
  build landing page, define design tokens.
  Covers design decisions (what to build) AND implementation quality (how it looks/feels).
  Industry-validated patterns (8 sectors in references/industry-rules/) + pbakaus/impeccable anti-slop principles.
credit: See "Credits" section below for the full source list.
version: 2.4.0
---

# UX/UI Designer

Design and implement distinctive, production-grade interfaces — from aesthetic direction to pixel-perfect code that doesn't look like "AI slop."

## Credits

| Source | License | Contributes | Status |
| ------ | ------- | ------------ | ------ |
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | — | Original anti-slop principles this skill was first built around | inspiration |
| [saifyxpro/ui-ux-design-pro-skill](https://github.com/saifyxpro/ui-ux-design-pro-skill) | — | Early UI-UX Pro structure this skill's design-patterns approach was modeled on | inspiration |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | MIT | Live design search engine — `scripts/{core,design_system,search,validate_data}.py` + `data/*.csv` (styles, colors, typography, industry reasoning, tech stacks). | synced |
| [Nutlope/hallmark](https://github.com/Nutlope/hallmark) | MIT | Diversification memory (`references/diversification-memory.md`) + Audit/Redesign/Study modes (`references/{audit,redesign,study}-verb.md`) | ported |
| [Nutlope/inspo](https://github.com/Nutlope/inspo) | MIT | Live production inspiration MCP server — 832 sites, 2,320 screens (desktop/mobile), DOM-extracted tokens (`DESIGN.md`), 68 reference JSX components | integrated |

## Core Capabilities

| Capability | Count | Use Case |
| ---------- | ----- | -------- |
| **Industry Rules** | 161 | Domain-specific patterns across 8 sectors (`references/industry-rules/`) |
| **UI Styles** | 84 | Visual approaches (minimalism, brutalism, etc.) |
| **Color Palettes** | 192 | Psychology-backed, industry-aligned colors |
| **Font Pairings** | 74 | Google Fonts, accessibility-tested combinations |
| **Chart Types** | 25 | Data visualization for dashboards & analytics |
| **UX Guidelines** | 98 | Detailed interactive patterns |
| **Anti-Patterns** | 24+ | Explicit bans to avoid generic AI aesthetics |
| **Slash Commands** | 17 | Targeted design operations (audit, polish, critique, etc.) |

All counts above are live, searchable via `scripts/search.py` (BM25-ranked over `data/*.csv`) — not a static snapshot. See "Run the Design Search Engine" below.

## Modes

| Mode | Trigger | Output |
| ---- | ------- | ------ |
| **Design** | "ออกแบบ", "design system", "pick colors", "industry rules" | Design spec, tokens, system rules (see `references/industry-rules/`) |
| **Implement** | "polish", "make it look better", "build this UI" | Working code with high aesthetic quality |
| **Audit** | "audit", "score this design", "check for anti-patterns", "quality check" — **read-only** | Ranked punch list, grouped by severity — zero edits. See `references/audit-verb.md`. |
| **Redesign** | "redesign this", "this looks templated/generic", "same content, different structure" | Restructured code — same copy/IA, different structural fingerprint. See `references/redesign-verb.md`. |
| **Study** | "study this design", "extract the DNA from [screenshot/URL]", "what makes this design work", a pasted URL/screenshot of an admired design with no build request yet | Diagnosis report; optional portable system on explicit request. See `references/study-verb.md`. |

All modes share the same principles and anti-patterns. `audit` and `study` never edit or write code on their own — they hand off to `Implement`/`Redesign` only after the user confirms.

## Workflow

### Design Mode (spec → tokens → components)

1. **Phase 0** — Detect existing design system
2. **Identify Industry** — SaaS, Finance, Healthcare, E-commerce, Services, Creative, Lifestyle, Emerging Tech
3. **Run Design Search & Inspiration** — Pull real-world production references:
   - **Primary (Inspo MCP)**: If Inspo MCP is available, call `recommend(brief)` or `search_screens(query)` to ground decisions in real production sites with DOM-extracted palettes, typography, spacing scales, and JSX reference components (see "Inspo MCP Integration" below).
   - **Fallback / Local (BM25 Engine)**: `python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<product type + industry + keywords>" --design-system -p "<Project Name>"` (see "Run the Design Search Engine" below).
4. **Context Gathering** — Audience, use cases, brand personality/tone
5. **Aesthetic Direction** — Commit to BOLD tone + differentiation
6. **Run Reasoning Engine** — 4-stage analysis (search → match → generate → validate)
7. **Apply Industry Rules** — Match product type → style → color mood → anti-patterns, using the Step 3 design-search results as the source of truth (supplement with `--domain` searches as needed)
8. **Diversification Check (MANDATORY)** — Read `.ui-designer/log.json` in the target project (if present). The pattern + style pick must differ from the log's last entry on at least one axis (pattern / style / accent hue band) — state the rotation in plain text before locking it in. Skip this check only if a locked `DESIGN.md`/`design-system/<project>/MASTER.md` governs the project (consistency wins there instead — see `references/redesign-verb.md` § Diversification rule — inverted for multi-page). Full protocol: `references/diversification-memory.md`.
9. **Tokens** — Define colors, spacing, typography as CSS variables. Stamp the output's CSS with `/* uxui-designer · pattern: <name> · style: <name> · accent: <band> */` per `references/diversification-memory.md`.
10. **Validate** — AI Slop Test + WCAG AA + responsive + dark mode. Append this build to `.ui-designer/log.json` (create the file if absent) so future runs on this project can diversify against it.

### Implement Mode (structure → polish)

1. Structure first (HTML/semantic, no styling)
2. Layout and spacing
3. Typography and color
4. Interactive states (hover, focus, active, disabled)
5. Edge case states (empty, loading, error)
6. Motion (purposeful transitions)
7. Responsive adaptation
8. **AI Slop Test** — would someone immediately say "AI made this"? If yes, redo.

## Phase 0: Existing Design System Detection (MANDATORY)

Before designing, check if a design system already exists:

| Found | Action |
| ----- | ------ |
| `DESIGN.md` exists at project root (see `rules/product-design.md`) | Read it first — it's the canonical design language. Align to it, don't regenerate tokens or drift from it. |
| Figma URL exists | Analyze → extract tokens, components → extend, don't rebuild |
| Design tokens file exists (CSS vars, Tailwind config) | Import existing → align, don't override |
| Component library exists (MUI, Ant Design, shadcn/ui) | Document existing → extend with custom tokens |
| Nothing exists | Build new following industry rules + reasoning engine |

**Always ask:** "Do you have an existing design system or Figma file?"

## Inspo MCP Integration (Live Design Inspiration)

When Inspo MCP is configured (`https://inspomcp.dev/api/mcp`), prioritize using its live tools for visual grounding and reference:

| Tool | When to Call | What it Returns |
| ---- | ------------ | --------------- |
| `recommend(brief)` | **Step 3 of Design Mode (Start here)** | Macrostructure pick, 5 real production exemplars, reference components, suggested palette, and baked-in `heroGuidance` + `spacingGuidance`. |
| `search_screens(query, ...)` | Specific industry, style, or vibe search | Desktop + mobile capture pairs, extracted palettes, fonts, tech stack across 832 sites. |
| `get_design_system(slug)` | In **Study Mode** or when adopting an exemplar's tokens | Full DOM-extracted `DESIGN.md` (colors, CSS variables, type scale, container widths). |
| `find_examples_for_macrostructure(name)` | When exploring layout structures (e.g. `Bento Grid`, `Specimen`) | Canonical production examples of that exact layout pattern. |
| `find_by_color(hex)` | When matching a brand color to real production usage | Production sites using that color band (OKLAB distance). |
| `get_reference_jsx(type, id)` | In **Implement Mode** for clean component starting points | Copy-pasteable, production-tested JSX for heroes, pricing tables, navbars, footers. |

*Baked-in Inspo Guidance to always enforce:*
- **Hero**: Compose the hero section to fit the initial viewport (~1280×800 / `100svh`) without cutting off below the fold.
- **Spacing**: Keep generous vertical rhythm (80–160px between sections on desktop) and keep copy inside a centered, padded column.

## Run the Design Search Engine (Local Fallback)

`scripts/search.py` is a standalone BM25 search engine over `data/*.csv` (styles, colors, typography, products, ux-guidelines, charts, icons, motion, react-performance, and 22 stack files under `data/stacks/`) plus `ui-reasoning.csv` for `--design-system` mode. Use as offline/local fallback when Inspo MCP is unreachable. No external dependencies — Python 3.x only.

```bash
# Full design system recommendation (pattern, style, colors, typography, effects, anti-patterns)
python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<product type + industry + keywords>" --design-system -p "<Project Name>"

# Deep-dive a single dimension
python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<keyword>" --domain <style|color|typography|product|ux|chart|icons|google-fonts|landing>

# Stack-specific guidance (react, nextjs, vue, svelte, astro, swiftui, flutter, jetpack-compose, html-tailwind, shadcn, angular, laravel, and more)
python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<keyword>" --stack <stack>
```

If a search returns 0 results: retry once with broader/different keywords before falling back to the Anti-Patterns/Quick Reference sections below, and say explicitly that the recommendation came from defaults, not a database match — never present a 0-result search as if it returned data.

For the full rule-category priority table and the pre-delivery checklist read `references/design-search/quick-reference.md` and `references/design-search/pro-rules.md`.

## Context Gathering (REQUIRED)

You MUST have confirmed design context before any design work:
- **Target audience**: Who uses this product and in what context?
- **Use cases**: What jobs are they trying to get done?
- **Brand personality/tone**: How should the interface feel?

You cannot infer this by reading the codebase. Code tells you what was built, not who it's for. If `PRODUCT.md` exists at project root, read it for target audience/use cases instead of asking — only ask for what it doesn't cover (e.g. brand tone if `PRODUCT.md` doesn't state it).

## The AI Slop Test

If you showed this interface to someone and said "AI made this," would they believe you immediately? If yes, that's the problem. A distinctive interface should make someone ask "how was this made?"

## Anti-Patterns (Hard Bans)

### Typography
- ❌ Overused fonts: Inter, Roboto, Arial, Open Sans, DM Sans, Fraunces, Playfair Display, Instrument Sans/Serif, Plus Jakarta Sans, Space Grotesk
- ❌ Monospace as lazy shorthand for "technical" vibes
- ❌ Only one font family for the entire page
- ✅ Reject your first 3 font instincts — they're from training data

### Color
- ❌ Pure black (#000) or pure white (#fff) — always tint neutrals toward brand hue
- ❌ Gray text on colored backgrounds
- ❌ The AI color palette: cyan-on-dark, purple-to-blue gradients, neon accents on dark
- ❌ Default to dark mode with glowing accents
- ❌ Another AI-cluster tell: warm cream (`~#F4F1EA`) + high-contrast serif + terracotta accent — this skill's own "tint neutrals toward brand hue" rule below actually funnels toward this cluster, so watch for it specifically rather than assuming the rule already avoids it [source: Anthropic's official `frontend-design` Claude Code plugin — compared, not adopted]
- ❌ Heavy `rgba()` / alpha transparency (design smell = incomplete palette)
- ✅ Use OKLCH, not HSL
- ✅ 60-30-10 rule: 60% neutral, 30% secondary, 10% accent
- ✅ Tint neutrals toward brand hue (chroma 0.005-0.01)

### Layout
- ❌ Wrap everything in cards — not everything needs a container
- ❌ Nest cards inside cards
- ❌ Identical card grids (same-sized cards with icon + heading + text, repeated)
- ❌ Center everything — left-aligned with asymmetric layouts feels more designed
- ❌ Numbered markers (01/02/03) as decoration — only use them when order is real information (steps, ranking), not to fake structure
- ✅ Use `gap` instead of margins for sibling spacing
- ✅ 4pt base spacing scale: 4, 8, 12, 16, 24, 32, 48, 64, 96px

### Motion
- ❌ Bounce or elastic easing — feels dated
- ❌ Animate anything except `transform` and `opacity`
- ✅ Exponential easing (ease-out-quart/quint/expo)
- ✅ 100-150ms feedback, 200-300ms state changes, 300-500ms layout changes
- ✅ Always respect `prefers-reduced-motion`

### Visual
- ❌ Glassmorphism everywhere
- ❌ Rounded rectangles with generic drop shadows
- ❌ Modals unless truly no better alternative
- ❌ Side-stripe borders (`border-left` > 1px as accent)
- ❌ Gradient text (`background-clip: text` with gradients)
- ❌ Emojis as icons — use SVG (Heroicons, Lucide)

## Slash Commands (Implement Mode)

| Command | Purpose |
| ------- | ------- |
| `/audit` | Read-only quality check — anti-patterns, structural fingerprint, `design-system` drift. Zero edits. See `references/audit-verb.md`. |
| `/critique` | UX evaluation with actionable feedback |
| `/polish` | Final pass — alignment, spacing, consistency, detail |
| `/normalize` | Align with design system standards |
| `/distill` | Strip to essence, remove unnecessary complexity |
| `/clarify` | Improve UX copy, error messages, labels |
| `/optimize` | Performance (loading, rendering, animations, bundle) |
| `/harden` | Resilience (error handling, i18n, overflow, edge cases) |
| `/animate` | Add purposeful motion and micro-interactions |
| `/colorize` | Add strategic color to monochromatic interfaces |
| `/bolder` | Amplify safe/boring designs to be memorable |
| `/quieter` | Tone down overwhelming designs |
| `/delight` | Add moments of joy and personality |
| `/extract` | Pull repeated patterns into reusable components |
| `/adapt` | Responsive adaptation for different devices |
| `/onboard` | Design effective onboarding flows |
| `/teach` | One-time setup: gather design context for project |

### Command Workflows

```text
Quality:     /audit → /normalize → /harden → /polish
Enhancement: /critique → /distill → /colorize → /animate → /polish
New Project: /teach → /critique → /normalize → /animate → /audit → /polish
```

`/audit` is diagnosis-only (see `references/audit-verb.md`) — get the user's confirmation on which findings to act on before continuing into `/normalize`/`/harden`/`/polish` in these chains. `redesign` and `study` (see Modes above) are separate top-level triggers, not slash commands — they operate on an existing page or an external reference rather than polishing the current build.

## Stack Detection

| Stack | Notes |
| ----- | ----- |
| React / Next.js | Tailwind + CSS vars; shadcn/ui if applicable |
| Vue / Nuxt | Same token approach, adapt class syntax |
| Flutter | ThemeData tokens, Material 3 |
| SwiftUI | Color assets + ViewModifier |
| HTML + Tailwind | Default if unspecified |

## Output Format (Design Mode)

```text
TARGET: [Project Name] — RECOMMENDED DESIGN SYSTEM
─────────────────────────────────────────────────
INDUSTRY:  [Sector]
PATTERN:   [Landing page / app structure]
STYLE:     [UI style name + keywords]
COLORS:    Primary / Secondary / CTA / Background / Text
TYPOGRAPHY: [Display font] / [Body font]
KEY EFFECTS: [Animations, interactions]
AVOID:     [Anti-patterns for this industry]
─────────────────────────────────────────────────
PRE-DELIVERY CHECKLIST:
□ Passes AI Slop Test
□ WCAG AA contrast ratios
□ Responsive breakpoints (320 / 768 / 1024px)
□ Touch targets 44px+
□ Dark mode tokens
□ Focus states & keyboard navigation
□ prefers-reduced-motion respected
```

## Quick Reference

### Typography
- Modular type scale with fluid sizing (`clamp`) for headings
- Cap line length at ~65-75ch
- Pair a distinctive display font with a refined body font

### Spacing
- Vary spacing for hierarchy — not uniform gaps everywhere
- Use whitespace as a design element (cards are overused)

### Design Direction
- Commit to a BOLD aesthetic: brutally minimal, maximalist, retro-futuristic, organic, luxury, playful, editorial, brutalist, art deco, soft/pastel, industrial
- What makes this UNFORGETTABLE?

## Gotchas

- **Font reflex** — First 3 choices are training data defaults. Reject them.
- **Theme = context** — Dark/light derived from audience, not preference.
- **Alpha = design smell** — Heavy transparency means incomplete palette.
- **Cards are overused** — Spacing and alignment create grouping naturally.
- **Selector specificity can cancel your own spacing rules** — e.g. `.section` and `.cta` both setting padding/margin on the same element can silently cancel each other out; check computed styles, not just the rule you just wrote.

## When to Load Each Reference

| User says | Load |
| --------- | ---- |
| "typography", "fonts", "type scale", "font pairing" | `references/typography.md` |
| "colors", "palette", "dark mode", "contrast", "OKLCH" | `references/color-and-contrast.md` |
| "spacing", "layout", "grid", "cards", "visual hierarchy" | `references/spatial-design.md` |
| "animation", "motion", "transitions", "easing" | `references/motion-design.md` |
| "forms", "focus", "loading", "modals", "interaction states" | `references/interaction-design.md` |
| "responsive", "mobile", "breakpoints", "fluid design" | `references/responsive-design.md` |
| "copy", "labels", "error messages", "empty states" | `references/ux-writing.md` |
| "craft", "build feature", "shape then build" | `references/craft.md` |
| "extract", "design system", "tokens", "reusable components" | `references/extract.md` |
| "industry rules", "finance", "healthcare", "SaaS", "product type" | Run `python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<query>" --design-system` (see "Run the Design Search Engine" above); for the full priority table read `references/design-search/quick-reference.md` |
| "reasoning engine", "4-stage process" | `references/reasoning-engine/four-stage-process.md` |
| "color palette options", "color index" | Run `python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<query>" --domain color` |
| "pre-delivery checklist", "app polish rules", "native/mobile UI" | `references/design-search/pro-rules.md` |
| "tech stack", "React", "Flutter", "SwiftUI" | `references/tech-stacks.md` |
| "figma", "existing design system" | `references/figma.md` |
| "audit", "score this design", "check for anti-patterns", "quality check" (read-only) | `references/audit-verb.md` |
| "redesign", "looks templated/generic", "same content different structure" | `references/redesign-verb.md` |
| "study this design", "extract the DNA", "what makes this design work", pasted URL/screenshot of an admired design | `references/study-verb.md` |
| "diversification", "don't repeat the same design", "vary this from last time", "design memory" | `references/diversification-memory.md` |

## Conventions

- Aesthetic direction first → tokens → components (always in this order)
- Semantic color names (`--color-primary` not `--blue`)
- Mobile-first responsive design
- No emojis as icons — use SVG (Heroicons, Lucide)

---

## Red Flags

- 🚩 Uses Inter, Roboto, DM Sans, or any banned font → Reject and find distinctive alternative
- 🚩 No context gathering happened → Stop and ask user for audience, use cases, brand tone
- 🚩 Passes "AI Slop Test" negatively → Lacks bold direction; commit to specific tone
- 🚩 Heavy `rgba()` / alpha transparency → Incomplete palette; define explicit tokens
- 🚩 No industry identification → Reasoning engine skipped; identify sector first
- 🚩 Implementation starts with colors before HTML structure → Wrong order
- 🚩 Pure #000/#fff in tokens → Always tint neutrals toward brand hue

---

## Verification

Before declaring complete, confirm:

- [ ] Context gathered (audience, use cases, brand tone)
- [ ] Industry identified (SaaS/Finance/Healthcare/etc.)
- [ ] Existing design system checked (Phase 0)
- [ ] Passes AI Slop Test — doesn't look generically AI-generated
- [ ] No banned fonts used
- [ ] Color tokens defined (no pure #000/#fff, no rgba overuse)
- [ ] WCAG AA contrast ratios validated
- [ ] Implementation order followed (if code was written)
- [ ] `prefers-reduced-motion` respected
- [ ] Pre-delivery checklist passed (responsive, touch targets, dark mode, focus states)
- [ ] Tokens defined BEFORE component design
- [ ] Diversification check run against `.ui-designer/log.json` and the pick stamped/logged (Design Mode only — skip on a locked `DESIGN.md`/`MASTER.md` project)

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a new anti-slop pattern, an industry rule not yet covered (`references/industry-rules/`), a diversification finding.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
