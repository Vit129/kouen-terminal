# Harness

A native macOS terminal that keeps your sessions running, brings your editor tools with you, and tells you the moment a coding agent needs you.

Everything is first-party Swift — the GPU terminal engine, session daemon, and CLI. The only external dependency is Sparkle for auto-updates.

---

## Why Harness

**Terminal first.** GPU Metal renderer with accurate sRGB color, 490 built-in themes, inline images (Sixel/Kitty/iTerm2), ligatures, and procedural box-drawing. Your sessions live in a background daemon — quit the app, reopen it, everything is exactly where you left it. Attach the same session from a second window or a remote machine over SSH.

**vi power user.** The file editor has a full vi normal mode — motions, operators, text objects, marks, registers, macros, jump list, and `:` ex commands. Open files with `:e`, navigate buffers with `:bn`/`:bp`, substitute with `:%s`, set relative numbers with `:set relativenumber`. Feel at home if you live in vim.

**tmux compatible.** Prefix keymap, copy mode, `send-keys`, `capture-pane`, `pipe-pane`, `select-layout`, `synchronize-panes`, format strings, hooks — the full command set. Import `.tmux.conf` with `source-file`. Options: `word-separators`, `wrap-search`, `window-size`, `destroy-unattached`, `clear-history`.

**IDE convenient.** A sidebar (`Cmd+\`) houses a file tree with keyboard navigation (j/k/h/l/Enter), a real-time Git panel (stage, commit, push, history, worktrees), and an LSP-powered file editor (hover, go-to-definition, diagnostics). Everything is in the terminal window — no app switching.

**Agent aware.** Harness watches the agents running inside it (Claude Code, Codex, Cursor, and more), alerts you when one stops or needs approval, and lets you jump straight to it with `Cmd+Shift+U`.

---

## Quick start

```bash
make run          # build + sign + open Harness.app
make preview      # isolated preview build (separate daemon socket)
swift build       # compile all targets
swift test        # run test suite
```

Or [download the signed DMG](https://github.com/Vit129/harness-terminal/releases/latest) and drag to Applications.

**Requirements:** Apple silicon Mac, macOS 15+. (Daemon + CLI also build headless on Linux.)

---

## Features

### Terminal engine
- Metal renderer — sRGB default, opt-in Display P3 vivid color
- 490 built-in themes + `.harnesstheme` import/export
- Inline images: Sixel, Kitty, iTerm2
- Ligatures, procedural box-drawing glyphs (no seams at any font size)
- Live re-wrap on resize with grid-size overlay
- Word/line/block/rectangle selection; middle-click paste; alternate-screen scrolling
- Shell integration (OSC 133): prompt marks, jump-to-prompt, success/fail gutter
- Auto light/dark theme switching; minimum contrast; hollow unfocused cursor

### Sessions & daemon
- Sessions, tabs, and splits owned by a background daemon — survive quit and relaunch
- Scrollback persisted to disk per surface, restored on daemon restart
- Remote daemon: `harness-cli --host devbox` via SSH tunnel (`harness-cli remote add`)
- Experience modes: **Plain** (no prefix, closes on quit) → **Persistent** → **Full** → **Agent Workspace**

### Split panes (CMUX)
- Binary-tree pane model, N-ary flatten, drag-to-split with live drop overlays
- Layout presets `Cmd+Opt+1–5`: Even Horizontal, Even Vertical, Main Horizontal, Main Vertical, Tiled
- Pane-local surface tabs, zoom pane, synchronize panes
- Layouts persist across restarts

### File tree
- FSEvents live-watch with 500ms debounce
- Git status colors on every entry
- **Keyboard navigation:** j/k move cursor, h/l collapse/expand folder, Enter/o open/preview, g/G first/last, Ctrl+d/u half-page, `/` focus filter
- Context menu: new file, reveal in Finder, copy path, delete

### File editor + vi mode
- 20+ language syntax highlighting
- **Full vi normal mode** — all motions (hjkl wWbBeE 0^$ gg/G {}/% H/M/L f/F/t/T), operators (d/c/y + motion + text objects), visual mode (v/V), marks (`ma`/`'a`/`` `a ``), named registers (`"ayy`/`"ap`), macros (`qa`…`q` / `@a`), jump list (Ctrl+o/Ctrl+i), count prefix
- **Text objects:** `iw`/`aw`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`, `ip`/`ap`, `is`/`as`
- **Ex commands:** `:w` `:q` `:wq` `:N` `:s/old/new/g` `:%s` `:noh` `:set number/relativenumber/hlsearch` `:e <file>` `:bn`/`:bp`/`:ls` `:set wrap/ignorecase`
- **Inline `*`/`#` search highlight** — all matches highlighted; `:noh` clears
- **LSP:** hover tooltip, go-to-definition (⌘+click), diagnostics underline — Swift, TypeScript, Python (pyright), Rust (rust-analyzer), Go (gopls) — auto-detected by project markers
- Git diff gutter (added/modified/deleted bars per line)
- Find/replace, vi-mode, drag-to-resize editor/terminal split

### Git panel
- **Changes** — stage/unstage per file, Stage All, commit (amend, signoff), +N -M counts per file
- **Sync** — Fetch/Pull/Push with per-remote options
- **History** — click commit → file list + diff with syntax coloring; right-click for Copy ID/Message/Show Diff
- **Worktrees** — add/remove `git worktree` entries; adding one opens a new session tab automatically
- FSEvents recursive watcher, 500ms debounce — reflects every commit, stage, and checkout instantly

### tmux compatibility
Full tmux command set: `send-keys`, `capture-pane`, `pipe-pane`, `kill-pane`, `zoom-pane`, `select-pane`, `select-layout`, `rotate-window`, `break-pane`, `join-pane`, `synchronize-panes`, `if-shell`, `run-shell`, `wait-for`, `source-file`, `set-option`, `bind-key`, `display-message`, `command-prompt`, `choose-*`, `find-window`, and more.

Options: `word-separators`, `wrap-search`, `window-size` (smallest/largest/latest), `destroy-unattached`, `clear-history`, `remain-on-exit`, `base-index`, `repeat-time`, `monitor-activity`, `monitor-silence`, `pane-border-status`, and the full format-string `#{…}` set.

`source-file ~/.tmux.conf` parses bind/set/setenv lines as-is. Import your existing config.

```bash
list-sessions -F "#{session_name}: #{session_windows} windows"
list-panes --json
clear-history
resize-window -x 220 -y 50
```

### Command palette (`Cmd+K`)
- Fuzzy session/tab switch
- File quick-open (background enumeration, no stutter)
- Switch Project — open tabs' CWDs + zoxide frecency list
- Workspace symbol search (functions, classes, variables) → send to terminal

### Agent system
Passive process-tree scan detects: Claude Code, Codex, Cursor, Grok, Pi, Hermes, OpenClaw, OpenCode, Aider, Gemini, Goose, and more — each with brand color + sidebar chip.

- Desktop banner + sidebar bell when agent stops or needs input
- `Cmd+Shift+U` jumps to the waiting agent
- `harness-cli install-hooks <agent>` one-line hook setup

---

## Keyboard shortcuts

| Action | Key |
|--------|-----|
| New tab | `Cmd+T` |
| New session | `Cmd+Shift+N` |
| Close tab | `Cmd+W` |
| Split right | `Cmd+D` |
| Toggle sidebar | `Cmd+\` |
| Toggle IDE mode | `Cmd+Shift+D` |
| Command palette | `Cmd+K` |
| Search command history | `Ctrl+R` |
| Jump to waiting agent | `Cmd+Shift+U` |
| Switch session 1–9 | `Cmd+1` … `Cmd+9` |
| Layout presets | `Cmd+Opt+1–5` |
| Settings | `Cmd+,` |

Command prefix (default `Ctrl-A`): press prefix then `?` for the full cheatsheet.

---

## harness-cli

```bash
harness-cli list-surfaces
harness-cli new-session --workspace Default --cwd ~/Code/myproject
harness-cli send-keys --surface "$HARNESS_SURFACE" --keys "ls -la Enter"
harness-cli capture-pane --surface "$HARNESS_SURFACE"
harness-cli notify --surface "$HARNESS_SURFACE" --title Agent --body "Needs approval"
harness-cli remote add devbox user@devbox.example.com
harness-cli --host devbox list-surfaces
harness-cli color-check
harness-cli theme-preview --theme "Harness Default"
```

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 6 (strict concurrency throughout) |
| GUI | AppKit + Metal |
| Terminal engine | First-party VT parser + screen/grid model |
| Renderer | CoreText + Metal glyph atlas, sRGB/P3 |
| IPC | Unix-domain sockets, length-prefixed JSON + binary PTY frames |
| Auto-update | Sparkle (macOS only, EdDSA signatures) |
| Platforms | macOS 15+ (GUI), Linux (daemon + CLI headless) |

---

## Build from source

```bash
git clone https://github.com/Vit129/harness-terminal
cd harness-terminal
make run            # builds, signs, and opens Harness.app
```

Requires Xcode 16+ / Swift 6.0. The daemon and CLI (`swift build --product HarnessDaemon`, `swift build --product harness-cli`) also build on Linux without Xcode.

---

## Documentation

- [Experience modes](docs/MODES.md)
- [tmux parity ledger](docs/TMUX_PARITY.md) — capability status, adaptations, explicitly rejected features
- [tmux capabilities guide](docs/HARNESS_TMUX_CAPABILITIES.md)
- [Commands reference](docs/COMMANDS.md)
- [Keybindings](docs/KEYBINDINGS.md)
- [Shell integration](docs/shell-integration/README.md)
- [Agent hooks](docs/agent-hooks/README.md)
- [Migration](docs/MIGRATION.md)
- [Release runbook](docs/RELEASE.md)
- [Changelog](CHANGELOG.md)

---

## License

MIT
