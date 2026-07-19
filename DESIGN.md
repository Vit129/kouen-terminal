# Design System

## Design Direction
Native macOS-first, monochrome/near-black chrome, "Liquid Glass" vibrancy. Deliberately avoids default system accent blue ("no macOS blue").

## Colors
Source: `KouenChrome` / `KouenChromePalette` (`Apps/Kouen/Sources/KouenApp/UI/Chrome/KouenChrome.swift`)
- Tokens: `textPrimary`, `textSecondary`, `surfaceElevated`, `border`, `borderStrong`, `sidebarBackground`, `terminalBackground`, `accent`, `danger`, `waiting`, `idleStatus`, `isDark`
- Status/agent color-coding: idle / waiting / running (blue) / done (green) / error (red) / per-agent hex tint — via `StatusDotView` + `BoardColumnKind.color`

## Typography
- AppKit `NSFont`-based tokens (not SwiftUI `Font` extensions), via `KouenDesign.Typography`: sidebarLabel, rowTitle, rowMeta (monospaced), tabTitle, sectionLabel, badge, kbd, paletteTitle/Header, settingsHeading
- Sizes: chromeSmall 11, chromeBody 12, sidebarLabel 13, sectionLabel 10.5
- Bundled: SymbolsNerdFontMono-Regular (icon/symbol glyphs in terminal UI)

## Spacing / Radius / Motion
Source: `KouenDesign.swift`
- Spacing scale: xxs(2) → xxl(22)
- Radius: card 7, control 6, pill 5, badge 4, overlay 10, capsule 999
- Motion: microFast .10s → slow .32s, shared `CAMediaTimingFunction` curves

## Components
- Shadows: only via `KouenDesign.applyShadow(_:to:)` preset system (4 elevation levels) — never raw `.shadow()`
- Materials: `NSVisualEffectView` (`.sidebar`/`.underWindowBackground`) as fallback; `NSGlassEffectView` ("Liquid Glass") preferred on macOS 26+ via runtime reflection
- Agent status: "breathing halo" pulse animation for actively-working agents

## Avoid
- System accent blue in chrome
- Raw `.shadow()` / gradient literals outside `KouenDesign` tokens
- Custom SwiftUI `Font` extensions — funnel through `KouenDesign.Typography` instead

---
Sourced from `KouenDesign.swift`, `KouenChrome.swift`, and Sidebar view files (`SidebarSessionListView.swift`, `SidebarSessionRows.swift`, `SidebarWorkspaceViews.swift`) as of 2026-07-18.
