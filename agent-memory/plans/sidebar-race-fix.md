# Plan: Fix Sidebar Race Conditions (NSTableView → Stable Data Source)

> **Problem:** `z`/`cd`/`⌘\` crash because `snapshotChanged` fires while NSTableView holds stale row count.
> **Root cause:** NSTableView + NotificationCenter = no data consistency guarantee.
> **Goal:** Eliminate all row-index-based crashes permanently.

---

## Option A: Diffable-style batch updates (smaller, safer)

Keep NSTableView but add a proper diff layer.

### Tasks
1. Create `SidebarDiffEngine` — compares old `cachedSidebarRows` vs new, produces insert/delete/move IndexSets
2. Replace all `reloadData()` calls with `beginUpdates` + `insertRows`/`removeRows`/`moveRow` + `endUpdates`
3. Guard ALL `view(atColumn:row:)` calls with `row < sessionTable.numberOfRows`
4. Add `@MainActor` assertion at entry of every sidebar update path

### Pros/Cons
- ✅ Minimal change, stays AppKit, no rewrite
- ❌ Still fragile — NSTableView API is error-prone, diffing logic adds complexity

---

## Option B: SwiftUI List migration (bigger, definitive)

Replace `sessionTable` (NSTableView) with SwiftUI `List` backed by `@Observable` model.

### Tasks
1. Create `SidebarSessionListModel: Observable` — holds `[SidebarSessionRow]`, publishes changes
2. Create `SidebarSessionListView: View` — SwiftUI List with `ForEach` over model
3. Host in `NSHostingView` inside existing sidebar container
4. On `snapshotChanged` → update model (SwiftUI diffs automatically, no manual row sync)
5. Remove all `sessionTable.reloadData()`, `rebuildSidebarRows()`, manual row iteration
6. Migrate context menus, drag-drop, selection to SwiftUI equivalents

### Pros/Cons
- ✅ Eliminates entire class of row-index crashes forever
- ✅ Automatic diffing, no manual beginUpdates/endUpdates
- ✅ Easier to maintain long-term
- ❌ Large refactor (~72KB file touches)
- ❌ SwiftUI List has performance quirks with 100+ rows
- ❌ Drag-drop and right-click menus need AppKit bridge

---

## Recommendation

**Option A now** (1-2 hours, stops the crashes) → **Option B later** (when sidebar refactor is scheduled in the God Objects decomposition plan).

---

## Immediate Patches Already Applied

| Commit | Fix |
|--------|-----|
| `e611e78` | `reloadData()` before row iteration + `min()` guard in `refreshMetadata()` |

## Remaining Risk Areas

| Location | Risk |
|----------|------|
| `updateWorktrees()` | May access table rows after worktree list changes |
| `selectActiveSessionRowIfVisible()` | Safe (uses `rowIndex(for:)` lookup) |
| `toggleGroupCollapse()` | Uses beginUpdates/endUpdates (safe) |
| Any future `view(atColumn:row:)` call | Must always guard with row count check |

---

## Definition of Done
- [ ] No crash on: rapid `z` navigation, `cd` to new repo, `⌘\` toggle after tab close
- [ ] Stress test: open 5 tabs, close 3 rapidly while `z`-jumping in remaining → no crash
- [ ] All `view(atColumn:row:)` calls guarded
