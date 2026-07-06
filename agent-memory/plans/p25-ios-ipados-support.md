# P25 — iOS/iPadOS Support

Status: **Planning — MVP re-scoped to Web/PWA (2026-07-04)**

**Hard constraint (2026-07-04): no Apple Developer Program account.** No TestFlight, no App Store, no push notification entitlements (APNs certs require a paid account). Native deployment to a physical device is only possible via free-provisioning sideload, which re-signs and expires every 7 days through Xcode tethered to a Mac — fine for solo daily use, unusable for distribution or for relying on background push. Decision: **do not start native UIKit/Xcode work (Phase 0–4 below) yet.** Build the Web/PWA MVP first (see new section right after Competitive Landscape); revisit native only if a paid account is obtained or the web MVP proves the demand and hits a real ceiling.
Priority: **P1** — strategic platform expansion, not a current macOS release blocker
Owner surface: Package.swift, KouenCore, KouenTerminalEngine, KouenCopyMode, KouenTheme, KouenTerminalRenderer, new KouenTerminalUIKit, new KouenMobileApp
Created: 2026-06-19
Depends on: stable daemon IPC, remote host model, terminal renderer isolation

---

## Product Intent

Kouen on iPad should be a **remote-first terminal workstation**:

- attach to Kouen daemons running on a Mac, Linux box, or server
- render live sessions with the same terminal engine, themes, copy mode, panes, tabs, scrollback, and agent notifications
- provide iPad-native input: hardware keyboard, touch selection, pointer, command menus, Split View, Stage Manager, and Files integration
- preserve daemon-owned persistence; closing the iPad app must not kill sessions

The first iPad milestone is **not** a standalone local macOS-equivalent terminal. iOS/iPadOS sandboxing, background execution, launchd absence, PTY/process ownership, SSH tunneling, helper installation, Sparkle, AppKit, and service-provider APIs make a direct port the wrong first cut.

Core mental model:

```text
iPad Kouen app -> network transport -> KouenDaemon on Mac/Linux/server -> PTY sessions
```

---

## Competitive Landscape (research 2026-07-04)

Surveyed how existing terminal/agent products solve "terminal on mobile." Four architecture families observed:

| Product | Transport | Persistence model | Mobile UX | Notes |
|---------|-----------|--------------------|-----------|-------|
| **cmux** (`manaflow-ai/cmux`) — Ghostty-based macOS terminal for AI coding agents, direct category competitor to harness | SSH → remote `tmux -CC` mirroring; iOS companion pairs via a "Mobile Connect" window on the Mac | Session lives in remote tmux; Mac app and iOS companion both attach/detach without killing it | iOS app in TestFlight beta ("cmux BETA"); forwards terminal notifications to phone | GitHub issues #1037 ("Remote access") and #2587 ("Remote session reattachment — SSH from phone/iPad") show this was user-requested, not designed upfront — validates D1 option 3 (companion gateway) as a real shipped MVP path, not just a stepping stone |
| **WezTerm** | Custom mux protocol; SSH bootstrap → upgrades to TLS-domain TCP for steady state | Daemon-owned mux server, GUI is a thin client (same shape as harness's `RealPty` daemon) | None — no iOS/mobile client exists | Confirms the daemon/thin-client split is sound, but nobody has shipped the mobile side of it for WezTerm |
| **Blink Shell** (iOS) | **Mosh** (UDP, survives IP change/sleep/packet loss) + SSH/libssh2, PKI + Secure Enclave keys | Remote `tmux` session; Mosh reconnects transparently, tmux holds scrollback | Native iOS terminal, hardware keyboard focus | The mosh+tmux pairing is the de facto standard stack for "real remote shell from a phone" |
| **Termius** | SSH/mosh | No live session mirroring — syncs *host configs, keys, snippets* (E2E encrypted vault) across devices, each device opens its own session | Polished cross-platform SSH client | Solves credential/host sync, not session continuity — orthogonal to F3 pairing but relevant to "remote host store" reuse already in `HarnessCore` |
| **iSH / a-Shell** | None (fully local) | N/A | Local Linux-ish shell on-device (iSH: x86 usermode emulation, largely stalled since 2023; a-Shell: native ARM64-compiled tools) | Confirms P25's existing call to defer local-shell — iSH's emulation approach is stagnant, a-Shell's is real but solves a different problem (no daemon, no session mirroring) |
| **Moshi** (getmoshi.app) — "mobile terminal for AI coding agents" | Mosh | Attaches to existing Claude Code/Codex/etc. sessions via a `moshi-hook` integration | **Renders the agent session as a native chat view** — tool-call cards, plan/approval cards, voice input (on-device Whisper), push notification on task completion, Face-ID-gated SSH keys in Keychain | Closest existing product to "what would iPhone Harness look like" — explicitly not a shrunken terminal grid, it's agent-turn-aware UI |
| **VibeTunnel** | Local web server (`localhost:4020`) + Tailscale for remote reach; browser is the client | Wraps any CLI (`vt <cmd>`) in a PTY-to-websocket bridge | Plain browser terminal (xterm.js-style); authors themselves note touch doesn't translate well beyond monitoring | Good proof that "just expose a websocket PTY" is easy to build but poor UX without agent-aware rendering |
| **Claude Code Remote Control** (first-party, code.claude.com/docs/en/remote-control, shipped 2026-02-25) | **Outbound-only.** Local `claude remote-control` process makes an outbound HTTPS connection to Anthropic's API and *polls/streams* for instructions — **no inbound listener, no open port, no port-forward, ever.** Phone/browser also just talks to the same Anthropic-hosted relay. | Session runs on the user's machine (full local filesystem, MCP servers, tools); conversation stays in sync across every connected device, streamed at the message/turn level, not raw PTY bytes. Reconnects automatically after sleep/network drop; hard-times-out and exits after ~10 min unreachable. | Built into claude.ai/code + Claude iOS/Android app; QR code or session URL to pair; push notifications (proactive + action-required), suppressed while the desktop screen is unlocked/user present | **Gold-standard reference for this plan.** Pairing uses ephemeral Curve25519 keys + Diffie-Hellman per session (forward secrecy) verified by an HMAC proof derived from the pairing token; relay joins "rooms" keyed by `SHA-512(token)` and **never sees the token or plaintext** — it's a blind ciphertext relay, not a party that can be tricked into replaying a raw shell. Optional "Trusted Devices" tier adds per-device enrollment + 18h re-auth + biometric step-up, with only a public key + device metadata stored server-side (no biometric data leaves the device). Also documents Anthropic's own product taxonomy for "not at your terminal" access: Remote Control (steer a running local session) vs Dispatch (phone spawns a new Desktop session) vs Claude Code on the web (fully cloud-run, own MCP/tools do NOT apply) vs Channels (event-driven via Telegram/Discord) vs Scheduled tasks — P25 is scoped to the Remote Control shape specifically, the others are explicitly out of scope. |
| **OpenAI Codex Remote** (first-party, GA 2026-06-25) | OpenAI-run relay; one-to-one **QR pairing per phone-per-host** | Host machine — projects, credentials, plugins, MCP servers — stays local and never exposed to the public internet; relay only carries *session messages* (prompts, approvals, diffs, screenshots, terminal output), not raw shell/PTY access | Built into ChatGPT mobile app: approve diffs, redirect running tasks, monitor terminal output | Near-identical shape to what P25's D1/F3 already sketch (daemon stays local + authenticated relay + per-device pairing) — direct validation, and note it deliberately relays *messages*, not a shell, which is a stronger security stance than a raw PTY tunnel |
| **OpenAI Codex Cloud** (distinct from Codex Remote above) | N/A — no local host at all | Task runs in an OpenAI-owned ephemeral microVM sandbox with the repo cloned in; you submit and collect a diff later | Native ChatGPT app UI, not a terminal at all | A fifth, fundamentally different family: **fully cloud-executed, no daemon of yours involved** — out of scope for harness (which is explicitly "attach to a daemon you own"), but explains why it needs no pairing/relay-security story: nothing sensitive ever leaves OpenAI's infra |
| **ttyd / GoTTY** | WebSocket + xterm.js | Whatever process it wraps; no session ownership model | Generic browser terminal | Commodity building block other tools (VibeTunnel-style) are built on; not a product-level answer by itself |

### Implications for this plan

- **D1 (transport):** every real mobile terminal in this survey (Blink, Moshi) uses **Mosh (UDP)**, not TLS/WebSocket, specifically for the mobile-specific failure modes (cellular↔WiFi handoff, sleep/wake, tunnels). Re-weigh D1 option 1 — a WebSocket/TLS endpoint may need mosh-like state-sync semantics (idempotent frame resend, sequence-numbered redraw) even if the wire protocol stays custom, rather than assuming plain reconnect-and-replay is enough.
- **D1 option 3 (Mac companion gateway) is de-risked** — cmux shipped exactly this as its first mobile milestone (Mac pairs an iOS companion, SSH-mirrors a remote tmux). Good evidence this is a legitimate MVP, not just a fallback.
- **F3 (pairing):** cmux's "Mobile Connect" pairing window on the desktop app is a concrete UX reference for the pairing-code/QR flow already sketched here.
- **New idea — agent-native mobile rendering (not yet a feature spec below):** Moshi and Claude Code Remote Control both skip literal terminal-grid rendering in favor of turn/block-aware UI (tool cards, approval cards, chat framing). Harness already has the primitive for this — `TerminalBlock` / OSC-133 command boundaries from P34 (`harnessGetLastBlock`/`harnessGetBlock`). A phone-first Harness client could render *blocks* (command + output + exit status) as cards instead of a raw VT grid, which sidesteps most of the hard touch/keyboard terminal-UX problems in F4/F5. Worth a dedicated spike before committing to F4's raw UIKit terminal surface as the only mobile rendering path.
- **Open Questions below:** all three competitor products (cmux, Blink, Moshi) treat **iPhone**, not iPad, as the primary or equal-priority target (pocketable "check on my agent" use case) — this cuts against this plan's current iPad-first framing and should be revisited explicitly (see updated Open Questions).
- **Security posture for the Web/PWA MVP:** OpenAI Codex Remote's choice to relay only *session messages* (not a raw shell) is a stronger stance than a plain PTY-over-WebSocket bridge. Worth a deliberate tradeoff note in the Web/PWA MVP section: harness's daemon already draws its security line at "authenticated client, then full shell" (matches SSH/mosh/cmux's model), so a PTY-over-WebSocket bridge is consistent with harness's existing threat model — just be explicit that this is a materially wider blast radius per pairing than OpenAI's message-relay approach, and make sure the pairing/revocation story (F3) is taken as seriously as the transport.
- **Outbound-only connection pattern (Claude Code Remote Control):** the single most transferable architectural idea here. Instead of the Mac binding a listener that the phone dials into (this plan's current default — see Web/PWA MVP "Bind default"), the Mac-side process could instead dial *out* to a relay and poll/stream, with the phone also dialing the same relay. That eliminates "open a port on the Mac" entirely — no LAN assumption, no router/firewall config, works identically on cellular. The catch: harness has no Anthropic-scale relay to lean on, so this trades "no inbound port" for "need *some* always-on relay endpoint" — a small self-hosted relay (or an existing outbound-tunnel service like Cloudflare Tunnel, which itself dials out from the Mac the same way) is the pragmatic version of this for a solo/personal deployment. Should be weighed against the simpler LAN/Tailscale-direct default before committing to the Web/PWA MVP's transport shape.
- **End-to-end encryption of the relay payload**, independent of transport-level TLS, is what makes Claude Code's and Codex Remote's relays trustworthy even though a third party operates them: the relay is architecturally incapable of reading plaintext or replaying a session (SHA-512(token) room IDs, per-session ephemeral keys). If harness's Web/PWA MVP ever routes through anything other than a direct LAN link or a private mesh VPN (Tailscale) — e.g. Cloudflare Tunnel or a self-hosted relay — it should adopt the same shape: encrypt PTY frames with a key derived from the pairing secret, not just rely on the transport's TLS, since transport TLS alone trusts whoever operates the relay.

Sources: [manaflow-ai/cmux](https://github.com/manaflow-ai/cmux), [cmux issue #1037](https://github.com/manaflow-ai/cmux/issues/1037), [cmux issue #2587](https://github.com/manaflow-ai/cmux/issues/2587), [WezTerm multiplexing](https://wezterm.org/multiplexing.html), [Blink Shell](https://blink.sh/), [Termius docs](https://docs.termius.com/), [iSH](https://ish.app/), [a-Shell](https://apps.apple.com/us/app/a-shell/id1473805438), [Moshi](https://getmoshi.app/), [VibeTunnel](https://steipete.me/posts/2025/vibetunnel-turn-any-browser-into-your-mac-terminal), [Claude Code Remote Control](https://code.claude.com/docs/en/remote-control), [ttyd](https://github.com/tsl0922/ttyd), [OpenAI Codex Remote GA](https://www.techtimes.com/articles/319201/20260627/openai-codex-remote-goes-live-all-plans-phone-control-now-secured-qr-relay.htm), [OpenAI Codex on ChatGPT mobile](https://techcrunch.com/2026/05/14/openai-says-codex-is-coming-to-your-phone/), [Codex sandboxing](https://developers.openai.com/codex/concepts/sandboxing), [Claude Code Remote Control docs](https://code.claude.com/docs/en/remote-control)

---

## Revised MVP: Web/PWA Terminal (P0 — current focus)

No App Store, no signing, no Xcode device dance. The daemon already owns PTY/session truth (`RealPty`) — add an HTTP+WebSocket bridge next to the existing Unix-socket IPC listener, same pattern as VibeTunnel/ttyd, and let any phone browser (iOS Safari, Android Chrome) be the client.

```text
iPhone/iPad/Android browser -> WebSocket over Tailscale (or LAN at home) -> HarnessDaemon bridge -> RealPty sessions
```

### Why this order

- Zero distribution friction: works today, no $99/yr, no 7-day resign cycle, no App Store review.
- Same daemon-owns-truth model P25 already committed to (D2/F6) — the bridge is a second `Endpoint` transport, not a redesign.
- De-risks the UX question raised in Competitive Landscape (block/chat view vs raw terminal grid) with much cheaper iteration than native UIKit — it's HTML/CSS/JS, ship-on-save.
- If this MVP is all Vit ends up needing day-to-day, native Phase 0–4 may never need to happen at all.

### Spike result (2026-07-04): transport hypothesis confirmed over LAN

Built and ran a throwaway target — `Spikes/MobileBridgeSpike/` (`Package.swift` executable `MobileBridgeSpike`, no new SwiftPM dependency: `NWListener` + `NWProtocolWebSocket` from `Network.framework`) plus `Spikes/MobileBridgeSpike/index.html` as the phone-side test page, served locally via `python3 -m http.server`. Builds clean under the repo's Swift 6 strict-concurrency mode. Confirmed end-to-end over home WiFi: phone browser opened the page, connected via WebSocket, sent a message, received the mock reply back. **Tailscale is not yet installed on this Mac** (no CLI, no app, no tailnet interface) — the "not on the same WiFi" leg of D1's reachability decision is still unverified; LAN-only was confirmed as a stand-in. Delete `Spikes/MobileBridgeSpike/` once the real bridge work starts in `HarnessDaemonCore` below.

**Update (2026-07-04, same day): wired to the real daemon.** `MobileBridgeSpike` now depends on `HarnessCore` and calls the real `DaemonClient().request(.daemonStats)` (same call `DaemonLauncher.daemonStats()` in the GUI app makes, over the existing `.localControlSocket` Unix socket) instead of returning a mock string — deliberately scoped to this one read-only, non-sensitive request while there's still no pairing/auth, since real PTY input/output *is* the actual trust boundary (see Security Notes) and stays out until F3 lands. Verified over LAN: phone round-trip now returns real data from the actually-running daemon (`{"version":"3.14.0","pid":16743,"surfaceCount":2,"clientCount":2,...}` — matched the live daemon's actual PID/version/session counts, not a fixture). `DaemonClient.request` blocks its caller, so the reply is dispatched off the listener's main queue to avoid stalling other connections. Confirms the whole chain end to end: **phone browser → WebSocket → real `DaemonClient` IPC call → real daemon → back to phone.** Remaining before this can move out of Spikes/: Tailscale verification (still pending), and swapping `daemon-stats` for the real terminal I/O once real pairing exists.

**Update (2026-07-04, same day): minimal pairing gate added.** `MobileBridgeSpike` now generates a random 6-digit token at launch (printed to console, regenerated every restart — this spike's stand-in for "revoke all"), and every new connection must send that token as its first message before it gets anything back; a wrong/missing token gets `{"error":"invalid pairing token"}` and the connection is closed. `index.html` updated with a token field — connects, sends the token automatically, and only enables "Get daemon stats" after a `{"ok":"paired"}` ack. Verified both paths directly (not just via the phone): wrong token → rejected + closed; correct token → paired → real daemon stats returned. This is deliberately the minimum needed to prove the auth *mechanism* (reject-by-default, explicit token to proceed) — real F3 (persistent per-device grants, individual revocation, `harness-cli mobile list-clients/revoke`) is still real daemon work, not spike work, and is the thing to build next when this moves out of Spikes/ into `HarnessDaemonCore`.

**Update (2026-07-05): confirmed a phone-side drop, not a server bug — client error message cleaned up.** Testing over real WiFi, a phone connection paired, got real stats, then dropped with the server log showing `Connection reset by peer` (client-initiated RST) right after the reply — a debug-mantra pass reproduced the pair→stats sequence over loopback held open 10s+ with a second request succeeding, ruling out any server-side idle-close bug. Leading explanation: the phone's browser tab backgrounded (screen lock / app switch) and iOS tore down the WebSocket, which is exactly the gap already tracked as unbuilt ("Reconnect: WebSocket drop → resume by replaying retained scrollback" in Scope above) — not a new defect. `index.html`'s `onerror`/`onclose` previously logged the raw unhelpful `[object Event]`; now reports the close `code`/`reason` and a plain-language hint distinguishing a clean close from an unexpected drop.

**Update (2026-07-05): attached to a REAL live terminal session (not just stats) — output direction fully proven.** `MobileBridgeSpike` now, on successful pairing, calls the real `.listSurfaces` request, picks the first live surface, and calls the real `DaemonClient.attachReplayingSurfaceOutput` — the exact same call the GUI uses to reattach a session — streaming the replay (current screen) then live output as binary WS frames. `index.html` renders it into a `<pre>` block (raw text incl. ANSI escapes — a real terminal renderer is still future work) and gained a text input that sends Enter-terminated keystrokes as the next feature to prove. Verified directly: paired, got `{"ok":"attached","surfaceID":...,"tabTitle":...,"cwd":...}`, then a stream of real binary frames — which, because `.listSurfaces().first` happened to resolve to *this very agent session*, visibly included live text from this conversation and the CLI's own "Vibing…" spinner frames as they redrew. Confirms the output half of the real terminal-I/O chain end to end with the strongest possible evidence (it streamed itself).

**Safety note, not yet resolved:** did not test the input direction (`sendInput`) against this run, because the attached surface was this live agent session — typing into it from a phone would inject characters into the terminal this conversation runs in. `.listSurfaces` currently has no way to target a *specific* surface or exclude any — the spike just grabs `.first`. Before further keystroke testing, either open a disposable second tab so `.first` (or an explicit picker) lands somewhere safe, or treat "let the phone choose which session to attach to" as a real requirement to add before this leaves Spikes/ — right now any client that pairs can land on *any* surface non-deterministically, including one someone is actively relying on.

**Update (2026-07-05): input direction confirmed too — the full terminal-I/O chain works both ways.** Added a temporary `SPIKE_SURFACE_ID` env-var override to `attachFirstSurface` so testing could target a specific, known-safe surface (found via the real `harness-cli list-surfaces` — a third, plain idle zsh prompt, not either of the two live agent sessions) instead of `.first`'s non-deterministic pick. Sent `echo hello-from-phone-test\n` as WS messages; the daemon log and the streamed-back output showed the real zsh processing it keystroke-by-keystroke (individual character echoes, real OSC 697 PreExec/NewCmd shell-integration marks firing), actually running the command, and streaming the real `hello-from-phone-test` output plus the prompt redraw back to the client. **Both directions of real terminal I/O are now proven end to end: phone → WebSocket → real `DaemonClient` → real PTY → real shell → real command execution → real output → back to phone.** `SPIKE_SURFACE_ID` is a throwaway test knob, not a feature — the real requirement it stands in for (letting a client pick/see which session it's attaching to, and never attaching to a session someone didn't choose) is unchanged from the Safety note above and still needs solving before this leaves Spikes/.

**Update (2026-07-05): Tailscale installed and both devices already paired — D1's last open item is closed.** Installed via `brew install --cask tailscale` (the pkg installer needs an interactive `sudo` prompt, which this session's non-PTY shell can't supply — Vit ran it himself in a real terminal). `tailscale status` confirms both devices are on the tailnet: Mac `100.94.236.66` (`supavits-macbook-pro`), iPhone `100.115.53.5` (`iphone174`) — Vit had already installed and signed in on the iPhone side himself. `index.html`'s default host updated from the LAN IP to the Mac's Tailscale IP. This is the first point where an actual "not on the same WiFi" test is possible — not yet run, but nothing code-side blocks it anymore.

**Update (2026-07-05): full end-to-end test on cellular (not WiFi) — every open item in the Web/PWA MVP's core transport is now closed.** Vit connected from the iPhone over 5G cellular (confirmed via screenshot: status bar showed "5G", URL was the Mac's Tailscale IP `100.94.236.66:8080`, not the LAN IP) — the actual "away from home WiFi" scenario D1 needed verified. Attach worked; raw output was readable as literal escape-code garbage, so `index.html` was upgraded from a plain `<pre>` dump to real `xterm.js` (CDN-loaded, both URLs confirmed reachable) — `term.write()` on incoming binary frames now renders actual ANSI/VT output, `term.onData()` forwards real keystrokes. First pass broke typing entirely: `term.focus()` was called from the async WS "attached" handler, and iOS Safari only raises the on-screen keyboard when `.focus()` runs synchronously inside a real user gesture — fixed by focusing on a `click`/`touchend` listener on the terminal element itself. Vit confirmed typing through the iPhone keyboard now reaches the real terminal. **Every core Web/PWA MVP transport question is now empirically proven: WebSocket transport, pairing-token auth gate, real daemon attach (output + input), Tailscale reachability from cellular, and legible rendering with working mobile keyboard input.** Remaining before this leaves Spikes/ for real `HarnessDaemonCore` work: real F3 (persistent per-device pairing/revocation — see below, this closed the *session-choice* half but not persistent multi-device grants), and resize-sync (terminal is hardcoded to 80×30, doesn't match the real PTY's actual size).

**Update (2026-07-05): session-picker safety gap closed — QR pairing now binds token to a specific chosen surface.** Replaced the single static launch-time token with an interactive console prompt (`runPairingPrompt`, background thread so it doesn't block the WS listener's main queue): lists live surfaces via the real `.listSurfaces`, operator picks one, a fresh random token is generated bound to `{surfaceID, tabTitle, cwd, expiresAt: +15s}` (`PairingBox`, lock-guarded — written by the prompt thread, read by every connection's auth check). The token is rendered as an ASCII QR (CoreImage's built-in `CIQRCodeGenerator` — no new dependency, macOS-native) encoding a URL to `index.html?token=...`. Deliberately **not** an in-page camera scan: iOS Safari requires HTTPS for `getUserMedia`, which this spike's plain-`http://` Tailscale setup doesn't have — scanning happens in the phone's native Camera app instead (same pattern as WhatsApp Web), which opens Safari at that URL with no HTTPS requirement at all. `index.html` now reads `?token=` from `location.search` and auto-fills + auto-connects; `host` defaults to `location.hostname` (wherever the page was actually loaded from), removing the manual IP-typing step this spike needed all session.

Server-side, `attachToPairedSurface` now attaches to the *exact* surfaceID the token was bound to — `.listSurfaces().first`'s non-determinism is gone entirely; a client cannot land on, or even request, any surface other than the one an operator explicitly chose at the console. Verified: a token generated for surface A is rejected if presented after `expiresAt` (confirmed empirically — an earlier manual test round-tripped through slow shell commands in between and the token had already expired, which turned out to be genuine 15s-window enforcement, not a bug); a freshly generated token immediately attaches to precisely the chosen surface (`{"ok":"attached","surfaceID":"52CAFED7-...","tabTitle":"⠂ terminal on mobile research",...}` matched the picked option exactly). Caught and fixed a real bug during this: `readLine()` returns `nil` instantly (not blocking) when stdin isn't a real TTY (e.g. launched under `nohup` with redirected stdin), and the loop didn't distinguish that from "bad input" — busy-looped at full CPU printing "invalid choice" as fast as possible until killed. Fixed by treating `readLine() == nil` as "no interactive stdin available, exit the prompt loop" instead of retrying instantly.

**This is real interactive-terminal-only functionality now** (session picking + QR happen at a console prompt) — further testing needs `swift run MobileBridgeSpike` in an actual terminal, not a piped/backgrounded process.

### Scope

- [ ] `HarnessDaemonCore`: add a bound-to-loopback-or-LAN HTTP server (Swift `NIO`/`URLSession`-adjacent or minimal hand-rolled HTTP/1.1 — reuse whatever the daemon's networking story already has before adding a dependency) serving one static page + one WebSocket upgrade endpoint
- [ ] WebSocket message framing: reuse `IPCCodec`'s existing JSON control + binary PTY frame shapes, just tunneled over WS instead of the Unix socket
- [ ] Pairing: short-lived token shown as a QR code / text code in the macOS app (same UX reference as cmux's "Mobile Connect" and Claude Code's `claude remote-control` QR), stored in browser `localStorage` on the phone — no Keychain, since there's no native app. If reachability ever goes through anything other than direct LAN/Tailscale (see below), derive a payload-encryption key from the pairing token so the relay is a blind pipe, per the Claude Code Remote Control / Codex Remote precedent — don't rely on transport TLS alone once a third party could be operating the relay.
- [x] **Bind/reachability decided (2026-07-04): Tailscale.** Vit needs access when the phone isn't on the Mac's WiFi, which rules out LAN-only. Weighed against a Claude-Code/Codex-Remote-style dial-out relay (Mac dials out to a shared relay, phone dials the same relay): that pattern needs its own E2E-encryption-of-the-payload engineering (see Implications above) because it's built for a relay shared across many users. For Vit's own two devices, Tailscale gives the same "reachable from anywhere, no port-forward" property via a private WireGuard mesh that's already encrypted end-to-end between exactly those two devices — no relay to host, no extra crypto layer to build. Bind the bridge to loopback + the Tailscale interface only; never port-forward to the public internet (same posture as VibeTunnel's own docs). Revisit a dial-out relay only if access needs to extend beyond Vit's own Tailscale network (e.g. sharing with someone else).
- [ ] Frontend: start with a plain xterm.js-style raw terminal render (fastest path to "it works"), then layer the block/chat-card view (from `TerminalBlock`/OSC-133, P34) as a second, phone-optimized mode once the plumbing is proven
- [ ] Reconnect: WebSocket drop → resume by replaying retained scrollback (same `captureGrid`-style replay `RealPty.block(id:)` already does for F2/F3 MCP tools — reuse, don't reinvent)
- [ ] `make preview`-equivalent: a `make mobile-web` or similar dev target that starts the bridge against the existing daemon for local iteration

### Explicitly not in this MVP

- Native app shell, UIKit terminal surface, hardware-keyboard `UIKeyCommand` mapping (F4) — browser handles keyboard input already
- Push notifications (needs APNs/paid account) — web push is possible in principle on iOS 16.4+ Safari PWAs but is its own spike, not MVP
- Offline/background PTY ownership on the phone — daemon stays the only owner, matching F6's existing "daemon owns truth" principle

---

## Current Architecture Fit

### Already portable or mostly portable

| Layer | Current role | iPadOS use |
|-------|--------------|------------|
| `KouenCore` | IPC schema, commands, settings, models, keybindings, agents, remote host store | Reuse models/codecs; add network endpoint support |
| `KouenTerminalEngine` | Pure Swift VT parser and grid model | Reuse directly |
| `KouenCopyMode` | UI-agnostic copy-mode reducer | Reuse directly |
| `KouenTheme` | Theme catalog and theme document format | Reuse directly |
| `KouenDaemonCore` | PTY/session authority | Stays off-device; remote target |
| `kouen-cli` | Automation and daemon management | Stays Mac/Linux-first; may provide pairing/bootstrap helper |

### macOS-specific today

| Layer | Constraint | iPadOS path |
|-------|------------|-------------|
| `KouenApp` | AppKit, NSWindow, NSView, menus, Sparkle, service provider, launchd helper install | Do not port directly; create new mobile app shell |
| `KouenTerminalKit` | AppKit host views and `NSEvent` mapping | Create UIKit sibling: `KouenTerminalUIKit` |
| `KouenTerminalRenderer` | Metal/CoreText renderer, likely salvageable but currently macOS-hosted | Extract platform-neutral renderer core; add UIKit/CAMetalLayer or MTKView host |
| `RemoteHostsService` / `SSHTunnelManager` | Uses local SSH process and Unix socket forwarding | Replace for mobile with network endpoint, gateway, or embedded SSH strategy |
| `CLIInstaller`, `SparkleUpdater`, `LaunchAgentInstaller` | macOS install/update lifecycle | Exclude from mobile |
| File editor / Quick Look / LSP | AppKit text views, local filesystem/process assumptions | Defer; remote read-only browser later |

---

## Required Architectural Decisions

### D1: Transport model (P0 gate)

The iPad app cannot depend on spawning `ssh -N -L` or attaching to a local Unix socket. Pick one supported remote transport before UI work expands:

1. **Daemon TCP/WebSocket endpoint** — preferred for iPad UX.
   - Add authenticated network listener to daemon or companion relay.
   - Reuse existing length-prefixed IPC and binary PTY frames over TLS/WebSocket.
   - Good for App Store, pairing, reconnect, and background-friendly networking.
   - Caveat from competitive research: Blink Shell and Moshi both use **Mosh (UDP)** specifically because plain TCP/TLS handles cellular↔WiFi handoff and sleep/wake poorly. If this option is chosen, design the reconnect path with mosh-like semantics (sequence-numbered frames, idempotent resend/redraw) rather than assuming a clean TCP reconnect.

2. **Embedded SSH tunnel** — possible but higher risk.
   - Requires SSH library, key management UI, known-hosts storage, and App Store review confidence.
   - Preserves current remote mental model but expands security surface.

3. **Mac companion gateway** — viable stepping stone.
   - Mac app/CLI exposes a local-network relay to the iPad.
   - Lower daemon churn, good for first TestFlight, but weaker for Linux/server-only workflows.
   - **De-risked by precedent:** cmux (direct competitor, same AI-agent-terminal category) shipped exactly this as its first mobile milestone — Mac companion pairs an iOS app, SSH-mirrors a remote `tmux -CC` session. See Competitive Landscape above.

Decision target: choose one for MVP, document threat model, and avoid supporting all three initially.

### D2: Renderer reuse boundary (P0 gate)

Do not duplicate VT rendering logic. The goal is:

```text
KouenTerminalEngine -> TerminalFrame model -> shared Metal renderer core -> AppKit host or UIKit host
```

If `KouenTerminalRenderer` has AppKit-only color/font assumptions, introduce a small platform adapter rather than forking the renderer.

### D3: Local terminal support (explicitly deferred)

Local iPad shell sessions are out of MVP unless proven viable without private APIs and without pretending to own background PTYs like the macOS daemon. Treat local terminal as a future research track, not a dependency for remote attach.

---

## Feature Specs

### F1: Mobile Package Targets — P0

Add platform-gated targets:

- `KouenTerminalUIKit`
  - UIKit terminal host view
  - touch selection, scroll gestures, pointer hover, hardware keyboard mapping
  - consumes `KouenTerminalEngine`, `KouenCopyMode`, `KouenTheme`, `KouenTerminalRenderer`
- `KouenMobileApp`
  - iOS/iPadOS SwiftUI/UIKit app shell
  - remote host list, session browser, terminal workspace
  - no Sparkle, no launchd install, no AppKit services

Package direction:

```swift
#if os(iOS)
// KouenTerminalUIKit + KouenMobileApp
#endif
```

Keep macOS products unchanged. Do not weaken the existing Linux headless split.

### F2: Network Endpoint for IPC — P0

Add an `Endpoint` case that works on iPad:

```swift
case network(host: String, port: Int, security: NetworkSecurity)
case websocket(URL)
```

Implementation requirements:

- preserve current `IPCCodec` framing semantics
- support binary PTY output/input frames
- support reconnect with last seen surface/frame sequence where possible
- keep Unix socket path untouched for local macOS/Linux
- authenticate before exposing daemon commands
- expose precise errors: auth failed, host unreachable, incompatible daemon, unsupported transport

### F3: Pairing and Trust — P0

The iPad app needs a non-fragile trust flow:

- UX reference: cmux's "Mobile Connect" window on the desktop app (generates a pairing code, iOS companion scans/enters it) — a concrete precedent for the flow below.
- daemon or companion generates pairing code / QR code
- iPad stores host identity and token in Keychain
- daemon stores revocable client grants
- pairings are scoped by device and can be removed
- remote command permissions are explicit enough to avoid accidentally exposing shell access on LAN

Minimum daemon commands:

```bash
kouen-cli mobile pair
kouen-cli mobile list-clients
kouen-cli mobile revoke <client-id>
```

### F4: UIKit Terminal Surface — P0

Create a UIKit sibling of `TerminalHostView` and `KouenTerminalSurfaceView`:

- `UIView` / `MTKView` or `CAMetalLayer` backed rendering
- hardware keyboard input through `UIPress`, `UIKeyCommand`, and text input traits
- touch selection mapped into `KouenCopyMode`
- two-finger scrollback and inertial scrolling
- clipboard through `UIPasteboard`
- pointer interactions for iPad trackpad/mouse
- safe area and keyboard avoidance without resizing the daemon surface incorrectly

Preserve existing input boundary: UIKit maps platform events into engine/core key intent; `InputEncoder` remains AppKit-free.

### F5: iPad Workspace UX — P1

Build a mobile-native workspace, not a squeezed macOS window:

- sidebar host/session list optimized for Split View and Stage Manager
- terminal surface as the primary screen
- panes and tabs reachable through compact controls and keyboard shortcuts
- command palette adapted to iPad keyboard and touch
- remote host switcher with connection state
- agent notifications as a compact inbox, not macOS notch/panel chrome
- command menu entries for common session actions

Defer dense macOS-only surfaces:

- full settings window parity
- file editor/LSP
- git panel
- browser pane
- Sparkle/update UI
- macOS service provider workflows

### F6: Remote Session Lifecycle — P1

Support the workflows that make an iPad useful immediately:

- list remote workspaces/sessions
- attach/detach without killing sessions
- create a session on a remote host
- split panes and resize
- send keys and paste
- capture pane / copy mode
- reconnect after app backgrounding
- show daemon version mismatch clearly

The iPad app must assume the daemon owns truth. Local cached state is presentation-only.

### F7: Files and Sharing — P2

Once remote attach is stable:

- import/export `.kouentheme`
- import SSH keys or pairing bundles if the selected transport needs them
- share copied terminal text/images
- optional remote file preview through daemon-mediated read-only APIs

Do not expose arbitrary remote file browsing until the permission model is defined.

---

## Implementation Phases

**Phases 0–4 below are DEFERRED as of 2026-07-04 — blocked on Apple Developer Program membership (see Status note at top).** Work through the Web/PWA MVP section above first. Resume here only after either (a) a paid Apple Developer account is obtained, or (b) the web MVP hits a real ceiling the browser genuinely can't cross (e.g. true background PTY ownership, native push).

### Phase 0 — Feasibility Spike (P0)

- [ ] Build a small iPadOS SwiftPM/Xcode target importing `KouenCore`, `KouenTerminalEngine`, `KouenCopyMode`, and `KouenTheme`
- [ ] Compile `KouenTerminalRenderer` for iOS or list exact AppKit/CoreText blockers
- [ ] Prototype one terminal grid rendered in a UIKit/Metal view
- [ ] Choose D1 transport model and write the security model
- [ ] Confirm App Store constraints for background networking, local network permission, key storage, and remote shell access
- [ ] Define minimum supported iPadOS version based on Metal/UIKit/SwiftUI needs

Exit criteria: one rendered static terminal frame on iPad simulator/device and a written transport decision.

### Phase 1 — Shared Renderer Extraction (P0)

- [ ] Split renderer host concerns from renderer core
- [ ] Introduce platform color/font/glyph rasterization adapters only where necessary
- [ ] Keep existing macOS renderer tests passing
- [ ] Add renderer parity fixtures comparing macOS and UIKit frame output where possible
- [ ] Avoid behavior drift in ligatures, inline image cells, selection overlays, and damage tracking

Exit criteria: macOS renderer remains unchanged from the app's perspective; iOS target compiles the shared renderer core.

### Phase 2 — Mobile IPC Transport (P0)

- [ ] Add network-capable `Endpoint`
- [ ] Add `EndpointConnector` implementation for the chosen transport
- [ ] Add daemon-side listener or companion gateway
- [ ] Add pairing, token storage, revocation, and version handshake
- [ ] Add tests for frame ordering, auth failure, reconnect, and binary PTY frames over the new transport

Exit criteria: iPad test client can request `list-sessions` from a paired daemon.

### Phase 3 — UIKit Terminal MVP (P0)

- [ ] Create `KouenTerminalUIKit`
- [ ] Implement live PTY output subscription
- [ ] Implement keyboard text, arrows, modifiers, paste, resize, and detach
- [ ] Implement touch scrollback and basic selection/copy
- [ ] Add snapshot/replay handling for reconnect after backgrounding
- [ ] Add simulator/device smoke tests for blank-frame prevention

Exit criteria: iPad app attaches to one remote session, displays live output, accepts keyboard input, scrolls, and reconnects.

### Phase 4 — iPad App Shell (P1)

- [ ] Create `KouenMobileApp`
- [ ] Remote host setup and pairing UI
- [ ] Session list and attach flow
- [ ] Terminal workspace with tab/pane controls
- [ ] Command palette subset
- [ ] Agent notification inbox subset
- [ ] Settings subset: theme, font size, key behavior, host management

Exit criteria: TestFlight-quality remote terminal client for one or more paired daemons.

### Phase 5 — Multiplexer Parity (P1)

- [ ] Split pane creation/removal
- [ ] Pane focus navigation
- [ ] Session rename/close
- [ ] Copy mode parity with macOS reducer
- [ ] Resize vote behavior across background/foreground transitions
- [ ] Remote host switching without stale session bleed

Exit criteria: core multiplexer workflows from `docs/MULTIPLEXER_GUIDE.md` work from iPad.

### Phase 6 — Polish and Platform Integration (P2)

- [ ] Stage Manager and external display layout
- [ ] Pointer hover affordances
- [ ] Keyboard shortcut discoverability
- [ ] Drag/drop terminal text
- [ ] Theme import/export through Files
- [ ] Push/local notifications for agent waits if allowed by user
- [ ] Accessibility pass: Dynamic Type strategy, VoiceOver labels for controls, reduced motion

Exit criteria: iPad app feels native under touch, keyboard, and pointer usage.

---

## Testing and Verification

### Build matrix

- [ ] `swift build` on macOS still passes
- [ ] `swift build` on Linux still excludes GUI/mobile surfaces and passes headless targets
- [ ] iOS simulator build passes for `KouenTerminalUIKit`
- [ ] iPadOS app archive or Xcode build passes for `KouenMobileApp`

### Unit tests

- [ ] `KouenCoreTests`: endpoint parsing, auth models, pairing persistence, network framing
- [ ] `KouenTerminalEngineTests`: unchanged
- [ ] `KouenCopyModeTests`: reused for touch selection paths
- [ ] Renderer parity tests: frame model / damage / color conversion where testable without AppKit

### Integration tests

- [ ] Paired iPad simulator connects to local daemon gateway
- [ ] Remote Linux daemon attach
- [ ] Background app for 30+ seconds, foreground, verify no lost resize/input state
- [ ] Network drop/reconnect during output burst
- [ ] Version mismatch and auth revoke flows

### Manual test checklist

- [ ] Hardware keyboard: text, arrows, Option, Control, Command shortcuts
- [ ] Magic Keyboard / trackpad pointer
- [ ] Touch selection and copy/paste
- [ ] Split View / Stage Manager resizing
- [ ] External display if supported by target OS
- [ ] Large scrollback session
- [ ] High-throughput command output
- [ ] Agent wait notification

---

## Security Notes

- Remote terminal access is shell access. Pairing and transport auth are product-critical, not polish.
- Never expose daemon network listener unauthenticated.
- Prefer explicit bind address defaults: loopback for companion mode, opt-in LAN/server mode.
- Store secrets in Keychain on iPad and permission-restricted config on daemon hosts.
- Include daemon command allow/deny policy before adding file read/write APIs.
- Log remote client identity for session creation, input, and revocation events.

---

## Non-goals

- Native iOS/iPadOS app, App Store/TestFlight distribution, or APNs push — blocked on Apple Developer Program membership; not pursued until that changes (2026-07-04)
- Running `KouenDaemon` locally on iPad in MVP
- Porting `KouenApp` AppKit views through compatibility shims
- Sparkle/update flow on iOS/iPadOS
- Full file editor/LSP parity in the first release
- Git panel/browser pane parity in the first release
- Supporting every possible remote transport in MVP
- Replacing the macOS app architecture

---

## Risks

- Network transport and security can become larger than the UI work; keep MVP transport singular.
- Renderer extraction may reveal CoreText/AppKit coupling that needs a careful adapter layer.
- Hardware keyboard behavior differs between simulator, iPad, Magic Keyboard, and external keyboards.
- Backgrounding can break subscription semantics unless reconnect/replay is designed early.
- App Store review may scrutinize remote shell, SSH key handling, local network discovery, and executable-like workflows.
- Duplicating terminal UI behavior across AppKit and UIKit can drift; keep reducers/frame models shared.

---

## Open Questions

- ~~Is the first release iPad-only, or should iPhone compile with a reduced layout?~~ **Resolved 2026-07-04:** moot for now — Web/PWA MVP runs identically in Safari on either device; native-only question deferred with Phase 0–4.
- Should the mobile client render a literal terminal grid as the only mobile UI, or should a block/chat-aware view (per `TerminalBlock` from P34) be the primary experience? Moshi and Claude Code Remote Control both chose block/chat-aware for phone — Web/PWA MVP scope above plans to build raw-grid first, then layer this in.
- **Distribution:** ~~is TestFlight enough for early users?~~ **Resolved 2026-07-04:** no Apple Developer account exists; MVP is Web/PWA specifically to avoid this question until/unless a paid account is obtained.
- Should pairing be daemon-native or Mac-app-companion-first?
- Should the network transport be raw TLS, WebSocket, or HTTPS upgrade?
- Does remote daemon need multi-client permissions beyond all-or-nothing shell access?
- What is the minimum acceptable offline behavior when no daemon is reachable?

---

## First Implementation Slice

1. Create a throwaway iPadOS spike target that imports pure shared packages.
2. Render one static `TerminalFrame` through a UIKit-hosted Metal surface.
3. Add a tiny paired network proof-of-concept that calls `daemon-stats`.
4. Decide transport based on the spike, then replace the throwaway target with real `KouenTerminalUIKit` and `KouenMobileApp` targets.

