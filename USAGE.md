# Harness Usage

Getting started guide. For deep dives, follow the links at the bottom.

## 1. Install Harness

### Option A: Download the app

Check [releases](https://github.com/Vit129/harness-terminal/releases/latest) for a `Harness.dmg`. Requires Apple silicon + macOS 15+.

### Option B: Preview build (dev/test)

```bash
make preview        # isolated build, separate state
make preview-stop
make preview-clean
```

### Option C: Interactive build menu (recommended)

```bash
make start
```

Opens a menu to preview, bump version, or run a full release cycle.

### Option D: Install into `/Applications`

```bash
make install
```

Builds, signs, stops the old daemon, copies to `/Applications`, and opens the app.

## 2. Install The CLI On PATH

```bash
/Applications/Harness.app/Contents/MacOS/harness-cli install
# or from a local build:
.build/release/harness-cli install
```

Add to shell profile if prompted:

```bash
export PATH="$HOME/Library/Application Support/Harness/bin:$PATH"
```

Verify:

```bash
harness-cli doctor
harness-cli ping
```

## 3. Pick An Experience Mode

Open **Settings → Terminal → Experience**:

| Mode | Use when |
|---|---|
| Plain Terminal | Normal terminal, minimal chrome |
| Persistent Terminal | Sessions survive clean app quits |
| Full Terminal | tmux-style prefix, status line, panes, copy mode |
| Agent Workspace | Project sessions + agent notifications foregrounded |

→ [docs/MODES.md](docs/MODES.md)

## 4. Agent Notifications

```bash
harness-cli install-hooks claude-code
harness-cli install-hooks codex
harness-cli install-hooks cursor
```

`⌘⇧I` opens the Agent Notch. `⌘⇧U` opens the notifications inbox.

→ [docs/agent-hooks/README.md](docs/agent-hooks/README.md)

## 5. Recommended Shell Tools

```bash
brew install zoxide fzf ripgrep bat
```

Add to `~/.zshrc`:

```bash
eval "$(zoxide init zsh)"
source <(fzf --zsh)
```

| Tool | Harness integration |
|------|---------------------|
| `zoxide` | `⌘P` fuzzy jump · `⌘⇧J` visual picker (↩ cd · ⌘↩ new tab) |
| `fzf` | `ctrl+r` history · `ctrl+t` file pick |
| `ripgrep` | `:grep` uses rg when available |
| `bat` | Better `cat` output in terminal |

`⌘⇧R` — saved command Recipes (run immediately or send to Composer).

## 6. Troubleshooting

| Problem | Try |
|---|---|
| CLI cannot find daemon | `harness-cli doctor`, relaunch Harness |
| CLI version differs from daemon | `harness-cli install`, restart daemon |
| Preview app is stale | `make preview-stop && make preview-clean && make preview` |
| Agent hook silent | Check `harness-cli doctor` + `HARNESS_SURFACE` + agent guide |

## More Docs

- [docs/COMMANDS.md](docs/COMMANDS.md) — full CLI command reference
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) — shortcuts, IDE workflow, vi ex commands
- [docs/MODES.md](docs/MODES.md) — experience modes in detail
- [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md) — panes, copy mode, remote/headless
- [docs/MIGRATION.md](docs/MIGRATION.md) — migrating from tmux
- [docs/shell-integration/README.md](docs/shell-integration/README.md) — prompt marks, shell snippets
- [docs/agent-hooks/README.md](docs/agent-hooks/README.md) — per-agent notification setup
