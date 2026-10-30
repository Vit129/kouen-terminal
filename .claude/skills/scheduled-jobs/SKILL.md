---
name: scheduled-jobs
description: Cron and launchd jobs — adding a scheduled script, a job that never fires or fails silently, unattended `claude -p` runs from a scheduler. Use when the user says "ตั้ง cron", "ตั้งเวลา", "launchd", "job ไม่รัน", "ทำไมไม่ได้รายงานเมื่อเช้า", "schedule this script", or a daily report/push did not arrive. Not for Claude Code's own /schedule or CronCreate session tasks.
version: 0.1.6
origin: auto-captured
---

# Scheduled jobs (cron / launchd)

1. **Editing the crontab file is not installing it.** After changing your crontab file, install it (`crontab <file>`), then confirm with `crontab -l`. For launchd: `launchctl load` the plist and check `launchctl list | grep <label>`.
2. **No shell rc in cron/launchd:** use absolute paths for every tool (`/usr/bin/python3`, the full `npx`/`uv` path), set `PATH` in the wrapper, and commit the wrapper script (an untracked wrapper disappears on a new machine).
3. **Unattended agents have no one to approve permissions:** let the shell wrapper gather inputs and write outputs; run the model with no tools (`claude -p --tools ""`) and capture stdout. When the reply drives an automatic action (trade, delete, send), ask for one tagged line (`VERDICT: X`) and parse only that; no tag = no action + exit 1. Never keyword-search prose ("sell" in "no reason to sell").
4. **A failed run must be visible:** the wrapper advances its "last run" state only on exit 0, so the next tick retries; when a daily result is missing, read the job's own logs (the job's log files) before anything else.
4b. **Pass a generated prompt to `claude -p` on stdin, not argv.** A prompt that starts with `-` (e.g. a file with `---` frontmatter) is parsed as an option: `error: unknown option '---…'`, exit 1. Use `subprocess.run([claude, "-p", ...flags], input=prompt)` / `claude -p < prompt.txt`, and treat a non-zero exit or empty stdout as a failed run. Never grep the output for a success marker that also appears in the prompt itself, because the error text echoes the prompt. Check: `claude -p "---x" </dev/null` prints the error.
5. **Call the real agent binary, not the shell name.** In an interactive shell `claude` (or any agent CLI) may be a shell function/wrapper (`type -a claude`); a scheduler or `spawn` resolves PATH only, so use the absolute binary path (overridable by env). A mode flag can be unavailable per account (the CLI warns and falls back to default mode); check one run's stderr instead of assuming.
6. **Retry ticks + done-marker:** for "run at T1, retry at T2 only if T1 failed", put both times in one `StartCalendarInterval` array and have the wrapper exit early when the state file already holds the target date; write the state only after the whole job (agent + delivery/push) succeeded. Calendar limits (weekdays only: `[ "$(date +%u)" -gt 5 ] && exit 0`) go in the wrapper, so the catch-up tick obeys them too.
7. **Editing a plist array element: `plutil -replace ProgramArguments.<i>` inserts, it does not replace** — the old value shifts to the next index and is passed as an extra argument. Use `plutil -remove <key>.<i>` then `-insert`, or rewrite the whole array (`plutil -replace ProgramArguments -json '[...]'`); confirm with `plutil -extract ProgramArguments json -o - <plist>` and reload with `launchctl bootout gui/$UID/<label>` + `launchctl bootstrap gui/$UID <plist>`.
8. **Keep the job's script inside its own repo** so tools can map and review it, and so it survives a new machine; set the plist `WorkingDirectory` and write the log to a known path (`>> <log>` or `StandardOutPath`).

## Check it worked
Trigger once by hand through the same wrapper the scheduler calls, then confirm the scheduler lists the job and the log shows the next real tick.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: add the trap as a numbered rule (keep ≤10).
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
