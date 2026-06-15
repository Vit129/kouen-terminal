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

### Option C: Build a local app at the repo root

```bash
make prod
open Harness.app
```

This builds a release-style `Harness.app` at the repository root and opens it without copying it to `/Applications`.

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

Jump to the waiting agent with `Cmd+Shift+U`.

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

## More Docs

- [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md) - panes, sessions, copy mode, attach, remote workflows
- [docs/COMMANDS.md](docs/COMMANDS.md) - full command reference
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) - shortcuts and custom bindings
- [docs/shell-integration/README.md](docs/shell-integration/README.md) - prompt marks and shell snippets
- [docs/MANUAL_TEST_PLAN.md](docs/MANUAL_TEST_PLAN.md) - manual QA checklist
