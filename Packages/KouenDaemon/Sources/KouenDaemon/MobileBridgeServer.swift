// `Network` (and CoreImage, used only for the QR ascii art) are Apple-platform only —
// this whole bridge is unavailable on the Linux headless daemon build. Guarded here,
// not by moving the file, so it stays alongside the rest of KouenDaemonCore.
#if canImport(Network)
import CoreImage
import Foundation
import KouenCore
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
//      `{"detach":true}`, `{"spawn":{"cwd":"..."}}` (cwd optional).
//   4. Once attached, PTY output arrives as BINARY frames; the client sends keystrokes
//      back as BINARY frames (TEXT frames are always parsed as control messages, never
//      as input — this is how the two are told apart on one connection).
//
// Opt-in only: disabled unless KOUEN_MOBILE_BRIDGE_PORT is set in the daemon's
// environment. Binds loopback + the Tailscale interface only (never all interfaces),
// per the Web/PWA MVP's already-decided reachability posture in the plan doc above.
public final class MobileBridgeServer: @unchecked Sendable {
    private let pairingLifetime: TimeInterval = 15
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
        pairingBox = PairingBox(maxAttempts: maxTokenAttempts)
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

    /// `@unchecked Sendable` with an explicit lock: written by the pairing-loop thread,
    /// read by every WS connection's receive-callback chain. Also owns the P37 A1 failed-
    /// attempt counter, guarded by the SAME lock so a burst of parallel guessing connections
    /// can't race past the limit (the whole point of the limit). Internal for the same
    /// testability reason as `PendingPairing`.
    final class PairingBox: @unchecked Sendable {
        private let lock = NSLock()
        private var _current: PendingPairing?
        private var _failedAttempts = 0
        private let maxAttempts: Int
        init(maxAttempts: Int) { self.maxAttempts = maxAttempts }
        /// Setting a new token (rotation) resets the lockout — a fresh window gets a fresh
        /// budget, which is exactly the "until the next token rotates" release condition.
        var current: PendingPairing? {
            get { lock.lock(); defer { lock.unlock() }; return _current }
            set { lock.lock(); _current = newValue; _failedAttempts = 0; lock.unlock() }
        }
        var isLockedOut: Bool {
            lock.lock(); defer { lock.unlock() }
            return _failedAttempts >= maxAttempts
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
        /// Set once, at authorization — the id `PairedDeviceStore` tracks this
        /// connection under, so a `mobile-revoke-client` can cancel it specifically.
        var deviceID: String? {
            get { lock.lock(); defer { lock.unlock() }; return _deviceID }
            set { lock.lock(); _deviceID = newValue; lock.unlock() }
        }
    }

    /// The pairing page, served by this process itself (see `makePageListener`) — not a
    /// separate file some other HTTP server has to host. Single source of truth: this used
    /// to be `Scripts/mobile-web-test.html` served by a standalone `python3 -m http.server`
    /// the dev script (`mobile-web.sh`) spun up alongside the daemon; that only ever existed
    /// in the dev flow, so the production/preview daemon (spawned by `DaemonLauncher`,
    /// no such script involved) printed a pairing URL nothing was listening on — confirmed
    /// via a direct `curl` against a real `make preview` daemon returning connection refused.
    /// Not the real mobile client (that's W3 — the xterm.js session-switcher UI from
    /// `agent-memory/plans/p25-mobile-session-switcher-design.html`); this is a bare-bones
    /// smoke test: pair, list sessions, spawn, attach, send/receive raw text. No terminal
    /// rendering, no ANSI handling.
    private static let embeddedPageHTML = #"""
    <!doctype html>
    <title>Kouen Mobile Bridge — smoke test</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body { font-family: ui-monospace, monospace; max-width: 640px; margin: 2rem auto; padding: 0 1rem; }
      button { font: inherit; padding: 0.4rem 0.8rem; }
      #output { background: #111; color: #eee; padding: 1rem; height: 300px; overflow: auto; white-space: pre-wrap; }
      #input { width: 100%; font: inherit; padding: 0.4rem; box-sizing: border-box; }
      li { margin: 0.4rem 0; }
    </style>

    <div id="pair">
      <p>Paste the token the daemon printed to its console:
        <input id="token" autocomplete="off">
        <button onclick="connect()">Connect</button>
      </p>
    </div>

    <div id="sessions" style="display:none">
      <h3>Sessions <button onclick="spawnSession()">+ new</button></h3>
      <ul id="list"></ul>
    </div>

    <div id="term" style="display:none">
      <p><button onclick="detach()">&larr; back to sessions</button></p>
      <pre id="output"></pre>
      <input id="input" placeholder="type and press Enter" autocomplete="off">
    </div>

    <script>
      let ws;
      let authed = false;
      const params = new URLSearchParams(location.search);
      const wsPort = params.get('wsport') || 7777;
      // P37 A2: a returning device re-auths with the credentials it was issued on its first
      // pairing (persisted in localStorage), so it never needs another QR scan. keyed per
      // host so credentials from one Mac aren't replayed against another.
      const credKey = 'kouenDeviceCreds:' + location.hostname;
      function storedCreds() { try { return JSON.parse(localStorage.getItem(credKey)); } catch { return null; } }

      function connect() {
        ws = new WebSocket(`ws://${location.hostname}:${wsPort}/`);
        ws.binaryType = 'arraybuffer';
        ws.onopen = () => {
          const creds = storedCreds();
          // Returning device: send deviceAuth instead of the token. On failure (revoked /
          // stale secret) the daemon closes the socket; onclose falls back to a token pairing.
          if (creds) ws.send(JSON.stringify({ deviceAuth: creds }));
          else ws.send(document.getElementById('token').value);
        };
        ws.onerror = (e) => alert('WebSocket error — check the daemon is running and the token is current.');
        ws.onclose = () => {
          // A deviceAuth that got rejected (device revoked, or a stale secret) closes the
          // socket before we ever saw a sessions list — the stored secret is dead, so drop it
          // and reload to the plain token field for a fresh pairing.
          if (storedCreds() && !authed) { localStorage.removeItem(credKey); location.reload(); }
        };
        ws.onmessage = (ev) => {
          if (typeof ev.data === 'string') {
            let msg;
            try { msg = JSON.parse(ev.data); } catch { return; }
            if (msg.deviceCredentials) { localStorage.setItem(credKey, JSON.stringify(msg.deviceCredentials)); return; }
            if (msg.sessions) { authed = true; showSessions(msg.sessions); return; }
            else if (msg.ok === 'attached') showTerm();
            else if (msg.ok === 'detached' || msg.detached) requestSessions();
            else if (msg.error) alert(msg.error);
          } else {
            const text = new TextDecoder().decode(ev.data);
            const out = document.getElementById('output');
            out.textContent += text;
            out.scrollTop = out.scrollHeight;
          }
        };
      }

      function requestSessions() {
        // The daemon already pushes the list right after auth; this just re-shows the
        // last-known list view (a real client would re-request via detach's own push).
        document.getElementById('term').style.display = 'none';
        document.getElementById('sessions').style.display = '';
      }

      function showSessions(sessions) {
        document.getElementById('pair').style.display = 'none';
        document.getElementById('term').style.display = 'none';
        document.getElementById('sessions').style.display = '';
        document.getElementById('list').innerHTML = sessions.map(s =>
          `<li><button onclick='attach(${JSON.stringify(s.surfaceID)})'>${s.tabTitle} — ${s.cwd}</button></li>`
        ).join('') || '<li>(no sessions yet — try + new)</li>';
      }

      function attach(id) { ws.send(JSON.stringify({ attach: id })); }
      function spawnSession() { ws.send(JSON.stringify({ spawn: {} })); }
      function detach() { ws.send(JSON.stringify({ detach: true })); }

      function showTerm() {
        document.getElementById('sessions').style.display = 'none';
        document.getElementById('output').textContent = '';
        document.getElementById('term').style.display = '';
      }

      document.getElementById('input').addEventListener('keydown', (e) => {
        if (e.key !== 'Enter') return;
        ws.send(new TextEncoder().encode(e.target.value + '\n'));
        e.target.value = '';
      });

      // Auto-connect when we can do it without a tap: a stored device credential (returning
      // device, P37 A2) needs no token at all; otherwise a token in the URL (QR scan) — the
      // token expires in pairingLifetime (15s), and phone unlock + camera app + page load
      // already eats into that, so waiting on a manual Connect tap timed out before.
      if (storedCreds()) {
        document.getElementById('pair').style.display = 'none';
        connect();
      } else if (params.get('token')) {
        document.getElementById('token').value = params.get('token');
        connect();
      }
    </script>
    """#

    /// Plain HTTP (no WebSocket upgrade) — serves `embeddedPageHTML` to any GET, ignoring
    /// the path (there's only ever one page). Reads the request just enough to know a full
    /// HTTP request line has arrived, then closes after responding (`Connection: close`),
    /// matching how a phone browser making one page-load request actually behaves.
    private func makePageListener(bindHost: String, port: NWEndpoint.Port) throws -> NWListener {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(bindHost), port: port)
        parameters.allowLocalEndpointReuse = true
        let listener = try NWListener(using: parameters)
        let body = Data(Self.embeddedPageHTML.utf8)
        let response = Data("""
        HTTP/1.1 200 OK\r
        Content-Type: text/html; charset=utf-8\r
        Content-Length: \(body.count)\r
        Connection: close\r
        \r

        """.utf8) + body
        // Captures only the queue (by value), not `self` — this handler needs nothing else
        // from the server, so no retain-cycle/implicit-self question to reason about at all.
        listener.newConnectionHandler = { [bridgeQueue] connection in
            // Found via Agy + Opus verification: a peer that completes the TCP handshake
            // and then just sits there (never sending the GET request line) held this
            // connection, and its fd, open forever — no idle timeout on the `.receive`
            // below. `respondedOrGone` is only ever touched on `bridgeQueue` (the single
            // serial queue every listener/connection callback runs on, per its own doc
            // comment above), so plain state, no lock, is enough to coordinate the
            // watchdog with the real receive completion.
            // `@unchecked Sendable`: every access (the receive completion, the state
            // callback, and the watchdog below) runs on `bridgeQueue`, the single serial
            // queue this class documents at its declaration — queue confinement, not a
            // lock, is what makes this safe, same reasoning as `bridgeQueue`'s own comment.
            final class RespondedFlag: @unchecked Sendable { var value = false }
            let respondedOrGone = RespondedFlag()
            connection.stateUpdateHandler = { state in
                if case .ready = state {
                    // A GET request line always arrives before the client waits for a
                    // response — no need to parse it since this listener only ever
                    // serves the one page regardless of requested path.
                    connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { _, _, _, _ in
                        respondedOrGone.value = true
                        connection.send(content: response, completion: .contentProcessed { _ in
                            connection.cancel()
                        })
                    }
                    bridgeQueue.asyncAfter(deadline: .now() + 5) {
                        guard !respondedOrGone.value else { return }
                        respondedOrGone.value = true
                        connection.cancel()
                    }
                } else if case .cancelled = state {
                    respondedOrGone.value = true
                } else if case .failed = state {
                    respondedOrGone.value = true
                }
            }
            connection.start(queue: bridgeQueue)
        }
        return listener
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

    /// Generates a fresh pairing token, prints its QR, and waits it out before generating
    /// the next one — runs forever on a background thread. No longer needs an interactive
    /// console prompt (the old "pick a session" step): since a token now grants the whole
    /// daemon rather than one surface, there's nothing left to ask the operator to choose.
    /// This also lifts the earlier "must run in a real foreground terminal" constraint.
    private func runPairingLoop(wsPort: UInt16, pageURLPort: Int, log: @escaping @Sendable (String) -> Void) {
        let tailscaleHost = detectTailscaleHost()
        let host = tailscaleHost ?? "127.0.0.1"
        if tailscaleHost == nil {
            log("mobile bridge: Tailscale IP not detected — QR will use loopback (same-Mac testing only)")
        }
        while true {
            let token = String(format: "%06d", Int.random(in: 0..<1_000_000))
            // `makePageListener` serves `embeddedPageHTML` for any path, so the root path
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
            Thread.sleep(forTimeInterval: pairingLifetime)
        }
    }

    // MARK: - Control protocol (client -> bridge, TEXT/JSON)

    private struct ControlMessage: Decodable {
        var attach: String?
        var detach: Bool?
        var spawn: SpawnPayload?
        struct SpawnPayload: Decodable { var cwd: String? }
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

    private func sendText(_ text: String, on connection: NWConnection, completion: @escaping @Sendable () -> Void = {}) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "text", metadata: [metadata])
        connection.send(content: Data(text.utf8), contentContext: context, isComplete: true, completion: .contentProcessed { _ in completion() })
    }

    private func sendBinary(_ data: Data, on connection: NWConnection) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "binary", metadata: [metadata])
        connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed { _ in })
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

    /// Spawns a new session (same daemon call the CLI/GUI use) and immediately attaches
    /// to it — matches the session-switcher mockup's "+ opens the terminal" flow.
    private func handleSpawn(cwd: String?, connection: NWConnection, state: ConnectionState) {
        let client = DaemonClient()
        guard let response = try? client.request(.createSurface(cwd: cwd, shell: nil)),
              case let .surfaceID(newID) = response
        else {
            sendText(#"{"error":"failed to spawn a new session"}"#, on: connection)
            return
        }
        sendJSON(SpawnedAck(surfaceID: newID), on: connection)
        handleAttach(surfaceID: newID, connection: connection, state: state)
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
        } else {
            sendText(#"{"error":"unrecognized control message"}"#, on: connection)
        }
    }

    private func receiveLoop(_ connection: NWConnection, state: ConnectionState) {
        connection.receiveMessage { [weak self] data, context, _, error in
            guard let self else { return }
            if error != nil {
                state.subscription?.cancel()
                return
            }
            guard let data else {
                self.receiveLoop(connection, state: state)
                return
            }
            let isText = (context?.protocolMetadata(definition: NWProtocolWebSocket.definition) as? NWProtocolWebSocket.Metadata)?.opcode == .text

            if !state.authorized {
                guard isText, let text = String(data: data, encoding: .utf8) else {
                    self.sendText(#"{"error":"invalid or expired pairing token"}"#, on: connection) { connection.cancel() }
                    return
                }
                // Returning device (`{deviceAuth}`) is checked FIRST and is exempt from the
                // token lockout below — a phone that paired earlier reconnects with no QR
                // scan even while a brute-forcer has the token path locked out.
                if let deviceID = self.authorizeReturningDevice(text) {
                    state.authorized = true
                    state.deviceID = deviceID
                    self.registerLive(connection, deviceID: deviceID)
                    self.sendSessionList(on: connection)
                    self.receiveLoop(connection, state: state)
                    return
                }
                // New pairing via the rotating 6-digit token. Refuse once the window's
                // attempt budget (P37 A1) is spent — released only when the token rotates.
                guard !self.pairingBox.isLockedOut else {
                    self.sendText(#"{"error":"too many attempts — wait for the next pairing code"}"#, on: connection) { connection.cancel() }
                    return
                }
                guard let pending = self.pairingBox.current,
                      Date() < pending.expiresAt,
                      constantTimeEquals(Array(pending.token.utf8), Array(text.utf8))
                else {
                    if self.pairingBox.recordFailure() {
                        self.log?("mobile bridge: pairing locked out after \(self.maxTokenAttempts) failed token attempts — resets on next token rotation")
                    }
                    self.sendText(#"{"error":"invalid or expired pairing token"}"#, on: connection) { connection.cancel() }
                    return
                }
                // Fresh pairing: mint the device id + re-auth secret, persist it, and hand the
                // client its credentials (once) BEFORE the sessions push, so the page can store
                // them and skip the token on its next connect.
                let deviceID = UUID().uuidString
                let secret = Self.randomSecretHex()
                state.authorized = true
                state.deviceID = deviceID
                self.store?.register(id: deviceID, label: "Mobile device (\(deviceID.prefix(8)))", secret: secret)
                self.registerLive(connection, deviceID: deviceID)
                self.sendJSON(DeviceCredentials(deviceCredentials: .init(id: deviceID, secret: secret)), on: connection)
                self.sendSessionList(on: connection)
                self.receiveLoop(connection, state: state)
                return
            }

            if isText, let text = String(data: data, encoding: .utf8) {
                self.handleControlMessage(text, connection: connection, state: state)
            } else if let surfaceID = state.surfaceID, let subscription = state.subscription {
                _ = subscription.sendInput(data, surfaceID: surfaceID)
            }
            self.receiveLoop(connection, state: state)
        }
    }

    /// Found via Agy + Opus verification: `NWProtocolWebSocket.Options` left
    /// `maximumMessageSize` at its (large) default, so an inbound frame had no explicit cap
    /// BEFORE authentication — hit by the raw byte compare against the pairing token and by
    /// `authorizeReturningDevice`'s JSON decode, both of which run on unauthenticated input.
    /// Every real frame on this protocol is small: control JSON is a few hundred bytes at
    /// most, and PTY input frames are keystrokes — 64 KiB is generous headroom for either
    /// while still bounding what an unauthenticated peer can make the daemon buffer/decode.
    private static let maxWSFrameBytes = 64 * 1024

    private func makeListener(bindHost: String, port: NWEndpoint.Port) throws -> NWListener {
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        wsOptions.maximumMessageSize = Self.maxWSFrameBytes
        let parameters = NWParameters.tcp
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
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
        listener.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            let state = ConnectionState()
            connection.stateUpdateHandler = { [weak self] connState in
                switch connState {
                case .cancelled, .failed:
                    state.subscription?.cancel()
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
            connection.start(queue: bridgeQueue)
            self.receiveLoop(connection, state: state)
            // Found via Agy + Opus verification: `receiveLoop`'s `connection.receive` has the
            // identical Slowloris gap as `makePageListener` above — a peer that completes the
            // WS upgrade and then sends nothing (never even a pairing token) held the
            // connection/fd open forever. Scoped to the pre-auth window only, via
            // `state.authorized` (already lock-protected) — once a connection is authorized,
            // waiting on the next keystroke/control message for arbitrarily long is normal
            // interactive use, not a stall, so no timeout applies past this point.
            bridgeQueue.asyncAfter(deadline: .now() + 5) {
                guard !state.authorized else { return }
                connection.cancel()
            }
        }
        return listener
    }

    /// Starts the WS bridge bound to loopback + (if detected) the Tailscale interface,
    /// and the pairing loop on a background thread. No-op-safe to call once; caller
    /// (main.swift) gates this behind the KOUEN_MOBILE_BRIDGE_PORT opt-in.
    public func start(
        wsPort: UInt16,
        pageURLPort: Int,
        store: PairedDeviceStore,
        log: @escaping @Sendable (String) -> Void
    ) {
        guard let port = NWEndpoint.Port(rawValue: wsPort) else {
            log("mobile bridge: invalid port \(wsPort), not starting")
            return
        }
        self.store = store
        self.log = log
        store.onRevoke = { [weak self] id in self?.cancelConnection(forDeviceID: id) }

        // Every listener (WS + page) binds ONLY the hosts this returns — loopback plus a
        // detected Tailscale IP, never an all-interfaces address (see `allowedBindHosts`).
        let bindHosts = Self.allowedBindHosts(tailscaleIP: detectTailscaleHost())
        for host in bindHosts {
            do {
                let listener = try makeListener(bindHost: host, port: port)
                listener.stateUpdateHandler = { [weak self] state in
                    switch state {
                    case .ready:
                        self?.setWSListener(host: host, ready: true)
                    case .failed(let error):
                        // A squatted port surfaces HERE (bind errors don't throw above with
                        // `allowLocalEndpointReuse`) — mark the host down so the pairing URL
                        // is withheld and the Settings panel shows the failure (R4).
                        log("mobile bridge: WS listener on \(host) failed: \(error)")
                        self?.setWSListener(host: host, ready: false)
                    case .cancelled:
                        self?.setWSListener(host: host, ready: false)
                    default: break
                    }
                }
                listener.start(queue: bridgeQueue)
                listeners.append(listener)
            } catch {
                log("mobile bridge: failed to bind WS on \(host):\(wsPort): \(error)")
            }
        }
        log("mobile bridge: WS listening on \(bindHosts.map { "\($0):\(wsPort)" }.joined(separator: ", "))")

        // The page server serves `embeddedPageHTML` (see `makePageListener`) so it needs the
        // exact same bind scope as the WS listeners — same `bindHosts`, no exceptions.
        if let pagePort = NWEndpoint.Port(rawValue: UInt16(clamping: pageURLPort)) {
            for host in bindHosts {
                do {
                    let pageListener = try makePageListener(bindHost: host, port: pagePort)
                    pageListener.start(queue: bridgeQueue)
                    listeners.append(pageListener)
                } catch {
                    log("mobile bridge: failed to bind page server on \(host):\(pageURLPort): \(error)")
                }
            }
        } else {
            log("mobile bridge: invalid page port \(pageURLPort), pairing page will not be served")
        }

        DispatchQueue.global().async { [weak self] in
            self?.runPairingLoop(wsPort: wsPort, pageURLPort: pageURLPort, log: log)
        }
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
    /// but not listening" error state. `enabled` is always true here — this method is only
    /// reachable once `start()` has run, and main.swift only wires the IPC provider then; a
    /// disabled bridge is represented by the provider being absent (DaemonServer then reports
    /// enabled=false).
    public func currentPairingInfo() -> (url: String?, secondsRemaining: Int, enabled: Bool) {
        guard anyWSListenerReady, let pending = pairingBox.current else { return (nil, 0, true) }
        let remaining = max(0, Int(pending.expiresAt.timeIntervalSinceNow.rounded()))
        return (pending.url, remaining, true)
    }
}
#endif
