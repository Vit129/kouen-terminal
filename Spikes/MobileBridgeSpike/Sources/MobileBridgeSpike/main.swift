import CoreGraphics
import CoreImage
import Foundation
import KouenCore
import Network

// P25 throwaway spike: proves a phone can scan a QR code (via its native Camera
// app, not in-browser — avoids iOS Safari's HTTPS-only getUserMedia requirement
// entirely) to both pair AND pick which real terminal session to attach to in
// one motion, using only Network.framework + CoreImage (no new SwiftPM
// dependency). Not wired into KouenDaemonCore itself. Delete this whole
// target once the real bridge lands there.
//
// Flow: console prompt lists live surfaces -> operator picks one -> a random
// token bound to {that surfaceID, +15s expiry} is generated -> QR (ASCII, for
// this CLI-only spike) encodes a URL to index.html with ?token=... -> phone's
// Camera app scans it -> opens Safari at that URL -> page auto-fills the token
// and connects -> server looks up the token's bound surfaceID (client can't
// choose/spoof it) -> attaches (replay + live) -> further messages are
// keystrokes into that exact surface.
//
// Run:   swift run MobileBridgeSpike   (requires a running KouenDaemon with
//        at least one open session)

setvbuf(stdout, nil, _IONBF, 0) // print prompts/QR immediately even when stdout is piped/redirected

let wsPort: NWEndpoint.Port = 7777
let pageURLPort = 8080 // where index.html is served (e.g. `python3 -m http.server 8080`)
let pairingLifetime: TimeInterval = 15

// MARK: - Pairing state (session-bound, time-limited)

struct PendingPairing {
    let token: String
    let surfaceID: String
    let tabTitle: String
    let cwd: String
    let expiresAt: Date
}

/// `@unchecked Sendable` with an explicit lock: written by the console-prompt
/// thread, read by every WS connection's receive-callback chain.
final class PairingBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _current: PendingPairing?
    var current: PendingPairing? {
        get { lock.lock(); defer { lock.unlock() }; return _current }
        set { lock.lock(); _current = newValue; lock.unlock() }
    }
}
let pairingBox = PairingBox()

// MARK: - Per-connection state

/// `@unchecked Sendable` with an explicit lock: mutated both from the WS receive
/// chain (main queue) and the background queue performing the (blocking) daemon
/// attach, so these two can genuinely race without it.
final class ConnectionState: @unchecked Sendable {
    private let lock = NSLock()
    private var _authorized = false
    private var _surfaceID: String?
    private var _subscription: DaemonSubscription?

    var authorized: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _authorized }
        set { lock.lock(); _authorized = newValue; lock.unlock() }
    }
    var surfaceID: String? {
        get { lock.lock(); defer { lock.unlock() }; return _surfaceID }
        set { lock.lock(); _surfaceID = newValue; lock.unlock() }
    }
    var subscription: DaemonSubscription? {
        get { lock.lock(); defer { lock.unlock() }; return _subscription }
        set { lock.lock(); _subscription = newValue; lock.unlock() }
    }
}

// MARK: - QR (ASCII, native-Camera-app scan target — no in-page camera code)

/// Renders a QR code as block-character ASCII art via CoreImage's built-in
/// generator (`CIQRCodeGenerator` — no new dependency, macOS-native). Adds a
/// manual quiet zone (blank border) since the raw filter output has none, which
/// hurts real-world scan reliability.
func qrAsciiArt(for string: String) -> String? {
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

    var lines: [String] = []
    for y in -quietZone..<(height + quietZone) {
        var line = ""
        for x in -quietZone..<(width + quietZone) {
            line += isDark(x, y) ? "██" : "  "
        }
        lines.append(line)
    }
    return lines.joined(separator: "\n")
}

/// Best-effort LAN/Tailscale-reachable host for the QR's URL. Shells out to the
/// `tailscale` CLI if present; falls back to loopback (fine for same-Mac testing).
func detectHost() -> String {
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
    return "127.0.0.1"
}

// MARK: - Interactive console pairing prompt (runs on a background thread)

func runPairingPrompt() {
    let host = detectHost()
    while true {
        let client = DaemonClient()
        guard let response = try? client.request(.listSurfaces),
              case let .surfaces(surfaces) = response, !surfaces.isEmpty
        else {
            print("no live terminal sessions found on this daemon — retrying in 3s")
            Thread.sleep(forTimeInterval: 3)
            continue
        }

        print("\nAvailable sessions:")
        for (index, surface) in surfaces.enumerated() {
            print("  \(index + 1). \(surface.tabTitle)  (\(surface.cwd))")
        }
        print("Pick a number to generate a \(Int(pairingLifetime))s pairing QR (Ctrl+C to quit): ", terminator: "")

        guard let line = readLine() else {
            // stdin closed/non-interactive (e.g. launched detached) — nothing to
            // read ever again; without this, readLine() returns nil instantly
            // forever and spins this loop as fast as the CPU allows.
            print("stdin is not interactive — no console pairing prompt available. Exiting the prompt loop.")
            return
        }
        guard let choice = Int(line), (1...surfaces.count).contains(choice) else {
            print("invalid choice, try again")
            continue
        }
        let surface = surfaces[choice - 1]
        let token = String(format: "%06d", Int.random(in: 0..<1_000_000))
        pairingBox.current = PendingPairing(
            token: token,
            surfaceID: surface.surfaceID,
            tabTitle: surface.tabTitle,
            cwd: surface.cwd,
            expiresAt: Date().addingTimeInterval(pairingLifetime)
        )

        let url = "http://\(host):\(pageURLPort)/?token=\(token)"
        print("\nScan with your iPhone's Camera app — valid \(Int(pairingLifetime))s, attaches ONLY to \"\(surface.tabTitle)\":\n")
        print(qrAsciiArt(for: url) ?? "(QR generation failed — open this URL manually)")
        print("\n\(url)\n")
    }
}

// MARK: - WebSocket bridge

let wsOptions = NWProtocolWebSocket.Options()
wsOptions.autoReplyPing = true
let parameters = NWParameters.tcp
parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

struct AttachedAck: Codable {
    var ok = "attached"
    var surfaceID: String
    var tabTitle: String
    var cwd: String
}

func sendText(_ text: String, on connection: NWConnection, completion: @escaping @Sendable () -> Void = {}) {
    let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
    let context = NWConnection.ContentContext(identifier: "text", metadata: [metadata])
    connection.send(content: Data(text.utf8), contentContext: context, isComplete: true, completion: .contentProcessed { _ in completion() })
}

func sendBinary(_ data: Data, on connection: NWConnection) {
    let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
    let context = NWConnection.ContentContext(identifier: "binary", metadata: [metadata])
    connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed { _ in })
}

/// Attaches to the EXACT surface the pairing token was bound to at generation
/// time — no `.listSurfaces().first` guessing, so a client can never land on a
/// session it (or the operator) didn't explicitly choose to share.
func attachToPairedSurface(pending: PendingPairing, connection: NWConnection, state: ConnectionState) {
    let client = DaemonClient()
    do {
        let subscription = try client.attachReplayingSurfaceOutput(
            surfaceID: pending.surfaceID,
            onReplay: { text in sendBinary(Data(text.utf8), on: connection) },
            onData: { data, _ in sendBinary(data, on: connection) },
            onEnd: { connection.cancel() }
        )
        state.surfaceID = pending.surfaceID
        state.subscription = subscription
        let ack = AttachedAck(surfaceID: pending.surfaceID, tabTitle: pending.tabTitle, cwd: pending.cwd)
        if let json = try? JSONEncoder().encode(ack) {
            sendText(String(decoding: json, as: UTF8.self), on: connection)
        }
    } catch {
        print("attach failed: \(error)")
        sendText(#"{"error":"failed to attach to the terminal session"}"#, on: connection) { connection.cancel() }
    }
}

func receiveLoop(_ connection: NWConnection, state: ConnectionState) {
    connection.receiveMessage { data, _, _, error in
        if let error {
            print("connection ended: \(error)")
            state.subscription?.cancel()
            return
        }
        guard let data else {
            receiveLoop(connection, state: state)
            return
        }

        if !state.authorized {
            guard let text = String(data: data, encoding: .utf8),
                  let pending = pairingBox.current,
                  pending.token == text,
                  Date() < pending.expiresAt
            else {
                print("rejected connection: invalid or expired pairing token")
                sendText(#"{"error":"invalid or expired pairing token"}"#, on: connection) { connection.cancel() }
                return
            }
            state.authorized = true
            print("connection authorized for surface \(pending.surfaceID) (\(pending.tabTitle))")
            DispatchQueue.global().async { attachToPairedSurface(pending: pending, connection: connection, state: state) }
            receiveLoop(connection, state: state)
            return
        }

        // Authorized: once attached, every subsequent message is raw keystrokes
        // for the PTY it was paired to.
        if let surfaceID = state.surfaceID, let subscription = state.subscription {
            _ = subscription.sendInput(data, surfaceID: surfaceID)
        }
        receiveLoop(connection, state: state)
    }
}

let listener = try! NWListener(using: parameters, on: wsPort)

listener.newConnectionHandler = { connection in
    print("new connection from \(connection.endpoint)")
    let state = ConnectionState()
    connection.stateUpdateHandler = { connState in
        switch connState {
        case .cancelled, .failed: state.subscription?.cancel()
        default: break
        }
    }
    connection.start(queue: .main)
    receiveLoop(connection, state: state)
}

listener.stateUpdateHandler = { state in
    print("listener state: \(state)")
}

listener.start(queue: .main)

print("MobileBridgeSpike listening on port \(wsPort) on all interfaces (incl. Tailscale).")
DispatchQueue.global().async { runPairingPrompt() }

RunLoop.main.run()
