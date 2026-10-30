# Antigravity Integration (agy)

This document describes how `aodd-aisdlc` integrates with Google Antigravity (the `agy` CLI).

## What is supported

| Feature | Support in Antigravity |
|---|---|
| Skills (`skills/`) | Copied into `$AGY_HOME/skills` (default `~/.gemini/antigravity-cli/skills`). |
| Agents (`agents/`) | Copied into `$AGY_HOME/agents` (default `~/.gemini/antigravity-cli/agents`). |
| Rules (`rules/aodd.md`, `rules/ai-sdlc-workflow.md`) | Inlined into the Antigravity instruction file (`AGENTS.md`, default `~/.gemini/AGENTS.md`) between `<!-- aodd:begin -->` and `<!-- aodd:end -->` markers. |
| Lifecycle Hook Adapter (`adapters/antigravity-hook-adapter.py`) | Registered under `"aodd-guardrails"` in Antigravity's `config/hooks.json` (default `~/.gemini/config/hooks.json`). Bridges Antigravity events to installed Python hooks. |

### Lifecycle Hook Adapter details

The adapter translates Antigravity lifecycle events to the payload format expected by AODD hooks:
- **`PreToolUse`**: Maps Antigravity tool names to standard names (`run_command` -> `Bash`, `view_file` -> `Read`, `write_to_file` -> `Write`, `replace_file_content` -> `Edit`). When an auditor run is active (`AODD_AUDITOR=1`), `auditor-readonly.py` blocks write operations with `{"decision": "deny"}`.
- **`PostToolUse`**: Records tool executions for post-tool hooks (such as `coding-rules-gate.py` if installed).
- **`Stop`**:
  - `done-gate.py`: Scans Antigravity transcript tool calls. If a progress file (`ai-sdlc-task-progress.md`) was touched and still has open `[ ]` tasks, or if 5+ files were edited without an independent audit report, it blocks turn completion with `{"decision": "continue"}`.
  - `skill-capture-nudge.py`: Scans the session transcript for learning signals (user corrections or fix commits). If >= 20 tool calls have run since the last nudge, it guides the model to file an `agy-proposal` with evidence before stopping.
- **Fail-open**: If any hook module is missing from the installed hooks directory or encounters an error, the adapter allows execution to proceed normally (`{"decision": "allow"}`).

## How to install

Run the Antigravity installer from this repository:

```bash
./install-agy.sh --dry-run    # Preview actions without writing anything
./install-agy.sh              # Perform installation
```

### Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `AGY_HOME` | `~/.gemini/antigravity-cli` | Destination root for skills, agents, and adapters. |
| `GEMINI_HOME` | `$(dirname "$AGY_HOME")` (`~/.gemini`) | Root directory containing `AGENTS.md` and `config/hooks.json`. |
| `CLAUDE_HOME` | `~/.claude` | Fallback location for installed Claude hooks. |
| `AODD_HOOKS_DIR` | `${CLAUDE_HOME:-~/.claude}/hooks` | Directory from which the adapter loads the underlying Python hooks. |
| `AODD_HOME` | `~/.aodd` | Root directory for state, task progress, and audit reports. |

### Safety and Idempotency

- `install-agy.sh` is safe to re-run. If destination files already match source files, no files are modified.
- If an existing file differs from the installer's version, a backup copy is created once as `<file>.aodd-bak`.
- Existing custom instruction content outside the `<!-- aodd:begin -->` and `<!-- aodd:end -->` markers is preserved.
- Existing hook suites in `config/hooks.json` are retained; only `"aodd-guardrails"` is added or updated.
- Host files are never deleted or chmodded.

## Limits

- **Tool errors as learning signals**: Ordinary tool errors in Antigravity sessions are counted but not treated as skill-learning signals. Only explicit user corrections or fix commits trigger a skill-capture nudge.
- **Shell file modifications**: Files modified indirectly through shell commands in `run_command` are intercepted by the read-only auditor regex, but are not counted toward the 5-file threshold for the done-gate heuristic.
- **Evidence verification**: Skill proposals created from Antigravity sessions must contain all required evidence sections (commit hash, failing command, passing verification command); incomplete proposals are rejected by `scripts/check_agy_proposal.py`.
