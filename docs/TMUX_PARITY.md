# tmux parity — status, adaptations, and deliberate divergences

Kouen targets **capability parity** with tmux, not byte-for-byte emulation: Kouen is a
native GUI terminal with a daemon-owned session model, so a handful of tmux concepts are
*adapted* to that architecture and a few are *rejected* with rationale. This document is
the single honest ledger. Updated last for the 2026-06 parity close-out series
(PRs #102–#108); user-facing usage lives in
[MULTIPLEXER_GUIDE.md](MULTIPLEXER_GUIDE.md), grammar in [COMMANDS.md](COMMANDS.md).

## At parity

| Area | Notes |
|---|---|
| Sessions / windows / panes | Full lifecycle: new/kill/rename/select/move/swap/link/unlink/break/join/respawn (pane **and** window), renumber, last-window/pane, rotate, zoom, layouts (incl. main-horizontal/vertical), `synchronize-panes` |
| **Grouped sessions** | `new-session -t <session>` (CLI: `--group-with`): shared window list, per-member focus (a new member starts on the group's current window); window create/kill propagates group-wide — kill matches by surface overlap, so it still propagates after members' split layouts diverge. Built atop linked windows — see ADAPT below |
| Targeting | Full `-t` grammar everywhere (`session:window.pane`, `$`/`@`/`%` ids, indexes, `!`, `{last}`, `{top}/{bottom}/{left}/{right}`, `^`/`$`), with `base-index`/`pane-base-index`. STRICT resolution: a named component that doesn't match makes the command `.unresolved` at the one translator choke point, so *every* targeted verb (kill/respawn/send-keys/…) fails loudly in every front-end — never a silent misroute. `swap-pane` takes `-s` too |
| Copy mode | vi + emacs tables (`copy-mode-vi` accepted as the vi table's name), `-X` action set (motions, selection, rectangle, search, prompt jumps, copy-pipe), mouse, in GUI **and** the `attach-window` compositor |
| Paste buffers | set/get/list/delete/paste/choose, save/load (CLI), bindable verbs |
| Options | Scoped store (global/workspace/session/tab/pane + fallback chain), `set`/`setw`/`show` bindable, status-line set, styles, monitoring, `display-time`, `set-titles(+string)`, `detach-on-destroy`, `remain-on-exit`, `repeat-time`, … |
| Hooks | `set-hook`/`show-hooks` + full lifecycle events: after-* command events, `session-created/renamed/closed`, `window-renamed/linked/unlinked/layout-changed`, alert-activity/silence/bell, client-attached/detached, pane-exited (+ Kouen-only agent events) |
| Format strings | ~50 `#{…}` variables (pane/session/window/client/server) + operators (`#{?,,}`, `==`, `m:`, `s///`, `e\|op\|`, `=N:` truncation, `time:` strftime). IDs render with target-grammar prefixes so they round-trip into `-t` |
| Key tables | root/prefix/copy-mode(+emacs)/command + `switch-client -T` modal tables, `bind -r` repeat, tombstoned unbinds |
| Scripting | `send-keys`, `capture-pane` (+ ranges/escapes), `pipe-pane`, `run-shell`, `if-shell`, `wait-for -S/-L/-U`, `display-message`/`show-messages`, `command-prompt`, `confirm-before`, `source-file` (a `.tmux.conf`'s bind/set/setw/setenv lines parse as-is), choose-tree/session/window/buffer/client, `find-window`, control mode (`-CC`) |
| Misc | display-popup/menu, clock-mode, lock-client, multi-client smallest-size voting, environment tables (global/session) |

## Adapted (same capability, Kouen-shaped)

| tmux | Kouen adaptation | Why |
|---|---|---|
| `attach-session` | `kouen-cli attach` / `attach-window` (compositor) | The GUI is the primary attached client; terminal attach is the remote/SSH path |
| `start-server` / `kill-server` | `kouen-cli start-server` (ensure via launchctl) / `kill-server` (SIGTERM; launchd KeepAlive respawns with sessions restored — `launchctl bootout` for a permanent stop) | launchd supervises the daemon; pretending otherwise would lie |
| Grouped-session **layout** sharing | Window *create/kill* propagates (overlap-matched, divergence-safe); per-window split layouts may diverge between members. Killing the group's LAST window leaves each member an independent default window (Kouen sessions never die from a window kill; tmux would destroy the whole group) | tmux shares one window object; Kouen links windows (clones sharing live surfaces) — the model that also powers `link-window` |
| `default-terminal` | Aliases the `terminal-identity` option | TERM is pinned (`xterm-256color`); identity (TERM_PROGRAM/XTVERSION) is the meaningful adjustable |
| `set-titles` | Applies to the **outer** terminal of attach clients (OSC 2) | The GUI owns native window titles |
| `find-window` multi-match | Focuses the first match in snapshot order | tmux opens a picker; a filtered chooser may come later |
| `find-window` default scope | Bare default searches window name + title; pane content needs an explicit `-C` (tmux's bare default is the full `-CNT`); `-t <session>` scopes the search to one session (a `-t` naming a missing session matches nothing, never a silent global search) | Content search captures every pane — opt-in keeps the common name search snapshot-cheap |
| `window-layout-changed` hook | Fires on explicit layout verbs (select/next/previous-layout, rotate); splits/kills/resizes fire their own `after-*` events instead | One event per user intent — tmux fires it for every geometry change |
| `respawn-window` / `respawn-pane` `-k` | `-k` clears scrollback history; panes respawn regardless of running state | tmux's `-k` kills a still-running command (Kouen respawn always replaces the process) |
| `refresh-client` | Re-pulls options + snapshot; tmux's size/flag arguments are ignored | Client geometry is vote-driven (see `aggressive-resize`) |
| `set-option` scopes | Bare `set` defaults to **global** (tmux: the current session); `-s` selects the **session** scope (tmux: server). tmux's server scope ≈ Kouen global | One fallback chain (pane→tab→session→workspace→global) instead of two option trees |
| `session_attached` | Count of registered daemon clients (subscription **or** identify) | Kouen has no per-session attach registry; the GUI attaches everything |
| Option scope flags | `-w` = workspace, `-t` = tab (tmux's window), `-T <target>` for explicit targets | Kouen has a workspace level above sessions; documented in COMMANDS.md |

## Rejected (with rationale)

| tmux | Why not |
|---|---|
| `escape-time` | No escape-sequence ambiguity to time out: input parsing is event-based (GUI) / Kitty-keyboard-aware, not raw-byte-timing |
| `terminal-overrides` | Kouen owns its renderer; there is no terminfo negotiation layer to override |
| `suspend-client` | No terminal-suspend concept for a GUI window or the compositor |
| `customize-mode` | Settings (GUI) is the customize surface |
| `pane-mode-changed` hook | Copy-mode state is client-local by architecture (GUI overlay / compositor); the daemon never sees mode entry |
| `aggressive-resize` | Inherently on: surfaces are sized by per-surface client votes, so only clients actually viewing a window vote |
| `server-access` | The daemon is single-user by construction: the control socket is 0600 and every connection is peer-credential-checked against the owning UID — there is no multi-user surface to ACL |

## Deferred (tracked, unimplemented)

- `status-interval` (status refresh is currently event-driven)
- `find-window` multi-match picker (currently focuses first snapshot-order match)
- `word-separators` for copy-mode word motions (double-click uses it; copy-mode w/b/e does not yet read the option)

## Implemented (previously deferred, now shipped)

- ✅ `window-size` option (smallest/largest/latest) — `DaemonServer.applyEffectiveSize` reads the option
- ✅ `resize-window -x/-y` — `IPCMessage.resizeWindow` + SurfaceRegistry handler
- ✅ `destroy-unattached` — enforced in `SurfaceRegistry.fireClientDetached`
- ✅ `word-separators` — double-click word selection; `OptionStore` default `" \t"`
- ✅ `wrap-search` — copy-mode `CopyModeState.wrapSearch`, `matchIndex(wrap:)`
- ✅ `find-window -C` from hooks — `DaemonCommandExecutor` does inline capturePane
- ✅ `list-*` `-F` format-string + `--json` — all four list commands in `MainExecutor`
- ✅ `clear-history` — `IPCMessage.clearHistory` → `RealPty.clearHistory()`
- ✅ `show-prompt-history` — `CommandPromptController.shared.historyEntries` via display-message
- ✅ `list-sessions`, `list-windows`, `list-panes`, `list-clients` commands added

## Invariants this ledger protects

1. **No silent misroutes.** An unrecognized or unresolvable `-t` errors loudly in every
   front-end (parse-time for nonsense, resolve-time for missing names). v1.7.1 policy.
2. **One mechanism for config migration.** `source-file` takes a `.tmux.conf`'s bind/set/
   setw/setenv lines unchanged (`TmuxMigrationTests`).
3. **Adaptations are documented here before they ship.** If behavior diverges from tmux
   and this file doesn't say why, that's a bug in this file.
