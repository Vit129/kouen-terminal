#if canImport(Network)
import CryptoKit
import Foundation
import KouenCore
import Network

// Connection layer for `MobileBridgeServer`: hand-rolled RFC 6455 framing, the per-connection
// receive loop, and the auth gate every frame passes before it reaches a control handler.

extension MobileBridgeServer {
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

    static let webSocketGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    /// RFC 6455 §1.3: accept value is base64(SHA-1(key + the fixed GUID)). Every real WS
    /// client computes the same thing to verify the server actually understood the upgrade.
    static func webSocketAcceptValue(for key: String) -> String {
        let hash = Insecure.SHA1.hash(data: Data((key + webSocketGUID).utf8))
        return Data(hash).base64EncodedString()
    }

    /// Server-to-client frames are never masked (RFC 6455 §5.1: only client-to-server frames
    /// are). Single-frame (FIN=1) only — this bridge never needs to fragment its own writes,
    /// every payload here fits comfortably under the 64-bit length encoding's practical range.
    static func encodeWSFrame(opcode: UInt8, payload: Data) -> Data {
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

    func sendText(_ text: String, on connection: NWConnection, completion: @escaping @Sendable () -> Void = {}) {
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
    func rejectAndClose(_ json: String, on connection: NWConnection) {
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

    func sendBinary(_ data: Data, on connection: NWConnection, state: ConnectionState? = nil) {
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

    func sendJSON<T: Encodable>(_ value: T, on connection: NWConnection) {
        guard let json = try? JSONEncoder().encode(value) else { return }
        sendText(String(decoding: json, as: UTF8.self), on: connection)
    }

    /// Reads raw bytes and hands them to `drainFrames` — replaces the old
    /// `connection.receiveMessage` + `NWProtocolWebSocket.Metadata` pair now that WS framing
    /// is decoded by hand (see the framing section above for why).
    func receiveLoop(_ connection: NWConnection, state: ConnectionState) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, _, error in
            guard let self else { return }
            if error != nil {
                state.subscription?.cancel()
                state.snapshotSubscription?.cancel()
                state.transcriptTimer = nil
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
    func drainFrames(_ connection: NWConnection, state: ConnectionState) {
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
    func handleFrame(_ frame: DecodedWSFrame, connection: NWConnection, state: ConnectionState) -> Bool {
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
    static let maxWSFrameBytes = 8 * 1024 * 1024
}
#endif
