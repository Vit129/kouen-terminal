# @design-system Skill

**AI-powered design system generator** that analyzes project requirements and automatically generates complete, tailored design systems.

---

## Quick Start

### 1. Invoke the Skill
```bash
# In Claude Code, type:
@ui-designer

# Or specify parameters:
@ui-designer --industry fintech --stack react
```

### 2. Provide Project Context
- **Industry**: Tech, Finance, Healthcare, E-commerce, Services, Creative, Lifestyle, Emerging Tech
- **Tech Stack**: React, Next.js, Vue, Svelte, Flutter, SwiftUI, etc.
- **Target Users**: Developers, designers, product teams

### 3. Get Your Design System
Output includes:
- **Reasoning Engine**: 4-stage analysis (search, match, generate, validate)
- **Pattern Recommendations**: Layout, navigation, components, interactions
- **Color Palette**: Primary, secondary, semantic colors with dark mode
- **Typography**: Fonts, scale, weights, accessibility specs
- **Animation Effects**: Transitions, timings, easing functions
- **Accessibility Checklist**: WCAG AA validation, responsive breakpoints

---

## Features

| Feature | Count | Benefit |
|---------|-------|---------|
| **Industry Rules** | 161 | Domain-specific, battle-tested patterns |
| **UI Styles** | 84 | Visual approaches (minimalism, brutalism, etc.) |
| **Color Palettes** | 192 | Psychology-backed, industry-aligned colors |
| **Font Pairings** | 74 | Google Fonts combinations, accessibility-tested |
| **Chart Types** | 25 | Data visualization for dashboards |
| **UX Guidelines** | 98 | Detailed, interactive patterns |
| **Tech Stacks** | 22 | Web, mobile, native platforms |

---

## Directory Structure

```
ui-designer/
├── SKILL.md                                    ← Skill entry point
├── scripts/                                    ← Design search engine (BM25 over CSV databases)
│   ├── search.py                               ← CLI entry point
│   ├── core.py                                 ← Search/ranking logic
│   ├── design_system.py                        ← --design-system generator
│   └── validate_data.py                        ← Data integrity checker
├── data/                                       ← CSV databases the engine searches (+ stacks/)
└── references/
    ├── figma.md                                ← Figma integration
    ├── design-system-README.md                 ← You are here
    ├── tech-stacks.md                          ← 15 platforms, output format
    ├── reasoning-engine/
    │   └── four-stage-process.md               ← How the engine works
    ├── industry-rules/                         ← 161 rules across 8 industries (folded in from the retired industry-rules skill)
    │   ├── README.md                           ← overview of all 161 rules
    │   ├── tech-saas.md, finance.md, healthcare.md, ecommerce.md
    │   └── services.md, creative.md, lifestyle.md, emerging-tech.md
    └── design-search/                          ← 84 styles, 192 palettes, 74 fonts, 25 charts, 98 guidelines (via scripts/search.py)
        ├── quick-reference.md                  ← Full rule categories
        └── pro-rules.md                        ← Pre-delivery checklist (native/mobile)
```

[source:github.com/nextlevelbuilder/ui-ux-pro-max-skill] — the design-patterns/ static snapshot referenced above was retired in favor of the live search engine at scripts/ + data/.

---

## Core Capabilities

### Reasoning Engine (4 Stages)

1. **Multi-Domain Search** — Category, style, color, pattern, typography analysis
2. **Intelligent Matching** — Apply 161 industry rules, BM25 ranking, filter anti-patterns
3. **Complete Output** — Pattern recommendations, color system, typography, animations, tokens
4. **Quality Validation** — WCAG AA, responsive breakpoints, contrast ratios

---

## Next Steps (Remaining)

1. ~~`design-patterns/typography.md` (font pairing index)~~ — superseded: `python3 $CLAUDE_HOME/skills/uxui-designer/scripts/search.py "<query>" --domain typography` now covers this live, no static file needed
2. `design-patterns/components.md` (UI component patterns) — still open, unrelated to the design-search sync

---

*Status: Core structure complete; industry-rules/ complete (8/8 industry files + README)*
