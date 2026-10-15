#if canImport(Network)
import Foundation
import KouenCore
import Network

// Connecting & host-discovery layer for `MobileBridgeServer`:
// - Tailscale IP and MagicDNS resolution with strict process validation
// - Tailscale Serve HTTPS detection
// - Pairing URL construction
// - Bind-scope validation (allowedBindHosts)
// - Unified listener creation and dynamic interface binding

extension MobileBridgeServer {
    /// Intel Homebrew, Apple Silicon Homebrew, then the CLI bundled in the App Store / standalone app.
    static let tailscalePath: String = [
        "/usr/local/bin/tailscale",
        "/opt/homebrew/bin/tailscale",
        "/Applications/Tailscale.app/Contents/MacOS/Tailscale",
    ].first { FileManager.default.isExecutableFile(atPath: $0) } ?? "/usr/local/bin/tailscale"

    /// Best-effort Tailscale IPv4 for the QR's URL; nil if Tailscale isn't installed/up or returns an error.
    func detectTailscaleHost() -> String? {
        let res = Self.runProcess(
            executableURL: URL(fileURLWithPath: Self.tailscalePath),
            arguments: ["ip", "-4"],
            timeoutSeconds: 3
        )
        guard res.status == 0 else { return nil }
        let output = res.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !output.isEmpty, output.hasPrefix("100.") else { return nil }
        guard output.allSatisfy({ $0.isNumber || $0 == "." }) else { return nil }
        return output
    }

    /// Best-effort Tailscale MagicDNS name (e.g. `mac-name.tailXXXX.ts.net`) for the QR's
    /// URL; nil if Tailscale isn't installed/up or MagicDNS is off. Used ONLY for the
    /// pairing URL's host — listener binds still use `detectTailscaleHost()`'s raw IP.
    func detectTailscaleMagicDNSName() -> String? {
        let res = Self.runProcess(
            executableURL: URL(fileURLWithPath: Self.tailscalePath),
            arguments: ["status", "--json"],
            timeoutSeconds: 3
        )
        guard res.status == 0 else { return nil }
        guard let data = res.stdout.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let selfPeer = json["Self"] as? [String: Any],
              var dnsName = selfPeer["DNSName"] as? String,
              !dnsName.isEmpty,
              !dnsName.contains(" ")
        else { return nil }
        if dnsName.hasSuffix(".") { dnsName.removeLast() }
        return dnsName
    }

    /// Generates a valid pairing URL. Falls back to 127.0.0.1 if host is empty or contains whitespace/error strings.
    public static func buildPairingURL(
        host: String,
        pageURLPort: Int,
        wsPort: UInt16,
        token: String,
        magicDNSName: String? = nil,
        isServeActive: Bool = false
    ) -> String {
        if isServeActive, let dns = magicDNSName, !dns.isEmpty {
            return "https://\(dns)/?token=\(token)"
        }
        let safeHost = host.isEmpty || host.contains(" ") ? "127.0.0.1" : host
        return "http://\(safeHost):\(pageURLPort)/?token=\(token)&wsport=\(wsPort)"
    }

    public static func isTailscaleServeConfigured(port: Int) -> Bool {
        let res = runProcess(
            executableURL: URL(fileURLWithPath: Self.tailscalePath),
            arguments: ["serve", "status", "--json"],
            timeoutSeconds: 5
        )
        return res.status == 0 && serveStatusProxiesPort(res.stdout, port: port)
    }

    /// Pure: true only when `tailscale serve status --json` has a web handler proxying to the
    /// bridge's own port. Any other serve config (a different app's port) must not flip the
    /// QR to an https:// URL that lands on someone else's server.
    static func serveStatusProxiesPort(_ statusJSON: String, port: Int) -> Bool {
        guard let data = statusJSON.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let web = json["Web"] as? [String: Any] else { return false }
        let targets = ["127.0.0.1:\(port)", "localhost:\(port)"]
        for case let site as [String: Any] in web.values {
            for case let handler as [String: Any] in (site["Handlers"] as? [String: Any] ?? [:]).values {
                guard let proxy = handler["Proxy"] as? String else { continue }
                if proxy == "\(port)" || targets.contains(where: { proxy.hasSuffix($0) || proxy.contains($0 + "/") }) {
                    return true
                }
            }
        }
        return false
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

    /// One listener per bind host, serving both the plain page and the WS bridge on the
    /// SAME port (see the framing section's doc comment above `webSocketGUID` for why: a
    /// real phone could reach the page's port over Tailscale but never a second, WS-only
    /// port on the same host/interface, with Tailscale ACLs confirmed wide open — the only
    /// way to remove that unexplained difference was removing the second port).
    func makeUnifiedListener(bindHost: String, port: NWEndpoint.Port) throws -> NWListener {
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
                    state.transcriptTimer = nil
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
            // Found via Agy + Opus verification: a peer that completes the TCP handshake and
            // then just sits there — never finishing its HTTP request, or completing a WS
            // upgrade and then sending nothing, not even a pairing token — held the
            // connection/fd open forever. One watchdog covers both: `pageServed` for the
            // plain-HTTP path, `authorized` for the WS path.
            self.bridgeQueue.asyncAfter(deadline: .now() + self.preAuthTimeout) { [weak self] in
                guard !state.authorized, !state.pageServed else { return }
                self?.log?("mobile bridge: pre-auth watchdog firing for \(connection.endpoint) — no auth/page-serve within \(self?.preAuthTimeout ?? -1)s, cancelling")
                connection.cancel()
            }
        }
        return listener
    }

    func bindUnifiedListener(bindHost: String, port: NWEndpoint.Port, log: @escaping @Sendable (String) -> Void) {
        do {
            let listener = try makeUnifiedListener(bindHost: bindHost, port: port)
            listener.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    self?.setWSListener(host: bindHost, ready: true)
                case .failed(let error):
                    // A squatted port surfaces HERE (bind errors don't throw above with
                    // `allowLocalEndpointReuse`) — mark the host down so the pairing URL
                    // is withheld and the Settings panel shows the failure (R4).
                    log("mobile bridge: listener on \(bindHost) failed: \(error)")
                    self?.setWSListener(host: bindHost, ready: false)
                case .cancelled:
                    self?.setWSListener(host: bindHost, ready: false)
                default: break
                }
            }
            // Under the lock with the isRunning check, so a listener bound by the pairing loop
            // while `stop()` runs is either drained by it or never started (no leaked port).
            listenersLock.lock()
            defer { listenersLock.unlock() }
            guard isRunning else { return }
            listener.start(queue: bridgeQueue)
            listeners.append((bindHost, listener))
        } catch {
            log("mobile bridge: failed to bind on \(bindHost):\(port.rawValue): \(error)")
        }
    }

    /// Drops the listener for a Tailscale IP that went away (re-login, new node key), so the
    /// stale bind doesn't keep `anyWSListenerReady` true for a host the QR no longer names.
    func cancelListener(bindHost: String) {
        listenersLock.lock()
        let gone = listeners.filter { $0.host == bindHost }
        listeners.removeAll { $0.host == bindHost }
        listenersLock.unlock()
        gone.forEach { $0.listener.cancel() }
    }
}
#endif
