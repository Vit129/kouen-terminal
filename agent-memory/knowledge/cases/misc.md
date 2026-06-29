# CASE — Git / FS / Terminal / Architecture

Grep target: `grep -n "CASE-\|<keyword>" knowledge/cases/misc.md`

## Git / File System

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-009 | Git panel not updating in real-time | DispatchSource on `.git` dir + 500ms debounce |
| CASE-015 | File tree 3s polling wastes CPU | FSEvents watcher + reconcile in-place (preserve expand state) |
| CASE-016 | Nested file add/delete not detected | FSEventStreamCreate on rootPath (recursive); Unmanaged for @convention(c) |
| CASE-020 | Branch chip stale after git checkout | Run git rev-parse at end of loadRoot() |
| CASE-021 | Git Changes panel not real-time | FSEventStreamCreate on rootPath (same WatcherContext pattern) |
| CASE-022 | File preview doesn't update on disk change | FileChangeWatcher (single-file DispatchSource, 0.3s debounce) |

## Terminal / Renderer / Daemon

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-011 | AnyCodable no subscript for nested access | Pattern-match: `if case let .object(inner) = dict["key"]` |
| CASE-017 | Folder expand state resets on refresh | Move isExpanded to @Observable FileTreeNode (survives reconcile) |
| CASE-019 | Terminal selection highlight invisible | Pass selectionBackground from theme in FrameBuilder.init |
| CASE-023 | Garbled TUI (interleaved status fragments) | Don't clear synchronizedOutput in resetForShellPrompt; use 150ms timeout |
| CASE-033 | Tool-injected names appear as OSC 2 title | Strip suffix in daemon updateTabTitle; change pane-border-format default |

## Architecture / Keybindings

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-034 | Keybinding in banner doesn't match menu binding | Centralize in `BannerShortcutRegistry.Keybinding` struct — single source of truth |

## Command Prompt / Parser

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-042 | :z/:view/:edit/:agent etc throw unknownCommand | Add verb to `CommandParser.buildCommand` + `knownVerbs`. See `knowledge/architecture/command-prompt.md` |

## Claude Code / Tooling / Environment (the agent running *inside* Harness)

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-057 | statusLine + advisor + remote-control all "broke after Harness migration" | NOT Harness. `~/.claude/settings.json` had invalid `skillOverrides.deep-research:"disabled"` (valid: `on\|name-only\|user-invocable-only\|off`). CC **2.1.195** skips the **whole** file on one bad value → every setting ignored. Fix: `"disabled"`→`"off"`. Verified statusLine 0→36 invokes |

**CASE-057 diagnostic technique (reusable):** symptoms that look like a Harness regression
may be a rejected `~/.claude/settings.json`. The `SettingsError` startup dialog is invisible
in background/`-p`/already-running sessions. Force a real PTY to see it:
```bash
rm -f /tmp/sl.log
script -q /dev/null claude >/tmp/out 2>&1 </dev/null &   # real PTY → TUI → startup dialog
SPID=$!; ( sleep 9; kill "$SPID" 2>/dev/null; pkill -P "$SPID" 2>/dev/null ) & wait "$SPID" 2>/dev/null
sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' /tmp/out | grep -A3 SettingsError   # ← the rejected file + key
```
Gotchas: `/model` *writes* settings.json fine (persistence works; only *loading* fails — don't
conclude "not writable"). `defaultToAgentsView:true` in `~/.claude.json` makes bare `claude`
open the agents dashboard (renders `subagentStatusLine`, not `statusLine`). To prove invocation,
wrap the command `bash -c 'echo called >>/tmp/sl.log; cat | bash <script>'` and count calls.

Two of the three symptoms were **separate, not part of the settings reject** (don't over-attribute):
- **advisor "Off" every session = by design** — schema has `advisorModel` (which model) but NO
  enable-persist field; on/off is a per-session toggle. Enable with `/advisor` each session.
- **remote-control = separate re-auth** — `~/.claude/daemon-auth-status.json` `auth_required` +
  `bridgeOauthDeadFailCount` (cooldown via `bridgeOauthDeadExpiresAt` in `~/.claude.json`). Fix:
  run `claude --remote-control` once to re-login. Independent of the settings.json bug.
