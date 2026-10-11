# Terminal quality implementation and verification

All five requested improvements are implemented in the existing working tree. Existing appearance and workflows remain the default. No release, publishing, GitHub Actions dispatch, or benchmark comparison was performed.

## Delivered behavior

1. **Stable text positions.** Selection, reading position, and the active search result follow text through width changes and history movement. Evicted text invalidates its references safely. Anchor registration uses a short synchronized context rather than waiting behind output parsing. Normal scrolling advances a shared origin rather than walking every retained command marker.
2. **Precise command actions.** Shell integration emits prompt, input, output, and completion boundaries for zsh, bash, and fish. The context menu can copy a command, copy/select its output, search within its output, and navigate failed commands. Exclusive end positions handle output without a trailing newline. Command metadata survives checkpoints; the checkpoint schema is version 2, with no added legacy decoder.
3. **Consistent Unicode and composition.** Grapheme segmentation uses pinned, checksum-verified Unicode data matching the existing width tables. Mode 2027 supports set/reset/query and persistence. Capture preserves cell boundaries across grapheme modes. IME preedit and copy-mode status use the engine's literal text layout, including emoji, Hangul, Indic, Thai, and combining marks.
4. **Font controls.** Ordered fallback families and OpenType feature settings reach terminal rendering and thumbnails. Fallback glyph ink fits the primary font's line geometry. Default geometry is retained; color glyph conversion preserves the existing pixel tolerance.
5. **Bounded output work.** Each scheduled receiver turn handles at most 64 KiB and 256 fragments, then yields to queued frame work. Splitting preserves FIFO, replay boundaries, and consumption acknowledgement after the final fragment.

## Verification

- Final integrated run: **77 tests passed**, no failures or skips. It covers text anchors, command regions/checkpoints, Unicode, capture, selection, scoped search, and composed-text frame layout.
- Across the focused runs, the latest result for each distinct test is **263 passed, 2 skipped, 0 failing**. This is a union of focused runs, not a claim that all 265 were rerun after every edit. Unchanged font, shell, receiver, settings, and resize paths passed in preceding runs; affected paths were rerun after integration changes.
- The two skipped cases require **3270 Nerd Font**, which is not installed. Other font rasterization tests passed without relaxing their assertions.
- Real shell tests cover repeated sourcing, dynamic prompts, prompt boundaries, and exit-status preservation. Native surface tests exercise selection, resize, search, and frame behavior; pure overlay tests compare rendered cluster contents with committed engine text.
- Initial integration failures were corrected: color conversion order, an anchor fixture whose history cap legitimately evicted its target, and a private type alias used in newly testable helpers. Their affected checks subsequently passed.
- Optimized macOS build: `swift build -c release` passed (80.46 seconds). The build reported one existing warning in vendored MCP `NetworkTransport.swift` about nested capture ownership; no terminal implementation warnings were reported. `git diff --check` passed.

[Per-test results](test-results.json) identify each result's log. Local full logs are retained under `.benchmark-results/terminal-quality-2026-10-10/`. The [source manifest](source-sha256.txt) covers 884 application, package, tool, script, and test source files; its SHA-256 is `0749989a68459f20cecaa6ff99008e9f977bc2696cecede2d1e7e598aea1f71b`.

## Limits

This work does not establish a measured latency improvement or superiority over Ghostty. No broad benchmark matrix was rerun. Physical input-method interaction, every third-party prompt framework, and a new Linux build were not manually validated during this pass. The optimized build's result is recorded separately from test coverage. Existing earlier performance and production-audit receipts describe their own source snapshots and are not presented as proof for newly changed code.
