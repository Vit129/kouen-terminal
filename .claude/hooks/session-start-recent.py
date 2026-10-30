#!/usr/bin/env python3
"""SessionStart hook (agent-memory module): inject this project's latest session digest and, in the
workspace only, the queue of reports that wait for the CEO.

  digest     <memory root>/<project>/SESSION-TOPICS.md, last "## " section (when the file exists);
             $AODD_DIGEST = path template with {project}, $AODD_PROJECT_ALIASES = "name=alias,..."
  reports    newest report of each kind in $AODD_REPORTS (kinds: $AODD_REPORT_KINDS, comma list; default
             agent-ops,housekeeping,pending-work), pointed at once
  proposals  agy-*.md in $AODD_REPORTS until moved to done/; an agy-proposal without evidence
             (scripts/check_agy_proposal.py) is auto-rejected into done/ and never reaches the CEO
  progress   unfinished ai-sdlc/dev/qa progress files of this project ($AODD_PLANS with {project}, and
             <repo>/agent-memory/plans/): feature + first open box; carried-over files (Moved to:) skipped
  audits     audit-*.md: PASS is filed to done/, FAIL / DISPUTED / UNVERIFIABLE is shown until filed

"Workspace" = a session whose cwd is inside a dir of $AODD_WORKSPACE (os.pathsep list; default: the
Claude home). The queue is shown there only, so it never interrupts a project session; an audit also
shows in a session of the repo it audited. Fails open (any error prints nothing).
"""
import importlib.util
import json
import os
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
for _d in (HERE, HERE.parents[2] / "hooks"):  # installed: next to this file; in the repo: core hooks/
    sys.path.append(str(_d))
import _aodd_paths  # noqa: E402


def report_kinds():
    raw = os.environ.get("AODD_REPORT_KINDS") or "agent-ops,housekeeping,pending-work"
    return [k.strip() for k in raw.split(",") if k.strip()]


def digest_file(cwd):
    """First existing digest for the project: $AODD_DIGEST template ({project}; default
    <memory root>/{project}/SESSION-TOPICS.md for every root) tried for the project name, then for its
    alias from $AODD_PROJECT_ALIASES ("name=alias,...")."""
    name = _aodd_paths.project(cwd)
    aliases = dict(a.split("=", 1) for a in os.environ.get("AODD_PROJECT_ALIASES", "").split(",") if "=" in a)
    tpls = [os.environ["AODD_DIGEST"]] if os.environ.get("AODD_DIGEST") else [
        str(m / "{project}" / "SESSION-TOPICS.md") for m in _aodd_paths.memory_dirs()]
    for n in (name, aliases.get(name, "").strip()):
        for t in tpls if n else []:
            f = Path(t.replace("{project}", n)).expanduser()
            if f.is_file():
                return f
    return None


PROGRESS = ("ai-sdlc-task-progress.md", "dev-task-progress.md", "qa-task-progress.md")


def open_progress(here):
    """'<feature>: <first open box>' for each live progress file of this project: $AODD_PLANS when it is
    per project ({project}), plus the repo's own agent-memory/plans/. A file with 'Moved to:' was carried
    over and is skipped."""
    dirs = [here / "agent-memory" / "plans"]
    if "{project}" in os.environ.get("AODD_PLANS", ""):
        dirs.insert(0, _aodd_paths.plans(str(here)))
    out = []
    for d in dirs:
        for f in sorted(p for n in PROGRESS for p in d.rglob(n)) if d.is_dir() else []:
            lines = f.read_text(encoding="utf-8", errors="ignore").splitlines()
            box = next((l.strip()[6:] for l in lines if l.lstrip().startswith("- [ ]")), None)
            if box and not any(l.startswith("Moved to:") for l in lines):
                out.append(f"- {f.parent.relative_to(d)}: {box[:120]}  ({f})")
    return out[:10]


def main(payload):
    cwd = payload.get("cwd") or "."
    here = Path(cwd).expanduser().resolve()
    reports = _aodd_paths.reports()
    parts = []
    topics = digest_file(cwd)
    if topics:
        parts.append("Last session digest for this project (from SESSION-TOPICS.md):\n## "
                     + topics.read_text(encoding="utf-8").split("\n## ")[-1][:3000])
    live = open_progress(here)
    if live:
        parts.append("Unfinished work in this project (feature: first open box). On 'continue' or a related "
                     "request, open that file and resume there; do not re-read the rest:\n" + "\n".join(live))
    workspace = any(here == r or r in here.parents for r in _aodd_paths.workspace_dirs())
    if workspace and reports.is_dir():
        seen_file = _aodd_paths.state() / "reports-seen"
        seen = set(seen_file.read_text().split()) if seen_file.is_file() else set()
        new = []
        for kind in report_kinds():
            newest = max(reports.glob(f"{kind}-*.md"), default=None, key=lambda p: p.stat().st_mtime)
            if newest and newest.name not in seen:
                new.append(newest)
        if new:
            parts.append("New scheduled reports not yet shown to the user:\n" + "\n".join(f"- {p}" for p in new) +
                         "\nMention them in one line each in your first reply (path + what decision waits); do not act on them unasked.")
            seen_file.parent.mkdir(parents=True, exist_ok=True)
            seen_file.write_text("\n".join(sorted(seen | {p.name for p in new})))
    agy = sorted(reports.glob("agy-*.md")) if reports.is_dir() else []
    cap = None
    for d in (HERE.parent / "scripts", HERE.parents[2] / "scripts"):
        f = d / "check_agy_proposal.py"
        if f.is_file():
            spec = importlib.util.spec_from_file_location("cap", f)
            cap = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(cap)
            break
    if workspace and cap and any(p.name.startswith("agy-proposal-") for p in agy):
        rejected = []
        for p in [p for p in agy if p.name.startswith("agy-proposal-")]:
            why = cap.problems(p.read_text(errors="ignore"))
            if why:
                (reports / "done").mkdir(exist_ok=True)
                p.write_text(p.read_text(errors="ignore") + "\n\n---\n**Auto-rejected (check_agy_proposal.py):** " + "; ".join(why) + "\n")
                p.rename(reports / "done" / p.name)
                rejected.append(p.name)
        agy = [p for p in agy if p.name not in rejected]
        if rejected:
            parts.append(f"{len(rejected)} agy-proposal(s) auto-rejected for missing evidence (filed to pending-reports/done/): " +
                         ", ".join(rejected) + ". Mention this in one line; no decision needed.")
    if agy and workspace:
        parts.append("Pending proposals from other agents (you decide, the user approves):\n" +
                     "\n".join(f"- {p}" for p in agy) +
                     "\nTriage them with ONE Haiku subagent (Agent model=haiku): it reads each proposal and its target file and returns "
                     "accept/reject + one-line why. List those with the source project in your first reply. On the user's approval apply it "
                     "in the Claude home, then move the file to done/ with the decision noted.")
    show = []
    for p in sorted(reports.glob("audit-*.md")) if reports.is_dir() else []:
        text = p.read_text(errors="ignore")
        verdict = next((l for l in text.splitlines() if l.startswith("verdict:")), "verdict: ?")
        repo = next((l.split(":", 1)[1].strip() for l in text.splitlines() if l.startswith("repo:")), "")
        mine = bool(repo) and (here == Path(repo).resolve() or Path(repo).resolve() in here.parents)
        if verdict == "verdict: PASS":
            if workspace:  # recorded, nothing to decide: file it so pending-reports/ does not fill up
                try:
                    (reports / "done").mkdir(exist_ok=True)
                    p.rename(reports / "done" / p.name)
                except OSError:
                    pass
        elif workspace or mine:
            show.append(f"- {p}: {verdict}")
    if show:
        parts.append("Independent audits that need the CEO (quote each verdict line as-is in your first reply; "
                     "listed until the file is moved to done/):\n" + "\n".join(show))
    if parts:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart",
              "additionalContext": "\n\n".join(parts)}}, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main(json.load(sys.stdin) if not sys.stdin.isatty() else {})
    except Exception:
        pass  # fail open
