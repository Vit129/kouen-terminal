import Foundation
import HarnessCore

enum MCPStdioFraming {
    case contentLength
    case newline
}

final class MCPStdioBuffer {
    private var data = Data()

    func append(_ newData: Data) {
        data.append(newData)
    }

    func nextMessage() throws -> (ACPMessage, MCPStdioFraming)? {
        trimLeadingNewlines()
        guard !data.isEmpty else { return nil }

        if data.starts(with: Data("Content-Length:".utf8)) {
            return try nextContentLengthMessage()
        }
        return try nextNewlineMessage()
    }

    private func nextContentLengthMessage() throws -> (ACPMessage, MCPStdioFraming)? {
        guard let headerRange = data.range(of: Data("\r\n\r\n".utf8)) else {
            return nil
        }
        guard let header = String(data: data[..<headerRange.lowerBound], encoding: .utf8) else {
            throw ACPTransport.TransportError.invalidUTF8Header
        }
        guard let contentLength = header
            .components(separatedBy: "\r\n")
            .first(where: { $0.lowercased().hasPrefix("content-length:") })
            .flatMap({ Int($0.split(separator: ":", maxSplits: 1)[1].trimmingCharacters(in: .whitespaces)) })
        else {
            throw ACPTransport.TransportError.missingContentLength
        }

        let bodyStart = headerRange.upperBound
        let bodyEnd = bodyStart + contentLength
        guard data.count >= bodyEnd else { return nil }

        let message = try JSONDecoder().decode(ACPMessage.self, from: data[bodyStart..<bodyEnd])
        data.removeSubrange(..<bodyEnd)
        return (message, .contentLength)
    }

    private func nextNewlineMessage() throws -> (ACPMessage, MCPStdioFraming)? {
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
        return (try JSONDecoder().decode(ACPMessage.self, from: line), .newline)
    }

    private func trimLeadingNewlines() {
        while data.first == 0x0A || data.first == 0x0D {
            data.removeFirst()
        }
    }
}

/// Reads JSON-RPC messages from stdin and mirrors the client's framing for responses.
final class StdioTransport: @unchecked Sendable {
    let incoming: AsyncStream<ACPMessage>
    private let continuation: AsyncStream<ACPMessage>.Continuation
    private let framingLock = NSLock()
    private var framing = MCPStdioFraming.contentLength

    init() {
        var cont: AsyncStream<ACPMessage>.Continuation?
        incoming = AsyncStream { cont = $0 }
        continuation = cont!
        startReading()
    }

    func send(_ message: ACPMessage) {
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
                while let (message, framing) = try? buffer.nextMessage() {
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
