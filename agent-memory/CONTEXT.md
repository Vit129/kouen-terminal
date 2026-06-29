# Context — harness-terminal

## Now
- **Task:** CPU peaks + memory guards session ✅
- **Branch:** `main`
- **Status:** 3 perf commits + 1 guard commit pushed. Patch release in progress.

### 2026-06-29 — CPU/memory hardening

**Root cause:** Every daemon snapshot commit fired all UI observers **twice**:
- Phase-1: `DaemonClient` posts `postSnapshotChanged(revision:)` — no typed payload → fallback `(structureChanged=true, metadataOnly=false)` → full work before data changed
- Phase-2: `DaemonSyncService` applies snapshot → posts `postSnapshotChanged(payload:)` with real flags → correct work

**Fix commits (all on main, pushed):**
| Commit | What |
|--------|------|
| `5cbbe82` | `guard note.userInfo?["payload"] is SnapshotChangedPayload` in 5 UI observers (ContentAreaVC, MainSplitVC, BoardVC, StatusLineView, SettingsModel) |
| `ffb059a` | `SnapshotCoalescer` in `SessionCoordinator` — burst Phase-1 pings → 1 `scheduleSnapshotRefresh()` per runloop turn |
| `ffb059a` | `FrecencyDirectoryStore` capped at 500 entries; `evictTail()` drops lowest-scored on overflow |
| `81fe735` | `check_retire_coverage.py` gains `--mode filter`; Leak D robot test enforces snapshot-sweep pattern for `NotificationCoordinator` |

**Key pattern:** Phase-1 ping guard = `note.userInfo?["payload"] is SnapshotChangedPayload`. SessionCoordinator intentionally handles Phase-1 (needs it to schedule sync), but now coalesced.

---

## Previous
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
