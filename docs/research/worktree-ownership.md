# Who creates branches / worktrees in AI coding tools

Researched 2026-10-13 from each vendor's own docs (URLs below were fetched that day). Cells say
"not stated" where the page does not say — nothing is filled in from memory.

**Question:** who decides to create a branch or worktree, and does any tool move the user's own
checkout implicitly?

| Tool | Who creates branch / worktree | Worktree or clone/container | Touches user's checkout? | Cleanup |
|---|---|---|---|---|
| Claude Code (`--worktree`, `EnterWorktree`) | User passes `--worktree <name>` or asks Claude to; branch `worktree-<name>` from the default branch (`worktree.baseRef`, default `fresh`) | Worktree under `.claude/worktrees/<name>/` | No. While isolated, edits/commands/git redirects into the main checkout are blocked | Exit prompts when work exists; clean unnamed sessions auto-removed; background/subagent worktrees swept after `cleanupPeriodDays` |
| Claude Code subagent `isolation: worktree` | Declared in the subagent's frontmatter or requested by Claude; created per subagent run | Temporary worktree | No; commands resolving to the main checkout fail | Removed automatically when the subagent finishes without changes |
| Codex app / CLI (local) | User picks "Worktree" under the composer; scheduled tasks use background worktrees | Worktree in `$CODEX_HOME/worktrees`, detached HEAD by default | Separate directory; a branch can only be checked out in one place, so Hand off moves it between Local and the worktree explicitly | Keeps newest 15 managed worktrees; deleted on chat archive; snapshot saved before deletion |
| Codex cloud | Not stated (page does not mention branch creation) | Remote task workspace from a configured environment | Not stated; described as separate from your computer | Review changes, then commit or open a PR |
| Cursor cloud ("background") agents | Agent works on its own branch and pushes it (naming not stated) | Isolated cloud VM with cloned repo | Not stated explicitly; work happens in the VM, test without "checking out the branch locally" | Result is a PR |
| GitHub Copilot cloud agent | "Copilot handles branch creation, commit messages, and pushing changes" | Ephemeral cloud dev environment | Not stated; runs outside your IDE | One PR per task |
| Google Jules | You choose the branch to work on; whether it creates a new one is not stated | VM that clones the repo | Page does not mention a local checkout | Plan approval before changes; result delivery not covered in the page read |
| Conductor | Conductor creates a branch per workspace from the configured base (`origin/main`), then asks the agent to rename it | Git worktrees ("separate checkouts") | Agents work "without colliding with your main checkout"; a setup script can optionally keep the root checkout's branch current | Archive after review/merge (mechanics not on the pages read) |
| **Kouen before this change** | **Kouen itself, unprompted, on a polled branch change** | Worktree in `.kouen-worktrees/<slug>` | **Yes: `git checkout <base>` in the shared primary tree, then `cd` the tab** | Removed on session close if clean |

## Findings

- Every local tool surveyed makes creation an explicit act by the user or by the agent the user
  launched (a flag, a composer toggle, a frontmatter field, a tool call). None of the pages read
  describes a tool that watches a shell's branch and relocates it on its own.
- None of the local tools moves the user's checkout as a side effect of creating a worktree.
  Claude Code goes further and blocks isolated sessions from touching it; Codex makes handoff an
  explicit, user-triggered operation.
- Worktrees come with their own environment step: Claude Code tells the user to initialize
  dependencies in the worktree and offers `.worktreeinclude` for gitignored files; Codex runs a
  local environment's setup script. This matches Kouen's `setupScript` and the CASE-041 lesson
  (never symlink `node_modules` between checkouts).
- The cloud agents sidestep the question by never sharing the user's folder at all.

## What this means for Kouen

A branch change observed in a shared folder is information, not a request. Kouen now only shows
a notice with an explicit "Isolate into worktree" action; the creating paths agents should use
(`kouenWorktreeCreate`, task/feature create) stay explicit and run `setupScript`.

## Sources

- Claude Code worktrees: https://code.claude.com/docs/en/worktrees
- Claude Code common workflows (parallel sessions): https://code.claude.com/docs/en/common-workflows
- Claude Code subagents (`isolation: worktree`): https://code.claude.com/docs/en/sub-agents
- Codex worktrees: https://learn.chatgpt.com/docs/environments/git-worktrees (redirected from https://developers.openai.com/codex/app/worktrees)
- Codex cloud: https://learn.chatgpt.com/docs/cloud
- Cursor cloud agents: https://cursor.com/docs/background-agent
- GitHub Copilot cloud agent: https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent
- Google Jules: https://jules.google/docs
- Conductor: https://www.conductor.build/docs/ and https://www.conductor.build/docs/concepts/workspaces-and-branches
