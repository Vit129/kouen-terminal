# Harness Usage

This is the practical setup guide for installing, running, and driving Harness. For the full command reference, see [docs/COMMANDS.md](docs/COMMANDS.md).

## 1. Install Harness

### Option A: Download the app

The latest release in this fork does not currently attach a `.dmg` asset. Check <https://github.com/Vit129/harness-terminal/releases/latest>; if a future release includes `Harness.dmg`, open it, drag `Harness.app` to `/Applications`, launch the app, and run first-run setup when prompted.

The app requires Apple silicon and macOS 15 or later.

### Option B: Run an isolated preview build

Use this when developing or testing. It keeps runtime state separate from your production Harness install.

```bash
make preview
```

The preview app lives under `.harness-preview/` and uses a preview-specific daemon socket and state directory.

Stop and clean it with:

```bash
make preview-stop
make preview-clean
```

### Option C: Interactive build menu (recommended)

```bash
make start
```

Opens an interactive menu to commit+push, run a preview build, bump version and build, or run a full release cycle. Use this as the primary workflow.

### Option D: Install the local build into `/Applications`

```bash
make install
```

`make install` builds, packages, ad-hoc signs, stops the old production daemon, copies `Harness.app` to `/Applications`, refreshes app-support daemon/CLI binaries, clears runtime state, and opens the installed app.

If `Harness.app` already exists at the repo root and you only want to copy it:

```bash
make install-no-build
```

## 2. Install The CLI On PATH

From an installed app:

```bash
/Applications/Harness.app/Contents/MacOS/harness-cli install
```

From a local release build:

```bash
.build/release/harness-cli install
```

Then add the app-support bin directory to your shell profile if the installer asks:

```bash
export PATH="$HOME/Library/Application Support/Harness/bin:$PATH"
```

Check the install:

```bash
harness-cli doctor
harness-cli ping
```

## 3. Pick An Experience Mode

Open **Settings -> Terminal -> Experience**:

| Mode | Use when |
| --- | --- |
| Plain Terminal | You want a normal terminal with minimal chrome |
| Persistent Terminal | You want sessions to survive clean app quits |
| Full Terminal | You want tmux-style prefix, status line, panes, and copy mode |
| Agent Workspace | You want project sessions and agent notifications foregrounded |

See [docs/MODES.md](docs/MODES.md) for the behavior differences.

## 4. Core CLI Commands

```bash
harness-cli list-workspaces
harness-cli list-sessions
harness-cli list-surfaces
harness-cli new-session --workspace Default --name work --cwd ~/Code/project
harness-cli new-tab --workspace Default --cwd ~/Code/project
harness-cli attach --surface <uuid>
harness-cli attach-window --session work
harness-cli send-keys --surface <uuid> --keys "make test Enter"
harness-cli capture-pane --surface <uuid> --scrollback
```

Run `harness-cli` with no arguments to print the available command list.

## 5. Agent Notifications

Harness sets `HARNESS_SURFACE` inside panes so hooks can notify the exact tab or pane.

Install a supported agent hook:

```bash
harness-cli install-hooks codex
harness-cli install-hooks claude-code
harness-cli install-hooks cursor
```

Send a manual notification:

```bash
harness-cli notify --surface "$HARNESS_SURFACE" --title "Agent" --body "Needs approval"
```

Jump to the waiting agent with `Cmd+Shift+I`.

Per-agent guides live in [docs/agent-hooks/README.md](docs/agent-hooks/README.md).

## 6. Remote Or Headless Daemon

On the remote machine, run `harness-cli doctor` to find the daemon socket path. On your local machine, register it:

```bash
harness-cli remote add --name devbox --ssh me@devbox --socket "/home/me/.config/harness/harness.sock"
harness-cli remote list
harness-cli ping --host devbox
harness-cli new-session --host devbox --cwd ~/Code
harness-cli send-keys --host devbox --surface <id> --keys "ls -la Enter"
harness-cli capture-pane --host devbox --surface <id>
```

Pass SSH options with repeated `--ssh-arg` flags:

```bash
harness-cli remote add --name devbox --ssh me@devbox --socket "/home/me/.config/harness/harness.sock" --ssh-arg -p --ssh-arg 2222
```

## 7. Build And Test

```bash
swift build
swift test
swift build --product Harness
swift build --product HarnessDaemon
swift build --product harness-cli
HARNESS_BENCHMARKS=1 swift test -c release --filter HarnessBenchmarks
```

Always run `swift build` after code edits. For daemon, IPC, or PTY changes, also run the relevant filtered tests or the full `swift test` suite when practical.

## Troubleshooting

| Problem | Try |
| --- | --- |
| CLI cannot find the daemon | `harness-cli doctor`, then relaunch Harness |
| CLI version differs from daemon | Re-run `harness-cli install`, then restart the daemon/app |
| Preview app is stale | `make preview-stop && make preview-clean && make preview` |
| Production app still uses old daemon | `make install` refreshes `/Applications` and app-support binaries |
| Agent hook does not notify | Check `harness-cli doctor`, `HARNESS_SURFACE`, and the matching guide in `docs/agent-hooks/` |

## 8. IDE-Like Workflow (Terminal Workbench)

Harness includes IDE-like features accessible without leaving the terminal. No path memorization required.

### File Navigation (replaces File Tree)

| Shortcut / Command | What it does |
|--------------------|-------------|
| `⌘P` | Fuzzy file search — like Spotlight or VS Code Cmd+P |
| `:find <partial>` | Fuzzy-open file by name fragment (vi ex command) |
| `:recent` | Show recently opened files, pick by number |
| `:copy-path` | Copy relative path of the current file |
| `:copy-path absolute` | Copy absolute path |
| `gf` | Open path under cursor (works on compiler/test output) |

### Search in Project (replaces Search Panel)

| Command | What it does |
|---------|-------------|
| `:grep <query>` | Search across the project, results shown as `path:line:col` |
| `gf` on result | Jump to file at that line |

### Errors and Diagnostics (replaces Problems Panel)

| Command | What it does |
|---------|-------------|
| `:errors` | Show LSP diagnostics for the current file |
| `]d` / `[d` | Jump to next / previous error |
| `gd` | Go to definition at cursor |
| `K` | Hover info at cursor (requires LSP) |

### Build and Test (replaces Run Panel)

| Command | What it does |
|---------|-------------|
| `:make` | Auto-detect and run the project's default build command |
| `:make build` | Run the build command (SwiftPM / Makefile / npm auto-detected) |
| `:make test` | Run the test command |
| `:make last` | Repeat the last `:make` command |

Tasks run in a split pane — the current terminal stays usable.

### Session State (replaces Status Panel)

| Command | What it does |
|---------|-------------|
| `:board` | Open Board tab — Running / Idle / Done / Error / Needs Attention |
| `:attention` | Jump to the next session that needs attention |
| `:ack` | Dismiss the current tab's Needs Attention state |
| `harness-cli board` | Same board view from the shell |
| `harness-cli board --watch` | Live-updating board (htop-style) |

### Vi Ex Commands (open file editor first, then press `:`)

File editor opens when you click a file in the sidebar, or via `:view <path>` / `:edit <path>`.

```
:find SessionCoord     → fuzzy-open file matching "SessionCoord"
:recent                → list recently opened files
:copy-path             → copy relative path to clipboard
:grep BoardModel       → search project for "BoardModel"
:errors                → show LSP errors in current file
:make test             → run tests in a split pane
:make last             → repeat last build/test command
:board                 → show session board
:split path/to/file    → open file in a new split pane
```

## More Docs

- [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md) - panes, sessions, copy mode, attach, remote workflows
- [docs/COMMANDS.md](docs/COMMANDS.md) - full command reference
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) - shortcuts and custom bindings
- [docs/shell-integration/README.md](docs/shell-integration/README.md) - prompt marks and shell snippets

## 9. Experience Modes

Switch in **Settings → Terminal → Experience**.

| Mode | Prefix key | Status line | Sessions survive quit | Agent workflows |
|------|:----------:|:-----------:|:--------------------:|:---------------:|
| **Plain Terminal** | — | — | No | available |
| **Persistent Terminal** | — | — | Yes | available |
| **Full Terminal** | ✓ | ✓ | Yes | available |
| **Agent Workspace** | optional | optional | Yes | foregrounded |

See [docs/MODES.md](docs/MODES.md) for full details on persistence and prefix/status line overrides.

## 10. Migrating From Another Terminal

### From tmux

Switch to **Full Terminal** mode. Your muscle memory works immediately — prefix `Ctrl-A`, splits, copy mode, paste buffers, command prompt, and `harness-cli attach-window` for full layout attach.

See [docs/MIGRATION.md](docs/MIGRATION.md) for the full tmux key-by-key translation and `.tmux.conf` import guide.

### Importing Colors And Fonts

Harness auto-imports colors, font face, opacity, and padding from compatible terminal configs on first run. Re-import any time via **Settings → Appearance → Reset to defaults** or the `source-config` command.

