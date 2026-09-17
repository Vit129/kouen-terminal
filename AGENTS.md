# kouen-terminal — Agent Instructions

## Agent Memory

`agent-memory/` is gitignored here (2026-08-16+) — not tracked in this repo, centrally backed up instead to the private `github.com/Vit129/agent-memory-private` repo (`agent-memory/kouen-terminal/`). Files stay physically in place; only git tracking changed. Missing on a fresh clone? Restore via `~/.claude/scripts/bootstrap-new-machine.sh`, or manually: `rsync -a ~/Git/Personal/agent-memory-private/agent-memory/kouen-terminal/ agent-memory/`.

## Session Start

- Continuation → read `CONTEXT.md` → invoke `macos-swiftui` skill
- Code navigation → `graphify-out/GRAPH_SUMMARY.md`
- Bug/pattern → `grep -rn "<keyword>" agent-memory/knowledge/cases/ agent-memory/MEMORY.md`

## Skills & Rules

- **Global skills** (`~/.claude/skills/`) — always available every session; pick whichever fits the task.
- **Project-local skills** (`.claude/skills/`, when this repo has any) — check first; these specialize/override the global ones for this repo's own conventions.
- **Global rules** (`~/.claude/rules/`) — behavior/workflow/coding conventions that apply everywhere.
- **Project-local rules** (`rules/` — `build-release.md`, `concurrency.md`, `ipc-protocol.md`) — check first; these specialize the global ones for this repo's own domain.
- AppKit/SwiftUI/macOS → `macos-swiftui` | debugging → `9arm-skills:debug-mantra` | review → `mattpocock-skills:code-review` + `9arm-skills:scrutinize`

## Rules (read when triggered)

- `rules/build-release.md` — build/test/run commands, release flow, version sync, git hooks, worktree constraint
- `rules/concurrency.md` — Swift 6 strict concurrency, `@unchecked Sendable` ownership, terminal replay
- `rules/ipc-protocol.md` — IPC framing, daemon socket security, generated-file regeneration

## Graphify

```
mcp__graphify__query_graph   # focused question
mcp__graphify__shortest_path # dependency path A → B
mcp__graphify__get_node      # explain concept/symbol
```

```bash
graphify update . && ~/.claude/scripts/generate-graph-summary.sh .  # rebuild index (CLI)
```

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<ClassName/FileName>"` for a known symbol/file (name match, not free-form concept search - use `query` for that). These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
- After judging a query/path/explain result useful, a dead end, or wrong, run `graphify save-result --question "Q" --answer "A" --outcome useful|dead_end|corrected --nodes N1 N2` - this accumulates across sessions so the same dead end or vocabulary mismatch isn't re-derived every time. At the start of a session, check `graphify-out/reflections/LESSONS.md` if it exists (built via `graphify reflect`) for preferred sources, known dead ends, and past corrections.
