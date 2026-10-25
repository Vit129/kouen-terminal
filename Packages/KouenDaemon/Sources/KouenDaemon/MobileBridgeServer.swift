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
    let pairingBox: PairingBox
    /// P37 A3: one dedicated serial queue for every listener accept AND every connection's
    /// send/receive callbacks — moves the whole bridge off the daemon's `.main` queue so a
    /// flooding/slow mobile peer can't stall the GUI's PTY relay. Serial (not concurrent):
    /// per-connection frame ordering is load-bearing (control-vs-input demux, PTY byte
    /// order), and one serial queue preserves it without per-connection locking.
    let bridgeQueue = DispatchQueue(label: "com.vit129.kouen.mobile-bridge")
    var listeners: [(host: String, listener: NWListener)] = []
    /// `listeners` is appended from `start()` AND from the pairing loop (Tailscale coming up
    /// late), and drained by `stop()` on the caller's thread — all three race without this.
    let listenersLock = NSLock()
    var store: PairedDeviceStore?
    let liveConnectionsLock = NSLock()
    var liveConnections: [String: NWConnection] = [:]
    /// Retained from `start()` so the receive loop can log a lockout (P37 A1) from off the
    /// pairing-loop thread. Set once, before any connection is accepted.
    var log: (@Sendable (String) -> Void)?
    /// P37 B2 (plan risk R4): bind hosts whose WS listener is currently `.ready`, keyed by
    /// host so a late `.failed` only clears its own entry. When this is empty the pairing URL
    /// is withheld from `currentPairingInfo` — the Settings panel then shows "not listening"
    /// instead of a QR that could never work (the silent-port-squat failure W1 already hit).
    /// Own lock (not `liveConnectionsLock`): touched from listener state callbacks on
    /// `bridgeQueue` AND from IPC reads on the daemon queue.
    let wsReadyLock = NSLock()
    var wsReadyHosts: Set<String> = []

    /// Lets `start()`/`stop()` be called repeatedly on the same instance — the daemon now
    /// owns one `MobileBridgeServer` for its whole lifetime and starts/stops it in place from
    /// `.setMobileBridgeEnabled` (Settings toggle), instead of a full daemon restart minting a
    /// fresh instance each time. Also the cancellation flag `runPairingLoop` polls between
    /// token rotations, since its sleep can no longer just run forever.
    private let lifecycleLock = NSLock()
    private var _isRunning = false
    var isRunning: Bool {
        get { lifecycleLock.lock(); defer { lifecycleLock.unlock() }; return _isRunning }
        set { lifecycleLock.lock(); _isRunning = newValue; lifecycleLock.unlock() }
    }

    func setWSListener(host: String, ready: Bool) {
        wsReadyLock.lock()
        if ready { wsReadyHosts.insert(host) } else { wsReadyHosts.remove(host) }
        wsReadyLock.unlock()
    }

    var anyWSListenerReady: Bool {
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
    let maxTokenAttempts = 5

    /// Slowloris guard for both listeners (page + WS) — a peer that never sends its first
    /// byte (page: the GET line; WS: the connection is created and this starts counting
    /// immediately, before the WS upgrade handshake even completes — see its use site) gets
    /// dropped after this. Was 5s; too tight for the WS listener specifically once a real
    /// phone tested over a Tailscale connection still doing DERP-relay/NAT-traversal
    /// negotiation on its first connection — that adds real round-trip latency BEFORE the
    /// WS upgrade handshake, browser `onopen`, and the client's first token frame can all
    /// complete, unlike the page listener's window (which only starts once TCP is already
    /// `.ready`, and needs just one more simple GET+response over an already-warm path).
    let preAuthTimeout: TimeInterval = 15

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
    final class ConnectionState: @unchecked Sendable {
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
        /// P57: per-attach slow timer (re-resolves the transcript URL + re-arms the file watcher) that tails the attached agent's own transcript file. Replaced
        /// on every attach, cancelled on detach and disconnect — same lifetime as `subscription`.
        var transcriptTimer: DispatchSourceTimer? {
            get { lock.lock(); defer { lock.unlock() }; return _transcriptTimer }
            set {
                lock.lock(); let old = _transcriptTimer; _transcriptTimer = newValue; lock.unlock()
                old?.cancel()
                if newValue == nil { transcriptWatcher = nil } // tail stopped: release the fd too
            }
        }
        private var _transcriptTimer: DispatchSourceTimer?
        /// Watches the resolved transcript file so `startTranscriptTail` reads only on change.
        /// Same lifetime as `transcriptTimer`: replacing/clearing it cancels the old watcher,
        /// whose cancel handler closes the file descriptor.
        var transcriptWatcher: TranscriptFileWatcher? {
            get { lock.lock(); defer { lock.unlock() }; return _transcriptWatcher }
            set { lock.lock(); let old = _transcriptWatcher; _transcriptWatcher = newValue; lock.unlock(); old?.cancel() }
        }
        private var _transcriptWatcher: TranscriptFileWatcher?
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
        /// Claude's permission mode as last seen in the transcript: where a Shift+Tab cycle starts.
        var agentMode: String? {
            get { lock.lock(); defer { lock.unlock() }; return _agentMode }
            set { lock.lock(); _agentMode = newValue; lock.unlock() }
        }
        private var _agentMode: String?

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


    /// One connection can be either a plain page load OR a WS upgrade — both now share the
    /// same port/listener (see the framing section's doc comment for why), so every accepted
    /// connection reads its HTTP request headers first and branches on whether they ask for
    /// a WS upgrade. `leftover` carries any bytes read past the blank line terminating the
    /// headers into the WS frame buffer, in case a client pipelines its first frame before
    /// waiting for the 101 response (real browsers don't, but nothing forbids it).
    func readRequestHeader(connection: NWConnection, state: ConnectionState, buffer: Data, pageResponse: Data) {
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

    /// Generates a fresh pairing token, prints its QR, and waits it out before generating
    /// the next one — runs on a background thread until `stop()` flips `isRunning` false.
    /// Dynamically re-checks Tailscale and Tailscale Serve if they were not online at launch.
    func runPairingLoop(
        wsPort: UInt16,
        pageURLPort: Int,
        tailscaleHost: String?,
        magicDNSName: String?,
        log: @escaping @Sendable (String) -> Void
    ) {
        var currentTailscaleHost = tailscaleHost
        var currentMagicDNSName = magicDNSName
        var serveActive = currentMagicDNSName != nil && Self.isTailscaleServeConfigured(port: pageURLPort)
        if currentTailscaleHost == nil {
            log("mobile bridge: Tailscale IP not detected — QR will use loopback (same-Mac testing only)")
        } else if !serveActive {
            log("mobile bridge: Tailscale Serve HTTPS not detected — run 'tailscale serve --bg \(pageURLPort)' to enable HTTPS for PWA installation")
        }
        var notReadyTicks = 0
        var warnedNoListener = false
        // Wall-clock, not a tick counter: once a token is minted the loop sits in the 120s
        // sleep below, so a per-iteration counter only fired every ~16 minutes.
        var lastRecheck = Date()
        // True when the pairing host/scheme changed, so the live QR must be re-minted.
        // Fast while Tailscale is absent (the user is likely bringing it up right now), slow
        // once known: every probe spawns up to three `tailscale` subprocesses.
        func recheckTailscale() -> Bool {
            let interval: TimeInterval = currentTailscaleHost == nil ? 2 : 30
            guard Date().timeIntervalSince(lastRecheck) >= interval else { return false }
            lastRecheck = Date()
            // Through `allowedBindHosts` so a late bind obeys the same no-LAN invariant as start().
            let detectedIP = Self.allowedBindHosts(tailscaleIP: detectTailscaleHost()).dropFirst().first
            var changed = false
            if detectedIP != currentTailscaleHost {
                if let old = currentTailscaleHost { cancelListener(bindHost: old) }
                if let ip = detectedIP, let port = NWEndpoint.Port(rawValue: UInt16(clamping: pageURLPort)) {
                    bindUnifiedListener(bindHost: ip, port: port, log: log)
                }
                log("mobile bridge: Tailscale IP changed (\(currentTailscaleHost ?? "none") → \(detectedIP ?? "none")) — rebound listener and updated pairing host")
                currentTailscaleHost = detectedIP
                currentMagicDNSName = nil
                changed = true
            }
            guard currentTailscaleHost != nil else {
                if serveActive { serveActive = false; changed = true }
                return changed
            }
            if currentMagicDNSName == nil, let dns = detectTailscaleMagicDNSName() {
                currentMagicDNSName = dns
                changed = true
                log("mobile bridge: Tailscale MagicDNS detected (\(dns))")
            }
            let serveNow = currentMagicDNSName != nil && Self.isTailscaleServeConfigured(port: pageURLPort)
            if serveNow != serveActive {
                serveActive = serveNow
                changed = true
                log("mobile bridge: Tailscale Serve HTTPS \(serveNow ? "detected — pairing URL is now HTTPS" : "gone — pairing URL back to HTTP")")
            }
            return changed
        }
        // Each re-check spawns `tailscale` subprocesses; this loop never returns, so drain
        // their autoreleased objects per call instead of never.
        while isRunning {
            _ = autoreleasepool(invoking: recheckTailscale)

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
            let host = currentTailscaleHost ?? "127.0.0.1"
            let url = Self.buildPairingURL(
                host: host,
                pageURLPort: pageURLPort,
                wsPort: wsPort,
                token: token,
                magicDNSName: currentMagicDNSName,
                isServeActive: serveActive
            )
            pairingBox.current = PendingPairing(token: token, url: url, expiresAt: Date().addingTimeInterval(pairingLifetime))
            print("\nScan with your iPhone's Camera app — valid \(Int(pairingLifetime))s, grants access to every session on this Mac:\n")
            print(qrAsciiArt(for: url) ?? "(QR generation failed — open this URL manually)")
            print("\n\(url)\n")
            // A Mac can't open TCP to its own Tailscale IP (ping works, connect times out), so the
            // phone URL above never loads on this Mac; give the loopback one too (same token).
            if host != "127.0.0.1" || serveActive {
                let local = Self.buildPairingURL(host: "127.0.0.1", pageURLPort: pageURLPort, wsPort: wsPort, token: token)
                print("On this Mac: \(local)\n")
            }
            fflush(stdout)
            var slept: TimeInterval = 0
            while slept < pairingLifetime && isRunning {
                Thread.sleep(forTimeInterval: 0.25)
                slept += 0.25
                if autoreleasepool(invoking: recheckTailscale) { break }
            }
        }
    }

    // MARK: - Control protocol (client -> bridge, TEXT/JSON)

    struct ControlMessage: Decodable {
        /// `{"ping":N}` → `{"pong":N}`: the page's liveness check. iOS can leave a suspended
        /// socket reporting OPEN while it is dead; a missed pong makes the page reconnect.
        var ping: Int?
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
        /// `{"agentCommand":{"kind":"model|effort|mode","value":"..."}}` — drives the attached Claude
        /// Code TUI through its own slash commands / Shift+Tab; values are allowlisted server-side.
        var agentCommand: AgentCommandRequest?
        /// `{"agyModels":true}` — asks for agy's current model list (`AgyModelCatalog`).
        var agyModels: Bool?

        /// `agent` is the page's own idea of the agent ("claude-code"/"antigravity"), used only when the
        /// daemon's detector has nothing for the pane (agy is often missed right after launch).
        struct AgentCommandRequest: Decodable { var kind: String; var value: String; var agent: String? }
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
            /// `AgentKind.rawValue`, the key into the page's `AGENT_ICONS`.
            var kind: String?
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
    /// P57: `{"transcript":{"reset":true,"items":[…]}}`. `reset` = replace what the client shows
    /// (first send after attach, or the agent switched sessions via /clear or /resume); otherwise
    /// append. Absent entirely for a surface with no transcript — the client keeps its raw view.
    struct TranscriptPush: Encodable {
        struct Body: Encodable {
            var reset: Bool
            var items: [TranscriptItem]
            var model: String?
            var mode: String?
            var usage: AgentUsage?
        }
        var transcript: Body
    }
    static let transcriptBacklogLimit = 200
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
    private struct AgyModelsPush: Encodable {
        struct Body: Encodable { var models: [[String]]; var efforts: [String] }
        var agyModels: Body
    }
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
    struct DeviceCredentials: Encodable {
        struct Cred: Encodable { var id: String; var secret: String }
        var deviceCredentials: Cred
    }

    /// 32 random bytes as 64 lowercase hex chars — the per-device re-auth secret. 256 bits of
    /// entropy makes the secret (unlike the 6-digit token) infeasible to guess, so device
    /// re-auth needs no rate limit of its own.
    static func randomSecretHex() -> String {
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
    func registerLive(_ connection: NWConnection, deviceID: String) {
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
    func authorizeReturningDevice(_ text: String) -> String? {
        guard let data = text.data(using: .utf8),
              let envelope = try? JSONDecoder().decode(DeviceAuthEnvelope.self, from: data),
              let auth = envelope.deviceAuth,
              store?.authenticate(id: auth.id, secret: auth.secret) == true
        else { return nil }
        return auth.id
    }

    func sendSessionList(on connection: NWConnection) {
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
                kind: agent?.kind.rawValue ?? (s.tabTitle.lowercased().contains("claude") ? AgentKind.claudeCode.rawValue : nil),
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
    func startSessionListSubscription(on connection: NWConnection, state: ConnectionState) {
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
        state.transcriptTimer = nil
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
            startTranscriptTail(surfaceID: surfaceID, connection: connection, state: state)
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

    /// Streams the attached agent's own transcript (Claude, Antigravity, Codex) as typed items, so the
    /// phone shows real user/assistant/tool bubbles instead of ANSI-stripped TUI redraws.
    /// A slow 5s timer re-resolves pid/surface → transcript (`/clear` and `/resume` swap the session
    /// file) and re-arms a `TranscriptFileWatcher` on it; the read/parse/push path itself runs only
    /// when that watcher reports the file changed. Both run on `state.controlQueue` (serial), so the
    /// captured locals below need no lock.
    private func startTranscriptTail(surfaceID: String, connection: NWConnection, state: ConnectionState) {
        var url: URL?
        var offset = 0
        var cachedCwd: String?
        var lastCwdCheck: Date = .distantPast
        var lastUrlCheck: Date = .distantPast
        var lastPid: Int32?
        var kind: AgentKind?
        var watchedURL: URL?

        // Read new lines from `url`, parse, push. `reset` = the URL just changed (backlog replay).
        let readAndPush: (NWConnection, ConnectionState, Bool) -> Void = { [weak self] connection, state, reset in
            guard let self, state.surfaceID == surfaceID, let current = url, let kind else { return }
            guard let read = AgentHistoryScanner.readJSONLLines(from: current, fromOffset: offset) else {
                offset = 0 // truncated or replaced: start over next read
                return
            }
            offset = read.endOffset

            // Performance: on initial attach or reset, only parse the tail lines needed for backlog
            let linesToProcess = reset ? Array(read.lines.suffix(Self.transcriptBacklogLimit * 2)) : read.lines

            var items: [TranscriptItem]
            let metaModel: String?
            let metaMode: String?
            let metaUsage: AgentUsage?

            switch kind {
            case .claudeCode:
                items = linesToProcess.flatMap(ClaudeTranscriptLine.items(from:))
                let meta = ClaudeTranscriptLine.meta(from: read.lines)
                metaModel = meta.model
                metaMode = meta.mode
                metaUsage = meta.usage
            case .antigravity:
                items = linesToProcess.flatMap(AntigravityTranscriptLine.items(from:))
                let meta = AntigravityTranscriptLine.meta(from: read.lines)
                metaModel = meta.model
                metaMode = meta.mode
                metaUsage = meta.usage
            case .codex:
                items = linesToProcess.flatMap(CodexTranscriptLine.items(from:))
                let meta = CodexTranscriptLine.meta(from: read.lines)
                metaModel = meta.model
                metaMode = meta.mode
                metaUsage = meta.usage
            default:
                items = []
                metaModel = nil
                metaMode = nil
                metaUsage = nil
            }

            if reset { items = Array(items.suffix(Self.transcriptBacklogLimit)) }
            if let mode = metaMode { state.agentMode = mode }
            guard reset || !items.isEmpty || metaModel != nil || metaMode != nil || metaUsage != nil else { return }
            self.sendJSON(TranscriptPush(transcript: .init(
                reset: reset,
                items: items,
                model: metaModel,
                mode: metaMode,
                usage: metaUsage
            )), on: connection)
        }

        let timer = DispatchSource.makeTimerSource(queue: state.controlQueue)
        timer.schedule(deadline: .now(), repeating: 5.0, leeway: .milliseconds(500))
        timer.setEventHandler { [weak self, weak connection, weak state] in
            guard let self, let connection, let state, state.surfaceID == surfaceID,
                  let snap = AgentDetector.snapshot(forSurfaceKey: surfaceID) else { return }

            let now = Date()
            let pidChanged = (snap.pid != lastPid)
            if pidChanged {
                lastPid = snap.pid
                cachedCwd = nil
                url = nil
                offset = 0
            }

            // Avoid opening a new DaemonClient socket on every tick:
            // CWD only needs refresh if unknown, PID changed, or every 5 seconds.
            let cwd: String?
            if let cached = cachedCwd, !pidChanged, now.timeIntervalSince(lastCwdCheck) < 5.0 {
                cwd = cached
            } else {
                let freshCwd = Self.surfaceCwd(surfaceID: surfaceID)
                cachedCwd = freshCwd
                lastCwdCheck = now
                cwd = freshCwd
            }

            // Re-resolve transcript URL only if not resolved yet, PID changed,
            // or periodically every 5 seconds (to catch /clear or /resume).
            let current: URL?
            let shouldRecheckURL = url == nil || pidChanged || now.timeIntervalSince(lastUrlCheck) >= 5.0
            if shouldRecheckURL {
                lastUrlCheck = now
                switch snap.kind {
                case .claudeCode:
                    current = ClaudeSessionLocator.transcriptURL(pid: snap.pid)
                case .antigravity:
                    current = AntigravitySessionLocator.transcriptURL(pid: snap.pid, surfaceCwd: cwd)
                case .codex:
                    current = CodexSessionLocator.transcriptURL(pid: snap.pid, surfaceCwd: cwd)
                default:
                    current = nil
                }
            } else {
                current = url
            }

            guard let current else { return }
            kind = snap.kind

            var reset = false
            if current != url { url = current; offset = 0; reset = true }

            // (Re-)arm the watcher when the file changed, or the old one died (file deleted/renamed).
            if watchedURL != current || state.transcriptWatcher == nil {
                state.transcriptWatcher = TranscriptFileWatcher(
                    url: current, queue: state.controlQueue
                ) { [weak connection, weak state] event in
                    guard let connection, let state else { return }
                    if !event.isDisjoint(with: [.delete, .rename]) {
                        // Bound to the old inode: drop it, the next slow tick re-arms on the new file.
                        state.transcriptWatcher = nil
                        watchedURL = nil
                    }
                    readAndPush(connection, state, false)
                }
                watchedURL = state.transcriptWatcher == nil ? nil : current
            }

            // Read now on a URL switch (backlog) — and on every tick if no watcher could be opened
            // (degrades to the old poll, at the slow rate).
            if reset || state.transcriptWatcher == nil {
                readAndPush(connection, state, reset)
            }
        }
        state.transcriptTimer = timer
        timer.resume()
    }

    private func handleDetach(connection: NWConnection, state: ConnectionState) {
        // Same nil-before-cancel ordering as `handleAttach` — see its comment.
        let previous = state.subscription
        state.subscription = nil
        state.surfaceID = nil
        state.transcriptTimer = nil
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

    /// Where a paired phone may read/list files: the active session's cwd, plus Antigravity's
    /// brain dir (agy writes its artifacts there, outside any repo). Anything else — `~/.ssh`,
    /// another project — is rejected; before this the phone could read any path on the Mac.
    static func authorizedReadPath(
        _ path: String,
        surfaceID: String?,
        surfaceLookup: (String) -> String? = { surfaceCwd(surfaceID: $0) },
        extraRoots: [String] = [NSHomeDirectory() + "/.gemini/antigravity-cli/brain"]
    ) -> String? {
        if case .success(let resolved) = resolveAuthorizedCwd(requestedPath: path, surfaceID: surfaceID, surfaceLookup: surfaceLookup) {
            return resolved
        }
        let req = URL(fileURLWithPath: path).standardizedFileURL.resolvingSymlinksInPath().path
        for root in extraRoots {
            let r = URL(fileURLWithPath: root).standardizedFileURL.resolvingSymlinksInPath().path
            if req.hasPrefix(r + "/") { return req }
        }
        return nil
    }

    private func handleReadFile(path: String, connection: NWConnection, state: ConnectionState) {
        guard let path = Self.authorizedReadPath(path, surfaceID: state.surfaceID) else {
            sendText(#"{"error":"foreign or unauthorized path rejected"}"#, on: connection)
            return
        }
        guard let info = Self.readFileInfo(path: path) else {
            sendText(#"{"error":"cannot read file"}"#, on: connection)
            return
        }
        sendJSON(FileReadResponse(file: info), on: connection)
    }

    private func handleListDirectory(path: String, connection: NWConnection, state: ConnectionState) {
        guard let path = Self.authorizedReadPath(path, surfaceID: state.surfaceID) else {
            sendText(#"{"error":"foreign or unauthorized path rejected"}"#, on: connection)
            return
        }
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
            // Close explicitly: callers like `runPairingLoop` run inside one never-ending GCD
            // block whose autorelease pool never drains, so waiting for dealloc leaked 2 fds
            // per call until the daemon hit EMFILE.
            try? outPipe.fileHandleForReading.close()
            try? errPipe.fileHandleForReading.close()
        }

        do {
            try process.run()
        } catch {
            // `run()` failed, so Process never closed the parent's write ends either.
            outPipe.fileHandleForReading.readabilityHandler = nil
            errPipe.fileHandleForReading.readabilityHandler = nil
            try? outPipe.fileHandleForWriting.close()
            try? errPipe.fileHandleForWriting.close()
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
        // The handlers can still be holding the final chunk (gh prints the PR URL last), so
        // detach them and read whatever is left before snapshotting.
        outPipe.fileHandleForReading.readabilityHandler = nil
        errPipe.fileHandleForReading.readabilityHandler = nil
        outBuffer.append(outPipe.fileHandleForReading.readDataToEndOfFile())
        errBuffer.append(errPipe.fileHandleForReading.readDataToEndOfFile())

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
        var inHunk = false

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
                inHunk = false
                let parts = line.components(separatedBy: " ")
                if parts.count >= 4 {
                    let bPart = parts[3]
                    currentFile = bPart.hasPrefix("b/") ? String(bPart.dropFirst(2)) : bPart
                }
            } else if !inHunk && line.hasPrefix("+++ b/") {
                currentFile = String(line.dropFirst(6))
            } else if !inHunk && line.hasPrefix("--- a/") && currentFile == nil {
                currentFile = String(line.dropFirst(6))
            } else if line.hasPrefix("@@") {
                inHunk = true
                currentHunkLines.append(line)
            } else if currentFile != nil && inHunk {
                if line.hasPrefix("+") {
                    currentAdditions += 1
                    currentHunkLines.append(line)
                } else if line.hasPrefix("-") {
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
            let reqURL = URL(fileURLWithPath: requested).standardizedFileURL.resolvingSymlinksInPath().path
            let cwdURL = URL(fileURLWithPath: cwd).standardizedFileURL.resolvingSymlinksInPath().path
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
        var isTruncated = false
        var cappedFiles = files
        if cappedFiles.count > 200 {
            cappedFiles = Array(cappedFiles.prefix(200))
            isTruncated = true
        }
        cappedFiles = cappedFiles.map { file in
            if file.lines.count > 500 {
                isTruncated = true
                return GitDiffFile(
                    path: file.path,
                    additions: file.additions,
                    deletions: file.deletions,
                    uncommitted: file.uncommitted,
                    lines: Array(file.lines.prefix(500))
                )
            }
            return file
        }
        struct GitDiffPayload: Encodable {
            var files: [GitDiffFile]
            var truncated: Bool?
        }
        struct GitDiffAck: Encodable {
            var gitDiff: GitDiffPayload
        }
        sendJSON(GitDiffAck(gitDiff: GitDiffPayload(files: cappedFiles, truncated: isTruncated ? true : nil)), on: connection)
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

    func handleControlMessage(_ text: String, connection: NWConnection, state: ConnectionState) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(ControlMessage.self, from: data)
        else {
            sendText(#"{"error":"unrecognized control message"}"#, on: connection)
            return
        }
        if let n = message.ping {
            sendText(#"{"pong":\#(n)}"#, on: connection)
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
                self?.handleReadFile(path: readFile.path, connection: connection, state: state)
            }
        } else if let listDirectory = message.listDirectory {
            state.controlQueue.async { [weak self] in
                self?.handleListDirectory(path: listDirectory.path, connection: connection, state: state)
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
        } else if let cmd = message.agentCommand {
            state.controlQueue.async { [weak self] in
                self?.handleAgentCommand(cmd, connection: connection, state: state)
            }
        } else if message.agyModels == true {
            state.controlQueue.async { [weak self] in
                guard let catalog = AgyModelCatalog.current() else { return } // page keeps its fallback list
                self?.sendJSON(AgyModelsPush(agyModels: .init(models: catalog.models, efforts: catalog.efforts)), on: connection)
            }
        } else if message.stop == true {
            state.controlQueue.async { [weak self] in
                self?.handleStop(connection: connection, state: state)
            }
        } else {
            sendText(#"{"error":"unrecognized control message"}"#, on: connection)
        }
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
            bindUnifiedListener(bindHost: host, port: port, log: log)
        }
        log("mobile bridge: listening on \(bindHosts.map { "\($0):\(pageURLPort)" }.joined(separator: ", "))")

        DispatchQueue.global().async { [weak self] in
            self?.runPairingLoop(
                wsPort: UInt16(clamping: pageURLPort),
                pageURLPort: pageURLPort,
                tailscaleHost: tailscaleHost,
                magicDNSName: tailscaleMagicDNSName,
                log: log
            )
        }
    }

    /// Tears down every listener and live connection and stops the pairing loop (within
    /// ~0.25s — see `runPairingLoop`'s sleep granularity). Safe to call when not running
    /// (no-op). Does NOT clear `PairedDeviceStore` — paired devices stay authorized so a
    /// later `start()` doesn't force every phone through the QR flow again.
    public func stop() {
        guard isRunning else { return }
        isRunning = false
        listenersLock.lock()
        listeners.forEach { $0.listener.cancel() }
        listeners.removeAll()
        listenersLock.unlock()
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
