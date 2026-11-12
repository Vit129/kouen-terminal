# How the audit works

`python3 scripts/audit.py --transcript <session.jsonl> --repo <repo> --claims "<your Done claims>"`

1. **The worker never writes the brief.** `audit.py` builds it from the CEO's own messages (verbatim, from the transcript), the git log and diff of the session (including uncommitted and untracked files), and the worker's claims, labelled untrusted.
2. **Cross-family auditor.** The auditor is a different model family than the worker:

   | Worker | Auditor |
   |---|---|
   | Claude Opus / Fable | Codex |
   | Codex | Claude Opus |
   | Claude Sonnet / Haiku | Claude Opus |
   | Claude Opus / Fable, Codex not installed | Claude Opus, reported as same-family |

3. **Verifier and the DISPUTED rule.** Codex sometimes invents evidence, so when it audits, a cold Claude Opus re-checks every row. It has also caught real Claude mistakes, so a Claude verifier may not clear its FAIL on its own: auditor FAIL + verifier PASS = **DISPUTED**, and the CEO decides. The verifier can only add failures, never erase one silently. Combined verdicts: PASS, FAIL, DISPUTED, UNVERIFIABLE.
4. **Read-only, void on write.** The auditor runs with `AODD_AUDITOR=1`; `hooks/auditor-readonly.py` denies edits and Bash commands that write files or git history. Afterwards `audit.py` compares `git status` and `HEAD` and the reports directory; any change voids the audit (verdict FAIL, "Audit void").
5. **Report.** Written to `$AODD_REPORTS/audit-<date>-<sid8>.md` with a `verdict:` frontmatter line. Exit code 0 = PASS, 1 = FAIL/DISPUTED/UNVERIFIABLE, 2 = could not run.

### done-gate behaviour

`hooks/done-gate.py` is a Stop hook. It blocks stopping once per stop cycle, and only for progress files this session wrote to:

- a touched `ai-sdlc-task-progress.md` still has `- [ ]` boxes: finish them or say plainly the feature is not done;
- every box is ticked but no audit report exists for this session: run `audit.py` first;
- no progress file but the session edited 5 or more files (AODD medium): same audit requirement;
- the audit verdict is FAIL / UNVERIFIABLE / DISPUTED: report it to the CEO as it is.

It fails open on any error. `DONE_GATE_AUDIT=0` disables the audit requirement.
