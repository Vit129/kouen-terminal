import Foundation
import KouenCore

public enum LSPClientError: Error, Equatable {
    case serverNotExecutable(String)
    case processNotRunning
    case missingPipe
    case requestFailed(String)
}

public actor LSPClient {
    public let incomingMessages: AsyncStream<LSPMessage>

    private var process: Process?
    private var stdinPipe: Pipe?
    private var stdoutPipe: Pipe?
    private var readBuffer = LSPTransportBuffer()
    private var readerTask: Task<Void, Never>?
    private var nextRequestID = 1
    private var pending: [Int: CheckedContinuation<AnyCodable?, Error>] = [:]
    private let continuation: AsyncStream<LSPMessage>.Continuation

    public init() {
        var streamContinuation: AsyncStream<LSPMessage>.Continuation?
        incomingMessages = AsyncStream { continuation in
            streamContinuation = continuation
        }
        continuation = streamContinuation!
    }

    public func launch(configuration: LSPServerConfiguration) throws {
        guard FileManager.default.isExecutableFile(atPath: configuration.executablePath) else {
            throw LSPClientError.serverNotExecutable(configuration.executablePath)
        }
        let proc = Process()
        let input = Pipe()
        let output = Pipe()
        proc.executableURL = URL(fileURLWithPath: configuration.executablePath)
        proc.arguments = configuration.arguments
        proc.currentDirectoryURL = configuration.rootURL
        proc.standardInput = input
        proc.standardOutput = output
        proc.standardError = FileHandle.nullDevice
        try proc.run()
        process = proc
        stdinPipe = input
        stdoutPipe = output
        startReading(fileHandle: output.fileHandleForReading)
    }

    public func initialize(rootURL: URL, processID: Int32 = getpid()) async throws {
        let params: AnyCodable = .object([
            "processId": .int(Int(processID)),
            "rootUri": .string(rootURL.absoluteString),
            "capabilities": .object([
                "textDocument": .object([
                    "hover": .object(["dynamicRegistration": .bool(false)]),
                    "definition": .object(["dynamicRegistration": .bool(false)]),
                    "publishDiagnostics": .object(["relatedInformation": .bool(false)]),
                ]),
            ]),
        ])
        _ = try await request(method: "initialize", params: params)
        try await notify(method: "initialized", params: .object([:]))
    }

    public func openDocument(url: URL, languageID: String, text: String, version: Int = 1) async throws {
        try await notify(method: "textDocument/didOpen", params: .object([
            "textDocument": .object([
                "uri": .string(url.absoluteString),
                "languageId": .string(languageID),
                "version": .int(version),
                "text": .string(text),
            ]),
        ]))
    }

    public func hover(url: URL, position: LSPPosition) async throws -> LSPHover? {
        let result = try await request(method: "textDocument/hover", params: textDocumentPosition(url: url, position: position))
        guard let result, result != .null else { return nil }
        let data = try JSONEncoder().encode(result)
        return try JSONDecoder().decode(LSPHover.self, from: data)
    }

    public func definition(url: URL, position: LSPPosition) async throws -> [LSPLocation] {
        let result = try await request(method: "textDocument/definition", params: textDocumentPosition(url: url, position: position))
        guard let result, result != .null else { return [] }
        let data = try JSONEncoder().encode(result)
        if let locations = try? JSONDecoder().decode([LSPLocation].self, from: data) {
            return locations
        }
        if let location = try? JSONDecoder().decode(LSPLocation.self, from: data) {
            return [location]
        }
        return []
    }

    public func changeDocument(url: URL, text: String, version: Int) async throws {
        // Full-text sync: the server advertises no incremental ranges from this client.
        try await notify(method: "textDocument/didChange", params: .object([
            "textDocument": .object([
                "uri": .string(url.absoluteString),
                "version": .int(version),
            ]),
            "contentChanges": .array([.object(["text": .string(text)])]),
        ]))
    }

    public func closeDocument(url: URL) async throws {
        try await notify(method: "textDocument/didClose", params: .object([
            "textDocument": .object(["uri": .string(url.absoluteString)]),
        ]))
    }

    /// Asks the server to shut down, but never waits longer than `timeout` for the reply
    /// (a hung server must not pin its process and pipes), then terminates and, if it
    /// ignores SIGTERM, SIGKILLs it.
    public func shutdown(timeout: Duration = .seconds(2)) async {
        if let proc = process, proc.isRunning {
            let watchdog = Task { [weak self] in
                try await Task.sleep(for: timeout)
                await self?.failAllPending(LSPClientError.requestFailed("shutdown timed out"))
            }
            _ = try? await request(method: "shutdown", params: nil)
            watchdog.cancel()
            try? await notify(method: "exit", params: nil)
        }
        stdoutPipe?.fileHandleForReading.readabilityHandler = nil
        readerTask?.cancel()
        if let proc = process, proc.isRunning {
            proc.terminate()
            let doomed = UncheckedProcess(proc)
            Task.detached {
                try? await Task.sleep(for: .seconds(1))
                if doomed.process.isRunning { kill(doomed.process.processIdentifier, SIGKILL) }
            }
        }
        failAllPending(LSPClientError.processNotRunning)
        continuation.finish()
        process = nil
        stdinPipe = nil
        stdoutPipe = nil
    }

    public func request(method: String, params: AnyCodable?) async throws -> AnyCodable? {
        guard process?.isRunning == true else { throw LSPClientError.processNotRunning }
        let id = nextRequestID
        nextRequestID += 1
        return try await withCheckedThrowingContinuation { continuation in
            pending[id] = continuation
            Task {
                do {
                    try await self.send(.request(id: .int(id), method: method, params: params))
                } catch {
                    self.failPending(id: id, error: error)
                }
            }
        }
    }

    public func notify(method: String, params: AnyCodable?) async throws {
        try await send(.notification(method: method, params: params))
    }

    private func send(_ message: LSPMessage) async throws {
        guard process?.isRunning == true else { throw LSPClientError.processNotRunning }
        guard let stdinPipe else { throw LSPClientError.missingPipe }
        let data = try LSPTransport.encode(message)
        try stdinPipe.fileHandleForWriting.write(contentsOf: data)
    }

    private func startReading(fileHandle: FileHandle) {
        // One unstructured Task per chunk is NOT order-preserving onto the actor; a
        // Content-Length frame split across chunks would then re-join out of order and kill
        // the stream. Funnel chunks through one AsyncStream drained by a single task instead.
        let (chunks, chunkContinuation) = AsyncStream<Data>.makeStream()
        fileHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty {
                handle.readabilityHandler = nil
                chunkContinuation.finish()
            } else {
                chunkContinuation.yield(data)
            }
        }
        readerTask?.cancel()
        readerTask = Task { [weak self] in
            for await data in chunks {
                await self?.processIncomingData(data)
            }
            await self?.finishReading()
        }
    }

    private func processIncomingData(_ data: Data) {
        readBuffer.append(data)
        do {
            while let message = try readBuffer.nextMessage() {
                continuation.yield(message)
                handle(message)
            }
        } catch {
            finishReading()
        }
    }

    private func finishReading() {
        stdoutPipe?.fileHandleForReading.readabilityHandler = nil
        failAllPending(LSPClientError.processNotRunning)
        continuation.finish()
    }

    private func failAllPending(_ error: Error) {
        let waiting = pending
        pending.removeAll()
        for (_, continuation) in waiting { continuation.resume(throwing: error) }
    }

    private func handle(_ message: LSPMessage) {
        guard case let .response(id, result, error) = message, case let .int(intID) = id else { return }
        guard let continuation = pending.removeValue(forKey: intID) else { return }
        if let error {
            continuation.resume(throwing: LSPClientError.requestFailed(error.message))
        } else {
            continuation.resume(returning: result)
        }
    }

    private func failPending(id: Int, error: Error) {
        pending.removeValue(forKey: id)?.resume(throwing: error)
    }

    private func textDocumentPosition(url: URL, position: LSPPosition) -> AnyCodable {
        .object([
            "textDocument": .object(["uri": .string(url.absoluteString)]),
            "position": .object([
                "line": .int(position.line),
                "character": .int(position.character),
            ]),
        ])
    }
}

/// Carries a `Process` into a detached task for the SIGKILL fallback; it only reads
/// `isRunning`/`processIdentifier`, which Foundation allows from any thread.
private struct UncheckedProcess: @unchecked Sendable {
    let process: Process
    init(_ process: Process) { self.process = process }
}
