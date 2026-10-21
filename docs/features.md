# Kouen Features

Reference material moved out of the README.

## What's different from upstream

This fork started from upstream (currently v1.12.1) and has since diverged substantially — over 100 changelog entries of its own (upstream's count of 23 was last checked earlier and may be stale), and a set of first-party Swift packages backing the features below (see [ARCHITECTURE.md](../ARCHITECTURE.md)). Checked directly against upstream's current source, not assumed:

- **AI browser control via MCP** — `kouen-mcp` exposes tools like `kouenBrowserOpen` and `kouenBrowserSnapshot` (full list under [AI Browser Control](mcp-tools.md)) so agents can drive the embedded browser pane directly. Upstream has no browser pane and no MCP server.
- **A built-in code editor with LSP** across 21 languages, with vi ex commands `gd` / `K` / `:errors` working against the live session (see [Editor & LSP](#editor--lsp)). Upstream's sidebar is session/tab lists only — no file editor, no LSP.
- **A denser navigation layer** — Recipes (`⌘⇧R`), Composer (`⌘⇧E`), the zoxide frecency picker (`⌘⇧J`), tab overview (`⌘⇧\`), and hint mode (`⌘⇧U`) — none of these shortcuts exist upstream.
- **JavaScriptCore-based scripting** (see [Stack](#stack)) — upstream has no scripting layer at all.

None of this is a knock on the original — it's a different, more actively-maintained branch, kept for personal use rather than as a distributed product.

## Why Kouen

- Native terminal rendering with Swift, CoreText, Metal, ligatures, and a large built-in theme catalog.
- Daemon-owned sessions, tabs, panes, scrollback, and layouts so work survives app restarts and can be attached from another client.
- `kouen-cli` automation for creating sessions, sending keys, capturing panes, installing hooks, and driving remote/headless daemons.
- Agent detection and notifications for Claude Code, Codex, Cursor, Grok, Pi, Hermes, OpenClaw, OpenCode, Aider, Gemini, Goose, and generic agents.
- Embedded browser pane with `kouen-mcp` — AI agents can open URLs, read DOM snapshots, click elements, fill forms, capture screenshots, and inspect network/storage without a separate Playwright process.
- Headless Claude Code runs — `kouen cc run` (CLI) or `kouenCCRun`/`kouenCCStatus` (`kouen-mcp`) drive `claude` as a real subprocess for one-shot prompts/automations, no pane or human supervision needed.
- Multi-agent workflows — run Claude Code, Codex, and Gemini CLI in parallel panes with per-agent statusline showing model, context usage, and rate limits.
- Orchestrator and Agent Swarm — an agent decomposes a goal into Tasks, spawns Worker sessions (interactive or headless via `kouenSpawnWorker`), and drives each toward merge-ready with a bounded auto-fix loop; task status shows inline on tabs and the sidebar. Headless workers accept follow-up turns.
- Automations — scheduled agent launches with a Jobs fleet view and result viewer (`kouenAutomation*` MCP tools).
- Worktree-first sessions — lineage and drift tracking per worktree, per-ticket isolated worktrees from the issue tracker, and auto-isolate that keeps the primary checkout on its own branch.
- Unified History — Claude Code, Codex, Antigravity, Copilot and VS Code Copilot Chat sessions in one list; resume in place or hand a session off to another agent. ◀ ▶ next to the sidebar toggle step to the previous/next session in list order (same action as ⌘⇧[ / ⌘⇧], not a switch-history stack).
- Per-agent launch modes — `local`, `remote-control` or `cloud` per agent (`agentSessionModes` in `settings.json`), driven by one launch table; see [Mobile](#mobile).
- Optional tmux-style controls: prefix key, status line, copy mode, paste buffers, hooks, command prompt, and many tmux-compatible commands.
- IDE-like navigation — double-click folders to cd, ⌘P fuzzy jump to any directory via zoxide frecency, ⌘⇧J frecency dir picker (↩ cd · ⌘↩ open new tab), ⌘⇧R saved command recipes, ⌘-click file paths, `:cd` from the command prompt, and **Open With Kouen** from Finder on any source file.
- Sidebar tools for sessions, file navigation, real-time Git workflows (one-step Commit & Push, per-hunk stage/unstage, PR merge with squash/rebase/merge picker), command palette, and editor/LSP flows across 21 languages — see [Editor & LSP](#editor--lsp).
- Sidebar dev-server detection — live listening-port badge per session, click to open in the browser pane.
- SSH agent forwarding for remote hosts, toggleable per host in Settings.
- Fleet visibility — footer badge + Agent Inbox header show running/needs-attention counts across all active agent sessions, plus a dedicated Fleet sidebar tab flattening every live session across every workspace.
- Agent safety net — automatic per-turn checkpoints with `kouen undo`, two-tier build/test verification (`kouen verify`, `verify-on-turn`), and write-origin guards that refuse an automation write onto a protected branch, a dirty unisolated checkout, or a surface a human is actively typing in — see [Agent Safety Net](#agent-safety-net-checkpoints-verification-write-guards).
- Stable under long sessions — per-pane controller trees and browser network buffers are bounded and released on pane close; memory stays flat across hours of use.

## How It Feels

Kouen has four experience modes:

| Mode | Best for | Persistence |
| --- | --- | --- |
| Plain Terminal | A normal, quiet terminal | Sessions close on clean quit |
| Persistent Terminal | Plain terminal plus daemon-backed sessions | Sessions survive clean quit |
| Full Terminal | tmux-style panes, prefix, status line, copy mode | Sessions survive clean quit |
| Agent Workspace | Project workspaces with agent detection foregrounded | Sessions survive clean quit |

Switch modes in **Settings -> Terminal -> Experience**. Details live in [docs/MODES.md](MODES.md).

## Claude Code Harness

Run `claude` as a real subprocess — `-p --output-format stream-json` — instead of a pty pane. No adapter binary, no screen-scraping; tool access is controlled via `--allowedTools`/`--disallowedTools`. For one-shot prompts and automations where nothing needs to watch it run; use `kouenSpawnAgent`/an interactive pane instead when a human is steering.

**From the terminal, no AI agent needed:**

```bash
kouen-cli cc run "summarize the last commit" --cwd ~/Code/myrepo
kouen-cli cc run "add input validation" --profile edit --model sonnet --effort high
kouen-cli cc status <runId>
kouen-cli cc list
kouen-cli cc cancel <runId>
```

**From an AI agent, via `kouen-mcp`:**

| Capability | Tool | Returns |
| --- | --- | --- |
| Start a run | `kouenCCRun` | run id + immediate status |
| Get / list / cancel | `kouenCCStatus` | run status, result, cost |

**Permission profiles** — `readonly` (Read/Glob/Grep only) or `edit` (default: Edit/Write + a git-readonly Bash allowlist; `rm`/`sudo`/`git push` always denied). Never `bypassPermissions`.

## Agent Safety Net (Checkpoints, Verification, Write Guards)

Every agent turn is automatically snapshotted and, optionally, verified — so a bad turn is a
`kouen undo` away instead of a manual `git diff`/`git checkout` scramble, and a broken build
surfaces as a desktop notification instead of silently compounding into the next turn.

- **Checkpoints on every turn** — when an agent's Stop hook fires, the daemon snapshots the
  working tree (tracked + untracked) into a `refs/kouen/checkpoints/<session>/<turn>` git ref via
  a temporary index, never touching your real staging area or `git stash`.
- **`kouen undo`** — revert the working tree in a tab's `cwd` to its last checkpoint, or list
  checkpoints with their diffstat: `kouen undo`, `kouen undo list`, `kouen undo --tab <id>`,
  `kouen undo --feature <slug>`.
- **`kouen verify`** — run a two-tier check against a tab's project: `tier1` (fast syntax/build
  check, auto-detected per toolchain) or `tier2` (the project's own full test command, manual-only
  since running a full suite after every turn is too expensive a default). Enable tier1
  automatically after every agent turn with `set-option -g verify-on-turn on`; a failing check
  flips the tab to an error state with a desktop notification you can act on directly (see
  Turn Diff Reviewer below).
- **Write-origin guards** — every PTY write is tagged `human` or `automation`. An automation
  write is refused (not silently accepted) when: a human typed in that surface within the last
  1.5s (avoids stepping on a live human edit), the tab sits directly on a protected branch
  (`main`/`master`/`develop`) with no worktree isolation, or the tab's checkout already has
  uncommitted changes with no worktree isolation — each a guard against an agent clobbering work
  that isn't its own. Worktree-isolated tabs are exempt from the branch/dirty-tree checks by design.
- **Turn Diff Reviewer (⌘⌥D)** — review the diff since the last checkpoint in a floating panel;
  `y` accepts, `r` reverts to the checkpoint, `esc` dismisses.
- **Quick Context Injector (⌘K)** — a HUD that resolves `@`-mention tokens (`@diff`, `@file:<path>`,
  `@last`, `@error`, `@builderror` for the last failed `verify-on-turn` output, `@pane:<id>`,
  `@graph:<symbol>`, `@issue`) and sends the expanded text straight into the active surface.
- **`kouen history`** — list, search, show, or resume past agent sessions (Claude Code, Codex,
  Antigravity) across every workspace from the shell (Copilot and VS Code Copilot Chat sessions also appear in the app's History view): `kouen history`, `kouen history search
  <keyword>`, `kouen history show <id>`, `kouen history resume <id>`.
- **`kouen task pack-pr [<slug>] [--out <file>]`** — assembles a PR description (diff stat, gate
  approvals, task checklist) from a feature's tracked state, for `gh pr create --body "$(kouen
  task pack-pr <slug>)"`.
- **Fleet tab** — one sidebar view flattening every live tab across every workspace, sorted
  needs-attention-first, with a filter box; the more useful entry point in day-to-day use is
  still a notification's own "jump to this session" action — the tab itself is for scanning many
  concurrent agents at once, not a screen you keep open.

## Editor & LSP

Opening a file in the sidebar file editor auto-detects a language server from the file extension or a project marker (e.g. `package.json`, `Package.swift`) in an ancestor directory, and starts it if the binary is on `PATH`. Vi ex commands work against the live session: `gd` (go to definition, falls back to `gf` path resolution), `K` (hover), `:errors` (diagnostics). See [docs/COMMANDS.md](COMMANDS.md#errors-and-lsp).

Nothing ships bundled — install the server binary you need yourself. Auto-start is off by default; turn it on and override any default binary path via `settings.json`:

```json
{ "lspAutoStart": true, "lspServers": { "python": "/opt/homebrew/bin/pyright-langserver" } }
```

| Group | Extensions | Server |
| --- | --- | --- |
| iOS native | `.swift` `.m` `.mm` | `sourcekit-lsp` |
| Android native | `.kt` `.kts` | `kotlin-language-server` |
| Android native | `.java` | `jdtls` |
| Flutter | `.dart` | `dart language-server` |
| Web / React / Next.js / Apps Script | `.ts` `.tsx` `.js` `.jsx` `.gs` | `typescript-language-server` |
| PHP | `.php` | `intelephense` |
| Ruby | `.rb` | `ruby-lsp` |
| Go | `.go` | `gopls` |
| Rust | `.rs` | `rust-analyzer` |
| Python | `.py` | `pyright-langserver` |
| C / C++ | `.c` `.cpp` `.cc` `.cxx` `.h` `.hpp` `.hxx` | `clangd` |
| C# / .NET | `.cs` | `csharp-ls` |
| SQL | `.sql` | `sql-language-server` |
| JSON | `.json` `.jsonc` | `vscode-json-language-server` |
| YAML | `.yml` `.yaml` | `yaml-language-server` |
| CSS | `.css` `.scss` `.sass` | `vscode-css-language-server` |
| HTML | `.html` `.htm` | `vscode-html-language-server` |
| Robot Framework | `.robot` `.resource` | `robotcode` |
| Gherkin / Cucumber | `.feature` | `cucumber-language-server` |
| Shell | `.sh` `.bash` `.zsh` | `bash-language-server` |
| Markdown | `.md` | `marksman` |

## Mobile

Kouen does not ship its own mobile app or relay. To watch or steer an agent from a phone, use the vendor's own remote-control app for the session Kouen launched:

| Agent | Mobile route | Status |
| --- | --- | --- |
| Claude Code | `claude remote-control` → Claude app / claude.ai/code (Kouen's default launch mode) | Confirmed |
| Codex | ChatGPT mobile app | Not yet confirmed for `codex` CLI sessions started inside Kouen |
| Antigravity | Antigravity remote control / companion app | Not yet confirmed for `agy` CLI sessions |


Trade-off: no single cross-vendor mobile dashboard by default — Kouen's Fleet view is desktop-only. The earlier built-in Mobile Connect bridge (QR + Tailscale web client) is deprecated, off by default (`mobileBridgeEnabled`) and no longer developed. Reasoning: [ARCHITECTURE.md](../ARCHITECTURE.md) § Architecture Decisions (2026-09-23).

## Remote And Headless

The daemon and CLI can run without the GUI, including on Linux. Register a remote daemon over SSH and use `--host` with normal CLI commands:

```bash
kouen-cli remote add --name devbox --ssh me@devbox --socket "/home/me/.config/kouen/kouen.sock"
kouen-cli ping --host devbox
kouen-cli new-session --host devbox --cwd ~/Code
kouen-cli capture-pane --host devbox --surface <id>
```

## Stack

| Area | Technology |
| --- | --- |
| Language | Swift 6, strict concurrency |
| GUI | AppKit + SwiftUI |
| Terminal rendering | CoreText + Metal |
| IPC | Unix sockets, length-prefixed JSON, binary PTY frames |
| Scripting | JavaScriptCore |
| Agent tooling | CLI hooks + `kouen-mcp` |
| Platforms | macOS 15+ GUI, macOS/Linux daemon and CLI |

