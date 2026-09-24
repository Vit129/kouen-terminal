# Claude Code → Kouen

Make Claude Code surface its `Notification` and `Stop` events as Kouen pane
notifications (tab-pill working dot, sidebar bell, and macOS notification banner), so you
can leave a long edit running and pop back when it's actually waiting on you.

## One-line install

```bash
kouen-cli install-hooks claude-code
```

This writes `~/.claude/settings.json` (backing up any existing file as
`settings.json.kouen-bak-<timestamp>`).

## What gets written

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "PATH=\"$HOME/Library/Application Support/Kouen/bin:$PATH\" kouen-cli notify --surface \"$KOUEN_SURFACE\" --title \"Claude Code\" --from-hook"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "PATH=\"$HOME/Library/Application Support/Kouen/bin:$PATH\" kouen-cli notify --surface \"$KOUEN_SURFACE\" --title \"Claude Code\" --body \"Done\" --status done"
          }
        ]
      }
    ]
  }
}
```

`$KOUEN_SURFACE` is exported by Kouen for every pane, so the hook always
notifies the right tab. Claude Code passes the `Notification` message as JSON on
the hook's **stdin** (not an env var), so `--from-hook` reads that stdin and uses
its `message` field for the notification body.

## Verifying

1. Open a new Kouen pane, run `claude` and start a long task.
2. While it's working, the tab pill's status dot turns Anthropic violet
   (Kouen detected `claude` in the process tree).
3. When Claude Code emits a permission request or finishes, you see:
   - macOS notification banner.
   - The tab pill's working dot lights up (waiting state).
   - "Claude Code: <message>" in the sidebar card meta line.
4. Press `Cmd+Shift+I` to open the Agent Notch and select the pane, or `Cmd+Shift+U` for the notifications inbox.

## Customizing

Edit `~/.claude/settings.json` directly — you can match specific tools or
pre/post events by following the standard Claude Code hook schema. `install-hooks`
is idempotent and self-healing: re-running it replaces Kouen's own
`Notification`/`Stop` entries with the current versions (handy for picking up
fixes) while leaving the rest of your config — model, permissions, MCP, and any
non-Kouen hooks — untouched.

## Session mode: Remote Control / cloud / local

Every Claude Code session Kouen starts (new pane via `kouenSpawnAgent`, `kouen-cli wake`,
Automations, the ViEx spawn command), every History resume, and — once shell integration is
installed — every `claude` you type by hand in a Kouen pane reads `agentSessionModes["claude-code"]`
(or legacy `claudeSessionMode`) from `settings.json`:

| `claudeSessionMode` | New session | Resume from History |
|---|---|---|
| `"remote-control"` (default) | `claude --remote-control --remote-control-session-name-prefix kouen` | `claude --resume <id> --remote-control …` |
| `"cloud"` | `claude --cloud` | same as remote-control |
| `"local"` | `claude` | `claude --resume <id>` |

- **remote-control** (default): the agent runs in the Kouen pane on this Mac — local files,
  Xcode, MCP servers, hooks and `$KOUEN_SURFACE` notifications all work — and the same
  session shows up in the Claude Desktop/mobile apps and at claude.ai/code. The Mac has to stay
  awake and online.
- **cloud**: the agent runs in an Anthropic cloud container (Linux: no Xcode, so it can't build
  or test a macOS app). The Kouen pane is a client for it, and the CLI syncs this folder's files
  both ways. Local MCP servers, hooks and `$KOUEN_SURFACE` notifications do **not** run in the
  container. Keeps running when the Mac sleeps.
- Resuming a *local* transcript can't go to the cloud (`--cloud` only takes cloud session IDs),
  so cloud mode resumes with Remote Control instead.

Headless runs (`kouenCCRun`, `claude -p`) aren't affected.

### A `claude` typed by hand

The daemon exports `KOUEN_CLAUDE_SESSION_MODE` into every pane, and the shell integration
(`kouen-cli install-shell-integration`, re-run it after updating Kouen) defines a `claude()`
wrapper that adds the matching flags. It:

- chains to your own `claude` function if you have one (it doesn't replace it);
- leaves the command alone when you already chose: `--cloud`, `--remote-control`/`--rc`,
  `--teleport`, `-p`, `--bg`, `--help`/`--version`, or a subcommand (`claude agents …`);
- adds Remote Control flags (not `--cloud`) to `--resume`/`--continue` in cloud mode, for the
  same reason as History resume.

`command claude` bypasses the wrapper entirely.

## The reverse direction: a session opened in Claude showing up in Kouen

History (sidebar tab, `kouen history`) scans local transcripts (`~/.claude/projects/*.jsonl`),
so anything that ran on this Mac — Claude Desktop in Local mode, a Remote Control session, a
`claude` in any terminal — shows up there.

It also runs `claude agents --json` and merges its rows by session id:

| `kind` from `claude agents --json` | Shows up as | Resume command |
|---|---|---|
| `cloud` | ☁️ Cloud badge | `claude --teleport <id>` |
| `background` (`claude --bg`) | ⌁ Background badge | `claude attach <id>` (id not verified against a real `--bg` session) |
| `remote-control` | 📱 Remote Control badge | ordinary `--resume`/`ClaudeSessionMode` path |
| `interactive` | *(skipped)* | already covered by the JSONL scan |

Cloud sessions stay listed after their pane closes: every cloud row the live scan sees is
remembered in `~/Library/Application Support/Kouen/claude-cloud-sessions.json` (30 days,
200 max) and shown in History as a ☁️ row.

**Limitation — cloud sessions started from the phone or claude.ai/code:** `claude agents --json`
only lists sessions with a client on *this* machine, and the Claude CLI has no non-interactive
way to list the account's cloud sessions. A cloud session that never had a client on this Mac
therefore can't appear in History automatically. Pull it in with `claude --teleport` (it opens a
picker of your account's cloud sessions); once teleported it has a local transcript and shows up
in History like any other session.

Best-effort throughout: if `claude` isn't found, isn't logged in, or the call times out (5s),
History falls back to the transcript scan. Kouen looks for `claude` in `~/.local/bin`,
`~/.claude/local`, `/opt/homebrew/bin`, `/usr/local/bin`, then `which`, then your login zsh's
`whence -p claude` (for npm/nvm installs the GUI app's minimal PATH can't see).
