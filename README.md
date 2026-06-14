# Harness

> Forked from [robzilla1738/harness-terminal](https://github.com/robzilla1738/harness-terminal)

A native macOS terminal for every kind of developer — terminal purist, vi power user, IDE user, or AI agent operator. Sessions run in a background daemon so nothing is ever lost.

Everything is first-party Swift — GPU terminal engine, session daemon, CLI, MCP server. One external dependency: Sparkle for auto-updates.

---

## Why Harness

**Terminal first.** Metal GPU renderer, 490 themes, inline images, ligatures. Split panes side-by-side or stacked (`Cmd+D` / `Cmd+Shift+D`). Sessions live in a background daemon — quit and reopen and everything is exactly where you left it. Attach from a second window or remote machine over SSH.

**vi power user.** Full vi normal mode in the file editor — motions, operators, text objects, marks, registers, macros, jump list, `:` ex commands (`:w` `:q` `:s/old/new/g` `:%s` `:set relativenumber` `:e file` `:find` `:split` `:vsplit`). `gf` open path under cursor, `gd` go-to-definition, `K` hover, `]d`/`[d` diagnostic jump. Inline `*` search highlight.

**tmux compatible.** Prefix keymap, copy mode, `word-separators`, `wrap-search`, `window-size`, `destroy-unattached`, format strings, hooks, `source-file ~/.tmux.conf`. Full command set including `list-sessions -F "#{session_name}"`.

**IDE convenient.** Sidebar (`Cmd+\`): file tree with keyboard nav (j/k/h/l/Enter), real-time Git panel (stage, commit, push, history, worktrees), LSP-powered file editor (hover, go-to-definition, diagnostics). `Cmd+K` command palette with file quick-open, Switch Project (+ zoxide), symbol search.

**Agent aware.** Detects Claude Code, Codex, Cursor, and 10+ more. Desktop alerts + `Cmd+Shift+U` jump to whoever's waiting. Kanban-style Board sidebar tab and `harness board` CLI organize live sessions by status (Running / Needs Attention / Idle / Done).

**Scriptable.** WezTerm-style JavaScript config at `~/.config/harness/init.js` — `harness.toast()`, `harness.sessions`, `harness.panes`, `harness.board.list()`, `harness.commands.parse()`. Live reload on save.

**MCP server.** `harness-mcp` exposes pane/session control to any MCP-compatible agent: list sessions, read output, send keys, spawn sessions, split panes, wait for output. Read-only by default; set `HARNESS_MCP_ALLOW_CONTROL=1` to enable mutating tools.

---

## Quick start

```bash
make preview      # isolated preview (separate daemon socket)
make debug        # alias for make preview
make prod         # repo-root production build, no /Applications copy
swift build       # compile all targets
swift test        # run tests
```

[Download signed DMG →](https://github.com/Vit129/harness-terminal/releases/latest) · Requires Apple silicon, macOS 15+

---

## CLI

```bash
harness view <file>                        # syntax-highlighted file view
harness lsp start / status                 # language server lifecycle
harness lsp hover <file>:<line>:<col>      # hover info
harness lsp definition <file>:<line>:<col> # go-to-definition
harness lsp diagnostics <file>             # diagnostics list
harness board                              # session board (text table)
harness board --watch                      # live-updating board
harness attach <session>                   # attach to session
harness send-keys <session> <keys>         # send keys to pane
harness capture-pane <session>             # capture pane output
```

---

## Stack

| | |
|--|--|
| Language | Swift 6, strict concurrency |
| GUI | AppKit + Metal |
| Terminal | First-party VT parser, CoreText/Metal renderer |
| IPC | Unix sockets, length-prefixed JSON + binary PTY frames |
| Scripting | JavaScriptCore (built-in, no dependency) |
| MCP | stdio JSON-RPC 2.0 (`harness-mcp`) |
| Platforms | macOS 15+ (GUI), Linux (daemon + CLI headless) |

---

## Build from source

```bash
git clone https://github.com/Vit129/harness-terminal
cd harness-terminal
make preview
```

Requires Xcode 16+ / Swift 6.0. Daemon and CLI also build on Linux: `swift build --product HarnessDaemon`.

---

## Docs

[tmux parity](docs/TMUX_PARITY.md) · [Commands](docs/COMMANDS.md) · [Keybindings](docs/KEYBINDINGS.md) · [Shell integration](docs/shell-integration/README.md) · [Agent hooks](docs/agent-hooks/README.md) · [Manual Test Plan](docs/MANUAL_TEST_PLAN.md) · [Migration](docs/MIGRATION.md) · [Changelog](CHANGELOG.md)

---

MIT
