# Pi → Harness

```bash
harness-cli install-hooks pi
```

Writes `~/.pi/hooks.json`:

```json
{
  "notify": "PATH=\"$HOME/Library/Application Support/Harness/bin:$PATH\" harness-cli notify --surface \"$HARNESS_SURFACE\" --title \"Pi\""
}
```

If your Pi build uses a different hook config path, copy the same JSON to
the correct location manually.

The dot color for Pi panes is `#b48cff`.
