---
feature: 20 — Picker Enhancements (⌘↩ + zoxide)
status: approved
---

## Decisions

### D1 — ⌘↩ opens new tab at selected dir (⌘⇧J only)
- `↩` = `cd` in current terminal (existing)
- `⌘↩` = `addTab(to: activeWorkspace, cwd: selectedPath)`
- Recipes (⌘⇧R) not affected — no new-tab concept for commands

### D2 — Zoxide as primary data source for ⌘⇧J
- Query `zoxide query --list` async after model init
- Merge: zoxide-ranked first, then Harness-only dirs not in zoxide
- FrecencyDirectoryStore kept as fallback (zoxide not installed → still works)

### D3 — fzf / fd / rg: out of scope
- fzf = TUI picker, GUI already provides that layer
- fd = filesystem search, different use case
- rg = text search, not dir/recipe relevant
