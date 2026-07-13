# Dev Task Progress — P37 Phase G: Autocomplete (mobile bridge)

Last updated: 2026-07-13
Status: In Progress

## Context

Follows Phase F2 (keyboard toolbar, `9c4706f3`). Interview completed via `Skill(interview)` →
`doc.md` mode: user asked for autocomplete "ทั้งในหน้า terminal, ai" (both in the terminal page
and AI-flavored), which resolved into 3 distinct sub-features via AskUserQuestion — @ file-path
insertion, a shell tab-completion suggestion strip, and an AI-powered command suggestion via the
user's own `claude` CLI. No existing AI/LLM backend in this codebase (confirmed via grep — only
hit was an unrelated comment about the user's own separate `ANTHROPIC_API_KEY` env var for their
own CLI use); G3 deliberately reuses that CLI via subprocess rather than building new API
integration. No new bounded context — same reasoning every other Phase D/E/F entry already used.

## Artifacts
- Design: `agent-memory/plans/p37-phase-g-autocomplete/design.md`
- Test Scripts: none pre-existing — same convention as every other phase in this project:
  `swift test --filter` + `Tests/robot/run.sh` + live-daemon check via `make mobile-web`, not a
  TDD-skeleton-first flow

## Summary
- Total tasks: 12
- Completed: 6
- Remaining: 6

## G1 — @ file-path picker ✅ DONE 2026-07-13

**Deviation from design.md, smaller than planned:** design.md called for "a lightweight inline
picker (not D1's full-screen files sheet)". On implementation, reusing D1's existing files-sheet
DOM/CSS/state wholesale (`filesCwd`, `listFiles`, `fileEntryRow`, `renderFileEntries`) with a new
`filesPickerMode` flag turned out strictly smaller than building a second near-identical sheet —
same sheet, file-tap now branches `openFileTab(...)` (preview, D1) vs `insertFilePath(...)` (G1)
on the flag, D2's upload row hidden via the same flag. No new CSS at all.

### Client Application
- [x] Add `@` button to the existing `.kbd-toolbar` row (`embeddedPageHTML`, shipped in `9c4706f3`)
- [x] Picker UI — reused D1's files-sheet wholesale (see deviation note above) instead of a new
      one; drives navigation via the existing `listDirectory` WS request (D1, zero new
      server-side surface)
- [x] Path selection → client-side shell-quote (`shellQuotePath`, single-quote wrap) → insert via
      `sendKeySeq` (F2's existing helper)
- [x] Error handling: already covered for free — `listDirectory` failures already route through
      the existing generic `msg.error` → `showError()` path every WS response shares, nothing
      picker-specific needed
- [x] ✅ Run test scripts — `swift build` clean, `swift test --filter MobileBridge` (35/35, 3
      skipped live-daemon-only, as before — no new server-side code path so no new unit tests),
      `Tests/robot/run.sh` 23/23
- [x] Live check: real Chrome + isolated `make mobile-web` daemon (fresh instance, non-default
      ports to avoid the prod-daemon port conflict noted during F2 testing) — paired, attached
      `Shell` session, tapped `@`, picker opened showing the real home directory (125 items, D2's
      upload row correctly hidden), tapped `.DS_Store`, sheet closed and
      `'/Users/supavit.cho/.DS_Store'` landed correctly in the real PTY input line, shell-quoted
      exactly as designed

## G2 — shell tab-completion suggestion strip (heuristic, best-effort)

### Client Application
- [ ] `term.buffer.active` snapshot-before-Tab / read-after-Tab helper (~150ms debounce)
- [ ] Heuristic token-list detection per design.md's exact signature — hard rule: ambiguous result
      → show nothing, never a wrong/garbage suggestion
- [ ] Render detected tokens as a tappable strip above `.kbd-toolbar` (new shared strip component,
      reused by G3 — build this once, not twice)
- [ ] Tap-to-insert via `sendKeySeq`, trailing space appended (matches normal shell completion)
- [ ] ✅ Run test scripts — build clean; this is pure client heuristic logic, no server-side test
      surface. Manual verification only (see Live check below) — flag if this needs a lightweight
      JS-level test harness instead of relying on live-only verification
- [ ] Live check: real Chrome + isolated daemon, real zsh session — confirm strip appears on an
      actual multi-candidate Tab-completion, confirm it does NOT appear on a single-candidate
      Tab (auto-completed inline, no menu) or on a normal command's stdout

## G3 — AI command suggestion (via `claude` CLI subprocess)

### Server Logic
- [ ] New WS message pair: `{"aiSuggest":{"commandBuffer","cwd"}}` →
      `{"aiSuggestion":{"suggestion"}}` / `{"error":...}` (reuses existing `ErrorAck` shape)
- [ ] `claude` CLI path resolution — mirror `GitHubCLIClient.cachedGhPath`'s cached-lookup +
      `which` fallback shape (`Packages/KouenCore/Sources/KouenCore/GitHub/GitHubCLIClient.swift`)
- [ ] Subprocess invocation wrapped in a fixed prompt template (design.md's exact wording) —
      never pass `commandBuffer` to the CLI unwrapped
- [ ] **Must run off the connection-handling queue** — dedicated background dispatch, async
      response back to the originating WS connection; a synchronous `waitUntilExit()` inline in
      `handleControlMessage` is a correctness bug here, not a style preference (see design.md's
      Strategic Design R3 note)
- [ ] Timeout (~20s) — kill the subprocess and return an error past that bound
- [ ] ✅ Run test scripts — new `MobileBridgeAISuggestTests.swift`: path-resolution fallback logic,
      prompt-template construction (pure function, testable without spawning a real process),
      timeout-triggers-error path. Full `swift test --filter MobileBridge`, `Tests/robot/run.sh`

### Client Application
- [ ] Explicit trigger button (kbd-toolbar or adjacent) — never auto-suggest while typing
- [ ] Reuse G2's suggestion-strip component for rendering (same tap-to-insert mechanism)
- [ ] Loading/pending state while the subprocess round-trip is in flight (multi-second — needs a
      visible "thinking" state, not a silent multi-second gap)
- [ ] ✅ Run test scripts — build clean, full suite green
- [ ] Live check: real Chrome + isolated daemon, real `claude` CLI installed and authenticated on
      the test machine — confirm a real suggestion round-trips and inserts correctly; confirm the
      timeout path (kill/hang the subprocess artificially) surfaces a clean error, not a hang

## Integration
- [ ] End-to-end wiring — G1/G2/G3 all reachable from one attached session, no reconnect needed
      between them
- [ ] ✅ Run all test scripts (verify GREEN) — `swift build`, `swift test`, `Tests/robot/run.sh`
- [ ] Live check against a real daemon — build-green alone is NOT done (`MEMORY.md` 2026-07-07
      lesson, governs every phase in this project)
- [ ] Code review — `review-personas`, then the standing lesson: review against
      `agent-memory/knowledge/rl-lessons.md` + `cases/*.md` before calling multi-file new-feature
      work done
