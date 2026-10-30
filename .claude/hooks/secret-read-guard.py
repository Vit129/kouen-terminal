#!/usr/bin/env python3
"""secret-read-guard: secret files may be READ, but their values never reach the session output,
and the agent never edits them itself.

  pre  (PreToolUse Read|Bash|Edit|Write|MultiEdit)
       - Read tool, or a Bash command that prints a secret file (cat/head/tail/less/more/bat/sed/awk/
         grep without -c/-l/-q, jq without `keys`) -> deny, and name the masked view instead:
         `python3 <hooks dir>/secret-read-guard.py --show <file>` (structure kept, values ***).
       - Edit/Write, or a Bash write (sed -i, >, >>, tee) on a secret file -> deny: tell the user the
         path and the exact command to run themselves, with a placeholder, never the value.
  --show FILE   print FILE with every secret value masked.

Secret file = name like .env*, *secret*, *credential*, *.pem/*.key, or a config file (json/yaml/toml/
ini/env/properties/conf) whose content has a secret-like key (pat, token, api_key, password, ...) or a
known token shape (_aodd_secrets.py SECRET_PATTERNS). Why: a cat/sed on a secret file puts its values
into the transcript, and the key then has to be rotated. Fails open on any error. Disable with SECRET_READ_GUARD=0.

ponytail: Bash detection is a heuristic over the command text. Known ceiling, not caught: interpreter
reads (python -c "open('.env').read()"), `source .env && echo $KEY`, `env`/`printenv`, command
substitution / xargs (`cat $(echo .env)`), and secrets
in files with no config extension. Upgrade path: a PostToolUse scan of tool output for token shapes.
"""
import json
import os
import re
import shlex
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from _aodd_secrets import SECRET_PATTERNS  # noqa: E402
TOKEN_SHAPES = [p for _, p in SECRET_PATTERNS]

NAME = re.compile(r"(^\.env(\..*)?$|secret|credential|\.pem$|\.key$|\.p12$|\.keystore$|^\.netrc$|^\.npmrc$|^\.pypirc$)", re.I)
TEMPLATE = re.compile(r"\.(example|sample|template|dist)$", re.I)  # checked by content instead
CODE_EXT = re.compile(r"\.(py|pyi|js|jsx|mjs|cjs|ts|tsx|go|rs|swift|java|kt|rb|php|c|h|cs|sh|zsh|md|txt|html|css)$", re.I)  # source/docs: name says nothing
CONFIG_EXT = re.compile(r"\.(json|ya?ml|toml|ini|env|properties|conf|cfg|example|sample|template|dist)$", re.I)
_WORD = r"(?:pats?|tokens?|api[_-]?keys?|secrets?|passw(?:or)?ds?|private[_-]?keys?|access[_-]?keys?|credentials?)\d*"
KEY = rf"(?:[\w-]*[_.-])?{_WORD}(?:[_.-][\w-]*)?"
# key/value anywhere on a line (minified JSON has many per line); value = quoted string, list, or bare word
KV = re.compile(rf"""(?ix)(["']?\b{KEY}\b["']?\s*[:=]\s*)("(?:\\.|[^"\\])*"|'[^']*'|\[[^\]]*\]|[^\s,}}\]]+)""")
READERS = {"cat", "head", "tail", "less", "more", "bat", "sed", "awk", "grep", "rg", "jq", "yq", "strings", "xxd", "od",
           "nl", "base64", "hexdump", "diff", "git", "cp", "mv", "scp", "rsync", "openssl", "column", "sort", "uniq", "cut"}
WRITE = re.compile(r"\bsed\s+(?:-\w*\s+)*-i|\bperl\s+-\w*i|\btee\b|>>?")
SHOW = f"python3 {HERE / 'secret-read-guard.py'} --show"


def is_secret(path):
    p = Path(os.path.expanduser(path))
    if NAME.search(p.name) and not TEMPLATE.search(p.name) and not CODE_EXT.search(p.name):
        return True
    if not (p.is_file() and CONFIG_EXT.search(p.name)) or p.stat().st_size > 2_000_000:
        return False
    text = p.read_text(errors="ignore")
    return any(not _benign(m) for m in KV.finditer(text)) or any(t.search(text) for t in TOKEN_SHAPES)


def _placeholder(value):
    v = value.strip().strip("\"'[]").strip().strip("\"'")
    return v in ("", "null", "true", "false", "{") or v.startswith(("${", "<", "$"))


def _call_arg(m):
    """An unquoted `key=` right after `(` or `,` is a function argument in a template
    (git-cliff/Tera `split(pat="\n")`), not a config key. Quoted JSON keys stay suspect."""
    key = m.group(1).lstrip()
    return "=" in key and not key.startswith(("\"", "'")) and m.string[:m.start(1)].rstrip()[-1:] in ("(", ",")


def _benign(m):
    """Placeholder, a number on a token-count key (max_tokens: 4096), or a template call argument - not a secret."""
    v = m.group(2).strip("\"'")
    return (_placeholder(m.group(2)) or _call_arg(m)
            or (re.fullmatch(r"\d+", v) is not None and re.search(r"tokens?\b", m.group(1), re.I) is not None))


def _mask_value(m):
    v = m.group(2)
    if _benign(m):
        return m.group(0)
    if v.startswith("["):
        return m.group(1) + re.sub(r'"(?:\\.|[^"\\])*"|\'[^\']*\'', '"***"', v)
    q = v[0] if v[0] in "\"'" else ""
    return f"{m.group(1)}{q}***{q}"


def mask(text):
    text = KV.sub(_mask_value, text)
    for t in TOKEN_SHAPES:
        text = t.sub("***", text)
    return text


def bash_targets(cmd):
    """(read targets, write targets) of secret files in a Bash command, per pipeline segment."""
    reads, writes = [], []
    for seg in re.split(r"&&|\|\|?|;|\n", cmd):
        try:
            words = shlex.split(seg, comments=True)
        except ValueError:
            words = seg.split()
        if not words or "secret-read-guard.py --show" in seg:
            continue
        args = [g for w in words[1:] if not w.startswith("-") and ("/" in w or "." in w) for g in _expand(w)]
        if os.path.basename(words[0]) == "git":  # branch/ref names look like paths; only real files count
            args = [a for a in args if os.path.isfile(os.path.expanduser(a))]
        if os.path.basename(words[0]) in ("cp", "mv", "scp", "rsync", "install", "ln"):
            if args and is_secret(args[-1]):
                writes.append(args[-1])  # overwriting a secret file is an edit
            args = args[:-1]  # the destination is written, not printed; only a secret source leaks
        files = [w for w in args if is_secret(w)]
        redirect = re.findall(r">>?\s*([^\s|;&]+)", seg)
        writes += [f for f in redirect if is_secret(f)]
        if files and words[0] in ("sed", "perl", "tee") and (words[0] == "tee" or WRITE.search(seg)):
            writes += files
            continue
        prog, flags = os.path.basename(words[0]), " ".join(w for w in words if w.startswith("-"))
        if prog in ("grep", "rg") and re.search(r"-\w*[clqL]", flags):
            continue
        if prog in ("jq", "yq") and any(re.fullmatch(r"\.?\s*keys(_unsorted)?|\.?\s*\|?\s*keys", w.strip("'\"")) for w in words[1:]):
            continue
        if prog in READERS:
            reads += files
        recursive = prog == "rg" or (prog == "grep" and re.search(r"-\w*[rR]|--recursive", flags))
        if recursive and not re.search(r"-\w*[clqL]", flags) and re.search(_WORD, seg, re.I):
            reads.append(f"{seg.strip()} (recursive grep for a secret key name)")
    return reads, writes


def _expand(word):
    """A glob like .e* names the files it matches (cat .e* would print .env)."""
    w = os.path.expanduser(word)
    if any(c in w for c in "*?["):
        import glob
        return glob.glob(w) or [word]
    return [word]


def deny(reason):
    return {"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny",
                                   "permissionDecisionReason": reason}}


def read_msg(f):
    return (f"secret-read-guard: {f} holds secrets - its values must never appear in this session. "
            f"Read it masked instead: `{SHOW} {f}` (full structure, values ***).")


def edit_msg(f):
    return (f"secret-read-guard: {f} holds secrets - do not edit it yourself. Tell the user the file path "
            f"and the exact command to run themselves, with a placeholder like <NEW_VALUE> instead of any "
            f"real value (e.g. a sed -i or an editor line), and wait for them to confirm.")


def decide(payload):
    if os.environ.get("SECRET_READ_GUARD") == "0":
        return None
    tool, inp = payload.get("tool_name"), payload.get("tool_input") or {}
    if tool == "Read" and is_secret(inp.get("file_path", "")):
        return deny(read_msg(inp["file_path"]))
    if tool in ("Edit", "Write", "MultiEdit") and is_secret(inp.get("file_path", "")):
        return deny(edit_msg(inp["file_path"]))
    if tool == "Bash":
        reads, writes = bash_targets(str(inp.get("command", "")))
        if writes:
            return deny(edit_msg(writes[0]))
        if reads:
            return deny(read_msg(reads[0]))
    return None


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--show":
        try:
            print(mask(Path(os.path.expanduser(sys.argv[2])).read_text(errors="ignore")))
        except OSError as e:
            print(f"secret-read-guard --show: cannot read {sys.argv[2]}: {e.strerror}", file=sys.stderr)
            sys.exit(1)
        return
    try:
        out = decide(json.load(sys.stdin))
    except Exception:
        return  # fail open
    if out:
        print(json.dumps(out))


if __name__ == "__main__":
    main()
