# Design System

## Design Direction
Native macOS-first, monochrome/near-black chrome, "Liquid Glass" vibrancy. Deliberately avoids default system accent blue ("no macOS blue").

## Colors
Source: `KouenChrome` / `KouenChromePalette` (`Apps/Kouen/Sources/KouenApp/UI/Chrome/KouenChrome.swift`)
- Tokens: `textPrimary`, `textSecondary`, `surfaceElevated`, `border`, `borderStrong`, `paneDivider`, `sidebarBackground`, `terminalBackground`, `accent`, `accentSoft`, `danger`, `waiting`, `idleStatus`, `isDark`
- The palette is derived from the active theme's background/foreground (`KouenChromePalette.from`). `accent` is the theme cursor color, or the foreground blended 30% toward a soft blue when no cursor color is set — never `NSColor.controlAccentColor`. `waiting`, `danger` and the success color are fixed soft sRGB values.
- Status/agent color-coding: `StatusDotView.Style` = idle / waiting / running / done / error / accent / `agent(hex:)` / `agentWorking(hex:)`; board columns are colored via `extension BoardColumnKind` in `KouenDesign.swift` (enum lives in `KouenCommands`)

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
- Shadows: `KouenDesign.applyShadow(_:to:)` presets — `none`, `elevation1` (opacity .10, radius 4), `elevation2` (.18, 9), `overlay` (.38, 30) — for AppKit layers
- Materials: `NSVisualEffectView` (`.sidebar`/`.underWindowBackground`) as fallback; `NSGlassEffectView` ("Liquid Glass") preferred on macOS 26+ via runtime reflection
- Agent status: "breathing halo" pulse animation for actively-working agents
- Chrome metrics: `KouenDesign.tabBarHeight` 38, `tabPillHeight` 26; the sidebar header uses `tabBarHeight`
- The terminal tab bar shows blue for running sessions, green for confirmed completion, and gray for idle sessions.
- Draggable chrome (title strip, sidebar header, tab bar) all zoom the window on double-click via one helper, `NSView.zoomWindowIfDoubleClick(_:)`
- Surfaces added since the original audit, all built from the same tokens: Agent Notch HUD (`UI/Notch/`, off by default, hidden while Vorssaint's notch is running), Attention Beacon dot, Agent Inbox panel, Automations/Jobs fleet view, session History view, Issue Tracker panel

### Projects

- Keep the current group header at the top of the scrolling project list. The next group header pushes it out as it reaches the top.
- Use the theme accent to outline the selected session row. Keep session rows in the same order when selection changes. Bring its header into view when switching sessions or reopening the Projects sidebar. Expand its group if needed and respect the active search or filter.
- Repository rows start expanded and can be collapsed by clicking their header. Group headers and discovered worktree lists collapse independently.

- Show the primary checkout first with its branch name and relative last-activity time. Dim the row when no session is open there. Show blue when any agent in a session is working, green on confirmed completion, yellow when awaiting input, red on error, and a gray house when idle. Show other running sessions above a compact, collapsed-by-default disclosure for discovered worktrees. Show the count on the disclosure and include only worktrees whose directories still exist.
- The Projects and group header plus controls open the same three-item menu: Browse folder…, Clone from URL…, and Create new project…. A group import stays in that group and adds projects without opening a session. The repository-row plus opens a new session.
- Clone and Create show the destination path and a Local Mac label. Add the checkout to Projects after Git succeeds. If registration fails, retry with the existing checkout.
- Keep a refresh action next to Add in the Projects header; refresh rescans source folders and reloads linked worktrees so deleted checkout directories leave the sidebar. Show refresh progress and a brief checkmark when the scan finishes. Hide confirmed missing saved projects from Projects automatically. Keep their registrations available for restoration or move review.

- Folder import and rescan show primary Git checkout candidates. Reconciliation presents the saved and proposed paths together, with an explicit action for uncertain matches.

### Session History

- Open session history in the sidebar’s History tab. View → Show Session History (⌃⌘H) expands the sidebar and selects that tab.

- Workspace history shows the active tab's repository first under Current Project, followed by the date-grouped history of other open repositories. Search results retain relevance order.

- Keep history rows compact: one session title, a single metadata line, and search evidence only while searching. Show token usage and transcript content in selected-session details.
- Keep repository scope and agent filters visible at narrow sidebar widths; agent shortcuts scroll horizontally while the trailing More menu remains fixed. The More menu holds other providers and shortcut management.
- Shortcut management numbers the selected agents and lets users drag the handle to reorder them; selection changes append and removal closes the gaps.
- Search counts distinguish matching sessions from searchable sessions under the active scope and agent filters. Empty results offer clear/reset actions.
- Selected details label the first prompt and latest turns, identify speaker roles, and show worktree availability before resume actions.

### Review Changes

- Use the File Preview split beside the terminal. Review Changes has a close button in the tab bar and Refresh above the diff. ⌘L opens or closes the active review tab.
- Show the file and change kind before the diff. Click a line or Shift-click within a hunk to select a range. Keep comments visible through refresh and expose Resolve and Reattach actions.

## Avoid
- System accent blue in chrome
- Raw shadows on AppKit layers outside `applyShadow` presets. Known exceptions in SwiftUI views: the notch status-dot glow (`AgentNotchRootView`) and the tab pill (`TerminalTabBarView`)
- Custom SwiftUI `Font` extensions — funnel through `KouenDesign.Typography` instead

---
Sourced from `KouenDesign.swift` (`UI/Shared/`), `KouenChrome.swift`, and Sidebar view files as of 2026-07-18; all tokens re-verified against source 2026-09-30 (spacing, radius, motion, font sizes, typography, shadow presets, palette tokens, status styles, glass-effect runtime lookup, `tabBarHeight`/`tabPillHeight`). Not verified: literal palette values per theme, and the Sidebar view files listed originally.
Surface list re-checked 2026-10-07 against v4.20.11: Quick Terminal, the sidebar project-header context menu and the Files-tab inline preview no longer exist; the notch yields to Vorssaint. Token values were not re-verified since 2026-09-30.

## Menu-bar icon preference

Appearance contains a native “Menu Bar” section with “Show menu bar icon”, enabled by default. Changes apply immediately and persist; the help text points to ⌘, to reopen Settings after hiding the icon. This preference is independent of the Agent Notch HUD.
