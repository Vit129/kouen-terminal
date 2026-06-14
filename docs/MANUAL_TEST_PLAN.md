# Manual Test Plan — P4 / P11 / P12 / P13 / P16

> Run with `make preview`. All tests use the isolated preview instance.
> Mark each test ✅ PASS / ❌ FAIL / ⚠️ PARTIAL with notes.

---

## P4 — Terminal-First LSP & File View

### Track 1: Syntax Highlighting

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 4.1.1 | Swift highlighting | File tree → click any `.swift` file | Keywords (func/class/let) colored, strings green, comments gray |
| 4.1.2 | JSON highlighting | Open `Package.resolved` | Keys vs values distinguished |
| 4.1.3 | Binary file guard | Open a `.dmg` or image file | Shows "Binary file" placeholder, no crash |
| 4.1.4 | Large file guard | Terminal: `dd if=/dev/zero of=/tmp/bigfile.txt bs=1M count=2` → file tree → open | Shows size warning, doesn't freeze |

### Track 2: Vi Navigation (gf/gd/K/]d/[d)

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 4.2.1 | `gf` opens path | Open a Swift file in editor → cursor on `import HarnessCore` → Normal Mode (press Esc) → `gf` | Navigates to HarnessCore source or shows "gf: no path under cursor" |
| 4.2.2 | `gf` with line suffix | Cursor on text like `file.swift:42:10` → `gf` | Opens `file.swift`, strips `:42:10` suffix |
| 4.2.3 | `gf` no path | Cursor on blank line → `gf` | Shows "gf: no path under cursor" in status bar |
| 4.2.4 | `gd` with LSP | Open Swift file → cursor on function call (e.g. `SessionCoordinator.shared`) → `gd` | Jumps to definition (if sourcekit-lsp running) or attempts gf fallback |
| 4.2.5 | `gd` no LSP | Open a `.txt` file → `gd` | Shows "gd: no definition" — no crash |
| 4.2.6 | `K` hover | Cursor on type name → `K` | Shows type signature in status bar |
| 4.2.7 | `K` no LSP | No LSP active → `K` | Shows "K: no hover" |
| 4.2.8 | `]d` / `[d` | File with LSP diagnostics → `]d` cycles through errors | Cursor jumps to each diagnostic, wraps at end with status |
| 4.2.9 | `]d` empty | File with 0 diagnostics → `]d` | Shows "no diagnostics" — no crash |

### Track 2: Ex Commands (`:view`/`:edit`/`:split`/`:find`)

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 4.2.10 | `:view <path>` | In vi normal mode, type `:view Package.swift` Enter | Opens in read-only file viewer (sidebar) |
| 4.2.11 | `:edit <path>` | `:edit Package.swift` | Opens in editor panel |
| 4.2.12 | `:split <path>` | `:split README.md` | New terminal split opens with `$EDITOR README.md` |
| 4.2.13 | `:vsplit <path>` | `:vsplit README.md` | Vertical split with editor |
| 4.2.14 | `:find <query>` | `:find appdelegate` | Fuzzy matches, opens top match or shows ranked list |
| 4.2.15 | `:find` no match | `:find xyznonexistent` | Shows "no matches" status |
| 4.2.16 | `:view <partial>` | `:view syntax` | Fuzzy resolves to SyntaxTextView or similar |

### Track 3: CLI (`harness lsp` / `harness view`)

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 4.3.1 | `harness view` | Terminal: `harness view README.md` | Prints file content to stdout |
| 4.3.2 | `harness view` binary | `harness view Harness.dmg` | Shows binary guard message |
| 4.3.3 | `harness lsp start` | `harness lsp start` in project root | Prints JSON status with detected server |
| 4.3.4 | `harness lsp status` | `harness lsp status` | Reports server state |
| 4.3.5 | `harness lsp hover` | `harness lsp hover Package.swift:5:8` | Returns hover info or "no info" |
| 4.3.6 | `harness lsp definition` | `harness lsp definition <file>:<line>:<col>` | Returns location or empty |
| 4.3.7 | `harness lsp diagnostics` | `harness lsp diagnostics <file>` | Lists diagnostics or empty |

---

## P11 — Scripting & Config API (JavaScriptCore)

### Config Discovery

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 11.1 | Default config path | Create `~/.config/harness/init.js` with `harness.log("loaded")` → restart preview | Console/log shows "loaded" |
| 11.2 | XDG override | Set `XDG_CONFIG_HOME=/tmp/xdg`, create `/tmp/xdg/harness/init.js` → restart | Uses XDG path |
| 11.3 | HARNESS_CONFIG_FILE | `export HARNESS_CONFIG_FILE=/tmp/test.js` → restart | Uses that file |
| 11.4 | No config | Remove all config files → restart | No error, app starts normally |

### Runtime API

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 11.5 | `harness.version` | `init.js`: `harness.toast(harness.version)` | Toast shows current version |
| 11.6 | `harness.log()` | `harness.log("hello")` in init.js | Appears in console/debug output |
| 11.7 | `harness.toast()` | `harness.toast("test")` | Toast notification appears |
| 11.8 | `harness.sessions` | `harness.log(JSON.stringify(harness.sessions))` | Logs array of session objects |
| 11.9 | `harness.panes` | `harness.log(JSON.stringify(harness.panes))` | Logs array of pane objects |
| 11.10 | `harness.commands.parse` | `harness.commands.parse("split-window -h")` | Returns parsed command object |

### File Watcher Reload

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 11.11 | Hot reload | Edit `init.js` while app running → save | Script re-executes (verify via toast/log change) |
| 11.12 | Syntax error | Introduce a syntax error in `init.js` → save | Previous good runtime kept, error logged, no crash |

---

## P12 — Agent Orchestration via MCP

> Requires MCP client connection. Test with `harness-mcp` stdio or a compatible client.

### Read-Only Tools

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 12.1 | `harnessList` | Call via MCP | Returns workspaces/sessions/tabs/panes JSON |
| 12.2 | `readPaneOutput` | Open a session, run `echo hello` → MCP `readPaneOutput` | Contains "hello" in output |
| 12.3 | `harnessBoard` | Call via MCP | Returns board columns (Running/Idle/etc.) |

### Mutating Tools (require HARNESS_MCP_ALLOW_CONTROL=1)

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 12.4 | `sendPaneText` denied | Without env var → MCP `sendPaneText` | Denied with policy error |
| 12.5 | `sendPaneText` allowed | With `HARNESS_MCP_ALLOW_CONTROL=1` → send "ls\n" | Text appears in pane |
| 12.6 | `spawnSession` | MCP `spawnSession` | New session created, returned in subsequent `harnessList` |
| 12.7 | `splitPane` | MCP `splitPane` on active pane | Split created |
| 12.8 | `closePane` | MCP `closePane` | Pane closed |
| 12.9 | `waitForPaneOutput` | Send "echo DONE" → `waitForPaneOutput` matching "DONE" | Resolves with matching output |

### Tool Policy

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 12.10 | Default policy | No env var → any mutating tool | Rejected |
| 12.11 | Explicit allow | `HARNESS_MCP_ALLOW_CONTROL=1` → mutating tool | Allowed |

---

## P13 — Split Pane Parity

### Creating Splits

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 13.1 | Split right (⌘D) | Press ⌘D | New pane appears to the right |
| 13.2 | Split down (⌘⇧D) | Press ⌘⇧D | New pane appears below |
| 13.3 | Menu "Split Right" | Menu → Split Right | Same as ⌘D |
| 13.4 | Menu "Split Down" | Menu → Split Down | Same as ⌘⇧D |
| 13.5 | Command `:split-window -h` | In prefix/command mode | Side-by-side split |
| 13.6 | Command `:split-window -v` | In prefix/command mode | Top/bottom split |

### Navigating Splits

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 13.7 | Focus left/right/up/down | Create 2x2 grid → use prefix + arrows | Focus moves correctly |
| 13.8 | ⌘[ / ⌘] | Multiple panes → ⌘] | Cycles to next pane |

### Resizing

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 13.9 | Resize horizontal | Drag divider between side-by-side panes left/right | Smooth resize, text wraps properly, no flicker |
| 13.10 | Resize vertical | Drag divider between top/bottom panes up/down | Smooth resize, no text cutoff |
| 13.11 | `resize-pane -R 5` | Command after split | Pane grows 5 cells right, text visible (byTruncatingTail) |

### Closing

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 13.12 | Close pane (⌥⇧⌘W) | Focus a split pane → ⌥⇧⌘W | Pane closes, sibling fills space |
| 13.13 | Close last pane | Only one pane left → close | Tab closes (or new shell spawns) |

### Edge Cases

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 13.14 | Nested splits | Split right → focus right pane → split down | 3 panes: left, top-right, bottom-right |
| 13.15 | Session reattach | Create splits → quit → reopen | Same split layout restored |

---

---

## Mock Data Setup (for P16 + others)

### Quick Test Session Setup
```bash
# Terminal 1: Create workspace with long-running job
cd /tmp
harness attach my-workspace
sleep 100 &

# Terminal 2: Create second workspace that completes quickly
harness attach test-workspace  
exit  # → will show "Done" status in Board

# Terminal 3: Pane with error
harness attach error-workspace
false  # → exit code 1, shows "Error" in Board
```

---

## P16 — Agent/Session Board

### GUI Board Tab

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 16.1 | Board tab visible | Sidebar → Board tab | Shows Kanban columns (Running/Idle/Done/Error) |
| 16.2 | Columns populated | Have 3+ sessions from mock-up (one idle, one long-running, one exited) | Cards appear in correct columns |
| 16.3 | Card click | Click a "Running" card in the board | Focuses that session/pane in main terminal |
| 16.4 | Live update | Start a long-running command (e.g. `sleep 60`) from Terminal 1 | Card moves to "Running" column immediately |
| 16.5 | Command completes | In Terminal 2: `exit 0` → watch Board | Card moves to "Done" column |
| 16.6 | Exit error | In Terminal 3: `false` (exit 1) → watch Board | Card moves to "Error" column (red) |
| 16.7 | Agent detection | Start Claude Code or similar in a pane | Card shows agent type icon + "Needs Attention" column if agent waiting |
| 16.8 | Notifications (⌘⇧U) | Trigger agent notification (pane enters "Needs Attention") → ⌘⇧U | Dropdown shows notification with Board card link |

### CLI Board

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 16.7 | `harness board` | Run in terminal | Prints text-table with columns |
| 16.8 | `harness board --watch` | Run → start/stop commands in other panes | Table updates live |

### Scripting Board

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 16.9 | `harness.board.list()` | In `init.js`: `harness.log(JSON.stringify(harness.board.list()))` | Logs board state array |

### MCP Board

| # | Test | Steps | Expected |
|---|------|-------|----------|
| 16.10 | `harnessBoard` tool | Call via MCP client | Returns board JSON with columns |

---

## Cross-Feature Integration

| # | Test | Steps | Expected |
|---|------|-------|----------|
| X.1 | Split + LSP | Split right → open Swift file in editor → `gd` | Definition navigates correctly in split |
| X.2 | Board + Split | Create multiple splits → check Board | Board shows correct pane count |
| X.3 | Script + Board | `init.js` calls `harness.board.list()` on session change | Returns updated state |
| X.4 | MCP + Split | MCP `splitPane` → MCP `harnessList` | New pane visible in list |

---

## Smoke Test Checklist (quick daily check)

- [ ] `make preview` launches without crash
- [ ] Open file in file tree → syntax highlighted
- [ ] `gf` on an import line → navigates
- [ ] ⌘D splits right, ⌘⇧D splits down
- [ ] Board tab shows sessions
- [ ] `harness board` prints columns
- [ ] Edit `~/.config/harness/init.js` → hot reloads
- [ ] Close all splits → no orphan views

---

## Thai Translation / การแปลเป็นภาษาไทย

| English | ไทย |
|---------|-----|
| Split right (⌘D) | แยกขวา |
| Split down (⌘⇧D) | แยกลง |
| Resizing | ปรับขนาด |
| Text truncation | ตัดคำ |
| Board columns (Running/Idle/Done/Error) | คอลัมน์บอร์ด (กำลังทำ/ไม่ใช้งาน/เสร็จ/ผิดพลาด) |
| Notification dropdown (⌘⇧U) | DropDown การแจ้งเตือน |
| Mock data setup | ตั้งค่าข้อมูลทดสอบ |
| Agent waiting | Agent รอสัั่ง |
| Go to definition | ไปยังคำนิยาม |
| Syntax highlighting | เน้นไวยากรณ์ |
