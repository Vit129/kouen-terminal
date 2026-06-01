# OpenClaw → Harness

```bash
harness-cli install-hooks openclaw
```

Writes `~/.openclaw/hooks.json`:

```json
{
  "notify": "PATH=\"$HOME/Library/Application Support/Harness/bin:$PATH\" harness-cli notify --surface \"$HARNESS_SURFACE\" --title \"OpenClaw\""
}
```

The dot color for OpenClaw panes is `#f5a623`.
