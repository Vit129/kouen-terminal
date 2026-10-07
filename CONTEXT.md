# Kouen Terminal — Domain Language

An Agent Development Environment built around a native macOS terminal: daemon-owned sessions, a scriptable CLI, an MCP-controlled browser, and multi-agent orchestration. Terminal-first, not an IDE.

## Language

**Task**:
A session-scoped checklist item, persisted per-session, MCP-addressable (create/list/update/delete via `kouen-mcp`). Belongs to exactly one session — not a global, session-independent object.
_Avoid_: Superset Task, Todo

**Task Dashboard**:
UI view aggregating Tasks across all sessions into one place for the human user. Retired from default UI in P44; superseded by inline Task status in session tabs and GitPanelView.
_Avoid_: Fleet dashboard

**Orchestrator**:
A CLI agent session that, given a human-supplied goal, decomposes it into Tasks, spawns Worker sessions to execute each, monitors their Worktree/git/CI state via `kouen-mcp`, retries a Worker on CI failure (Auto-Fix Loop), and drives each Task to merge-ready.
_Avoid_: Autonomous agent, First-party AI brain

**Worker**:
A session an Orchestrator spawns (via `kouenSpawnWorker`, or `kouenSpawnAgent` for an interactive pane) to execute one Task in its own isolated Worktree.
_Avoid_: Subordinate bot, Background worker thread

**Auto-Fix Loop**:
When CI fails on a Worker's branch, the Orchestrator respawns/re-prompts that Worker to fix the failure and retries (bounded, 3 retries max, 15m timeout; never auto-merges).
_Avoid_: Auto-merge loop, Unchecked retry

**Worktree (MCP resource)**:
The existing worktree-per-branch-per-agent isolation (`WorktreeManager`), exposed as an MCP-addressable CRUD resource (`kouen-mcp` tools to create/list/delete).
_Avoid_: Workspace

**Workspace**:
A window-level container of sessions (`WorkspaceID` in `SessionEditor.swift`), distinctly separated from a Git Worktree.
_Avoid_: Worktree, Project container

**Host (MCP resource)**:
An entry in the existing `RemoteHostStore` (SSH remote machine config), exposed read-only via `kouen-mcp`.
_Avoid_: Remote Host

**Session Mode**:
How an agent is launched in a pane, per agent (`AgentSessionMode`, `agentSessionModes` in `settings.json`): `local`, `remote-control` (default; vendor mobile/desktop app), `cloud`, or `happy` (through the Happy wrapper). One launch table resolves agent + mode to a command.
_Avoid_: Launch profile, Connection type

**Happy**:
A third-party cross-vendor mobile/web app and wrapper (`happy claude|codex|agy|acp`). Kouen runs no relay itself; Happy's daemon is started by the Kouen daemon whenever Happy is installed and logged in. A phone-started session is headless until adopted (`kouen-cli happy adopt`).
_Avoid_: Mobile bridge (the deprecated built-in QR/Tailscale bridge)

**Checkpoint**:
An automatic per-agent-turn snapshot of the working tree stored as a `refs/kouen/checkpoints/<session>/<turn>` git ref (never the real index or `git stash`); `kouen undo` reverts to it.
_Avoid_: Stash, Backup

**Write-origin Guard**:
Every PTY write is tagged `human` or `automation`; an automation write is refused when a human typed there within 1.5 s, or the tab sits on a protected branch or a dirty checkout without worktree isolation.
_Avoid_: Permission prompt, Lock

**History / Handoff**:
History lists past Claude Code, Codex, Antigravity, Copilot and VS Code Copilot Chat sessions in one view. Resume reopens one in a new tab; Handoff has the source agent write a note, then continues the work in another agent.
_Avoid_: Session restore, Fork Conversation (that splits a live pane)

**Fleet**:
Sidebar tab flattening every live session across every workspace, needs-attention first.
_Avoid_: Task Dashboard

**Agent Notch**:
Menu-bar-notch HUD summarizing agent status; off by default, hidden while Vorssaint's notch is running.
_Avoid_: Notification inbox (⌘⌃I)

**Project**:
A git repo root registered in the sidebar; auto-registered only from a real `.git` directory, shown as missing (Relocate/Remove) when its folder moves.
_Avoid_: Workspace, Worktree

**Shader Preset**:
A pre-built, Kouen-authored GPU visual effect (e.g. CRT/scanline/bloom) toggled on/off in Settings.
_Avoid_: Custom shader, User shader script

**Automation**:
A scheduled agent launch (`repoPath` + `agent` + `prompt` + `intervalMinutes`), MCP-addressable via `kouen-mcp`.
_Avoid_: Cron job, System daemon

**Scheduled Memory Maintenance Job**:
A `launchd`-scheduled headless `claude -p` run external to Kouen entirely, scanning `agent-memory/` for broken links and archive/crystallize candidates.
_Avoid_: Automation, Internal task

**Agent Routing Rule**:
An ordered, user-configured rule (repo-path glob and/or `SignalFileRouter`-detected stack) that resolves to an `AgentKind` when a spawn call passes `agent: "auto"`.
_Avoid_: Model router, LLM switcher

**Design Mode**:
A human-facing visual inspection toggle on the browser pane for live CSS preview without persisting file changes.
_Avoid_: Source editor mode, Live-code reload

**Fork Conversation**:
A command that splits the active pane and invokes the CLI agent's native fork capability (`claude --continue --fork-session`, `codex fork --last`).
_Avoid_: Kouen fork, State snapshot

**Saved Layout**:
A named, human-saved `PaneLayoutShape` (split directions/ratios/leaf positions only) applied via template.
_Avoid_: Layout Template, Session restore

**Risky Command Advisory**:
A local heuristic flagging an already-finished shell command with a warning Toast on OSC 133 `D`.
_Avoid_: Command blocker, Pre-execution firewall

**Request Peer Review**:
A human-triggered action finding another agent-running pane in the active tab and prompting it to review a diff.
_Avoid_: Automated review bot, CI reviewer

**Merge Waiver**:
Permission allowing a PR with `reviewDecision == "APPROVED"` to merge when checks are pending or waived (never waives conflicts).
_Avoid_: Force merge, Conflict bypass

**Slash Command Picker**:
Composer popup (⌘⇧E) listing interactive commands (`/clear`, `/compact`, `/model`, etc.) for discoverability.
_Avoid_: Terminal autocomplete, AI prompt popup

## Relationships

- A **Task** belongs to exactly one session; deleting the session's underlying data does not orphan Tasks silently.
- A **Worktree (MCP resource)** maps 1:1 to a git worktree (`WorktreeManager.WorktreeInfo`); a **session** (`SessionID`) may attach to a Worktree via `SessionEditor.setWorktree`, but is a distinct runtime concept — and both are distinct from the pre-existing **Workspace** (`WorkspaceID`).
- A **Host (MCP resource)** is read-only via MCP — creating/editing a Host remains a Settings-UI-only action.
- An **Automation** is independent of Tasks, Worktrees, and Hosts.
- An **Agent Routing Rule** resolves to an existing **AgentKind** value — it selects the binary to spawn, not the internal model.
- A **Session Mode** is per agent, not per tab; `happy` and `remote-control` can both apply to a hand-typed `claude` when Happy is logged in.
- An **Orchestrator** creates **Worker** sessions via `kouenSpawnWorker` — a Worker is an ordinary session whose lifecycle is managed by the Orchestrator.
- An **Auto-Fix Loop** only ever retries the same **Worker** on its own **Worktree** — it never spawns a second Worker on the same Task, and never touches the **Merge Waiver** gate.
