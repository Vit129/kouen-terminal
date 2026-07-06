# Migrating to Kouen

Kouen has tested migration paths for terminal config import and **tmux**
commands/keybindings. Both rest on first-party code — no plug-ins.

## Import Terminal Colors And Fonts

Kouen reads compatible source terminal configs so your colors and font carry over on day one.

**What's imported** (`TerminalConfigImporter`, covered by `TerminalConfigImporterTests`):
colors (background/foreground/cursor/selection/bold/cursor-text), the 16-color ANSI palette,
font **face**, `background-opacity`, `background-blur`, window padding, cursor style, cursor
blink, copy-on-select, and the default shell.

**What's not imported:** the font **size** is Kouen-owned (default 16) — a terminal's size
preference doesn't carry over, only the face does.

**Sources tried:** the importer checks its supported compatibility paths in order and
merges matches, with later files overriding earlier files.

Import happens automatically on first run and is re-applied when the source config's
fingerprint changes. Re-import manually any time:

- **Settings → Appearance → Reset to defaults** (re-seeds from the imported config), or
- the `source-config` command (prefix `r` in Full Terminal mode).

Comment lines start with `#`; `#` is **not** stripped from values (so hex colors survive).

### Make Kouen the default terminal

macOS does not expose one universal "default terminal" switch. Kouen registers the
Launch Services handlers terminal users expect: SSH links, Telnet links, man-page links,
and `.command` / `.tool` files. Set them from **Settings → Terminal → Default terminal**.

Opening one of those links or files creates a new Kouen tab. SSH/Telnet/man-page URLs run
the matching command, directories open as the tab's working directory, and command files run
from their parent directory.

## From tmux

Switch to **Full Terminal** mode (Settings → Terminal → Experience). Your muscle
memory works immediately:

- **Prefix key** `Ctrl-A` (change in Settings → Keys, or blank it to disable).
- **Splits / panes** — `prefix %` / `prefix "`, `prefix z` zoom, `prefix x` kill,
  `prefix` arrows to move (GUI; hjkl navigate panes in `attach-window` compositor only), `prefix o`/`;` cycle, `prefix Space` cycle layouts.
- **Copy mode**, **paste buffers**, **`-t session:window.pane` targets**, **`base-index` /
  `pane-base-index`**, **command prompt** (`prefix :`), **attach/detach**.
- **Detach / reattach** — `kouen-cli attach` (one pane) or `kouen-cli attach-window` (the
  full split layout, even over ssh); control mode via `kouen-cli -CC`.

See the [multiplexer guide](MULTIPLEXER_GUIDE.md) for the full command and shortcut tour.

### Key-by-key translation

| You'd type in tmux | In Kouen |
|---|---|
| `tmux` (start) | Just open Kouen, or `kouen-cli new-session` |
| `prefix c` / `,` / `&` | Same (new / rename / kill tab) |
| `prefix %` / `"` | Same (splits) |
| `prefix o` / `q` / `z` / `x` | Same (cycle / numbers / zoom / kill) |
| `prefix [` then vi keys | Same (copy mode) |
| `prefix d` | Same (detach) — or View ▸ Detach Pane |
| `prefix :` command-prompt | Same `:` prompt |
| `tmux a` (attach) | `kouen-cli attach-window` (full layout, incl. ssh) |
| `tmux send-keys` | `kouen-cli send-keys --surface <id> --keys "…"` |
| `tmux bind -T copy-mode-vi` | `bind -T copy-mode-vi …` (alias for the vi table; `copy-mode` and `copy-mode-vi` are interchangeable everywhere) |
| `tmux capture-pane` | `kouen-cli capture-pane --surface <id>` (`-S/-E/-e/-J`) |
| `$TMUX` set inside a pane | `$KOUEN` (and `$KOUEN_SURFACE` for the pane id) |

The default prefix differs (`Ctrl-A` vs `Ctrl-B`) — change it in Settings if you prefer `Ctrl-B`.

### Bringing your `.tmux.conf` over

One mechanism: every line runs through the same parser as the command prompt (verified by
`TmuxMigrationTests`). Put your `bind` lines, `set`/`setw` options, environment, and one-shot
commands in a file and `source-file` it — `#` comments are skipped:

```tmux
# ~/.kouen.conf  — bindings + options + commands
bind | split-window -h
bind - split-window -v
bind -r H resize-pane -L 2
set  -g status-left " #{session_name} "
set  -g base-index 1
setw monitor-activity on
setenv -g EDITOR vim
```

Scope flags in options:
- `-g` = global (like tmux)
- `-s` = session (tmux uses `-s` for the SERVER scope; Kouen's global ≈ tmux's server)
- `-w` = workspace (Kouen-specific; above the session level)
- `-t` = tab (Kouen's windows are tabs; tmux: window scope)
- `-p` = pane (like tmux)

`setw` is tab-scoped everywhere. From a source file or `:` prompt, a scoped set without `-T`
resolves against the caller's focus chain; in the CLI it resolves the calling pane's tab via
`$KOUEN_SURFACE` (outside a Kouen pane, pass `-T <target>` explicitly).

```
:source-file ~/.kouen.conf      # from the command prompt (prefix :)
```

Persistent key bindings also live in `keybindings.json` (merged over the defaults); set them
with `kouen-cli bind-key` / `unbind-key`, or edit the file directly.

Options write the same store the Settings ▸ Advanced page and `kouen-cli set-option` edit —
the CLI form requires `-T <target>` for scoped writes, while the command form (`:` prompt or source-file) resolves a
missing target against the focused workspace/session/tab/pane like tmux. Unresolvable targets (bad names in `-t`) fail loudly rather than silently falling back to focus.

```bash
kouen-cli set-option -g status-left  " #{session_name} "
kouen-cli set-option -g status-right " #{cwd_basename} #{time:%H:%M} "
kouen-cli set-option -g base-index 1
```

### Deliberate divergences

A few tmux concepts are intentionally *not* reproduced because they conflict with Kouen's
value-typed, session-owned-tabs, always-visible-sessions model — grouped sessions and some
session-lifecycle options. These are design choices, not gaps.
