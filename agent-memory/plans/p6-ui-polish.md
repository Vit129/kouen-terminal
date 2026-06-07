# P6 — UI Polish: macOS-Native Quality Icons & Components

Status: **complete**  
Priority: **P1** — first impression for external users  
Depends on: P3 (split fix) recommended first  

---

## Goal

Every button, icon, and control feels native macOS — consistent with Finder, Xcode, and system apps. No custom Unicode arrows, no hardcoded colors, proper vibrancy and animation.

## Audit: Current vs Target

| Component | Current | Target |
|-----------|---------|--------|
| Disclosure arrows | Unicode `▶`/`▼` text | SF Symbol `chevron.right` with 90° rotation animation |
| Split buttons | Hardcoded black pill, white icons | Theme-aware `surfaceElevated` bg, `textSecondary` icons |
| Git Fetch▼/Push▼/Commit▼ | Mixed font size/weight, no icons on some | Uniform `SoftIconButton` style, SF Symbol per action |
| Sidebar material | Flat color background | `NSVisualEffectView` with `.sidebar` material + vibrancy |
| Button hover states | Some have, some don't | All interactive elements show hover highlight |
| Tab close (✕) | Appears on hover (good) | ✅ Keep |
| Segmented control | System default | ✅ Keep |
| Spacing/padding | Ad-hoc values scattered | Centralized in `HarnessDesign.Spacing` |

## Steps

### 1. Design Tokens Audit
- ✅ Added `HarnessDesign.FontSize`, `HarnessDesign.IconSize`, `symbolConfig(...)`, and `configurePillButton(...)`
- ✅ Consolidated P6-touched controls into `HarnessDesign.Spacing`, `.Radius`, `.FontSize`, and `.IconSize`
- ✅ P6-touched components read from tokens/helpers instead of inline style setup
- ✅ Split/sidebar/Git controls use `HarnessChromePalette` colors instead of hardcoded `.black`/`.white`

### 2. SF Symbols Everywhere
- ✅ `SessionGroupHeaderRowView` disclosure now uses SF Symbol `chevron.right`
- ✅ Disclosure chevron rotates on expand/collapse with `HarnessDesign.Motion.standard`

```swift
// Before: Unicode
disclosureLabel.stringValue = isCollapsed ? "▶" : "▼"

// After: SF Symbol with animation
let config = NSImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
disclosureImage.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)?
    .withSymbolConfiguration(config)
// Rotate 90° when expanded
disclosureImage.frameCenterRotation = isCollapsed ? 0 : -90
```

### 3. Consistent Button Styles
Define 3 button styles used everywhere:

| Style | Use case | Spec |
|-------|----------|------|
| `SoftIconButton` | Toolbar actions (+, ×, split) | 22×22, symbol-only, hover highlight |
| `PillButton` | Fetch▼, Commit▼, Push▼ | Recessed, 12pt semibold, SF Symbol left, dropdown arrow |
| `InlineTextButton` | Branch name, clickable labels | No border, underline on hover, system font |

- ✅ `SoftIconButton` already exists and is shared by toolbar/sidebar/tab actions
- ✅ `PillButton` behavior is centralized in `HarnessDesign.configurePillButton(...)`
- ✅ Group header add/options and worktree remove actions now use SF Symbol icon buttons

### 4. Split Buttons Restyle
- ✅ `PaneSplitButtonsView` uses `HarnessDesign.chrome.surfaceElevated`, `borderStrong`, and themed icon tint
- ✅ Split button spacing/radius reads from `HarnessDesign`

```swift
// Current: hardcoded black pill
layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor

// Target: theme-aware, matches tab bar chrome
layer?.backgroundColor = HarnessDesign.chrome.surfaceElevated.withAlphaComponent(0.6).cgColor
// Icons use textSecondary, brighten to textPrimary on hover
```

### 5. Sidebar Vibrancy
- ✅ Sidebar root installs `ChromeBackdrop`
- ✅ Sidebar role now uses `NSVisualEffectView.Material.sidebar`

```swift
let effectView = NSVisualEffectView()
effectView.material = .sidebar
effectView.blendingMode = .behindWindow
effectView.state = .followsWindowActiveState
// Use as sidebar background instead of flat color
```

### 6. Animations
- ✅ Disclosure chevron: `NSAnimationContext.runAnimationGroup` rotation
- ✅ Tab close ✕: fade in 0.15s (already exists)
- ✅ Split buttons: hover-responsive themed tint
- ✅ Git stage checkboxes: subtle scale pulse on toggle

### 7. Git Panel Button Consistency
- ✅ `Stage All`, `Commit`, `Fetch/Push`, and add-worktree controls use shared `HarnessDesign.configurePillButton(...)`
- ✅ Fetch/Push icon swaps now go through the same pill helper

```swift
// All action buttons use PillButton style:
// [⟳ Fetch ▼]  [✓ Commit ▼]  [↑ Push ▼]
// Same: bezelStyle .recessed, controlSize .small, font 11pt semibold
// Same: SF Symbol left, imagePosition .imageLeft
// Same: dropdown indicator (▼ built into title)
```

## Files to Modify

| File | Changes |
|------|---------|
| `HarnessDesign.swift` | Add `.FontSize`, `.IconSize` tokens |
| `HarnessSidebarPanelViewController.swift` | Disclosure → SF Symbol + animation, vibrancy bg |
| `ContentAreaViewController.swift` | Split buttons → theme-aware colors |
| `GitPanelView.swift` | Uniform PillButton style for Fetch/Commit/Push |
| `SessionGroupHeaderRowView` (in sidebar) | Disclosure animation |
| `TerminalTabBarView.swift` | Verify tokens usage |

## Definition of Done

- [x] No hardcoded colors in P6-touched controls (all from `HarnessChromePalette`)
- [x] No Unicode disclosure arrows (all SF Symbols)
- [x] All P6-touched buttons hover-responsive
- [x] Sidebar uses `NSVisualEffectView` vibrancy
- [x] Disclosure arrows animate on expand/collapse

## Progress Log

### 2026-06-07
- Added shared design tokens/helper methods in `HarnessDesign.swift`.
- Restyled pane split buttons to use theme-aware palette colors and hover tint.
- Replaced session-group Unicode disclosure arrows with animated SF Symbol chevrons.
- Unified Git panel pill-style buttons through a shared helper.
- Converted group header add/options and worktree remove controls to SF Symbols.
- Added Git stage checkbox pulse animation.
- Switched sidebar vibrancy material to `.sidebar`.
- Removed visual review/screenshot checks per user request.
- Verified with `make build`; build passed with existing SwiftPM resource warnings.

## Estimate

1–2 sessions (mostly search-and-replace + style unification)
