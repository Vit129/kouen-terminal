# Recorded coding-agent terminal stream

`codex-recorded-2026-10-10.cast` is an actual PTY recording of Codex CLI 0.162.1
at 100×30, xterm-256color, captured on the owner's Mac in an empty temporary
working directory. It contains startup and command-entry redraws. No model
turn was submitted. The `/help` command was unrecognized; its real error and
subsequent input redraws are preserved rather than replaced with synthetic VT.
The capture ends by terminating only the temporary recording process.

This is a short interactive UI trace, not evidence about model-generation
performance or a complete coding task. Use it alongside the large SGR and
Unicode workloads, and label its scope in benchmark receipts.

`consumer_ack_runner.py --generate ... --agent-session ...` extracts output
events and removes CSI status-report queries before replay. The original cast
remains intact. Removing those non-display queries prevents a recorded early
cursor response from being mistaken for the benchmark's final parsing fence.
