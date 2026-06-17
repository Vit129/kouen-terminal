# P21 — Hermes-Inspired Agent Platform (ACP + Multi-Provider + Learning + Orchestration)

Status: **Shelved** — ACP adapters not publicly available; direct terminal agent invocation covers all current needs
Priority: **P1** — foundational AI-first workflow (terminal-first, no panel)
Owner surface: HarnessApp, HarnessCore, harness-cli, agent-memory/, execution backends
Created: 2026-06-15
Scope: 5 independent capability layers (24 PBIs total)
Depends on: P12 (MCP/ToolPolicy), P19 (workbench commands), AgentBridge

---

## Vision

Transform Harness into a **persistent, multi-provider, self-learning agent orchestration platform** inspired by Hermes Agent.

**What changes:**
- Agent runs → learns skills → next run uses learned skills (faster/cheaper)
- Pick LLM provider per command (not vendor-locked: Claude, OpenAI, Anthropic, custom, etc.)
- Spawn parallel subagent teams for concurrent work
- Agent executes locally, in Docker, on SSH remote, or serverless backend
- All output in terminal, visible on Board, fully trackable

**Core promise:** "One agent brain, many surfaces, continuous learning"

---

## Five Capability Layers (P21.1 → P21.5)

### P21.1: ACP Re-enable (PBI-ACP-001 to 005)
Re-enable ACP sideband so agents get tool access (read/write/run files) gated by ToolPolicy.

```bash
:agent --claude --model sonnet --effort high "fix tests"
# → Claude spawns in pane + ACP gives it file/command access
```

### P21.2: Multi-Provider (PBI-ACP-006 to 010)
Support any LLM provider, not just agent-specific wrappers.

```bash
:agent --provider anthropic --model claude-opus "review code"
:agent --provider openai --model gpt-4o --effort low "draft"
:agent --provider openrouter --model meta-llama/3 "quick idea"
```

### P21.3: Persistent Agent Brain (PBI-ACP-011 to 015)
Learn skills from runs, remember solutions, reuse patterns.

```bash
:agent skills list                    # show learned skills
:agent skills show fix-tests-pattern  # inspect a skill
:agent metrics show effectiveness     # which skills/providers work best
```

### P21.4: Subagent Orchestration (PBI-ACP-016 to 020)
Spawn parallel teams for concurrent work with RPC delegation.

```bash
:agent orchestrate --team-of-3 \
  --reviewer "spot bugs in src/" \
  --tester "write tests for src/" \
  --documenter "update docs"
# → 3 agents run in parallel panes, results merged
```

### P21.5: Execution Backends (PBI-ACP-021 to 024)
Run agents locally, in containers, on remote machines, or serverless.

```bash
:agent --backend docker --image swiftpm:latest "swift build"
:agent --backend ssh --host dev.example.com "run tests"
:agent --backend modal --gpu a40 "expensive training"
```

---

## Unified Platform Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ HARNESS UNIFIED AGENT PLATFORM (P21)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ [P21.3] Agent Brain (.agent-brain/)                         │
│ ├── memory.db → skills, precedents, metrics                 │
│ ├── skills/ → learned solutions (fix-tests.md, etc.)        │
│ └── metrics/ → provider/skill effectiveness                 │
│                                                              │
│ [P21.2] Provider Registry                                   │
│ ├── anthropic, openai, openrouter, custom                   │
│ ├── claude-code, codex, kiro, gemini (wrapped)              │
│ └── ProviderRegistry { list, select, estimate cost }        │
│                                                              │
│ [P21.4] Orchestration Engine                                │
│ ├── Single agent (current)                                  │
│ ├── Team mode (parallel subagents)                          │
│ └── Delegation via RPC (tools routed to each subagent)      │
│                                                              │
│ [P21.5] Execution Backends                                  │
│ ├── local → direct PTY                                      │
│ ├── docker → container (isolated)                           │
│ ├── ssh → remote machine                                    │
│ └── modal → serverless pay-per-use                          │
│                                                              │
│ [P21.1] ACP Sideband + ToolPolicy (P12)                     │
│ └── agent ← readFile/writeFile/runCommand/listDirectory    │
│                                                              │
│ [P19] Terminal Surface (Workbench)                          │
│ ├── :agent CLI + Board visibility                           │
│ └── Pane output streaming                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## How ACP Works (from research)

```
Editor (Harness)
    │ JSON-RPC over stdio
    ▼
Agent Adapter (claude-code-acp / codex-acp / kiro-cli --acp)
    │ internal
    ▼
AI Model (Claude Sonnet / GPT-4 / Gemini)
```

- **Local agents** spawn as subprocess, communicate via stdio JSON-RPC
- Agent gets tools: readFile, writeFile, runCommand, listDirectory
- Agent output streams back to editor
- Editor controls which tools are allowed (ToolPolicy — already have this)

---

## P21.1: ACP Re-enable + Agent Selection

### Agent-Specific Wrappers
```
--claude     → claude-code-acp adapter
--codex      → codex-acp adapter  
--kiro       → kiro-cli --acp
--gemini     → gemini-cli
--goose      → goose
```

### Model (per agent/provider)
```
--model sonnet       (Claude: sonnet/opus/haiku)
--model o3           (Codex: o3/o4-mini)
--model gpt-4o       (OpenAI: gpt-4o/gpt-4-turbo)
--model flash        (Gemini: flash/pro)
```

### Effort
```
--effort high    → agent does deep analysis, multiple iterations
--effort medium  → balanced (default)
--effort low     → quick fix, single pass
```

Effort maps to agent-specific parameters:
- Claude: `--max-turns` / thinking budget
- Codex: `--effort` flag (native)
- Kiro: reasoning effort parameter

---

## P21.2: Multi-Provider Support

Instead of wrapping each agent, expose raw LLM providers:

```bash
# Old (agent-specific):
:agent --claude --model sonnet "fix tests"
:agent --codex --model o3 "review"

# New (provider-agnostic):
:agent --provider anthropic --model claude-opus "fix tests"
:agent --provider openai --model gpt-4o "review"
:agent --provider openrouter --model meta-llama/llama-3 "draft docs"
:agent --provider custom --endpoint http://localhost:8000 "experiment"
```

Benefits:
- Switch provider mid-project (cost/speed tradeoff)
- Use cheapest provider for simple tasks
- Support self-hosted LLMs (ollama, vLLM)
- Zero vendor lock-in

---

## P21.3: Persistent Agent Brain

After each run, Harness extracts and stores:
- **What problem was solved** (pattern matching)
- **How it was solved** (the solution/skill)
- **Which provider worked best** (effectiveness metric)

Next time a similar problem appears → reuse learned skill (faster + cheaper).

```
project-root/.agent-brain/
├── memory.db                    # SQLite: skills, precedents, metrics
├── skills/
│   ├── fix-swift-tests.md       # "When: test failure, How: restructure asserts"
│   ├── async-deadlock-debug.md  # Pattern + solution
│   └── protocol-extraction.md
├── precedents.json              # Error pattern → [applicable skills]
└── metrics/
    ├── provider-effectiveness.json  # "claude=95%, codex=87%"
    └── skill-success-rate.json      # "fix-tests works 90% of the time"
```

Commands:
```bash
:agent skills list                # see learned skills
:agent skills show fix-tests      # inspect a skill
:agent skills delete obsolete     # remove a skill
:agent metrics show effectiveness # which skills/providers work best
```

---

## P21.4: Subagent Orchestration

Spawn parallel teams where each subagent:
- Works on a scoped piece of the task
- Has its own conversation + terminal
- Calls back to parent via RPC (file/command execution)
- Reports results when done

```bash
:agent orchestrate --team-of-3 \
  --reviewer "spot bugs in src/" \
  --tester "write tests for src/" \
  --documenter "update README for src/"

# → 3 separate panes open, each gets same context
# → each agent works independently
# → Harness merges results
```

Use cases:
- **Pair review:** 2 reviewers → highest quality
- **Full squad:** reviewer + tester + documenter → parallel work
- **Delegation:** split large task across roles
- **Cost optimization:** cheap provider for docs, expensive for tests

---

## P21.5: Execution Backends

Run agents on different infrastructure:

```bash
# Local (current):
:agent --backend local "swift build"

# Docker (sandboxed, reproducible):
:agent --backend docker --image swiftpm:latest "swift build"

# SSH (offload to remote):
:agent --backend ssh --host dev.example.com "run benchmarks"

# Serverless (expensive compute):
:agent --backend modal --gpu a40 "train ML model"
```

Benefits:
- **Local:** tight feedback, instant
- **Docker:** reproducible, network isolated, clean env
- **SSH:** offload heavy work, preserve local resources
- **Modal/Lambda:** run expensive tasks without owning hardware

---

## Implementation Plan (24 PBIs across 5 Layers)

### Layer 1: P21.1 ACP Re-enable (PBI-ACP-001 to 005)

**PBI-ACP-001: Re-enable ACP compilation**
- Remove `#if HARNESS_ACP` guards
- Fix compilation issues from shelved code
- Do NOT wire into UI yet

**PBI-ACP-002: Agent Registry (AgentCatalog expansion)**
- Centralized config for claude/codex/kiro/gemini/goose
- Binary paths, models, effort mapping
- AgentCatalog SSOT (already 80% done)

**PBI-ACP-003: Agent spawn with model/effort**
- Update `:agent` ex command with `--model` and `--effort`
- Build correct spawn command via AgentCatalog
- (already partially done)

**PBI-ACP-004: ACP sideband attach**
- When agent spawns with `--acp`, attach ACPClient to pane
- Route tools through ToolPolicy (P12)
- readFile (default), writeFile (gated), runCommand (gated)

**PBI-ACP-005: Agent Selection UI**
- `:agent` with no args → picker (which agent + model + effort)
- Command Palette → agent actions
- Settings → Agents → configure defaults

---

### Layer 2: P21.2 Multi-Provider (PBI-ACP-006 to 010)

**PBI-ACP-006: Provider Registry + Protocol**
```swift
protocol LLMProvider: Sendable {
    var id: String { get }
    func listModels() -> [String]
    func completion(prompt: String, model: String) -> AsyncStream<String>
    func estimateCost(tokens: Int) -> Double
}

struct ProviderRegistry {
    var providers: [String: any LLMProvider]
}
```

**PBI-ACP-007: Anthropic direct API (no wrapper)**
- Direct HTTP calls to Anthropic API
- Model selection: claude-opus, sonnet, haiku
- Effort mapping → --max-turns parameter

**PBI-ACP-008: OpenAI/OpenRouter adapters**
- OpenAI (gpt-4o, gpt-4-turbo, o3, o4-mini)
- OpenRouter (200+ models from single interface)
- Cost estimation per token

**PBI-ACP-009: Self-hosted support (ollama/vLLM)**
- Custom endpoint registration
- Local model serving (Llama, Mistral, etc.)
- No auth = free local experimentation

**PBI-ACP-010: Provider selection + cost tracking**
- `:agent --provider openai --model gpt-4o "fix"`
- Auto-select cheapest provider for role
- Track cost per provider + aggregate

---

### Layer 3: P21.3 Persistent Agent Brain (PBI-ACP-011 to 015)

**PBI-ACP-011: Agent Brain DB schema**
- SQLite `.agent-brain/memory.db`
- Tables: skills, precedents, conversations, execution_records
- FTS5 indexing for pattern search

**PBI-ACP-012: Post-run analysis + skill extraction**
- After agent completes, analyze: what problem was solved?
- Extract skill: pattern + solution
- Store with success_rate, provider effectiveness

**PBI-ACP-013: Skill injection into prompts**
- On next similar run, inject learned skill
- Example: "Previously solved this pattern with: [skill summary]"
- Reduces prompt size, improves speed

**PBI-ACP-014: Precedent indexing**
- Index error patterns → [applicable skills]
- Quick lookup: "seen this error before?"
- Confidence scoring

**PBI-ACP-015: Skill management + metrics**
- `:agent skills list` / `show` / `delete`
- `:agent metrics show effectiveness` (provider/skill stats)
- Archive old skills, keep high-value ones

---

### Layer 4: P21.4 Subagent Orchestration (PBI-ACP-016 to 020)

**PBI-ACP-016: Orchestrator core + role model**
- Define role types: reviewer, tester, documenter, etc.
- Role = specialized context + tool filter
- RPC message format for tool delegation

**PBI-ACP-017: Subagent spawning + RPC messaging**
- Spawn N isolated agents in parallel panes
- Each gets role-scoped context
- Bidirectional RPC: subagent → parent for tool access

**PBI-ACP-018: Tool scoping per role**
- Reviewer: readFile (wide scope), no writeFile
- Tester: full access (read/write/run)
- Documenter: write to docs/, no execute

**PBI-ACP-019: Result aggregation + conflict resolution**
- Merge outputs from multiple subagents
- Handle conflicts (both agents modified same file?)
- Report final status to user

**PBI-ACP-020: Orchestration templates**
- Team-of-2 (pair review)
- Team-of-3 (reviewer + tester + docs)
- Custom DAG workflows (fan-out/fan-in)

---

### Layer 5: P21.5 Execution Backends (PBI-ACP-021 to 024)

**PBI-ACP-021: Backend registry + protocol**
```swift
protocol ExecutionBackend: Sendable {
    var id: String { get }
    func spawn(command: String, env: [String: String]) -> ExecutionContext
    func supportsNetwork() -> Bool
    func estimateCost(duration: TimeInterval) -> Double?
}
```

**PBI-ACP-022: Docker executor**
- Container management: start, attach, cleanup
- Image selection (swiftpm:latest, node:20, etc.)
- Volume binding for file access
- Network isolation option

**PBI-ACP-023: SSH executor**
- Remote machine connection (host + auth)
- Persistent session across commands
- File tunneling (upload/download)
- Cost: usage-based billing (if applicable)

**PBI-ACP-024: Modal/serverless adapters**
- Spawn GPU-enabled tasks
- Pay-per-use pricing model
- Async result handling
- Cost estimation before launch

---

## User Flow Examples (Across All Layers)

### Quick fix (P21.1 + P21.3)
```
:agent fix --claude --effort low "fix failing test"
```
- Spawns Claude with effort=low (few turns)
- If learned skill exists: inject it into prompt
- Result stored in brain for reuse
- Next similar failure: 30% faster

### Deep code review (P21.2 + P21.4)
```
:agent orchestrate --team-of-2 \
  --provider claude --provider codex \
  --file src/critical-module.swift
```
- Claude reviews for logic bugs
- Codex reviews for style/perf
- Both run in parallel
- Results merged
- Metrics: which provider caught most bugs?

### Cost optimization (P21.2 + P21.3)
```
:agent --effort low "draft API docs"
```
- Brain suggests cheapest provider (Meta Llama via OpenRouter = 10× cheaper)
- Uses skill from previous docs run
- Total: 20× faster, 10× cheaper than first attempt

### Expensive training (P21.5)
```
:agent --backend modal --gpu a40 "optimize ML model on full dataset"
```
- Spawn on Modal's GPU
- Agent optimizes model
- Local machine stays responsive
- Cost: only GPU time used

### Team orchestration (P21.4 + P21.5)
```
:agent orchestrate --team-of-3 \
  --backend local --reviewer "check API design" \
  --backend docker --tester "write integration tests" \
  --backend ssh --documenter "update README"
```
- Reviewer runs locally (fast feedback)
- Tester runs in Docker (clean environment)
- Documenter runs remotely (doesn't need code)
- All run in parallel
- Results merge automatically

---

## Non-Goals (v1)

- No chat panel / GUI sidebar for agent
- No streaming diff viewer (agent writes files directly)
- No agent marketplace/skill sharing
- No git-integrated skill versioning
- No persistent agent (session survives restart)
- No agent-to-agent communication

---

## Acceptance Criteria (All Layers)

**P21.1 (ACP):**
- `swift build` passes without `HARNESS_ACP` flag
- Agent spawns in pane with tool access
- Tools gated by ToolPolicy
- Multiple agents simultaneous (different panes)

**P21.2 (Multi-Provider):**
- 5+ providers available (anthropic, openai, openrouter, claude-code, codex)
- Switch provider per command
- Cost estimation works
- Self-hosted endpoints work

**P21.3 (Agent Brain):**
- Skills stored + retrieved (95%+ accuracy)
- Skill injection reduces prompt 30%+
- Precedent matching works
- Metrics show effectiveness

**P21.4 (Orchestration):**
- 3 agents run in parallel panes
- RPC tool delegation works
- Results aggregate
- Board shows all subagents

**P21.5 (Backends):**
- Docker executor: spawn, isolate, cleanup
- SSH executor: remote execution
- Cost tracking: per provider + per backend
- Modal integration: GPU spawning works

---

## Rollout Strategy (5 Waves)

```
Wave 1 (PBI-001–005): ACP foundation + agent selection
  → Ship after: Core agent spawning works in panes

Wave 2 (PBI-006–010): Multi-provider support
  → Ship after: Anthropic + OpenAI direct access works

Wave 3 (PBI-011–015): Agent brain + skill learning
  → Ship after: Skills stored + reused

Wave 4 (PBI-016–020): Subagent orchestration
  → Ship after: Team mode works + results merge

Wave 5 (PBI-021–024): Execution backends
  → Ship after: Docker + SSH executors work
```

Each wave blocks UI, not terminal use.

---

## Implementation Progress (2026-06-15)

### Layer 1: ACP Re-enable (PBI-001–005)

**✅ PBI-ACP-002/003: Agent Registry + Spawn**
- AgentCatalog.swift (SSOT for claude/codex/kiro/gemini)
- `:agent fix --kiro --model auto --effort high` works
- AgentBridge finds/sends to agent panes

**❌ PBI-ACP-001: Re-enable ACP compilation**
- `#if HARNESS_ACP` guards still in place
- Remove when ready to wire tools

**❌ PBI-ACP-004: ACP sideband (tool access)**
- ACPClient exists but not attached to pane
- Need ToolPolicy integration

**❌ PBI-ACP-005: Agent Selection UI**
- No picker UI yet
- CLI flags handle selection (partial)

### Layer 2: Multi-Provider (PBI-006–010)

**❌ PBI-ACP-006–010: Provider registry + Anthropic + OpenAI + custom**
- Not started
- Needs: LLMProvider protocol, API clients, cost estimation

### Layer 3: Persistent Agent Brain (PBI-011–015)

**❌ PBI-ACP-011–015: Brain DB + skill extraction + learning**
- Not started
- Needs: SQLite schema, post-run analysis, skill injection

### Layer 4: Subagent Orchestration (PBI-016–020)

**❌ PBI-ACP-016–020: Orchestrator + RPC delegation**
- Not started
- Needs: role model, parallel spawning, result merge

### Layer 5: Execution Backends (PBI-021–024)

**❌ PBI-ACP-021–024: Docker + SSH + Modal executors**
- Not started
- Needs: backend protocol, container management, cost tracking

---

## Success Metrics (Hermes-Inspired)

| Metric | Target | How to measure |
|--------|--------|-----------------|
| **Skill reuse** | Agent solves 30% faster on repeated problems | Track duration: first vs. repeat run |
| **Multi-provider adoption** | 20%+ of runs use non-default provider | Log provider selection |
| **Orchestration adoption** | Team mode used for ≥10% of tasks | Board shows team runs |
| **Cost reduction** | 20% lower cost via right provider choice | Track tokens + cost per provider |
| **Learning in action** | ≥80% of runs inject or create skills | Monitor brain.db writes |
| **Build time** | No regression from current (<5s agent spawn) | Benchmark spawn + first output |

---

## Key Decisions

1. **Five independent layers:** Can ship P21.1 (ACP) without P21.2–5 (multi-provider/brain/orchestration/backends). Each layer adds value independently.

2. **Skill learning, not AI training:** Agent brain stores *solutions* (extracted by heuristics), not fine-tuned models. Low cost, high reuse.

3. **Orchestration via RPC, not prompt chaining:** Subagents use sideband messaging, not context padding. Scales to 10+ agents without token overflow.

4. **Provider agnostic:** No special handling for Claude vs. OpenAI. Protocol-based, so any LLM endpoint works.

5. **Terminal-first execution:** Agents run in visible panes. Board tracks state. No hidden processes or parallel daemon.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Agent brain DB bloats | FTS5 indexing, archival of old conversations |
| Skill injection makes prompts ambiguous | Skill versioning, relevance ranking |
| Subagent RPC overhead | Batch tool calls, connection pooling |
| Docker/SSH adds complexity | Start with local, defer backends to wave 5 |
| Provider config scattered | ProviderRegistry SSOT, validate on startup |
| Cost explosion | Per-provider budgets + alerts + dry-run mode |
| Skill overfitting | Track skill success rate, disable low-confidence ones |

---

## What Makes This "Hermes-Inspired"

✅ **Persistent learning:** Skills extracted, stored, reused  
✅ **Multi-provider:** Choose LLM per command (not vendor-locked)  
✅ **Subagent delegation:** Parallel teams with RPC (not prompt chaining)  
✅ **Flexible execution:** Local → Docker → SSH → serverless  
✅ **One brain, many surfaces:** Agent brain in project, visible on Board, pane output streaming  
✅ **Closed learning loop:** agent runs → success? → extract skill → next run uses it

Hermes uses it for multi-platform agents (Telegram/Discord/CLI). Harness uses it for multi-provider, multi-role, multi-backend agents in terminal.
