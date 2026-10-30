# playwright-cli session continuity

> Load only for `playwright-cli` exploration / verification rounds, not for writing `.spec.ts`. Parent: `rules/playwright/pw-coding-standards.md`.

A headless `playwright-cli` session shuts down after 1 hour idle; if a context compaction or long pause exceeds that, the browser dies and every element ref is lost. Open each round with both flags:

```bash
playwright-cli -s={feature} open <app-url> --idle-timeout=0 --persistent
```

- Pass the flags on the `open` that starts the round, and reuse the same `-s={feature}` name for every later command.
- `--persistent` keeps the profile (cookies/login) on disk at `~/Library/Caches/ms-playwright/daemon/<hash>/ud-{session}-chrome`; it survives `close`, only `delete-data` removes it.
- If only auth needs to survive, `state-save auth.json` / `state-load auth.json` is lighter.

---
