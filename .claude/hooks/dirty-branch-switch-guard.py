#!/usr/bin/env python3
"""PreToolUse(Bash): refuse to start another task while earlier work is uncommitted.

  1. `git checkout|switch` to ANOTHER branch while this tree has uncommitted tracked changes.
  2. `git worktree add` while ANY worktree of that repo has uncommitted
     changes (a new worktree branches from main/baseRef, so it never contains them). When all are
     committed but a sibling branch still has commits not in the base, it only adds a reminder to
     merge that branch into the new one if the new task builds on it.

Rule: commit task 1 on its own branch before starting task 2 elsewhere.
Fails open on any error. Disable with BRANCH_SWITCH_GUARD=0. `git checkout -- <path>` / `-b` from a
clean tree / `git switch -` are judged only by the dirty check, file restores are never blocked.
"""
import json
import os
import re
import subprocess
import sys

SWITCH = re.compile(r"\bgit\s+(?:-C\s+(?P<c>\S+)\s+)?(checkout|switch)\b(?P<rest>[^;&|\n]*)")


# `git stash` / `stash push|save` (not list/show/pop/apply) before the switch in the same command
# leaves the tree clean at that point ponytail: a path-limited `stash push -- <p>` is
# trusted to cover all changes; if a partial stash ever slips dirty work through, check the paths.
STASH = re.compile(r"\bgit\s+(?:-C\s+\S+\s+)?stash(?:\s+(?:push|save)\b|\s*(?:-q\s*)?(?:&&|;|\|\||$))")


def stashed_before(cmd: str, pos: int) -> bool:
    return bool(STASH.search(cmd[:pos]))


def switches_branch(rest: str) -> bool:
    args = rest.split()
    if "--" in args or "-p" in args or "--patch" in args:
        return False  # restoring paths, not switching
    return any(not a.startswith("-") or a in ("-b", "-B", "-c", "-C") for a in args)


def unquoted(cmd: str) -> str:
    """Drop quoted strings and heredoc bodies so prose in a commit message / script never looks like a git command."""
    cmd = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?.*?\n\1\b", "", cmd, flags=re.S)
    return re.sub(r"\"(?:\\.|[^\"\\])*\"|'[^']*'", '""', cmd)


# a graphify refresh rewrites graphify-out/ after every session; in repos that track it that is never "unfinished work"
GENERATED = ":(exclude,glob)**/graphify-out/**"


def git(repo, *args):
    return subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, timeout=5).stdout


def sibling_state(repo):
    """(dirty, unmerged): worktrees with uncommitted changes, and branches with commits not in main."""
    dirty, unmerged = [], []
    base = next((b for b in ("main", "master") if git(repo, "rev-parse", "--verify", "-q", b).strip()), None)
    for line in git(repo, "worktree", "list", "--porcelain").splitlines():
        if not line.startswith("worktree "):
            continue
        wt = line.split(" ", 1)[1]
        if git(wt, "status", "--porcelain", "--untracked-files=no", "--", ".", GENERATED).strip():
            dirty.append(wt)
        branch = git(wt, "symbolic-ref", "--short", "-q", "HEAD").strip()
        if base and branch and branch != base and git(repo, "rev-list", "--count", f"{base}..{branch}").strip() not in ("", "0"):
            unmerged.append(branch)
    return dirty, unmerged


def new_worktree_repo(tool, ti):
    cmd = unquoted(ti.get("command", ""))
    m = re.search(r"\bgit\s+(?:-C\s+(\S+)\s+)?worktree\s+add\b", cmd)
    return (m.group(1) or ".", stashed_before(cmd, m.start())) if m else None


def decide(data: dict):
    """Returns (error_msg, is_blocking: bool, additional_context: str | None)."""
    ti = data.get("tool_input", {})
    wt = new_worktree_repo(data.get("tool_name", ""), ti)
    if isinstance(wt, str):
        wt = (wt, False)
    if wt and wt[0]:
        repo, stashed = wt
        dirty, unmerged = sibling_state(os.path.expanduser(repo))
        if stashed:  # the stash cleans the current worktree; other dirty worktrees still block
            here = os.path.realpath(git(os.path.expanduser(repo), "rev-parse", "--show-toplevel").strip() or repo)
            dirty = [d for d in dirty if os.path.realpath(d) != here]
        if dirty:
            msg = ("Cannot start a new worktree: uncommitted work in\n" + "\n".join(dirty[:5]) +
                   "\n\nCommit it on its own branch first (two tasks, two branches); the new "
                   "worktree starts from main/baseRef and will not contain it.")
            return msg, True, None
        if unmerged:
            ctx = ("Branches with commits not in main: " + ", ".join(unmerged[:6]) + ". If the new task builds on "
                   "one of them, merge that branch into the new branch (never into main) and say so in the PR.")
            return None, False, ctx
        return None, False, None
    cmd = unquoted(ti.get("command", ""))
    m = SWITCH.search(cmd)
    if not m or not switches_branch(m.group("rest")) or stashed_before(cmd, m.start()):
        return None, False, None
    out = git(os.path.expanduser(m.group("c") or "."), "status", "--porcelain", "--untracked-files=no", "--", ".", GENERATED).strip()
    if not out:
        return None, False, None
    files = "\n".join(out.splitlines()[:8])
    msg = ("Uncommitted work on the current branch:\n" + files +
           "\n\nCommit it on THIS branch first (two tasks, two branches). If the next task "
           "builds on it, branch from here or merge this branch into the new one; if independent, branch from main.")
    return msg, True, None


def main():
    if os.environ.get("BRANCH_SWITCH_GUARD") == "0":
        return 0
    try:
        data = json.load(sys.stdin)
        msg, blocking, ctx = decide(data)
        if blocking and msg:
            print(msg, file=sys.stderr)
            return 2
        if ctx:
            print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": ctx}}))
        return 0
    except Exception:
        return 0


if __name__ == "__main__":
    sys.exit(main())
