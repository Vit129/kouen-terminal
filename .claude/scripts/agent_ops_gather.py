"""Gather the weekly Agent Ops input for every agent tool installed (Claude Code in CLAUDE_HOME, Codex in
CODEX_HOME) into one markdown file, so the review covers all of them, not only the one that was used.

Per agent: skill inventory with how many of the last N days' sessions invoked each skill (unused skills
are an improvement target too) and rule files with last-modified date. Then the Work Log report
(hooks/work-log.py) and the skill learning loop (skill_learning_report.py).

ponytail: usage = transcripts containing an invocation marker (see markers()), not a real per-tool
transcript parse - good enough to separate used from never-used; upgrade to per-tool transcript parsing
if the counts start driving decisions on their own.

Antigravity has no skills folder to inventory, so it gets its own section when transcripts exist (dirs in
$AODD_AGY_TRANSCRIPTS, os.pathsep list; default ~/.gemini/antigravity/brain and ~/.gemini/antigravity-cli/brain):
per session the tool calls and the skills loaded. Silent when there are none.

Usage: agent_ops_gather.py OUT.md [--days 7]
"""
import datetime
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
CLAUDE = Path(os.environ.get("CLAUDE_HOME") or Path.home() / ".claude").expanduser()
CODEX = Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex").expanduser()
AGENTS = {
    "claude": {"root": CLAUDE, "sessions": [(CLAUDE / "projects", "*/*.jsonl")]},
    "codex": {"root": CODEX, "sessions": [(CODEX / "sessions", "**/*.jsonl")]},
}


def recent_files(sessions, days):
    cutoff = time.time() - days * 86400
    out = []
    for base, pattern in sessions:
        out += [p for p in base.glob(pattern) if p.is_file() and p.stat().st_mtime >= cutoff]
    return out


def session_key(f):
    parts = f.parts
    return f


def markers(skill):
    # An invocation, not a mention: Claude lists every skill name in each session's context, so
    # a bare name match counts everything. Skill tool call, or the SKILL.md being loaded/read.
    return (f'"skill":"{skill}"', f'"skill": "{skill}"', f"skills/{skill}/SKILL.md", f"skills/{skill}\n")


def skill_usage(skills, files):
    """(session count, {skill: sessions mentioning it})."""
    seen = {}
    for f in files:
        try:
            text = f.read_text(errors="ignore")
            seen.setdefault(session_key(f), set()).update(s for s in skills if any(m in text for m in markers(s)))
        except OSError:
            continue
    return len(seen), {s: sum(s in hit for hit in seen.values()) for s in skills}


SKILL_NAME = re.compile(r"skills/([^/\s'\"\\]+)/SKILL\.md")


def agy_dirs():
    raw = os.environ.get("AODD_AGY_TRANSCRIPTS")
    dirs = raw.split(os.pathsep) if raw else [str(Path.home() / ".gemini" / d / "brain") for d in ("antigravity", "antigravity-cli")]
    return [Path(os.path.expandvars(d)).expanduser() for d in dirs if d]


def agy_section(days):
    """Per-session tool calls and skills loaded from Antigravity transcripts; "" when none."""
    sessions = {}  # session dir -> [tool calls, {skills}]
    for base in agy_dirs():
        files = recent_files([(base, "*/.system_generated/messages/*"), (base, "**/*.jsonl")], days)
        for f in files:
            try:
                text = f.read_text(errors="ignore")
            except OSError:
                continue
            sid = f.relative_to(base).parts[0] if f.relative_to(base).parts[1:] else f.stem
            n, skills = sessions.setdefault(f"{base.name}/{sid}", [0, set()])
            skills.update(SKILL_NAME.findall(text))
            for line in text.splitlines():
                try:
                    rec = json.loads(line)
                except ValueError:
                    continue
                calls = rec.get("tool_calls") if isinstance(rec, dict) else None
                if isinstance(calls, list):
                    sessions[f"{base.name}/{sid}"][0] += len(calls)
                    skills.update(str(c["args"]["skill"]).split(":")[-1] for c in calls
                                  if isinstance(c, dict) and c.get("name") == "Skill" and isinstance(c.get("args"), dict) and c["args"].get("skill"))
    if not sessions:
        return ""
    lines = [f"# Agent: antigravity (transcripts)", "", f"Sessions in the last {days} days: {len(sessions)}", "",
             "## Usage per session (tool calls / skills loaded)", ""]
    for sid, (n, skills) in sorted(sessions.items()):
        lines.append(f"- {sid}: {n} / {', '.join(sorted(skills)) or 'none'}")
    return "\n".join(lines)


def section(name, cfg, days):
    root = cfg["root"]
    skills = sorted(p.parent.name for p in (root / "skills").glob("*/SKILL.md"))
    files = recent_files(cfg["sessions"], days)
    n_sessions, usage = skill_usage(skills, files)
    lines = [f"# Agent: {name} ({root})", "",
             f"Sessions in the last {days} days: {n_sessions}", "",
             "## Skills (sessions mentioning it / last modified)", ""]
    for s in skills:
        mtime = datetime.date.fromtimestamp((root / "skills" / s / "SKILL.md").stat().st_mtime)
        lines.append(f"- {s}: {usage[s]} / {mtime}" + ("  <- UNUSED" if usage[s] == 0 else ""))
    lines += ["", "## Rules (last modified)", ""]
    for r in sorted((root / "rules").glob("**/*.md")):
        lines.append(f"- {r.relative_to(root)}: {datetime.date.fromtimestamp(r.stat().st_mtime)}")
    return "\n".join(lines)


def main(argv):
    out = Path(argv[1])
    days = int(argv[argv.index("--days") + 1]) if "--days" in argv else 7
    parts = [section(n, c, days) for n, c in AGENTS.items() if c["root"].is_dir()]
    parts += [x for x in [agy_section(days)] if x]
    hooks = next((d for d in (HERE.parent / "hooks", HERE.parent.parent / "hooks") if (d / "work-log.py").is_file()), None)
    month = datetime.date.today().strftime("%Y-%m")
    for title, cmd in ((f"Work Log {month}", hooks and [hooks / "work-log.py", "--report", month]),
                       ("Skill learning loop", [HERE / "skill_learning_report.py"])):
        if not cmd:
            continue
        rep = subprocess.run([sys.executable, *map(str, cmd)], capture_output=True, text=True).stdout
        parts.append(f"## {title}\n\n" + "\n".join(rep.splitlines()[-40:]))
    out.write_text("\n\n".join(parts))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
