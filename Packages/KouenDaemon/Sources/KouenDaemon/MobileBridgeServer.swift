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
    private let pairingBox = PairingBox()
    private var listeners: [NWListener] = []
    private var store: PairedDeviceStore?
    private let liveConnectionsLock = NSLock()
    private var liveConnections: [String: NWConnection] = [:]

    public init() {}

    private func cancelConnection(forDeviceID id: String) {
        liveConnectionsLock.lock()
        let connection = liveConnections.removeValue(forKey: id)
        liveConnectionsLock.unlock()
        connection?.cancel()
    }

    /// No longer bound to one surface (see the session-switcher design) — a redeemed
    /// token grants the whole daemon; the client picks/spawns a session afterward.
    private struct PendingPairing {
        let token: String
        let expiresAt: Date
    }

    /// `@unchecked Sendable` with an explicit lock: written by the pairing-loop thread,
    /// read by every WS connection's receive-callback chain.
    private final class PairingBox: @unchecked Sendable {
        private let lock = NSLock()
        private var _current: PendingPairing?
        var current: PendingPairing? {
            get { lock.lock(); defer { lock.unlock() }; return _current }
            set { lock.lock(); _current = newValue; lock.unlock() }
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
      const params = new URLSearchParams(location.search);
      const wsPort = params.get('wsport') || 7777;

      function connect() {
        ws = new WebSocket(`ws://${location.hostname}:${wsPort}/`);
        ws.binaryType = 'arraybuffer';
        ws.onopen = () => ws.send(document.getElementById('token').value);
        ws.onerror = (e) => alert('WebSocket error — check the daemon is running and the token is current.');
        ws.onmessage = (ev) => {
          if (typeof ev.data === 'string') {
            let msg;
            try { msg = JSON.parse(ev.data); } catch { return; }
            if (msg.sessions) showSessions(msg.sessions);
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

      // Token in the URL (QR scan) means connect immediately — the token expires in
      // pairingLifetime (15s), and phone unlock + camera app + page load already eats into
      // that; waiting on a manual tap timed out before the user could ever click Connect.
      if (params.get('token')) {
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
        listener.newConnectionHandler = { connection in
            connection.stateUpdateHandler = { state in
                if case .ready = state {
                    // A GET request line always arrives before the client waits for a
                    // response — no need to parse it since this listener only ever
                    // serves the one page regardless of requested path.
                    connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { _, _, _, _ in
                        connection.send(content: response, completion: .contentProcessed { _ in
                            connection.cancel()
                        })
                    }
                }
            }
            connection.start(queue: .main)
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
            pairingBox.current = PendingPairing(token: token, expiresAt: Date().addingTimeInterval(pairingLifetime))
            // `makePageListener` serves `embeddedPageHTML` for any path, so the root path
            // is enough here. `wsport` lets the page know which port to open the WS
            // connection on, since it can differ from the page-serving port.
            let url = "http://\(host):\(pageURLPort)/?token=\(token)&wsport=\(wsPort)"
            // The real production path (Kouen.app spawning its daemon via
            // `DaemonLauncher.spawnFallbackProcess`) sets `standardOutput = nil` — a
            // plain `print()` QR is invisible there, nowhere a user could ever see it
            // (confirmed: ran the actual GUI-spawned daemon, checked daemon.log, zero
            // matches for the printed URL). `daemonLog` is the only sink that survives
            // that path, so log the URL there too — not the full ASCII QR art (that's
            // sized for a real terminal, and would spam/rotate daemon.log every
            // pairingLifetime for no benefit; the URL alone is enough to copy/paste or
            // for a future GUI surface to render its own QR from).
            log("mobile bridge: pairing URL (valid \(Int(pairingLifetime))s): \(url)")
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
            DispatchQueue.global().async { [weak self] in
                self?.handleAttach(surfaceID: surfaceID, connection: connection, state: state)
            }
        } else if message.detach == true {
            handleDetach(connection: connection, state: state)
        } else if let spawn = message.spawn {
            DispatchQueue.global().async { [weak self] in
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
                guard isText, let text = String(data: data, encoding: .utf8),
                      let pending = self.pairingBox.current,
                      pending.token == text,
                      Date() < pending.expiresAt
                else {
                    self.sendText(#"{"error":"invalid or expired pairing token"}"#, on: connection) { connection.cancel() }
                    return
                }
                state.authorized = true
                let deviceID = UUID().uuidString
                state.deviceID = deviceID
                self.store?.register(id: deviceID, label: "Mobile device (\(deviceID.prefix(8)))")
                self.liveConnectionsLock.lock()
                self.liveConnections[deviceID] = connection
                self.liveConnectionsLock.unlock()
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

    private func makeListener(bindHost: String, port: NWEndpoint.Port) throws -> NWListener {
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
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
                    if let deviceID = state.deviceID {
                        self?.liveConnectionsLock.lock()
                        self?.liveConnections.removeValue(forKey: deviceID)
                        self?.liveConnectionsLock.unlock()
                    }
                default: break
                }
            }
            connection.start(queue: .main)
            self.receiveLoop(connection, state: state)
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
        store.onRevoke = { [weak self] id in self?.cancelConnection(forDeviceID: id) }
        do {
            let loopback = try makeListener(bindHost: "127.0.0.1", port: port)
            loopback.stateUpdateHandler = { state in
                if case .failed(let error) = state { log("mobile bridge: loopback listener failed: \(error)") }
            }
            loopback.start(queue: .main)
            listeners.append(loopback)
        } catch {
            log("mobile bridge: failed to bind loopback: \(error)")
        }
        let tailscaleHost = detectTailscaleHost()
        if let tailscaleHost {
            do {
                let tsListener = try makeListener(bindHost: tailscaleHost, port: port)
                tsListener.stateUpdateHandler = { state in
                    if case .failed(let error) = state { log("mobile bridge: Tailscale listener failed: \(error)") }
                }
                tsListener.start(queue: .main)
                listeners.append(tsListener)
                log("mobile bridge: listening on 127.0.0.1:\(wsPort) and \(tailscaleHost):\(wsPort)")
            } catch {
                log("mobile bridge: failed to bind Tailscale interface \(tailscaleHost): \(error)")
            }
        } else {
            log("mobile bridge: listening on 127.0.0.1:\(wsPort) only (Tailscale not detected)")
        }

        // Same loopback+Tailscale-only reachability posture as the WS listeners above —
        // this serves the pairing page itself now (see `makePageListener`'s doc comment),
        // so it needs the exact same bind scope, not just "whatever's convenient."
        if let pagePort = NWEndpoint.Port(rawValue: UInt16(clamping: pageURLPort)) {
            do {
                let pageLoopback = try makePageListener(bindHost: "127.0.0.1", port: pagePort)
                pageLoopback.start(queue: .main)
                listeners.append(pageLoopback)
            } catch {
                log("mobile bridge: failed to bind page server on loopback: \(error)")
            }
            if let tailscaleHost {
                do {
                    let pageTS = try makePageListener(bindHost: tailscaleHost, port: pagePort)
                    pageTS.start(queue: .main)
                    listeners.append(pageTS)
                } catch {
                    log("mobile bridge: failed to bind page server on Tailscale interface \(tailscaleHost): \(error)")
                }
            }
        } else {
            log("mobile bridge: invalid page port \(pageURLPort), pairing page will not be served")
        }

        DispatchQueue.global().async { [weak self] in
            self?.runPairingLoop(wsPort: wsPort, pageURLPort: pageURLPort, log: log)
        }
    }
}
#endif
