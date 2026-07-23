---
name: browser-pane-local-daemon-merge
description: Recurring pattern (3rd known occurrence, 2026-06-15 -> 2026-07-23) — any daemon-driven pane-tree change silently discarded whenever a tab has a browser pane open, because browser panes are local-only and the preserve-merge condition never accounted for that.
metadata:
  type: project
  confidence: 1.0
  date: 2026-07-23
---

# Bug pattern: browser-pane preserve-merge discards real daemon changes

## Root architectural fact

Browser panes are **local-only** GUI state. `SplitPaneCoordinator.openBrowserPane`
inserts them via `applyLocalSnapshot`, which deliberately bypasses normal daemon
sync (own comment: "skip the daemon-sync re-injection that would otherwise
restore a just-closed browser pane"). The daemon's own pane tree **never**
contains a browser leaf, by design, for any tab that has one open.

`DaemonSyncService.applySnapshot`'s "preserve browser panes across sync" merge
has to compensate for this on every incoming snapshot. The compensating
condition has been wrong twice now, in two different ways, because both times
it was written as "does the incoming tree lack browser leaves" instead of "did
the daemon-side *terminal* structure actually change" — the former is always
true for any tab with a browser pane open, so it always fires.

## Occurrence 1 — 2026-06-15 (`b76fb0dd`)

**Symptom:** Clicking the browser pane's own close (×) button did nothing.
**Cause:** The merge ran for `applyLocalSnapshot` too (the same path
`closeBrowserPane` uses to record "browser leaf removed"), so the close
button's own updated snapshot — with the browser leaf already gone — got
immediately overwritten by the *previous* snapshot, which still had it.
**Fix applied:** Added a `preserveBrowserPanes: Bool = true` parameter and had
`applyLocalSnapshot` call `applySnapshot(..., preserveBrowserPanes: false)` —
an **opt-out for that one caller**, not a fix to the merge condition itself.
The condition (`if incoming has no browser leaves, keep local tree wholesale`)
was left exactly as broken for every other caller, including the plain
`sync()` path used by every daemon-driven refresh (subscription push,
periodic poll, and any GUI action that goes through `requestDaemon` + resync
— e.g. a keyboard-shortcut split).

## Occurrence 2 — 2026-07-23 (this session)

**Symptom:** Pressing ⌘D / ⌘⇧D ("Split Right"/"Split Down") while focused in an
open browser pane did **nothing at all** — no new pane anywhere, no error
logged. Root-caused after 2 disproven hypotheses (WKWebView swallowing the
key event — real but separate, already fixed) and a Fable consult, because
"the daemon call succeeded and was then silently reverted" produces the exact
same UI symptom as "the shortcut never fired." `splitActivePane` → `.newSplit`
→ daemon succeeds → `syncFromDaemon()` → `applySnapshot` (the plain `sync()`
path, `preserveBrowserPanes: true`) → same broken condition → the daemon's new
split gets thrown away before it ever renders.

**Fix applied this time (the actual root cause, not another opt-out):**
`DaemonSyncService.mergedRootPane` (extracted, testable, `nonisolated static`)
now compares the daemon's incoming tree against the **local tree with browser
leaves already stripped out** (`SplitPaneCoordinator.removePaneNode`) — only
keeps the local tree wholesale when that stripped structure genuinely matches;
otherwise adopts the daemon's tree and re-attaches each browser leaf at root
level. See `agent-memory/knowledge/rl-lessons.md` RL-068 for the terse rule.
Regression test: `Tests/KouenAppTests/DaemonSyncServiceBrowserPaneMergeTests.swift`.

Related, same-session, same root architectural fact (browser panes are
daemon-unknown): `SplitPaneCoordinator.splitActivePane`'s fallback pane target
used `allPaneIDs()` (includes browser leaves) instead of `allLeaves()`
(terminal-only) — could target the browser's own daemon-unknown paneID.
`SessionCoordinator.setSplitRatio` unconditionally asked the daemon to persist
a divider ratio even when one side was a browser leaf, failing every time with
`"Split not found"` and spamming the "Reconnecting to KouenDaemon" toast.

## Lesson for the next occurrence

If a 3rd bug in this exact area shows up again: **do not add another
per-caller opt-out flag.** Two of these three incidents trace back to the same
one-line condition (`incomingBrowserLeaves.isEmpty`) being the wrong test.
Check `DaemonSyncService.mergedRootPane` and its one call site first — if it's
been re-broken (e.g. someone reintroduces the old inline condition, or a new
caller bypasses `mergedRootPane` with its own ad-hoc merge), that is almost
certainly the cause before looking anywhere else. If the symptom is instead
"the daemon call itself never happens," check `splitActivePane`/`setSplitRatio`
for a new fallback path that resolves to a browser leaf's paneID again.
