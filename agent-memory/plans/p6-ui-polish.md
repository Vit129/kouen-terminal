# P6 — UI Polish: macOS-Native Quality Icons & Components

Status: **planned**  
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
- Consolidate all magic numbers into `HarnessDesign.Spacing`, `.Radius`, `.FontSize`
- Ensure every component reads from tokens, not inline values
- Dark/light mode: all colors from `HarnessChromePalette`, no hardcoded `.black`/`.white`

### 2. SF Symbols Everywhere
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

### 4. Split Buttons Restyle
```swift
// Current: hardcoded black pill
layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor

// Target: theme-aware, matches tab bar chrome
layer?.backgroundColor = HarnessDesign.chrome.surfaceElevated.withAlphaComponent(0.6).cgColor
// Icons use textSecondary, brighten to textPrimary on hover
```

### 5. Sidebar Vibrancy
```swift
let effectView = NSVisualEffectView()
effectView.material = .sidebar
effectView.blendingMode = .behindWindow
effectView.state = .followsWindowActiveState
// Use as sidebar background instead of flat color
```

### 6. Animations
- Disclosure chevron: `NSAnimationContext.runAnimationGroup` 0.2s rotation
- Tab close ✕: fade in 0.15s (already exists)
- Split buttons: fade in/out on pane hover (0.2s)
- Git stage checkboxes: subtle scale pulse on toggle

### 7. Git Panel Button Consistency
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

- [ ] No hardcoded colors (all from `HarnessChromePalette`)
- [ ] No Unicode arrows (all SF Symbols)
- [ ] All buttons hover-responsive
- [ ] Sidebar uses `NSVisualEffectView` vibrancy
- [ ] Disclosure arrows animate on expand/collapse
- [ ] Passes visual review in both dark and light mode
- [ ] Screenshot comparison with Finder/Xcode sidebar for consistency

## Estimate

1–2 sessions (mostly search-and-replace + style unification)
