# tmux parity — status, adaptations, and deliberate divergences

Harness targets **capability parity** with tmux, not byte-for-byte emulation: Harness is a
native GUI terminal with a daemon-owned session model, so a handful of tmux concepts are
*adapted* to that architecture and a few are *rejected* with rationale. This document is
the single honest ledger. Updated last for the 2026-06 parity close-out series
(PRs #102–#108); user-facing usage lives in
[HARNESS_TMUX_CAPABILITIES.md](HARNESS_TMUX_CAPABILITIES.md), grammar in
[COMMANDS.md](COMMANDS.md).

## At parity

| Area | Notes |
|---|---|
| Sessions / windows / panes | Full lifecycle: new/kill/rename/select/move/swap/link/unlink/break/join/respawn (pane **and** window), renumber, last-window/pane, rotate, zoom, layouts (incl. main-horizontal/vertical), `synchronize-panes` |
| **Grouped sessions** | `new-session -t <session>`: shared window list, per-member focus; window create/kill propagates group-wide. Built atop linked windows — see ADAPT below |
| Targeting | Full `-t` grammar everywhere (`session:window.pane`, `$`/`@`/`%` ids, indexes, `!`, `{last}`, `{top}/{bottom}/{left}/{right}`, `^`/`$`), with `base-index`/`pane-base-index`. Unresolvable targets fail loudly in every front-end — never a silent misroute |
| Copy mode | vi + emacs tables (`copy-mode-vi` accepted as the vi table's name), `-X` action set (motions, selection, rectangle, search, prompt jumps, copy-pipe), mouse, in GUI **and** the `attach-window` compositor |
| Paste buffers | set/get/list/delete/paste/choose, save/load (CLI), bindable verbs |
| Options | Scoped store (global/workspace/session/tab/pane + fallback chain), `set`/`setw`/`show` bindable, status-line set, styles, monitoring, `display-time`, `set-titles(+string)`, `detach-on-destroy`, `remain-on-exit`, `repeat-time`, … |
| Hooks | `set-hook`/`show-hooks` + full lifecycle events: after-* command events, `session-created/renamed/closed`, `window-renamed/linked/unlinked/layout-changed`, alert-activity/silence/bell, client-attached/detached, pane-exited (+ Harness-only agent events) |
| Format strings | ~50 `#{…}` variables (pane/session/window/client/server) + operators (`#{?,,}`, `==`, `m:`, `s///`, `e\|op\|`, `=N:` truncation, `time:` strftime). IDs render with target-grammar prefixes so they round-trip into `-t` |
| Key tables | root/prefix/copy-mode(+emacs)/command + `switch-client -T` modal tables, `bind -r` repeat, tombstoned unbinds |
| Scripting | `send-keys`, `capture-pane` (+ ranges/escapes), `pipe-pane`, `run-shell`, `if-shell`, `wait-for -S/-L/-U`, `display-message`/`show-messages`, `command-prompt`, `confirm-before`, `source-file` (a `.tmux.conf`'s bind/set/setw/setenv lines parse as-is), choose-tree/session/window/buffer/client, `find-window`, control mode (`-CC`) |
| Misc | display-popup/menu, clock-mode, lock-client, multi-client smallest-size voting, environment tables (global/session) |

## Adapted (same capability, Harness-shaped)

| tmux | Harness adaptation | Why |
|---|---|---|
| `attach-session` | `harness-cli attach` / `attach-window` (compositor) | The GUI is the primary attached client; terminal attach is the remote/SSH path |
| `start-server` / `kill-server` | `harness-cli start-server` (ensure via launchctl) / `kill-server` (SIGTERM; launchd KeepAlive respawns with sessions restored — `launchctl bootout` for a permanent stop) | launchd supervises the daemon; pretending otherwise would lie |
| Grouped-session **layout** sharing | Window *create/kill* propagates; per-window split layouts may diverge between members | tmux shares one window object; Harness links windows (clones sharing live surfaces) — the model that also powers `link-window` |
| `default-terminal` | Aliases the `terminal-identity` option | TERM is pinned (`xterm-256color`); identity (TERM_PROGRAM/XTVERSION) is the meaningful adjustable |
| `set-titles` | Applies to the **outer** terminal of attach clients (OSC 2) | The GUI owns native window titles |
| `find-window` multi-match | Focuses the first match in snapshot order | tmux opens a picker; a filtered chooser may come later |
| `session_attached` | Count of identified daemon clients | Harness has no per-session attach registry; the GUI attaches everything |
| Option scope flags | `-w` = workspace, `-t` = tab (tmux's window), `-T <target>` for explicit targets | Harness has a workspace level above sessions; documented in COMMANDS.md |

## Rejected (with rationale)

| tmux | Why not |
|---|---|
| `escape-time` | No escape-sequence ambiguity to time out: input parsing is event-based (GUI) / Kitty-keyboard-aware, not raw-byte-timing |
| `terminal-overrides` | Harness owns its renderer; there is no terminfo negotiation layer to override |
| `suspend-client` | No terminal-suspend concept for a GUI window or the compositor |
| `customize-mode` | Settings (GUI) is the customize surface |
| `pane-mode-changed` hook | Copy-mode state is client-local by architecture (GUI overlay / compositor); the daemon never sees mode entry |
| `aggressive-resize` | Inherently on: surfaces are sized by per-surface client votes, so only clients actually viewing a window vote |

## Deferred (tracked, unimplemented)

- `window-size` (smallest/largest/latest vote aggregation) + `resize-window` manual override
- `destroy-unattached` enforcement
- `word-separators`, `wrap-search` (copy-mode engine plumbing)
- `status-interval` (status refresh is currently event-driven)
- `find-window` multi-match picker; `-C` content search from hooks (front-ends only today)
- `list-*` `-F` format-string output (rows are fixed-shape + `--json`)
- `#{session_group}` context fill in clients (helper landed with grouped sessions; the
  one-line fills ride the format-variable PR)
- CLI flag for `new-session -t` (the command form covers it)

## Invariants this ledger protects

1. **No silent misroutes.** An unrecognized or unresolvable `-t` errors loudly in every
   front-end (parse-time for nonsense, resolve-time for missing names). v1.7.1 policy.
2. **One mechanism for config migration.** `source-file` takes a `.tmux.conf`'s bind/set/
   setw/setenv lines unchanged (`TmuxMigrationTests`).
3. **Adaptations are documented here before they ship.** If behavior diverges from tmux
   and this file doesn't say why, that's a bug in this file.
