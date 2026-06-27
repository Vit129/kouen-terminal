# Plan: SwiftUI Migration — Harness Terminal

## ทำไมตอนแรกไม่ใช้ SwiftUI ตั้งแต่ต้น

1. **Fork มาจาก upstream ที่เป็น AppKit ทั้งหมด** — codebase เดิมเขียน AppKit ไว้แล้ว
2. **Terminal ต้อง Metal + low-level input** — SwiftUI ทำไม่ได้ (ไม่มี keyDown, displayLink, Metal view)
3. **SwiftUI ปี 2024-25 ยังไม't mature** — NSTableView performance ดีกว่า SwiftUI List สำหรับ complex cells
4. **AppKit ให้ control เต็ม** — borderless window, custom titlebar, NSSplitView divider, cursor rects

## AppKit vs SwiftUI — ข้อดี/ข้อเสีย

| | AppKit | SwiftUI |
|--|--------|---------|
| **ข้อดี** | Full control, Metal, low-level input, mature | Declarative, auto-diffing, less code, no row-index crash |
| **ข้อเสีย** | Verbose, manual state sync, crash-prone (RL-051) | ไม่ได้ทุก use case, performance quirks, less control |
| **เหมาะกับ** | Terminal rendering, window management | Data-driven panels, lists, forms |

## ย้ายแล้วดีกว่ายังไง

- **ลบ bug class ทั้งหมด** — RL-051 (row out-of-range), manual reloadData, stale state
- **Code น้อยลง 50-70%** — ไม่ต้อง NSTableViewDataSource/Delegate boilerplate
- **State management ง่ายขึ้น** — `@Observable` model + SwiftUI auto-diff
- **Maintain ง่ายขึ้น** — เพิ่ม feature ใหม่ไม่ต้อง wire 5 delegate methods

---

## Component Map

### ✅ Phase 1: ย้ายได้เลย (data-driven, ไม่ต้อง low-level)

| Component | File(s) | Lines | ความยาก | ผลลัพธ์ |
|-----------|---------|:-----:|:-------:|---------|
| Sidebar session list | HarnessSidebarPanelVC | ~72KB | ★★★★ | ✅ Done |
| Sidebar chrome (pill, tabs, label, footer) | SidebarWorkspaceViews + HarnessSidebarPanelVC | −998 lines | ★★★ | ✅ Done — deleted HarnessControls.swift |
| Settings panel | SettingsViewController | ~40KB | ★★★ | ✅ Done (S1–S9) |
| Command palette | CommandPalettePanel | ~15KB | ★★ | SwiftUI search + list |
| Agent notch | NotchPanelView | ~10KB | ★★ | SwiftUI popup |
| Notifications inbox | NotificationListView | ~8KB | ★★ | SwiftUI List |
| Onboarding | HarnessOnboarding pkg | already SwiftUI | — | ✅ Done |

### ⚡ Phase 2: Hybrid (AppKit shell + SwiftUI content)

| Component | ทำอะไร | ทำไม hybrid |
|-----------|--------|-------------|
| File tree | ✅ SwiftUI อยู่แล้ว | Bridge via NSHostingView |
| Git panel | ✅ SwiftUI อยู่แล้ว | Bridge via NSHostingView |
| Browser tab bar | SwiftUI tabs + AppKit WKWebView | WKWebView ต้อง NSView |
| Tab bar (terminal) | SwiftUI pill list + AppKit drag | Drag-drop ต้อง AppKit |

### ❌ Phase 3: ย้ายไม่ได้ (ต้อง AppKit/Metal)

| Component | ทำไม |
|-----------|------|
| Terminal surface (Metal) | 60fps rendering, glyph atlas, display link |
| PTY input | keyDown/keyUp/flagsChanged — SwiftUI ไม่ expose |
| Window chrome | Borderless NSWindow, custom titlebar, traffic lights |
| Split pane divider | NSSplitView custom constraints |
| Cursor rects | NSView.resetCursorRects — ไม่มีใน SwiftUI |
| Copy mode overlay | Metal overlay + keyboard capture |

---

## Execution Order (recommended)

| # | งาน | Est. | Priority |
|---|------|------|----------|
| 1 | ~~Sidebar session list~~ | ~~4-6hr~~ | ✅ Done |
| 2 | ~~Sidebar chrome (pill, tab bar, label, footer)~~ | ~~3-4hr~~ | ✅ Done — +Open With Harness file routing |
| 3 | ~~Settings panel → SwiftUI Form~~ | ~~3-4hr~~ | ✅ Done (S1–S9) |
| 4 | Command palette → SwiftUI | 2-3hr | Medium |
| 5 | Notifications inbox → SwiftUI | 1-2hr | Medium |
| 6 | Agent notch → SwiftUI | 1-2hr | Low |
| 7 | Terminal tab bar → SwiftUI pills | 3-4hr | Medium (RL-040 area) |
| 8 | Browser tab bar → SwiftUI | 2-3hr | Low |

## Definition of Done

- [x] Sidebar session list migrated
- [x] Sidebar chrome (pill, tab bar, section label, footer) migrated — deleted HarnessControls.swift
- [x] Settings (S1–S9) migrated — SettingsViewController eliminated
- [ ] Command palette migrated
- [ ] Notifications inbox migrated
- [ ] No `sessionTable.reloadData()` or manual row management remaining
- [ ] `swift build` passes
- [ ] No regressions in functionality (context menus, selection, keyboard nav)
