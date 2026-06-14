# P5 — ACP (Agent Client Protocol) — Harness as ACP Editor/Client

Status: **implemented but shelved/experimental** — `ACPClient`, `ACPSession`,
`AgentChatPanelView`, and `AgentConfig` exist in `HarnessCore`/`HarnessApp`, but the
Agent sidebar tab and Chat toggle are commented out (see CLAUDE.md: most CLI agents
need separate ACP adapter binaries that aren't widely installed, PATH resolution
inside .app bundles is unreliable, and there's no tool-invocation control). Code
remains intact for future re-enablement; do not resume "Phase 3.1" work without
re-scoping against that note.  
Priority: **P1** — enables Claude Code/Codex/Gemini native integration  
Depends on: Async IPC (P2) recommended but not blocking  
Full design: `.aidlc/harness/acp/`  

---

## Goal

Harness acts as an **ACP Client (Editor)** — Claude Code, Codex, and Gemini CLI connect to Harness via JSON-RPC 2.0 over stdio. Agents can request file context, propose edits, and render streamed responses natively.

## Architecture

```
Agent Process (Claude Code / Codex / Gemini)
    │ stdio (JSON-RPC 2.0)
    ▼
ACPRuntime (actor) ── manages sessions, routes messages
    │
    ├── AgentRegistry ── config, launch, lifecycle
    ├── SessionContext ── workspace/file context for agent
    └── ResponseRenderer ── stream agent output into terminal
```

## Bounded Contexts

| Context | Responsibility |
|---------|---------------|
| **ACPRuntime** | JSON-RPC transport, session lifecycle, message routing |
| **AgentRegistry** | Agent configs, binary discovery, process launch/kill |
| **SessionContext** | Provide workspace files, git status, open buffers to agent |
| **ResponseRenderer** | Stream markdown/code responses, inline diffs, approval prompts |

## MVP PBIs (3)

### PBI-ACP-001: Agent Subprocess Lifecycle
- Launch agent binary as child process with stdio pipes
- JSON-RPC initialize/shutdown handshake
- Detect crash/exit, surface to UI
- Actor-based (`ACPSession`) for concurrency safety

### PBI-ACP-002: Session Bootstrap with Workspace Context
- On agent connect: send workspace root, open files, git branch
- Handle `context/get` requests from agent
- File content provider (read from disk, respect .gitignore)

### PBI-ACP-003: Prompt Sending & Streaming Response Rendering
- User sends prompt via sidebar input or terminal command
- Stream response chunks into terminal surface (real-time)
- Handle tool_use requests (file edit approval, command execution)
- Render inline diffs with accept/reject UI

## Key Files (New)

```
Packages/HarnessCore/Sources/HarnessCore/ACP/
├── ACPTransport.swift          — JSON-RPC framing (Content-Length headers)
├── ACPSession.swift            — actor managing one agent connection
├── ACPMessage.swift            — request/response/notification types
└── ACPProcess.swift            — subprocess launch + stdio pipe management

Apps/Harness/Sources/HarnessApp/
├── Services/ACPCoordinator.swift   — registry + session factory
└── UI/ACPResponseView.swift        — streamed response rendering
```

## Transport Protocol

```
Content-Length: 123\r\n
\r\n
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}
```

Same framing as LSP — reuse `ACPTransport` for both ACP and LSP (P4).

## Steps

1. `ACPTransport` — Content-Length framed JSON-RPC read/write over stdio
2. `ACPProcess` — spawn agent binary, pipe stdin/stdout, handle lifecycle
3. `ACPSession` — actor wrapping transport + process, initialize handshake
4. `ACPCoordinator` — manage multiple sessions, route to active pane
5. Wire UI: sidebar "Start Agent" button, response rendering in terminal
6. Integration test with mock agent + real Claude Code

## Shared with LSP (P4)

- `ACPTransport` = same `Content-Length` framing as LSP
- Can extract to `Packages/HarnessProtocol/` shared package
- Both use JSON-RPC 2.0, both are actor-based async

## Estimate

3–4 sessions (transport + lifecycle + response rendering)
