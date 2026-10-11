#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation

/// Synchronous IPC client. @unchecked Sendable: stateless between calls (each request
/// opens and closes its own socket) and all calls funnel through the serial `queue`.
public final class DaemonClient: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.robert.harness.daemon-client")
    /// Where this client connects. Defaults to the local daemon's control socket, so every existing
    /// `DaemonClient()` call is unchanged; a remote client passes the local end of an SSH tunnel.
    private let endpoint: Endpoint

    public init(endpoint: Endpoint = .localControlSocket) {
        self.endpoint = endpoint
    }

    public func request(_ ipcRequest: IPCRequest, timeout: TimeInterval = 2) throws -> IPCResponse {
        let deadline = SocketDeadline(timeout: timeout)
        return try queue.sync {
            try self.performRequest(ipcRequest, deadline: deadline)
        }
    }

    func requestFromLocalOwner(_ request: IPCRequest, pid: Int32, generation: String, timeout: TimeInterval) throws -> IPCResponse {
        let deadline = SocketDeadline(timeout: timeout)
        return try queue.sync {
            try performRequest(request, deadline: deadline, expectedOwner: (pid, generation))
        }
    }

    /// Layout-bearing calls advertise the current client's supported content directly.
    /// The coordinated protocol cutover makes a separate health probe unnecessary.
    public func requestForCurrentClient(_ request: IPCRequest, timeout: TimeInterval = 2) throws -> IPCResponse {
        switch request {
        case .getSnapshot:
            StartupMetrics.shared.mark(.firstSnapshotRequestStarted)
            let response = try self.request(.getSnapshotForClient(capabilities: [DaemonStats.paneContent, DaemonStats.agentIdentities]), timeout: timeout)
            StartupMetrics.shared.mark(.firstSnapshotResponseReceived)
            return response
        case let .library(operation):
            return try self.request(.libraryForClient(operation, capabilities: [DaemonStats.paneContent, DaemonStats.agentIdentities]), timeout: timeout)
        default:
            return try self.request(request, timeout: timeout)
        }
    }

    @discardableResult
    public func subscribeSurfaceOutput(
        surfaceID: String,
        label: String? = nil,
        onData: @escaping @Sendable (Data, UInt64) -> Void,
        onEnd: (@Sendable () -> Void)? = nil
    ) throws -> DaemonSubscription {
        let deadline = SocketDeadline(timeout: 2)
        let fd = try EndpointConnector.connect(endpoint, deadline: deadline)
        let payload = try IPCCodec.encode(IPCEnvelope(request: .subscribeSurfaceOutput(surfaceID: surfaceID, label: label)))
        do { try deadline.write(payload, to: fd) } catch { close(fd); throw error } // EINTR-safe, looped
        let subscription = DaemonSubscription(fd: fd)
        subscription.start(onData: onData, onEnd: onEnd)
        if RemoteAttach.isTunnel(endpoint) { subscription.presentAsTunnel() }
        return subscription
    }

    /// Where a client's terminal stands in a daemon's output: the daemon's epoch and the next
    /// sequence it expects. Handing it back on reconnect resumes instead of repainting.
    public struct AttachPoint: Equatable, Sendable {
        public var epoch: String
        public var sequence: UInt64
        public init(epoch: String, sequence: UInt64) {
            self.epoch = epoch
            self.sequence = sequence
        }
    }

    /// How an attach starts. With `resync` the caller resets its terminal before the bytes
    /// that follow; otherwise they continue where `resume` left off. Bytes below `historyEnd`
    /// are history (feed them as a replay: no bells or notifications); `point` is nil on a
    /// daemon that can't resume. A resync from a current daemon carries `screen`, the visible
    /// screen at `historyEnd` as VT bytes, to paint before the history.
    public struct AttachStart: Equatable, Sendable {
        public var resync: Bool
        public var historyEnd: UInt64
        public var point: AttachPoint?
        public var screen: Data?
        public var replaySizes: [ReplaySize]?
    }

    /// Attach to a surface's output with its history. On a daemon with `attach-stream` this
    /// is one request: the history streams as binary frames (no JSON size cap) and a known
    /// `resume` point sends only what was missed. All controlling clients use the current streaming protocol.
    /// `onStart` runs before any `onData`, on the subscription's read thread.
    @discardableResult
    public func attach(
        surfaceID: String,
        label: String? = nil,
        readOnly: Bool = false,
        resume: AttachPoint? = nil,
        launch: AttachLaunch? = nil,
        acknowledgesOutput: Bool = false,
        onStart: @escaping @Sendable (AttachStart) -> Void,
        onData: @escaping @Sendable (Data, UInt64) -> Void,
        onOwnership: (@Sendable (SizeOwnership) -> Void)? = nil,
        onEnd: (@Sendable () -> Void)? = nil
    ) throws -> DaemonSubscription {
        let request = AttachRequest(
            surfaceID: surfaceID, label: label, readOnly: readOnly, history: true,
            fromSequence: resume?.sequence, epoch: resume?.epoch, inputErrors: true, launch: launch, acknowledgesOutput: acknowledgesOutput
        )
        return try attachStream(request, onAttached: { reply, _ in
            onStart(AttachStart(
                resync: reply.resync, historyEnd: reply.endSequence,
                point: AttachPoint(epoch: reply.epoch, sequence: reply.endSequence), screen: reply.screen,
                replaySizes: reply.replaySizes
            ))
        }, onData: { data, sequence, _ in onData(data, sequence) }, onOwnership: onOwnership, onEnd: onEnd)
    }

    /// The `attachStream` request itself: `.attached`, then output frames. `harness-cli attach`
    /// uses it screen-only (`history: false`), painting `reply.screen`.
    @discardableResult
    public func attachStream(
        _ request: AttachRequest,
        onAttached: @escaping @Sendable (AttachReply, @escaping @Sendable () -> Void) -> Void,
        onData: @escaping @Sendable (Data, UInt64, @escaping @Sendable () -> Void) -> Void,
        onResize: (@Sendable (ReplaySize) -> Void)? = nil,
        onOwnership: (@Sendable (SizeOwnership) -> Void)? = nil,
        onEnd: (@Sendable () -> Void)? = nil,
        onError: (@Sendable (String) -> Void)? = nil
    ) throws -> DaemonSubscription {
        let deadline = SocketDeadline(timeout: 2)
        let fd = try EndpointConnector.connect(endpoint, deadline: deadline)
        let payload = try IPCCodec.encode(IPCEnvelope(request: .attachStream(request)))
        do { try deadline.write(payload, to: fd) } catch { close(fd); throw error }
        let subscription = DaemonSubscription(fd: fd)
        subscription.start(onResponse: { [weak subscription] response in
            switch response {
            case let .attached(reply):
                guard !request.acknowledgesOutput || reply.outputToken != nil else {
                    onError?("The daemon lacks acknowledged terminal output. Restart the updated daemon and session host before attaching.")
                    subscription?.cancel(); return
                }
                subscription?.setInputErrorSupport(reply.inputErrors == true)
                subscription?.setOutputToken(reply.outputToken, surfaceID: request.surfaceID)
                onAttached(reply) { [weak subscription] in subscription?.acknowledgeOutput(surfaceID: request.surfaceID, sequence: reply.endSequence) }
            case let .data(data, sequence):
                onData(data, sequence) { [weak subscription] in subscription?.acknowledgeOutput(surfaceID: request.surfaceID, sequence: sequence + UInt64(data.count)) }
            case let .terminalResize(size): onResize?(size)
            case let .sizeOwnership(ownership): onOwnership?(ownership)
            case let .error(message): onError?(message)
            default: break
            }
        }, onEnd: onEnd)
        if RemoteAttach.isTunnel(endpoint) { subscription.presentAsTunnel() }
        return subscription
    }


    /// Long-lived snapshot subscription: invokes `onRevision` each time the daemon
    /// pushes a `snapshotChanged(revision:)` frame (i.e. the layout committed). Replaces
    /// the compositor's structure poll.
    @discardableResult
    public func subscribeSnapshot(
        label: String? = nil,
        capabilities: [String] = [],
        onRevision: @escaping @Sendable (Int) -> Void,
        onDirective: (@Sendable (ClientDirective) -> Void)? = nil,
        onEnd: (@Sendable () -> Void)? = nil
    ) throws -> DaemonSubscription {
        let deadline = SocketDeadline(timeout: 2)
        let fd = try EndpointConnector.connect(endpoint, deadline: deadline)
        let payload = try IPCCodec.encode(IPCEnvelope(request: .subscribeSnapshot(label: label, directives: onDirective != nil, capabilities: capabilities)))
        do { try deadline.write(payload, to: fd) } catch { close(fd); throw error } // EINTR-safe, looped
        let subscription = DaemonSubscription(fd: fd)
        subscription.start(
            onResponse: { response in
                switch response {
                case let .snapshotChanged(revision): onRevision(revision)
                case let .clientDirective(directive): onDirective?(directive)
                default: break
                }
            },
            onEnd: onEnd
        )
        return subscription
    }

    /// Block until the follow socket closes, delivering each NDJSON event. `.ok` is the
    /// subscription ack and is not an event. A daemon error ends the call.
    public func followEvents(
        sessionID: String?,
        includeServer: Bool,
        onEvent: (FollowEvent) -> Void
    ) throws {
        let deadline = SocketDeadline(timeout: 2)
        let fd = try EndpointConnector.connect(endpoint, deadline: deadline)
        defer { close(fd) }
        let payload = try IPCCodec.encode(
            IPCEnvelope(request: .subscribeEvents(sessionID: sessionID, includeServer: includeServer))
        )
        try deadline.write(payload, to: fd)
        var buffer = Data()
        var temp = [UInt8](repeating: 0, count: 65_536)
        while true {
            var ready = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
            let polled = poll(&ready, 1, -1)
            if polled < 0, errno == EINTR { continue }
            if polled < 0 || ready.revents & Int16(POLLNVAL) != 0 { throw DaemonClientError.connectionFailed }
            let count = read(fd, &temp, temp.count)
            if count == 0 { return }
            if count < 0 {
                if errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK { continue }
                throw DaemonClientError.connectionFailed
            }
            buffer.append(contentsOf: temp.prefix(count))
            while true {
                let reply: IPCReply?
                do {
                    reply = try IPCCodec.decodeReply(from: &buffer)
                } catch {
                    throw DaemonClientError.unexpectedResponse
                }
                guard let reply else { break }
                switch reply.response {
                case let .follow(line):
                    if let event = try? JSONDecoder().decode(FollowEvent.self, from: Data(line.utf8)) {
                        onEvent(event)
                    }
                case let .error(message):
                    throw FollowStreamError(message: message)
                case .ok:
                    break
                default:
                    break
                }
            }
        }
    }

    private func performRequest(_ ipcRequest: IPCRequest, deadline: SocketDeadline, expectedOwner: (pid: Int32, generation: String)? = nil) throws -> IPCResponse {
        let fd = try EndpointConnector.connect(endpoint, deadline: deadline)
        defer { close(fd) }
        if let expectedOwner, !DaemonOwnership.localPeerMatches(fd: fd, pid: expectedOwner.pid, generation: expectedOwner.generation) {
            throw DaemonRestart.Failure.refused("The local socket owner changed or could not be verified. Existing shells have been preserved.")
        }
        let payload = try IPCCodec.encode(IPCEnvelope(request: ipcRequest))
        try deadline.write(payload, to: fd)
        var buffer = Data()
        var temp = [UInt8](repeating: 0, count: 65_536)
        while true {
            try deadline.wait(fd, events: Int16(POLLIN))
            let count = read(fd, &temp, temp.count)
            if count > 0 {
                buffer.append(contentsOf: temp.prefix(count))
                if let reply = try IPCCodec.decodeReply(from: &buffer) { return reply.response }
            } else if count < 0, errno == EINTR || errno == EAGAIN {
                continue
            } else {
                throw DaemonClientError.connectionFailed
            }
        }
    }


}

/// Live output stream over a dedicated socket.
///
/// A nonblocking subscription. Its read source owns the descriptor until cancellation
/// completes; input writes remain serialized independently of output delivery.
public final class DaemonSubscription: @unchecked Sendable {
    private let fd: Int32
    private let queue = DispatchQueue(label: "com.robert.harness.daemon-subscription")
    private let lock = NSLock()
    /// Serializes writes to the single full-duplex `fd` so concurrent writers (keystroke `sendInput`
    /// + `detachSurface`) can never interleave bytes mid-frame. Distinct from `lock` (which guards
    /// the cancel flags) so a blocking write can't wedge `cancel()`. Uncontended in practice —
    /// input is already serialized upstream on the host's IO queue.
    private let writeLock = NSLock()
    private let acknowledgementQueue = DispatchQueue(label: "com.robert.harness.output-acknowledgement")
    private var acknowledgementScheduled = false
    private var acknowledgements: [String: (UUID, UInt64)] = [:]
    private var outputTokens: [String: UUID] = [:]
    private var cancelled = false
    private var finished = false
    private var reader: DispatchSourceRead?
    private var readerSuspended = false
    private var readingPaused = false
    private var readBuffer = IPCReadBuffer()
    private var scratch = [UInt8](repeating: 0, count: 65536)
    private var responseHandler: (@Sendable (IPCResponse) -> Void)?

    init(fd: Int32) {
        self.fd = fd
    }

    /// Detach this subscription's surface on the daemon **without closing the connection** —
    /// releases only this client's hold (its subscription + size vote) on `surfaceID`, leaving
    /// the PTY and every other client running, so the surface can be re-grabbed later. Use
    /// `cancel()` instead to also tear down the connection. Safe to call from any thread (the
    /// socket is full-duplex; the read loop runs on its own queue).
    public func detachSurface(_ surfaceID: String) {
        lock.lock(); let dead = cancelled || finished; lock.unlock()
        guard !dead,
              let payload = try? IPCCodec.encode(IPCEnvelope(request: .detachSurface(surfaceID: surfaceID)))
        else { return }
        writeFrame(payload)
    }

    private var inputErrorsSupported = false
    private var inputErrorHandler: (@Sendable (String) -> Void)?

    func setInputErrorSupport(_ supported: Bool) {
        lock.lock(); inputErrorsSupported = supported; lock.unlock()
    }

    public func setInputErrorHandler(_ handler: @escaping @Sendable (String) -> Void) {
        lock.lock(); inputErrorHandler = handler; lock.unlock()
    }

    /// A false result has an UNKNOWN delivery outcome. Never retry this mutation.
    /// Old daemons use their existing JSON request/reply path; binary input requires the
    /// attach handshake's explicit agreement to report admission failures.
    @discardableResult
    public func sendInput(_ data: Data, surfaceID: String) -> Bool {
        lock.lock()
        let dead = cancelled || finished
        let binary = inputErrorsSupported
        lock.unlock()
        guard !dead else { return false }
        let payload = binary
            ? try? IPCCodec.encodeInputFrame(surfaceID: surfaceID, payload: data)
            : try? IPCCodec.encode(IPCEnvelope(request: .sendData(surfaceID: surfaceID, data: data)))
        guard let payload else { return false }
        return writeFrame(payload)
    }

    fileprivate func setOutputToken(_ token: UUID?, surfaceID: String) {
        lock.lock(); outputTokens[surfaceID] = token; acknowledgements.removeValue(forKey: surfaceID); lock.unlock()
    }

    /// Coalesce consumption fences off the parser worker; never block parsing on a socket write.
    public func acknowledgeOutput(surfaceID: String, sequence: UInt64) {
        lock.lock()
        guard !cancelled, !finished, let token = outputTokens[surfaceID] else { lock.unlock(); return }
        let prior = acknowledgements[surfaceID].map { $0.0 == token ? $0.1 : 0 } ?? 0
        acknowledgements[surfaceID] = (token, max(prior, sequence))
        let schedule = !acknowledgementScheduled
        acknowledgementScheduled = true
        lock.unlock()
        guard schedule else { return }
        acknowledgementQueue.async { [weak self] in
            guard let self else { return }
            while true {
                self.lock.lock()
                let fences = self.acknowledgements
                self.acknowledgements.removeAll(keepingCapacity: true)
                if fences.isEmpty { self.acknowledgementScheduled = false }
                self.lock.unlock()
                guard !fences.isEmpty else { return }
                for (surfaceID, fence) in fences {
                    guard let payload = try? IPCCodec.encode(IPCEnvelope(request: .acknowledgeOutput(surfaceID: surfaceID, token: fence.0, sequence: fence.1))),
                          self.writeFrame(payload) else { return }
                }
            }
        }
    }

    /// Mark this subscription as an SSH-tunneled client so a dropped forward emits
    /// `client.connection`. The `.ok` is ignored by the output read loop, same as a resize ack.
    func presentAsTunnel() {
        let request = IPCRequest.presentClient(
            kind: "client",
            version: HarnessVersion.short,
            uid: UInt32(getuid()),
            tunnel: true
        )
        guard let payload = try? IPCCodec.encode(IPCEnvelope(request: request)) else { return }
        writeFrame(payload)
    }

    /// Record this client's PTY size vote for `surfaceID` over the persistent connection. The
    /// daemon keys size votes by fd and drops them when the fd closes — so a vote sent through
    /// one-shot `DaemonClient.request(.resizeSurface:)` dies with its socket and multi-client
    /// smallest-size sizing degrades to last-resize-wins. Sending the vote on this connection
    /// ties its lifetime to the subscription: it holds while attached and is released exactly
    /// on `detachSurface`/disconnect, letting the surface grow back.
    ///
    /// Deliberately the plain JSON `.resizeSurface` request, NOT a new binary frame: every
    /// daemon (including older builds) already handles it per-fd on any connection, so this is
    /// compatible in both directions — a new binary magic would read as an oversized JSON
    /// length on an old daemon, which drops the connection. The daemon's `.ok` ack arrives
    /// interleaved with the output stream and is ignored by the read loop, exactly like
    /// `detachSurface`'s; resizes are far too infrequent for the ack to matter.
    public func resize(_ surfaceID: String, rows: UInt16, cols: UInt16, takeOwnership: Bool = false) {
        lock.lock(); let dead = cancelled || finished; lock.unlock()
        guard !dead,
              var payload = try? IPCCodec.encode(IPCEnvelope(request: .resizeSurface(surfaceID: surfaceID, rows: rows, cols: cols)))
        else { return }
        // Keep the vote and claim on the same socket, in order. A separate RPC can
        // reach the daemon before this subscription's size vote exists.
        if takeOwnership {
            guard let claim = try? IPCCodec.encode(IPCEnvelope(request: .takeSurface(surfaceID: surfaceID, clientID: nil))) else { return }
            payload.append(claim)
        }
        writeFrame(payload)
    }

    /// Write one complete framed message to `fd`, retrying partial/interrupted writes. Holds
    /// `writeLock` for the whole frame so two writers can't interleave bytes. A hard error (peer
    /// gone) just stops — the read loop independently observes EOF and tears down. Returns `true`
    /// iff every byte of the frame flushed; `false` on a torn-down subscription or a hard write
    /// error (the caller must report the uncertain delivery, without retrying). `detachSurface`/`resize` ignore the result.
    @discardableResult
    private func writeFrame(_ payload: Data) -> Bool {
        writeLock.lock()
        defer { writeLock.unlock() }
        // The read loop sets `finished` and closes `fd` under `writeLock` on teardown. Holding it
        // here means either that close already happened (bail — the fd is closed and its number may
        // be recycled) or it can't begin until we're done. Re-checking under `lock` (not just in the
        // sendInput/detachSurface entry points) closes the window where `cancel()` + the read-loop
        // close raced an in-flight write into a stale descriptor.
        lock.lock(); let dead = cancelled || finished; lock.unlock()
        guard !dead else { return false }
        do {
            try SocketDeadline(timeout: 2).write(payload, to: fd)
            return true
        } catch {
            // The outcome may be unknown. Close this stream and never retry its input.
            cancel()
            return false
        }
    }

    public func cancel() {
        lock.lock()
        guard !cancelled, !finished else { lock.unlock(); return }
        cancelled = true
        shutdown(fd, Int32(SHUT_RDWR))
        lock.unlock()
        queue.async { [weak self] in self?.finishReading() }
    }

    public func pauseReading() {
        lock.lock(); readingPaused = true; lock.unlock()
        queue.async { [weak self] in self?.updateReadSuspension() }
    }

    public func resumeReading() {
        lock.lock(); readingPaused = false; lock.unlock()
        queue.async { [weak self] in
            guard let self else { return }
            self.updateReadSuspension()
            self.readReady()
        }
    }

    private func updateReadSuspension() {
        lock.lock(); let paused = readingPaused; lock.unlock()
        guard let reader else { return }
        if paused && !readerSuspended { reader.suspend(); readerSuspended = true }
        if !paused && readerSuspended { reader.resume(); readerSuspended = false }
    }
    func start(onData: @escaping @Sendable (Data, UInt64) -> Void, onEnd: (@Sendable () -> Void)?) {
        start(onResponse: { response in
            if case let .data(data, sequence) = response { onData(data, sequence) }
        }, onEnd: onEnd)
    }

    func start(
        onResponse: @escaping @Sendable (IPCResponse) -> Void,
        onEnd: (@Sendable () -> Void)?
    ) {
        queue.async { [self] in
            responseHandler = onResponse
            _ = fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_NONBLOCK)
            let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
            source.setEventHandler { [weak self] in self?.readReady() }
            let descriptor = fd, descriptorWriteLock = writeLock
            source.setCancelHandler {
                descriptorWriteLock.lock(); close(descriptor); descriptorWriteLock.unlock()
                onEnd?()
            }
            reader = source; source.resume()
            lock.lock(); let dead = cancelled || finished; lock.unlock()
            if dead { finishReading() } else { updateReadSuspension() }
        }
    }

    private func readReady() {
        guard reader != nil else { return }
        for _ in 0..<16 {
            while true {
                lock.lock(); let dead = cancelled || finished, paused = readingPaused; lock.unlock()
                if dead { finishReading(); return }
                if paused { updateReadSuspension(); return }
                let decoded: IPCCodec.DecodedReplyFrame?
                do { decoded = try IPCCodec.decodeReplyOrData(from: &readBuffer) }
                catch { finishReading(); return }
                guard let decoded else { break }
                switch decoded {
                case let .reply(response):
                    if case let .inputRejected(message) = response { reportInputFailure(message) }
                    if case let .error(message) = response { reportInputFailure(message) }
                    responseHandler?(response)
                    if case .error = response { finishReading(); return }
                case let .output(data, sequence): responseHandler?(.data(data, sequence: sequence))
                }
            }
            let count = scratch.withUnsafeMutableBytes { read(fd, $0.baseAddress, $0.count) }
            if count < 0, errno == EINTR { continue }
            if count < 0, errno == EAGAIN || errno == EWOULDBLOCK { return }
            if count <= 0 { finishReading(); return }
            readBuffer.append(scratch, count: count)
        }
        // The last read may have filled complete frames even if the socket is now empty.
        queue.async { [weak self] in self?.readReady() }
    }

    private func reportInputFailure(_ message: String) {
        lock.lock(); let handler = inputErrorHandler; lock.unlock()
        handler?(message)
    }

    private func finishReading() {
        guard let source = reader else { return }
        lock.lock(); finished = true; lock.unlock()
        if readerSuspended { source.resume(); readerSuspended = false }
        reader = nil; responseHandler = nil; readBuffer.removeAll()
        source.setEventHandler {}; source.cancel()
    }

    deinit {
        cancel()
        if readerSuspended { reader?.resume() }
        reader?.cancel()
    }
}

public struct FollowStreamError: Error, CustomStringConvertible {
    public var message: String
    public var description: String { message }
    public init(message: String) { self.message = message }
}

public enum DaemonClientError: Error, CustomStringConvertible {
    case connectionFailed
    case writeFailed
    case timeout
    case unexpectedResponse

    public var description: String {
        switch self {
        case .connectionFailed: "Could not connect to HarnessDaemon"
        case .writeFailed: "Failed to write IPC request"
        case .timeout: "HarnessDaemon request timed out"
        case .unexpectedResponse: "Unexpected response from HarnessDaemon"
        }
    }
}
