---
name: git-safety
description: Git and PR moves that silently lose or misplace work — deciding a branch is merged, deleting branches, pushing to a branch whose PR may already be merged, creating branches/worktrees with uncommitted work, worktree isolation, old PR branches far behind main. Use before "ลบ branch", "branch นี้ merge แล้วยัง", "push เพิ่มเข้า PR", "สร้าง worktree", "git push -u", "clean up branches", or any git step that moves or deletes commits. Not for resolving a merge conflict itself.
version: 0.1.6
last_improved: 2026-10-21
origin: auto-captured
---

# Git safety

Basic rules apply (two tasks on two branches, never push main). These are the verified traps behind them.

## Before deleting a branch
- **Merged = ancestor of `origin/main`, or `git cherry origin/main <b>` shows no `+` lines.** Never judge by commit subject or "a merged PR exists" — squash merges and follow-up commits make both lie (9 of 22 "merged" branches once had unique commits).
- Re-check each branch right before deleting, with that strict test, even if a list says it is merged.
- **"Both are merged" covers several PRs: check each one** (`gh pr view <n> --json state`) before deleting its branch. Deleting the head branch of an OPEN PR closes it. Recover: `git push origin <sha>:refs/heads/<b>` then `gh pr reopen <n>`.

## Before pushing more commits to a PR branch
- **Check the PR is still open:** `gh pr view <n> --json state -q .state`. Pushing to a merged PR's branch leaves the commit off main silently.
- After any merge: `git log origin/main..origin/<branch>` — anything listed needs its own PR (cherry-pick onto a fresh branch from main).
- An old PR branch far behind main: merge `origin/main` into it first, then commit; `gh pr ready <n>` before `gh pr merge` on a draft.
- **PR CLI on a repo whose remote is an SSH host alias** (`git@<alias>:...`): the host's CLI (for example `az repos pr create`) may fail to infer the repo ("A valid repository name is required"). Pass organization, project and repository explicitly, read from `git remote get-url origin` (URL-decode `%20`).

## Creating branches and worktrees
- Commit task 1 before creating task 2's branch/worktree; a new worktree starts from main and does not carry uncommitted work.
- With dirty files on main: `git stash push -- <paths>` alone (add `-u` when a run produced new untracked files, e.g. generated reports, or they stay behind on main), then `git switch -c <b>` + `git stash pop` + commit, then `git worktree add` in a **separate** command (a dirty-branch guard may judge a chained `&&` command as dirty).
- A dirty-branch guard hook (if you run one) may match `git checkout`/`git switch` anywhere in the command text, including a test in a throwaway repo: commit the current work first, then run the test.
- To test a git hook script in a throwaway repo: `git init -b main`, make one commit with `-c core.hooksPath=/dev/null` (with no commit, `git rev-parse HEAD` fails), then run the hook by hand on main, on a branch, and with its disable flag set.
- **Terminals/IDEs that auto-isolate worktrees:** `git checkout -b <b>` on main may be auto-isolated into a worktree while the tab stays on main. After creating a branch run `git branch --show-current` and `git worktree list`; work in the worktree path.
- Never `git push -u origin HEAD:<new>` from main — it re-points main's upstream. Use `git push origin HEAD:refs/heads/<b>`, then `git branch --track`.
- A worktree with symlinked deps (`node_modules -> ../../node_modules`): ignore it as `node_modules` (no trailing slash — `node_modules/` matches dirs only) and never `git add -A` there, or the symlink gets tracked and replaces the real dir on merge.

## Rewriting history to change an identity
- `git filter-repo --mailmap` fixes author/committer only; a `Co-authored-by: <old email>` trailer in the message needs `--replace-message` too. Bundle first (`git bundle create .tmp/<repo>.bundle --all`), then check `git log --branches --tags --format='%ae%n%ce%n%B' | grep -ci <old>` is 0 and the HEAD tree hash is unchanged. Push main with `--force-with-lease=main:<old sha>`, then `--force --tags`. Other clones must `reset --hard origin/main`, never pull. Changing the email does not change who owns the copyright.
- **Before any rewrite, list open PRs** (`gh pr list --state open`): a rewrite or fresh-history push closes them unmerged and their changes vanish silently. Merge them first, or re-apply each one's diff (`gh pr diff <n>`) on the new main.

## Check it worked
`git status -sb`, `git worktree list`, and for a PR `gh pr view <n> --json state,mergedAt` plus `git log origin/main..origin/<b>` empty.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a new git trap goes in the section for the moment it happens (keep ≤15 bullets).
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
