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

## Session mode: cloud / Remote Control / local

Every Claude Code session Kouen starts (new pane via `kouenSpawnAgent`, `kouen-cli wake`,
Automations, the ViEx spawn command) and every History resume reads `claudeSessionMode` from
`settings.json`:

| `claudeSessionMode` | New session | Resume from History |
|---|---|---|
| `"cloud"` (default) | `claude --cloud` | `claude --resume <id> --remote-control …` |
| `"remote-control"` | `claude --remote-control --remote-control-session-name-prefix kouen` | same as cloud |
| `"local"` | `claude` | `claude --resume <id>` |

- **cloud**: the agent runs in an Anthropic cloud container. The Kouen pane is a client for it,
  and the CLI syncs this folder's files (uncommitted changes included) both ways. The session
  appears in the Claude Desktop/mobile apps and at claude.ai/code without any extra flag.
  Local MCP servers, local hooks and `$KOUEN_SURFACE` notifications do **not** run inside the
  cloud container.
- **remote-control**: the agent runs in the Kouen pane on this Mac (local files, MCP, hooks all
  work) and the same session can be driven from the Claude app. The Mac has to stay awake and online.
- Resuming a *local* transcript can't go to the cloud (`--cloud` only takes cloud session IDs),
  so cloud mode resumes with Remote Control instead.

Headless runs (`kouenCCRun`, `claude -p`) aren't affected.

## The reverse direction: a session opened in Claude showing up in Kouen

History (sidebar tab, `kouen history`) always scanned local transcripts
(`~/.claude/projects/*.jsonl`) — a session started from Claude Desktop on this Mac already
showed up there. The gap was `--cloud` sessions: they never write a transcript to this disk,
so the JSONL scan alone can't see them.

`AgentHistoryScanner` now also runs `claude agents --json` and merges its rows into History by
session id:

| `kind` from `claude agents --json` | Shows up as | Resume command |
|---|---|---|
| `cloud` | ☁️ Cloud badge | `claude --cloud <id>` |
| `background` (`claude --bg`) | ⌁ Background badge | `claude attach <id>` (id not verified against a real `--bg` session) |
| `remote-control` | 📱 Remote Control badge | ordinary `--resume`/`ClaudeSessionMode` path |
| `interactive` | *(skipped)* | already covered by the JSONL scan; merging it in too would just risk a duplicate row |

Best-effort: if `claude` isn't installed, isn't logged in, or the call times out (5s), History
just falls back to what the transcript scan alone would show — nothing crashes or blocks on it.
