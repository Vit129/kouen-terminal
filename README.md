# Harness

> Forked from [robzilla1738/harness-terminal](https://github.com/robzilla1738/harness-terminal). Current release: **v3.11.5**.

Harness is a native macOS terminal built for AI agent workflows. A first-party Swift terminal engine, a background session daemon, a scriptable CLI, embedded browser with MCP control, and multi-agent awareness — all in one app.

Run Claude Code, Codex, Gemini CLI, or any agent side-by-side. Sessions persist across app restarts, agents notify you when done, the embedded browser responds to MCP tool calls, and panes render on Metal.

## Install

This fork does not currently publish a downloadable `.dmg` asset. Install it by building from source.

### Requirements

- Apple silicon Mac
- macOS 15 or later
- Xcode 16+ / Swift 6.0

### Install Into Applications

Use this for a normal local install:

```bash
git clone https://github.com/Vit129/harness-terminal.git
cd harness-terminal
make install
```

`make install` builds Harness, packages `Harness.app`, copies it to `/Applications/Harness.app`, refreshes the local daemon/CLI helper binaries, and opens the app.

After the app opens, install the CLI on your `PATH` if prompted, or run:

```bash
/Applications/Harness.app/Contents/MacOS/harness-cli install
```

Then verify:

```bash
harness-cli doctor
harness-cli ping
```

### Development Builds

For an isolated dev/test app that does not touch production Harness state:

```bash
make preview
```

See [USAGE.md](USAGE.md) for the full install, run, CLI, and remote/headless guide.

## Why Harness

- Native terminal rendering with Swift, CoreText, Metal, ligatures, and a large built-in theme catalog.
- Daemon-owned sessions, tabs, panes, scrollback, and layouts so work survives app restarts and can be attached from another client.
- `harness-cli` automation for creating sessions, sending keys, capturing panes, installing hooks, and driving remote/headless daemons.
- Agent detection and notifications for Claude Code, Codex, Cursor, Grok, Pi, Hermes, OpenClaw, OpenCode, Aider, Gemini, Goose, and generic agents.
- Embedded browser pane with `harness-mcp` — AI agents can open URLs, read DOM snapshots, click elements, fill forms, capture screenshots, and inspect network/storage without a separate Playwright process.
- Multi-agent workflows — run Claude Code, Codex, and Gemini CLI in parallel panes with per-agent statusline showing model, context usage, and rate limits.
- Optional tmux-style controls: prefix key, status line, copy mode, paste buffers, hooks, command prompt, and many tmux-compatible commands.
- IDE-like navigation — double-click folders to cd, ⌘P fuzzy jump to any directory via zoxide frecency, ⌘⇧J frecency dir picker (↩ cd · ⌘↩ open new tab), ⌘⇧R saved command recipes, ⌘-click file paths, `:cd` from the command prompt, and **Open With Harness** from Finder on any source file.
- Sidebar tools for sessions, file navigation, real-time Git workflows (one-step Commit & Push), command palette, and editor/LSP flows.
- Stable under long sessions — per-pane controller trees and browser network buffers are bounded and released on pane close; memory stays flat across hours of use.

## Keyboard Shortcuts

### Terminal editing

| Shortcut | Action |
|----------|--------|
| ⌘⌃V | Toggle Vi modal editing (normal / insert mode) |
| Esc (Vi normal) | Enter normal mode — `hjkl` move, `wb` word, `0`/`$` line, `x` delete, `i`/`a`/`A` insert |
| ⌘-click output block | Select OSC 133 command block — copy or send to AI |
| ⌃C (with selection) | Copy selection first, then send interrupt |
| ⌘⇧U | Hint mode — keyboard-driven link/path opening |

### AI chat

| Shortcut | Action |
|----------|--------|
| ⌘I | Toggle inline AI chat (Claude / Codex / Gemini / Kiro) |
| ⌘⇧↩ | Prompt queue — batch prompts, run sequentially |
| ⌥Space | Inline AI command suggestion overlay |
| Right-click selection | Ask AI → prefill chat with selected text |
| ⌘V (in AI chat) | Paste image → inserts file path (not inline render) |
| Drag image to AI chat | Inserts image file path |

### Navigation & layout

| Shortcut | Action |
|----------|--------|
| ⌘⇧J | Frecency directory picker (zoxide-powered) |
| ⌘⇧R | Recipes — saved command picker |
| ⌘⇧E | Composer panel — multi-line command editor |
| ⌘⌥F | Floating terminal pane (NSPanel, persisted frame) |
| ⌘⇧\ | Tab overview — thumbnail grid, click to switch |
| ⌘F | Scrollback search |
| ⌘⇧F | Find in files |

### Session & layout files

| Shortcut / command | Action |
|-------------------|--------|
| ⌘⇧S (export) | Export current layout to `.harness-layout` JSON |
| ⌘⇧O (import) | Restore a saved `.harness-layout` |
| OSC 26 | Agent protocol — Fork Tab, approval bar, agent activity |

## How It Feels

Harness has four experience modes:

| Mode | Best for | Persistence |
| --- | --- | --- |
| Plain Terminal | A normal, quiet terminal | Sessions close on clean quit |
| Persistent Terminal | Plain terminal plus daemon-backed sessions | Sessions survive clean quit |
| Full Terminal | tmux-style panes, prefix, status line, copy mode | Sessions survive clean quit |
| Agent Workspace | Project workspaces with agent detection foregrounded | Sessions survive clean quit |

Switch modes in **Settings -> Terminal -> Experience**. Details live in [docs/MODES.md](docs/MODES.md).

## CLI

After installation, `harness-cli` is available from the app bundle or app-support bin directory:

```bash
/Applications/Harness.app/Contents/MacOS/harness-cli install
export PATH="$HOME/Library/Application Support/Harness/bin:$PATH"
```

Common commands:

```bash
harness-cli doctor
harness-cli list-sessions
harness-cli list-surfaces
harness-cli new-session --workspace Default --cwd ~/Code
harness-cli attach --surface <uuid>
harness-cli attach-window --session <name>
harness-cli send-keys --surface <uuid> --keys "ls -la Enter"
harness-cli capture-pane --surface <uuid> --scrollback
harness-cli install-hooks codex
```

More examples are in [USAGE.md](USAGE.md), [docs/COMMANDS.md](docs/COMMANDS.md), and [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md).

## AI Browser Control (harness-mcp)

AI agents (Claude Code, Codex, Kiro) can see and interact with the embedded browser pane via `harness-mcp`. No separate browser or Playwright process needed.

**What an agent can do:**

| Capability | Tool | Returns |
| --- | --- | --- |
| Open / navigate URL | `harnessBrowserOpen`, `harnessBrowserNavigate` | pane ID |
| Read DOM + elements | `harnessBrowserSnapshot` | accessibility tree with stable refs (e1, e2…) |
| Click / fill / scroll | `harnessBrowserInteract` | ok / error |
| Screenshot | `harnessBrowserScreenshot` | base64 PNG |
| Read console logs | included in snapshot | array of log strings |
| Network requests | `harnessBrowserNetwork` | url, method, status, req/res body |
| Cookies | `harnessBrowserCookies` | name, value, domain, expires, secure |
| localStorage / sessionStorage | `harnessBrowserStorage` | key/value pairs |

**Snapshot element format** — stable refs let agents interact without writing selectors:

```json
{ "id": "e7", "tag": "button", "role": "button", "text": "Save", "bounds": {"x":120,"y":340,"width":80,"height":32}, "visible": true }
```

**Default home page** is configurable in `settings.json`:

```json
{ "browserHomePage": "https://www.google.com" }
```

**Token efficiency:** snapshot returns structured data (~200–500 tokens), not screenshots or raw HTML — significantly cheaper than vision-based browser automation.

## Remote And Headless

The daemon and CLI can run without the GUI, including on Linux. Register a remote daemon over SSH and use `--host` with normal CLI commands:

```bash
harness-cli remote add --name devbox --ssh me@devbox --socket "/home/me/.config/harness/harness.sock"
harness-cli ping --host devbox
harness-cli new-session --host devbox --cwd ~/Code
harness-cli capture-pane --host devbox --surface <id>
```

## Stack

| Area | Technology |
| --- | --- |
| Language | Swift 6, strict concurrency |
| GUI | AppKit + SwiftUI |
| Terminal rendering | CoreText + Metal |
| IPC | Unix sockets, length-prefixed JSON, binary PTY frames |
| Scripting | JavaScriptCore |
| Agent tooling | CLI hooks + `harness-mcp` |
| Platforms | macOS 15+ GUI, macOS/Linux daemon and CLI |

## Documentation

- [USAGE.md](USAGE.md) - install, run, CLI, remote/headless, IDE-like workflow, experience modes, migration, and troubleshooting
- [docs/MODES.md](docs/MODES.md) - Plain, Persistent, Full, and Agent Workspace modes (detail)
- [docs/MIGRATION.md](docs/MIGRATION.md) - migrating from tmux or another terminal setup
- [docs/COMMANDS.md](docs/COMMANDS.md) - full command reference including workbench commands (`:find`, `:grep`, `:make`, `:errors`, `:recent`)
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) - shortcuts, key bindings, and vi ex command quick reference (IDE-like navigation)
- [sheet-cheat.html](sheet-cheat.html) - interactive cheat sheet (shell tools, unix, vim, Harness) — regenerate with `make cheatsheet`
- [docs/shell-integration/README.md](docs/shell-integration/README.md) - shell integration
- [docs/agent-hooks/README.md](docs/agent-hooks/README.md) - agent notification hooks
- [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md) - sessions, panes, prefix key, attach, copy mode
- [docs/RELEASE.md](docs/RELEASE.md) - release workflow
- [CHANGELOG.md](CHANGELOG.md) - release history

## Build From Source

```bash
swift build
swift test
make preview
```

For release packaging, use the documented order:

```bash
make release
make sign
make dmg
make finalize
```

## License

MIT
