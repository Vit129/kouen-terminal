# Context — harness-terminal

## Now
- **Task:** idle
- **Branch:** `main`

### 2026-06-29 — Claude Code statusLine/advisor/remote-control "broke after migrate" ✅

**User report:** statusLine, advisor, remote-control all stopped after the SwiftUI
settings migration → blamed the migration. **It was NOT the migration.**

**Root cause:** `~/.claude/settings.json` had `skillOverrides.deep-research: "disabled"`
(invalid; valid = `on|name-only|user-invocable-only|off`). **Claude Code 2.1.195**
(updated Jun 28) tightened validation and now **skips the ENTIRE settings.json** on any
single invalid value → `statusLine`, `advisorModel`, `remoteControlAtStartup`, `tui`,
`model` all ignored. Timing coincided with the Harness migration → looked migration-caused.

**Fix:** `"disabled"` → `"off"`. Verified: statusLine invocation 0 → 36 calls.

**Diagnostic that cracked it:** `script -q /dev/null claude` (real PTY) surfaced the
`SettingsError` startup dialog — invisible in background/`-p` sessions. See
`knowledge/cases/misc.md` CASE-042.

**Secondary (separate) issues:** remote-control needs re-auth (`daemon-auth-status.json`
= `auth_required`, cooldown expired → `claude --remote-control`); advisor on/off is a
per-session toggle by design (no persist field — only `advisorModel` persists).

---

## Previous
- **Task:** CPU peaks + memory guards session ✅ (`5cbbe82`, `ffb059a`, `81fe735` on main)
  - Phase-1/Phase-2 double snapshot fanout → payload-type guard in 5 UI observers + SnapshotCoalescer
- **Task:** tab-switch black screen ✅
- **Commits:** `f6a0182`, `2b9295d`, `1a2ca4c`, `9c5c1fa`, `0a5f2fe` on main (squash-merged from fix branch)
- **4 failure modes fixed:** detach-then-cache, structural rebuild caches empty shell, host theft, orphan overwrite

### Previous sessions (abbreviated)

| Date | Task | Key outcome |
|------|------|-------------|
| 2026-06-29 | Notch animation CPU | SwiftUI AnimatableFrameAttribute → CAShapeLayer/CABasicAnimation (`9d49488`) |
| 2026-06-27 | otty-features P1–P20 | All phases shipped; P13/P21 deferred |
| 2026-06-26 | Memory-leak audit | existingHosts pin, BrowserPaneView cap, AI controller retire → v3.9.4 |
| 2026-06-26 | cwd bleed | deepestReadableDescendant removed; shell pid direct |
| 2026-06-25 | harness view | OSC 7735 → sidebar file viewer |
| 2026-06-23 | Sidebar SwiftUI | NSTableView removed; VC 1676 → 890 lines |

## Unresolved
- Pre-existing robot failure: "Bug 1 - Browser Pane Reuse On Rebuild" (BrowserIntegrationController refactor changed call sites)
