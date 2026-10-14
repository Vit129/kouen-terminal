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

    func makeUnifiedListener(bindHost: String, port: NWEndpoint.Port) throws -> NWListener {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(bindHost), port: port)
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
                    state.snapshotSubscription?.cancel()
                    state.snapshotSubscription = nil
                    if let browserPaneID = state.browserPaneID {
                        state.controlQueue.async {
                            _ = try? DaemonClient().request(.browserClose(paneID: browserPaneID), timeout: 5)
                        }
                    }
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
                    log("mobile bridge: listener on \(bindHost) failed: \(error)")
                    self?.setWSListener(host: bindHost, ready: false)
                case .cancelled:
                    self?.setWSListener(host: bindHost, ready: false)
                default: break
                }
            }
            listener.start(queue: bridgeQueue)
            bridgeQueue.async { [weak self] in
                self?.listeners.append(listener)
            }
        } catch {
            log("mobile bridge: failed to bind on \(bindHost):\(port.rawValue): \(error)")
        }
    }
}
#endif
