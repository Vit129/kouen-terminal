#!/usr/bin/env python3
"""Stop hook: the agent improves its own skills after real work (Hermes-style).

Procedure the model follows: docs/agents/skill-learning.md. Lessons go into skills
(patch a loaded skill > patch an existing umbrella > add a references/ file > new skill),
never into a loose lessons file.

Fires when the session has >= MIN_TOOL_CALLS tool calls and at least one learning signal
(a user correction or a `fix` commit; tool errors are counted but no longer a signal) since
the last nudge, and no skill file was written since then. After a nudge it can fire again
every INTERVAL further tool calls (Hermes `creation_nudge_interval`), each time only on new
signals. Skills loaded this session are named in the prompt as the first patch targets.
With the `post` argument it runs as PostToolUse(Bash) and, right after a fix commit,
asks for the skill patch while the cause is still in context.
Fails open (any error -> allow stop). Disable with CLAUDE_SKILL_CAPTURE=0.
"""
import json
import os
import re
import sys
from pathlib import Path

MIN_TOOL_CALLS = 20  # Known limit: raw tool-call count as "complex"; swap for a smarter signal if it fires on grind-y but trivial sessions
INTERVAL = 40        # further tool calls before the same session can be nudged again
sys.path.insert(0, str(Path(__file__).resolve().parent))
import _aodd_paths  # noqa: E402
STATE_DIR = _aodd_paths.state() / "skill-capture"
CORRECTION = re.compile(r"ไม่ใช่|ทำผิด|ผิดแล้ว|อย่าทำ|ไม่ต้องทำแบบ|ยาวไป|สั้นๆ|\b(no[,.]|wrong|that'?s not|too (long|verbose)|stop doing)\b", re.I)
FIX_COMMIT = re.compile(r"git commit[\s\S]{0,80}?\b(fix|revert)(\(|:)", re.I)  # conventional-commit subject only
SKILL_FILE = re.compile(r"(?:^|[\s/'\"])skills/[^/\s]+/(SKILL\.md|references/|scripts/|templates/)")
# a Bash write INTO a skill dir: redirect (not 2>/&>), sed -i/tee/cp/mv/install, or python open(..., "w"/"a")
SKILL_BASH_WRITE = re.compile(r"(?<![0-9&])>>?\s*['\"]?\S*skills/[^/\s]+/"
                              r"|\b(sed\s+-i|tee|cp|mv|install)\b[^|;&]*skills/[^/\s]+/"
                              r"|open\([^)]*skills/[^)]*,\s*['\"][wa]")
SKILL_MD = re.compile(r"(/[^\s'\"]*/skills/([^/\s'\"]+)/SKILL\.md)")
PATCH_FILE = re.compile(r"^\*\*\* (?:Add|Update|Delete) File: (.+?)\s*$", re.M)  # Codex apply_patch headers
DOC = "docs/skill-learning.md (under your Claude home)"

SKILL_PASS = """[skill-capture] This session had a learning signal ({sig}; {n} tool calls). If it taught a verified, reusable rule, patch the skill now; most sessions teach nothing new and "skill-capture: nothing" is a fine answer. Procedure: {doc}.
{loaded}
Pick the FIRST rung that fits:
1. Patch a skill loaded this session (above) if it covers the lesson — whoever wrote it.
2. Patch an existing class-level skill (~/.claude/skills/ or this project's .claude/skills/): add a step/pitfall, widen its description.
3. Add or extend references/<topic>.md or scripts/<name> under an existing skill.
4. Only if nothing fits: new skill (project-specific -> the project's .claude/skills/), frontmatter name, description (what the user would say, Thai+English), version 0.1.0, origin: auto-captured, created: <today>.

Write only what was verified here (test/build/command passed or the user confirmed) and how to check it. Generalize (placeholders, not this session's values). If a skill's rule caused the mistake, rewrite or delete that rule instead of appending. Bump version (patch) and last_improved. No secrets or company identifiers in global skills.
Then tell the user in one line which skill changed.
Nothing worth keeping: reply "skill-capture: nothing" and carry on with the user's task{fix_note}."""

FIX_NOTE = "; a fix was committed, so its cause belongs in the skill that governs that code or workflow"

MID_FLIGHT = ("[skill-capture] You just committed a fix. While the cause is in context, patch the skill that governs "
              "this code/workflow (pitfall + how to check), per " + DOC + ".")


def _text(content) -> str:
    if isinstance(content, str):
        return content
    return " ".join(b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text")


def scan(transcript: Path, since: int = 0):
    """Return (tool_calls, skill_written_since, signals_since, loaded_skills). `since` = tool-call count at last nudge."""
    n = errors = corrections = fixes = 0
    written = False
    loaded = {}
    with transcript.open() as f:
        for line in f:
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            if isinstance(rec.get("payload"), dict):  # Codex rollout
                n, corrections, fixes, written = _codex(rec, n, since, corrections, fixes, written, loaded)
                continue
            content = (rec.get("message") or {}).get("content") or []
            after = n > since
            said = _text(content)
            # a correction typed right after a nudge (before the next tool call) still counts; the nudge itself does not
            if (rec.get("type") == "user" and n >= since and "[skill-capture]" not in said
                    and CORRECTION.search(said[:400])):
                corrections += 1
            if isinstance(content, str):
                continue
            for block in content:
                if not isinstance(block, dict):
                    continue
                kind = block.get("type")
                if kind == "tool_result" and block.get("is_error") and after:
                    errors += 1
                elif kind == "tool_use":
                    n += 1
                    name, inp = block.get("name"), block.get("input") or {}
                    path = str(inp.get("file_path", ""))
                    cmd = str(inp.get("command", ""))
                    if name == "Skill" and inp.get("skill"):
                        loaded.setdefault(str(inp["skill"]).split(":")[-1], "")
                    for m in SKILL_MD.finditer(path if name == "Read" else cmd if name == "Bash" else ""):
                        loaded[m.group(2)] = m.group(1)
                    if n <= since:
                        continue
                    if name in ("Write", "Edit", "MultiEdit"):
                        written |= bool(SKILL_FILE.search(path))
                    elif name == "Bash":
                        if FIX_COMMIT.search(cmd):
                            fixes += 1
                        written |= bool(SKILL_BASH_WRITE.search(cmd))
    # Only a user correction or a fix commit counts (nudges that fired on ordinary tool
    # errors broke flow). Errors are normal work, not lessons (`errors` is still counted, unused).
    signals = []
    if corrections:
        signals.append(f"{corrections} user correction(s)")
    if fixes:
        signals.append("fix commit")
    return n, written, signals, loaded


def _codex(rec, n, since, corrections, fixes, written, loaded):
    """Codex rollout record {type: response_item, payload}. Returns updated (n, corrections, fixes, written)."""
    pl = rec.get("payload") or {}
    if pl.get("type") == "message" and pl.get("role") == "user":
        said = " ".join(b.get("text", "") for b in pl.get("content") or [] if isinstance(b, dict) and b.get("type") == "input_text").strip()
        if (n >= since and said and not said.startswith(("<", "# AGENTS.md")) and "[skill-capture]" not in said
                and CORRECTION.search(said[:400])):
            corrections += 1
    elif pl.get("type") in ("function_call", "custom_tool_call"):
        n += 1
        name = pl.get("name")
        if name == "exec_command":
            try:
                cmd = str(json.loads(pl.get("arguments") or "{}").get("cmd", ""))
            except (ValueError, AttributeError):
                cmd = ""
            for m in SKILL_MD.finditer(cmd):
                loaded[m.group(2)] = m.group(1)
            if n > since:
                fixes += bool(FIX_COMMIT.search(cmd))
                written |= bool(SKILL_BASH_WRITE.search(cmd))
        elif name == "apply_patch" and n > since:
            written |= any(SKILL_FILE.search(f) for f in PATCH_FILE.findall(str(pl.get("input") or "")))
    return n, corrections, fixes, written


def skill_path(name: str, known: str, cwd: Path) -> str:
    if known:
        return known
    for base in (cwd / ".claude/skills", Path.home() / ".claude/skills"):
        if (base / name / "SKILL.md").is_file():
            return str(base / name / "SKILL.md")
    return "(plugin skill: read-only, patch a local skill instead)"


def decide(payload: dict):
    """Return the block reason, or None to allow the stop."""
    if os.environ.get("CLAUDE_SKILL_CAPTURE") == "0" or payload.get("stop_hook_active"):
        return None
    sid = payload.get("session_id") or ""
    transcript = Path(payload.get("transcript_path") or "")
    if not sid or not transcript.is_file():
        return None
    marker = STATE_DIR / sid
    last = None
    if marker.exists():
        raw = marker.read_text().strip()
        last = int(raw) if raw.isdigit() else 10**9  # legacy empty marker: already nudged, never again
    n, written, signals, loaded = scan(transcript, since=last or 0)
    if n < (MIN_TOOL_CALLS if last is None else last + INTERVAL) or written or not signals:
        return None
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    marker.write_text(str(n))
    cwd = Path(payload.get("cwd") or os.getcwd())
    loaded_txt = ("Skills loaded this session (patch these first):\n" +
                  "\n".join(f"  - {k}: {skill_path(k, v, cwd)}" for k, v in loaded.items())) if loaded else \
        "No skill was loaded this session."
    return SKILL_PASS.format(n=n, sig=", ".join(signals), doc=DOC, loaded=loaded_txt,
                             fix_note=FIX_NOTE if "fix commit" in signals else "")


def post_tool(payload: dict):
    """PostToolUse(Bash): mid-flight reminder right after a fix commit."""
    if os.environ.get("CLAUDE_SKILL_CAPTURE") == "0":
        return None
    cmd = str((payload.get("tool_input") or {}).get("command", ""))
    return MID_FLIGHT if FIX_COMMIT.search(cmd) else None


def main():
    try:
        payload = json.load(sys.stdin)
        if sys.argv[1:] == ["post"]:
            note = post_tool(payload)
            if note:
                print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": note}}))
            return
        reason = decide(payload)
    except Exception:
        return
    if reason:
        print(json.dumps({"decision": "block", "reason": reason}))


if __name__ == "__main__":
    main()
