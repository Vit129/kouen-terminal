# Kouen Domain Language

## MCP Surface

| Term | Definition | Aliases to avoid |
|------|-----------|-----------------|
| **Task** | A session-scoped checklist item, persisted per-session, MCP-addressable (create/list/update/delete via `kouen-mcp`). Belongs to exactly one session — not a global, session-independent object. | Superset Task (different model — theirs is global, not session-scoped), Todo |
| **Task Dashboard** | UI view aggregating Tasks across all sessions into one place, for the human user (not an MCP-exposed object itself). | Fleet dashboard (that's agent/notification status, a separate existing concept) |
| **Worktree (MCP resource)** | The existing worktree-per-branch-per-agent isolation (`WorktreeManager`), newly exposed as an MCP-addressable CRUD resource (`kouen-mcp` tools to create/list/delete). The underlying git-worktree mechanism is unchanged — this term refers specifically to its new external-agent-facing surface. | **Workspace** — already a distinct, pre-existing Kouen term (`WorkspaceID` in `SessionEditor.swift`, a window-level container of sessions). Do not reuse "Workspace" for the worktree concept — that's the naming Superset uses, not Kouen's. |
| **Host (MCP resource)** | An entry in the existing `RemoteHostStore` (SSH remote machine config), newly exposed read-only via `kouen-mcp` (`hosts_list`-equivalent). No new storage — this term refers to the new MCP-facing view of existing state. | Remote Host (UI-facing term in `SettingsRemoteView`, same underlying data) |
| **Shader Preset** | A pre-built, Kouen-authored GPU visual effect (e.g. CRT/scanline/bloom) the user toggles on/off in Settings. Not user-authored/arbitrary shader code — that's explicitly out of scope. | Custom shader (implies user-authored code, which this is not) |
| **Automation** | A scheduled agent launch (`repoPath` + `agent` + `prompt` + `intervalMinutes`), MCP-addressable (create/list/get/update/delete/pause/resume/run-now via `kouen-mcp`). On fire, spawns a session and types `prompt` into the launched agent — same mechanism a human or `kouenSpawnAgent` uses. Kouen has no `agent-memory/plans` awareness; the connection is purely the `prompt` text convention (e.g. "ทำต่อ p40" relies on the launched agent's own CLAUDE.md continuation rule). | Superset Automation (theirs uses RRULE recurrence + a `run` log history; Kouen's is a simpler fixed-interval-minutes model with last-run status only) |

## Relationships
- A **Task** belongs to exactly one session; deleting the session's underlying data does not orphan Tasks silently — behavior TBD in design (see dev-architect).
- A **Worktree (MCP resource)** maps 1:1 to a git worktree (`WorktreeManager.WorktreeInfo`); a **session** (`SessionID`) may attach to a Worktree via `SessionEditor.setWorktree`, but is a distinct runtime concept — and both are distinct from the pre-existing **Workspace** (`WorkspaceID`, a window-level container of sessions).
- A **Host (MCP resource)** is read-only via MCP — creating/editing a Host remains a Settings-UI-only action (SSH connection setup has security implications not delegated to external agents in this plan).
- An **Automation** is independent of Tasks, Worktrees, and Hosts — it does not reference any of them by ID. Its `repoPath`/`agent`/`prompt` fields are free text; if that `repoPath` happens to be a git repo with `agent-memory/plans/`, and the `prompt` happens to name a specific plan file, the *launched agent* is what reads and acts on the plan — Kouen itself never opens or parses plan files.
