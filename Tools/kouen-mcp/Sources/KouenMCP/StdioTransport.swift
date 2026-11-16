import Foundation
import KouenCore

enum TransportError: Error { case invalidUTF8Header, missingContentLength, frameTooLarge }

enum MCPStdioFraming {
    case contentLength
    case newline
}

final class MCPStdioBuffer {
    /// Largest accepted `Content-Length` body, and the most unframed bytes (no terminator yet)
    /// buffered; beyond either, the frame is dropped instead of growing memory without bound.
    static let maxFrameBytes = 16 * 1024 * 1024
    private var data = Data()

    func append(_ newData: Data) {
        data.append(newData)
        // No complete frame can be this large; a peer streaming unframed bytes must not OOM us.
        if data.count > Self.maxFrameBytes + 4096 && !data.starts(with: Data("Content-Length:".utf8)) {
            data.removeAll()
        }
    }

    func nextMessage() throws -> (JSONRPCMessage, MCPStdioFraming)? {
        trimLeadingNewlines()
        guard !data.isEmpty else { return nil }

        if data.starts(with: Data("Content-Length:".utf8)) {
            return try nextContentLengthMessage()
        }
        return try nextNewlineMessage()
    }

    private func nextContentLengthMessage() throws -> (JSONRPCMessage, MCPStdioFraming)? {
        guard let headerRange = data.range(of: Data("\r\n\r\n".utf8)) else {
            if data.count > 64 * 1024 {
                data.removeAll()
                throw TransportError.frameTooLarge
            }
            return nil
        }
        // Every error below first removes the bad frame so the caller can keep reading;
        // otherwise a malformed header would be re-parsed (and re-throw) forever.
        guard let header = String(data: data[..<headerRange.lowerBound], encoding: .utf8) else {
            data.removeSubrange(..<headerRange.upperBound)
            throw TransportError.invalidUTF8Header
        }
        guard let contentLength = header
            .components(separatedBy: "\r\n")
            .first(where: { $0.lowercased().hasPrefix("content-length:") })
            .flatMap({ Int($0.split(separator: ":", maxSplits: 1)[1].trimmingCharacters(in: .whitespaces)) })
        else {
            data.removeSubrange(..<headerRange.upperBound)
            throw TransportError.missingContentLength
        }
        guard contentLength >= 0, contentLength <= Self.maxFrameBytes else {
            data.removeSubrange(..<headerRange.upperBound)
            throw TransportError.frameTooLarge
        }

        let bodyStart = headerRange.upperBound
        let bodyEnd = bodyStart + contentLength
        guard data.count >= bodyEnd else { return nil }

        let body = data[bodyStart..<bodyEnd]
        data.removeSubrange(..<bodyEnd)
        return (try JSONDecoder().decode(JSONRPCMessage.self, from: body), .contentLength)
    }

    private func nextNewlineMessage() throws -> (JSONRPCMessage, MCPStdioFraming)? {
        guard let newlineIndex = data.firstIndex(of: 0x0A) else {
            return nil
        }
        var line = data[..<newlineIndex]
        if line.last == 0x0D {
            line = line.dropLast()
        }
        data.removeSubrange(...newlineIndex)
        guard !line.isEmpty else {
            return try nextMessage()
        }
        return (try JSONDecoder().decode(JSONRPCMessage.self, from: line), .newline)
    }

    private func trimLeadingNewlines() {
        while data.first == 0x0A || data.first == 0x0D {
            data.removeFirst()
        }
    }
}

/// Reads JSON-RPC messages from stdin and mirrors the client's framing for responses.
final class StdioTransport: @unchecked Sendable {
    let incoming: AsyncStream<JSONRPCMessage>
    private let continuation: AsyncStream<JSONRPCMessage>.Continuation
    private let framingLock = NSLock()
    private var framing = MCPStdioFraming.contentLength

    init() {
        var cont: AsyncStream<JSONRPCMessage>.Continuation?
        incoming = AsyncStream { cont = $0 }
        continuation = cont!
        startReading()
    }

    func send(_ message: JSONRPCMessage) {
        guard let body = try? JSONEncoder().encode(message) else { return }
        framingLock.lock()
        let currentFraming = framing
        framingLock.unlock()

        switch currentFraming {
        case .contentLength:
            var frame = Data("Content-Length: \(body.count)\r\n\r\n".utf8)
            frame.append(body)
            FileHandle.standardOutput.write(frame)
        case .newline:
            FileHandle.standardOutput.write(body)
            FileHandle.standardOutput.write(Data("\n".utf8))
        }
    }

    private func startReading() {
        let cont = continuation
        Thread.detachNewThread {
            let buffer = MCPStdioBuffer()
            while true {
                let data = FileHandle.standardInput.availableData
                if data.isEmpty { break }
                buffer.append(data)
                // A bad frame is already dropped by the buffer; skip it and keep serving.
                while true {
                    let next: (JSONRPCMessage, MCPStdioFraming)?
                    do { next = try buffer.nextMessage() } catch { continue }
                    guard let (message, framing) = next else { break }
                    self.framingLock.lock()
                    self.framing = framing
                    self.framingLock.unlock()
                    cont.yield(message)
                }
            }
            cont.finish()
        }
    }
}
