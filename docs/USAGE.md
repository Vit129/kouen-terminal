# Kouen Usage

Getting started guide. For deep dives, follow the links at the bottom.

## 1. Install Kouen

This fork does not publish a downloadable `.dmg`; build from source (Apple silicon, macOS 15+, Xcode 16+).

### Option A: Install into `/Applications` (normal use)

```bash
git clone https://github.com/Vit129/kouen-terminal.git && cd kouen-terminal
make install-graceful
```

Builds first, then installs to `/Applications/Kouen.app` and opens it. Session state is kept, and the daemon is restarted only when the IPC protocol changed, so running agents survive an update. If the running daemon is on an older build, run `kouen-cli install` when nothing important is running to reload it.

### Option B: Preview build (dev/test)

```bash
make preview        # isolated build, separate state
make preview-stop
make preview-clean
```

### Option C: Interactive menu

```bash
make start
```

Opens a menu to preview, bump version, or run a full release cycle (`Scripts/full-cycle.sh`; see [RELEASE.md](RELEASE.md)).

On launch Kouen checks `version.json` on `main` and, on a clean working tree, asks whether to `git pull` when a newer version exists — never automatically.

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

→ [MODES.md](MODES.md)

## 4. Agent Notifications

```bash
kouen-cli install-hooks claude-code
kouen-cli install-hooks codex
kouen-cli install-hooks cursor
```

`⌘⇧I` opens the Agent Notch (off by default; enable in Settings). `⌘⌃I` opens the notifications inbox.

→ [agent-hooks/README.md](agent-hooks/README.md)

### Steering agents from a phone

Each agent launches in `remote-control` mode by default (`agentSessionModes` in `settings.json`), so Claude Code shows up in the Claude app. For one cross-vendor phone app install [Happy](https://happy.engineering) (`npm i -g happy`, `happy auth login`) and set an agent's mode to `happy`; with Happy logged in, a hand-typed `claude` is reachable from both apps. A session started from the phone runs headless — `kouen-cli happy adopt <id>|--all` pulls it into a pane. Claude/Codex resume through `happy resume`; Antigravity and Copilot resume natively (`agy --conversation`, `copilot --resume`) since Happy's `agy`/`acp` modes are headless. Details: README § Mobile.

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
| CLI version differs from daemon | `kouen-cli install` (reloads the daemon; running tasks stay alive until then) |
| Preview app is stale | `make preview-stop && make preview-clean && make preview` |
| Agent hook silent | Check `kouen-cli doctor` + `KOUEN_SURFACE` + agent guide |

## More Docs

- [COMMANDS.md](COMMANDS.md) — full CLI command reference
- [KEYBINDINGS.md](KEYBINDINGS.md) — shortcuts, IDE workflow, vi ex commands
- [MODES.md](MODES.md) — experience modes in detail
- [MULTIPLEXER_GUIDE.md](MULTIPLEXER_GUIDE.md) — panes, copy mode, remote/headless
- [MIGRATION.md](MIGRATION.md) — migrating from tmux
- [shell-integration/README.md](shell-integration/README.md) — prompt marks, shell snippets
- [agent-hooks/README.md](agent-hooks/README.md) — per-agent notification setup
