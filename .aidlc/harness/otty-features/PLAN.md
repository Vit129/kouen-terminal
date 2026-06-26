# Terminal Feature Gap Plan — Harness Terminal
**Mode:** Dev Only | **Approach:** SDLC | **Date:** 2026-06-26
**Sources:** Otty, Ghostty, WezTerm, Warp, Zellij, iTerm2

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

#### Quick Wins (Small)
| # | Feature | Ponytail Rung | Source |
|---|---|---|---|
| **3** | **Send selection → AI chat** | Wire `rightMouseUp` → `AITerminalChatController` | Otty, Warp |
| **4** | **Scrollback Search** | `NSSearchField` overlay + `TerminalSearchEngine` | Ghostty 1.3, iTerm2, WezTerm |
| **5** | **Click-to-move cursor** | `mouseDown` → compute cell offset → send cursor escape seq | Ghostty 1.3, WezTerm |
| **6** | **Auto Secure Input** | Monitor PTY for password prompt pattern → toggle macOS Secure Input API | Otty |
| **7** | **Context-aware keybindings** | Key handler checks selection state before dispatching (Ctrl+C = copy vs interrupt) | Ghostty "Performable" |

#### Medium
| # | Feature | Ponytail Rung | Source |
|---|---|---|---|
| **1** | **Hint mode** — keyboard URL picker overlay | Reuse `DisplayPanesOverlay` + `linkRange()` | Otty |
| **8** | **Composer** — multi-line command editor | Slide-up panel, submit → send to PTY | Otty (⌘⇧E) |
| **9** | **Prompt Queue** — sequential command runner | Queue DSL + fire-when-idle observer | Otty |
| **10** | **Quick Terminal** — hotkey dropdown window | `NSPanel` + global `NSEvent` monitor | Ghostty, iTerm2 Visor |
| **11** | **Recipes** — saved commands/layouts/snippets | JSON store + picker UI | Otty, Warp Drive |

#### Large
| # | Feature | Ponytail Rung | Source |
|---|---|---|---|
| **2** | **Vi mode** — vi keybindings in terminal input | State machine in Input handler | Otty, WezTerm |
| **12** | **Block-based output** — command+output as discrete blocks | Shell integration hook → block boundary markers | Warp |
| **13** | **Kitty Graphics Protocol** — inline images | Decode sixel/PNG from PTY stream → render in Metal layer | Ghostty, WezTerm, Kitty |
| **14** | **Floating panes** — overlay pane without disrupting layout | Z-layer pane outside split tree | Zellij |
| **15** | **Tab thumbnails overview** — visual all-tabs view | Thumbnail render → grid overlay | Ghostty |

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

Build smallest → largest. Feature 3 unblocks AIChat API before Feature 1 needs it.

```
── Quick Wins ──────────────────────────────────────────────────
Phase 3:  Send selection → AI chat    Small,   ~30 lines
Phase 4:  Scrollback Search           Small,   ~80 lines
Phase 5:  Click-to-move cursor        Small,   ~20 lines
Phase 6:  Auto Secure Input           Small,   ~50 lines
Phase 7:  Context-aware keybindings   Small,   ~40 lines

── Medium ──────────────────────────────────────────────────────
Phase 1:  Hint mode                   Medium,  ~150 lines
Phase 8:  Composer                    Medium,  ~120 lines
Phase 9:  Prompt Queue                Medium,  ~100 lines
Phase 10: Quick Terminal              Medium,  ~150 lines
Phase 11: Recipes                     Medium,  ~200 lines

── Large ───────────────────────────────────────────────────────
Phase 2:  Vi mode                     Large,   ~200 lines
Phase 12: Block-based output          Large,   ~250 lines
Phase 14: Floating panes              Large,   ~200 lines
Phase 15: Tab thumbnails              Large,   ~180 lines

── Defer until demand ──────────────────────────────────────────
Phase 13: Kitty Graphics Protocol     XL,      ~400 lines
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

---

## Phase 4: Scrollback Search

**Source:** Ghostty 1.3, iTerm2, WezTerm

**What already exists:**
- `TerminalBuffer` / scrollback — buffer already exists, rows addressable
- `NSSearchField` — standard AppKit component, no new dependency

**What's missing:** search overlay that highlights match rows and lets user jump n/N

**Files to touch:**
| File | Change |
|---|---|
| `UI/Shared/ScrollbackSearchBar.swift` | NEW — `NSSearchField` + result counter + prev/next nav |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Search.swift` | NEW — `searchScrollback(query:)`, `nextMatch()`, `prevMatch()`, highlight cells |
| `UI/Chrome/MainMenuBuilder.swift` | Add "Find…" `Cmd+F` menu item |

**Success criteria:** `Cmd+F` → search bar → type → matches highlight → `↩/⇧↩` jumps prev/next → `Esc` closes.

---

## Phase 5: Click-to-move cursor

**Source:** Ghostty 1.3, WezTerm

**What already exists:**
- `mouseDown` in `HarnessTerminalSurfaceView+Mouse.swift`
- `cellSizePoints()` — pixel → grid conversion
- PTY write path — `write(data:)` on surface

**What's missing:** convert click coords → cursor motion escape sequence, send to PTY

**Files to touch:**
| File | Change |
|---|---|
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Mouse.swift` | In `mouseDown`: if `!hasSelection`, compute target (row,col) from click → send `\x1b[<row>;<col>H` or relative hjkl sequence |

**Guard:** only send if PTY app supports cursor positioning (check `$TERM` has `cup` capability). Disable if app has own mouse handler (detect via terminal mouse mode flag).

**Minimum code:** ~20 lines.

**Success criteria:** click anywhere in prompt line → cursor jumps to that position.

---

## Phase 6: Auto Secure Input

**Source:** Otty

**What already exists:**
- macOS Secure Input API — `EnableSecureEventInput()` / `DisableSecureEventInput()` in AppKit
- PTY output observer — shell integration already monitors prompt events

**What's missing:** heuristic to detect password prompt in PTY stream → auto-toggle secure input

**Files to touch:**
| File | Change |
|---|---|
| `HarnessTerminalKit/.../SecureInputMonitor.swift` | NEW — monitor PTY output for password prompt pattern (`password:`, `passphrase:`, hidden input escape `\x1b[8m`) → call `EnableSecureEventInput()` / `DisableSecureEventInput()` |
| `Apps/Harness/Sources/HarnessApp/AppDelegate.swift` | Wire `SecureInputMonitor.shared` to active surface lifecycle |

**Pattern to detect:** `[Pp]assword`, `[Pp]assphrase`, `Enter PIN`, `sudo:`, ESC `[8m` (conceal mode)

**Success criteria:** `sudo command` → password prompt appears → secure input auto-enables → password hidden from screen capture apps → prompt returns → secure input releases.

---

## Phase 7: Context-aware keybindings

**Source:** Ghostty "Performable Keybindings" (v1.2.0)

**What already exists:**
- `KeybindingsService` + `KeyTableSet` — key dispatch infrastructure
- `currentSelectionRegion` — selection state accessible

**What's missing:** before firing action, check whether the action is "performable" given current state

**Files to touch:**
| File | Change |
|---|---|
| `HarnessCore/.../KeybindingsService.swift` | Add `canPerform(action:in:context:) -> Bool` guard; wrap dispatch in check |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Input.swift` | Pass context (hasSelection, hasFocus, cursorAtEnd) to `canPerform` |

**Key examples:**
- `Ctrl+C` → copy if selection active, else send interrupt to PTY
- `Cmd+K` → clear scrollback if no selection, else cut
- `Enter` → insert newline in Composer, submit in search bar, send to PTY in normal mode

**Minimum code:** ~40 lines — context struct + guard clause.

---

## Phase 8: Composer (multi-line command editor)

**Source:** Otty (⌘⇧E), concept similar to Warp block editor

**What already exists:**
- `NSTextView` — standard AppKit, no new dep
- PTY write path — `write(data:)` on surface

**What's missing:** slide-up panel with multi-line editor, submit → write to PTY

**Files to touch:**
| File | Change |
|---|---|
| `UI/Shared/ComposerPanel.swift` | NEW — `NSPanel` subclass, `NSTextView` with syntax hints, `Cmd+Enter` = submit → `surface.write(text + "\n")` |
| `UI/Chrome/MainMenuBuilder.swift` | Add "Composer" `Cmd+Shift+E` |

**Success criteria:** `Cmd+Shift+E` → panel slides up → type multi-line command → `Cmd+Enter` → command sent to PTY → panel closes.

---

## Phase 9: Prompt Queue

**Source:** Otty

**What already exists:**
- Shell integration — knows when PTY shows a fresh prompt (OSC 133 `A` = prompt start, `B` = prompt end, `C` = command start, `D` = command end)
- PTY write path

**What's missing:** queue data structure + fire-next-on-fresh-prompt observer

**Files to touch:**
| File | Change |
|---|---|
| `HarnessTerminalKit/.../PromptQueue.swift` | NEW — FIFO queue, subscribe to shell integration `commandDidFinish` → dequeue + write next |
| `UI/Shared/PromptQueueBar.swift` | NEW — thin status bar showing queue length + cancel button |
| `UI/Chrome/MainMenuBuilder.swift` | "Add to Queue" `Cmd+Shift+Return` |

**Success criteria:** add 3 commands to queue → each runs after previous completes → status bar shows remaining count → cancel clears queue.

---

## Phase 10: Quick Terminal (hotkey dropdown)

**Source:** Ghostty Quick Terminal, iTerm2 Visor

**What already exists:**
- `NSPanel` — standard AppKit
- `NSEvent.addGlobalMonitorForEvents` — global hotkey already used elsewhere

**What's missing:** a dedicated `NSPanel` window that animates down from menu bar on global hotkey

**Files to touch:**
| File | Change |
|---|---|
| `Apps/Harness/Sources/HarnessApp/UI/QuickTerminal/QuickTerminalController.swift` | NEW — `NSPanel` (nonactivating, floats above all), animate slide-down/up, spawn single `HarnessTerminalSurfaceView` |
| `Apps/Harness/Sources/HarnessApp/AppDelegate.swift` | Register global hotkey `⌥Space` (configurable) → toggle `QuickTerminalController` |
| `Settings/SettingsViewController+General.swift` | Quick Terminal hotkey setting |

**Success criteria:** press `⌥Space` anywhere → terminal panel slides down from top of screen → press again or `Esc` → slides back up.

---

## Phase 11: Recipes (saved commands/layouts/snippets)

**Source:** Otty Recipes, Warp Drive

**What already exists:**
- `LayoutDescriptor` / session restore — layout serialization exists
- `CommandPaletteController` — fuzzy picker UI reusable

**What's missing:** persistent store of named commands + picker to insert/run them

**Files to touch:**
| File | Change |
|---|---|
| `HarnessCore/.../RecipesStore.swift` | NEW — `[Recipe]` JSON in `~/Library/Application Support/Harness/recipes.json`, CRUD |
| `UI/Shared/RecipePickerController.swift` | NEW — reuse `CommandPaletteController` UI, shows recipe list, on select → paste or run |
| `UI/Chrome/MainMenuBuilder.swift` | "Recipes…" `Cmd+Shift+R` |
| `Settings/SettingsViewController+Recipes.swift` | Manage/edit recipes list |

**Recipe schema:**
```json
{ "id": "uuid", "name": "Start dev server", "command": "npm run dev", "runImmediately": true }
```

**Success criteria:** save a recipe → `Cmd+Shift+R` → fuzzy find → select → command runs in active pane.

---

## Phase 12: Block-based output

**Source:** Warp

**What already exists:**
- Shell integration OSC 133 — already marks command start/end boundaries
- `TerminalBuffer` — rows addressable

**What's missing:** render boundary markers as visual block separators, allow block-level selection/copy/share

**Files to touch:**
| File | Change |
|---|---|
| `HarnessTerminalKit/.../BlockRenderer.swift` | NEW — maintain list of (startRow, endRow, command) from OSC 133 events; render subtle bg tint per block |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Mouse.swift` | Triple-click or `Cmd+Click` on block → select entire block output |
| `UI/Shared/BlockActionBar.swift` | NEW — ephemeral popover on block select: Copy, Share, AI explain |

**Success criteria:** each command's output has distinct background; click block → copy entire output; "AI explain" sends block to AI chat.

---

## Phase 13: Kitty Graphics Protocol

**Source:** Ghostty, WezTerm, Kitty

**What already exists:**
- Metal rendering layer
- PTY stream parser

**What's missing:** parse Kitty graphics APC escape `\x1b_G...ST`, decode base64 PNG/JPEG, render as Metal texture in cell grid

**Files to touch:**
| File | Change |
|---|---|
| `HarnessTerminalKit/.../KittyGraphicsParser.swift` | NEW — parse `APC G` escape sequences, decode chunked base64 image data |
| `HarnessTerminalKit/.../KittyGraphicsRenderer.swift` | NEW — allocate `MTLTexture` per image ID, blit into cell region during Metal render pass |
| `HarnessTerminalKit/.../TerminalStreamParser.swift` | Route `\x1b_` (APC) sequences to `KittyGraphicsParser` |

**Note:** large effort — implement basic `a=T` (transmit) + `a=p` (put/display) only; skip animation and virtual placement initially. `ponytail: defer until there's actual user demand for inline images.`

---

## Phase 14: Floating panes

**Source:** Zellij

**What already exists:**
- `SplitTree` — current pane layout is a split tree
- `HarnessTerminalSurfaceView` — pane views

**What's missing:** a pane that lives outside the split tree, rendered as a draggable overlay NSWindow/NSPanel

**Files to touch:**
| File | Change |
|---|---|
| `HarnessTerminalKit/.../FloatingPaneController.swift` | NEW — `NSPanel` (child window), hosts one `HarnessTerminalSurfaceView`, user-resizable/draggable |
| `UI/Chrome/MainMenuBuilder.swift` | "New Floating Pane" `Cmd+Shift+F` |
| `Apps/Harness/Sources/HarnessApp/WindowController.swift` | Track floating panels for session restore |

**Success criteria:** open floating pane → drag anywhere → runs independent PTY → toggle hide/show with keybinding → persists across session restore.

---

## Phase 15: Tab thumbnails overview

**Source:** Ghostty

**What already exists:**
- `TabBarController` — manages tabs
- Metal rendering — can render terminal to offscreen texture

**What's missing:** render each tab's terminal to a thumbnail texture → display grid overlay

**Files to touch:**
| File | Change |
|---|---|
| `UI/Shared/TabOverviewController.swift` | NEW — `NSCollectionView` grid, each cell = offscreen render of tab's surface, click → switch tab |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Thumbnail.swift` | NEW — `renderThumbnail(size:) -> NSImage` using offscreen Metal pass |
| `UI/Chrome/MainMenuBuilder.swift` | "Tab Overview" `Cmd+Shift+\` |

**Success criteria:** `Cmd+Shift+\` → grid of tab thumbnails → click any → jumps to that tab.

---

## Files Created / Modified Summary

### Original 3 features
| File | Type | Feature |
|---|---|---|
| `UI/Shared/HintModeOverlay.swift` | NEW | Hint mode |
| `UI/AIChat/AITerminalChatController.swift` | MODIFY | Send to chat |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+SelectionAndLinks.swift` | MODIFY | Send to chat + Hint mode |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+ViMode.swift` | NEW | Vi mode |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Input.swift` | MODIFY | Vi mode |
| `UI/Chrome/MainMenuBuilder.swift` | MODIFY | All (menu items) |
| `HarnessCore/.../BannerShortcutRegistry.swift` | MODIFY | Hint mode keybinding |
| `Settings/SettingsViewController+Terminal.swift` | MODIFY | Vi mode toggle |

### New 12 features
| File | Type | Feature |
|---|---|---|
| `UI/Shared/ScrollbackSearchBar.swift` | NEW | #4 Scrollback Search |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Search.swift` | NEW | #4 Scrollback Search |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Mouse.swift` | MODIFY | #5 Click-to-move |
| `HarnessTerminalKit/.../SecureInputMonitor.swift` | NEW | #6 Auto Secure Input |
| `HarnessCore/.../KeybindingsService.swift` | MODIFY | #7 Context-aware keys |
| `UI/Shared/ComposerPanel.swift` | NEW | #8 Composer |
| `HarnessTerminalKit/.../PromptQueue.swift` | NEW | #9 Prompt Queue |
| `UI/Shared/PromptQueueBar.swift` | NEW | #9 Prompt Queue |
| `UI/QuickTerminal/QuickTerminalController.swift` | NEW | #10 Quick Terminal |
| `HarnessCore/.../RecipesStore.swift` | NEW | #11 Recipes |
| `UI/Shared/RecipePickerController.swift` | NEW | #11 Recipes |
| `HarnessTerminalKit/.../BlockRenderer.swift` | NEW | #12 Block output |
| `UI/Shared/BlockActionBar.swift` | NEW | #12 Block output |
| `HarnessTerminalKit/.../KittyGraphicsParser.swift` | NEW | #13 Kitty Graphics |
| `HarnessTerminalKit/.../KittyGraphicsRenderer.swift` | NEW | #13 Kitty Graphics |
| `HarnessTerminalKit/.../FloatingPaneController.swift` | NEW | #14 Floating panes |
| `UI/Shared/TabOverviewController.swift` | NEW | #15 Tab thumbnails |
| `HarnessTerminalKit/.../HarnessTerminalSurfaceView+Thumbnail.swift` | NEW | #15 Tab thumbnails |

**Total estimate:** ~1,500 lines new code across 25+ files. No new external dependencies (Kitty Graphics uses Metal + existing PTY parser).

---

## Open Questions (decide before starting each phase)

| # | Question | Default |
|---|---|---|
| 1 | Hint mode keybinding? | `Cmd+Shift+U` (U = URL) |
| 2 | Hint mode opens in browser pane or system browser? | Reuse existing `openLink()` logic |
| 3 | Vi mode per-session toggle or global? | Global toggle in Settings first |
| 4 | Vi mode status shown in status bar? | Yes — `[N]` / `[I]` badge |
| 5 | Send to chat keybinding? | `Cmd+Shift+A` optional, context menu sufficient |
| 6 | Scrollback search highlight color? | Accent color with 40% opacity |
| 7 | Click-to-move — require modifier key (Option+click) to avoid accident? | Yes, `Option+click` |
| 8 | Quick Terminal hotkey? | `⌥Space` (configurable in Settings) |
| 9 | Quick Terminal — own PTY or mirror last active pane? | Own independent PTY |
| 10 | Block output — shell integration required or opt-in? | Require shell integration (OSC 133) |
| 11 | Recipes — sync via iCloud? | Local only first, iCloud later |
| 12 | Kitty Graphics — defer until user demand? | Yes, `ponytail: skip until requested` |
