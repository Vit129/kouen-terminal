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

        private var _inFlightBytes: Int = 0
        static let maxInFlightBytes: Int = 1 * 1024 * 1024 // 1 MB backpressure cap

        func canSend(bytes: Int) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            if _inFlightBytes + bytes > Self.maxInFlightBytes {
                return false
            }
            _inFlightBytes += bytes
            return true
        }

        func didCompleteSend(bytes: Int) {
            lock.lock()
            defer { lock.unlock() }
            _inFlightBytes = max(0, _inFlightBytes - bytes)
        }
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
    static let embeddedPageHTML = #"""
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title>Kouen Companion</title>
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
      <meta name="theme-color" content="#2f6b4f">
      <meta name="apple-mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
      <link rel="manifest" href="/manifest.json">
      <link rel="icon" href="/icon.svg" type="image/svg+xml">
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:wght@400;700&family=JetBrains+Mono:wght@400;600&display=swap">
      <style>
      :root{
        --bg:#eef1ee; --surface:#ffffff; --ink:#18201c; --muted:#5d6a63; --line:#d8dfda;
        --accent:#2f6b4f; --accent-ink:#ffffff; --accent-soft:#e2efe8;
        --add:#e3f4e8; --add-ink:#1d6b3a; --del:#fbe6e4; --del-ink:#a2342a;
        --warn:#b86e00; --warn-soft:#fff1dc; --run:#2f6b4f; --idle:#8a958f;
        --frame:#cfd7d2; --code-bg:#f5f7f5;
        --f-body:"Atkinson Hyperlegible",-apple-system,system-ui,sans-serif;
        --f-mono:"JetBrains Mono",ui-monospace,Menlo,monospace;
      }
      @media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
        --bg:#0f1412; --surface:#171d1a; --ink:#e4ebe7; --muted:#93a19a; --line:#2a332e;
        --accent:#7cc4a0; --accent-ink:#0c1a13; --accent-soft:#1d2e25;
        --add:#16301f; --add-ink:#8fdcab; --del:#3a1d1a; --del-ink:#f2a097;
        --warn:#f0b357; --warn-soft:#3a2b12; --run:#7cc4a0; --idle:#6c7a73;
        --frame:#2a332e; --code-bg:#111714; color-scheme:dark}}
      :root[data-theme="dark"]{
        --bg:#0f1412; --surface:#171d1a; --ink:#e4ebe7; --muted:#93a19a; --line:#2a332e;
        --accent:#7cc4a0; --accent-ink:#0c1a13; --accent-soft:#1d2e25;
        --add:#16301f; --add-ink:#8fdcab; --del:#3a1d1a; --del-ink:#f2a097;
        --warn:#f0b357; --warn-soft:#3a2b12; --run:#7cc4a0; --idle:#6c7a73;
        --frame:#2a332e; --code-bg:#111714; color-scheme:dark}
      *{box-sizing:border-box}
      html,body{height:100%}
      body{background:var(--bg);color:var(--ink);font:15px/1.45 var(--f-body);margin:0}
      .stage{min-height:100%;display:flex;justify-content:center;align-items:flex-start;gap:32px;padding-block:24px;padding-inline:16px;flex-wrap:wrap}
      .phone{width:100%;max-width:390px;height:780px;max-height:calc(100vh - 48px);min-height:560px;background:var(--surface);border:1px solid var(--frame);border-radius:28px;overflow:hidden;display:flex;flex-direction:column;position:relative}
      @media (max-width:480px){
        .stage{padding:0;gap:0}
        .phone{max-width:none;height:100%;max-height:none;border:0;border-radius:0}
        .stage{height:100%}
      }
      header.bar{display:flex;align-items:center;gap:10px;padding:14px 16px 10px;border-bottom:1px solid var(--line)}
      header.bar h2{font-size:17px;margin:0;flex:1;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
      .sub{color:var(--muted);font-size:12px;font-family:var(--f-mono)}
      button{font:inherit;color:inherit;background:none;border:0;cursor:pointer}
      button:focus-visible,textarea:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
      .icon-btn{width:36px;height:36px;border-radius:10px;display:grid;place-items:center;font-size:18px}
      .icon-btn:hover{background:var(--accent-soft)}
      .scroll{flex:1;overflow-y:auto;min-height:0}

      /* Pairing View */
      #scr-pairing{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;padding:24px;text-align:center;gap:14px}
      #scr-pairing h3{margin:0;font-size:19px;font-weight:700}
      #scr-pairing p{margin:0;color:var(--muted);font-size:13px;max-width:280px}
      .token-input{font-family:var(--f-mono);font-size:22px;letter-spacing:0.18em;text-align:center;width:180px;padding:10px;border-radius:12px;border:1px solid var(--line);background:var(--code-bg);color:var(--ink)}

      /* Sessions */
      .list{display:flex;flex-direction:column}
      .sess{display:grid;grid-template-columns:auto 1fr auto;gap:4px 12px;align-items:center;padding:14px 16px;border-bottom:1px solid var(--line);text-align:left;width:100%}
      .sess:hover{background:var(--accent-soft)}
      .dot{width:10px;height:10px;border-radius:50%;grid-row:span 2}
      .dot.run{background:var(--run);box-shadow:0 0 0 4px var(--accent-soft)}
      .dot.wait{background:var(--warn);box-shadow:0 0 0 4px var(--warn-soft)}
      .dot.idle{background:var(--idle)}
      .sess .name{font-weight:700;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
      .sess .meta{grid-column:2;color:var(--muted);font-size:12px;font-family:var(--f-mono);min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
      .pill{font-size:11px;font-weight:700;padding:2px 8px;border-radius:999px;letter-spacing:.03em;grid-row:span 2}
      .pill.wait{background:var(--warn-soft);color:var(--warn)}
      .pill.run{background:var(--accent-soft);color:var(--accent)}
      .pill.idle{background:var(--code-bg);color:var(--muted)}
      .agent{font-family:var(--f-mono);font-size:11px;color:var(--muted);border:1px solid var(--line);border-radius:6px;padding:0 5px;margin-left:6px;font-weight:400}
      .section-label{font-size:11px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);padding:14px 16px 6px}

      /* Output */
      .out{padding:12px 16px;display:flex;flex-direction:column;gap:10px;font-size:14px}
      .msg{min-width:0}
      .msg.user{align-self:flex-end;background:var(--accent);color:var(--accent-ink);padding:8px 12px;border-radius:14px 14px 4px 14px;max-width:85%}
      .tool{font-family:var(--f-mono);font-size:12px;color:var(--muted);background:var(--code-bg);border:1px solid var(--line);border-radius:8px;padding:6px 10px;overflow-x:auto;white-space:pre}
      .ask{border:1px solid var(--warn);background:var(--warn-soft);border-radius:12px;padding:10px 12px;display:flex;flex-direction:column;gap:8px}
      .ask strong{color:var(--warn)}
      .ask .row{display:flex;gap:8px}
      .btn{padding:8px 14px;border-radius:10px;font-weight:700;font-size:14px}
      .btn.primary{background:var(--accent);color:var(--accent-ink)}
      .btn.ghost{border:1px solid var(--line);background:var(--surface)}

      /* Cards */
      .card{border:1px solid var(--line);border-radius:12px;padding:10px 12px;display:flex;align-items:center;gap:10px;text-align:left;width:100%;background:var(--surface);color:inherit;text-decoration:none}
      .card:hover{background:var(--accent-soft)}
      .card .ic{width:30px;height:30px;border-radius:8px;background:var(--code-bg);display:grid;place-items:center;font-family:var(--f-mono);font-size:13px;flex:none}
      .card .tx{flex:1;min-width:0}
      .card .tx b{display:block;font-size:14px}
      .card .tx span{font-size:12px;color:var(--muted);font-family:var(--f-mono);display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
      .card .go{color:var(--accent);font-weight:700;font-size:13px}

      /* Diff */
      .files{display:flex;flex-direction:column}
      .file{border-bottom:1px solid var(--line)}
      .file summary{list-style:none;display:flex;gap:8px;align-items:center;padding:12px 16px;cursor:pointer}
      .file summary::-webkit-details-marker{display:none}
      .file .path{font-family:var(--f-mono);font-size:13px;flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;direction:rtl;text-align:left}
      .stat{font-family:var(--f-mono);font-size:12px;white-space:nowrap}
      .stat .a{color:var(--add-ink)} .stat .d{color:var(--del-ink)}
      .hunk{font-family:var(--f-mono);font-size:12px;line-height:1.55;overflow-x:auto;background:var(--code-bg)}
      .hunk div{padding:0 12px;white-space:pre}
      .hunk .h{color:var(--muted);padding-block:4px}
      .hunk .add{background:var(--add);color:var(--add-ink)}
      .hunk .del{background:var(--del);color:var(--del-ink)}
      .badge{font-size:10px;font-weight:700;letter-spacing:.05em;padding:1px 6px;border-radius:6px;background:var(--warn-soft);color:var(--warn)}

      /* Preview */
      .pv-src{display:flex;gap:6px;padding:10px 16px;overflow-x:auto}
      .chip{padding:6px 12px;border-radius:999px;border:1px solid var(--line);font-size:13px;white-space:nowrap}
      .chip[aria-pressed="true"]{background:var(--ink);color:var(--surface);border-color:var(--ink)}
      .urlbar{margin:0 16px;font-family:var(--f-mono);font-size:12px;color:var(--muted);background:var(--code-bg);border-radius:8px;padding:6px 10px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
      .mock{margin:10px 16px 16px;border:1px solid var(--line);border-radius:12px;overflow:hidden;background:var(--bg)}
      .mock .hero{padding:22px 16px;background:var(--accent);color:var(--accent-ink)}
      .mock .hero b{display:block;font-size:20px}
      .caption{font-size:12px;color:var(--muted);padding:0 16px 12px}

      /* Composer */
      .composer{border-top:1px solid var(--line);padding:8px 10px calc(10px + env(safe-area-inset-bottom,0px));display:flex;flex-direction:column;gap:6px;background:var(--surface)}
      .inrow{display:flex;gap:6px;align-items:flex-end}
      .inrow textarea{flex:1;min-width:0;resize:none;border:1px solid var(--line);border-radius:14px;padding:9px 12px;font:inherit;background:var(--bg);color:var(--ink);max-height:120px}
      .send{background:var(--accent);color:var(--accent-ink);border-radius:12px;width:40px;height:40px;font-size:18px}
      .send.stopping{background:var(--del);color:var(--del-ink);font-size:14px}
      .attach-list{display:flex;gap:6px;flex-wrap:wrap}
      .att{font-size:12px;background:var(--accent-soft);color:var(--accent);border-radius:8px;padding:2px 8px}

      /* Slide-up Panels & Sheets */
      .panel-bg{position:absolute;inset:0;background:rgba(0,0,0,.35);display:flex;align-items:flex-end;z-index:5}
      .panel{background:var(--surface);width:100%;height:88%;border-radius:20px 20px 0 0;display:flex;flex-direction:column;min-height:0}
      .grab{width:40px;height:5px;border-radius:3px;background:var(--line);margin:8px auto 2px}
      .panel-h{display:flex;align-items:center;gap:8px;padding:6px 12px 10px 16px;border-bottom:1px solid var(--line)}
      .panel-h h3{margin:0;font-size:16px;flex:1}
      @media (prefers-reduced-motion:no-preference){.panel{animation:up .22s ease-out}}
      .edit-link{cursor:pointer;text-decoration:underline dotted;text-underline-offset:3px}

      .menu{position:absolute;top:56px;right:12px;z-index:4;background:var(--surface);border:1px solid var(--line);border-radius:12px;padding:4px;display:flex;flex-direction:column;min-width:190px;box-shadow:0 8px 24px rgba(0,0,0,.18)}
      .menu button{text-align:left;padding:10px 12px;border-radius:8px;display:flex;justify-content:space-between;gap:12px}
      .menu button:hover{background:var(--accent-soft)}
      .menu button:disabled{opacity:.4}

      .toast{position:absolute;left:16px;right:16px;bottom:96px;background:var(--ink);color:var(--surface);border-radius:12px;padding:10px 14px;font-size:14px;display:flex;justify-content:space-between;gap:10px;z-index:10}
      .toast span:last-child{font-family:var(--f-mono);font-size:12px;opacity:.8;white-space:nowrap}
      </style>
    </head>
    <body>
    <div class="stage">
      <div class="phone" id="phone">
        <!-- Pairing screen -->
        <section id="scr-pairing" hidden>
          <div class="dot wait" style="width:24px;height:24px;margin-bottom:8px"></div>
          <h3>Pair Kouen Companion</h3>
          <p>Scan the QR code in Kouen or enter the 6-digit pairing code from the desktop app.</p>
          <input type="text" id="pair-token" class="token-input" maxlength="6" placeholder="000000" autofocus>
          <button class="btn primary" id="pair-btn" style="width:180px">Pair Device</button>
        </section>

        <!-- Sessions screen -->
        <section id="scr-list" style="display:contents">
          <header class="bar">
            <h2>Kouen</h2>
            <span class="sub" id="header-host">tailnet</span>
          </header>
          <div class="scroll">
            <div class="section-label">Needs you</div>
            <div class="list" id="list-wait"></div>
            <div class="section-label">Working</div>
            <div class="list" id="list-run"></div>
            <div class="section-label">Idle</div>
            <div class="list" id="list-idle"></div>
          </div>
        </section>

        <!-- Session screen -->
        <section id="scr-sess" hidden style="display:none">
          <header class="bar">
            <button class="icon-btn" id="back" aria-label="Back to sessions">‹</button>
            <div style="flex:1;min-width:0">
              <h2 id="s-name"></h2>
              <div class="sub" id="s-meta"></div>
            </div>
            <button class="icon-btn" id="more" aria-label="More actions" aria-expanded="false">⋯</button>
            <div class="menu" id="menu" hidden>
              <button id="diff-btn">Diff <span class="stat"><span class="a" id="d-add">+0</span> <span class="d" id="d-del">−0</span></span></button>
              <button id="pv-btn">Preview</button>
              <button id="pr-btn">Draft PR → GitHub</button>
            </div>
          </header>
          <div class="scroll" id="pane"></div>
          <div class="composer">
            <div class="attach-list" id="atts"></div>
            <div class="inrow">
              <label class="icon-btn" for="file" aria-label="Attach file" style="cursor:pointer">📎</label>
              <input type="file" id="file" hidden multiple>
              <textarea id="msg" rows="1" placeholder="Message the agent…"></textarea>
              <button class="send" id="send" aria-label="Send">↑</button>
            </div>
          </div>
        </section>

        <!-- Slide-up Panel (Diff / Preview) -->
        <div class="panel-bg" id="panel" hidden>
          <div class="panel" role="dialog" aria-labelledby="panel-t">
            <div class="grab"></div>
            <div class="panel-h"><h3 id="panel-t"></h3><button class="icon-btn" id="panel-x" aria-label="Close">✕</button></div>
            <div class="scroll" id="panel-body"></div>
          </div>
        </div>


        <!-- Toast -->
        <div class="toast" id="toast" hidden><span id="toast-t"></span><span id="toast-s"></span></div>
      </div>
    </div>

    <script>
    const LABEL = { wait: "WAITING", run: "WORKING", idle: "IDLE" };
    const $ = id => document.getElementById(id);
    let ws = null, sessions = [], cur = null, atts = [], pv = "local", authed = false;
    const params = new URLSearchParams(location.search);
    const wsPort = params.get('wsport') || location.port;
    const credKey = 'kouenDeviceCreds:' + location.hostname;
    function storedCreds() { try { return JSON.parse(localStorage.getItem(credKey)); } catch { return null; } }

    function esc(t) { return (t || '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }
    function stripANSI(str) {
      return (str || '')
        .replace(/\x1b\][^\x07\x1b]*(\x07|\x1b\\)/g, '')
        .replace(/\x1b\[[0-9;?]*[a-zA-Z]/g, '')
        .replace(/\x1b[@-Z\\-_]/g, '')
        .replace(/\r\n/g, '\n')
        .replace(/\r/g, '');
    }

    function renderList() {
      $("header-host").textContent = location.hostname + " · tailnet";
      ["wait", "run", "idle"].forEach(st => {
        const box = $("list-" + st);
        box.innerHTML = "";
        const matched = sessions.filter(s => s.state === st);
        if (matched.length === 0) {
          const empty = document.createElement("div");
          empty.style.padding = "10px 16px";
          empty.style.color = "var(--muted)";
          empty.style.fontSize = "13px";
          empty.textContent = "No " + LABEL[st].toLowerCase() + " sessions";
          box.appendChild(empty);
          return;
        }
        matched.forEach(s => {
          const add = s.files ? s.files.reduce((a, f) => a + f[1], 0) : 0;
          const del = s.files ? s.files.reduce((a, f) => a + f[2], 0) : 0;
          const b = document.createElement("button");
          b.className = "sess";
          b.innerHTML = `<span class="dot ${st}"></span><span class="name">${esc(s.name)}<span class="agent">${esc(s.agent)}</span></span><span class="pill ${st}">${LABEL[st]}</span><span class="meta">${esc(s.branch)} · ${s.files ? s.files.length : 0} files +${add} −${del}</span>`;
          b.onclick = () => openSession(s);
          box.appendChild(b);
        });
      });
    }

    function openSession(s) {
      cur = s;
      $("scr-list").hidden = true; $("scr-list").style.display = "none";
      $("scr-sess").hidden = false; $("scr-sess").style.display = "contents";
      $("s-name").textContent = s.name;
      $("s-meta").textContent = s.agent + " · " + s.branch;
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ attach: s.id }));
        ws.send(JSON.stringify({ gitDiff: { path: s.cwd } }));
      }
      renderPane();
    }

    function back() {
      $("scr-sess").hidden = true; $("scr-sess").style.display = "none";
      $("scr-list").hidden = false; $("scr-list").style.display = "contents";
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ detach: true }));
      }
      cur = null;
      renderList();
    }
    $("back").onclick = back;

    function renderPane() {
      if (!cur) return;
      const p = $("pane");
      const wasAtBottom = (p.scrollHeight - p.scrollTop - p.clientHeight) < 60;
      const items = [...cur.out];

      if (cur.files && cur.files.length > 0 && !items.some(x => x[0] === 'diff')) {
        items.push(["diff"]);
      }
      const port = (cur.ports && cur.ports[0]) || (cur.rawOutput && cur.rawOutput.includes('localhost:') ? (cur.rawOutput.match(/localhost:(\d+)/) || [])[1] : null);
      if (port && !items.some(x => x[0] === 'preview')) {
        items.push(["preview", "http://localhost:" + port + "/"]);
      }
      if (cur.branch && cur.branch !== 'main' && cur.branch !== 'master' && !items.some(x => x[0] === 'pr' || x[0] === 'prdone')) {
        if (cur.pr) items.push(["prdone"]);
        else items.push(["pr"]);
      }

      p.innerHTML = '<div class="out">' + items.map(([k, t]) => {
        if (k === "user") return `<div class="msg user">${esc(t)}</div>`;
        if (k === "tool") return `<div class="tool${t.startsWith("Edit") ? " edit-link" : ""}">${esc(t)}</div>`;
        if (k === "diff") {
          const a = cur.files.reduce((x, f) => x + f[1], 0), d = cur.files.reduce((x, f) => x + f[2], 0);
          return `<button class="card" data-c="diff"><span class="ic">±</span><span class="tx"><b>${cur.files.length} files changed</b><span>+${a} −${d} · ${esc(cur.files.map(f => f[0].split("/").pop()).join(", "))}</span></span><span class="go">Diff</span></button>`;
        }
        if (k === "preview") return `<button class="card" data-c="pv"><span class="ic">◳</span><span class="tx"><b>Dev server running</b><span>${esc(t)}</span></span><span class="go">Open</span></button>`;
        if (k === "pr") return `<button class="card" data-c="pr"><span class="ic">⇡</span><span class="tx"><b>Ready for review</b><span>${esc(cur.branch)} → main</span></span><span class="go">Create draft PR</span></button>`;
        if (k === "prdone") {
          const rawUrl = (cur.pr && cur.pr.url) ? String(cur.pr.url) : '';
          const isSafe = rawUrl.startsWith("https://github.com/");
          const safeUrl = isSafe ? esc(rawUrl) : '#';
          const displayUrl = isSafe ? esc(rawUrl.replace('https://','')) : 'invalid URL';
          const prNum = esc(String(cur.pr ? cur.pr.n : ''));
          return `<a class="card" href="${safeUrl}" target="_blank" rel="noopener noreferrer"><span class="ic">⇡</span><span class="tx"><b>Draft PR #${prNum} opened</b><span>${displayUrl}</span></span><span class="go">GitHub ↗</span></a>`;
        }
        if (k === "ask") return `<div class="ask"><div><strong>Approval needed</strong></div><div class="tool">${esc(t)}</div><div class="row"><button class="btn primary" data-a="y">Allow</button><button class="btn ghost" data-a="n">Deny</button></div></div>`;
        return `<div class="msg">${esc(t)}</div>`;
      }).join("") + '</div>';

      p.querySelectorAll("[data-a]").forEach(b => {
        b.onclick = () => {
          const ans = b.dataset.a;
          if (ws && ws.readyState === WebSocket.OPEN) ws.send(new TextEncoder().encode(ans + '\r'));
          cur.out.push(["tool", (ans === "y" ? "✓ allowed" : "✗ denied")]);
          renderPane();
        };
      });
      p.querySelectorAll(".edit-link").forEach(x => x.onclick = openDiff);
      p.querySelectorAll("[data-c]").forEach(c => {
        c.onclick = () => ({ diff: openDiff, pv: openPreview, pr: openPR })[c.dataset.c]();
      });

      if (wasAtBottom) p.scrollTop = p.scrollHeight;
      const add = cur.files ? cur.files.reduce((x, f) => x + f[1], 0) : 0;
      const del = cur.files ? cur.files.reduce((x, f) => x + f[2], 0) : 0;
      $("d-add").textContent = "+" + add;
      $("d-del").textContent = "−" + del;
      $("diff-btn").disabled = !cur.files || !cur.files.length;
      syncSend();
    }

    function panel(title, html) {
      $("panel-t").textContent = title;
      $("panel-body").innerHTML = html;
      $("panel").hidden = false;
    }
    $("panel-x").onclick = () => { $("panel").hidden = true; };
    $("panel").onclick = e => { if (e.target.id === "panel") $("panel").hidden = true; };

    function openDiff() {
      if (!cur || !cur.files || !cur.files.length) return;
      panel(`Diff · ${cur.files.length} files`,
        '<div class="files">' + cur.files.map(([path, a, d, unc, h], i) => `
          <details class="file" ${i === 0 ? "open" : ""}>
            <summary>
              <span class="path">${esc(path)}</span>
              ${unc ? '<span class="badge">UNCOMMITTED</span>' : ''}
              <span class="stat"><span class="a">+${a}</span> <span class="d">−${d}</span></span>
            </summary>
            <div class="hunk">${(h || []).map(l => `<div class="${l.startsWith("@@") ? "h" : l[0] === "+" ? "add" : l[0] === "-" ? "del" : ""}">${esc(l)}</div>`).join("")}</div>
          </details>
        `).join("") + '</div>'
      );
    }

    function openPreview() {
      if (!cur) return;
      const port = (cur.ports && cur.ports[0]) || (cur.rawOutput && cur.rawOutput.includes('localhost:') ? (cur.rawOutput.match(/localhost:(\d+)/) || [])[1] : null);
      const htmlFile = cur.files ? cur.files.find(f => f[0].toLowerCase().endsWith('.html')) : null;
      const artMatch = cur.rawOutput ? cur.rawOutput.match(/https?:\/\/[^\s<>"']*(?:artifact|preview|page)[^\s<>"']*/i) : null;

      const src = {};
      if (port) {
        src.local = ["Dev server", `http://localhost:${port}/`];
      } else {
        src.local = ["Dev server", "http://localhost:5173/"];
      }
      if (htmlFile) {
        src.html = ["HTML file", htmlFile[0]];
      }
      if (artMatch) {
        src.art = ["Artifact", artMatch[0]];
      }

      if (!src[pv]) pv = Object.keys(src)[0] || 'local';
      const url = src[pv] ? src[pv][1] : src.local[1];

      let bodyHTML = "";
      let captionText = "";
      if (pv === "local") {
        bodyHTML = `
          <div class="pv-viewport" style="background:#fff;border-radius:8px;overflow:hidden;border:1px solid var(--line);min-height:240px;display:flex;align-items:center;justify-content:center;position:relative">
            <div id="pv-loading" style="padding:40px 16px;text-align:center;color:var(--muted);font-size:13px">Connecting to browser mirror…</div>
            <img id="pv-frame" style="width:100%;display:none;object-fit:contain" alt="Preview frame" />
          </div>
          <div class="pv-bar" style="display:flex;gap:8px;margin-top:8px">
            <button class="btn ghost" id="pv-reload" style="padding:6px 12px;font-size:12px">↻ Reload</button>
            <button class="btn ghost" id="pv-snap" style="padding:6px 12px;font-size:12px">📸 Capture</button>
          </div>
        `;
        captionText = "Mirrored live from Mac via Kouen browser mirror.";
      } else if (pv === "html") {
        bodyHTML = `
          <div id="pv-html-content" style="background:#fff;border-radius:8px;min-height:200px;border:1px solid var(--line);padding:12px">
            <div style="color:var(--muted);font-size:13px;text-align:center;padding:24px 0">Loading workspace file…</div>
          </div>
        `;
        captionText = "Rendered from workspace file.";
      } else {
        bodyHTML = `
          <div style="background:var(--surface);border:1px solid var(--line);border-radius:10px;padding:20px;text-align:center">
            <p style="margin:0 0 12px 0;font-size:14px;color:var(--ink)">External artifact detected</p>
            <a class="btn primary" href="${esc(url)}" target="_blank" rel="noopener noreferrer" style="display:inline-block;padding:8px 16px;text-decoration:none">Open artifact ↗</a>
          </div>
        `;
        captionText = "External link.";
      }

      panel("Preview", `
        <div class="pv-src">${Object.entries(src).map(([k, v]) => `<button class="chip" data-pv="${k}" aria-pressed="${k === pv}">${esc(v[0])}</button>`).join("")}</div>
        <div class="urlbar">${esc(url)}</div>
        <div class="mock">${bodyHTML}</div>
        <p class="caption">${esc(captionText)}</p>
      `);

      $("panel-body").querySelectorAll("[data-pv]").forEach(b => {
        b.onclick = () => { pv = b.dataset.pv; openPreview(); };
      });

      if (pv === "local") {
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ browserNavigate: { url } }));
        }
        const rBtn = $("pv-reload");
        if (rBtn) rBtn.onclick = () => { if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ browserReload: true })); };
        const sBtn = $("pv-snap");
        if (sBtn) sBtn.onclick = () => { if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ browserScreenshot: true })); };
      } else if (pv === "html") {
        const fullPath = cur.cwd ? (cur.cwd.replace(/\/$/, '') + '/' + url) : url;
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ readFile: { path: fullPath } }));
        }
      }
    }

    function syncSend() {
      const stop = cur && cur.state === "run" && !$("msg").value.trim() && !atts.length;
      const b = $("send");
      b.textContent = stop ? "■" : "↑";
      b.classList.toggle("stopping", stop);
      b.setAttribute("aria-label", stop ? "Stop agent" : "Send");
    }

    function renderAtts() {
      $("atts").innerHTML = atts.map(a => {
        const name = typeof a === 'object' ? a.name : a;
        const loading = typeof a === 'object' && a.loading;
        return `<span class="att">${loading ? '⏳' : '📎'} ${esc(name)}</span>`;
      }).join("");
    }

    function send(text) {
      if (!text.trim() && !atts.length) {
        if (cur && cur.state === "run") {
          if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ stop: true }));
          }
          cur.out.push(["tool", "■ stopping (Esc sent to pane)"]);
          renderPane();
          toast("Stopping " + cur.name, "Esc sent");
        }
        return;
      }
      const readyPaths = atts.map(a => typeof a === 'object' ? (a.path || a.name) : a).filter(Boolean);
      const toSend = text.trim() + (readyPaths.length ? (text.trim() ? " " : "") + readyPaths.join(" ") : "");
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(new TextEncoder().encode(toSend + '\r'));
      }
      const attNames = atts.map(a => typeof a === 'object' ? a.name : a);
      const fullDisplay = text + (attNames.length ? (text ? "\n" : "") + "📎 " + attNames.join(", ") : "");
      cur.out.push(["user", fullDisplay]);
      atts = [];
      renderAtts();
      $("msg").value = "";
      renderPane();
    }

    function toast(t, s) {
      $("toast-t").textContent = t;
      $("toast-s").textContent = s || '';
      $("toast").hidden = false;
      clearTimeout(toast.h);
      toast.h = setTimeout(() => { $("toast").hidden = true; }, 3200);
    }

    function closeMenu() { $("menu").hidden = true; $("more").setAttribute("aria-expanded", "false"); }
    $("more").onclick = e => {
      e.stopPropagation();
      const m = $("menu");
      m.hidden = !m.hidden;
      $("more").setAttribute("aria-expanded", String(!m.hidden));
    };
    document.addEventListener("click", e => { if (!e.target.closest("#menu") && !e.target.closest("#more")) closeMenu(); });
    $("diff-btn").onclick = () => { closeMenu(); openDiff(); };
    $("pv-btn").onclick = () => { closeMenu(); openPreview(); };
    $("pr-btn").onclick = () => { closeMenu(); openPR(); };

    function openPR() {
      if (!cur) return;
      if (cur.pr) {
        if (cur.pr.url && String(cur.pr.url).startsWith("https://github.com/")) {
          window.open(cur.pr.url, '_blank');
        }
        return;
      }
      toast("Creating draft PR…", "gh pr create --draft");
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ createDraftPR: { title: cur.name || "Draft PR", path: cur.cwd } }));
      }
    }

    $("msg").addEventListener("input", syncSend);
    $("send").onclick = () => send($("msg").value);
    $("msg").addEventListener("keydown", e => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        send($("msg").value);
      }
    });

    $("file").onchange = e => {
      const files = Array.from(e.target.files);
      for (const f of files) {
        const item = { name: f.name, path: null, loading: true };
        atts.push(item);
        const reader = new FileReader();
        reader.onload = ev => {
          const b64 = ev.target.result.split(',')[1];
          if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({
              attachFile: {
                name: f.name,
                mimeType: f.type || "application/octet-stream",
                content: b64
              }
            }));
          }
        };
        reader.readAsDataURL(f);
      }
      renderAtts();
      e.target.value = "";
      syncSend();
    };

    function showPairing() {
      $("scr-pairing").hidden = false;
      $("scr-list").hidden = true; $("scr-list").style.display = "none";
      $("scr-sess").hidden = true; $("scr-sess").style.display = "none";
    }
    function hidePairing() {
      $("scr-pairing").hidden = true;
      if (!cur) {
        $("scr-list").hidden = false; $("scr-list").style.display = "contents";
      }
    }
    $("pair-btn").onclick = () => {
      const val = $("pair-token").value.trim();
      if (val && ws && ws.readyState === WebSocket.OPEN) {
        ws.send(val);
      }
    };

    function handleWSJSON(msg) {
      if (msg.deviceCredentials) {
        localStorage.setItem(credKey, JSON.stringify(msg.deviceCredentials));
        authed = true;
        hidePairing();
      }
      if (msg.sessions) {
        authed = true;
        hidePairing();
        sessions = msg.sessions.map(s => {
          const existing = (cur && cur.id === s.surfaceID) ? cur : (sessions.find(x => x.id === s.surfaceID) || {});
          return {
            id: s.surfaceID,
            name: s.tabTitle || s.cwd.split('/').pop() || 'Session',
            agent: s.agent || (s.tabTitle && s.tabTitle.toLowerCase().includes('claude') ? 'claude' : 'agent'),
            state: s.state || (s.waiting ? 'wait' : 'idle'),
            cwd: s.cwd,
            branch: s.branch || 'main',
            ports: s.ports || [],
            files: existing.files || [],
            out: existing.out || [["text", "Attached to session " + (s.tabTitle || s.surfaceID.slice(0, 8))]],
            rawOutput: existing.rawOutput || "",
            pr: existing.pr || null
          };
        });
        renderList();
        if (cur) {
          const updated = sessions.find(s => s.id === cur.id);
          if (updated) {
            cur.state = updated.state;
            cur.branch = updated.branch;
            cur.agent = updated.agent;
            syncSend();
          }
        }
      }
      if (msg.ok === "attached") {
        if (cur) ws.send(JSON.stringify({ gitDiff: { path: cur.cwd } }));
      }
      if (msg.gitDiff && msg.gitDiff.files) {
        if (cur) {
          cur.files = msg.gitDiff.files.map(f => [f.path, f.additions, f.deletions, f.uncommitted, f.lines]);
          renderPane();
        }
      }
      if (msg.ok === "draftPRCreated" || msg.draftPRCreated) {
        if (cur) {
          const prUrl = msg.url || (msg.draftPRCreated && msg.draftPRCreated.url);
          const prNum = msg.number || (msg.draftPRCreated && msg.draftPRCreated.number) || 1;
          cur.pr = { n: prNum, url: prUrl };
          renderPane();
          toast(`Draft PR #${cur.pr.n} opened`, 'launching GitHub…');
          if (prUrl && prUrl.startsWith('https://github.com/')) {
            window.open(prUrl, '_blank');
          }
        }
      }
      if (msg.ok === "fileAttached" || msg.fileAttached) {
        const filePath = msg.path || (msg.fileAttached && msg.fileAttached.path) || '';
        const fileName = msg.name || (msg.fileAttached && msg.fileAttached.name);
        const item = atts.find(a => typeof a === 'object' && a.loading && (!fileName || a.name === fileName))
                  || atts.find(a => typeof a === 'object' && a.loading);
        if (item) {
          item.path = filePath;
          item.loading = false;
        }
        renderAtts();
        syncSend();
        toast('File attached', (fileName || filePath.split('/').pop()));
      }
      if (msg.ok === "browserOpened" || msg.ok === "browserNavigated") {
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({ browserScreenshot: true }));
        }
      }
      if (msg.browserFrame) {
        const frameImg = $("pv-frame");
        if (frameImg) {
          frameImg.src = "data:image/png;base64," + msg.browserFrame.png;
          frameImg.style.display = "block";
          const loading = $("pv-loading");
          if (loading) loading.style.display = "none";
        }
      }
      if (msg.file) {
        const container = $("pv-html-content");
        if (container) {
          container.innerHTML = `<iframe sandbox srcdoc="${esc(msg.file.content)}" style="width:100%;height:320px;border:0;background:#fff;border-radius:8px"></iframe>`;
        }
      }
      if (msg.error) {
        toast('Error', msg.error);
        if (!authed && msg.error.includes('token')) showPairing();
      }
    }

    function handleTerminalBytes(raw) {
      if (!cur) return;
      const clean = stripANSI(raw);
      if (!clean.trim()) return;
      cur.rawOutput += clean;
      const lines = clean.split('\n').filter(l => l.trim().length > 0);
      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed.startsWith('> ') || trimmed.startsWith('$ ')) {
          cur.out.push(["user", trimmed.slice(2)]);
        } else if (trimmed.startsWith('Edit ') || trimmed.startsWith('Read ') || trimmed.startsWith('Bash: ') || trimmed.startsWith('Running ') || trimmed.startsWith('View ')) {
          cur.out.push(["tool", trimmed]);
          if (trimmed.startsWith('Edit ')) {
            ws.send(JSON.stringify({ gitDiff: { path: cur.cwd } }));
          }
        } else if (trimmed.includes('(y/n)') || trimmed.includes('[y/n]') || trimmed.toLowerCase().includes('approval needed') || trimmed.toLowerCase().includes('permission to')) {
          cur.out.push(["ask", trimmed]);
        } else {
          cur.out.push(["text", trimmed]);
        }
      }
      if (cur.out.length > 200) cur.out = cur.out.slice(-200);
      renderPane();
    }

    let sawServerError = false;
    function showError(msg) { toast('Notice', msg); }

    function connectWS() {
      if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) return;
      const proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
      const wsUrl = proto + '//' + location.hostname + (wsPort ? ':' + wsPort : '') + location.pathname + location.search;
      ws = new WebSocket(wsUrl);
      ws.binaryType = 'arraybuffer';
      ws.onopen = () => {
        const creds = storedCreds();
        if (creds) {
          ws.send(JSON.stringify({ deviceAuth: creds }));
        } else if (params.get('token')) {
          ws.send(params.get('token'));
        } else {
          showPairing();
        }
      };
      ws.onmessage = e => {
        if (typeof e.data === 'string') {
          try { handleWSJSON(JSON.parse(e.data)); } catch (err) {}
        } else if (e.data instanceof ArrayBuffer) {
          handleTerminalBytes(new TextDecoder().decode(e.data));
        }
      };
      ws.onclose = (ev) => {
        if (!sawServerError) {
          showError(ev.code === 1008
            ? 'Pairing rejected — rescan the QR code.'
            : 'Connection lost — check the daemon is running and try again.');
        }
        setTimeout(connectWS, 2000);
      };
      ws.onerror = () => console.error('[kouen mobile] websocket error');
    }

    if ('serviceWorker' in navigator) navigator.serviceWorker.register('/sw.js').catch(() => {});
    document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible' && (!ws || ws.readyState === WebSocket.CLOSED)) connectWS(); });
    window.addEventListener('pageshow', e => { if (e.persisted && (!ws || ws.readyState === WebSocket.CLOSED)) connectWS(); });
    connectWS();
    renderList();
    </script>
    </body>
    </html>
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
    private static let manifestJSON = """
    {
      "name": "Kouen Companion",
      "short_name": "Kouen",
      "description": "Mobile companion for Kouen Terminal and AI Agents",
      "start_url": "/",
      "display": "standalone",
      "background_color": "#171d1a",
      "theme_color": "#2f6b4f",
      "icons": [
        {
          "src": "/icon.svg",
          "sizes": "any",
          "type": "image/svg+xml"
        }
      ]
    }
    """

    static let manifestResponse: Data = {
        let body = manifestJSON
        return Data("""
        HTTP/1.1 200 OK\r
        Content-Type: application/manifest+json; charset=utf-8\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.utf8)
    }()

    private static let serviceWorkerJS = """
    const CACHE_NAME = 'kouen-companion-v1';
    self.addEventListener('install', e => { self.skipWaiting(); });
    self.addEventListener('activate', e => { e.waitUntil(clients.claim()); });
    self.addEventListener('fetch', e => {
      if (e.request.url.includes('/?') || e.request.headers.get('Upgrade') === 'websocket') return;
      e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
    });
    """

    static let serviceWorkerResponse: Data = {
        let body = serviceWorkerJS
        return Data("""
        HTTP/1.1 200 OK\r
        Content-Type: application/javascript; charset=utf-8\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.utf8)
    }()

    private static let iconSVG = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <rect width="100" height="100" rx="22" fill="#2f6b4f"/>
      <path d="M28 25 L40 25 L40 45 L58 25 L74 25 L52 48 L76 75 L60 75 L40 52 L40 75 L28 75 Z" fill="#ffffff"/>
    </svg>
    """

    static let iconResponse: Data = {
        let body = iconSVG
        return Data("""
        HTTP/1.1 200 OK\r
        Content-Type: image/svg+xml; charset=utf-8\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.utf8)
    }()

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
            let requestLine = lines.first ?? ""
            let parts = requestLine.split(separator: " ")
            let path = parts.count >= 2 ? String(parts[1]) : "/"

            let responseToSend: Data
            if path == "/manifest.json" || path.hasPrefix("/manifest.json?") {
                responseToSend = Self.manifestResponse
            } else if path == "/sw.js" || path.hasPrefix("/sw.js?") {
                responseToSend = Self.serviceWorkerResponse
            } else if path == "/icon.svg" || path.hasPrefix("/icon.svg?") {
                responseToSend = Self.iconResponse
            } else {
                responseToSend = pageResponse
            }
            connection.send(content: responseToSend, completion: .contentProcessed { _ in
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
        var gitDiff: GitDiffRequest?
        var createDraftPR: CreateDraftPRRequest?
        var stop: Bool?

        struct GitDiffRequest: Decodable { var path: String? }
        struct CreateDraftPRRequest: Decodable { var title: String?; var path: String? }
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
            var agent: String?
            var branch: String?
            var state: String?
            var waiting: Bool?
            var ports: [Int]?
            var filesAdditions: Int?
            var filesDeletions: Int?
            var filesCount: Int?
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
    struct FileAttachedAck: Codable, Equatable, Sendable { var ok = "fileAttached"; var path: String; var name: String? = nil }
    /// P51 Phase 1. Draft PR created ack sent to mobile client.
    struct DraftPRAck: Codable, Equatable, Sendable { var ok = "draftPRCreated"; var url: String; var number: Int? }

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

    private func sendBinary(_ data: Data, on connection: NWConnection, state: ConnectionState? = nil) {
        let count = data.count
        if let state, !state.canSend(bytes: count) {
            // Never drop bytes mid-stream: the phone's emulator would desync (half an escape
            // sequence, missing redraws). Drop the stalled client instead; on reconnect it
            // re-attaches and gets a clean scrollback replay.
            connection.cancel()
            return
        }
        let frame = Self.encodeWSFrame(opcode: 0x2, payload: data)
        connection.send(content: frame, completion: .contentProcessed { [weak state] _ in
            state?.didCompleteSend(bytes: count)
        })
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
        var agentsBySurfaceID: [String: AgentSessionSummary] = [:]
        if let agentResp = try? client.request(.listAgents), case let .agents(agents) = agentResp {
            for agent in agents {
                agentsBySurfaceID[agent.surfaceID] = agent
            }
        }
        let push = SessionsPush(sessions: surfaces.map { s in
            let agent = agentsBySurfaceID[s.surfaceID]
            let state: String
            if agent?.waiting == true || agent?.activity == .awaiting {
                state = "wait"
            } else if agent?.activity == .working {
                state = "run"
            } else {
                state = "idle"
            }
            return SessionsPush.Entry(
                surfaceID: s.surfaceID,
                tabTitle: s.tabTitle,
                cwd: s.cwd,
                agent: agent?.agentName.lowercased() ?? (s.tabTitle.lowercased().contains("claude") ? "claude" : nil),
                branch: agent?.gitBranch,
                state: state,
                waiting: agent?.waiting,
                ports: agent?.listeningPorts,
                filesAdditions: nil,
                filesDeletions: nil,
                filesCount: nil
            )
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
                onReplay: { [weak self, weak connection, weak state] text in
                    guard let connection, let state else { return }
                    self?.sendBinary(Data(text.utf8), on: connection, state: state)
                },
                onData: { [weak self, weak connection, weak state] data, _ in
                    guard let connection, let state else { return }
                    self?.sendBinary(data, on: connection, state: state)
                },
                onEnd: { [weak self, weak connection, weak state] in
                    // Only announce a real end — an intentional detach/re-attach already
                    // cleared `state.subscription` to nil before cancelling (see above),
                    // so a nil here means this callback is the echo of that, not news.
                    guard let state, let connection, state.subscription != nil else { return }
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
        sendJSON(FileAttachedAck(path: path, name: name), on: connection)
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

    struct ProcessRunResult: Equatable, Sendable {
        var status: Int32
        var stdout: String
        var stderr: String
        var timedOut: Bool
    }

    /// Unified process runner with concurrent pipe draining and hard timeout.
    /// Drains both stdout and stderr concurrently via PipeBuffer to prevent pipe buffer deadlocks.
    static func runProcess(
        executableURL: URL,
        arguments: [String],
        cwd: String? = nil,
        timeoutSeconds: TimeInterval
    ) -> ProcessRunResult {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        if let cwd = cwd, !cwd.isEmpty {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        }
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        let outBuffer = PipeBuffer()
        let errBuffer = PipeBuffer()
        outPipe.fileHandleForReading.readabilityHandler = { handle in
            let chunk = handle.availableData
            if !chunk.isEmpty { outBuffer.append(chunk) }
        }
        errPipe.fileHandleForReading.readabilityHandler = { handle in
            let chunk = handle.availableData
            if !chunk.isEmpty { errBuffer.append(chunk) }
        }
        defer {
            outPipe.fileHandleForReading.readabilityHandler = nil
            errPipe.fileHandleForReading.readabilityHandler = nil
        }

        do {
            try process.run()
        } catch {
            return ProcessRunResult(status: -1, stdout: "", stderr: error.localizedDescription, timedOut: false)
        }

        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        var timedOut = false
        if process.isRunning {
            timedOut = true
            process.terminate()
        }
        process.waitUntilExit()

        let outStr = String(data: outBuffer.snapshot(), encoding: .utf8) ?? ""
        let errStr = String(data: errBuffer.snapshot(), encoding: .utf8) ?? ""

        return ProcessRunResult(
            status: process.terminationStatus,
            stdout: outStr,
            stderr: errStr,
            timedOut: timedOut
        )
    }

    /// Cached `claude` CLI path resolution — mirrors `GitHubCLIClient.cachedGhPath`'s shape
    /// (`Packages/KouenCore/Sources/KouenCore/GitHub/GitHubCLIClient.swift`): common install
    /// locations first, `which` fallback for non-standard installs.
    private static let cachedClaudePath: String? = {
        let paths = [
            NSHomeDirectory() + "/.local/bin/claude",
            "/opt/homebrew/bin/claude",
            "/usr/local/bin/claude",
        ]
        if let found = paths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            return found
        }
        let res = runProcess(
            executableURL: URL(fileURLWithPath: "/usr/bin/which"),
            arguments: ["claude"],
            timeoutSeconds: 5
        )
        guard res.status == 0 else { return nil }
        let path = res.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else { return nil }
        return path
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
        let res = runProcess(
            executableURL: URL(fileURLWithPath: claudePath),
            arguments: ["-p", prompt],
            cwd: cwd,
            timeoutSeconds: timeoutSeconds
        )
        if res.timedOut {
            return .failure("claude CLI timed out")
        }
        if res.status == 0 {
            let firstLine = Self.firstLine(of: res.stdout.trimmingCharacters(in: .whitespacesAndNewlines))
            return firstLine.isEmpty ? .failure("claude CLI returned no suggestion") : .success(firstLine)
        }
        let errText = res.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        return .failure(StringError(errText.isEmpty ? "claude CLI failed" : errText))
    }

    public struct GitDiffFile: Encodable, Sendable, Equatable {
        public var path: String
        public var additions: Int
        public var deletions: Int
        public var uncommitted: Bool
        public var lines: [String]

        public init(path: String, additions: Int, deletions: Int, uncommitted: Bool, lines: [String]) {
            self.path = path
            self.additions = additions
            self.deletions = deletions
            self.uncommitted = uncommitted
            self.lines = lines
        }
    }

    public static func parseGitDiffOutput(_ diffOutput: String) -> [GitDiffFile] {
        var results: [GitDiffFile] = []
        if diffOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }

        let lines = diffOutput.components(separatedBy: "\n")
        var currentFile: String?
        var currentAdditions = 0
        var currentDeletions = 0
        var currentHunkLines: [String] = []

        func flushCurrent() {
            if let file = currentFile {
                results.append(GitDiffFile(
                    path: file,
                    additions: currentAdditions,
                    deletions: currentDeletions,
                    uncommitted: true,
                    lines: currentHunkLines
                ))
            }
            currentFile = nil
            currentAdditions = 0
            currentDeletions = 0
            currentHunkLines = []
        }

        for line in lines {
            if line.hasPrefix("diff --git ") {
                flushCurrent()
                let parts = line.components(separatedBy: " ")
                if parts.count >= 4 {
                    let bPart = parts[3]
                    currentFile = bPart.hasPrefix("b/") ? String(bPart.dropFirst(2)) : bPart
                }
            } else if line.hasPrefix("+++ b/") {
                currentFile = String(line.dropFirst(6))
            } else if line.hasPrefix("--- a/") && currentFile == nil {
                currentFile = String(line.dropFirst(6))
            } else if line.hasPrefix("@@") {
                currentHunkLines.append(line)
            } else if currentFile != nil {
                if line.hasPrefix("+") && !line.hasPrefix("+++") {
                    currentAdditions += 1
                    currentHunkLines.append(line)
                } else if line.hasPrefix("-") && !line.hasPrefix("---") {
                    currentDeletions += 1
                    currentHunkLines.append(line)
                } else if line.hasPrefix(" ") {
                    currentHunkLines.append(line)
                }
            }
        }
        flushCurrent()
        return results
    }

    public static func parseGitDiff(in cwd: String) -> [GitDiffFile] {
        let res = runProcess(
            executableURL: URL(fileURLWithPath: "/usr/bin/git"),
            arguments: ["diff", "HEAD", "--", "."],
            cwd: cwd,
            timeoutSeconds: 10
        )
        var diffOutput = res.stdout
        if diffOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !res.timedOut {
            let fallbackRes = runProcess(
                executableURL: URL(fileURLWithPath: "/usr/bin/git"),
                arguments: ["diff"],
                cwd: cwd,
                timeoutSeconds: 10
            )
            diffOutput = fallbackRes.stdout
        }
        return parseGitDiffOutput(diffOutput)
    }

    static func surfaceCwd(surfaceID: String?, client: DaemonClient = DaemonClient()) -> String? {
        guard let surfaceID = surfaceID, !surfaceID.isEmpty else { return nil }
        guard let response = try? client.request(.listSurfaces),
              case let .surfaces(surfaces) = response else { return nil }
        return surfaces.first { $0.surfaceID == surfaceID }?.cwd
    }

    enum CwdAuthorizationError: Error, Equatable {
        case missingSessionOrCwd
        case foreignPathRejected
        case other(String)

        var message: String {
            switch self {
            case .missingSessionOrCwd:
                return "missing active session surface or cwd"
            case .foreignPathRejected:
                return "foreign or unauthorized path rejected"
            case .other(let msg):
                return msg
            }
        }
    }

    /// Validates that cwd resolves from the active surface session.
    /// If the client passes a requested path, it must match or be a descendant within the surface cwd.
    /// Foreign paths are strictly rejected.
    static func resolveAuthorizedCwd(
        requestedPath: String?,
        surfaceID: String?,
        surfaceLookup: (String) -> String? = { surfaceCwd(surfaceID: $0) }
    ) -> Result<String, CwdAuthorizationError> {
        guard let surfaceID = surfaceID, let cwd = surfaceLookup(surfaceID), !cwd.isEmpty else {
            return .failure(.missingSessionOrCwd)
        }
        if let requested = requestedPath?.trimmingCharacters(in: .whitespacesAndNewlines), !requested.isEmpty {
            let reqURL = URL(fileURLWithPath: requested).standardizedFileURL.path
            let cwdURL = URL(fileURLWithPath: cwd).standardizedFileURL.path
            if reqURL != cwdURL && !reqURL.hasPrefix(cwdURL + "/") {
                return .failure(.foreignPathRejected)
            }
            return .success(reqURL)
        }
        return .success(cwd)
    }

    private func handleGitDiff(path: String?, connection: NWConnection, state: ConnectionState) {
        let cwd: String
        switch Self.resolveAuthorizedCwd(requestedPath: path, surfaceID: state.surfaceID) {
        case .failure(let error):
            sendText(#"{"error":"\#(error.message)"}"#, on: connection)
            return
        case .success(let resolved):
            cwd = resolved
        }

        let files = Self.parseGitDiff(in: cwd)
        struct GitDiffPayload: Encodable {
            var files: [GitDiffFile]
        }
        struct GitDiffAck: Encodable {
            var gitDiff: GitDiffPayload
        }
        sendJSON(GitDiffAck(gitDiff: GitDiffPayload(files: files)), on: connection)
    }

    private func handleCreateDraftPR(title: String?, path: String?, connection: NWConnection, state: ConnectionState) {
        let cwd: String
        switch Self.resolveAuthorizedCwd(requestedPath: path, surfaceID: state.surfaceID) {
        case .failure(let error):
            sendText(#"{"error":"\#(error.message)"}"#, on: connection)
            return
        case .success(let resolved):
            cwd = resolved
        }

        let prTitle = (title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? title! : "Draft PR"
        let res = Self.runProcess(
            executableURL: URL(fileURLWithPath: "/usr/bin/env"),
            arguments: ["gh", "pr", "create", "--draft", "--title", prTitle, "--fill"],
            cwd: cwd,
            timeoutSeconds: 30
        )

        if res.timedOut {
            sendJSON(ErrorAck(error: "gh command timed out after 30s"), on: connection)
            return
        }

        let output = res.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let errOutput = res.stderr.trimmingCharacters(in: .whitespacesAndNewlines)

        if res.status == 0 && output.contains("github.com") {
            let prUrl = output.components(separatedBy: .whitespacesAndNewlines).last { $0.hasPrefix("http") } ?? output
            let prNum = Int(prUrl.components(separatedBy: "/").last ?? "")
            sendJSON(DraftPRAck(url: prUrl, number: prNum), on: connection)
        } else {
            let errMsg = !errOutput.isEmpty ? errOutput : (!output.isEmpty ? output : "gh command failed")
            sendJSON(ErrorAck(error: errMsg), on: connection)
        }
    }

    private func handleStop(connection: NWConnection, state: ConnectionState) {
        guard let surfaceID = state.surfaceID, let subscription = state.subscription else {
            sendText(#"{"error":"no active session attached to stop"}"#, on: connection)
            return
        }
        _ = subscription.sendInput(Data([0x1b]), surfaceID: surfaceID)
        sendText(#"{"ok":"stopped"}"#, on: connection)
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
        } else if let gitDiff = message.gitDiff {
            state.controlQueue.async { [weak self] in
                self?.handleGitDiff(path: gitDiff.path, connection: connection, state: state)
            }
        } else if let pr = message.createDraftPR {
            state.controlQueue.async { [weak self] in
                self?.handleCreateDraftPR(title: pr.title, path: pr.path, connection: connection, state: state)
            }
        } else if message.stop == true {
            state.controlQueue.async { [weak self] in
                self?.handleStop(connection: connection, state: state)
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
                    state.subscription = nil
                    // Connection is going away for good (unlike a per-attach detach), so the
                    // whole-connection session-list subscription dies with it too.
                    state.snapshotSubscription?.cancel()
                    state.snapshotSubscription = nil
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
