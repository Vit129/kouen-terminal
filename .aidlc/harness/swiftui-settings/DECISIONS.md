# DECISIONS — Settings SwiftUI Migration

**Date:** 2026-06-26  
**Approach:** SDLC (Dev first → QA after)  
**Scope:** Replace `SettingsViewController` (3,430 lines AppKit) with SwiftUI Form

---

## Architecture Decisions

| # | Decision | Rationale |
|---|---|---|
| D1 | `@Observable SettingsModel` wrapper class | `HarnessSettings` is a `struct` + `SessionCoordinator` is not `@Observable` → need a bridge |
| D2 | `SettingsModel` subscribes to `NotificationBus.shared.snapshotChanged` | Same notification the AppKit VC uses — keeps parity without new infrastructure |
| D3 | Writes go through existing `SessionCoordinator.shared.requestDaemon` | Don't change the write path — settings daemon owns persistence |
| D4 | `NSHostingController<SettingsRootView>` replaces `SettingsViewController` | Drop-in at the call site: wherever `SettingsViewController()` is created today |
| D5 | `HarnessSwatchWell` + `KeyRecorderView` stay AppKit via `NSViewRepresentable` | Both are custom NSControl with complex hit-testing — not worth rewriting |
| D6 | `HarnessToggle/Slider/Segmented/Select` → SwiftUI `Toggle/Slider/Picker` | Standard SwiftUI controls; no NSViewRepresentable overhead needed |
| D7 | `+LiveApply.swift` deleted after migration | SwiftUI re-renders on model change — manual re-skin walk is replaced by the runtime |
| D8 | Migrate page by page; keep AppKit VC alive until all 7 pages done | Safe incremental delivery; each page independently testable |
| D9 | Terminal page first | Smallest (127 lines), unlocks otty vi-mode + quick terminal settings, no color wells |

---

## Control Mapping

| AppKit control | SwiftUI replacement | Bridge needed? |
|---|---|---|
| `HarnessToggle` | `Toggle` | No |
| `HarnessSlider` | `Slider` | No |
| `HarnessSegmented` | `Picker(.segmented)` | No |
| `HarnessSelect` | `Picker(.menu)` | No |
| `HarnessSwatchWell` | `SwatchWellView: NSViewRepresentable` | Yes |
| `KeyRecorderView` | `KeyRecorderRepresentable: NSViewRepresentable` | Yes |
| `NSTableView` (Remote) | SwiftUI `List` | No |
| `NSTextField` (label) | `Text` | No |

---

## What Disappears

- `SettingsViewController.swift` (854 lines)
- `SettingsViewController+LiveApply.swift` (709 lines) — SwiftUI handles this
- `SettingsViewController+Primitives.swift` (420 lines) — AppKit factory helpers
- `SettingsViewController+Colors.swift` (93 lines) — inline in SwiftUI color page
- `SettingsViewController+Appearance.swift` (121 lines)
- `SettingsViewController+Terminal.swift` (127 lines)
- `SettingsViewController+Keys.swift` (23 lines)
- `SettingsViewController+Agents.swift` (517 lines)
- `SettingsViewController+Advanced.swift` (219 lines)
- `SettingsViewController+Remote.swift` (347 lines)

**Total deleted:** ~3,430 lines  
**Estimated new SwiftUI:** ~800 lines (75% reduction)
