---
name: hook-authoring
description: Writing or fixing a Claude Code hook (a script under the agent home's `hooks/`: PreToolUse/PostToolUse/Stop/UserPromptSubmit/SessionStart python scripts, settings.json registration, regex guards on commands or prompts). Use when the user says "เขียน hook", "แก้ hook", "hook บล็อกผิด", "hook ไม่ทำงาน", "add a hook", "guard blocks my command", or a hook denies/blocks something it should not. Not for Claude Code plugin mods (use plugin-authoring) or git hooks.
version: 0.1.8
last_improved: 2026-10-21
origin: auto-captured
---

# Hook authoring

Hooks are installed into the agent home's `hooks/` and registered in `settings.json`. Every hook has `hooks/test_<name>.py` next to it (plain asserts, no framework).

## Rules

1. **Register fail-open:** `f="$CLAUDE_HOME/hooks/<name>.py"; [ -f "$f" ] || exit 0; exec python3 "$f"`. A bare `python3 <file>` blocks every tool call when the file is missing (exit 2 = block). Register it in `settings.json` only after the hook is merged.
2. **Catch everything in `main()`** and exit 0 with no output on any error; test with garbage stdin, `{}`, and a missing transcript path.
3. **Command-regex guards:** strip quoted strings and heredoc bodies before matching, or a guard fires on prose inside a commit message.
4. **Shell write detection:** a "write" needs a write operator — `>`/`>>` not preceded by `2`/`&` (so `2>/dev/null` is not a write), `sed -i`, `tee`, `cp`, `mv`, `install`, `open(<path>, "w"|"a")`. Match relative paths too (`skills/x/...`, not only `/skills/x/...`). Test reads (`cat`, `grep … 2>/dev/null`) as negatives.
5. **Path/name heuristics** (secret, skill, memory paths): exempt code/doc extensions, count only real files, and add false-positive asserts (its own tests, branch names containing the keyword).
6. **Prompt-text hooks** (UserPromptSubmit): skip harness text (`<system-reminder>`, `<task-notification>`, `<command-…>`) and pasted walls (>15 distinct keywords); match the hook's own injected text (e.g. `[skill-capture]`) out of its signal counts.
7. **Natural-language signals:** match phrases, not single words — in Thai, `อย่า` or `ไม่ต้อง` alone hit "อย่าลืม" (don't forget) and "ไม่ต้องรีบ" (no rush); in English "don't" alone hits "don't forget". Assert everyday sentences as negatives.
8. **Per-session state:** store a number (e.g. tool-call count at last fire) in `$AODD_STATE/<hook>/<session_id>`, not an empty marker, so the hook can refire on new evidence; treat legacy empty markers explicitly.
9. **Usage keyed by name** (skills, commands): names collide across projects/plugins and old ledgers persist — anchor age on the item's own `created` date, never only on the last use of the name.
- **Keyword tables:** match with word boundaries (`\btax\b`), not substrings (`tax` hits "syntax"), and keep the table in one data file the hook and the docs both read.
- **Gotcha:** a `scripts/*.sh` without +x fails "Permission denied"; run `bash <script>`.
- **settings.json `env` values are not shell-expanded.** `"X": "$HOME/notes"` reaches the hook literally and `Path(...)` creates a folder named `$HOME` in the session cwd. Resolve paths only through the shared path resolver (`hooks/_aodd_paths.py`, which expands `$VARS`/`${VARS}`/`~` at import); a shell or git hook calls `python3 <repo>/hooks/_aodd_paths.py <kind>` instead of its own `${v//\$HOME/...}`, which misses `${HOME}`. Check: `find <claude-home> -maxdepth 2 -name '$HOME'` stays empty after a session.
- **Prove a regression test fails without the fix** by stashing only the source file (`git stash push <src>`), never the whole tree: that stashes the new test too and the "fails before" run proves nothing.
- **Pick "the latest" report by the date in its name, not mtime alone.** Annotating or moving an old report updates its mtime and makes it look newest. Check: a test that edits an older report after a newer one exists.
- **A hook test must clear the env switches it depends on** (`CLAUDE_SKILL_CAPTURE`, `DONE_GATE_AUDIT`, `AODD_NO_BACKUP` for installer tests, …) at its top, including the env it passes to a subprocess: callers like `scripts/audit.py` set them, and the test then fails on correct code. Check: `CLAUDE_SKILL_CAPTURE=0 python3 hooks/test_<name>.py` still passes.
- **A hook that moves or deletes a file another hook reads** (e.g. session-start filing a report to `done/` that done-gate looks up) breaks the reader on a resumed session. Make the reader search both places, and add a test that moves the file first and then calls the reader.
- **Hooks import each other** (a helper hook may reuse `skill-capture-nudge.scan`). Before changing a helper's return shape or name: `grep -rn "<module>.<fn>(" hooks scripts`, update every caller, and run **every** `hooks/test_*.py` — fail-open `try/except` turns the breakage into silently wrong data (a log recorded `tool_calls: 0` for every session).
- **Every block path needs its own once-guard**, not only the one the docstring was written for: a Stop hook that returns the same reason on every stop (done-gate's medium-audit ask fired ~15 times in one session) costs tokens each turn. Check: call `decide()` twice on the same transcript and assert the second is `None`.
- **A plugin hook runs in every project the plugin is installed for.** Gate it on the project first (a marker folder in cwd), and for a `type: prompt` hook put that approve-first condition at the top of the prompt; a prompt hook cannot be skipped by code, so it still costs one model call per stop.
- **Anything a hook writes outside the project** (a shared notes repo, a personal log) must skip work that belongs to someone else, such as a client or employer repo: filter by cwd, and add a test with such a path.

## Check it worked

`python3 hooks/test_<name>.py` passes, `python3 -m py_compile hooks/<name>.py`, then trigger it once for real in a session (the PostToolUse/Stop output appears in the transcript).

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a new hook pitfall goes in Rules (keep ≤15; merge related ones).
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
