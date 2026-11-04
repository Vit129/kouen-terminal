# Codex

`./install.sh --codex` installs into `${CODEX_HOME:-~/.codex}` in addition to the Claude install (`--dry-run` covers it).

| Part | Status under Codex |
|---|---|
| Skills (`skills/`) and agents (`agents/`) | copied; Codex reads skills from `$CODEX_HOME/skills` |
| `rules/aodd.md` + `rules/ai-sdlc-workflow.md` | inlined in `$CODEX_HOME/AGENTS.md` between `<!-- aodd:begin -->` and `<!-- aodd:end -->` (Codex has no `@import`); a re-run replaces that block, text outside it is untouched; `AGENTS.md.aodd-bak` is made once |
| `scripts/audit.py` | supported: a Codex session transcript is detected (worker `codex`), and Codex can be the auditor (table above): `codex exec -s read-only --ephemeral -C <repo> -` with the prompt on stdin. Binary: `CODEX_BIN` (default `codex`). `--auditor codex` forces it |
| Hooks in `$CODEX_HOME/hooks.json` | registered for `PreToolUse`, `Stop`, `PostToolUse` (same fail-open commands; `hooks.json.aodd-bak` made once). Codex hook input uses the same field names as Claude, so no adapter is needed (see Verified below) |

Verified (Codex CLI 0.154, live run in a throwaway `CODEX_HOME`, `codex exec --dangerously-bypass-hook-trust`, and by tests):

- Hook input: `PreToolUse` receives `session_id`, `transcript_path`, `cwd`, `tool_name`, `tool_input`, `tool_use_id`. A file edit arrives as `tool_name: apply_patch` with `tool_input: {"command": "<patch text>"}`; the shell tool arrives as `tool_name: Bash` with `tool_input: {"command": ...}`.
- `auditor-readonly.py` (`AODD_AUDITOR=1`): the `apply_patch` edit was denied live (file not created, `git status` unchanged, Codex logged "Command blocked by PreToolUse hook"); `Bash` writes go through the same regex as under Claude.
- `done-gate.py` and `skill-capture-nudge.py` read the Codex rollout (`~/.codex/sessions/.../rollout-*.jsonl`: `{timestamp, type, payload}`): edited files come from `apply_patch` headers (`*** Add|Update|Delete File: <path>`), shell commands from `exec_command` (`arguments` JSON with `cmd`), user messages from `message`/`user`/`input_text` (injected `<...>` and `# AGENTS.md` blocks skipped). The shapes were read from real rollouts; the gates themselves are covered by `hooks/test_done_gate.py` and `hooks/test_skill_capture_nudge.py` with synthetic records of that shape, not by a full interactive Codex session.
- Codex may ask you to trust newly added hooks on first run.
- Transcript detection, auditor selection, the auditor command, install and re-install: `scripts/test_audit.py`, `scripts/test_install.py`.

Limits: Codex tool errors are not counted by the skill-capture hook (they are not a nudge signal anyway); a file written by a shell command (not `apply_patch`) is not counted toward the done-gate "medium" file count, same as under Claude.
