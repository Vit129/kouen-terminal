# Terminal quality in Harness 2.3

Harness 2.3 keeps the native interface and pane workflows while improving the terminal's parsing, retained history, output transport, and rendering. The [scorecard](SCORECARD.md) distinguishes measured performance from goals; it does not establish superiority over Ghostty or Rex.

## Text and command interaction

Selections, reading positions, and the active search result use stable text anchors. They follow retained text through width changes and history movement. When retention evicts the referenced text, Harness invalidates the reference rather than selecting unrelated text.

Right-click command output to copy its command, copy or select its output, find within that output, or navigate failed commands. The scoped find bar indicates that it is searching command output. Automatic bash, zsh, and fish integration emits separate prompt, input, output, and completion boundaries. See [shell integration](shell-integration/README.md) for installation, opt-out, and third-party prompt limits.

## Unicode and fonts

Grapheme segmentation and width data are pinned to Unicode 18 inputs with verified checksums. Harness supports terminal mode 2027 and uses the engine's text layout for composed input and overlays. Font coverage still depends on the configured and installed fonts.

### Input limits

The engine bounds hostile or runaway input. Each limit keeps the stream parsing and the following output intact.

- **Control sequences.** A CSI keeps up to 32 parameter groups and 128 values. That covers any supported SGR, including foreground, background, and underline truecolor in one sequence. A sequence past the cap is ignored whole rather than half-applied. A single number above 65,535 is clamped and still applied.
- **Strings.** OSC payloads keep 1 MiB (32 MiB for inline images). An oversized OSC, DCS, or APC is consumed through its terminator and never dispatched, so it cannot set a title, link, clipboard, or image.
- **One cell's text.** A grapheme cluster keeps its first 256 UTF-8 bytes. Further combining marks are consumed without moving the cursor, and copy returns the kept prefix.
- **All clusters.** Clusters longer than a base and two marks, such as emoji ZWJ sequences, share an 8 MiB store per screen. Unused entries are collected first. When live clusters still fill it, a new cell keeps its base character and first two marks and drops the rest.

`UnicodeAndCSILimitTests` and `ParserRobustnessTests` cover each edge.

In **Settings → Terminal**, configure ordered fallback font families and OpenType features. Fallback families are comma-separated, for example `Menlo, Apple Color Emoji`. Feature values use four-character tags and nonnegative integers, for example `calt=0, ss01=1`. Invalid feature syntax is reported instead of silently changing the effective configuration. The same settings reach terminal rendering and Overview thumbnails.

## Output, history, and startup

The output receiver processes bounded batches and yields between them. Output order, replay boundaries, and consumption acknowledgements remain ordered. System scroller-style changes preserve scrollbar visibility and its existing hide deadline. Packed retained history and damage-driven row snapshots reduce repeated copying and rendering; hidden panes stop requesting frames.

Windows resolve the saved sidebar state, tab-row placement, and final geometry before presentation. The initial window waits for a real daemon snapshot before mounting terminal panes, avoiding a temporary attachment and reconnecting chip. Loading a window does not rewrite the saved sidebar setting. In 2.3.1, a window awaiting its first snapshot shows connecting, update, or retry controls. An older service remains running until an explicit restart decision; the restart cleans only that stopped owner's unchanged control socket.

## Update behavior

The internal session-host protocol is 10 and terminal checkpoint schema is 2. Run matching components. A new build alone does not authorize terminating running programs; the app reports pending or incompatible host updates and offers an explicit restart path. See [session service updates](SESSION-SERVICE-UPDATES.md).

## Verification

The [implementation receipt](terminal-quality-2026-10-10/README.md) and [follow-up audit](terminal-quality-2026-10-10/audit/README.md) identify source snapshots, focused test results, native app observations, and limits. Full input-method candidate interaction, every third-party shell prompt, and every physical display configuration are not inferred from automated tests.
