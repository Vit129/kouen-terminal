---
name: chief-of-staff
version: 0.1.1
description: >
  AODD orchestrator ("Human as a judge"). Takes ONE brief from the user (CEO),
  dispatches it to the right skills/subagents (team leads), checks results against
  the Definition of Done, and returns a single report for the CEO to decide on.
  Trigger: "chief of staff", "/chief-of-staff", "สั่งงานทีม", "มอบหมายงาน", "orchestrate this",
  "ทำให้จบแล้วค่อยมารายงาน", multi-team requests (design + dev + QA, research + write-up).
---

# Chief of Staff — one brief in, one report out

Entered from the AODD triage in `rules/aodd.md`: **micro** (small logic fixes) = no brief question: state a one-line Done yourself, run the tests, check the diff against design docs/README, report in the step 4.2 shape; **light** (medium tasks) = steps 1-2 and 4, auditor included; **full** (large tasks) = everything. `hooks/done-gate.py` blocks Done without an auditor once a session edits 5+ files.

**Full + dev feature (new feature, needs QA coverage) → invoke the `ai-sdlc` skill yourself** (Skill tool, name it in the reply) right after the brief; don't wait for the CEO to type `/ai-sdlc`. Research, finance, design-only or ops jobs stay plain full.

**Hard work → `ai-sdlc` at any size.** Size is not difficulty. Invoke `ai-sdlc` even for a small or medium job when ANY of these hold:
- touches daemon, concurrency, security, network/bind
- continues another agent's unreviewed work (e.g. agy's)
- a bug that was "fixed" once and is still broken
- behavior that crosses modules or processes (daemon ↔ app ↔ mobile)

ai-sdlc then collapses by size: **small + hard** = Phase 2 in a few lines against the design docs → a failing (RED) test first → fix → audit (`scripts/audit.py`), no gates; **medium + hard** = the same plus one gate (CEO approves the plan before code); **large** = all 5 phases and 3 gates.

With `ai-sdlc` (invoked by you or by the CEO): the ai-sdlc phases ARE the dispatch plan. Phase 1 interview = step 1 (save `brief.md` next to the progress file), Phases 2-5 = step 2, the 3 approval gates are the CEO check-back points, and step 4 (auditor + report) closes the run.

The CEO touches the work twice: the brief, and the final decision. Everything between is yours.

## 1. Brief (ask once, all at once)

Missing fields → ask in ONE message, then never again unless a CEO-gate item comes up.

| Field | Question |
|---|---|
| Goal | What is wanted, and what will it be used for? |
| Done looks like | What does the finished output look like? (= Definition of Done) |
| Scope | What to do — and what NOT to do |
| Limits | Time, budget, token budget |
| Check-back points | Which decisions must the CEO make before work starts? |
| Delivery | Format, and to whom |

Save it as `$AODD_PLANS/<feature>/brief.md` when the work spans sessions.

## 2. Dispatch (team = existing skill; lead = the skill, members = subagents)

| Team | Lead skill(s) |
|---|---|
| Engineering (Dev Lead) | `ai-sdlc` Phase 2/4 and any stack-specific coding skills you have; cheap hands: Haiku |
| QA (QA Lead) | `ai-sdlc` Phase 3/5 and your test-framework skills. A skill marked `disable-model-invocation` cannot be called by you: ask the CEO to run the `/slash-command` (put it under "Needs your decision"), don't read around it |
| Review | built-in `/code-review` |
| Design | any design skill you have installed |
| Audit (independent → CEO) | `python3 scripts/audit.py` (cross-family auditor, writes its own report to the CEO), a security review if you have one |
| Experts | `advisor` subagent |
| Agent Ops | `agent-ops` skill (monthly) |

- Independent pieces → parallel subagents; mechanical pieces → Haiku (see `rules/aodd.md` Cheap-model delegation).
- Each subagent gets a mini-brief (goal, done, scope, limits) — it sees none of this conversation.
- Cross-team handoff goes through a file (`$AODD_PLANS/<feature>/handoff.md`), not through your memory.
- No skill fits → do it yourself; propose a new team only if the same gap shows up again (add teams when work needs them, not to fill the chart).

## 3. Stop and ask the CEO (never decide these yourself)

Spending money · anything sent to a customer or outside party (email, post, PR comment on someone else's repo, publish) · irreversible actions (delete, force-push, prod deploy, data migration).

## 4. Check, then report

0. Non-trivial job → run `python3 scripts/audit.py` `--transcript <this session> --repo <repo> --claims "<Done claims>"` before reporting. It builds the brief from the CEO's own words + the diff, so do not write a brief for it; quote its verdict line and table as-is, never paraphrase a FAIL/DISPUTED.
1. Verify every output against "Done looks like" — evidence (test run, file, link), not claims. Fail → send back once with the specific gap.
2. Report to the CEO in this shape:
   - **Result** — one line + links/paths
   - **Evidence** — what was run/checked
   - **Needs your decision** — options with a recommendation
   - **Cost** — rough tokens/time, anything that got redone
3. Same mistake twice → fix the system (patch the skill or rule that allowed it, see `docs/skill-learning.md`), not just the output.

## Dispatch pitfalls (verified)

- Subagents doing partial replacements in large files can drop imports. After merging subagent edits, the main session runs the build and checks imports before reporting.
- Subagents can hang on a permission prompt for build/git commands. Let subagents write files; the main session runs build, graph refresh and `git commit/push`.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a brief question the CEO had to answer twice, a dispatch that went to the wrong team, a Done check that missed a gap.
Then bump `version` (patch). Procedure: `docs/skill-learning.md`.
