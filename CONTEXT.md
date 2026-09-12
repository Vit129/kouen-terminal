# Kouen Terminal — Domain Language

Native macOS terminal designed for autonomous AI coding agent workflows.

## Language

**Task**:
A session-scoped checklist item, persisted per-session and MCP-addressable (create/list/update/delete via `kouen-mcp`). Belongs to exactly one session — not a global object.
_Avoid_: Superset Task, Todo

**Task Dashboard**:
Aggregated visual summary of Tasks across all active sessions, rendered at the session tab or worktree row.
_Avoid_: Fleet dashboard

**Orchestrator**:
A CLI agent session that decomposes a human goal into Tasks, spawns Worker sessions in isolated git worktrees, monitors CI status, and drives tasks to merge-ready without auto-merging.
_Avoid_: Autonomous runtime, Agent Orchestrator

**Worker**:
A CLI agent session spawned by an Orchestrator to execute one specific Task in its own isolated worktree.
_Avoid_: Background bot, Superset Worker

**Auto-Fix Loop**:
Bounded automated retry loop (max 3 retries, 15m timeout) where an Orchestrator prompts a Worker to resolve CI failure. Human approval remains required for PR merge.
_Avoid_: Auto-merge on green

**Worktree**:
Git worktree-per-branch-per-agent filesystem isolation exposed as an MCP CRUD resource.
_Avoid_: Workspace

**Host**:
An entry in `RemoteHostStore` (SSH remote machine config) exposed read-only via MCP.
_Avoid_: Cloud instance

**Shader Preset**:
Pre-built GPU visual effect (CRT, scanline, bloom) toggled in settings.
_Avoid_: Custom shader

**Automation**:
A scheduled agent launch (`repoPath` + `agent` + `prompt` + `intervalMinutes`) addressable via MCP.
_Avoid_: Cron bot, Daemon task

**Scheduled Memory Maintenance Job**:
A `launchd`-scheduled headless Claude run scanning `agent-memory/` for broken links and crystallization, separate from Kouen automations.
_Avoid_: Automation

**Agent Routing Rule**:
Rule matching repo path or tech stack to select which CLI agent binary (`AgentKind`) to spawn when `agent: "auto"` is requested.
_Avoid_: Model router

**Design Mode**:
Browser pane inspection tool allowing live computed style preview without modifying source files.
_Avoid_: In-browser CSS editor

**Fork Conversation**:
Pane split triggering the CLI agent's native session branching flag (`--continue --fork-session`).
_Avoid_: Kouen conversation fork

**Saved Layout**:
Named arrangement of pane splits and ratios created from user arrangement.
_Avoid_: Layout Template, Session snapshot

**Risky Command Advisory**:
Advisory heuristic toast warning when a potentially destructive command completes in an agent pane.
_Avoid_: AI execution blocker

**Merge Waiver**:
Human gate permitting an approved PR to merge when automated checks have not completed green.
_Avoid_: Conflict bypass, Force merge
