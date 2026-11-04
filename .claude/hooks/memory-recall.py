#!/usr/bin/env python3
"""UserPromptSubmit hook: surface relevant memory before the model answers.

Searches, for the prompt's keywords: knowledge/*.md sections under every root of $AODD_MEMORY (os.pathsep
list) and under <root>/<project> (the cwd's git repo folder), the repo's own agent-memory/ when present,
files matching the globs in $AODD_RECALL_EXTRA (os.pathsep list, relative to each root; default none), plus the auto-memory notes of the Claude home and of
the cwd's project (projects/<slug>/memory/*.md, matched on name+description+body). Adds at most 5 pointers
(file + description + one gist line, usually the note's 'How to apply') as additionalContext; it never
pastes whole notes, so the cost stays small.

Match rule: a candidate needs >=2 distinct keywords, or 1 keyword of >=10 chars (>=8 for Thai domain terms).
Keywords are Latin/identifier tokens >=4 chars and Thai terms >=3 chars minus stopwords.
Conversational filler returns nothing rather than noise. Fails open; disable with MEMORY_RECALL=0.
"""
import fnmatch
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

HERE = Path(__file__).resolve().parent
for _d in (HERE, HERE.parents[2] / "hooks"):  # installed: next to this file; in the repo: core hooks/
    sys.path.append(str(_d))
import _aodd_paths  # noqa: E402

HOME = _aodd_paths.claude_home()
STOP = set("""this that with from have what when where which would could should about there their them then than
into over also just like need want make does doesn't dont done please check look show tell give take more most some
any all not but and for the are was were has had can will let see use used using new old now still again
file files code work task using something anything everything nothing today tomorrow yesterday different
whatever otherwise important understand explain clearer variable""".split())
MAX_HITS, MAX_LINE, MAX_GIST, LONG = 5, 170, 200, 10
HIT_LOG = Path(os.environ.get("MEMORY_RECALL_LOG") or _aodd_paths.state() / "recall-hits.jsonl")


MACHINE_TEXT = re.compile(r"^\s*<(system-reminder|task-notification|local-command|command-)")
CASE_ROW = re.compile(r"^\s*\|\s*[`*]*([A-Za-z][A-Za-z0-9]*[-_][A-Za-z0-9_-]+)[`*]*\s*\|")
MAX_KEYWORDS = 15  # a real question has a handful; more means a pasted log/report/notification


def is_machine_or_pasted(prompt: str) -> bool:
    """Harness-generated text or a pasted wall of text: matching its vocabulary against notes is just noise."""
    return bool(MACHINE_TEXT.match(prompt)) or len(keywords(prompt, cap=None)) > MAX_KEYWORDS


THAI_STOP = set("""
สวัสดี ครับ ค่ะ นะคะ นะ หน่อย ช่วย ทำ การ ความ ได้ ให้ ไป มา ที่ ใน ของ จาก กับ โดย ตาม เพื่อ และ หรือ ถ้า แต่ เป็น อยู่ คือ มี จะ ไม่ ก็ แล้ว อีก บ้าง กัน ไว้ ด้วย ต้อง อยาก ขอ ลอง ดู เรื่อง ทั้งหมด ตอน เมื่อ ใด ใคร ไหม ไหน ทำไม อย่างไร ยังไง อะไร มาก น้อย ทุก แบบ ช่วยหน่อย ช่วยดู ช่วยทำ ขอบคุณ รบกวน ครับผม ทำยังไง เป็นยังไง อะไรบ้าง นิดหน่อย ตอนนี้
""".split())


def extract_thai_tokens(text: str) -> list[str]:
    blocks = re.findall(r"[\u0e00-\u0e7f]+", text)
    tokens = []
    prefixes = ("การ", "ความ", "ระบบ", "แผน", "ข้อมูล", "วิเคราะห์")
    fillers = ("ช่วยดู", "ช่วยทำ", "ลองดู", "ขอถาม", "ช่วยเช็ค", "ช่วยตรวจ", "ช่วย", "ลอง", "ขอ")
    for b in blocks:
        if b in THAI_STOP or len(b) < 3:
            continue
        cleaned = b
        for f in fillers:
            if cleaned.startswith(f) and len(cleaned) > len(f):
                sub = cleaned[len(f):]
                if sub in THAI_STOP:
                    cleaned = ""
                    break
                elif len(sub) >= 3:
                    cleaned = sub
                    break
        if not cleaned or cleaned in THAI_STOP or len(cleaned) < 3:
            continue
        if cleaned not in tokens:
            tokens.append(cleaned)
        for p in prefixes:
            if cleaned.startswith(p) and len(cleaned) > len(p) + 2:
                sub = cleaned[len(p):]
                if sub not in THAI_STOP and len(sub) >= 3 and sub not in tokens:
                    tokens.append(sub)
    return tokens


def is_long(k: str) -> bool:
    return len(k) >= LONG or (bool(re.search(r"[\u0e00-\u0e7f]", k)) and len(k) >= 8)


def keywords(prompt: str, cap: int | None = 20) -> list[str]:
    words = re.findall(r"[A-Za-z][A-Za-z0-9_./-]{3,}", prompt.lower())
    out = []
    for w in words:
        w = w.strip("./-_")
        if len(w) >= 4 and w not in STOP and w not in out:
            out.append(w)
    for tw in extract_thai_tokens(prompt):
        if tw not in out:
            out.append(tw)
    return out[:cap] if cap is not None else out


def is_recall_extra(path: Path) -> bool:
    if path.parent.name == "knowledge":
        return False
    extra = os.environ.get("AODD_RECALL_EXTRA", "")
    if not extra:
        return False
    for g in (x for x in extra.split(os.pathsep) if x):
        if path.name == g or path.match(g) or path.match(f"*/{g}") or fnmatch.fnmatch(str(path), f"*/{g}") or fnmatch.fnmatch(path.name, g):
            return True
    return False


def sections(path: Path, is_extra: bool | None = None):
    """Yield (anchor, text) chunks: table rows or '## ' sections for extra files, '## ' for knowledge/, whole file for notes."""
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return
    if is_extra is None:
        is_extra = is_recall_extra(path)
    if is_extra:
        rows = [
            (m.group(1), line.strip())
            for line in text.splitlines()
            if (m := CASE_ROW.match(line))
        ]
        if rows:
            yield from rows
        else:
            has_sections = bool(re.search(r"^##\s+", text, re.M))
            if has_sections:
                for chunk in re.split(r"\n(?=## )", text):
                    chunk = chunk.strip()
                    if not chunk:
                        continue
                    head = chunk.splitlines()[0][:60]
                    anchor = head.lstrip("# ").strip() if head.startswith("## ") else ""
                    yield anchor, chunk
            else:
                yield "", text
    elif path.parent.name == "knowledge":
        for chunk in re.split(r"\n(?=## )", text):
            head = chunk.strip().splitlines()[0][:60] if chunk.strip() else ""
            yield head.lstrip("# ").strip(), chunk
    else:
        yield "", text


def describe(path: Path, text: str, anchor: str) -> str:
    m = re.search(r"^description:\s*(.+)$", text, re.M)
    if m:
        return m.group(1).strip()
    first = next((l.strip() for l in text.splitlines() if l.strip() and not l.startswith("#")), "")
    if text.strip().startswith("|") and "\n" not in text.strip():
        return first
    return f"[{anchor}] {first}" if anchor else first


def gist(path: Path, text: str, shown: str) -> str:
    """One body line beyond the description, so the hit is usable without opening the file.
    Prefers the note's 'How to apply' line."""
    body = re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S)
    lines = [l.strip().lstrip("-* ").strip() for l in body.splitlines()]
    lines = [l for l in lines if l and not l.startswith(("#", "|", "```", "<")) and l[:60] not in shown]
    apply = next((l for l in lines if "how to apply" in l.lower()), "")
    return re.sub(r"^\**how to apply:?\**:?\s*", "", apply or (lines[0] if lines else ""), flags=re.I)


def candidates(cwd: Path):
    proj = _aodd_paths.project(cwd)
    roots = [r for m in _aodd_paths.memory_dirs() for r in (m, m / proj)]
    local = here = Path(cwd).resolve()
    for d in (here, *here.parents):  # project-local memory kept inside the repo
        if (d / ".git").exists():
            local = d
            break
    if (local / "agent-memory").is_dir():
        roots += [local / "agent-memory"]
    seen = set()
    for r in roots:
        for p in sorted((r / "knowledge").rglob("*.md")) if (r / "knowledge").is_dir() else []:
            if p.resolve() not in seen:
                seen.add(p.resolve())
                yield p
        for g in (x for x in os.environ.get("AODD_RECALL_EXTRA", "").split(os.pathsep) if x):  # legacy row files
            for p in sorted(r.glob(g)):
                if p.is_file() and p.resolve() not in seen:
                    seen.add(p.resolve())
                    yield p
    slugs = {re.sub(r"[/.]", "-", str(p)) for p in (HOME, cwd)}  # Claude Code's project dir naming
    for s in slugs:
        d = HOME / "projects" / s / "memory"
        if d.is_dir():
            yield from (p for p in sorted(d.glob("*.md")) if p.name != "MEMORY.md")


def recall(prompt: str, cwd: Path | None = None, limit: int = MAX_HITS):
    if is_machine_or_pasted(prompt):
        return []
    kws = keywords(prompt)
    if not kws:
        return []
    chunks = [(path, anchor, text, text.lower()) for path in candidates(cwd or Path.cwd())
              for anchor, text in sections(path)]
    hits = []
    for path, anchor, text, low in chunks:
        matched = [k for k in kws if k in low]
        if len(matched) >= 2 or any(is_long(k) for k in matched):
            d = describe(path, text, anchor)
            g = gist(path, text, d)
            hits.append((len(matched), path, anchor, f"{d[:MAX_LINE]}" + (f" | gist: {g[:MAX_GIST]}" if g else "")))
    hits.sort(key=lambda h: -h[0])
    return hits[:limit]


def main() -> int:
    if os.environ.get("MEMORY_RECALL") == "0":
        return 0
    try:
        data = json.load(sys.stdin)
        hits = recall(data.get("prompt", ""), Path(data.get("cwd") or os.getcwd()))
    except Exception:
        return 0
    if not hits:
        return 0
    try:  # usage counts for scripts/skill_learning_report.py; never block the prompt
        HIT_LOG.parent.mkdir(parents=True, exist_ok=True)
        with HIT_LOG.open("a") as f:
            f.write(json.dumps({"t": datetime.now().isoformat(timespec="seconds"), "sid": data.get("session_id", ""),
                                "files": [str(p) for _, p, _, _ in hits]}) + "\n")
    except OSError:
        pass
    lines = [f"- {str(p).replace(str(Path.home()), '~')}{('#' + a) if a else ''}: {d}" for _, p, a, d in hits]
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": "Possibly relevant memory (gist inline; apply it if it fits, open the file only for detail; ignore if not):\n" + "\n".join(lines)}}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
