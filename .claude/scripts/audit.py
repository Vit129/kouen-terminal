#!/usr/bin/env python3
"""Independent AODD audit: the worker never writes the brief, never sees the verdict first, never edits it.

    python3 scripts/audit.py --transcript <session.jsonl> [--repo .] [--base <ref>] [--claims "..."]

1. Brief is built here, not by the worker: the user's own messages (verbatim, from the transcript),
   the git log + diff of the session, and the worker's claims (labelled untrusted).
2. Auditor is another model family than the worker (cross-family rule):
   worker Claude Opus/Fable -> Codex (read-only sandbox) if installed, else Claude Opus (same-family, said in the report);
   worker Codex -> Claude Opus; worker Claude Sonnet/Haiku -> Claude Opus.
3. Codex can invent evidence, so when it audits, a fresh Claude Opus (cold, not the worker)
   re-checks every row. But Codex has also caught real Claude mistakes that Claude then confirmed,
   so a Claude verifier may not clear a Codex FAIL on its own: Codex FAIL + verifier PASS = DISPUTED,
   which the CEO decides (combine()). The verifier can only add failures, never erase one silently.
4. This script writes the report ($AODD_REPORTS/audit-<date>-<sid8>.md, frontmatter `verdict:`);
   hooks/done-gate.py reads it before a session may claim Done. Repo changed during the audit -> FAIL.
Exit 0 = PASS, 1 = FAIL/UNVERIFIABLE, 2 = could not run.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path

HOME = Path.home()
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "hooks"))
import _aodd_paths  # noqa: E402
REPORTS = _aodd_paths.reports()
JD = Path(__file__).resolve().parent.parent / "agents/auditor.md"
CLAUDE = os.environ.get("CLAUDE_BIN", "claude")
CODEX = os.environ.get("CODEX_BIN", "codex")
MAX_DIFF = 60_000
# `(?!\s*\|)`: never read the format template line "OVERALL: PASS|FAIL|..." (echoed in errors) as a verdict
VERDICT = re.compile(r"^\s*(?:\*\*)?OVERALL:\s*(PASS|FAIL|UNVERIFIABLE)\b(?![ \t]*\|)", re.M | re.I)

FORMAT = """Output format (exact):
OVERALL: PASS|FAIL|UNVERIFIABLE
| # | Claim / requirement | Verdict | Evidence (command + output excerpt, or file:line) |
Then at most 5 lines the CEO must decide. Max 40 lines. A row without concrete evidence is UNVERIFIABLE.
You cannot edit files; do not try."""


def _text(content) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text")
    return ""


def read_transcript(path: Path):
    """(user messages, worker kind: 'codex' | 'claude-<family>', first timestamp or None)."""
    users, worker, first_ts = [], None, None
    for line in path.open(errors="ignore"):
        try:
            r = json.loads(line)
        except json.JSONDecodeError:
            continue
        first_ts = first_ts or r.get("timestamp")
        pl = r.get("payload")
        if r.get("type") in ("session_meta", "turn_context", "response_item", "event_msg") and isinstance(pl, dict):
            worker = "codex"  # Codex rollout: {timestamp, type, payload}; model is in turn_context.payload.model
            if r["type"] == "response_item" and pl.get("type") == "message" and pl.get("role") == "user":
                said = _text([{**b, "type": "text"} for b in pl.get("content") or [] if b.get("type") == "input_text"]).strip()
                if said and not said.startswith(("<", "# AGENTS.md")):  # injected AGENTS.md / environment blocks are not the user
                    users.append(said[:4000])
            continue
        if r.get("type") == "user" and not r.get("isSidechain") and not r.get("isMeta"):
            said = _text((r.get("message") or {}).get("content"))
        else:
            m = (r.get("message") or {}).get("model") or ""
            if m.startswith("claude-") and worker != "codex":
                worker = "claude-" + next((f for f in ("opus", "fable", "sonnet", "haiku") if f in m), "opus")
            continue
        said = (said or "").strip()
        if said and not said.startswith(("<command-", "<local-command", "[Request interrupted", "Stop hook feedback")):
            users.append(said[:4000])
    return users, worker or "claude-opus", first_ts


def pick_auditor(worker: str) -> str:
    """Cross-family by default; Opus audits its own family only for Sonnet/Haiku work or when Codex is not installed."""
    if worker in ("claude-opus", "claude-fable"):
        return "codex" if shutil.which(CODEX) else "claude-opus"
    return "claude-opus"


def git(repo, *args) -> str:
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True).stdout


def scope(repo: Path, base: str | None, since: str | None) -> tuple[str, str]:
    if not base and since:
        first = git(repo, "log", "--reverse", f"--since={since}", "--format=%H").split()
        base = f"{first[0]}~1" if first else None
    base = base or git(repo, "merge-base", "HEAD", "origin/main").strip() or "HEAD"
    log = git(repo, "log", "--oneline", f"{base}..HEAD")
    untracked = [f for f in git(repo, "ls-files", "--others", "--exclude-standard").split("\n") if f]
    stat = git(repo, "diff", "--stat", base) + "".join(f" {f} (untracked)\n" for f in untracked)
    # new files get at most half the budget, so neither a big edit nor a big new file hides the other
    new = "".join(git(repo, "diff", "--no-index", "/dev/null", f) for f in untracked)[:MAX_DIFF // 2]
    diff = git(repo, "diff", base)[:MAX_DIFF - len(new)] + new
    return base, f"git log {base}..HEAD:\n{log or '(none)'}\n\ndiff vs {base} (incl. uncommitted):\n{stat}\n{diff}"


def run_model(who: str, prompt: str, repo: Path) -> str:
    # Claude gets the prompt on stdin: as argv, a prompt starting with the JD's `---` frontmatter is
    # parsed as an unknown option (exit 1).
    if who == "codex":  # prompt on stdin via `-`: read-only sandbox, no session file, only the final message on stdout
        cmd, stdin = [CODEX, "exec", "-s", "read-only", "--ephemeral", "--color", "never", "-C", str(repo), "-"], prompt
    else:
        cmd, stdin = [CLAUDE, "-p", "--model", "opus", "--allowedTools", "Read Grep Glob Bash",
                      "--disallowedTools", "Edit Write NotebookEdit"], prompt
    # AODD_AUDITOR: hooks/auditor-readonly.py blocks writes. CLAUDE_SKILL_CAPTURE=0: the Stop nudge would
    # otherwise ask the auditor to write a skill patch.
    env = {**os.environ, "AODD_AUDITOR": "1", "CLAUDE_SKILL_CAPTURE": "0"}
    try:
        p = subprocess.run(cmd, cwd=repo, input=stdin, stdin=None if stdin else subprocess.DEVNULL,
                           capture_output=True, text=True, env=env, timeout=1800)
    except (OSError, subprocess.TimeoutExpired) as e:
        return f"OVERALL: UNVERIFIABLE\n{who} run failed: {e}"
    if p.returncode or not p.stdout.strip():
        return f"OVERALL: UNVERIFIABLE\n{who} run failed (exit {p.returncode}): {p.stderr.strip()[-300:]}"
    return p.stdout.strip()


def verdict(text: str) -> str:
    m = VERDICT.search(text)
    return m.group(1).upper() if m else "UNVERIFIABLE"


def combine(first: str, opus: str) -> str:
    """Final verdict when Codex audits and a Claude Opus verifies (see docstring point 3)."""
    if first == "PASS" and opus == "PASS":
        return "PASS"
    if first == "FAIL" and opus == "PASS":
        return "DISPUTED"
    return "FAIL" if "FAIL" in (first, opus) else "UNVERIFIABLE"


def build_prompt(users, claims, scope_text) -> str:
    asks = "\n---\n".join(users[-15:]) or "(no user messages found)"
    jd = JD.read_text() if JD.is_file() else ""
    return (f"{jd}\n\nYou are auditing work done in this repo. Re-run checks yourself.\n\n"
            f"## What the user (CEO) actually asked, verbatim\n{asks}\n\n"
            f"## Worker's own Done claims (UNTRUSTED, verify each; also flag asks the claims skip)\n{claims or '(none given)'}\n\n"
            f"## Scope\n{scope_text}\n\n{FORMAT}")


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--transcript", required=True)
    ap.add_argument("--repo", default=".")
    ap.add_argument("--base")
    ap.add_argument("--claims", default="")
    ap.add_argument("--auditor", choices=["codex", "claude-opus"], help="override the cross-family pick")
    a = ap.parse_args(argv)
    tr, repo = Path(a.transcript), Path(a.repo).resolve()
    if not tr.is_file():
        print(f"audit: transcript not found: {tr}", file=sys.stderr)
        return 2
    users, worker, since = read_transcript(tr)
    who = a.auditor or pick_auditor(worker)
    label = who
    if who == "codex" and not shutil.which(CODEX):  # chosen auditor missing: Opus audits, said in the report
        who, label = "claude-opus", "claude-opus (codex not installed, same-family)"
    elif who == "claude-opus" and worker in ("claude-opus", "claude-fable") and not a.auditor:
        label = "claude-opus (codex not installed, same-family)"
    base, scope_text = scope(repo, a.base, since)
    before = git(repo, "status", "--porcelain") + git(repo, "rev-parse", "HEAD")
    reports_before = set(REPORTS.glob("*")) if REPORTS.is_dir() else set()

    first = run_model(who, build_prompt(users, a.claims, scope_text), repo)
    final, notes = first, ""
    other = who == "codex"
    if other:  # Codex can cite evidence that does not exist: a cold Opus re-checks every row
        check = (f"{JD.read_text() if JD.is_file() else ''}\n\nAnother model ({who}) audited this repo. It sometimes "
                 "invents evidence. Re-check EVERY row yourself (open the file:line, re-run the command). Keep rows "
                 "you confirm. To overturn a row you must show concrete counter-evidence (command + output, file:line); "
                 "it has caught real mistakes before, so do not dismiss a FAIL for lack of agreement. Add anything it missed against the user's asks.\n\n"
                 f"## User asks, verbatim\n" + "\n---\n".join(users[-15:]) +
                 f"\n\n## Scope\n{scope_text}\n\n## {who}'s audit\n{first}\n\n{FORMAT}\n"
                 "After the table add `Overturned auditor rows:` listing each row you reversed and why (or `none`).")
        final, notes = run_model("claude-opus", check, repo), "verified by a fresh Claude Opus"

    # Known limit: only the repo and pending-reports/ are checked; the auditor's own file tool can write elsewhere.
    stray = (set(REPORTS.glob("*")) if REPORTS.is_dir() else set()) - reports_before
    if git(repo, "status", "--porcelain") + git(repo, "rev-parse", "HEAD") != before or stray:
        final = ("OVERALL: FAIL\nThe auditor wrote files during the audit" +
                 (f" ({', '.join(p.name for p in stray)})" if stray else "") + ". Audit void.\n\n" + final)
    v = verdict(final)
    if other and "Audit void" not in final:
        v = combine(verdict(first), v)
    sid = _aodd_paths.session_id(tr)
    REPORTS.mkdir(parents=True, exist_ok=True)
    out = REPORTS / f"audit-{date.today()}-{sid}.md"
    if out.exists():  # a same-day re-audit keeps the earlier verdict as history in done/ instead of overwriting it
        (REPORTS / "done").mkdir(exist_ok=True)
        out.rename(REPORTS / "done" / f"audit-{date.today()}-{datetime.fromtimestamp(out.stat().st_mtime):%H%M%S}-{sid}.md")
    out.write_text(f"---\nsession: {tr.stem}\nrepo: {repo}\nbase: {base}\nworker: {worker}\nauditor: {label}\n"
                   f"verifier: {'claude-opus' if other else 'none'}\nverdict: {v}\n---\n\n"
                   f"# Audit {date.today()} — {repo.name}\n\n## Final ({notes or who})\n\n{final}\n" +
                   (f"\n## {who}'s original audit\n\n{first}\n" if other else ""))
    print(f"audit: {v} ({worker} audited by {label}{' + opus verifier' if other else ''}) -> {out}")
    return 0 if v == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
