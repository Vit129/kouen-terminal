// `Network` (and CoreImage, used only for the QR ascii art) are Apple-platform only —
// this whole bridge is unavailable on the Linux headless daemon build. Guarded here,
// not by moving the file, so it stays alongside the rest of KouenDaemonCore.
#if canImport(Network)
import CoreImage
import CryptoKit
import Foundation
import KouenCore
import KouenSettings
import Network

// P25 W1: WS<->daemon mobile bridge, originally proven as `Spikes/MobileBridgeSpike`
// (single console-picked surface, single-use token), now relocated into KouenDaemonCore
// (slice 1), backed by a persistent multi-device `PairedDeviceStore` (slice 2/2b), and
// multiplexed per the session-switcher design (slice 3, this revision):
// `agent-memory/plans/p25-mobile-session-switcher-design.html`. A pairing token now
// grants the whole daemon, not one surface — the client picks a session (or spawns one)
// after connecting via a small JSON control protocol, all on one WS connection.
//
// Wire contract (client <-> bridge, once WS-upgraded):
//   1. Client sends the pairing token as a single TEXT frame.
//   2. On success, bridge sends `{"sessions":[{surfaceID,tabTitle,cwd}, ...]}` (TEXT).
//   3. Client sends control messages as TEXT/JSON: `{"attach":"<surfaceID>"}`,
//      `{"detach":true}`, `{"spawn":{"cwd":"..."}}` (cwd optional), `{"resize":{"cols":N,
//      "rows":N}}` (P37 Phase C — only meaningful while attached).
//   4. Once attached, PTY output arrives as BINARY frames; the client sends keystrokes
//      back as BINARY frames (TEXT frames are always parsed as control messages, never
//      as input — this is how the two are told apart on one connection).
//
// Opt-in only: disabled unless KOUEN_MOBILE_BRIDGE_PORT is set in the daemon's
// environment. Binds loopback + the Tailscale interface only (never all interfaces),
// per the Web/PWA MVP's already-decided reachability posture in the plan doc above.
public final class MobileBridgeServer: @unchecked Sendable {
    // Was 15s, then 45s; real-device testing PROVED (controlled live experiment: grab token,
    // wait past one rotation, resend → "invalid or expired pairing token") that the phone
    // holds the token embedded in its page URL at load time while the server rotated past it.
    // Tailscale first-connect latency + camera→browser handoff + a manual Connect tap + any
    // retaps routinely cross a rotation boundary. 120s cuts how many rotations a human flow
    // can straddle; `PairingBox` also now accepts the just-rotated-out token for one extra
    // window (grace), so a single boundary crossing is a non-event regardless. Together these
    // fix the bug without weakening the shoulder-surf expiry (a truly old QR still dies). The
    // A1 lockout (5 attempts/window) stays the only real brute-force constraint.
    private let pairingLifetime: TimeInterval = 120
    private let pairingBox: PairingBox
    /// P37 A3: one dedicated serial queue for every listener accept AND every connection's
    /// send/receive callbacks — moves the whole bridge off the daemon's `.main` queue so a
    /// flooding/slow mobile peer can't stall the GUI's PTY relay. Serial (not concurrent):
    /// per-connection frame ordering is load-bearing (control-vs-input demux, PTY byte
    /// order), and one serial queue preserves it without per-connection locking.
    private let bridgeQueue = DispatchQueue(label: "com.vit129.kouen.mobile-bridge")
    private var listeners: [NWListener] = []
    private var store: PairedDeviceStore?
    private let liveConnectionsLock = NSLock()
    private var liveConnections: [String: NWConnection] = [:]
    /// Retained from `start()` so the receive loop can log a lockout (P37 A1) from off the
    /// pairing-loop thread. Set once, before any connection is accepted.
    private var log: (@Sendable (String) -> Void)?
    /// P37 B2 (plan risk R4): bind hosts whose WS listener is currently `.ready`, keyed by
    /// host so a late `.failed` only clears its own entry. When this is empty the pairing URL
    /// is withheld from `currentPairingInfo` — the Settings panel then shows "not listening"
    /// instead of a QR that could never work (the silent-port-squat failure W1 already hit).
    /// Own lock (not `liveConnectionsLock`): touched from listener state callbacks on
    /// `bridgeQueue` AND from IPC reads on the daemon queue.
    private let wsReadyLock = NSLock()
    private var wsReadyHosts: Set<String> = []

    /// Lets `start()`/`stop()` be called repeatedly on the same instance — the daemon now
    /// owns one `MobileBridgeServer` for its whole lifetime and starts/stops it in place from
    /// `.setMobileBridgeEnabled` (Settings toggle), instead of a full daemon restart minting a
    /// fresh instance each time. Also the cancellation flag `runPairingLoop` polls between
    /// token rotations, since its sleep can no longer just run forever.
    private let lifecycleLock = NSLock()
    private var _isRunning = false
    private var isRunning: Bool {
        get { lifecycleLock.lock(); defer { lifecycleLock.unlock() }; return _isRunning }
        set { lifecycleLock.lock(); _isRunning = newValue; lifecycleLock.unlock() }
    }

    private func setWSListener(host: String, ready: Bool) {
        wsReadyLock.lock()
        if ready { wsReadyHosts.insert(host) } else { wsReadyHosts.remove(host) }
        wsReadyLock.unlock()
    }

    private var anyWSListenerReady: Bool {
        wsReadyLock.lock()
        defer { wsReadyLock.unlock() }
        return !wsReadyHosts.isEmpty
    }

    public init() {
        pairingBox = PairingBox(maxAttempts: maxTokenAttempts, graceWindow: pairingLifetime)
    }

    /// Whether a teardown for `torndown` should remove `deviceID`'s `liveConnections` entry —
    /// true only if that entry is STILL `torndown` (reference identity), i.e. no newer
    /// connection has already replaced it via `registerLive`. `NWConnection` is a class, so
    /// `===` is exactly the right comparison. Extracted as a pure, static, `internal` (not
    /// `private`) function purely so this guard is unit-testable without a live listener —
    /// same testability convention `PendingPairing`/`PairingBox` document above.
    static func shouldRemoveLiveEntry(current: NWConnection?, torndown: NWConnection) -> Bool {
        current === torndown
    }

    private func cancelConnection(forDeviceID id: String) {
        liveConnectionsLock.lock()
        let connection = liveConnections.removeValue(forKey: id)
        liveConnectionsLock.unlock()
        connection?.cancel()
    }

    /// P37 A1: how many wrong token attempts (across ALL connections) burn through the
    /// current pairing window before the bridge refuses further token auth until the next
    /// token rotates. Device re-auth (`{deviceAuth}`) is unaffected — a returning device
    /// still reconnects during a lockout.
    private let maxTokenAttempts = 5

    /// Slowloris guard for both listeners (page + WS) — a peer that never sends its first
    /// byte (page: the GET line; WS: the connection is created and this starts counting
    /// immediately, before the WS upgrade handshake even completes — see its use site) gets
    /// dropped after this. Was 5s; too tight for the WS listener specifically once a real
    /// phone tested over a Tailscale connection still doing DERP-relay/NAT-traversal
    /// negotiation on its first connection — that adds real round-trip latency BEFORE the
    /// WS upgrade handshake, browser `onopen`, and the client's first token frame can all
    /// complete, unlike the page listener's window (which only starts once TCP is already
    /// `.ready`, and needs just one more simple GET+response over an already-warm path).
    private let preAuthTimeout: TimeInterval = 15

    /// No longer bound to one surface (see the session-switcher design) — a redeemed
    /// token grants the whole daemon; the client picks/spawns a session afterward. Carries
    /// its own pairing `url` (P37 B1) so the in-app QR panel can read the live URL over IPC
    /// without re-deriving it. Internal (not private) only so the A1 lockout logic is
    /// unit-testable without a live listener.
    struct PendingPairing {
        let token: String
        let url: String
        let expiresAt: Date
    }

    /// Result of checking a submitted token against the pairing state — `.accepted`, or the
    /// reason it was refused so the caller can log a real device's failure precisely (a stale
    /// token and a wrong token look identical from the client's side but are different bugs).
    enum TokenCheck: Equatable { case accepted, expired, mismatch, noActivePairing }

    /// `@unchecked Sendable` with an explicit lock: written by the pairing-loop thread,
    /// read by every WS connection's receive-callback chain. Also owns the P37 A1 failed-
    /// attempt counter, guarded by the SAME lock so a burst of parallel guessing connections
    /// can't race past the limit (the whole point of the limit). Internal for the same
    /// testability reason as `PendingPairing`.
    final class PairingBox: @unchecked Sendable {
        private let lock = NSLock()
        private var _current: PendingPairing?
        /// The token that most recently rotated OUT, kept redeemable for `graceWindow` past
        /// its rotation. Proven root cause (P37): a real phone holds the token embedded in
        /// its page URL at load time, but the server rotated past it and accepted ONLY the
        /// single current token, so every attempt bounced as "expired". Accepting current OR
        /// the just-rotated-out previous makes any single rotation boundary a non-event,
        /// while a genuinely old QR (2+ rotations back) still dies — shoulder-surf expiry
        /// intact.
        private var _previous: PendingPairing?
        private var _previousValidUntil: Date?
        private var _failedAttempts = 0
        private let maxAttempts: Int
        private let graceWindow: TimeInterval
        init(maxAttempts: Int, graceWindow: TimeInterval) {
            self.maxAttempts = maxAttempts
            self.graceWindow = graceWindow
        }
        /// Setting a new token (rotation) shifts the outgoing one into the grace slot and
        /// resets the lockout — a fresh window gets a fresh budget, which is exactly the
        /// "until the next token rotates" release condition.
        var current: PendingPairing? {
            get { lock.lock(); defer { lock.unlock() }; return _current }
            set {
                lock.lock()
                if let outgoing = _current {
                    _previous = outgoing
                    _previousValidUntil = Date().addingTimeInterval(graceWindow)
                }
                _current = newValue
                _failedAttempts = 0
                lock.unlock()
            }
        }
        /// Fully clears all pairing state. `stop()` uses this instead of `current = nil` — a
        /// stopped bridge must not leave the last token redeemable through the grace slot.
        func clear() {
            lock.lock()
            _current = nil; _previous = nil; _previousValidUntil = nil; _failedAttempts = 0
            lock.unlock()
        }
        var isLockedOut: Bool {
            lock.lock(); defer { lock.unlock() }
            return _failedAttempts >= maxAttempts
        }
        /// Constant-time check of `token` against the current token (within its `expiresAt`)
        /// OR the just-rotated-out previous token (within its grace window). Returns the
        /// refusal reason rather than a bare Bool so the caller logs *why* a device bounced.
        func check(_ token: String) -> TokenCheck {
            lock.lock(); defer { lock.unlock() }
            guard _current != nil || _previous != nil else { return .noActivePairing }
            let now = Date()
            let bytes = Array(token.utf8)
            var matchedButLapsed = false
            if let cur = _current, constantTimeEquals(Array(cur.token.utf8), bytes) {
                if now < cur.expiresAt { return .accepted }
                matchedButLapsed = true
            }
            if let prev = _previous, constantTimeEquals(Array(prev.token.utf8), bytes) {
                if let until = _previousValidUntil, now < until { return .accepted }
                matchedButLapsed = true
            }
            return matchedButLapsed ? .expired : .mismatch
        }
        /// Records one wrong-token attempt. Returns true only on the transition INTO
        /// lockout (the Nth failure), so the caller logs the lockout exactly once.
        func recordFailure() -> Bool {
            lock.lock(); defer { lock.unlock() }
            guard _failedAttempts < maxAttempts else { return false }
            _failedAttempts += 1
            return _failedAttempts == maxAttempts
        }
    }

    /// `@unchecked Sendable` with an explicit lock: mutated both from the WS receive chain
    /// (listener queue) and the background queue performing (blocking) daemon calls.
    private final class ConnectionState: @unchecked Sendable {
        private let lock = NSLock()
        private var _authorized = false
        private var _surfaceID: String?
        private var _subscription: DaemonSubscription?
        private var _deviceID: String?
        /// Found via Agy + Opus verification: `handleControlMessage` used to dispatch
        /// `handleAttach`/`handleSpawn` onto the shared `DispatchQueue.global()`, and
        /// `receiveLoop` re-arms the next receive immediately without waiting for that work to
        /// finish — two attach frames sent back-to-back on ONE connection could then run
        /// `handleAttach` concurrently and interleave its read-nil-cancel-recreate sequence,
        /// leaking a subscription that kept writing to the socket alongside the new one. The
        /// fix is NOT to hold `ConnectionState`'s lock across the blocking `DaemonClient` IPC
        /// calls inside `handleAttach`/`handleSpawn` (that's the anti-pattern this codebase's
        /// locking discipline forbids) — it's to serialize per-connection control-message
        /// handling on its own private queue, one per connection, so order is preserved
        /// without any lock spanning a blocking call.
        let controlQueue = DispatchQueue(label: "com.vit129.kouen.mobile-bridge.control")
        var authorized: Bool {
            get { lock.lock(); defer { lock.unlock() }; return _authorized }
            set { lock.lock(); _authorized = newValue; lock.unlock() }
        }
        /// The surface currently attached on this connection, if any — nil between
        /// `{"detach"}` and the next `{"attach":...}`.
        var surfaceID: String? {
            get { lock.lock(); defer { lock.unlock() }; return _surfaceID }
            set { lock.lock(); _surfaceID = newValue; lock.unlock() }
        }
        var subscription: DaemonSubscription? {
            get { lock.lock(); defer { lock.unlock() }; return _subscription }
            set { lock.lock(); _subscription = newValue; lock.unlock() }
        }
        /// Live for the WHOLE connection (auth → disconnect), unlike `subscription` above which
        /// is per-attach and gets replaced/cleared on every attach/detach. Pushes a fresh session
        /// list to the phone whenever the daemon's snapshot revision bumps (new tab, another
        /// device spawning a session, etc.) — without this, an already-connected mobile page only
        /// ever sees the one-time list sent right after auth and needs a reconnect to catch up.
        var snapshotSubscription: DaemonSubscription? {
            get { lock.lock(); defer { lock.unlock() }; return _snapshotSubscription }
            set { lock.lock(); _snapshotSubscription = newValue; lock.unlock() }
        }
        private var _snapshotSubscription: DaemonSubscription?
        /// Set once, at authorization — the id `PairedDeviceStore` tracks this
        /// connection under, so a `mobile-revoke-client` can cancel it specifically.
        var deviceID: String? {
            get { lock.lock(); defer { lock.unlock() }; return _deviceID }
            set { lock.lock(); _deviceID = newValue; lock.unlock() }
        }
        /// Raw bytes read but not yet consumed into a complete WS frame — only ever touched
        /// from `bridgeQueue` (the receive loop's recursive callback chain), so plain state,
        /// no lock, same reasoning as `respondedOrGone` elsewhere in this file.
        var frameBuffer = Data()
        /// Set once a plain (non-WS) request got its page response — lets the shared
        /// pre-auth watchdog tell "answered a page request" apart from "never sent
        /// anything," without needing a second `RespondedFlag`-style wrapper.
        var pageServed = false
        /// Opcode + accumulated payload of an in-progress fragmented message (a FIN=0 frame
        /// followed by CONTINUATION frames) — nil between messages. Only text/binary start
        /// frames fragment in practice; ping/pong/close are always sent as single frames.
        var fragmentedOpcode: UInt8?
        var fragmentedPayload = Data()
        /// Temporary diagnostic (P37 real-device WS debugging) — gates the one-shot
        /// first-frame log in `handleFrame`.
        var loggedFirstFrame = false
        /// P37 Phase D3 (browser mirror). The GUI's `BrowserPaneView` tab this connection is
        /// mirroring, if any — nil until the first `{"browserNavigate"}` opens one (`.browserOpen`
        /// IPC, no `paneID` yet), set from the `.open(paneID:)` response, then reused for every
        /// subsequent navigate/snapshot/interact/screenshot on this connection.
        var browserPaneID: UUID? {
            get { lock.lock(); defer { lock.unlock() }; return _browserPaneID }
            set { lock.lock(); _browserPaneID = newValue; lock.unlock() }
        }
        private var _browserPaneID: UUID?
    }

    /// The pairing page, served by this process itself (see `makeUnifiedListener`) — not a
    /// separate file some other HTTP server has to host. Single source of truth: this used
    /// to be `Scripts/mobile-web-test.html` served by a standalone `python3 -m http.server`
    /// the dev script (`mobile-web.sh`) spun up alongside the daemon; that only ever existed
    /// in the dev flow, so the production/preview daemon (spawned by `DaemonLauncher`,
    /// no such script involved) printed a pairing URL nothing was listening on — confirmed
    /// via a direct `curl` against a real `make preview` daemon returning connection refused.
    /// P37 Phase C (W3): the real client, replacing the old bare-bones smoke-test page —
    /// xterm.js terminal (real ANSI/cursor rendering) + the session-switcher UI from
    /// `agent-memory/plans/p25-mobile-session-switcher-design.html` (dark terminal aesthetic,
    /// session list, switcher sheet). Resize now round-trips: `FitAddon` measures the
    /// container, the client sends `{"resize":{cols,rows}}`, `handleControlMessage` forwards
    /// it to `DaemonClient.resize`.
    private static let embeddedPageHTML = #"""
    <!doctype html>
    <title>Kouen Mobile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <style>
    \#(MobileBridgeWebAssets.xtermCSS)
    </style>
    <style>
      :root {
        --bg: #100d0b; --surface: #1a1613; --surface-3: #241f1b;
        --text: #ede8e2; --muted: #9b8f80; --border: #322a23;
        --accent: #d77757; --accent-cyan: #5ec4c1; --live: #7fb878;
        --code-font: ui-monospace, "SF Mono", Menlo, Consolas, monospace;
        --ui-font: -apple-system, "SF Pro Text", system-ui, sans-serif;
      }
      * { box-sizing: border-box; }
      html, body { height: 100%; margin: 0; }
      body {
        background: var(--bg); color: var(--text); font-family: var(--ui-font);
        display: flex; flex-direction: column; overflow: hidden;
      }
      .view { flex: 1; display: none; flex-direction: column; min-height: 0; }
      .view.active { display: flex; }

      #view-home, #view-paired {
        align-items: center; justify-content: center; text-align: center; padding: 0 2rem; gap: 1rem;
      }
      .mark { font-family: var(--code-font); font-size: 1.6rem; color: var(--accent); }
      #view-home h4, #view-paired h4 { margin: 0; font-size: 1rem; font-weight: 600; }
      #view-home p, #view-paired p { margin: 0; color: var(--muted); font-size: 0.85rem; max-width: 26ch; }
      #token {
        font: inherit; font-family: var(--code-font); text-align: center; letter-spacing: 0.1em;
        background: var(--surface-3); border: 1px solid var(--border); color: var(--text);
        border-radius: 8px; padding: 0.6rem 0.8rem; width: 10rem;
      }
      .btn {
        appearance: none; border: none; cursor: pointer; background: var(--accent); color: #100d0b;
        font-family: var(--ui-font); font-weight: 600; font-size: 0.9rem;
        padding: 0.65rem 1.3rem; border-radius: 20px; margin-top: 0.4rem;
      }
      .btn:focus-visible { outline: 2px solid var(--accent-cyan); outline-offset: 2px; }
      .check {
        width: 44px; height: 44px; border-radius: 50%; background: var(--live); color: #0a0807;
        display: flex; align-items: center; justify-content: center; font-size: 1.3rem; font-weight: 700;
      }

      .list-header {
        padding: 0.9rem 1.1rem 0.8rem; border-bottom: 1px solid var(--surface-3); flex-shrink: 0;
        display: flex; align-items: flex-end; justify-content: space-between; gap: 0.6rem;
      }
      .list-header .host { font-family: var(--code-font); font-size: 0.68rem; color: var(--muted); letter-spacing: 0.03em; }
      .list-header h4 { margin: 0.15rem 0 0; font-size: 1.05rem; }
      .list-header-text { min-width: 0; }
      .sessions { flex: 1; overflow-y: auto; padding: 0.6rem 0.8rem; display: flex; flex-direction: column; gap: 0.5rem; }
      .session-card {
        display: flex; align-items: center; gap: 0.7rem; background: var(--surface); border: 1px solid var(--surface-3);
        border-radius: 12px; padding: 0.7rem 0.8rem; cursor: pointer; text-align: left; width: 100%;
        color: inherit; font-family: inherit;
      }
      .session-card:focus-visible { outline: 2px solid var(--accent-cyan); outline-offset: 1px; }
      .session-card .glyph { color: var(--accent); font-size: 1rem; width: 1.1rem; flex-shrink: 0; }
      .session-card .meta { min-width: 0; flex: 1; }
      .session-card .title { font-size: 0.87rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
      .session-card .cwd { font-family: var(--code-font); font-size: 0.7rem; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-top: 0.15rem; }
      .pill { flex-shrink: 0; width: 7px; height: 7px; border-radius: 50%; background: var(--live); }
      .empty { color: var(--muted); font-size: 0.85rem; text-align: center; padding: 2rem 1rem; }

      .add-btn {
        appearance: none; border: none; cursor: pointer; flex-shrink: 0; width: 30px; height: 30px; border-radius: 50%;
        background: var(--surface-3); color: var(--text); font-size: 1.1rem; line-height: 1;
        display: flex; align-items: center; justify-content: center;
      }
      .add-btn:active { transform: scale(0.94); }

      .term-header {
        display: flex; align-items: center; gap: 0.6rem; padding: 0.5rem 0.7rem;
        border-bottom: 1px solid var(--surface-3); flex-shrink: 0;
      }
      .iconbtn { appearance: none; background: none; border: none; color: var(--text); font-size: 1.1rem; padding: 0.2rem 0.4rem; cursor: pointer; line-height: 1; }
      .term-header .title { font-size: 0.85rem; font-weight: 600; flex: 1; min-width: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
      #term-body { flex: 1; min-height: 0; overflow: hidden; padding: 0.4rem; background: #100d0b; }
      #xterm-container { height: 100%; }
      /* Base state: hidden everywhere, including phone (<768px), which never had a base rule of
         its own before this fix — the only `display` rule lived inside the tablet media query,
         so this tablet-only "select a session" label was rendering above the live terminal on
         every phone session too. Found via code review. Tablet's own visible state
         (`body.tablet-unattached #term-empty`) still lives in the media query below. */
      #term-empty { display: none; }

      /* P37 Phase F2: quick-tap row for keys the iOS soft keyboard doesn't expose (Esc/Tab/Ctrl
         combos/arrows) — pinned above the keyboard, same idea Termius/Blink Shell ship. Hidden
         via the same `tablet-unattached` class the terminal itself uses (set on load, cleared by
         mountTerminal, added back by disposeTerminal) so it only shows while a session is live. */
      .kbd-toolbar {
        display: flex; gap: 0.4rem; padding: 0.4rem 0.6rem; overflow-x: auto; flex-shrink: 0;
        background: var(--surface); border-top: 1px solid var(--surface-3);
      }
      .kbd-toolbar button {
        appearance: none; border: 1px solid var(--border); background: var(--surface-3); color: var(--text);
        border-radius: 6px; padding: 0.35rem 0.7rem; font-size: 0.78rem; font-family: var(--code-font);
        cursor: pointer; flex-shrink: 0; line-height: 1;
      }
      .kbd-toolbar button:active { background: var(--accent); color: #100d0b; }
      body.tablet-unattached .kbd-toolbar { display: none; }

      /* P37 Phase G2: shell tab-completion suggestion strip — shared component, G3's AI
         suggestion reuses this same class rather than a second near-identical strip. Hidden by
         default; JS toggles `.show` only when a detection actually fires. */
      .suggest-strip {
        display: none; gap: 0.4rem; padding: 0.4rem 0.6rem; overflow-x: auto; flex-shrink: 0;
        background: var(--surface); border-top: 1px solid var(--surface-3);
      }
      .suggest-strip.show { display: flex; }
      .suggest-strip button {
        appearance: none; border: 1px solid var(--accent); background: var(--surface-3); color: var(--accent-cyan);
        border-radius: 6px; padding: 0.35rem 0.7rem; font-size: 0.78rem; font-family: var(--code-font);
        cursor: pointer; flex-shrink: 0; line-height: 1;
      }
      body.tablet-unattached .suggest-strip { display: none !important; }
      .suggest-loading { padding: 0.35rem 0.7rem; font-size: 0.78rem; color: var(--muted); font-family: var(--code-font); }

      .sheet-backdrop {
        position: fixed; inset: 0; background: rgba(0,0,0,0.45); opacity: 0; pointer-events: none;
        transition: opacity 0.2s ease; z-index: 5;
      }
      .sheet-backdrop.open { opacity: 1; pointer-events: auto; }
      .sheet {
        position: fixed; left: 0; right: 0; bottom: 0; background: var(--surface);
        border-radius: 18px 18px 0 0; border-top: 1px solid var(--border);
        transform: translateY(100%); transition: transform 0.25s ease; max-height: 70%;
        display: flex; flex-direction: column; z-index: 6;
      }
      .sheet.open { transform: translateY(0); }
      .sheet-handle { width: 32px; height: 4px; background: var(--border); border-radius: 2px; margin: 0.6rem auto; flex-shrink: 0; }
      .sheet .list-header { padding: 0 0.4rem 0.6rem; border-bottom: none; }

      .error-banner {
        position: fixed; top: 0; left: 0; right: 0; background: #c0392b; color: #fff; font-size: 0.8rem;
        padding: 0.5rem 1rem; text-align: center; z-index: 10; display: none;
      }
      .error-banner.show { display: block; }


      /* P37 Phase D2: the attach affordance is a leading row in the files sheet, not a 4th
         toolbar icon (the header already has back/title/files/switch — no room to spare on a
         narrow phone) — same call the design mockup landed on. */
      .attach-row {
        display: flex; align-items: center; gap: 0.7rem; background: transparent; border: 1px dashed var(--border);
        border-radius: 12px; padding: 0.65rem 0.75rem; width: calc(100% - 1.6rem); margin: 0.6rem 0.8rem 0;
        color: var(--accent); font-family: inherit; font-weight: 600; font-size: 0.85rem; flex-shrink: 0;
      }
      .attach-row .glyph { width: 1.1rem; text-align: center; flex-shrink: 0; }

      /* P37 Phase D3 (browser mirror) — deliberately minimal chrome for this MVP, NOT the
         tab-strip/webview redesign (that's a separate, larger, not-yet-built phase). */
      .browser-toolbar {
        display: flex; gap: 0.5rem; padding: 0.5rem 0.7rem; border-bottom: 1px solid var(--surface-3); flex-shrink: 0;
      }
      .browser-toolbar button {
        appearance: none; border: 1px solid var(--border); background: var(--surface); color: var(--muted);
        border-radius: 8px; padding: 0.3rem 0.6rem; font-size: 0.72rem; font-family: inherit; cursor: pointer;
      }
      /* Retargeted from D1's #file-body (Phase E folded the single-file view into this shared
         preview pane) rather than left dead — deleting outright would have shipped file-preview
         text with no padding/code-font/wrap, falling back to the browser's bare <pre> default. */
      #preview-body { flex: 1; min-height: 0; overflow: auto; padding: 0.8rem; }
      #preview-body pre {
        margin: 0; font-family: var(--code-font); font-size: 0.8rem; white-space: pre-wrap;
        word-break: break-word; color: var(--text);
      }
      #preview-body img { max-width: 100%; display: block; border-radius: 8px; }
      #preview-body .empty { padding-top: 2rem; }
      .browser-el {
        display: flex; flex-direction: column; gap: 0.1rem; padding: 0.6rem 0.8rem;
        border-bottom: 1px solid var(--surface-3); text-align: left; width: 100%; background: none; border-left: none; border-right: none; border-top: none;
        color: inherit; font-family: inherit;
      }
      .browser-el .tag { font-family: var(--code-font); font-size: 0.65rem; color: var(--accent-cyan); }
      .browser-el .label { font-size: 0.82rem; }

      /* P37 Phase E: preview chrome (tab strip + webview toolbar), ported visually from the
         desktop's own FileTabPillView (pill tabs, accent top-edge on active) and BrowserPaneView's
         toolbar (back/forward/reload/path field) — reusing this page's existing tokens, not new
         ones. Locked design: tab-strip replaces D1's single #view-file and D3's single #view-browser
         with one shared pane type; nav buttons are only meaningful (and only shown) on a browser tab. */
      .tabstrip {
        display: flex; gap: 1px; padding: 4px 6px 0; border-bottom: 1px solid var(--surface-3);
        overflow-x: auto; flex-shrink: 0; background: var(--surface);
      }
      .filetab {
        display: flex; align-items: center; gap: 5px; height: 26px; padding: 0 6px 0 10px;
        border-radius: 5px 5px 0 0; font-size: 0.72rem; color: var(--muted); white-space: nowrap;
        flex-shrink: 0; cursor: pointer;
      }
      .filetab.active { background: var(--bg); color: var(--text); box-shadow: inset 0 1px 0 var(--accent); font-weight: 600; }
      .filetab .x { opacity: 0.6; font-size: 0.65rem; margin-left: 2px; }
      .webbar {
        display: flex; align-items: center; gap: 6px; padding: 6px 8px; background: var(--bg);
        border-bottom: 1px solid var(--surface-3); flex-shrink: 0;
      }
      .webbar .nav { color: var(--muted); font-size: 0.9rem; cursor: pointer; padding: 0 2px; }
      .webbar .nav.hidden-nav { visibility: hidden; }
      .webbar .reload { color: var(--muted); font-size: 0.78rem; cursor: pointer; }
      #preview-pathfield {
        flex: 1; min-width: 0; font: inherit; font-family: var(--code-font); font-size: 0.72rem;
        background: var(--surface); border: 1px solid var(--surface-3); color: var(--text);
        border-radius: 6px; padding: 3px 9px;
      }
      #preview-pathfield[readonly] { color: var(--muted); background: var(--surface-3); }

      /* ---- Tablet (>=768px): persistent session rail, replacing the phone's full-screen
         list view + bottom switcher sheet. Additive only — the <768px phone layout below
         this breakpoint is untouched. */
      #app-layout { display: flex; flex: 1; min-height: 0; }
      #main-content { flex: 1; display: flex; flex-direction: column; min-width: 0; }
      #tablet-rail { display: none; }
      @media (min-width: 768px) {
        #tablet-rail {
          display: flex; flex-direction: column; width: 260px; flex-shrink: 0;
          border-right: 1px solid var(--surface-3); background: var(--bg); position: relative;
        }
        #tablet-rail.collapsed { width: 40px; align-items: center; padding-top: 0.7rem; }
        #tablet-rail.collapsed .list-header, #tablet-rail.collapsed .sessions { display: none; }
        #rail-collapse-btn {
          appearance: none; background: none; border: none; color: var(--muted); font-size: 1rem;
          padding: 0.3rem; cursor: pointer; line-height: 1; position: absolute; top: 0.6rem; right: 0.5rem;
        }
        #tablet-rail.collapsed #rail-collapse-btn { position: static; margin: 0 auto; }
        /* Opening a file/browser tab is a full-screen takeover on tablet too — rail hidden,
           same as the terminal it replaces (locked design, frame 06). */
        body.preview-active #tablet-rail { display: none; }
        body.tablet-unattached #term-empty { display: flex; }
        body.tablet-unattached #xterm-container { display: none; }
      }
    </style>

    <div id="app-layout">
      <div id="tablet-rail">
        <div class="list-header">
          <div class="list-header-text">
            <div class="host" id="rail-host"></div>
            <h4 id="rail-count">0 sessions</h4>
          </div>
          <button class="add-btn" onclick="spawnSession()" aria-label="New session">+</button>
        </div>
        <div class="sessions" id="sessions-rail"></div>
        <button class="iconbtn" id="rail-collapse-btn" onclick="toggleRailCollapse()" aria-label="Collapse sidebar">&#8676;</button>
      </div>

      <div id="main-content">
        <div id="view-home" class="view active">
          <div class="mark">⌁ kouen</div>
          <h4>Not paired</h4>
          <p>Open this page via the QR code shown in Kouen's Settings ▸ Remote panel.</p>
          <input id="token" placeholder="or paste code" autocomplete="off" inputmode="numeric">
          <button class="btn" onclick="connect()">Connect</button>
        </div>

        <div id="view-paired" class="view">
          <div class="check">&#10003;</div>
          <h4>Paired</h4>
          <p id="paired-sub"></p>
        </div>

        <div id="view-list" class="view">
          <div class="list-header">
            <div class="list-header-text">
              <div class="host" id="list-host"></div>
              <h4 id="list-count">0 sessions</h4>
            </div>
            <button class="add-btn" onclick="spawnSession()" aria-label="New session">+</button>
          </div>
          <div class="sessions" id="sessions-main"></div>
        </div>

        <div id="view-term" class="view">
          <div class="term-header">
            <button class="iconbtn" onclick="detach()" aria-label="Back to sessions">&larr;</button>
            <div class="title" id="term-title">—</div>
            <button class="iconbtn" onclick="openFilesSheet()" aria-label="Browse files">&#128193;</button>
            <button class="iconbtn" onclick="openBrowserView()" aria-label="Browse the web">&#127760;</button>
            <button class="iconbtn" onclick="openSheet()" aria-label="Switch session">&#8645;</button>
          </div>
          <div id="term-body">
            <div id="term-empty" class="empty">Select a session from the sidebar</div>
            <div id="xterm-container"></div>
          </div>
          <div class="suggest-strip" id="completion-strip"></div>
          <div class="kbd-toolbar" id="kbd-toolbar">
            <button onclick="sendKeySeq('\x1b')" aria-label="Escape">Esc</button>
            <button onclick="sendTab()" aria-label="Tab">Tab</button>
            <button onclick="sendKeySeq('\x03')" aria-label="Ctrl-C">^C</button>
            <button onclick="sendKeySeq('\x04')" aria-label="Ctrl-D">^D</button>
            <button onclick="sendKeySeq('\x1b[A')" aria-label="Up arrow">&uarr;</button>
            <button onclick="sendKeySeq('\x1b[B')" aria-label="Down arrow">&darr;</button>
            <button onclick="sendKeySeq('\x1b[D')" aria-label="Left arrow">&larr;</button>
            <button onclick="sendKeySeq('\x1b[C')" aria-label="Right arrow">&rarr;</button>
            <button onclick="openFilesPicker()" aria-label="Insert file path">@</button>
            <button onclick="requestAISuggestion()" aria-label="Suggest a command">AI</button>
          </div>
        </div>

        <div id="view-preview" class="view">
          <div class="term-header">
            <button class="iconbtn" onclick="closePreview()" aria-label="Back to terminal">&larr;</button>
            <div class="title" id="preview-title">—</div>
          </div>
          <div class="tabstrip" id="preview-tabstrip"></div>
          <div class="webbar">
            <span class="nav" id="preview-back" onclick="previewNavBack()">&#8249;</span>
            <span class="nav" id="preview-forward" onclick="previewNavForward()">&#8250;</span>
            <span class="reload" id="preview-reload" onclick="previewNavReload()">&#8635;</span>
            <input id="preview-pathfield" autocomplete="off" autocapitalize="off" spellcheck="false">
          </div>
          <div class="browser-toolbar" id="preview-browser-toolbar">
            <button onclick="browserRefreshSnapshot()">Refresh elements</button>
            <button onclick="browserRefreshFrame()">Refresh screenshot</button>
          </div>
          <div id="preview-body"></div>
        </div>
      </div>
    </div>

    <div class="sheet-backdrop" id="sheet-backdrop" onclick="closeSheet()">
      <div class="sheet" id="sheet" onclick="event.stopPropagation()">
        <div class="sheet-handle"></div>
        <div class="list-header">
          <div class="list-header-text"><h4 id="sheet-count" style="font-size:0.9rem;">0 sessions</h4></div>
          <button class="add-btn" onclick="spawnSession()" aria-label="New session">+</button>
        </div>
        <div class="sessions" id="sessions-sheet"></div>
      </div>
    </div>

    <div class="sheet-backdrop" id="files-sheet-backdrop" onclick="closeFilesSheet()">
      <div class="sheet" id="files-sheet" onclick="event.stopPropagation()">
        <div class="sheet-handle"></div>
        <div class="list-header">
          <div class="list-header-text">
            <div class="host" id="files-path"></div>
            <h4 id="files-count" style="font-size:0.9rem;">0 items</h4>
          </div>
          <button class="add-btn" onclick="filesGoUp()" aria-label="Up one level">&uarr;</button>
        </div>
        <button class="attach-row" onclick="document.getElementById('attach-input').click()">
          <span class="glyph">&#8593;</span>
          Upload photo or file
        </button>
        <div class="sessions" id="files-list"></div>
      </div>
    </div>
    <input type="file" id="attach-input" style="display:none" onchange="attachSelectedFile(this)">

    <div class="error-banner" id="error-banner"></div>

    <script>
    \#(MobileBridgeWebAssets.xtermJS)
    </script>
    <script>
    \#(MobileBridgeWebAssets.addonFitJS)
    </script>
    <script>
      let ws, term, fitAddon;
      let currentSurfaceID = null;
      // Survives a dropped socket (unlike `currentSurfaceID`, which `disposeTerminal` clears on
      // every close) so a reconnect can resume the same terminal instead of dumping the user
      // back to the session list. Cleared only on an intentional detach/session-end, not on a
      // connection drop.
      let lastAttachedSurfaceID = null;
      // Guards against a feedback loop: attaching selects the tab on the Mac, which bumps the
      // daemon's snapshot revision, which re-pushes `{sessions:...}` to this same connection
      // (the live session-list subscription) — without this flag, the resume branch below would
      // see that push, re-send `{attach}`, get re-selected, re-bump, forever.
      let resumeAttachInFlight = false;
      let sessionsCache = [];
      // P37 Phase D1: the directory currently shown in the files sheet — null until the sheet
      // is opened for the first time, at which point it defaults to the attached session's cwd.
      let filesCwd = null;
      // P37 Phase G1: reuses the D1 files sheet wholesale instead of building a second picker —
      // same sheet/CSS/state, just a different terminal action on file tap (insert path vs.
      // open preview) and the D2 upload row hidden since it's not relevant here.
      let filesPickerMode = false;
      let authed = false;
      let hasShownPairedToast = false;
      const params = new URLSearchParams(location.search);
      // WS and the page are the same listener/port now (P37: a real phone could reach this
      // page over Tailscale but never a separate WS-only port) — `location.port` is the
      // correct fallback if `wsport` is ever missing from the URL, not a hardcoded guess.
      const wsPort = params.get('wsport') || location.port;
      // P37 A2: a returning device re-auths with the credentials it was issued on its first
      // pairing (persisted in localStorage), so it never needs another QR scan. keyed per
      // host so credentials from one Mac aren't replayed against another.
      const credKey = 'kouenDeviceCreds:' + location.hostname;
      function storedCreds() { try { return JSON.parse(localStorage.getItem(credKey)); } catch { return null; } }

      function showError(msg) {
        const el = document.getElementById('error-banner');
        el.textContent = msg;
        el.classList.add('show');
        setTimeout(() => el.classList.remove('show'), 4000);
      }

      function goto(name) {
        document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
        document.getElementById('view-' + name).classList.add('active');
        // P37 Phase E: opening a file/browser tab is a full-screen takeover on tablet too —
        // drives the `body.preview-active #tablet-rail{display:none}` rule, one call site
        // instead of every place that navigates in/out of the preview view remembering to do it.
        document.body.classList.toggle('preview-active', name === 'preview');
      }

      // P37 Phase E: tablet breakpoint matches the CSS media query exactly (768px) — used to
      // decide whether the session-switch flow lands on the persistent rail (tablet) or the
      // full-screen list/sheet (phone), not just for styling.
      function isTabletLayout() { return window.matchMedia('(min-width: 768px)').matches; }

      let railCollapsed = false;
      function toggleRailCollapse() {
        railCollapsed = !railCollapsed;
        document.getElementById('tablet-rail').classList.toggle('collapsed', railCollapsed);
        document.getElementById('rail-collapse-btn').innerHTML = railCollapsed ? '&#8677;' : '&#8676;';
        // The rail's own width change is a container resize, not a viewport resize — xterm's
        // FitAddon only listens for the latter (see the existing `window.addEventListener('resize'...)`
        // below), so it has to be told explicitly. Deferred past the CSS width transition so it
        // measures the settled size, not mid-animation.
        if (fitAddon && currentSurfaceID) setTimeout(() => fitAddon.fit(), 260);
      }

      function sessionCard(s) {
        const btn = document.createElement('button');
        btn.className = 'session-card';
        btn.onclick = () => attach(s.surfaceID);
        const glyph = document.createElement('span'); glyph.className = 'glyph'; glyph.textContent = '›';
        const meta = document.createElement('span'); meta.className = 'meta';
        const title = document.createElement('div'); title.className = 'title'; title.textContent = s.tabTitle || '(untitled)';
        const cwd = document.createElement('div'); cwd.className = 'cwd'; cwd.textContent = s.cwd;
        meta.append(title, cwd);
        const pill = document.createElement('span'); pill.className = 'pill';
        btn.append(glyph, meta, pill);
        return btn;
      }

      // Built via DOM (not innerHTML interpolation) so a tab title/cwd containing HTML-like
      // text from the user's own shell can never inject markup into this page.
      function renderSessions(sessions) {
        sessionsCache = sessions;
        document.getElementById('list-host').textContent = location.hostname + ' · via tailscale';
        document.getElementById('rail-host').textContent = location.hostname + ' · via tailscale';
        for (const id of ['sessions-main', 'sessions-sheet', 'sessions-rail']) {
          const container = document.getElementById(id);
          container.innerHTML = '';
          if (sessions.length === 0) {
            const empty = document.createElement('div');
            empty.className = 'empty';
            empty.textContent = 'No sessions yet — tap + to start one';
            container.appendChild(empty);
          } else {
            sessions.forEach(s => container.appendChild(sessionCard(s)));
          }
        }
        const label = sessions.length + (sessions.length === 1 ? ' session' : ' sessions');
        document.getElementById('list-count').textContent = label;
        document.getElementById('sheet-count').textContent = label;
        document.getElementById('rail-count').textContent = label;
      }

      function sendResize() {
        if (!term || !ws || ws.readyState !== WebSocket.OPEN) return;
        ws.send(JSON.stringify({ resize: { cols: term.cols, rows: term.rows } }));
      }

      function sendKeySeq(seq) {
        if (ws && ws.readyState === WebSocket.OPEN) ws.send(new TextEncoder().encode(seq));
        clearCompletionStrip();
      }

      // Snapshot a fixed window of rows below the cursor BEFORE sending Tab, diff against the
      // same rows after — a content diff, not a cursor-position check. Found live: zsh's default
      // completion listing prints candidates below the prompt line then restores the cursor to
      // its original position (terminal cursor save/restore), so the cursor never visibly moves;
      // an earlier cursor-position-based version of this heuristic missed every real menu because
      // of exactly that.
      const COMPLETION_WATCH_ROWS = 8;
      function snapshotRowsBelowCursor() {
        if (!term) return null;
        const buf = term.buffer.active;
        const row = buf.baseY + buf.cursorY;
        const rows = [];
        for (let i = 1; i <= COMPLETION_WATCH_ROWS; i++) {
          const line = buf.getLine(row + i);
          rows.push(line ? line.translateToString(true).trim() : '');
        }
        return { row, rows };
      }

      function sendTab() {
        const before = snapshotRowsBelowCursor();
        sendKeySeq('\t');
        watchForCompletion(before);
      }

      // P37 Phase G2: heuristic completion-menu detection — no shell-side setup, so this reads
      // xterm.js's own rendered screen buffer after a Tab byte was sent rather than a structured
      // completion protocol. Explicitly best-effort: tuned against zsh's default menu-listing
      // shape (candidates print as short whitespace-separated tokens on rows that were blank
      // immediately below the cursor before Tab was sent). Hard rule: any ambiguity shows
      // nothing — a missed detection is fine, a wrong/garbage suggestion is not.
      let completionWatchTimer = null;
      function watchForCompletion(before) {
        clearTimeout(completionWatchTimer);
        if (!before) return;
        completionWatchTimer = setTimeout(() => detectCompletionMenu(before), 150);
      }

      function detectCompletionMenu(before) {
        if (!term) return;
        const buf = term.buffer.active;
        const candidateLines = [];
        for (let i = 0; i < before.rows.length; i++) {
          const line = buf.getLine(before.row + 1 + i);
          const text = line ? line.translateToString(true).trim() : '';
          // A row only counts as fresh completion output if it was blank before Tab and has
          // content now — this is what makes the diff resilient to cursor-restore. Stop at the
          // first gap once collection has started (trailing blank rows aren't more candidates).
          if (text && !before.rows[i]) {
            candidateLines.push(text);
          } else if (candidateLines.length) {
            break;
          }
        }
        if (!candidateLines.length) return;

        const tokens = [];
        for (const line of candidateLines) {
          for (const part of line.split(/\s{2,}|\t+/)) {
            const token = part.trim();
            // Reject anything containing an internal single space (reads as prose/output, not
            // a completion token) or implausibly long (not a filename/command-fragment).
            if (!token || token.length > 40 || /\s/.test(token)) continue;
            tokens.push(token);
          }
        }
        // A real completion menu lists multiple short candidates. Too few or an implausibly
        // large count both read as "this isn't actually a completion menu" — stay silent.
        if (tokens.length < 2 || tokens.length > 60) return;
        renderCompletionStrip(tokens.slice(0, 20));
      }

      function renderCompletionStrip(tokens) {
        const el = document.getElementById('completion-strip');
        el.innerHTML = '';
        tokens.forEach(t => {
          const btn = document.createElement('button');
          btn.textContent = t;
          btn.onclick = () => sendKeySeq(t + ' ');
          el.appendChild(btn);
        });
        el.classList.add('show');
      }

      function clearCompletionStrip() {
        const el = document.getElementById('completion-strip');
        if (el) { el.classList.remove('show'); el.innerHTML = ''; }
      }

      // P37 Phase G3: non-interactive variant of the strip, used only for the "thinking"
      // placeholder while the subprocess round trip is in flight — a stray tap during that
      // window must not send literal placeholder text into the shell (renderCompletionStrip's
      // buttons would do exactly that).
      function renderLoadingStrip(text) {
        const el = document.getElementById('completion-strip');
        el.innerHTML = '';
        const span = document.createElement('span');
        span.textContent = text;
        span.className = 'suggest-loading';
        el.appendChild(span);
        el.classList.add('show');
      }

      // Best-effort read of "what the user has typed so far" — xterm.js has no concept of an
      // input-line buffer (the shell's own readline/zle owns that), so this reads the currently
      // rendered cursor row instead. On custom prompt themes this may include prompt decoration
      // alongside the typed command; the AI prompt template is written to tolerate that rather
      // than assuming a clean extraction is possible client-side.
      function currentLineText() {
        if (!term) return '';
        const buf = term.buffer.active;
        const line = buf.getLine(buf.baseY + buf.cursorY);
        return line ? line.translateToString(true).trim() : '';
      }

      let aiSuggestPending = false;
      function requestAISuggestion() {
        if (aiSuggestPending || !ws || ws.readyState !== WebSocket.OPEN) return;
        const commandBuffer = currentLineText();
        if (!commandBuffer) { showError('Type something first, then tap AI.'); return; }
        const meta = sessionsCache.find(s => s.surfaceID === currentSurfaceID);
        const cwd = (meta && meta.cwd) || '/';
        aiSuggestPending = true;
        renderLoadingStrip('Asking claude…');
        ws.send(JSON.stringify({ aiSuggest: { commandBuffer, cwd } }));
      }

      function mountTerminal(surfaceID) {
        if (term) { term.dispose(); term = null; }
        currentSurfaceID = surfaceID;
        lastAttachedSurfaceID = surfaceID;
        resumeAttachInFlight = false;
        // A pending G3 request from the PREVIOUS session must not render into this one — found
        // via code review: `aiSuggestPending` was only ever cleared by the response handler, so
        // switching sessions mid-request left it stuck true (blocking the AI button forever if
        // the old request errored silently) and a late-arriving suggestion would pop into
        // whichever session happened to be active when it finally landed.
        aiSuggestPending = false;
        clearCompletionStrip();
        document.body.classList.remove('tablet-unattached');
        const meta = sessionsCache.find(s => s.surfaceID === surfaceID);
        document.getElementById('term-title').textContent = meta ? meta.tabTitle : surfaceID;
        term = new Terminal({
          fontFamily: 'ui-monospace, "SF Mono", Menlo, Consolas, monospace',
          fontSize: 13,
          theme: { background: '#100d0b', foreground: '#ede8e2', cursor: '#ede8e2' },
          scrollback: 5000,
          convertEol: true,
        });
        fitAddon = new FitAddon.FitAddon();
        term.loadAddon(fitAddon);
        const container = document.getElementById('xterm-container');
        container.innerHTML = '';
        term.open(container);
        // xterm.js's hidden input textarea ships with autocorrect off (it doesn't want the OS
        // rewriting what you type into a terminal). iOS Safari also gates its predictive/QuickType
        // suggestion bar (and the swipe-right-to-accept gesture) on that same attribute, so typing
        // in the terminal on a phone/tablet never showed suggestions at all. Flipped on by request
        // — trade-off: iOS may now also silently auto-replace a typed word on space/punctuation,
        // which can mangle a shell command mid-type.
        const helperTextarea = container.querySelector('textarea');
        if (helperTextarea) helperTextarea.setAttribute('autocorrect', 'on');
        fitAddon.fit();
        sendResize();
        term.onData(data => {
          const before = data === '\t' ? snapshotRowsBelowCursor() : null;
          sendKeySeq(data);
          if (data === '\t') watchForCompletion(before);
        });
        term.onResize(() => sendResize());
        goto('term');
        closeSheet();
      }

      function disposeTerminal() {
        if (term) { term.dispose(); term = null; }
        currentSurfaceID = null;
        aiSuggestPending = false;
        clearCompletionStrip();
        document.body.classList.add('tablet-unattached');
      }

      window.addEventListener('resize', () => { if (fitAddon && currentSurfaceID) fitAddon.fit(); });

      function connect() {
        ws = new WebSocket(`ws://${location.hostname}:${wsPort}/`);
        ws.binaryType = 'arraybuffer';
        // Set the moment the server's `{"error":...}` text arrives, so `onclose` doesn't
        // show a second, less specific banner on top of it (see `onclose` below).
        let sawServerError = false;
        ws.onopen = () => {
          const creds = storedCreds();
          // Returning device: send deviceAuth instead of the token. On failure (revoked /
          // stale secret) the daemon closes the socket; onclose falls back to a token pairing.
          if (creds) ws.send(JSON.stringify({ deviceAuth: creds }));
          else ws.send(document.getElementById('token').value.trim());
          // P37 Phase E: a fresh WS connection means a fresh server-side ConnectionState, so
          // any previously-open browser-mirror tab's paneID is gone (the daemon's own
          // .browserPaneID guard now reports "open a page first" instead of resuming). Clear
          // the cached snapshot/frame so the tab doesn't keep showing stale content as if it
          // were still live — the next interaction naturally re-opens a fresh pane via
          // handleBrowserNavigate's existing fallback. File tabs are untouched: their content
          // is static and survives a socket drop fine.
          const browserTab = findBrowserTab();
          if (browserTab) {
            browserTab.snapshot = null;
            browserTab.frame = null;
            if (browserTab.id === activePreviewTabId) renderActivePreviewTab();
          }
        };
        // `onerror` never carries a reason (browsers withhold it deliberately — MDN/WHATWG:
        // an error event here is not supposed to be used to relay information about why the
        // error occurred). Log only; `onclose`'s close code is the actual signal.
        ws.onerror = () => console.error('[kouen mobile] websocket error');
        ws.onclose = (ev) => {
          resumeAttachInFlight = false;
          disposeTerminal();
          // A deviceAuth that got rejected (device revoked, or a stale secret) closes the
          // socket before we ever saw a sessions list — the stored secret is dead, so drop it
          // and reload to the plain token field for a fresh pairing.
          if (storedCreds() && !authed) { localStorage.removeItem(credKey); location.reload(); }
          // Otherwise, only show a banner if the server didn't already send a specific
          // `{"error":...}` message for this close (rejectAndClose on the daemon side sends
          // one before every deliberate close) — this is the fallback for closes with no
          // prior message: watchdog timeout, or the connection genuinely dropping.
          else if (!authed && !sawServerError) {
            showError(ev.code === 1008
              ? 'Pairing rejected — rescan the QR code.'
              : 'Connection lost — check the daemon is running and try again.');
          }
        };
        ws.onmessage = (ev) => {
          if (typeof ev.data === 'string') {
            let msg;
            try { msg = JSON.parse(ev.data); } catch { return; }
            if (msg.deviceCredentials) { localStorage.setItem(credKey, JSON.stringify(msg.deviceCredentials)); return; }
            if (msg.sessions) {
              authed = true;
              renderSessions(msg.sessions);
              if (currentSurfaceID) {
                // Live background update (the session list changed elsewhere) while already
                // attached and viewing a terminal — the cache above is refreshed for whenever the
                // switcher sheet opens next; do not navigate or touch the attach, or a selection
                // side-effect of attaching (Mac focus-follow bumps the snapshot revision) would
                // re-trigger this same push and loop forever.
              } else if (!hasShownPairedToast) {
                hasShownPairedToast = true;
                const n = msg.sessions.length;
                document.getElementById('paired-sub').textContent = n + (n === 1 ? ' session available' : ' sessions available');
                goto('paired');
                // Tablet: the rail is the session switcher (persistent, always visible) — the
                // full-screen list view's whole job on phone, so tablet skips straight to the
                // terminal (its own empty state prompts "select from the sidebar" until attached).
                setTimeout(() => goto(isTabletLayout() ? 'term' : 'list'), 700);
              } else if (!resumeAttachInFlight && lastAttachedSurfaceID && msg.sessions.some(s => s.surfaceID === lastAttachedSurfaceID)) {
                // A reconnect (iOS dropped the socket on screen-lock/app-switch, see the
                // visibilitychange handler below) lands here with the same session list request
                // every fresh connect sends — resume the terminal the user was actually looking
                // at instead of dumping them back to the list. `resumeAttachInFlight` covers the
                // case where the AttachedAck (which would set currentSurfaceID and end this
                // branch) hasn't landed yet but another sessions push already has.
                resumeAttachInFlight = true;
                ws.send(JSON.stringify({ attach: lastAttachedSurfaceID }));
              } else {
                goto(isTabletLayout() ? 'term' : 'list');
              }
            } else if (msg.ok === 'attached') {
              mountTerminal(msg.surfaceID);
            } else if (msg.ok === 'detached' || msg.detached) {
              lastAttachedSurfaceID = null;
              disposeTerminal();
              goto(isTabletLayout() ? 'term' : 'list');
            } else if (msg.directory) {
              renderFileEntries(msg.directory);
            } else if (msg.file) {
              // Routed by path (the response's own natural key), not a wire-protocol tab id —
              // re-render only if this is still the visible tab, never force-switch to it (a
              // late response for a background tab must not steal focus from whatever the user
              // is actually looking at).
              const fileTab = findFileTab(msg.file.path);
              if (fileTab) {
                fileTab.content = msg.file;
                if (fileTab.id === activePreviewTabId) renderActivePreviewTab();
              }
            } else if (msg.browserSnapshot) {
              const browserTab = findBrowserTab();
              if (browserTab) {
                browserTab.snapshot = msg.browserSnapshot;
                browserTab.url = msg.browserSnapshot.url;
                browserTab.title = msg.browserSnapshot.title || 'Web';
                if (browserTab.id === activePreviewTabId) { renderActivePreviewTab(); renderPreviewTabstrip(); }
              }
            } else if (msg.browserFrame) {
              const browserTab = findBrowserTab();
              if (browserTab) {
                browserTab.frame = msg.browserFrame.png;
                if (browserTab.id === activePreviewTabId) renderActivePreviewTab();
              }
            } else if (msg.ok === 'browserOpened' || msg.ok === 'browserNavigated' || msg.ok === 'browserInteracted') {
              // Auto-refresh the element list after anything that could have changed the page —
              // one fewer tap than making the user hit "Refresh elements" every time.
              ws.send(JSON.stringify({ browserSnapshot: true }));
            } else if (msg.suggestion) {
              aiSuggestPending = false;
              renderCompletionStrip([msg.suggestion]);
            } else if (msg.error) {
              aiSuggestPending = false;
              sawServerError = true;
              showError(msg.error);
            }
          } else if (term) {
            term.write(new Uint8Array(ev.data));
          }
        };
      }

      function attach(id) { closeSheet(); ws.send(JSON.stringify({ attach: id })); }
      function spawnSession() { closeSheet(); ws.send(JSON.stringify({ spawn: {} })); }
      function detach() { ws.send(JSON.stringify({ detach: true })); }
      function openSheet() { document.getElementById('sheet-backdrop').classList.add('open'); document.getElementById('sheet').classList.add('open'); }
      function closeSheet() { document.getElementById('sheet-backdrop').classList.remove('open'); document.getElementById('sheet').classList.remove('open'); }

      // P37 Phase D1: file preview. Reuses .session-card (styled as a plain row here, glyph
      // doubles as a folder/file icon) so no new list styling was needed for the files sheet.
      function listFiles(path) {
        filesCwd = path;
        ws.send(JSON.stringify({ listDirectory: { path } }));
      }

      function openFilesSheet() {
        // Defaults to the attached session's cwd on first open; a later open reuses whatever
        // directory was last browsed, matching how the session switcher sheet keeps its state.
        if (filesCwd === null) {
          const meta = sessionsCache.find(s => s.surfaceID === currentSurfaceID);
          listFiles((meta && meta.cwd) || '/');
        } else {
          listFiles(filesCwd);
        }
        document.getElementById('files-sheet-backdrop').classList.add('open');
        document.getElementById('files-sheet').classList.add('open');
      }
      function closeFilesSheet() {
        document.getElementById('files-sheet-backdrop').classList.remove('open');
        document.getElementById('files-sheet').classList.remove('open');
        filesPickerMode = false;
        document.querySelector('.attach-row').style.display = 'flex';
      }

      function openFilesPicker() {
        filesPickerMode = true;
        document.querySelector('.attach-row').style.display = 'none';
        openFilesSheet();
      }

      // Minimal client-side shell quoting for path insertion — single-quote wrap, escape
      // embedded `'` as `'\''`. Mirrors the desktop's `ShellQuoting.quote` convention (can't
      // import it directly here, this is plain JS in a Swift string literal).
      function shellQuotePath(path) {
        return "'" + path.replace(/'/g, "'\\''") + "'";
      }

      function insertFilePath(path) {
        closeFilesSheet();
        sendKeySeq(shellQuotePath(path));
      }
      function filesGoUp() {
        if (!filesCwd) return;
        const trimmed = filesCwd.replace(/\/+$/, '');
        const parent = trimmed.slice(0, trimmed.lastIndexOf('/'));
        listFiles(parent || '/');
      }

      function joinPath(base, name) {
        return base.replace(/\/+$/, '') + '/' + name;
      }

      // Built via DOM (not innerHTML interpolation), same reasoning as `sessionCard` above —
      // a file/directory name comes straight from the filesystem the user's own shell can write to.
      function fileEntryRow(entry) {
        const btn = document.createElement('button');
        btn.className = 'session-card';
        btn.onclick = () => entry.isDirectory
          ? listFiles(joinPath(filesCwd, entry.name))
          : (filesPickerMode ? insertFilePath(joinPath(filesCwd, entry.name)) : openFileTab(joinPath(filesCwd, entry.name)));
        const glyph = document.createElement('span'); glyph.className = 'glyph';
        glyph.textContent = entry.isDirectory ? '\u{1F4C1}' : '\u{1F4C4}';
        const meta = document.createElement('span'); meta.className = 'meta';
        const title = document.createElement('div'); title.className = 'title'; title.textContent = entry.name;
        meta.appendChild(title);
        btn.append(glyph, meta);
        return btn;
      }

      function renderFileEntries(directory) {
        filesCwd = directory.path;
        document.getElementById('files-path').textContent = directory.path;
        const n = directory.entries.length;
        document.getElementById('files-count').textContent = n + (n === 1 ? ' item' : ' items');
        const container = document.getElementById('files-list');
        container.innerHTML = '';
        if (n === 0) {
          const empty = document.createElement('div');
          empty.className = 'empty';
          empty.textContent = 'Empty directory';
          container.appendChild(empty);
        } else {
          directory.entries.forEach(e => container.appendChild(fileEntryRow(e)));
        }
      }

      // P37 Phase E: unified tab model — replaces D1's single #view-file and D3's single
      // #view-browser with one shared tab-strip + webview-chrome pane (locked design). Multiple
      // file tabs can be open at once; at most ONE browser tab exists per connection (locked
      // scope decision — opening a second URL reuses/renavigates the existing browser tab rather
      // than spawning a second `BrowserPaneView` pane on the Mac).
      let previewTabs = [];
      let activePreviewTabId = null;
      let previewTabSeq = 0;

      function activePreviewTab() { return previewTabs.find(t => t.id === activePreviewTabId) || null; }
      function findFileTab(path) { return previewTabs.find(t => t.kind === 'file' && t.path === path); }
      function findBrowserTab() { return previewTabs.find(t => t.kind === 'browser'); }

      function openFileTab(path) {
        let tab = findFileTab(path);
        if (!tab) {
          tab = { id: 'tab' + (++previewTabSeq), kind: 'file', title: path.slice(path.lastIndexOf('/') + 1), path, content: null };
          previewTabs.push(tab);
        }
        activatePreviewTab(tab.id);
        ws.send(JSON.stringify({ readFile: { path } }));
        closeFilesSheet();
        goto('preview');
      }

      function openBrowserTab(url) {
        let tab = findBrowserTab();
        if (!tab) {
          tab = { id: 'tab' + (++previewTabSeq), kind: 'browser', title: 'Web', url, snapshot: null, frame: null };
          previewTabs.push(tab);
        } else {
          tab.url = url;
        }
        activatePreviewTab(tab.id);
        ws.send(JSON.stringify({ browserNavigate: { url } }));
        goto('preview');
      }

      // The 🌐 toolbar button: reopen the existing browser tab if one is already open (no
      // re-navigate — just switch back to it), otherwise prompt for a starting URL.
      function openBrowserView() {
        const existing = findBrowserTab();
        if (existing) { activatePreviewTab(existing.id); goto('preview'); return; }
        const url = window.prompt('Open URL', 'https://');
        if (!url || url === 'https://') return;
        openBrowserTab(normalizeURL(url));
      }

      function normalizeURL(raw) {
        const url = raw.trim();
        return /^[a-z][a-z0-9+.-]*:\/\//i.test(url) ? url : 'https://' + url;
      }

      function activatePreviewTab(id) {
        activePreviewTabId = id;
        renderPreviewTabstrip();
        renderActivePreviewTab();
      }

      function closePreviewTab(id) {
        const tab = previewTabs.find(t => t.id === id);
        if (!tab) return;
        previewTabs = previewTabs.filter(t => t.id !== id);
        if (tab.kind === 'browser') ws.send(JSON.stringify({ browserClose: true }));
        if (activePreviewTabId === id) {
          const next = previewTabs[previewTabs.length - 1];
          if (next) { activatePreviewTab(next.id); } else { activePreviewTabId = null; closePreview(); }
        } else {
          renderPreviewTabstrip();
        }
      }

      // Back button: return to the terminal, tabs stay open (re-tap 📁/🌐 to come back to them)
      // — a full close-everything would throw away file scroll position/browser state for no
      // reason the locked design asked for.
      function closePreview() { goto('term'); }

      // Built via DOM (not innerHTML), same reasoning as `sessionCard`/`fileEntryRow` above.
      function renderPreviewTabstrip() {
        const container = document.getElementById('preview-tabstrip');
        container.innerHTML = '';
        previewTabs.forEach(t => {
          const el = document.createElement('div');
          el.className = 'filetab' + (t.id === activePreviewTabId ? ' active' : '');
          const label = document.createElement('span'); label.textContent = t.title;
          const x = document.createElement('span'); x.className = 'x'; x.textContent = '×';
          x.onclick = (e) => { e.stopPropagation(); closePreviewTab(t.id); };
          el.append(label, x);
          el.onclick = () => activatePreviewTab(t.id);
          container.appendChild(el);
        });
      }

      function renderActivePreviewTab() {
        const tab = activePreviewTab();
        const pathfield = document.getElementById('preview-pathfield');
        const browserToolbar = document.getElementById('preview-browser-toolbar');
        const navEls = [document.getElementById('preview-back'), document.getElementById('preview-forward'), document.getElementById('preview-reload')];
        const body = document.getElementById('preview-body');
        if (!tab) { body.innerHTML = ''; return; }
        document.getElementById('preview-title').textContent = tab.title;
        if (tab.kind === 'file') {
          pathfield.value = tab.path;
          pathfield.readOnly = true;
          browserToolbar.style.display = 'none';
          navEls.forEach(n => n.classList.add('hidden-nav'));
          renderFileTabBody(tab, body);
        } else {
          pathfield.value = tab.url || '';
          pathfield.readOnly = false;
          browserToolbar.style.display = 'flex';
          navEls.forEach(n => n.classList.remove('hidden-nav'));
          renderBrowserTabBody(tab, body);
        }
      }

      function renderFileTabBody(tab, body) {
        body.innerHTML = '';
        if (!tab.content) {
          const loading = document.createElement('div'); loading.className = 'empty'; loading.textContent = 'Loading…';
          body.appendChild(loading);
          return;
        }
        const file = tab.content;
        if (file.encoding === 'utf8') {
          const pre = document.createElement('pre');
          pre.textContent = file.content + (file.truncated ? '\n\n… (truncated)' : '');
          body.appendChild(pre);
        } else if (file.mimeType.startsWith('image/')) {
          const img = document.createElement('img');
          img.src = 'data:' + file.mimeType + ';base64,' + file.content;
          body.appendChild(img);
        } else {
          const empty = document.createElement('div'); empty.className = 'empty';
          empty.textContent = 'Cannot preview this file type (' + file.mimeType + ').';
          body.appendChild(empty);
        }
      }

      function browserInteract(ref, action, text) {
        ws.send(JSON.stringify({ browserInteract: { ref, action, text: text || null } }));
      }

      // Built via DOM (not innerHTML), same reasoning as `sessionCard`/`fileEntryRow` above —
      // page text/labels come straight from whatever site is loaded.
      function browserElementRow(el) {
        const btn = document.createElement('button');
        btn.className = 'browser-el';
        const tag = document.createElement('span'); tag.className = 'tag';
        tag.textContent = el.tag + (el.role ? ' · ' + el.role : '');
        const label = document.createElement('span'); label.className = 'label';
        label.textContent = el.text || el.placeholder || el.value || '(no label)';
        btn.append(tag, label);
        const isTextInput = el.tag === 'input' || el.tag === 'textarea';
        btn.onclick = () => {
          if (isTextInput) {
            const text = window.prompt('Type into "' + label.textContent + '"', el.value || '');
            if (text !== null) browserInteract(el.id, 'type', text);
          } else {
            browserInteract(el.id, 'click');
          }
        };
        return btn;
      }

      function renderBrowserTabBody(tab, body) {
        body.innerHTML = '';
        if (tab.frame) {
          const img = document.createElement('img');
          img.src = 'data:image/png;base64,' + tab.frame;
          body.appendChild(img);
        }
        if (tab.snapshot) {
          if (!tab.snapshot.elements || tab.snapshot.elements.length === 0) {
            const empty = document.createElement('div'); empty.className = 'empty';
            empty.textContent = 'No interactive elements found on this page.';
            body.appendChild(empty);
          } else {
            tab.snapshot.elements.forEach(el => body.appendChild(browserElementRow(el)));
          }
        }
      }

      function browserRefreshSnapshot() { ws.send(JSON.stringify({ browserSnapshot: true })); }
      function browserRefreshFrame() { ws.send(JSON.stringify({ browserScreenshot: true })); }

      // P37 Phase E: real back/forward/reload for the ported webview toolbar — only shown
      // (see `renderActivePreviewTab`'s `hidden-nav` toggle) on a browser-kind tab.
      function previewNavBack() { if (activePreviewTab()?.kind === 'browser') ws.send(JSON.stringify({ browserGoBack: true })); }
      function previewNavForward() { if (activePreviewTab()?.kind === 'browser') ws.send(JSON.stringify({ browserGoForward: true })); }
      function previewNavReload() { if (activePreviewTab()?.kind === 'browser') ws.send(JSON.stringify({ browserReload: true })); }

      document.getElementById('preview-pathfield').addEventListener('keydown', e => {
        if (e.key !== 'Enter') return;
        const tab = activePreviewTab();
        if (!tab || tab.kind !== 'browser') return; // readonly on a file tab, nothing to submit
        const url = normalizeURL(e.target.value);
        if (!url) return;
        tab.url = url;
        ws.send(JSON.stringify({ browserNavigate: { url } }));
      });

      // P37 Phase D2: mirrors the server's own `maxFileReadBytes` (5 MiB) so an oversized pick
      // fails fast client-side instead of wasting a slow mobile upload before the server rejects it.
      const MAX_ATTACH_BYTES = 5 * 1024 * 1024;

      function attachSelectedFile(input) {
        const file = input.files && input.files[0];
        input.value = ''; // so picking the same file again still fires 'change'
        if (!file) return;
        if (file.size > MAX_ATTACH_BYTES) { showError('File is too large (max 5 MB).'); return; }
        const reader = new FileReader();
        reader.onload = () => {
          // readAsDataURL yields "data:<mime>;base64,<content>" — only the part after the
          // comma is the base64 payload the server expects.
          const base64 = reader.result.slice(reader.result.indexOf(',') + 1);
          ws.send(JSON.stringify({ attachFile: { name: file.name, mimeType: file.type, content: base64 } }));
          closeFilesSheet();
        };
        reader.onerror = () => showError('Could not read the selected file.');
        reader.readAsDataURL(file);
      }

      document.getElementById('token').addEventListener('keydown', e => { if (e.key === 'Enter') connect(); });

      // P37 Phase E: the page always starts with nothing attached — drives view-term's tablet
      // empty state ("select a session from the sidebar") from the very first render, not just
      // after a `disposeTerminal()` call (which never runs before a first attach).
      document.body.classList.add('tablet-unattached');

      // Auto-connect when we can do it without a tap: a stored device credential (returning
      // device, P37 A2) needs no token at all; otherwise a token in the URL (QR scan) — the
      // token expires in pairingLifetime (120s) and the server also honors the previous
      // token for one grace window, so an auto-connect that races a rotation still lands.
      if (storedCreds()) {
        connect();
      } else if (params.get('token')) {
        document.getElementById('token').value = params.get('token');
        connect();
      }

      // iOS Safari closes a background tab's WebSocket on screen-lock/app-switch to save power,
      // without ever running this page's JS to notice — so without this, coming back to the tab
      // silently shows a dead session until the user manually reloads. `visibilitychange` fires
      // the moment the tab is foregrounded again; `pageshow` with `persisted` additionally covers
      // Safari restoring the page straight from its back-forward cache instead of re-running the
      // script at all (a separate iOS-specific path that skips the code above entirely).
      function reconnectIfDropped() {
        if (!authed && !storedCreds()) return; // never paired yet — nothing to resume
        if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) return;
        connect();
      }
      document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') reconnectIfDropped(); });
      window.addEventListener('pageshow', e => { if (e.persisted) reconnectIfDropped(); });
    </script>
    """#

    /// One connection can be either a plain page load OR a WS upgrade — both now share the
    /// same port/listener (see the framing section's doc comment for why), so every accepted
    /// connection reads its HTTP request headers first and branches on whether they ask for
    /// a WS upgrade. `leftover` carries any bytes read past the blank line terminating the
    /// headers into the WS frame buffer, in case a client pipelines its first frame before
    /// waiting for the 101 response (real browsers don't, but nothing forbids it).
    private func readRequestHeader(connection: NWConnection, state: ConnectionState, buffer: Data, pageResponse: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] data, _, _, error in
            guard let self else { return }
            if error != nil { connection.cancel(); return }
            var buf = buffer
            if let data { buf.append(data) }
            if let range = buf.range(of: Data("\r\n\r\n".utf8)) {
                let headerData = Data(buf[..<range.lowerBound])
                let leftover = Data(buf[range.upperBound...])
                self.handleParsedRequest(headerData: headerData, leftover: leftover, connection: connection, state: state, pageResponse: pageResponse)
            } else if buf.count > 8192 {
                // Same bound as the old page listener's `maximumLength` — a real request's
                // headers never approach this; a peer that does is malformed or hostile.
                connection.cancel()
            } else {
                self.readRequestHeader(connection: connection, state: state, buffer: buf, pageResponse: pageResponse)
            }
        }
    }

    /// Minimal header parse — just enough to detect a WS upgrade (`Upgrade: websocket` +
    /// `Connection: ... Upgrade ...` + `Sec-WebSocket-Key`) versus a plain page GET. The
    /// request line and path are ignored either way: this listener only ever serves the one
    /// page or the one bridge protocol, regardless of what path a client asks for.
    private func handleParsedRequest(headerData: Data, leftover: Data, connection: NWConnection, state: ConnectionState, pageResponse: Data) {
        guard let headerText = String(data: headerData, encoding: .utf8) else { connection.cancel(); return }
        // `.components(separatedBy:)` (Foundation), not `.split(separator:)` — the latter's
        // `separator:` parameter takes a single `Character`/`RegexComponent`, not a `String`
        // like `"\r\n"`, on plain (non-regex-literal) String.
        var headers: [String: String] = [:]
        let lines = headerText.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        for line in lines.dropFirst() {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let key = line[line.startIndex..<colon].trimmingCharacters(in: .whitespaces).lowercased()
            let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            headers[key] = value
        }
        let isUpgrade = headers["upgrade"]?.lowercased() == "websocket"
            && (headers["connection"]?.lowercased().contains("upgrade") ?? false)
        // Temporary diagnostic (P37 Phase C real-device WS debugging): log exactly what a
        // real client sent, since every automated test so far (loopback python/WebKit) has
        // passed while a real phone over Tailscale still fails the same way port
        // consolidation was supposed to fix — the request itself is the one thing not yet
        // observed from a real failing attempt.
        log?("mobile bridge: request from \(connection.endpoint) — upgrade=\(headers["upgrade"] ?? "nil") connection=\(headers["connection"] ?? "nil") key=\(headers["sec-websocket-key"] != nil) isUpgrade=\(isUpgrade)")
        if isUpgrade, let key = headers["sec-websocket-key"] {
            let accept = Self.webSocketAcceptValue(for: key)
            let response = Data("""
            HTTP/1.1 101 Switching Protocols\r
            Upgrade: websocket\r
            Connection: Upgrade\r
            Sec-WebSocket-Accept: \(accept)\r
            \r

            """.utf8)
            connection.send(content: response, completion: .contentProcessed { [weak self] sendError in
                guard let self else { return }
                if let sendError {
                    self.log?("mobile bridge: sending 101 response to \(connection.endpoint) failed: \(sendError)")
                    return
                }
                self.log?("mobile bridge: 101 response sent to \(connection.endpoint), switching to frame mode")
                state.frameBuffer = leftover
                self.receiveLoop(connection, state: state)
            })
        } else {
            state.pageServed = true
            connection.send(content: pageResponse, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    /// Renders a QR code as block-character ASCII art via CoreImage's built-in generator.
    private func qrAsciiArt(for string: String) -> String? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("L", forKey: "inputCorrectionLevel")
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent),
              let pixelData = cgImage.dataProvider?.data
        else { return nil }
        let ptr = CFDataGetBytePtr(pixelData)!
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = max(1, cgImage.bitsPerPixel / 8)
        let width = cgImage.width
        let height = cgImage.height
        let quietZone = 2
        func isDark(_ x: Int, _ y: Int) -> Bool {
            guard x >= 0, x < width, y >= 0, y < height else { return false }
            return ptr[y * bytesPerRow + x * bytesPerPixel] < 128
        }
        // Half-block trick (same as `qrencode -t utf8`): each terminal row packs 2 module
        // rows via ▀/▄/█/space, keeping 1 char per module column. Terminal chars render
        // ~2x taller than wide, so this comes out square. The quadrant-block variant
        // (2x2 modules per char) was tried and reverted — it also compressed columns,
        // which left modules non-square (visibly stretched tall on screen) without
        // actually shrinking the true pixel footprint, since that's fixed by module
        // count x font size, not by ASCII-packing scheme.
        var lines: [String] = []
        for y in stride(from: -quietZone, to: height + quietZone, by: 2) {
            var line = ""
            for x in -quietZone..<(width + quietZone) {
                switch (isDark(x, y), isDark(x, y + 1)) {
                case (true, true): line += "█"
                case (true, false): line += "▀"
                case (false, true): line += "▄"
                case (false, false): line += " "
                }
            }
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }

    /// Best-effort Tailscale IPv4 for the QR's URL; nil if Tailscale isn't installed/up.
    private func detectTailscaleHost() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/tailscale")
        process.arguments = ["ip", "-4"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let output, !output.isEmpty { return output }
        } catch {}
        return nil
    }

    /// Best-effort Tailscale MagicDNS name (e.g. `mac-name.tailXXXX.ts.net`) for the QR's
    /// URL; nil if Tailscale isn't installed/up or MagicDNS is off. Used ONLY for the
    /// pairing URL's host — listener binds still use `detectTailscaleHost()`'s raw IP,
    /// since `NWListener` needs a literal address to bind, not a hostname.
    ///
    /// Real-device debugging lead (Agy second opinion, P37): iOS WebKit may treat a
    /// programmatic `new WebSocket("ws://100.x.y.z/...")` to a raw CGNAT-range IP as an
    /// insecure/local-network request and silently block it, while the SAME top-level
    /// `http://` page navigation (user-gesture, not JS-initiated) is allowed — matching every
    /// symptom seen so far (page always loads, the WS upgrade is received server-side and
    /// answered, yet the client still reports `onerror`). A named host is reportedly treated
    /// more permissively. This is unverified until tested against a real failing device.
    private func detectTailscaleMagicDNSName() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/tailscale")
        process.arguments = ["status", "--json"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let selfPeer = json["Self"] as? [String: Any],
                  var dnsName = selfPeer["DNSName"] as? String,
                  !dnsName.isEmpty
            else { return nil }
            if dnsName.hasSuffix(".") { dnsName.removeLast() }
            return dnsName
        } catch {}
        return nil
    }

    /// Generates a fresh pairing token, prints its QR, and waits it out before generating
    /// the next one — runs on a background thread until `stop()` flips `isRunning` false.
    /// No longer needs an interactive console prompt (the old "pick a session" step): since
    /// a token now grants the whole daemon rather than one surface, there's nothing left to
    /// ask the operator to choose. This also lifts the earlier "must run in a real foreground
    /// terminal" constraint.
    private func runPairingLoop(wsPort: UInt16, pageURLPort: Int, tailscaleHost: String?, log: @escaping @Sendable (String) -> Void) {
        let host = tailscaleHost ?? "127.0.0.1"
        if tailscaleHost == nil {
            log("mobile bridge: Tailscale IP not detected — QR will use loopback (same-Mac testing only)")
        }
        // Ticks (at the 0.25s granularity below) the listener has been not-ready, and whether
        // the one-shot warning has already fired for the current not-ready stretch. Both reset
        // the moment a listener goes ready again. The threshold (8 ticks ~= 2s) rides out the
        // normal async startup race — `listener.start()` returns immediately but `.ready` lands
        // a few ms later on `bridgeQueue` — without misreporting a real bind failure (e.g. port
        // already held by another Kouen daemon instance) as if pairing were merely slow.
        var notReadyTicks = 0
        var warnedNoListener = false
        while isRunning {
            guard anyWSListenerReady else {
                notReadyTicks += 1
                if notReadyTicks >= 8 && !warnedNoListener {
                    print("mobile bridge: no WS listener bound — cannot pair (is another Kouen daemon holding the port?)")
                    fflush(stdout)
                    warnedNoListener = true
                }
                Thread.sleep(forTimeInterval: 0.25)
                continue
            }
            notReadyTicks = 0
            warnedNoListener = false
            let token = String(format: "%06d", Int.random(in: 0..<1_000_000))
            // The unified listener serves `embeddedPageHTML` for any non-upgrade path, so the root
            // is enough here. `wsport` lets the page know which port to open the WS
            // connection on, since it can differ from the page-serving port.
            let url = "http://\(host):\(pageURLPort)/?token=\(token)&wsport=\(wsPort)"
            pairingBox.current = PendingPairing(token: token, url: url, expiresAt: Date().addingTimeInterval(pairingLifetime))
            // P37 B3 (log hygiene): the URL is NOT logged per rotation any more — that wrote
            // ~5,760 lines/day to daemon.log whether or not anyone was pairing. The GUI reads
            // the live URL over IPC (`mobilePairingInfo`) instead; daemon.log now only records
            // bridge start/stop/error/lockout. The stdout QR/print below stays: it's the
            // dev-console pairing surface (nil in the GUI-spawned daemon, harmless there).
            print("\nScan with your iPhone's Camera app — valid \(Int(pairingLifetime))s, grants access to every session on this Mac:\n")
            print(qrAsciiArt(for: url) ?? "(QR generation failed — open this URL manually)")
            print("\n\(url)\n")
            // stdout is fully buffered (not line-buffered) once it's not a TTY — e.g.
            // redirected to a log file, or the daemon launched detached — so without an
            // explicit flush this can sit unseen for the entire `pairingLifetime` sleep.
            fflush(stdout)
            // Slept in small increments (not one `Thread.sleep(pairingLifetime)`) so `stop()`
            // is noticed within a fraction of a second instead of up to 45s later.
            var slept: TimeInterval = 0
            while slept < pairingLifetime && isRunning {
                Thread.sleep(forTimeInterval: 0.25)
                slept += 0.25
            }
        }
    }

    // MARK: - Control protocol (client -> bridge, TEXT/JSON)

    private struct ControlMessage: Decodable {
        var attach: String?
        var detach: Bool?
        var spawn: SpawnPayload?
        /// P37 Phase C: `{"resize":{"cols":N,"rows":N}}`, sent by `FitAddon` whenever the
        /// mobile client's viewport changes — forwarded straight to `DaemonClient.resize`.
        var resize: ResizePayload?
        /// P37 Phase D: `{"readFile":{"path":"..."}}` — read-only, mirrors `ToolRegistry.readFile`'s
        /// contract (`Tools/kouen-mcp/Sources/KouenMCP/ToolRegistry.swift:324`), not a new one.
        var readFile: FileReadRequest?
        /// `{"listDirectory":{"path":"..."}}` — feeds the phone's own file picker.
        var listDirectory: DirectoryListRequest?
        /// P37 Phase D2: `{"attachFile":{"name":"...","mimeType":"...","content":"<base64>"}}` —
        /// the reverse of `readFile`. Requires an active `attach` (there's no surface to paste
        /// the resulting path into otherwise).
        var attachFile: AttachFileRequest?
        /// P37 Phase D3 (browser mirror): `{"browserNavigate":{"url":"..."}}` — opens the
        /// mirrored `BrowserPaneView` tab on first use (no `paneID` tracked yet), navigates the
        /// existing one on every call after.
        var browserNavigate: BrowserNavigateRequest?
        /// `{"browserSnapshot":true}` — same trigger-flag shape as `detach`, no payload beyond
        /// presence. Requires a pane already opened via `browserNavigate`.
        var browserSnapshot: Bool?
        /// `{"browserInteract":{"ref":"e3","action":"click","text":null}}` — `ref` is an element
        /// id from the last `browserSnapshot` response, same contract `kouenBrowserInteract`
        /// (the MCP tool) already uses, deliberately not raw x/y coordinates.
        var browserInteract: BrowserInteractRequest?
        /// `{"browserScreenshot":true}` — manual refresh only (P37 Phase D risk note: start
        /// without continuous polling until ref-tap is validated live).
        var browserScreenshot: Bool?
        /// P37 Phase E: the ported webview-style toolbar's back/forward/reload — real navigation
        /// history actions, only meaningful (and only shown by the client) on a browser-kind
        /// preview tab. All three reuse already-wired `IPCRequest` cases, same as every other
        /// browser control message here — no new IPC.
        var browserGoBack: Bool?
        var browserGoForward: Bool?
        var browserReload: Bool?
        /// `{"browserClose":true}` — sent when the client closes its (single, per Phase E's
        /// locked "1 browser tab per connection" scope) browser tab, so the Mac-side pane doesn't
        /// linger until the whole connection tears down.
        var browserClose: Bool?
        /// P37 Phase G3: `{"aiSuggest":{"commandBuffer":"...","cwd":"..."}}` — explicit-trigger
        /// only (client never auto-sends this while typing). `cwd` comes from the client's own
        /// already-tracked session metadata, not a server-side lookup.
        var aiSuggest: AISuggestRequest?
        struct SpawnPayload: Decodable { var cwd: String? }
        struct ResizePayload: Decodable { var cols: Int; var rows: Int }
        struct FileReadRequest: Decodable { var path: String }
        struct DirectoryListRequest: Decodable { var path: String }
        struct AttachFileRequest: Decodable { var name: String; var mimeType: String?; var content: String }
        struct BrowserNavigateRequest: Decodable { var url: String }
        struct BrowserInteractRequest: Decodable { var ref: String; var action: String; var text: String? }
        struct AISuggestRequest: Decodable { var commandBuffer: String; var cwd: String }
    }

    // MARK: - Server -> client payloads (TEXT/JSON)

    private struct SessionsPush: Encodable {
        struct Entry: Encodable {
            var surfaceID: String
            var tabTitle: String
            var cwd: String
        }
        var sessions: [Entry]
    }
    private struct AttachedAck: Encodable { var ok = "attached"; var surfaceID: String }
    private struct DetachedAck: Encodable { var ok = "detached" }
    private struct SpawnedAck: Encodable { var ok = "spawned"; var surfaceID: String }

    /// P37 Phase D (D1). `encoding` is "utf8" when the bytes decode as UTF-8 text (the exact
    /// check `ToolRegistry.readFile` already uses), "base64" otherwise — no extension allowlist,
    /// so any text file previews regardless of its extension and any non-text file still comes
    /// through (as an opaque blob the client can `<img>` if `mimeType` says image/*, otherwise
    /// show a "can't preview" fallback).
    struct FileReadResponse: Encodable {
        struct FileInfo: Encodable {
            var path: String
            var mimeType: String
            var encoding: String
            var content: String
            var truncated: Bool
        }
        var file: FileInfo
    }
    struct DirectoryListResponse: Encodable {
        struct Entry: Encodable { var name: String; var isDirectory: Bool }
        struct Listing: Encodable { var path: String; var entries: [Entry] }
        var directory: Listing
    }
    /// P37 Phase D2. `path` is the temp path the file was written to, mainly for the client to
    /// display — the actual delivery already happened via the shell-quoted paste into the PTY.
    private struct FileAttachedAck: Encodable { var ok = "fileAttached"; var path: String }

    // P37 Phase D3 (browser mirror)
    private struct BrowserOkAck: Encodable { var ok: String }
    /// Dynamic error text (from the GUI's own `BrowserResponsePayload.error`, not a fixed
    /// string this file already inlines elsewhere) needs real JSON encoding for safe quoting —
    /// unlike the static `#"{"error":"..."}"#` literals used throughout this file.
    private struct ErrorAck: Encodable { var error: String }
    /// P37 Phase G3.
    private struct AISuggestionAck: Encodable { var suggestion: String }
    /// `BrowserSnapshot`/`BrowserElement` are already `Codable` in `KouenIPC` (the exact type
    /// `kouenBrowserSnapshot`, the MCP tool, already returns) — forwarded through verbatim, not
    /// re-modeled, so the phone gets the identical ref/bounds/text shape an agent would.
    private struct BrowserSnapshotAck: Encodable { var browserSnapshot: BrowserSnapshot }
    private struct BrowserFramePush: Encodable {
        struct Frame: Encodable { var png: String }
        var browserFrame: Frame
    }

    // MARK: - Device re-auth (P37 A2)

    /// A returning device's first TEXT frame: `{"deviceAuth":{"id":…,"secret":…}}`. Optional
    /// so a plain 6-digit token (not a JSON object) simply decodes to `deviceAuth == nil` and
    /// falls through to the token path.
    private struct DeviceAuthEnvelope: Decodable {
        struct DeviceAuth: Decodable { var id: String; var secret: String }
        var deviceAuth: DeviceAuth?
    }
    /// Handed to the client exactly once, right after a fresh token pairing succeeds, so it
    /// can `localStorage` these and reconnect without another QR scan.
    private struct DeviceCredentials: Encodable {
        struct Cred: Encodable { var id: String; var secret: String }
        var deviceCredentials: Cred
    }

    /// 32 random bytes as 64 lowercase hex chars — the per-device re-auth secret. 256 bits of
    /// entropy makes the secret (unlike the 6-digit token) infeasible to guess, so device
    /// re-auth needs no rate limit of its own.
    private static func randomSecretHex() -> String {
        var rng = SystemRandomNumberGenerator()
        return (0..<32).map { _ in String(format: "%02x", Int(rng.next() as UInt8)) }.joined()
    }

    /// Registers `connection` as the live socket for `deviceID` so a `mobile-revoke-client`
    /// can cancel it specifically (mirrors the un-register in `makeListener`'s teardown).
    ///
    /// Found via Agy + Opus verification: a device that re-auths (`{deviceAuth}`) while its
    /// prior connection is still up (e.g. a phone reconnecting before the old socket noticed
    /// the network drop) used to just overwrite the map entry here, leaving the OLD connection
    /// alive but unreachable from `liveConnections` — a revoke could then never find and cancel
    /// it (the map only ever pointed at the newer one). Capture + cancel the previous
    /// connection before replacing it, closing that bypass. Cancelling fires the OLD
    /// connection's own teardown in `makeListener`'s `stateUpdateHandler`, which now checks
    /// identity (`===`) before removing — so it can't delete the entry we're about to set here.
    private func registerLive(_ connection: NWConnection, deviceID: String) {
        liveConnectionsLock.lock()
        let previous = liveConnections[deviceID]
        liveConnections[deviceID] = connection
        liveConnectionsLock.unlock()
        if let previous, previous !== connection {
            previous.cancel()
        }
    }

    /// Returns the paired device id when `text` is a valid `{deviceAuth}` for a known,
    /// non-revoked device; nil otherwise (unknown/legacy/mismatched secret, or not deviceAuth
    /// JSON at all — the caller then tries the token path).
    private func authorizeReturningDevice(_ text: String) -> String? {
        guard let data = text.data(using: .utf8),
              let envelope = try? JSONDecoder().decode(DeviceAuthEnvelope.self, from: data),
              let auth = envelope.deviceAuth,
              store?.authenticate(id: auth.id, secret: auth.secret) == true
        else { return nil }
        return auth.id
    }

    // MARK: - Manual WebSocket framing (RFC 6455)
    //
    // Was `NWProtocolWebSocket` (Network.framework's built-in WS support) until a real phone
    // could reach the page-serving port (8080) over Tailscale but never the separate WS port
    // (7777) — same host, same interface, only the port differed in reachability, with
    // Tailscale ACLs confirmed wide open (`dst:["*"]`). The only way to remove that unexplained
    // difference was to stop needing a second port at all: this bridge now upgrades to WS on
    // the SAME listener/port that already serves the page, which meant reimplementing the
    // handshake and frame (de)coding by hand instead of relying on Network.framework's
    // automatic WS protocol negotiation (which only applies per-listener, not per-connection).

    private static let webSocketGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    /// RFC 6455 §1.3: accept value is base64(SHA-1(key + the fixed GUID)). Every real WS
    /// client computes the same thing to verify the server actually understood the upgrade.
    private static func webSocketAcceptValue(for key: String) -> String {
        let hash = Insecure.SHA1.hash(data: Data((key + webSocketGUID).utf8))
        return Data(hash).base64EncodedString()
    }

    /// Server-to-client frames are never masked (RFC 6455 §5.1: only client-to-server frames
    /// are). Single-frame (FIN=1) only — this bridge never needs to fragment its own writes,
    /// every payload here fits comfortably under the 64-bit length encoding's practical range.
    private static func encodeWSFrame(opcode: UInt8, payload: Data) -> Data {
        var frame = Data([0x80 | opcode])
        let len = payload.count
        if len <= 125 {
            frame.append(UInt8(len))
        } else if len <= 0xFFFF {
            frame.append(126)
            frame.append(UInt8((len >> 8) & 0xFF))
            frame.append(UInt8(len & 0xFF))
        } else {
            frame.append(127)
            for shift in stride(from: 56, through: 0, by: -8) {
                frame.append(UInt8((len >> shift) & 0xFF))
            }
        }
        frame.append(payload)
        return frame
    }

    struct DecodedWSFrame {
        let fin: Bool
        let opcode: UInt8
        let payload: Data
    }

    enum WSFrameParseResult {
        /// Not enough bytes yet for even the length header — normal, keep accumulating.
        case incomplete
        /// The frame's declared length exceeds `maxWSFrameBytes` — same bound
        /// `NWProtocolWebSocket.Options.maximumMessageSize` used to enforce (P37 A1:
        /// bounding what an unauthenticated peer can make the daemon buffer/decode).
        /// Distinct from `.incomplete` so the caller cancels instead of waiting forever
        /// for bytes that would only make the buffer bigger, never valid.
        case oversized
        case frame(DecodedWSFrame, consumed: Int)
    }

    /// Parses at most one WS frame from the front of `buffer`. Client frames are ALWAYS
    /// masked (RFC 6455 §5.3); unmasking happens here so callers only ever see plaintext
    /// payloads.
    static func parseOneWSFrame(_ buffer: Data) -> WSFrameParseResult {
        guard buffer.count >= 2 else { return .incomplete }
        let start = buffer.startIndex
        let b0 = buffer[start]
        let b1 = buffer[start + 1]
        let fin = (b0 & 0x80) != 0
        let opcode = b0 & 0x0F
        let masked = (b1 & 0x80) != 0
        let lengthByte = Int(b1 & 0x7F)
        var offset = 2
        let payloadLen: Int
        if lengthByte == 126 {
            guard buffer.count >= offset + 2 else { return .incomplete }
            payloadLen = Int(buffer[start + offset]) << 8 | Int(buffer[start + offset + 1])
            offset += 2
        } else if lengthByte == 127 {
            guard buffer.count >= offset + 8 else { return .incomplete }
            var len = 0
            for i in 0..<8 { len = (len << 8) | Int(buffer[start + offset + i]) }
            payloadLen = len
            offset += 8
        } else {
            payloadLen = lengthByte
        }
        guard payloadLen <= maxWSFrameBytes else { return .oversized }
        var maskKey: [UInt8] = []
        if masked {
            guard buffer.count >= offset + 4 else { return .incomplete }
            maskKey = Array(buffer[(start + offset)..<(start + offset + 4)])
            offset += 4
        }
        guard buffer.count >= offset + payloadLen else { return .incomplete }
        var payload = Data(buffer[(start + offset)..<(start + offset + payloadLen)])
        if masked {
            for i in 0..<payload.count {
                payload[payload.startIndex + i] ^= maskKey[i % 4]
            }
        }
        return .frame(DecodedWSFrame(fin: fin, opcode: opcode, payload: payload), consumed: offset + payloadLen)
    }

    private func sendText(_ text: String, on connection: NWConnection, completion: @escaping @Sendable () -> Void = {}) {
        connection.send(content: Self.encodeWSFrame(opcode: 0x1, payload: Data(text.utf8)), completion: .contentProcessed { _ in completion() })
    }

    /// Sends a JSON error message, then closes with a real WS close frame instead of an
    /// abrupt `connection.cancel()`. Found via real-device debugging (P37): an abrupt
    /// `cancel()` right after the error text tears down the TCP connection without a WS
    /// closing handshake, which browsers treat as an *abnormal* closure — `ws.onerror` fires
    /// (showing this bridge's generic "WebSocket error…" banner) regardless of whether the
    /// error text already arrived, clobbering the specific reason the server just sent. A
    /// graceful close (opcode 0x8) makes the closure clean, so only `onclose` fires and the
    /// `{"error":...}` message the client already received stays on screen.
    private func rejectAndClose(_ json: String, on connection: NWConnection) {
        // RFC 6455 §5.5.1: a close frame's payload, if present, starts with a 2-byte
        // big-endian status code. 1008 = Policy Violation — the standard code for "the
        // server understood you, but won't accept this" (as opposed to 1006/no-code, which
        // reads as a generic/unexplained drop). The client's `onclose` also already gets the
        // JSON error text above, but a real close code makes this inspectable even from
        // outside this app (e.g. Safari Web Inspector's Network tab).
        let closeFrame = Data([0x03, 0xF0]) // 1008 as UInt16 big-endian
        sendText(json, on: connection) {
            connection.send(content: Self.encodeWSFrame(opcode: 0x8, payload: closeFrame), completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    private func sendBinary(_ data: Data, on connection: NWConnection) {
        connection.send(content: Self.encodeWSFrame(opcode: 0x2, payload: data), completion: .contentProcessed { _ in })
    }

    private func sendJSON<T: Encodable>(_ value: T, on connection: NWConnection) {
        guard let json = try? JSONEncoder().encode(value) else { return }
        sendText(String(decoding: json, as: UTF8.self), on: connection)
    }

    private func sendSessionList(on connection: NWConnection) {
        let client = DaemonClient()
        guard let response = try? client.request(.listSurfaces), case let .surfaces(surfaces) = response else {
            sendText(#"{"sessions":[]}"#, on: connection)
            return
        }
        let push = SessionsPush(sessions: surfaces.map {
            SessionsPush.Entry(surfaceID: $0.surfaceID, tabTitle: $0.tabTitle, cwd: $0.cwd)
        })
        sendJSON(push, on: connection)
    }

    /// Opens the connection's long-lived session-list subscription right after auth (both auth
    /// paths below call this once) so a mobile page stays live instead of needing a
    /// disconnect/reconnect to see a new tab or another device's spawned session. Mirrors the
    /// native GUI's own `DaemonSyncService.ensureSnapshotSubscription` — `onRevision` here just
    /// re-sends the current list rather than diffing/hydrating a local snapshot, since the phone
    /// only ever needs the flat session list, not the full layout tree. `onRevision` fires on the
    /// subscription's own dedicated queue (see `DaemonSubscription`), not `bridgeQueue` — calling
    /// `sendSessionList` from there is the same off-queue `NWConnection.send` pattern `handleAttach`
    /// already relies on for `onData`/`onReplay`.
    private func startSessionListSubscription(on connection: NWConnection, state: ConnectionState) {
        let client = DaemonClient()
        state.snapshotSubscription = try? client.subscribeSnapshot(
            label: Self.clientLabel,
            onRevision: { [weak self] _ in self?.sendSessionList(on: connection) }
        )
    }

    /// Attaches the connection to `surfaceID`, replacing any previous attachment on it
    /// first — a `{"detach"}` a client skipped before sending `{"attach"}` again must not
    /// leave the old subscription running alongside the new one.
    private func handleAttach(surfaceID: String, connection: NWConnection, state: ConnectionState) {
        // Clear `state.subscription` to nil BEFORE cancelling the old one, not after —
        // `.cancel()` invokes the same `onEnd` closure a real server-side surface close
        // does, and `onEnd` uses "is this still the active subscription?" (nil check) to
        // tell the two apart. Cancel-then-nil left a window where `onEnd` fired against
        // the still-non-nil old subscription and leaked a spurious "surface ended"
        // message into the client on every attach-to-a-different-session switch
        // (reproduced via a direct WS protocol test — not a hypothetical race).
        let previous = state.subscription
        state.subscription = nil
        state.surfaceID = nil
        previous?.cancel()

        let client = DaemonClient()
        do {
            let subscription = try client.attachReplayingSurfaceOutput(
                surfaceID: surfaceID,
                label: Self.clientLabel, // marks this size vote as mobile (Feature B floor)
                onReplay: { [weak self] text in self?.sendBinary(Data(text.utf8), on: connection) },
                onData: { [weak self] data, _ in self?.sendBinary(data, on: connection) },
                onEnd: { [weak self] in
                    // Only announce a real end — an intentional detach/re-attach already
                    // cleared `state.subscription` to nil before cancelling (see above),
                    // so a nil here means this callback is the echo of that, not news.
                    guard state.subscription != nil else { return }
                    state.subscription = nil
                    state.surfaceID = nil
                    self?.sendText(#"{"detached":"surface ended"}"#, on: connection)
                }
            )
            state.surfaceID = surfaceID
            state.subscription = subscription
            sendJSON(AttachedAck(surfaceID: surfaceID), on: connection)
            // Feature A: a phone tap/spawn reached here (the native GUI never calls this bridge),
            // so jump the Mac's own window to the same session and bring it to the foreground. The
            // selects move the daemon-authoritative selection (GUI follows via snapshot sync); the
            // `.activateGUIWindow` push tells the GUI process to activate its window. Best-effort —
            // failures never break the phone's attach.
            Self.focusSurfaceOnMac(surfaceID: surfaceID, request: { try? client.request($0) })
            _ = try? client.request(.activateGUIWindow)
        } catch {
            sendText(#"{"error":"failed to attach to the terminal session"}"#, on: connection)
        }
    }

    private func handleDetach(connection: NWConnection, state: ConnectionState) {
        // Same nil-before-cancel ordering as `handleAttach` — see its comment.
        let previous = state.subscription
        state.subscription = nil
        state.surfaceID = nil
        previous?.cancel()
        sendJSON(DetachedAck(), on: connection)
    }

    /// Creates a brand-new *persistent* tab and returns the surface id a mobile client must
    /// attach to. Split out (and `static`, taking the request function) so a live-daemon test can
    /// drive it against a `SurfaceRegistry` directly and prove the returned surface is a real tab
    /// visible in `.listSurfaces` — the ghost-session regression guard.
    ///
    /// Must go through `.newTab`, not `.createSurface`: `.createSurface` spins a raw PTY that never
    /// joins the `SessionEditor` tree, so it shows up nowhere (GUI list, `.listSurfaces`, the
    /// bridge's own session switcher) and can never be reselected — the exact ghost-session bug.
    /// `.newTab` registers the tab in `editor` and `commit()`s it, so it's visible everywhere.
    /// Label every mobile-bridge subscription connection carries at the `DaemonServer`
    /// client-tracking layer, so `applyEffectiveSize` can tell a phone's size vote apart from a
    /// native Mac window's (Feature B — a phone must never shrink the Mac's terminal below what a
    /// native client established). Mirrors the GUI's own `"KouenGUI"` label convention.
    static let clientLabel = "KouenMobileBridge"

    /// Feature A: resolve `surfaceID` → its (workspace, session, tab) and drive the daemon's
    /// `.selectWorkspace`/`.selectSession`/`.selectTab` so the Mac's active selection jumps to the
    /// same session the phone just tapped/created. Static + `request`-driven (like
    /// `resolveSpawnedSurfaceID`) so a live-daemon test can drive it against a real `SurfaceRegistry`
    /// directly and assert the selects landed. Returns the resolved location (nil if the surface
    /// isn't in the tree — e.g. it closed between the tap and this call). The window *activation*
    /// itself is a separate GUI-process step (`.activateGUIWindow` → GUI `NSApp.activate`); this
    /// only moves the daemon-authoritative selection the GUI then syncs to.
    @discardableResult
    static func focusSurfaceOnMac(
        surfaceID: String,
        request: (IPCRequest) -> IPCResponse?
    ) -> (workspaceID: UUID, sessionID: UUID, tabID: UUID)? {
        guard case let .snapshot(snapshot)? = request(.getSnapshot) else { return nil }
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs where tab.rootPane.allSurfaceIDs().contains(where: { $0.uuidString == surfaceID }) {
                    _ = request(.selectWorkspace(id: workspace.id))
                    _ = request(.selectSession(workspaceID: workspace.id, sessionID: session.id))
                    _ = request(.selectTab(workspaceID: workspace.id, tabID: tab.id))
                    return (workspace.id, session.id, tab.id)
                }
            }
        }
        return nil
    }

    static func resolveSpawnedSurfaceID(cwd: String?, request: (IPCRequest) -> IPCResponse?) -> String? {
        guard case let .snapshot(snapshot)? = request(.getSnapshot),
              let workspaceID = snapshot.activeWorkspaceID ?? snapshot.workspaces.first?.id,
              case let .tabID(tabID)? = request(.newTab(workspaceID: workspaceID, cwd: cwd, shell: nil)),
              case let .snapshot(after)? = request(.getSnapshot)
        else { return nil }
        // The surface id everything else keys on is the pane leaf's `uuidString` — same string
        // `SessionEditor.listSurfaces` reports and `ensureTabSurfaces`/attach spun the PTY under.
        return after.workspaces
            .flatMap(\.sessions)
            .flatMap(\.tabs)
            .first { $0.id == tabID }?
            .rootPane.allSurfaceIDs().first?.uuidString
    }

    /// Spawns a new *persistent* tab (the same tab the GUI's "+" creates) and immediately attaches
    /// to it — matches the session-switcher mockup's "+ opens the terminal" flow.
    private func handleSpawn(cwd: String?, connection: NWConnection, state: ConnectionState) {
        let client = DaemonClient()
        guard let surfaceID = Self.resolveSpawnedSurfaceID(cwd: cwd, request: { try? client.request($0) }) else {
            sendText(#"{"error":"failed to spawn a new session"}"#, on: connection)
            return
        }
        sendJSON(SpawnedAck(surfaceID: surfaceID), on: connection)
        handleAttach(surfaceID: surfaceID, connection: connection, state: state)
    }

    /// Read cap for `handleReadFile` — outgoing WS frames aren't size-limited by this bridge
    /// (`encodeWSFrame` has no send-side cap, unlike the 64 KiB `maxWSFrameBytes` ceiling on
    /// incoming frames), but an unbounded read of an arbitrarily large file would still balloon
    /// daemon memory and the phone's network transfer for no benefit — 5 MiB covers any real
    /// source file or a phone-camera-sized photo with room to spare.
    private static let maxFileReadBytes = 5 * 1024 * 1024

    /// Extensions this bridge will label as `image/*` so the mobile client knows it can `<img>`
    /// the base64 content instead of treating it as an opaque download. Deliberately NOT reusing
    /// `FileViewerViewController.quickLookExtensions` — that list drives macOS QuickLook (PDF,
    /// Office docs, etc. via a native panel), which a web page can't render at all; this is only
    /// the subset a plain HTML `<img>` tag understands.
    private static let imageMimeTypesByExtension: [String: String] = [
        "png": "image/png", "jpg": "image/jpeg", "jpeg": "image/jpeg",
        "gif": "image/gif", "webp": "image/webp",
    ]

    /// Pure path→response logic for `{"readFile"}` (P37 Phase D1), split out from the
    /// connection-bound wrapper below so a test can drive it directly against a real temp file
    /// — same "static + request/no-network-needed" shape `resolveSpawnedSurfaceID`/
    /// `focusSurfaceOnMac` already use above. nil means "cannot read" (missing path, a
    /// directory, or a permission error) — the caller turns that into the WS error frame.
    /// Text-vs-binary split reuses the exact check `ToolRegistry.readFile` uses
    /// (`Tools/kouen-mcp/Sources/KouenMCP/ToolRegistry.swift:328`): if the bytes decode as UTF-8,
    /// it's text; otherwise base64 + a best-effort image mime type. Same trust boundary as
    /// `attach`/`spawn` — a paired device already has full shell access via the PTY, so there's
    /// no separate permission check here (see the plan doc's note on why per-capability scoping
    /// was dropped).
    static func readFileInfo(path: String) -> FileReadResponse.FileInfo? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path),
              (attributes[.type] as? FileAttributeType) != .typeDirectory,
              let size = (attributes[.size] as? Int),
              let handle = FileHandle(forReadingAtPath: path)
        else { return nil }
        defer { try? handle.close() }
        let data = handle.readData(ofLength: Self.maxFileReadBytes)
        let truncated = size > data.count
        if let text = String(data: data, encoding: .utf8) {
            return .init(path: path, mimeType: "text/plain", encoding: "utf8", content: text, truncated: truncated)
        }
        let ext = (path as NSString).pathExtension.lowercased()
        let mime = Self.imageMimeTypesByExtension[ext] ?? "application/octet-stream"
        return .init(path: path, mimeType: mime, encoding: "base64", content: data.base64EncodedString(), truncated: truncated)
    }

    /// Pure path→entries logic for `{"listDirectory"}` (P37 Phase D1) — same shape as
    /// `ToolRegistry.listDirectory` (`Tools/kouen-mcp/Sources/KouenMCP/ToolRegistry.swift:351`),
    /// plus an `isDirectory` flag per entry so the client can distinguish folders (drill in)
    /// from files (preview). nil means "cannot list" (missing/unreadable path).
    static func listDirectoryEntries(path: String) -> [DirectoryListResponse.Entry]? {
        let fm = FileManager.default
        guard let names = try? fm.contentsOfDirectory(atPath: path) else { return nil }
        return names.sorted().map { name in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: (path as NSString).appendingPathComponent(name), isDirectory: &isDir)
            return .init(name: name, isDirectory: isDir.boolValue)
        }
    }

    /// P37 Phase D2 (file/image attach). Writes to the same `KouenPaths.pastedImagesDirectory`
    /// desktop drag-drop already uses for pasted images (`PasteController.writePastedImage`,
    /// `KouenTerminalKit`) — same directory, same permissions (0o755 dir / 0o644 file), same
    /// `<prefix>-<unix-timestamp>-<uuid-prefix-8>[.ext]` naming and 24h prune-on-write. Can't
    /// literally call that function (it's `@MainActor`/`AppKit`, not importable into the
    /// headless daemon target) so the convention is replicated here rather than the exact
    /// symbol — but it is the same convention, not a new one. Only the filename's extension
    /// comes from the caller-supplied `name` (never a full path component), so a malicious
    /// `name` (e.g. containing `../`) can't escape the directory.
    static func writeAttachedFile(name: String, data: Data) -> String? {
        let dir = KouenPaths.pastedImagesDirectory
        let readableDir: [FileAttributeKey: Any] = [.posixPermissions: 0o755]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: readableDir)
        try? FileManager.default.setAttributes(readableDir, ofItemAtPath: dir.path)
        pruneAttachedFiles(in: dir)
        let ext = (name as NSString).pathExtension
        let base = "attached-\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(8))"
        let url = dir.appendingPathComponent(ext.isEmpty ? base : "\(base).\(ext)")
        do {
            try data.write(to: url)
            try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: url.path)
            return url.path
        } catch {
            return nil
        }
    }

    /// Same 24h threshold and shared directory as `PasteController.prunePastedImages` — kept
    /// separate only because that one is `internal` to a different (AppKit) target.
    private static func pruneAttachedFiles(in dir: URL, olderThan maxAge: TimeInterval = 24 * 60 * 60) {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]
        ) else { return }
        let cutoff = Date().addingTimeInterval(-maxAge)
        for url in entries {
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
            if let modified, modified < cutoff { try? fm.removeItem(at: url) }
        }
    }

    /// Mirrors the desktop drag-drop flow's end state exactly (dropped image → temp PNG →
    /// shell-quoted path pasted into the PTY) — only the source differs, an uploaded blob
    /// instead of `NSPasteboard`. Requires an active attach: there is no surface to paste into
    /// otherwise, and unlike `readFile`/`listDirectory` this one has a real side effect, so it
    /// doesn't make sense to run against a connection that isn't looking at a terminal.
    private func handleAttachFile(name: String, base64Content: String, connection: NWConnection, state: ConnectionState) {
        guard let surfaceID = state.surfaceID, let subscription = state.subscription else {
            sendText(#"{"error":"attach to a session before sending a file"}"#, on: connection)
            return
        }
        guard let data = Data(base64Encoded: base64Content), !data.isEmpty, data.count <= Self.maxFileReadBytes else {
            sendText(#"{"error":"file is empty, invalid, or too large"}"#, on: connection)
            return
        }
        guard let path = Self.writeAttachedFile(name: name, data: data) else {
            sendText(#"{"error":"failed to save the uploaded file"}"#, on: connection)
            return
        }
        let quoted = ShellQuoting.quote(path)
        _ = subscription.sendInput(Data(quoted.utf8), surfaceID: surfaceID)
        sendJSON(FileAttachedAck(path: path), on: connection)
    }

    /// P37 Phase D3 (browser mirror). Opens the mirrored `BrowserPaneView` tab on first use
    /// (`.browserOpen`, no `paneID` tracked yet — same IPC request `kouenBrowserOpen`/the desktop
    /// menu use) and navigates the existing one on every call after. Both paths already round-trip
    /// through `DaemonServer.forwardBrowserRequest` → the GUI process → a real `BrowserPaneView` →
    /// back (`DaemonBrowserRoutingTests` already covers that plumbing's routing/timeout/disconnect
    /// behavior) — this is only the WS-facing glue, no new IPC surface.
    private func handleBrowserNavigate(urlString: String, connection: NWConnection, state: ConnectionState) {
        guard let url = URL(string: urlString), url.scheme != nil else {
            sendText(#"{"error":"invalid URL"}"#, on: connection)
            return
        }
        let client = DaemonClient()
        let request: IPCRequest = state.browserPaneID.map { .browserNavigate(paneID: $0, url: url) }
            ?? .browserOpen(url: url, direction: nil, originSurfaceID: nil)
        guard case let .browserSuccess(payload)? = try? client.request(request, timeout: 31) else {
            sendText(#"{"error":"browser request failed"}"#, on: connection)
            return
        }
        state.browserPaneID = Self.nextBrowserPaneID(current: state.browserPaneID, response: payload)
        switch payload {
        case let .open(paneID):
            waitForBrowserLoad(paneID: paneID, client: client)
            sendJSON(BrowserOkAck(ok: "browserOpened"), on: connection)
        case .ok:
            waitForBrowserLoad(paneID: state.browserPaneID, client: client)
            sendJSON(BrowserOkAck(ok: "browserNavigated"), on: connection)
        case let .error(message):
            sendJSON(ErrorAck(error: message), on: connection)
        default:
            sendJSON(BrowserOkAck(ok: "browserNavigated"), on: connection)
        }
    }

    /// Pure state-transition logic for `handleBrowserNavigate`, split out so a test can drive it
    /// without a live connection — same "static, no socket needed" shape `readFileInfo`/
    /// `listDirectoryEntries` already use. `.error` clearing `current` (not just leaving it
    /// alone) is the actual regression fix: found via code review — without it, a closed-on-the-
    /// Mac pane (or any other "Browser pane not found" response) left `browserPaneID` pointing at
    /// a dead pane forever, since every subsequent navigate kept re-targeting the same stale id
    /// and kept failing, with no path back to `.browserOpen` short of a full WS reconnect.
    /// Clearing it here means the *next* navigate's `state.browserPaneID.map` in the caller finds
    /// nil and opens a fresh pane instead.
    static func nextBrowserPaneID(current: UUID?, response: BrowserResponsePayload) -> UUID? {
        switch response {
        case let .open(paneID): return paneID
        case .error: return nil
        default: return current
        }
    }

    /// Best-effort: `DaemonSyncService`'s `.navigate` case acks `.ok` immediately after calling
    /// `view.navigate(to:)`, before the page actually finishes loading — the client's own
    /// auto-refresh-snapshot-on-navigate (see the embedded page's `ws.onmessage`) would otherwise
    /// systematically capture the *previous* page. `.browserWait` already exists for exactly
    /// this (the MCP tool's own load-wait path) — reused here, result ignored either way: a
    /// timeout just means the snapshot that follows might still be a beat early, not that the
    /// navigate itself failed. `paneID` optional only to make the `.ok` call site painless; nil
    /// (shouldn't happen — `.ok` only reaches here after `.browserPaneID` was already set) is a
    /// no-op.
    private func waitForBrowserLoad(paneID: UUID?, client: DaemonClient) {
        guard let paneID else { return }
        _ = try? client.request(.browserWait(paneID: paneID, timeoutSeconds: 10), timeout: 15)
    }

    /// `interactive: true` — the phone always wants the tappable-element list, never the
    /// no-elements "just the page text" mode `kouenBrowserSnapshot` also supports.
    private func handleBrowserSnapshot(connection: NWConnection, state: ConnectionState) {
        guard let paneID = state.browserPaneID else {
            sendText(#"{"error":"open a page first"}"#, on: connection)
            return
        }
        let client = DaemonClient()
        guard case let .browserSuccess(payload)? = try? client.request(.browserSnapshot(paneID: paneID, interactive: true), timeout: 31) else {
            sendText(#"{"error":"snapshot failed"}"#, on: connection)
            return
        }
        switch payload {
        case let .snapshot(snapshot):
            sendJSON(BrowserSnapshotAck(browserSnapshot: snapshot), on: connection)
        case let .error(message):
            sendJSON(ErrorAck(error: message), on: connection)
        default:
            sendText(#"{"error":"unexpected snapshot response"}"#, on: connection)
        }
    }

    /// `ref` is an element id from the client's last `browserSnapshot` — same ref-based contract
    /// `kouenBrowserInteract` already uses, deliberately not raw x/y touch coordinates (those
    /// don't map cleanly onto a desktop-rendered page a phone is only viewing, not sized to).
    private func handleBrowserInteract(ref: String, action: String, text: String?, connection: NWConnection, state: ConnectionState) {
        guard let paneID = state.browserPaneID else {
            sendText(#"{"error":"open a page first"}"#, on: connection)
            return
        }
        let client = DaemonClient()
        guard case let .browserSuccess(payload)? = try? client.request(.browserInteract(paneID: paneID, action: action, elementID: ref, text: text), timeout: 31) else {
            sendText(#"{"error":"interact failed"}"#, on: connection)
            return
        }
        if case let .error(message) = payload {
            sendJSON(ErrorAck(error: message), on: connection)
        } else {
            sendJSON(BrowserOkAck(ok: "browserInteracted"), on: connection)
        }
    }

    /// Manual-refresh only (P37 Phase D3 risk note): the client calls this from an explicit
    /// button tap, never a poll loop — continuous frame streaming is explicitly out of scope
    /// until ref-tap interaction is validated live to actually be enough on its own.
    private func handleBrowserScreenshot(connection: NWConnection, state: ConnectionState) {
        guard let paneID = state.browserPaneID else {
            sendText(#"{"error":"open a page first"}"#, on: connection)
            return
        }
        let client = DaemonClient()
        guard case let .browserSuccess(payload)? = try? client.request(.browserScreenshot(paneID: paneID), timeout: 31) else {
            sendText(#"{"error":"screenshot failed"}"#, on: connection)
            return
        }
        switch payload {
        case let .screenshot(png):
            sendJSON(BrowserFramePush(browserFrame: .init(png: png)), on: connection)
        case let .error(message):
            sendJSON(ErrorAck(error: message), on: connection)
        default:
            sendText(#"{"error":"unexpected screenshot response"}"#, on: connection)
        }
    }

    /// P37 Phase E: real back/forward/reload for the ported webview toolbar's nav buttons —
    /// only meaningful on a browser-kind preview tab, hidden by the client on a file tab. All
    /// three share one shape: request the corresponding already-wired `IPCRequest` case, reply
    /// with the same `"browserNavigated"` ok-kind `handleBrowserNavigate` uses so the client's
    /// existing auto-refresh-snapshot-on-navigate wiring fires without any new client-side case.
    private func handleBrowserNavHistory(_ makeRequest: (UUID) -> IPCRequest, connection: NWConnection, state: ConnectionState) {
        guard let paneID = state.browserPaneID else {
            sendText(#"{"error":"open a page first"}"#, on: connection)
            return
        }
        let client = DaemonClient()
        guard case let .browserSuccess(payload)? = try? client.request(makeRequest(paneID), timeout: 31) else {
            sendText(#"{"error":"browser request failed"}"#, on: connection)
            return
        }
        if case let .error(message) = payload {
            sendJSON(ErrorAck(error: message), on: connection)
        } else {
            // Found via code review: without this, back/forward/reload had the exact same
            // race `handleBrowserNavigate` already works around — the GUI acks the history
            // action before the page finishes loading, so the client's auto-refresh-snapshot
            // (fired on this same "browserNavigated" ok-kind) would systematically capture the
            // *previous* page. `waitForBrowserLoad` is a no-op if the page isn't actually
            // loading (see its own doc comment), so a cached/instant history nav doesn't stall.
            waitForBrowserLoad(paneID: paneID, client: client)
            sendJSON(BrowserOkAck(ok: "browserNavigated"), on: connection)
        }
    }

    /// Closes this connection's mirrored browser pane on an explicit client request (tab close),
    /// not just on connection teardown — Phase D3's teardown-only close left the pane open for
    /// as long as the WS connection itself stayed up, which is fine for "the phone dropped" but
    /// wrong for "the user tapped the tab's × while still connected."
    private func handleBrowserClose(connection: NWConnection, state: ConnectionState) {
        if let paneID = state.browserPaneID {
            let client = DaemonClient()
            _ = try? client.request(.browserClose(paneID: paneID), timeout: 10)
            state.browserPaneID = nil
        }
        sendJSON(BrowserOkAck(ok: "browserClosed"), on: connection)
    }

    private func handleReadFile(path: String, connection: NWConnection) {
        guard let info = Self.readFileInfo(path: path) else {
            sendText(#"{"error":"cannot read file"}"#, on: connection)
            return
        }
        sendJSON(FileReadResponse(file: info), on: connection)
    }

    private func handleListDirectory(path: String, connection: NWConnection) {
        guard let entries = Self.listDirectoryEntries(path: path) else {
            sendText(#"{"error":"cannot list directory"}"#, on: connection)
            return
        }
        sendJSON(DirectoryListResponse(directory: .init(path: path, entries: entries)), on: connection)
    }

    /// P37 Phase G3: reuses the user's own already-authenticated `claude` CLI via subprocess —
    /// deliberately not a direct Anthropic API integration (no API key management to build,
    /// reuses auth the user already has). Runs synchronously on `state.controlQueue` like every
    /// other handler in this file (e.g. `handleBrowserNavigate`'s 31s-timeout blocking IPC call
    /// right above it) rather than hopping to a separate dispatch queue — `controlQueue` is
    /// already per-connection, so a slow call here only delays this one connection's next
    /// message, never other connections' PTY relay. (design.md originally called for a separate
    /// background queue on the assumption everything ran on one shared queue; reading the actual
    /// per-connection `controlQueue` architecture before implementing showed that assumption was
    /// wrong — corrected here rather than adding queueing complexity the codebase doesn't use
    /// anywhere else for comparably slow operations.)
    private func handleAISuggest(commandBuffer: String, cwd: String, connection: NWConnection) {
        switch Self.runClaudeSuggest(commandBuffer: commandBuffer, cwd: cwd) {
        case let .success(suggestion):
            sendJSON(AISuggestionAck(suggestion: suggestion), on: connection)
        case let .failure(error):
            sendJSON(ErrorAck(error: error.text), on: connection)
        }
    }

    /// Minimal `Error` wrapper so `runClaudeSuggest` can return a plain message — `String` itself
    /// doesn't conform to `Error`. `ExpressibleByStringLiteral` keeps every `.failure("...")`
    /// call site below unchanged.
    struct StringError: Error, ExpressibleByStringLiteral, Equatable {
        let text: String
        init(stringLiteral value: String) { text = value }
        init(_ text: String) { self.text = text }
    }

    /// Lock-protected accumulator for a `Process` pipe's `readabilityHandler` (which Foundation
    /// invokes on its own background dispatch queue) — Swift 6 strict concurrency rejects a
    /// captured `var Data` mutated from that closure even behind a manually-paired `NSLock`, so
    /// the lock has to live inside a class the compiler can see is safe to share.
    private final class PipeBuffer: @unchecked Sendable {
        private let lock = NSLock()
        private var data = Data()
        func append(_ chunk: Data) { lock.lock(); data.append(chunk); lock.unlock() }
        func snapshot() -> Data { lock.lock(); defer { lock.unlock() }; return data }
    }

    /// Cached `claude` CLI path resolution — mirrors `GitHubCLIClient.cachedGhPath`'s shape
    /// (`Packages/KouenCore/Sources/KouenCore/GitHub/GitHubCLIClient.swift`): common install
    /// locations first, `which` fallback for non-standard installs.
    private static let cachedClaudePath: String? = {
        // Found via live-testing on this machine: unlike `gh` (which installs via Homebrew),
        // the `claude` CLI commonly installs to `~/.local/bin` (curl-installer default) — the
        // launchd-spawned daemon's PATH doesn't include that, so the `which` fallback below
        // wouldn't have found it either. Check it explicitly rather than assuming Homebrew-only.
        let paths = [
            NSHomeDirectory() + "/.local/bin/claude",
            "/opt/homebrew/bin/claude",
            "/usr/local/bin/claude",
        ]
        if let found = paths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            return found
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["claude"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0,
                  let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !path.isEmpty, FileManager.default.fileExists(atPath: path)
            else { return nil }
            return path
        } catch {
            return nil
        }
    }()

    /// Pure — no I/O, directly testable without spawning a process. Wraps `commandBuffer` in a
    /// fixed template rather than passing it to the CLI unwrapped, so `claude -p`'s free-form
    /// chat behavior doesn't leak into what should be a single suggested command.
    static func buildSuggestPrompt(commandBuffer: String, cwd: String) -> String {
        "Suggest a single shell command for: \(commandBuffer). Context: cwd=\(cwd). Reply with ONLY the command, no explanation, no markdown formatting."
    }

    /// Pure, testable in isolation. The prompt asks the CLI for a single command, but nothing
    /// enforces that server-side, and the reply gets sent to the client as literal terminal
    /// input — an embedded newline would auto-submit an unreviewed second command the instant
    /// the user taps the suggestion (LF triggers accept-line in bash/zsh line editing, same as
    /// CR). Found via code review, not hit live.
    static func firstLine(of text: String) -> String {
        text.split(whereSeparator: { $0.isNewline }).first.map(String.init) ?? ""
    }

    /// 20s hard timeout — kills a hung subprocess rather than pinning this connection's
    /// suggestion slot forever. `cwd` is checked before `cachedClaudePath` so that guard is
    /// exercisable in tests regardless of whether `claude` happens to be installed on the
    /// machine running them.
    static func runClaudeSuggest(commandBuffer: String, cwd: String, timeoutSeconds: TimeInterval = 20) -> Result<String, StringError> {
        guard FileManager.default.fileExists(atPath: cwd) else {
            return .failure("working directory not found")
        }
        guard let claudePath = cachedClaudePath else {
            return .failure("claude CLI not found")
        }
        let prompt = buildSuggestPrompt(commandBuffer: commandBuffer, cwd: cwd)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: claudePath)
        process.arguments = ["-p", prompt]
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        // Drain both pipes concurrently as data arrives, rather than reading after the process
        // exits — `claude -p` output isn't bounded like `gh pr merge`'s (the pattern this
        // mirrors), so a reply larger than the pipe's OS buffer would block the child on
        // write() forever, surfacing as a spurious 20s timeout instead of the real answer.
        // Found via code review, not hit live. `readabilityHandler` fires on a background
        // dispatch queue Foundation owns, hence the lock-protected `@unchecked Sendable` box
        // rather than a captured `var` — same reasoning as this file's other lock-guarded state
        // (e.g. `ConnectionState`).
        let outputBuffer = PipeBuffer()
        let errorBuffer = PipeBuffer()
        outPipe.fileHandleForReading.readabilityHandler = { handle in
            let chunk = handle.availableData
            if !chunk.isEmpty { outputBuffer.append(chunk) }
        }
        errPipe.fileHandleForReading.readabilityHandler = { handle in
            let chunk = handle.availableData
            if !chunk.isEmpty { errorBuffer.append(chunk) }
        }
        defer {
            outPipe.fileHandleForReading.readabilityHandler = nil
            errPipe.fileHandleForReading.readabilityHandler = nil
        }

        do {
            try process.run()
        } catch {
            return .failure(StringError(error.localizedDescription))
        }

        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.1)
        }
        if process.isRunning {
            process.terminate()
            return .failure("claude CLI timed out")
        }
        process.waitUntilExit()

        let outText = String(data: outputBuffer.snapshot(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let errText = String(data: errorBuffer.snapshot(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if process.terminationStatus == 0 {
            // Only the first line: the prompt asks for a single command, but nothing enforces
            // that server-side, and this text gets sent to the client as literal terminal
            // input — an embedded newline would auto-submit an unreviewed command the instant
            // the user taps it (LF triggers accept-line in bash/zsh, same as CR). Found via
            // code review, not hit live.
            let firstLine = Self.firstLine(of: outText)
            return firstLine.isEmpty ? .failure("claude CLI returned no suggestion") : .success(firstLine)
        }
        return .failure(StringError(errText.isEmpty ? "claude CLI failed" : errText))
    }

    private func handleControlMessage(_ text: String, connection: NWConnection, state: ConnectionState) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(ControlMessage.self, from: data)
        else {
            sendText(#"{"error":"unrecognized control message"}"#, on: connection)
            return
        }
        if let surfaceID = message.attach {
            state.controlQueue.async { [weak self] in
                self?.handleAttach(surfaceID: surfaceID, connection: connection, state: state)
            }
        } else if message.detach == true {
            handleDetach(connection: connection, state: state)
        } else if let spawn = message.spawn {
            state.controlQueue.async { [weak self] in
                self?.handleSpawn(cwd: spawn.cwd, connection: connection, state: state)
            }
        } else if let resize = message.resize, let surfaceID = state.surfaceID, let subscription = state.subscription {
            // `resize` lives on the subscription (not a one-shot `DaemonClient`), same as the
            // native GUI's resize vote — its lifetime is tied to this attach, released
            // automatically on detach/disconnect (see `DaemonSubscription.resize`'s doc comment).
            subscription.resize(surfaceID, rows: UInt16(clamping: resize.rows), cols: UInt16(clamping: resize.cols))
        } else if let readFile = message.readFile {
            state.controlQueue.async { [weak self] in
                self?.handleReadFile(path: readFile.path, connection: connection)
            }
        } else if let listDirectory = message.listDirectory {
            state.controlQueue.async { [weak self] in
                self?.handleListDirectory(path: listDirectory.path, connection: connection)
            }
        } else if let attachFile = message.attachFile {
            state.controlQueue.async { [weak self] in
                self?.handleAttachFile(name: attachFile.name, base64Content: attachFile.content, connection: connection, state: state)
            }
        } else if let browserNavigate = message.browserNavigate {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserNavigate(urlString: browserNavigate.url, connection: connection, state: state)
            }
        } else if message.browserSnapshot == true {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserSnapshot(connection: connection, state: state)
            }
        } else if let browserInteract = message.browserInteract {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserInteract(ref: browserInteract.ref, action: browserInteract.action, text: browserInteract.text, connection: connection, state: state)
            }
        } else if message.browserScreenshot == true {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserScreenshot(connection: connection, state: state)
            }
        } else if message.browserGoBack == true {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserNavHistory({ .browserGoBack(paneID: $0) }, connection: connection, state: state)
            }
        } else if message.browserGoForward == true {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserNavHistory({ .browserGoForward(paneID: $0) }, connection: connection, state: state)
            }
        } else if message.browserReload == true {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserNavHistory({ .browserReload(paneID: $0) }, connection: connection, state: state)
            }
        } else if message.browserClose == true {
            state.controlQueue.async { [weak self] in
                self?.handleBrowserClose(connection: connection, state: state)
            }
        } else if let aiSuggest = message.aiSuggest {
            state.controlQueue.async { [weak self] in
                self?.handleAISuggest(commandBuffer: aiSuggest.commandBuffer, cwd: aiSuggest.cwd, connection: connection)
            }
        } else {
            sendText(#"{"error":"unrecognized control message"}"#, on: connection)
        }
    }

    /// Reads raw bytes and hands them to `drainFrames` — replaces the old
    /// `connection.receiveMessage` + `NWProtocolWebSocket.Metadata` pair now that WS framing
    /// is decoded by hand (see the framing section above for why).
    private func receiveLoop(_ connection: NWConnection, state: ConnectionState) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, _, error in
            guard let self else { return }
            if error != nil {
                state.subscription?.cancel()
                state.snapshotSubscription?.cancel()
                return
            }
            if let data { state.frameBuffer.append(data) }
            self.drainFrames(connection, state: state)
        }
    }

    /// Parses as many complete frames as `state.frameBuffer` currently holds, dispatching
    /// each in turn, then re-arms `receiveLoop` once only an incomplete trailing frame (or
    /// nothing) remains — so several frames arriving in one TCP read (coalesced keystrokes,
    /// DERP-relay batching) are all processed before waiting on the network again.
    private func drainFrames(_ connection: NWConnection, state: ConnectionState) {
        while true {
            switch Self.parseOneWSFrame(state.frameBuffer) {
            case .incomplete:
                receiveLoop(connection, state: state)
                return
            case .oversized:
                // Graceful close (P37 Phase D2), not the abrupt `connection.cancel()` this used
                // to be — that tears down the TCP connection without a WS closing handshake,
                // which browsers treat as an unexplained abnormal closure (`ws.onerror` with no
                // reason) instead of surfacing this specific error. Same reasoning `rejectAndClose`
                // already documents for the auth-failure paths; this was the one place that still
                // used the abrupt form.
                rejectAndClose(#"{"error":"message too large"}"#, on: connection)
                return
            case let .frame(frame, consumed):
                state.frameBuffer.removeFirst(consumed)
                if !handleFrame(frame, connection: connection, state: state) { return }
            }
        }
    }

    /// Handles one decoded frame. Returns `true` to keep draining `state.frameBuffer` /
    /// re-arm `receiveLoop`, `false` when this frame already ended the connection (close,
    /// or an auth failure that cancels after its error message flushes).
    private func handleFrame(_ frame: DecodedWSFrame, connection: NWConnection, state: ConnectionState) -> Bool {
        // Temporary diagnostic (P37 real-device WS debugging): first-ever frame log per
        // connection — everything up to "switching to frame mode" is proven to work on a
        // real failing attempt, but there is zero visibility into whether the client sends
        // anything at all afterward. This fills that gap.
        if !state.loggedFirstFrame {
            state.loggedFirstFrame = true
            log?("mobile bridge: first frame from \(connection.endpoint) — opcode=\(frame.opcode) fin=\(frame.fin) bytes=\(frame.payload.count)")
        }
        switch frame.opcode {
        case 0x9: // ping — mirror `NWProtocolWebSocket.Options.autoReplyPing`'s old behavior
            connection.send(content: Self.encodeWSFrame(opcode: 0xA, payload: frame.payload), completion: .contentProcessed { _ in })
            return true
        case 0xA: // pong — nothing to do
            return true
        case 0x8: // close
            connection.send(content: Self.encodeWSFrame(opcode: 0x8, payload: Data()), completion: .contentProcessed { _ in
                connection.cancel()
            })
            return false
        default:
            break
        }

        let opcode: UInt8
        let payload: Data
        if frame.opcode == 0x0 {
            // Continuation — accumulate; only dispatch once FIN arrives.
            guard let fragOpcode = state.fragmentedOpcode else { return true } // stray continuation, ignore
            state.fragmentedPayload.append(frame.payload)
            guard frame.fin else { return true }
            opcode = fragOpcode
            payload = state.fragmentedPayload
            state.fragmentedOpcode = nil
            state.fragmentedPayload = Data()
        } else if !frame.fin {
            // Start of a fragmented message — stash and wait for continuations.
            state.fragmentedOpcode = frame.opcode
            state.fragmentedPayload = frame.payload
            return true
        } else {
            opcode = frame.opcode
            payload = frame.payload
        }

        let isText = opcode == 0x1
        let data = payload

        if !state.authorized {
            guard isText, let text = String(data: data, encoding: .utf8) else {
                rejectAndClose(#"{"error":"invalid or expired pairing token"}"#, on: connection)
                return false
            }
            // Returning device (`{deviceAuth}`) is checked FIRST and is exempt from the
            // token lockout below — a phone that paired earlier reconnects with no QR
            // scan even while a brute-forcer has the token path locked out.
            if let deviceID = authorizeReturningDevice(text) {
                state.authorized = true
                state.deviceID = deviceID
                registerLive(connection, deviceID: deviceID)
                sendSessionList(on: connection)
                startSessionListSubscription(on: connection, state: state)
                return true
            }
            // New pairing via the rotating 6-digit token. Refuse once the window's
            // attempt budget (P37 A1) is spent — released only when the token rotates.
            guard !pairingBox.isLockedOut else {
                log?("mobile bridge: token rejected for \(connection.endpoint) — locked out")
                rejectAndClose(#"{"error":"too many attempts — wait for the next pairing code"}"#, on: connection)
                return false
            }
            // Accepts the current token OR the just-rotated-out previous token within its
            // grace window (see `PairingBox.check` — fixes the proven rotation-boundary bug
            // where a phone's page-URL token had already rotated out by connect time).
            let check = pairingBox.check(text)
            guard check == .accepted else {
                let reason: String
                switch check {
                case .expired: reason = "expired — token rotated past even the grace window"
                case .mismatch: reason = "mismatch"
                case .noActivePairing: reason = "no active pairing"
                case .accepted: reason = "" // unreachable (guarded above)
                }
                log?("mobile bridge: token rejected for \(connection.endpoint) — \(reason) (received \(text.count) chars)")
                if pairingBox.recordFailure() {
                    log?("mobile bridge: pairing locked out after \(maxTokenAttempts) failed token attempts — resets on next token rotation")
                }
                rejectAndClose(#"{"error":"invalid or expired pairing token"}"#, on: connection)
                return false
            }
            // Fresh pairing: mint the device id + re-auth secret, persist it, and hand the
            // client its credentials (once) BEFORE the sessions push, so the page can store
            // them and skip the token on its next connect.
            let deviceID = UUID().uuidString
            let secret = Self.randomSecretHex()
            state.authorized = true
            state.deviceID = deviceID
            store?.register(id: deviceID, label: "Mobile device (\(deviceID.prefix(8)))", secret: secret)
            registerLive(connection, deviceID: deviceID)
            sendJSON(DeviceCredentials(deviceCredentials: .init(id: deviceID, secret: secret)), on: connection)
            sendSessionList(on: connection)
            startSessionListSubscription(on: connection, state: state)
            return true
        }

        if isText, let text = String(data: data, encoding: .utf8) {
            handleControlMessage(text, connection: connection, state: state)
        } else if let surfaceID = state.surfaceID, let subscription = state.subscription {
            _ = subscription.sendInput(data, surfaceID: surfaceID)
        }
        return true
    }

    /// Was sized against `NWProtocolWebSocket.Options.maximumMessageSize`; now enforced by
    /// hand in `parseOneWSFrame`. Raised from the original 64 KiB (P37 Phase D2): an
    /// `attachFile` payload is base64 (~33% overhead) over up to `maxFileReadBytes` (5 MiB) of
    /// raw file content, so the JSON envelope carrying it can reach ~7 MiB — 8 MiB leaves
    /// headroom above that without being unbounded. An inbound frame has no cap BEFORE
    /// authentication either (hit by the raw token compare and `authorizeReturningDevice`'s
    /// JSON decode), so this is also the most an unauthenticated peer can make the daemon
    /// buffer per connection — accepted the same way the rest of this bridge already accepts
    /// loopback+Tailscale as the trust boundary (see the plan doc's R6 note), not the raw
    /// internet.
    private static let maxWSFrameBytes = 8 * 1024 * 1024

    /// One listener per bind host, serving both the plain page and the WS bridge on the
    /// SAME port (see the framing section's doc comment above `webSocketGUID` for why: a
    /// real phone could reach the page's port over Tailscale but never a second, WS-only
    /// port on the same host/interface, with Tailscale ACLs confirmed wide open — the only
    /// way to remove that unexplained difference was removing the second port).
    private func makeUnifiedListener(bindHost: String, port: NWEndpoint.Port) throws -> NWListener {
        let parameters = NWParameters.tcp
        // The port lives in `requiredLocalEndpoint` already — passing `on: port` too
        // (the two-argument initializer) makes NWListener bind twice and fail with
        // EINVAL. Bind exclusively through the endpoint.
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(bindHost), port: port)
        // Without this, binding the SAME port on two different local addresses (loopback
        // + the Tailscale interface) from two listeners in one process fails with
        // EADDRINUSE — Network.framework's own port bookkeeping, not a real conflict
        // (confirmed: freeing the first listener immediately frees the port for reuse).
        parameters.allowLocalEndpointReuse = true
        let listener = try NWListener(using: parameters)
        let body = Data(Self.embeddedPageHTML.utf8)
        let pageResponse = Data("""
        HTTP/1.1 200 OK\r
        Content-Type: text/html; charset=utf-8\r
        Content-Length: \(body.count)\r
        Connection: close\r
        \r

        """.utf8) + body
        listener.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            self.log?("mobile bridge: connection accepted from \(connection.endpoint)")
            let state = ConnectionState()
            connection.stateUpdateHandler = { [weak self] connState in
                switch connState {
                case .cancelled, .failed:
                    if case let .failed(error) = connState {
                        self?.log?("mobile bridge: connection from \(connection.endpoint) failed: \(error)")
                    } else {
                        self?.log?("mobile bridge: connection from \(connection.endpoint) cancelled — authorized=\(state.authorized) pageServed=\(state.pageServed) deviceID=\(state.deviceID ?? "nil")")
                    }
                    state.subscription?.cancel()
                    // Connection is going away for good (unlike a per-attach detach), so the
                    // whole-connection session-list subscription dies with it too.
                    state.snapshotSubscription?.cancel()
                    // Found via code review: iOS Safari drops the WS on screen-lock/backgrounding
                    // (the existing `reconnectIfDropped` client logic exists exactly because of
                    // this), and each reconnect that navigates again opens a brand-new
                    // `BrowserPaneView` on the Mac (`browserPaneID` lives on `ConnectionState`,
                    // not across connections) — without this, the old pane from every dropped
                    // connection just accumulates, never closed. Best-effort, off `controlQueue`
                    // so a slow/hung GUI can't stall this teardown handler for other connections.
                    if let browserPaneID = state.browserPaneID {
                        state.controlQueue.async {
                            _ = try? DaemonClient().request(.browserClose(paneID: browserPaneID), timeout: 5)
                        }
                    }
                    // Only drops the *live* entry — the device stays paired (persists
                    // in PairedDeviceStore) so a reconnect doesn't need a fresh QR scan.
                    //
                    // Found via Agy + Opus verification: this used to remove the map entry
                    // unconditionally. If `registerLive` had already replaced it with a NEWER
                    // connection for the same deviceID (see its comment), this teardown firing
                    // for the OLDER connection would delete the newer entry out from under it —
                    // the revocation-bypass bug. `NWConnection` is a class, so identity (`===`)
                    // is exactly "is this still the connection I registered", not just "same id".
                    if let deviceID = state.deviceID {
                        self?.liveConnectionsLock.lock()
                        if Self.shouldRemoveLiveEntry(current: self?.liveConnections[deviceID], torndown: connection) {
                            self?.liveConnections.removeValue(forKey: deviceID)
                        }
                        self?.liveConnectionsLock.unlock()
                    }
                default: break
                }
            }
            connection.start(queue: self.bridgeQueue)
            self.readRequestHeader(connection: connection, state: state, buffer: Data(), pageResponse: pageResponse)
            // Found via Agy + Opus verification (originally on the WS-only listener; still
            // applies here unchanged): a peer that completes the TCP handshake and then just
            // sits there — never finishing its HTTP request, or completing a WS upgrade and
            // then sending nothing, not even a pairing token — held the connection/fd open
            // forever. One watchdog now covers both cases: `pageServed` for the plain-HTTP
            // path, `authorized` for the WS path: once either fires, the peer got a real
            // response; if neither did within the window, it's a stall.
            self.bridgeQueue.asyncAfter(deadline: .now() + self.preAuthTimeout) { [weak self] in
                guard !state.authorized, !state.pageServed else { return }
                self?.log?("mobile bridge: pre-auth watchdog firing for \(connection.endpoint) — no auth/page-serve within \(self?.preAuthTimeout ?? -1)s, cancelling")
                connection.cancel()
            }
        }
        return listener
    }

    /// Starts the bridge bound to loopback + (if detected) the Tailscale interface, and the
    /// pairing loop on a background thread. Safe to call again after `stop()` — the Settings
    /// toggle now starts/stops this in place rather than restarting the daemon.
    ///
    /// `wsPort` is accepted but unused: the WS bridge and the page used to be two separate
    /// listeners on two separate ports, until a real phone could reach the page's port over
    /// Tailscale but never the WS-only one (Tailscale ACLs confirmed wide open — see the
    /// framing section above `webSocketGUID`). They're now ONE listener on `pageURLPort`;
    /// the parameter stays so callers (`main.swift`, still reading `KOUEN_MOBILE_BRIDGE_PORT`)
    /// don't need to change, but its value no longer means anything.
    public func start(
        wsPort: UInt16,
        pageURLPort: Int,
        store: PairedDeviceStore,
        log: @escaping @Sendable (String) -> Void
    ) {
        guard !isRunning else {
            log("mobile bridge: already running, ignoring start()")
            return
        }
        guard let port = NWEndpoint.Port(rawValue: UInt16(clamping: pageURLPort)) else {
            log("mobile bridge: invalid port \(pageURLPort), not starting")
            return
        }
        self.store = store
        self.log = log
        isRunning = true
        store.onRevoke = { [weak self] id in self?.cancelConnection(forDeviceID: id) }

        // Detected ONCE and reused for both the actual listener binds AND the QR/URL host
        // (via `runPairingLoop`, dispatched below) — two independent `tailscale ip -4`
        // subprocess calls at two different times (bind-time here vs. whenever the async
        // pairing loop's first tick ran) could disagree if Tailscale's state changed in
        // between, producing a QR that points at a host nothing is actually bound to (or
        // vice versa). Found via find-mismatch while chasing a real-device WS connect
        // failure — harmless when Tailscale is already stable, a real race otherwise.
        let tailscaleHost = detectTailscaleHost()
        // MagicDNS name, if available — used ONLY for the QR/URL host (see its doc comment
        // above `detectTailscaleMagicDNSName`); binds below still use the raw IP.
        let tailscaleMagicDNSName = detectTailscaleMagicDNSName()
        // Every listener binds ONLY the hosts this returns — loopback plus a detected
        // Tailscale IP, never an all-interfaces address (see `allowedBindHosts`).
        let bindHosts = Self.allowedBindHosts(tailscaleIP: tailscaleHost)
        for host in bindHosts {
            do {
                let listener = try makeUnifiedListener(bindHost: host, port: port)
                listener.stateUpdateHandler = { [weak self] state in
                    switch state {
                    case .ready:
                        self?.setWSListener(host: host, ready: true)
                    case .failed(let error):
                        // A squatted port surfaces HERE (bind errors don't throw above with
                        // `allowLocalEndpointReuse`) — mark the host down so the pairing URL
                        // is withheld and the Settings panel shows the failure (R4).
                        log("mobile bridge: listener on \(host) failed: \(error)")
                        self?.setWSListener(host: host, ready: false)
                    case .cancelled:
                        self?.setWSListener(host: host, ready: false)
                    default: break
                    }
                }
                listener.start(queue: bridgeQueue)
                listeners.append(listener)
            } catch {
                log("mobile bridge: failed to bind on \(host):\(pageURLPort): \(error)")
            }
        }
        log("mobile bridge: listening on \(bindHosts.map { "\($0):\(pageURLPort)" }.joined(separator: ", "))")

        DispatchQueue.global().async { [weak self] in
            // `wsport=` in the QR/URL is the SAME port as the page now — pass `pageURLPort`
            // (not the unused `wsPort` param) so the client's `new WebSocket(...)` call
            // actually targets the port something is listening on.
            self?.runPairingLoop(wsPort: UInt16(clamping: pageURLPort), pageURLPort: pageURLPort, tailscaleHost: tailscaleMagicDNSName ?? tailscaleHost, log: log)
        }
    }

    /// Tears down every listener and live connection and stops the pairing loop (within
    /// ~0.25s — see `runPairingLoop`'s sleep granularity). Safe to call when not running
    /// (no-op). Does NOT clear `PairedDeviceStore` — paired devices stay authorized so a
    /// later `start()` doesn't force every phone through the QR flow again.
    public func stop() {
        guard isRunning else { return }
        isRunning = false
        listeners.forEach { $0.cancel() }
        listeners.removeAll()
        wsReadyLock.lock()
        wsReadyHosts.removeAll()
        wsReadyLock.unlock()
        liveConnectionsLock.lock()
        let connections = Array(liveConnections.values)
        liveConnections.removeAll()
        liveConnectionsLock.unlock()
        connections.forEach { $0.cancel() }
        pairingBox.clear()
        log?("mobile bridge: stopped")
    }

    /// P37 bind-scope invariant (security-critical, plan risk R6): the bridge has NO TLS. Its
    /// only wire encryption is WireGuard (the Tailscale interface); the loopback interface never
    /// leaves the machine. So it may bind ONLY `127.0.0.1` and a detected Tailscale IP — NEVER an
    /// all-interfaces host (`0.0.0.0` / `::`) or an empty host, which would expose the plaintext
    /// bridge to the whole LAN. Pure + static so `MobileBridgeBindScopeTests` can assert this can
    /// never regress. A malformed/empty/non-Tailscale detected IP is dropped, not bound: the
    /// `100.64.0.0/10` (`100.`) prefix is Tailscale's CGNAT range, a second guard against a
    /// spoofed `tailscale ip` returning something routable.
    static func allowedBindHosts(tailscaleIP: String?) -> [String] {
        var hosts = ["127.0.0.1"]
        if let ip = tailscaleIP?.trimmingCharacters(in: .whitespacesAndNewlines),
           !ip.isEmpty, ip != "0.0.0.0", ip != "::", ip.hasPrefix("100.") {
            hosts.append(ip)
        }
        return hosts
    }

    /// P37 B1: current pairing state for the in-app QR panel, read over IPC. `url` is the
    /// live pairing URL — nil until the first token is minted, and nil whenever NO WS listener
    /// is `.ready` (port squatted, R4): a URL nobody is listening behind would render a QR
    /// that can never work, so `enabled == true` + nil URL is exactly the panel's "bridge on
    /// but not listening" error state. `enabled` mirrors `isRunning` — false both when the
    /// bridge was never started AND after `stop()`, matching the toggle's off state now that
    /// `start()`/`stop()` can happen live instead of only once at daemon launch.
    public func currentPairingInfo() -> (url: String?, secondsRemaining: Int, enabled: Bool) {
        guard anyWSListenerReady, let pending = pairingBox.current else { return (nil, 0, isRunning) }
        let remaining = max(0, Int(pending.expiresAt.timeIntervalSinceNow.rounded()))
        return (pending.url, remaining, isRunning)
    }
}
#endif
