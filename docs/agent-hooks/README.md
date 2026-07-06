# Agent hooks for Kouen

Wire your coding agent to surface notifications in Kouen.

## Per-agent guides

| Agent | One-line install | Real mechanism | Doc |
| --- | --- | --- | --- |
| Claude Code | `kouen-cli install-hooks claude-code` | `~/.claude/settings.json` event hooks | [claude-code.md](claude-code.md) |
| Codex | `kouen-cli install-hooks codex` | `~/.codex/hooks.json` event hooks | [codex.md](codex.md) |
| Cursor Agent | `kouen-cli install-hooks cursor` | `~/.cursor/hooks.json` `stop` hook | [cursor.md](cursor.md) |
| Grok Build | `kouen-cli install-hooks grok` | `~/.grok/hooks/kouen.json` | [grok.md](grok.md) |
| OpenCode | `kouen-cli install-hooks opencode` | `~/.config/opencode/plugins/kouen.js` | [opencode.md](opencode.md) |
| Pi | `kouen-cli install-hooks pi` | `~/.pi/agent/extensions/kouen.ts` | [pi.md](pi.md) |
| Hermes | `kouen-cli install-hooks hermes` | `~/.hermes/config.yaml` (consent) | [hermes.md](hermes.md) |
| OpenClaw | `kouen-cli install-hooks openclaw` | `~/.openclaw/openclaw.json` (JSON5) | [openclaw.md](openclaw.md) |

Each command writes the agent's **real** config format (researched per tool),
backs up any existing file first, and is idempotent — re-running it converges to
the current Kouen hook instead of duplicating it, and cleans up files an older
Kouen wrote at now-wrong paths. Hermes and OpenClaw need a one-time manual step
(consent / merging into an existing `hooks` key) — see their guides.

Kouen also recognizes `aider`, `gemini`, and `goose` automatically (status
dot colors per agent), but those tools don't have built-in hook protocols —
use the manual `kouen-cli notify` snippet from your shell or a `precmd`
hook to surface their state.

Installed hook commands prepend Kouen's app-support `bin` directory to
`PATH`, so notifications still work when an agent subprocess does not load your
interactive shell profile.

## Set up via your IDE (copy/paste prompt)

If one-click install can't reach a tool, open **Settings ▸ Agents ▸ Set up via your
IDE** and click **Copy Setup Prompt**, then paste it into any coding agent/IDE
running on the Mac (Claude Code, Cursor, Codex, …). The prompt instructs the agent
to run `kouen-cli install-hooks <tool>` (or write the hook config by hand if the
CLI isn't installed) so it wires up its own Kouen notifications.

## CLI notification

```bash
kouen-cli notify --surface "$HARNESS_SURFACE" --title "Claude" --body "Needs approval to run tests"
```

## OSC sequences (from terminal output)

Kouen recognizes standard notification OSC sequences (9, 99, 777) emitted by agents and terminals.

## Jump to waiting agent

Press `Cmd+Shift+I` in Kouen to open the Agent Notch and select the notifying agent, press
`Cmd+Shift+U` for the notifications inbox, or run:

```bash
# Use the command palette (Cmd+P) → jump-notification
```

## Example Claude Code hook

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "PATH=\"$HOME/Library/Application Support/Harness/bin:$PATH\" kouen-cli notify --surface \"${HARNESS_SURFACE:-default}\" --body \"Agent finished — review output\""
      }]
    }]
  }
}
```
