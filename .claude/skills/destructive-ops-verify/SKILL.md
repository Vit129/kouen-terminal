---
name: destructive-ops-verify
description: Checks before any action that deletes or overwrites data — rm/rmtree on a path from an argument, Write over a file that may already exist, bulk cleanup from a list someone (or an agent) prepared, data-store rewrites. Use when about to "ลบ", "ล้าง", "เคลียร์", "overwrite", "cleanup", "remove these", write code that deletes user-supplied paths, or run a cleanup produced by another agent.
version: 0.1.0
origin: auto-captured
---

# Verify before destroying

1. **Re-verify each item right before the action, with the strictest test available** — a cleanup list prepared earlier (by you, a subagent or a script) is a claim, not evidence.
2. **"New" file? Check first:** `git ls-files <path>` / `test -e <path>` before Write. If it exists, Edit or append instead; afterwards `git status` must show `??` (new), not `M`.
3. **Code that deletes a path from an argument or id:** require that the item exists in the owned index/DB/staging **and** that `os.path.commonpath([root, target]) == root` with `target != root` (resolve symlinks first). Reject `..`, absolute ids, and the root itself. Apply the same guard in `finally`/cleanup blocks.
4. **Remote data:** snapshot (GET/export) before any automated run that can write; prefer merge-by-key saves over clear-and-rewrite.
5. Dry-run first when the tool has one; show the user the list; delete only what was confirmed.

## Check it worked
A test that feeds `..`, an absolute path, the root, and a non-indexed id and asserts nothing is removed.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: add the new check as a numbered rule (keep ≤10).
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
