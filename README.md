# Kouen

*An Agent Development Environment built around a native macOS terminal.*

> This is a personal fork of [robzilla1738/harness-terminal](https://github.com/robzilla1738/harness-terminal), maintained independently by [Vit129](https://github.com/Vit129). Not affiliated with the original project or its author. It's a hard fork, not a PR queue back upstream — see [What's different from upstream](docs/features.md#whats-different-from-upstream).

Kouen is a native macOS terminal (Swift) with a first-party terminal engine, a background session daemon, a scriptable CLI, an embedded browser with MCP control, and multi-agent awareness. Run Claude Code, Codex, Gemini CLI, or any agent side by side; sessions persist across app restarts and agents notify you when done. It is terminal-first: it supervises agents and git/process state, it is not an IDE.

## Key features

- Native Metal terminal rendering; daemon-owned sessions, tabs and panes that survive app restarts.
- `kouen-cli` automation: create sessions, send keys, capture panes, install hooks, drive remote/headless daemons.
- Agent detection and notifications for Claude Code, Codex, Gemini, Cursor, Aider and others.
- Embedded browser pane with `kouen-mcp`, so agents can open pages, read the DOM, click and capture screenshots.
- Orchestrator and Agent Swarm, scheduled Automations, and worktree-first sessions.
- Agent safety net: per-turn checkpoints (`kouen undo`), build/test verification, and write guards.
- Built-in editor with LSP, unified agent History, and an optional tmux-style mode.

More in [docs/features.md](docs/features.md).

## Requirements

- Apple silicon Mac
- macOS 15 or later
- Xcode 16+ / Swift 6.0

## Install

This fork does not currently publish a downloadable `.dmg`; build from source. Prebuilt DMG and in-app updates (Sparkle) are planned.

```bash
git clone https://github.com/Vit129/kouen-terminal.git
cd kouen-terminal
make install-graceful
```

`make install-graceful` builds, installs `Kouen.app` into `/Applications`, refreshes the daemon/CLI helpers and opens the app. Then verify:

```bash
kouen-cli doctor
kouen-cli ping
```

For an isolated dev app that does not touch production state, run `make preview`.

## Update

```bash
git pull
make install-graceful
```

Workspace and session state is preserved, and the daemon only restarts when the IPC protocol changed, so running agents survive an update.

## Usage

Run `kouen-cli install` (from `/Applications/Kouen.app/Contents/MacOS/`) to put the CLI on your `PATH`, then `kouen-cli doctor`. See [docs/USAGE.md](docs/USAGE.md) and [docs/COMMANDS.md](docs/COMMANDS.md) for commands, and [docs/keyboard-shortcuts.md](docs/keyboard-shortcuts.md) for shortcuts.

## Documentation

- [PRODUCT.md](PRODUCT.md) / [ARCHITECTURE.md](ARCHITECTURE.md) / [DESIGN.md](DESIGN.md) - scope, architecture, visual system
- [docs/features.md](docs/features.md) - upstream differences, feature details, harness, safety net, editor and LSP, mobile, remote, stack
- [docs/keyboard-shortcuts.md](docs/keyboard-shortcuts.md) - most-used shortcuts
- [docs/mcp-tools.md](docs/mcp-tools.md) - `kouen-mcp` browser control tools
- [docs/USAGE.md](docs/USAGE.md) - install, run, CLI, remote/headless, troubleshooting
- [docs/MODES.md](docs/MODES.md) - experience modes
- [docs/MIGRATION.md](docs/MIGRATION.md) - migrating from tmux or another terminal
- [docs/COMMANDS.md](docs/COMMANDS.md) - full command reference
- [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) - full key binding reference
- [docs/MULTIPLEXER_GUIDE.md](docs/MULTIPLEXER_GUIDE.md) - sessions, panes, prefix key, copy mode
- [docs/shell-integration/README.md](docs/shell-integration/README.md) - shell integration
- [docs/agent-hooks/README.md](docs/agent-hooks/README.md) - agent notification hooks
- [docs/RELEASE.md](docs/RELEASE.md) - release workflow
- [sheet-cheat.html](sheet-cheat.html) - interactive cheat sheet (`make cheatsheet`)
- [CHANGELOG.md](CHANGELOG.md) - release history

## Contributors

Developed and maintained by **Vit129** and **Claude** (Anthropic).

## License

Apache License 2.0 — see `LICENSE` and `NOTICE`. Kouen is a fork of
[robzilla1738/harness-terminal](https://github.com/robzilla1738/harness-terminal) (MIT, © 2026 Robert);
that code and releases up to v4.21.10 remain available under MIT (`LICENSE-MIT`).
