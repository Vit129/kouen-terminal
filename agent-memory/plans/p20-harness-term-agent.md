# P20 — Harness-Term Agent

Status: **Partially implemented** — core agent workflow done; `harness chat` first-party branding deferred
Priority: **P2** — first-party agent experience for P19 without exposing runtime vendor names
Owner surface: HarnessApp, HarnessCLI, HarnessCore agent runtime adapters, harness-mcp integration
Created: 2026-06-14
Depends on:

- [[p12-agent-orchestration-mcp]] for pane/session control primitives
- [[p15-integration-roadmap]] event bridge for runtime state notifications
- [[p16-task-board]] for live agent/session visibility
- [[p19-terminal-workbench-migration]] for shared workbench commands and user workflow vocabulary

---

## Goal

Create a first-party **Harness-Term Agent** experience: the user talks to
`harness chat`, sees Harness-branded agent runs in panes and on the Board, and
never needs to know which external runtime adapter powers a given run.

Harness owns the product surface:

- `harness chat`
- `harness agents`
- HarnessApp command palette actions
- Board cards and attention state
- project-local context injection
- MCP/session control

Any external agent binary is an internal adapter detail. It can be detected,
validated, and launched if available, but it is not part of the user-facing
brand, command vocabulary, or docs unless a low-level diagnostic screen needs to
show the adapter id.

Example end state:

```bash
harness chat "Use the project map first, then inspect this repo"
harness chat --graphify-first "Plan P19 implementation"
harness agents list
harness agents status
harness agents attach --surface-id <id>
```

From HarnessApp:

- Command palette shows `Harness Chat`.
- Board cards show `Harness-Term Agent`.
- Status/attention indicators use Harness language.
- Adapter/runtime names are hidden by default.

---

## Brand Rule

**User-facing surfaces say Harness or Harness-Term, not runtime vendor names.**

Allowed user-facing terms:

- Harness Chat
- Harness-Term Agent
- Harness Agent
- agent runtime
- local runtime
- external runtime adapter

Avoid user-facing terms:

- specific provider/runtime names
- install instructions for third-party runtimes in primary flows
- command examples that ask the user to run a provider command directly

Low-level diagnostics may show an adapter id only when needed for debugging, for
example:

```json
{
  "agent": "harness-term",
  "adapter": "local-external",
  "available": false,
  "reason": "notFound"
}
```

---

## Context Ownership

Project-local context belongs to Harness and the project, not to an external
runtime.

Sources:

- `AGENTS.md`
- `agent-memory/`
- `graphify-out/`
- `GRAPHIFY_USAGE.md`
- current branch, workspace, pane cwd, and selected file
- live Board/session/task state

Harness builds a bounded **Project Context Packet** for every agent run. The
runtime consumes this packet; it does not own it.

Model:

```text
Harness-Term Agent =
  Harness UX
  + runtime adapter
  + role
  + project context packet
  + tool policy
  + visible terminal pane
  + Board state
```

Rules:

- `agent-memory/` is read-only by default for agent runs.
- Memory writes must go through explicit Harness/project workflows.
- Graphify is a project navigation layer, not a runtime-specific feature.
- Runtime global config must not become the source of truth.
- Missing runtime adapters must not block Harness startup or terminal use.

---

## Product Relationship

Harness has the first-party job:

| Layer | Responsibility |
|-------|----------------|
| Harness-Term | Chat UX, terminal panes, board, project context, task/error state |
| Runtime adapter | Execute a prompt through an available local engine |
| Graphify | Project map/navigation context |
| agent-memory | Project-local memory and decisions |

P20 is not "integrate a named agent product." It is "make Harness-Term the agent
surface, with pluggable local runtime adapters behind it."

---

## Non-Goals

- No bundled third-party runtime binary.
- No automatic installation flow.
- No GUI ACP sidebar revival.
- No separate hidden process manager in v1.
- No project-local auto-execution of scripts.
- No mutation of external runtime global config.
- No provider-specific command names in the primary CLI/App/docs.
- No replacement of P12 MCP tools; agents use the same pane/session primitives
  as other Harness workflows.

---

## Current State

- Harness already has daemon IPC and MCP pane/session control from P12.
- P16 Board can represent live sessions/panes and agent state.
- P19 defines the terminal workbench layer that humans and agents should share.
- Project-local `agent-memory/` and `graphify-out/` already establish the right
  ownership model: the project owns context; agent runtimes consume it.
- Existing routing guidance already prefers Graphify-first context before broad
  project exploration.

---

## Runtime Adapter Contract

Discovery search order:

1. User-provided environment variable for a Harness adapter binary, if supported.
2. User-configured path in Harness settings, if added by PBI-AGENT-002.
3. `PATH` lookup for supported local runtime adapters.
4. Informational hints only; do not execute guessed paths unless they exist and
   pass validation.

Validation:

- Run a lightweight version/help command through the adapter.
- Timeout quickly.
- Cache result in memory for the app session.
- Do not show startup errors if no adapter is available.

Unavailable state:

```json
{
  "agent": "harness-term",
  "available": false,
  "reason": "notFound",
  "hint": "Configure a local Harness agent runtime adapter"
}
```

Available state:

```json
{
  "agent": "harness-term",
  "available": true,
  "adapter": "local-external",
  "version": "..."
}
```

---

## Launch Model

Harness Chat runs inside visible Harness terminal panes by default.

Why:

- the user can see the run
- output is capturable by existing daemon APIs
- Board and attention state derive from real pane/session state
- no hidden process manager is required
- control and policy stay aligned with P12 MCP primitives

User command:

```bash
harness chat "Plan how to implement P19"
```

Graphify-aware command:

```bash
harness chat --graphify-first "Plan how to implement P19"
```

Internal prompt prefix:

```text
Use graphify query/path/explain first, then answer: <user task>
```

The final launched pane should show a Harness-owned command or wrapper, not a
provider command pasted directly into the user's workflow.

---

## Public Command Surface

### CLI

```bash
harness chat "<prompt>"
harness chat --graphify-first "<prompt>"
harness chat --cwd <path> "<prompt>"
harness chat --role planner "<prompt>"
harness agents list
harness agents status
harness agents attach --surface-id <id>
```

Behavior:

- `chat` is the primary user entry point.
- `agents list` shows Harness-Term agent availability and diagnostic reasons.
- `chat` creates or reuses a visible terminal pane.
- `--graphify-first` prepends the canonical Graphify instruction.
- Missing adapter returns deterministic non-zero CLI output, not a crash.

### App

- Command palette: `Harness Chat`.
- Optional board filter/chip: `Harness-Term Agent`.
- Status line transient indicator when an agent starts/stops or needs attention.
- Diagnostic detail can reveal adapter status behind a disclosure view, not in
  the primary label.

### Scripting

```js
harness.chat.run({ prompt, graphifyFirst: true, cwd, role: "planner" })
harness.agents.list()
harness.events.on("agentStateChanged", event => ...)
```

### MCP

P20 should not create provider-specific MCP tools in v1. Expose Harness-Term
agent metadata on the same pane/session/board tools:

- `harnessList`
- `harnessBoard`
- `readPaneOutput`
- `sendPaneText`
- `waitForPaneOutput`

---

## State Model

Add a generic Harness agent runtime metadata layer:

```swift
struct HarnessAgentDescriptor: Codable, Sendable {
    var id: String
    var displayName: String
    var adapterID: String?
    var version: String?
    var availability: Availability
}

struct HarnessAgentRunMetadata: Codable, Sendable {
    var agentID: String
    var surfaceID: UUID
    var startedAt: Date
    var cwd: String
    var role: String?
    var promptSummary: String?
    var graphifyFirst: Bool
}

struct ProjectContextPacket: Codable, Sendable {
    var cwd: String
    var branch: String?
    var instructionsPath: String?
    var memoryPaths: [String]
    var graphPath: String?
    var graphifyUsagePath: String?
    var selectedFile: String?
    var taskSummary: String?
}
```

Persistence:

- Adapter path setting may be persisted only if the user explicitly sets it.
- Active run metadata is runtime/session state.
- Do not persist full prompts in settings.
- Do not persist Board status separately from live snapshot state.
- Do not persist runtime global memory through Harness Chat.

---

## Implementation Plan

### PBI-AGENT-001: Project context packet

Files:

- New: `Packages/HarnessCore/Sources/HarnessCore/Agents/ProjectContextPacket.swift`
- New: `Packages/HarnessCore/Sources/HarnessCore/Agents/ProjectContextBuilder.swift`
- Tests: `Tests/HarnessCoreTests/ProjectContextBuilderTests.swift`

Tasks:

- Discover project-local context sources:
  - `AGENTS.md`
  - `agent-memory/memory.md`
  - `agent-memory/playbook.md`
  - `agent-memory/user-profile.md`
  - `graphify-out/graph.json`
  - `GRAPHIFY_USAGE.md`
- Build a bounded, serializable context packet.
- Use `N/A`/missing fields rather than guessing.
- Keep memory read-only in this pass.

Tests:

- Missing optional files are represented explicitly.
- Project root and cwd are preserved.
- Packet does not include full graph or unbounded memory contents.

### PBI-AGENT-002: Runtime adapter discovery

Files:

- New: `Packages/HarnessCore/Sources/HarnessCore/Agents/HarnessAgentDescriptor.swift`
- New: `Packages/HarnessCore/Sources/HarnessCore/Agents/AgentRuntimeDiscovery.swift`
- Tests: `Tests/HarnessCoreTests/AgentRuntimeDiscoveryTests.swift`

Tasks:

- Define generic runtime adapter descriptors.
- Implement side-effect-free adapter discovery.
- Validate executable path and version/help output with a short timeout.
- Return structured unavailable states.
- Keep provider names out of primary user-facing output.

Tests:

- Missing adapter returns `notFound`.
- Non-executable path returns `notExecutable`.
- Timeout returns `validationTimedOut`.
- Diagnostic output can include adapter id when explicitly requested.

### PBI-AGENT-003: Harness Chat CLI

Files:

- New: `Tools/harness/Sources/HarnessCLI/HarnessCLI+Chat.swift`
- Touch: `CLICommandCatalog`
- Touch: `docs/COMMANDS.md`

Tasks:

- Implement `harness chat`.
- Implement `harness chat --graphify-first`.
- Implement `harness chat --cwd`.
- Implement `harness chat --role`.
- Launch the agent in a visible terminal pane through existing daemon IPC.
- Return deterministic errors when no runtime adapter is available.

Tests:

- Missing adapter error text.
- Context packet inclusion.
- Command construction for plain and Graphify-first prompts.
- Prompt summary avoids storing full prompt in settings.

### PBI-AGENT-004: Harness Agents CLI

Files:

- New or touch: `Tools/harness/Sources/HarnessCLI/HarnessCLI+Agents.swift`
- Touch: `CLICommandCatalog`
- Touch: `docs/COMMANDS.md`

Tasks:

- Implement `harness agents list`.
- Implement `harness agents status`.
- Implement `harness agents attach --surface-id`.
- Keep provider-specific details behind `--verbose` or diagnostic output.

Tests:

- Default output shows Harness-Term Agent labels.
- Verbose output includes adapter diagnostics.
- Attach validates surface IDs.

### PBI-AGENT-005: App command palette integration

Files:

- Touch: command palette registration.
- Touch: session/pane launch routing.

Tasks:

- Add `Harness Chat` command.
- If unavailable, show a non-blocking message with a Harness setup hint.
- If available, open a prompt field and launch a visible agent pane.
- Use Harness labels in all primary UI.

Tests:

- Unavailable state does not crash.
- Available state routes to pane launch.
- Primary UI strings do not expose adapter names.

### PBI-AGENT-006: Board/session metadata

Files:

- Touch: P16 Board model only if metadata shape needs extension.
- Touch: snapshot/notification path if active runtime metadata is needed.

Tasks:

- Mark Harness-launched agent panes with `agentID == "harness-term"`.
- Show Harness-Term Agent chip on Board cards.
- Emit `agentStateChanged` events when agent panes start/exit/need attention.
- Do not infer agent identity from arbitrary shell output unless the process was
  launched by Harness Chat.

Tests:

- Harness Chat pane appears as Harness-Term Agent in Board JSON.
- Exited agent pane moves to Done/Error using existing exit status rules.

### PBI-AGENT-007: Script API bridge

Files:

- Touch: P11 `ScriptAPI.swift`

Tasks:

- Add `harness.chat.run(options)`.
- Add read-only `harness.agents.list()`.
- Add gated mutating support only after P11 command/session mutators exist.
- Reuse the same context packet and adapter discovery as CLI/App.

Tests:

- Script can list Harness-Term availability.
- Invalid role/runtime options throw typed JS errors.

### PBI-AGENT-008: Documentation and brand guard

Files:

- Touch: `docs/COMMANDS.md`
- Optional: new `docs/HARNESS_CHAT.md`
- Optional: test/lint helper for public docs strings

Tasks:

- Document Harness Chat as the first-party concept.
- Document project-local context ownership.
- Document Graphify-first behavior.
- Document that runtime adapters are externally managed.
- Avoid provider names in primary docs. If a provider name is needed, keep it in
  a short advanced diagnostics section.

Tests:

- Optional doc string check for provider names in primary command docs.

---

## Rollout Order

1. PBI-AGENT-001 project context packet.
2. PBI-AGENT-002 runtime adapter discovery.
3. PBI-AGENT-003 `harness chat` missing-state behavior.
4. PBI-AGENT-003 visible-pane launch.
5. PBI-AGENT-006 Board/session metadata.
6. PBI-AGENT-004 `harness agents`.
7. PBI-AGENT-005 app command palette.
8. PBI-AGENT-007 script API bridge.
9. PBI-AGENT-008 docs and brand guard.

The first implementation should prove `harness chat` before adding settings UI.
If env/PATH discovery is enough for early users, avoid adding settings surface
area.

---

## Acceptance Criteria

- `swift build` passes.
- Harness starts normally with no runtime adapter installed.
- `harness chat` is the primary command for agent interaction.
- `harness agents list` reports Harness-Term availability with clear reasons.
- If a runtime adapter is available, Harness can launch an agent in a visible
  pane.
- `--graphify-first` composes the canonical project-map instruction.
- Board/session state identifies Harness-launched agent panes as Harness-Term
  Agent.
- Project-local `agent-memory/` and `graphify-out/` remain owned by the project,
  not by the runtime adapter.
- Harness does not install external runtimes or mutate their global config.
- Public CLI/App/docs use Harness branding by default.

---

## Risks

- Provider names can leak into the primary UX. Keep adapter details behind
  diagnostics/verbose views.
- Task/context packets can grow too large. Include paths and short summaries by
  default, not full memory or graph content.
- Hidden installs would violate user trust. Keep setup hints documentation-only.
- Inferring agent identity from shell output is brittle. Prefer metadata from
  Harness-initiated launches.
- Prompt handling can leak too much into logs. Store summaries, not full prompts,
  unless the terminal pane itself shows the command.


---

## What Was Implemented (2026-06-15)

### ✅ AgentBridge (HarnessApp/Services/AgentBridge.swift)
- `allAgents()` — list all running agent panes with kind
- `agentSurfaceID(kind:)` — find agent by kind
- `sendToAgent(_:kind:)` — send text to agent pane
- `sendFile(path:command:kind:)` — send file content with command

### ✅ AgentCatalog (HarnessApp/Services/AgentCatalog.swift)
Centralized single source of truth for all agent CLI configurations:
- **Claude:** binary=`claude`, models (opus-4.8/4.7/4.6, sonnet-4.6/4.5/4.0, haiku-4.5), `--model` flag
- **Codex:** binary=`codex`, models (gpt-5.4/o3/o4-mini/gpt-4.1), `--model` + `-c model_reasoning_effort=` (low/medium/high)
- **Kiro:** binary=`kiro-cli`, models (auto/opus/sonnet/haiku/deepseek/minimax/glm/qwen), `--model` + `--effort` (low/medium/high/xhigh/max)
- **Gemini:** binary=`gemini`, models (2.5-pro/flash), `--acp` flag (ACP reference)
- `spawnCommand(kind:model:effort:acp:)` — builds full CLI command string

### ✅ :agent ex command (ViExCommands.swift)
```
:agent fix --claude --model claude-opus-4.8
:agent review --kiro --model auto --effort high
:agent fix BoardM --codex --model o3 --effort low
:agent "add tests" --kiro
```
- Fuzzy file path resolution via FuzzyPathResolver
- Auto-spawn: if agent not running → spawns via AgentCatalog.spawnCommand()
- Parses --model, --effort, --claude/--codex/--kiro/--gemini flags
- Shows agent list when multiple found and no flag given

### ✅ CLI: `harness agent send`
```bash
harness agent send <file> [--message <msg>]
```
Finds agent pane via getSnapshot, sends file content to agent.

### ❌ Deferred: `harness chat` first-party branding
Moved to [[p21-acp-agent-selection]] PBI-ACP-005 — `harness chat` is the UI layer on top of ACP agent selection.

