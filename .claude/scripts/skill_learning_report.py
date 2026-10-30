"""Is skill self-learning paying off? Reports, from real data:

  capture yield   sessions where hooks/skill-capture-nudge.py fired, and what the session did next
                  (wrote/patched a skill, or declined); test sessions with no transcript are skipped
  recall use      hooks/memory-recall.py hits (recall-hits.jsonl, agent-memory module) that were then opened
                  with Read in the same session
  per skill       each `origin: auto-captured` skill (Claude home and $AODD_REPOS/*/.claude/skills): created
                  date, Skill-tool invocations since then
  self-improve    skills patched in place (`last_improved` within --days, default 30)
  verdict         USED (>=1 call since created) / UNUSED after >=14 days (prune or fix its description) / NEW
  curator         every skill: stale (unused 14+ days) / archive (auto-captured, unused 30+ days, never younger
                  than 30 days); lint (oversized body, references sprawl, missing version, dead references/
                  paths); overlapping descriptions to merge. `--archive` moves archive candidates to
                  <skills>/.archive/ (never deletes); `pinned: true` in frontmatter skips a skill.

Usage: python3 scripts/skill_learning_report.py [--days N] [--json] [--archive]
Invocations are counted from <claude home>/projects/*/*.jsonl (Skill tool_use blocks), so they cover every project.
Paths: CLAUDE_HOME (default ~/.claude); state under AODD_STATE (hooks/_aodd_paths.py); AODD_REPOS (os.pathsep
list of folders holding git repos) adds their project-scoped skills.
"""
import json
import os
import re
import sys
from collections import Counter
from datetime import date, datetime
from pathlib import Path

for _d in (Path(__file__).resolve().parent.parent / "hooks", Path(__file__).resolve().parent.parent.parent / "hooks"):
    sys.path.append(str(_d))  # installed: <home>/hooks; in the repo: hooks/
import _aodd_paths  # noqa: E402

HOME = _aodd_paths.claude_home()
STATE = _aodd_paths.state()
CALL = re.compile(r'"name":\s*"Skill",\s*"input":\s*\{[^{}]*?"skill":\s*"([^"]+)"'
                  r'|"file_path":\s*"[^"]*/skills/([\w.-]+)/SKILL\.md"'      # Read/Edit of the SKILL.md (skill_view)
                  r'|<command-name>/?([\w:.-]+)</command-name>')            # /slash-command invocation
LEDGER = STATE / "skill-usage.json"  # last use per skill; outlives transcript cleanup
UNUSED_AFTER_DAYS = 14
STALE_DAYS, ARCHIVE_DAYS = 14, 30
MAX_BODY, MAX_REFS, OVERLAP = 24_000, 60, 0.5
NUDGE_WINDOW = 60  # transcript records after the nudge that count as "its answer"


def repo_dirs():
    for base in (d for d in os.environ.get("AODD_REPOS", "").split(os.pathsep) if d):
        b = Path(base).expanduser()
        yield from (p for p in sorted(b.glob("*")) if p.is_dir())


def skill_files():
    yield from sorted((HOME / "skills").glob("*/SKILL.md"))
    for r in repo_dirs():  # project-scoped captures
        yield from sorted(r.glob(".claude/skills/*/SKILL.md"))


def patched_skills(days: int):
    """[(skill, last_improved)] for skills improved in place within `days`."""
    out = []
    for md in skill_files():
        m = re.search(r"^last_improved:\s*(\d{4}-\d{2}-\d{2})", md.read_text(errors="ignore").split("\n---", 2)[0], re.M)
        if m and (date.today() - date.fromisoformat(m.group(1))).days <= days:
            out.append((md.parent.name, m.group(1)))
    return sorted(out, key=lambda x: x[1], reverse=True)


def auto_captured_skills():
    for md in skill_files():
        head = md.read_text(errors="ignore").split("\n---", 2)[0]
        if re.search(r"^origin:\s*auto-captured", head, re.M):
            created = re.search(r"^created:\s*(\d{4}-\d{2}-\d{2})", head, re.M)
            yield md.parent.name, date.fromisoformat(created.group(1)) if created else date.fromtimestamp(md.stat().st_mtime)


def skill_calls():
    """[(date, skill_name)] for every Skill tool call in every transcript (date = transcript mtime)."""
    calls = []
    for f in (HOME / "projects").glob("*/*.jsonl"):
        day = date.fromtimestamp(f.stat().st_mtime)
        try:
            text = f.read_text(errors="ignore")
        except OSError:
            continue
        calls += [(day, next(g for g in m.groups() if g).split(":")[-1]) for m in CALL.finditer(text)]
    return calls


def with_ledger(calls, path: Path = LEDGER):
    """Merge transcript calls into the persistent last-use ledger and return calls incl. ledger entries."""
    try:
        led = json.loads(path.read_text())
    except (OSError, ValueError):
        led = {}
    for d, name in calls:
        if str(d) > led.get(name, ""):
            led[name] = str(d)
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(led, indent=1, sort_keys=True))
    except OSError:
        pass
    return calls + [(date.fromisoformat(v), k) for k, v in led.items()]


def records(path: Path):
    for line in path.read_text(errors="ignore").splitlines():
        try:
            yield json.loads(line)
        except json.JSONDecodeError:
            continue


def tool_uses(rec):
    content = (rec.get("message") or {}).get("content")
    return [b for b in content if isinstance(b, dict) and b.get("type") == "tool_use"] if isinstance(content, list) else []


def capture_outcome(path: Path) -> str:
    """What the session did after its last skill-capture nudge: skill / declined / unanswered."""
    recs = list(records(path))
    at = max((i for i, r in enumerate(recs) if "[skill-capture]" in json.dumps(r) and r.get("type") != "assistant"), default=None)
    if at is None:
        return "no-nudge-in-transcript"
    out = set()
    for rec in recs[at + 1:at + 1 + NUDGE_WINDOW]:
        for b in tool_uses(rec):
            target = str((b.get("input") or {}).get("file_path") or (b.get("input") or {}).get("command") or "")
            if re.search(r"/skills/[^/]+/(SKILL\.md|references/|scripts/|templates/)", target) and (b.get("name") in ("Write", "Edit", "MultiEdit")):
                out.add("skill")
        if not out and rec.get("type") == "assistant" and re.search(r"nothing reusable|skill-capture: nothing", json.dumps(rec)):
            out.add("declined")
    return "+".join(sorted(out)) or "unanswered"


def frontmatter(md: Path) -> str:
    text = md.read_text(errors="ignore")
    return text.split("\n---", 2)[0] if text.startswith("---") else ""


def curate(calls, today: date | None = None):
    """Hermes-style curator pass over every skill file: state, lint, overlap. Pure apart from reading the files."""
    today = today or date.today()
    last_use = {}
    for d, name in calls:
        last_use[name] = max(d, last_use.get(name, d))
    rows, descs = [], {}
    for md in skill_files():
        head, text, name = frontmatter(md), md.read_text(errors="ignore"), md.parent.name
        created = re.search(r"^created:\s*(\d{4}-\d{2}-\d{2})", head, re.M)
        born = date.fromisoformat(created.group(1)) if created else date.fromtimestamp(md.stat().st_mtime)
        used = last_use.get(name)
        idle = (today - max(used or born, born)).days  # an old use of a same-named skill predates this one
        auto = bool(re.search(r"^origin:\s*auto-captured", head, re.M))
        if re.search(r"^pinned:\s*true", head, re.M):
            state = "pinned"
        elif (today - born).days < ARCHIVE_DAYS and (not used or used < born):
            state = "new"  # no use yet is absence of evidence, not staleness
        elif auto and idle >= ARCHIVE_DAYS and (today - born).days >= ARCHIVE_DAYS:
            state = "archive"
        elif idle >= STALE_DAYS:
            state = "stale"
        else:
            state = "active"
        lint = []
        if len(text) > MAX_BODY:
            lint.append(f"SKILL.md {len(text)} chars > {MAX_BODY}: move depth to references/")
        refs = md.parent / "references"
        if refs.is_dir() and sum(1 for _ in refs.rglob("*") if _.is_file()) > MAX_REFS:
            lint.append(f"references/ > {MAX_REFS} files: merge topics")
        if head and not re.search(r"^\s*version:", head, re.M):
            lint.append("no version in frontmatter")
        dead = sorted({r for r in re.findall(r"(?<![\w/.-])references/[\w./-]+\.md", text) if not (md.parent / r).exists()})
        if dead:
            lint.append("dead refs: " + ", ".join(dead[:3]))
        m = re.search(r"^description:\s*(.+)$", head, re.M)
        if m:
            descs[str(md)] = {w for w in re.findall(r"[a-z\u0e00-\u0e7f]{4,}", m.group(1).lower())}
        why = {"archive": f"auto-captured, no use for {idle} days (last use {used or 'never'}, created {born})",
               "stale": f"no use for {idle} days (last use {used or 'never'}); flagged only — archive needs "
                        f"origin: auto-captured + 30 days unused + 30 days old"}.get(state, "")
        rows.append({"skill": name, "path": str(md), "state": state, "last_used": str(used) if used else None,
                     "idle_days": idle, "auto": auto, "lint": lint, "why": why})
    keys, overlap = sorted(descs), []
    for i, a in enumerate(keys):
        for b in keys[i + 1:]:
            if Path(a).parent.name == Path(b).parent.name:
                continue  # same skill copied into several projects (e.g. graphify), not a merge candidate
            u = descs[a] | descs[b]
            if u and len(descs[a] & descs[b]) / len(u) >= OVERLAP:
                overlap.append((Path(a).parent.name, Path(b).parent.name))
    return rows, overlap


def archive(rows) -> list[str]:
    """Move archive-state skills to <skills>/.archive/<name>; recoverable, never deleted."""
    moved = []
    for r in rows:
        if r["state"] != "archive":
            continue
        src = Path(r["path"]).parent
        dst = src.parent / ".archive" / src.name
        if dst.exists():
            continue
        dst.parent.mkdir(exist_ok=True)
        src.rename(dst)
        moved.append(str(dst))
    return moved


def recall_use(transcripts: dict) -> tuple[int, int, Counter]:
    """(hits logged with a session id, hits whose file was Read in that session, anchors surfaced)."""
    log = STATE / "recall-hits.jsonl"
    surfaced = opened = 0
    cases = Counter()
    read_cache = {}
    for e in records(log) if log.is_file() else []:
        sid = e.get("sid")
        if not sid or sid not in transcripts:
            continue
        if sid not in read_cache:
            read_cache[sid] = " ".join(str((b.get("input") or {}).get("file_path") or (b.get("input") or {}).get("command") or "")
                                       for r in records(transcripts[sid]) for b in tool_uses(r) if b.get("name") in ("Read", "Bash"))
        for f in e.get("files", []):
            surfaced += 1
            opened += Path(f).name in read_cache[sid]  # Read, or cat/sed via Bash
    return surfaced, opened, cases


def main():
    days = int(sys.argv[sys.argv.index("--days") + 1]) if "--days" in sys.argv else 30
    skills = list(auto_captured_skills())
    patched = patched_skills(days)
    calls = skill_calls()
    transcripts = {f.stem: f for f in (HOME / "projects").glob("*/*.jsonl")}
    state = STATE / "skill-capture"
    nudged = [m.name for m in state.glob("*")] if state.is_dir() else []
    outcomes = Counter(capture_outcome(transcripts[sid]) for sid in nudged if sid in transcripts)
    fired = sum(outcomes.values())
    learned = sum(n for k, n in outcomes.items() if "skill" in k)
    surfaced, opened, cases = recall_use(transcripts)
    rows = []
    for name, created in skills:
        n = sum(1 for d, s in calls if s == name and d >= created)
        age = (date.today() - created).days
        rows.append({"skill": name, "created": str(created), "age_days": age, "calls_since": n,
                     "verdict": "USED" if n else ("UNUSED" if age >= UNUSED_AFTER_DAYS else "NEW")})
    cur, overlap = curate(with_ledger(calls))
    moved = archive(cur) if "--archive" in sys.argv else []
    out = {"capture_nudges_fired": fired, "skipped_no_transcript": len(nudged) - fired,
           "outcomes": dict(outcomes), "yield_pct": round(100 * learned / fired) if fired else None,
           "skills_created": len(skills), "skills": rows, "skills_patched": [{"skill": n, "last_improved": d} for n, d in patched],
           "curator": {"skills": cur, "overlap": overlap, "archived": moved},
           "recall": {"surfaced_with_session": surfaced, "opened": opened}}
    if "--json" in sys.argv:
        print(json.dumps(out, indent=2))
        return
    print(f"capture nudges: {fired} (skipped {out['skipped_no_transcript']} with no transcript)   "
          f"patched/created a skill: {learned}   skill yield: {out['yield_pct']}%")
    print("  outcomes: " + ", ".join(f"{k} {n}" for k, n in outcomes.most_common()))
    print(f"recall: {surfaced} hits with a session id, {opened} opened afterwards"
          + " (the gist is inline, so a low open rate is expected)")
    print(f"skills patched in place (last {days}d): {len(patched)}" + (f"  {', '.join(f'{n} {d}' for n, d in patched)}" if patched else ""))
    print(f"auto-captured skills on disk: {len(skills)}")
    for r in rows:
        print(f"  {r['verdict']:7} {r['skill']:32} created {r['created']} ({r['age_days']}d)  calls since: {r['calls_since']}")
    states = Counter(r["state"] for r in cur)
    print(f"\ncurator ({len(cur)} skills): " + ", ".join(f"{k} {n}" for k, n in states.most_common()))
    home = str(Path.home())
    for r in cur:
        if r["state"] in ("stale", "archive") or r["lint"]:
            tag = r["state"].upper() if r["state"] in ("stale", "archive") else "LINT"
            print(f"  {tag:7} {r['path'].replace(home, '~')}  why: {r['why'] or 'lint'}" + (f"  [{'; '.join(r['lint'])}]" if r["lint"] else ""))
    for a, b in overlap:
        print(f"  MERGE?  {a} <-> {b}  why: their descriptions share >= {int(OVERLAP * 100)}% of words, so they may fire on the same requests")
    for m in moved:
        print(f"  archived -> {m.replace(home, '~')}")
    unused = [r["skill"] for r in rows if r["verdict"] == "UNUSED"]
    if unused:
        print(f"\nUNUSED >= {UNUSED_AFTER_DAYS} days: {', '.join(unused)} -> rewrite the description so it triggers, or delete.")


if __name__ == "__main__":
    main()
