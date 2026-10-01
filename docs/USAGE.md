# Kouen Usage

Getting started guide. For deep dives, follow the links at the bottom.

## 1. Install Kouen

### Option A: Download the app

Check [releases](https://github.com/Vit129/kouen-terminal/releases/latest) for a `Kouen.dmg`. Requires Apple silicon + macOS 15+.

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
/Applications/Kouen.app/Contents/MacOS/kouen-cli install
# or from a local build:
.build/release/kouen-cli install
```

Add to shell profile if prompted:

```bash
export PATH="$HOME/Library/Application Support/Kouen/bin:$PATH"
```

Verify:

```bash
kouen-cli doctor
kouen-cli ping
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
kouen-cli install-hooks claude-code
kouen-cli install-hooks codex
kouen-cli install-hooks cursor
```

`⌘⇧I` opens the Agent Notch. `⌘⌃I` opens the notifications inbox.

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

| Tool | Kouen integration |
|------|---------------------|
| `zoxide` | `⌘P` fuzzy jump · `⌘⇧J` visual picker (↩ cd · ⌘↩ new tab) |
| `fzf` | `ctrl+r` history · `ctrl+t` file pick |
| `ripgrep` | `:grep` uses rg when available |
| `bat` | Better `cat` output in terminal |

`⌘⇧R` — saved command Recipes (run immediately or send to Composer).

## 6. Troubleshooting

| Problem | Try |
|---|---|
| CLI cannot find daemon | `kouen-cli doctor`, relaunch Kouen |
| CLI version differs from daemon | `kouen-cli install`, restart daemon |
| Preview app is stale | `make preview-stop && make preview-clean && make preview` |
| Agent hook silent | Check `kouen-cli doctor` + `KOUEN_SURFACE` + agent guide |

## More Docs

- [docs/COMMANDS.md](docs/COMMANDS.md) — full CLI command reference
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) — shortcuts, IDE workflow, vi ex commands
- [docs/MODES.md](docs/MODES.md) — experience modes in detail
- [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md) — panes, copy mode, remote/headless
- [docs/MIGRATION.md](docs/MIGRATION.md) — migrating from tmux
- [docs/shell-integration/README.md](docs/shell-integration/README.md) — prompt marks, shell snippets
- [docs/agent-hooks/README.md](docs/agent-hooks/README.md) — per-agent notification setup
