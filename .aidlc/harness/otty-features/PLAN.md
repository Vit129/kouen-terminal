# Otty Feature Import Plan — Harness Terminal
**Mode:** Dev Only | **Approach:** SDLC | **Date:** 2026-06-24

---

## Otty vs Harness — Gap Analysis

### ✅ Already have (no work needed)

| Otty Feature | Harness Equivalent | Location |
|---|---|---|
| GPU rendering (Metal) | Metal renderer | `HarnessTerminalKit` |
| Link/URL detection | `URLDetection` + `linkRange()` | `HarnessTerminalEngine/URLDetection.swift` + `HarnessTerminalSurfaceView+SelectionAndLinks.swift` |
| Session restore | `SessionLifecycleService` | `Services/` |
| Agent integration | `AgentCatalog`, `AgentBridge`, `AgentChatPanelView` | `UI/Agents/`, `UI/AIChat/` |
| Inline AI completion | `InlineAICompletionController` | `UI/Inline/` |
| Command palette | `CommandPalette/` | `UI/CommandPalette/` |
| File tree | `FileTree/` | `UI/FileTree/` |
| Shell integration | `SurfaceShellTracker` | `Services/` |
| Progress tracking (OSC) | `SurfaceProgressTracker` | `Services/` |
| Overlay / chip pattern | `DisplayPanesOverlay` | `UI/Shared/DisplayPanesOverlay.swift` |
| Multi-key prefix system | `PrefixKeymap` | `UI/Shared/PrefixKeymap.swift` |
| Key table lookup | `KeybindingsService` + `KeyTableSet` | `Services/KeybindingsService.swift` |
| Copy mode (keyboard nav) | `CopyMode` + `CopyModeReducer` | `HarnessTerminalSurfaceView+CopyMode.swift` |
| Text selection | `currentSelectionRegion`, `SelectionResolver` | `HarnessTerminalSurfaceView.swift` |
| Right-click hook | `rightMouseUp` (currently passes to super) | `HarnessTerminalSurfaceView+SelectionAndLinks.swift:321` |

### ❌ Missing — Target for this plan

| Feature | Ponytail Rung | Effort |
|---|---|---|
| **1. Hint mode** — keyboard URL picker overlay | Reuse `DisplayPanesOverlay` pattern + `linkRange()` | Medium |
| **2. Vi mode** — vi keybindings in terminal input | New state machine in Input handler | Large |
| **3. Send selection → AI chat** | Wire `rightMouseUp` context menu → `AITerminalChatController` | Small |

---

## Ponytail Analysis (climb the ladder before writing code)

### Feature 1: Hint mode

**What already exists:**
- `linkRange(atRow:column:)` — finds URL + column span at any cell (OSC 8 + auto-detect)
- `URLDetection.match()` / `detectFilePath()` / `detectLocalhost()` — 3 detection strategies
- `DisplayPanesOverlay` — exact pattern: key monitor + chip overlay + dismiss on key/timeout
- `cellSizePoints()` — converts grid coords → pixel frame (already in SelectionAndLinks)

**What's missing:** scan ALL rows in viewport → collect all links → render labeled chips → intercept key sequence

**Minimum code:** ~1 new file `HintModeOverlay.swift` (≈150 lines), modeled on `DisplayPanesOverlay`. No new infrastructure.

**API needed from terminal:**
- Need `allLinksInViewport() -> [(label: String, url: String, row: Int, cols: Range<Int>)]` — either a new public method on `HarnessTerminalSurfaceView` or computed inline in overlay
- Need `cellFrameInWindow(row:col:) -> NSRect` — for chip placement

**Key binding:** add `BannerShortcutRegistry.hintMode` + menu item → calls `HintModeOverlay.shared.show(on: surfaceView)`

---

### Feature 2: Vi mode

**What already exists:**
- `HarnessTerminalSurfaceView+Input.swift` — `_keyDown()` dispatches all key events
- `CopyMode` — has `CopyModeReducer` with motion commands (h/j/k/l, w/b, 0/$, etc.) already implemented
- `KeyTableSet` + `KeybindingsService` — key table lookup by table ID
- `PrefixKeymap` — shows how to intercept keys before PTY

**What's missing:** a `ViInputMode` state (normal/insert) that intercepts typed chars in normal mode and executes motion/command actions

**Ponytail insight:** Vi mode for INPUT is fundamentally different from CopyMode (which navigates scrollback). Vi mode affects what gets sent to the PTY. CopyMode reducer can be partially reused for motion logic, but the output is different (cursor move = send escape sequences, not highlight selection).

**Minimum code:**
- `HarnessTerminalSurfaceView+ViMode.swift` — `ViModeState` enum (normal/insert/visual), `handleViNormalKey()` dispatcher, motion → PTY escape sequence map
- Toggle via keybinding or `Esc` in terminal

**Escape sequence map needed:** h→`\x1b[D`, l→`\x1b[C`, j→`\x1b[B`, k→`\x1b[A`, 0→`\x01`, $→`\x05`, w→`\x1bf`, b→`\x1bb`, i→enter insert, a→move right + insert, etc.

**Risk:** conflicts with apps that use Esc for their own purposes (vim inside terminal). Need guard: vi mode only active when `$TERM` supports it or user explicitly enables per-session.

---

### Feature 3: Send selection → AI chat

**What already exists:**
- `rightMouseUp` — currently passes through to `super.rightMouseUp` when no link. Perfect hook.
- `currentSelectionRegion` — returns current selection (non-nil when text selected)
- `SelectionResolver.resolveSelectionRegion()` — converts raw selection → text string (called in copy path already)
- `AITerminalChatController` — `submit(_:)` is **private** — needs `prepopulate(text:)` exposed

**What's missing:**
1. `AITerminalChatController.prepopulate(text:)` — public method that opens chat + pre-fills query input
2. Context menu in `rightMouseUp` with "Send to AI Chat" item when selection active
3. Optional: keybinding `Cmd+Shift+A` → send selection

**Minimum code:** ~30 lines total across 2 files.

---

## Implementation Order

Build smallest → largest. Feature 3 unblocks understanding AIChat API before Feature 1 needs it.

```
Phase 1: Send selection → AI chat   (Feature 3 — Small,  ~30 lines, 2 files)
Phase 2: Hint mode                  (Feature 1 — Medium, ~150 lines, 2 files)
Phase 3: Vi mode                    (Feature 2 — Large,  ~200 lines, 1 new file)
```

---

## Phase 1: Send selection → AI chat

**Files to touch:**
| File | Change |
|---|---|
| `Apps/Harness/Sources/HarnessApp/UI/AIChat/AITerminalChatController.swift` | Add `func prepopulate(text: String)` — opens panel, sets query input text |
| `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView+SelectionAndLinks.swift` | In `rightMouseUp`: build NSMenu with "Send to AI Chat" when selection non-nil |

**Context menu trigger:**
```swift
// rightMouseUp — add before super call
if let region = currentSelectionRegion,
   let text = resolveSelectionText(region) {
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Send to AI Chat", action: #selector(sendSelectionToAI), ...))
    // + existing Copy, Open URL items
    NSMenu.popUpContextMenu(menu, with: event, for: self)
    return
}
```

**Success criteria:** right-click selected text → "Send to AI Chat" → chat panel opens with text pre-filled.

---

## Phase 2: Hint mode

**Files to touch:**
| File | Change |
|---|---|
| `Apps/Harness/Sources/HarnessApp/UI/Shared/HintModeOverlay.swift` | NEW — scan viewport links, render chips, key monitor (clone `DisplayPanesOverlay` shape) |
| `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView+SelectionAndLinks.swift` | Add `public func visibleLinks() -> [(label: String, url: String, frame: NSRect)]` |
| `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift` | Add "Hint Mode" menu item + `BannerShortcutRegistry.hintMode` |
| `Packages/HarnessCore/Sources/HarnessCore/ReleaseNotes/BannerShortcutRegistry.swift` | Add `hintMode` keybinding (e.g. `Cmd+F` or configurable) |

**Label scheme:** 2-char combos `aa`, `ab`, `ac`… (enough for ~20 links visible at once). Single-char `a`–`z` for <26 links.

**Chip style:** reuse `DisplayPanesOverlay.makeChip()` visual style — dark rounded rect + white label.

**Success criteria:** press keybinding → chips appear over all links → type label → link opens (browser pane or system browser per existing `openLink` logic).

---

## Phase 3: Vi mode

**Files to touch:**
| File | Change |
|---|---|
| `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView+ViMode.swift` | NEW — `ViModeState` enum, `handleViNormalKey()`, PTY escape map |
| `Packages/HarnessTerminalKit/Sources/HarnessTerminalKit/HarnessTerminalSurfaceView+Input.swift` | In `_keyDown`: check `viMode != nil` before PTY write; route to `handleViNormalKey()` |
| `Apps/Harness/Sources/HarnessApp/UI/Chrome/MainMenuBuilder.swift` | Add "Vi Mode" toggle menu item |
| `Apps/Harness/Sources/HarnessApp/Settings/SettingsViewController+Terminal.swift` | Add "Vi Mode" toggle setting |

**State machine:**
```
.insert  ← default, all keys pass through to PTY as normal
.normal  ← Esc triggers; h/j/k/l/w/b/0/$/i/a/A/o/O/x/dd/yy/p dispatch actions
.visual  ← v triggers; motion extends selection
```

**Guard:** only enable if no app in the PTY is itself vim/nvim (detect via `$SHELL` heuristic or explicit user toggle per session). `ponytail: global toggle first, per-session later if actually needed`.

**Success criteria:** enable vi mode → Esc enters normal → hjkl moves cursor → i re-enters insert → all other keys pass through normally in insert mode.

---

## Files Created / Modified Summary

| File | Type | Feature |
|---|---|---|
| `UI/Shared/HintModeOverlay.swift` | NEW | Hint mode |
| `UI/AIChat/AITerminalChatController.swift` | MODIFY | Send to chat |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+SelectionAndLinks.swift` | MODIFY | Send to chat + Hint mode |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+ViMode.swift` | NEW | Vi mode |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Input.swift` | MODIFY | Vi mode |
| `UI/Chrome/MainMenuBuilder.swift` | MODIFY | All 3 (menu items) |
| `HarnessCore/.../BannerShortcutRegistry.swift` | MODIFY | Hint mode keybinding |
| `Settings/SettingsViewController+Terminal.swift` | MODIFY | Vi mode toggle |

**Total estimate:** ~380 lines new code across 8 files. No new dependencies.

---

## Open Questions (decide before starting each phase)

| # | Question | Default |
|---|---|---|
| 1 | Hint mode keybinding? | `Cmd+Shift+U` (U = URL) |
| 2 | Hint mode opens in browser pane or system browser? | Reuse existing `openLink()` logic (browser pane for localhost/GitHub) |
| 3 | Vi mode per-session toggle or global? | Global toggle in Settings first |
| 4 | Vi mode status shown in status bar? | Yes — show `[N]` / `[I]` badge |
| 5 | Send to chat keybinding in addition to context menu? | `Cmd+Shift+A` optional, context menu sufficient for now |
