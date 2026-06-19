# P24 — Supacode-Inspired Competitive Features (Consolidated)

Status: **Phase 3 Complete**
Priority: **P1** — competitive parity + agent-first UX
Owner surface: HarnessApp, HarnessCore, HarnessDaemonCore, harness-cli
Created: 2026-06-19
Absorbs: P21 (actionable agent layer), P4 follow-ups (project-aware navigation)
Depends on: none (additive to existing infra)

---

## Research Sources

- **Website:** https://supacode.sh/
- **Docs:** https://docs.supacode.sh/
- **GitHub:** https://github.com/supabitapp/supacode (1.3k stars, 98 releases, Swift/TCA/libghostty)
- **Video:** Bret Fisher (YouTube, Jun 2026) — daily driver switch from Ghostty to Supacode, solving "Tab Hell" with multi-agent workflows. Key timestamps: 08:53 (Ghostty base), 09:40 (sidebar/project management), 11:38 (GitHub PR/CI), 13:49 (agent hooks), 15:54 (worktrees), 18:24 (session persistence/ZMX), 19:11 (Superset comparison), 20:26 (OpenCode Chamber comparison)

---

## What Supacode Is (Not)

**Is:** Worktree command center — git worktree isolation + Ghostty terminal + GitHub CLI + per-project automation

**Is Not:** Full terminal (no daemon, no remote, no multiplexer, no CLI scripting, no custom engine)

Core mental model: `Repository → Worktree → Terminal State (tabs/splits/notifications)`

---

## Consolidated Gap Analysis

### From Supacode comparison (new)

| Feature | Supacode | Harness | Priority |
|---------|----------|---------|----------|
| Per-project config (`supacode.json`) | ✅ | ❌ | P0 |
| Lifecycle scripts (setup/run/archive) | ✅ ⌘R/⌘. | ❌ | P0 |
| Agent status badge in sidebar | ✅ | ❌ (detection exists, not visual) | P0 |
| Git worktree management GUI | ✅ | ❌ | P1 |
| Per-worktree terminal state | ✅ | Partial (sessions, not worktree-bound) | P1 |
| GitHub PR/CI inline | ✅ via `gh` | ❌ | P1 |
| Sidebar info density (branch+status per row) | ✅ | Partial | P1 |
| Command palette PR actions | ✅ | ❌ | P2 |
| Auto-archive merged worktrees | ✅ | ❌ | P2 |

### From P21 (agent layer — now actionable via Supacode-style approach)

| Feature | P21 Scope | Adapted for P24 | Priority |
|---------|-----------|-----------------|----------|
| Agent spawn with auto-start | PBI-ACP-003 | Setup script in `harness.json` | P0 |
| Agent selection (which agent) | PBI-ACP-005 | Config-driven, not picker UI | P0 |
| Parallel agents (subagent) | PBI-ACP-016–020 | Worktree isolation (simpler than RPC) | P1 |
| Agent status tracking | P21.1 scope | Sidebar badge per session | P0 |

**What P24 does NOT absorb from P21** (remains shelved/separate):
- ACP sideband tool access (PBI-ACP-001/004) — still needs adapter ecosystem
- Multi-provider direct API (P21.2) — orthogonal, different scope
- Persistent agent brain/skills (P21.3) — research-grade, defer
- Execution backends (P21.5) — infra project, defer

### From P4 follow-ups (project-aware navigation)

| Feature | P4 Status | Relevant to P24 | Priority |
|---------|-----------|-----------------|----------|
| `:cd` sends to shell | ✅ Done | Foundation for worktree cd | — |
| `:find` fuzzy path | ✅ Done | Foundation for project switching | — |
| `:recent` MRU | Deferred | Worktree-aware recent files | P2 |
| `:grep`, `:make` | Deferred | Run script alternative | P2 |
| `harness view` | ✅ Done | Works with worktree paths | — |

---

## Feature Specs

### F1: Project Config (`harness.json`) — P0

**What:** JSON config in repo root. Teams commit it.

```jsonc
{
  "setupScript": "claude --dangerously-skip-permissions",
  "runScript": "pnpm dev",
  "archiveScript": "docker compose down",
  "workspace": "backend",
  "env": { "NODE_ENV": "development" },
  "agent": "claude-code",
  "baseRef": "origin/main"
}
```

**Behavior:**
- Daemon reads `harness.json` when session cwd matches repo root
- `setupScript` auto-executes on new session creation (once, flag in metadata)
- `runScript` → ⌘R in dedicated "▶ RUN" surface, ⌘. sends SIGTERM
- `archiveScript` runs before session close (blocks until exit)
- `agent` field → auto-detect agent type for status tracking
- Personal override: `~/.config/harness/projects/<repo-name>.json`

**Touch points:**
- `HarnessCore`: `ProjectConfig` struct + JSON decoder
- `HarnessDaemonCore`: `SurfaceRegistry` reads on session init
- `HarnessApp`: ⌘R/⌘. keybindings in `BannerShortcutRegistry`

**Harness advantage over Supacode:** Daemon persistence — run script survives app quit + remote sessions pick up config.

---

### F2: Agent Status Badges + Auto-Start — P0

**What:** Visual agent state per session + config-driven auto-start.

**Absorbed from P21:** PBI-ACP-003 (agent spawn) + PBI-ACP-005 (agent selection) — simplified to config-driven instead of picker UI.

**States:**
- 🟢 Agent running (process active, output streaming)
- 🟡 Waiting for input (no output for >5s while process alive)
- 🔴 Errored / exited non-zero
- ⚪ No agent detected
- Numeric badge for unread notifications

**Auto-start flow:**
1. New session created at cwd with `harness.json`
2. `setupScript` = `"claude --dangerously-skip-permissions"`
3. Agent detection fires → sidebar shows 🟢
4. Agent finishes → notification + sidebar 🔴 or ⚪

**Implementation:**
- `AgentDetector` already exists → extend with `AgentStatus` enum + Combine publisher
- Sidebar `SessionRowView`: dot left, badge right
- Daemon: track agent PID per surface via existing PTY process monitoring

---

### F3: Lifecycle Scripts UX (⌘R / ⌘.) — P0

**What:** One-key run/stop for repeatable project command.

**Design:**
- ⌘R: open/reuse dedicated surface titled "▶ RUN" with `runScript`
- ⌘.: SIGTERM → SIGKILL (2s timeout) to RUN surface process group
- RUN tab: distinct icon/color in tab bar, auto-closes on clean exit (optional)
- Setup: fires once on session create (metadata flag `setupScriptRan: true`)
- Archive: fires before session close, blocks close until exit or 10s timeout

**Add to `BannerShortcutRegistry`:** ⌘R (Run Script), ⌘. (Stop Script)

---

### F4: Git Worktree-Per-Session Model — P1

**What:** Every session owns its own git worktree. Session group = repo. Branch display = worktree branch (always correct, no shared HEAD problem).

**Core invariant: 1 session = 1 worktree = 1 branch = 1 cwd**

**Mental model:**
```
Project Group: harness-terminal/        (grouped by repo origin)
├── [CC] workingtree1                   (worktree: ~/.worktrees/workingtree1/)
├── [KR] DEEP-FEATURE                  (worktree: ~/.worktrees/DEEP-FEATURE/)
├── [●]  feature1                       (worktree: ~/.worktrees/feature1/)
├── [●]  main                           (worktree: ~/project/ — default worktree)
```

**How sessions get worktrees:**
1. **New session (⌘T):** Creates in repo's default worktree (main). Branch = main.
2. **Agent creates branch:** Agent runs `git worktree add` → session cwd moves to new worktree dir → sidebar auto-updates branch display.
3. **User switches branch:** If user runs `git switch feature1` in a session that's on main → Harness detects cwd still same BUT branch changed → auto-creates worktree for isolation, moves session cwd there.
4. **Manual:** `harness-cli new-session --worktree feature-x --repo ~/Code/project`

**Sidebar grouping logic:**
- Group key = **git toplevel / bare repo origin** (not cwd)
- Detect shared repo: `git -C <cwd> rev-parse --show-toplevel` or `git -C <cwd> worktree list` → all worktrees share same `.git` (or gitdir)
- Sessions with different cwds but same repo origin = same group

**Branch detection (per-session):**
- Each session's cwd is its own worktree dir → `git -C <session-cwd> branch --show-current` gives the correct per-session branch
- No more "propagate branch to all tabs with same cwd" — each session has unique cwd

**Display:**
- Title: branch name (from session's own worktree)
- Group header: repo name (folder name of main worktree)
- Agent icon: shown when agent detected

**CLI:**
```bash
harness-cli new-session --worktree feature-x --repo ~/Code/project
harness-cli list-sessions --worktree  # filter worktree-bound sessions

# Script: spin up 5 agents in parallel
for feature in auth payments search analytics logging; do
  harness-cli new-session --worktree "$feature" --repo ~/Code/app
done
# Each session auto-starts agent via harness.json setupScript
```

**Key implementation tasks:**
1. Sidebar grouping: detect repo origin across worktree cwds (`git worktree list --porcelain`)
2. Branch display: probe branch per-session using session's own cwd (already works if cwds differ)
3. Auto-worktree on branch switch: detect `git switch/checkout` in session → create worktree if not exists → move cwd
4. Agent worktree creation: detect when agent runs `git worktree add` → session cwd follows
5. Archive: `git worktree remove` + detach session from sidebar

**Harness advantage:** daemon persistence + remote + CLI scripting. Supacode requires manual GUI interaction.

---

### F5: GitHub PR/CI Integration — P1

**What:** PR status + CI inline, via `gh` CLI.

**Requirements:** `gh` installed + authenticated

**Display:**
- Sidebar: PR badge per session row (#123 ✅/❌/🟡)
- Toolbar: PR status bar (state, check summary, merge button)
- Command palette: PR actions

**Actions:** Open PR (⌃⌘G), mark ready, merge, close, re-run failed, copy CI logs

**Implementation:**
- `HarnessCore`: `GitHubCLIClient` — wraps `gh pr view --json` + `gh run list --json`
- Poll: 30s interval per session with active branch ≠ default branch
- Graceful degradation: no `gh` = feature hidden entirely

---

### F6: Sidebar Info Density — P1

**What:** More context per session row.

**Current:** `session-name` + workspace label (one line)
**Target:**
```
[🟢] session-name                    [#42 ✅] [3]
     feature-branch · ~/Code/app
```
- Line 1: agent dot + name + PR badge + notification count
- Line 2 (dimmed, smaller): branch · short cwd
- Workspace as collapsible section header (like Supacode's repo name grouping)

---

### F7: Project-Aware Navigation (from P4 follow-ups) — P2

**What:** Terminal navigation that respects worktree/project context.

**Features:**
- `:recent` — MRU file list scoped to current session's worktree
- `⌘P` palette — show worktree files alongside zoxide entries
- `:make` — alias for `runScript` from `harness.json`
- `:grep <pattern>` — scoped to worktree root

**Already done (P4):** `:find`, `:view`, `:edit`, `gf`, `gd`, `K`, `harness view`, `harness lsp`

---

## Implementation Phases

### Phase 1 — Foundation (P0, ~2 weeks)

| # | Task | Builds on |
|---|------|-----------|
| 1 | `ProjectConfig` model + JSON parser | New in HarnessCore |
| 2 | Daemon reads `harness.json` on session cwd | SurfaceRegistry |
| 3 | Setup script auto-execute on new session | Session lifecycle |
| 4 | ⌘R / ⌘. run/stop with dedicated RUN surface | BannerShortcutRegistry |
| 5 | `AgentStatus` enum + publisher | Existing AgentDetector |
| 6 | Sidebar agent badge (dot + count) | SessionRowView |

**Exit criteria:** Create session at repo with `harness.json` → agent auto-starts → sidebar shows 🟢 → ⌘R opens RUN tab → ⌘. stops it.

### Phase 2 — Worktree-Per-Session + Sidebar (P1, ~3 weeks)

| # | Task | Builds on |
|---|------|-----------|
| 7 | Sidebar grouping by repo origin (detect shared repo across worktree cwds via `git worktree list`) | Existing group logic (replace cwd-based with repo-origin-based) |
| 8 | Per-session branch probe using session's own cwd | Existing SurfaceShellTracker + git probe |
| 9 | Auto-create worktree when agent creates branch (detect `git worktree add` in PTY output) | Session lifecycle |
| 10 | Auto-create worktree on `git switch` (detect branch change → isolate into worktree) | PTY output monitoring |
| 11 | `harness-cli new-session --worktree` (creates worktree + session + cd) | CLI extension |
| 12 | Archive/delete worktree actions in sidebar | Git commands + session lifecycle |

**Exit criteria:** Agent creates branch → session moves to worktree → sidebar shows correct per-session branch → multiple sessions in same project show different branches → `harness-cli` can script parallel worktrees.

### Phase 3 — GitHub (P1, ~2 weeks)

| # | Task | Builds on |
|---|------|-----------|
| 13 | `GitHubCLIClient` (`gh` JSON wrapper) | New in HarnessCore |
| 14 | PR status polling per session | Background task |
| 15 | Sidebar PR badge | SessionRowView |
| 16 | Toolbar PR status bar | New toolbar view |
| 17 | Command palette PR actions | Existing palette |

**Exit criteria:** Session on branch with open PR → sidebar shows #N ✅/❌ → palette offers merge/close/re-run.

### Phase 4 — Polish (P2, ~1 week)

| # | Task |
|---|------|
| 18 | Auto-archive merged worktrees |
| 19 | Personal override config (`~/.config/harness/projects/`) |
| 20 | `:recent` scoped to worktree |
| 21 | `:make` alias for runScript |

---

## Relationship to Other Plans

| Plan | Relationship |
|------|-------------|
| **P21** (Agent Platform) | P24 absorbs actionable agent UX (auto-start, status, selection via config). P21's shelved layers (ACP sideband, multi-provider, brain, backends) remain separate for future re-enable. |
| **P4** (Code Viewing + LSP) | P24 builds on P4's shipped foundation (`:find`, `gf`, `harness view`). P4's deferred follow-ups (`:recent`, `:grep`, `:make`) move into P24 Phase 4. |
| **P12** (Agent Orchestration MCP) | Complementary — P12 = tool policy, P24 = user-facing workflow. |
| **P16** (Task Board) | Board can show worktree sessions + agent status from P24. |
| **P11** (Scripting/Config) | `harness.json` concept aligns with P11's config API direction. |

---

## Positioning

> "Supacode is a worktree command center. Harness is a terminal that manages worktrees too — plus daemon persistence, remote, multiplexer, and CLI scripting that Supacode can't do."

**After P24, Harness has everything Supacode offers PLUS:**
- Sessions survive app quit (daemon)
- Remote/headless/Linux
- `harness-cli` full automation (script 50 worktree agents in a loop)
- tmux-style multiplexer (prefix, copy mode, paste buffers)
- Custom terminal engine (no libghostty dependency, macOS 15+)
- IDE-like navigation (file tree, ⌘-click, zoxide, LSP, `:find`)
- Experience modes (plain → full → agent workspace)
- Works on macOS 15+ (Supacode requires macOS 26)
