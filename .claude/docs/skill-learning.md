# Skill learning: how an agent improves its own skills

Lessons live **inside skills**, not in a separate lessons file. The Stop hook
`hooks/skill-capture-nudge.py` runs this procedure for Claude Code. Other agents (Antigravity
`agy`, Codex) never patch their synced copies of a skill: they raise the same patch as an
`agy-proposal-*.md` in `$AODD_REPORTS/` and Claude decides. A proposal must carry the
evidence fields below; `scripts/check_agy_proposal.py` auto-rejects one without them.

```
- **Project:** <project name>
- **Repo:** <path to a git repo>
- **What:** <the skill/rule file to change, under .claude/>
- **Analysis:** <root cause, why it recurs, why it belongs in a global skill>
- **Code:** <file:line of the cause>
- **Test:** <command + failing output before the fix>
- **Fix:** <what changed>
- **Verified:** <the same command re-run after the fix, passing; must differ from Test>
- **Commit:** <hash that exists in Repo>
- **Proposed change:** <diff or exact text>
```

Sources: Hermes Agent (background review, curator), Letta Skill Learning, Voyager, Agent
Workflow Memory (AWM), ExpeL, Reflexion, SkillWeaver, SICA, Anthropic skill-creator.

## When to learn (any one signal is enough)

- The user corrected the approach, the order of steps, the output style, tone or length.
- A `fix:` / `revert:` commit was made: its cause belongs in the skill that governs that code or workflow.

The hook fires only on these two signals (plus at least 20 tool calls in the session). Ordinary tool errors are
normal work, not lessons. A skill that turned out wrong or missing a step is patched when it is noticed, with or without the hook.

## Where to write it (first rung that fits — Hermes order)

1. **A skill loaded this session** that covers the lesson: patch it, whoever wrote it.
2. **An existing class-level skill** (global `<claude-home>/skills/` or the project's
   `.claude/skills/`): add a step, a pitfall, or widen its trigger description.
3. **A support file under an existing skill**: `references/<topic>.md` (depth needed
   only sometimes; extend an existing topic file, never one file per incident),
   `scripts/<name>` (anything that should be run instead of retyped).
4. **A new skill**, only when nothing above fits. Project-specific → the project's
   `.claude/skills/<name>/`. Frontmatter: `name`, `description` (what the user would
   say to need it, Thai and English phrasing), `version: 0.1.0`,
   `origin: auto-captured`, `created: <today>`.

Aim for a few broad skills with references, not many narrow one-session skills.

## How to write it

- **Verified only (Voyager, Letta, SkillWeaver):** write a step only after it worked here —
  a test, build or command passed, or the user confirmed. Include how to check it worked.
  If the skill ships a `scripts/check*`, run it after the patch and keep the patch only if it passes.
- **General, not this session (AWM):** replace concrete values with placeholders
  (`<branch>`, `{ticker}`), keep the rule, drop the story. No error transcripts.
- **Fix wrong rules in place (ExpeL edit/downvote):** if a skill's rule caused the
  mistake, rewrite or delete that rule; do not append a contradicting one below it.
- **Bump frontmatter:** `version` patch +1 and `last_improved: <today>`
  (`improvement_count` +1 if the skill has it).
- **Bounded (Reflexion):** a Pitfalls/Gotchas list keeps at most ~15 items; past that,
  merge related ones or drop the least useful instead of appending.
- **Triggerable (skill-creator):** a new or widened `description` names what the user
  would actually say (Thai and English) and what it is NOT for, so it fires on the right
  requests and not on near-misses.
- **Size:** keep `SKILL.md` under ~500 lines / 24k chars; move depth to `references/`.
- **Safety:** no secrets, tokens, customer data or company identifiers in a global
  skill; project- or employer-specific lessons go in that project's own skills.
- Tell the user in one line which skill changed, so they can revert it. Git history is
  the version archive (SICA): a patch that made things worse is reverted, not stacked on.

## Curation

Periodically (the `agent-ops` skill) list every skill with its last use and its `version`:
skills unused for a long time, and auto-captured skills (`origin: auto-captured`) nobody loads, are
candidates to archive (move to `skills/.archive/`, recoverable, never deleted); skills with overlapping
descriptions are candidates to merge. These are proposals for the CEO, each with the evidence that
prompted it. `pinned: true` in frontmatter exempts a skill.

## Skill capture (self-improving skills)

`hooks/skill-capture-nudge.py` asks the agent to patch the governing skill, but only when the session has at least 20 tool calls and one of two signals: a **user correction** (English or Thai phrases such as "no", "wrong", "too long", "ไม่ใช่", "ยาวไป") or a **`fix:` / `revert:` commit**. Ordinary tool errors do not count. It nudges again only after 40 more tool calls with a new signal, and right after a fix commit it reminds in the moment. The procedure (where to write the lesson, verified-only, generalize, bump version) is `docs/skill-learning.md`. Disable with `CLAUDE_SKILL_CAPTURE=0`.

### Proposals from other agents (evidence gate)

Another agent (agy, Codex) never edits its synced copy of a skill. It writes `agy-proposal-<date>-<slug>.md` into `$AODD_REPORTS/`. `scripts/check_agy_proposal.py <file>` auto-rejects it unless it carries all of these fields, each non-trivial:

`Project`, `Repo` (a real git repo), `What` (targets a file under `.claude/`), `Analysis`, `Code`, `Test`, `Fix`, `Verified` (must differ from `Test`), `Commit` (a hash that exists in `Repo`), `Proposed change`.

It proves the evidence is present and the commit is real, not that the content is honest; the triage (the `agent-ops` skill) and the CEO still judge it.
