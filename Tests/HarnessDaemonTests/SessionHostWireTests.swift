import Foundation
import XCTest
@testable import HarnessDaemonCore
import HarnessCore
import HarnessTerminalEngine
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

final class SessionHostWireTests: XCTestCase {
    func testListenerIsOwnerOnlyUnderPermissiveUmaskAndAcceptsSameUserPeers() throws {
        let path = "/tmp/hs-\(UUID().uuidString.prefix(8)).sock"
        let previous = umask(0)
        defer { umask(previous) }
        let listener = SessionHostListener(path: path)
        let accepted = expectation(description: "same-user peer accepted")
        try listener.start { channel in channel.closeChannel(); accepted.fulfill() }
        defer { listener.stop() }

        var info = stat()
        XCTAssertEqual(lstat(path, &info), 0)
        XCTAssertEqual(info.st_mode & 0o777, 0o600)

        let client = socket(AF_UNIX, SOCK_STREAM, 0)
        defer { close(client) }
        var address = sockaddr_un(); address.sun_family = sa_family_t(AF_UNIX)
        let capacity = MemoryLayout.size(ofValue: address.sun_path)
        path.withCString { raw in withUnsafeMutablePointer(to: &address.sun_path) {
            _ = strncpy(UnsafeMutableRawPointer($0).assumingMemoryBound(to: CChar.self), raw, capacity - 1)
        } }
        let connected = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(client, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
        } }
        XCTAssertEqual(connected, 0)
        wait(for: [accepted], timeout: 5)
    }

    func testPlainOutputAcknowledgementsAccumulateAcrossSmallBatchesAndRecovery() {
        var consumed: UInt64?
        var fences: [UInt64] = []
        let packet: UInt64 = 65536
        for index in 0..<128 {
            let start = 1 + UInt64(index) * packet
            if let fence = SurfaceRegistry.observationAcknowledgement(start: start, end: start + packet,
                force: false, acknowledgedThrough: &consumed) { fences.append(fence) }
        }
        XCTAssertEqual(fences, (1...16).map { 1 + UInt64($0) * (512 << 10) },
            "A fresh plain stream must release the producer before its 4 MiB high-water mark")
        let recoveryEnd = fences.last! + (4 << 20)
        XCTAssertEqual(SurfaceRegistry.observationAcknowledgement(start: fences.last!, end: recoveryEnd,
            force: true, acknowledgedThrough: &consumed), recoveryEnd)
        XCTAssertNil(SurfaceRegistry.observationAcknowledgement(start: 1, end: 65537,
            force: true, acknowledgedThrough: &consumed), "Queued observations cannot move a recovered fence backward")
        XCTAssertEqual(consumed, recoveryEnd)
    }

    func testFinalRepliesSurviveRepeatedPeerReplacement() throws {
        _ = testSIGPIPEIgnored
        let request = try IPCCodec.encode(IPCEnvelope(request: .ping))
        let reply = try IPCCodec.encode(IPCReply(response: .pong))
        for _ in 0..<128 {
            var descriptors: [Int32] = [-1, -1]
            #if canImport(Darwin)
            let streamType = SOCK_STREAM
            #else
            let streamType = Int32(SOCK_STREAM.rawValue)
            #endif
            XCTAssertEqual(socketpair(AF_UNIX, streamType, 0, &descriptors), 0)
            let channel = SessionHostChannel(fd: descriptors[0])
            var timeout = timeval(tv_sec: 2, tv_usec: 0)
            XCTAssertEqual(setsockopt(descriptors[1], SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size)), 0)
            channel.start(onFrame: { frame in
                if frame == request { channel.send(reply); channel.closeAfterWrites() }
            })
            XCTAssertEqual(request.withUnsafeBytes { sysWrite(descriptors[1], $0.baseAddress, $0.count) }, request.count)
            var received = Data(), bytes = [UInt8](repeating: 0, count: 256)
            while received.count < reply.count {
                let count = read(descriptors[1], &bytes, bytes.count)
                guard count > 0 else { XCTFail("Replacement peer lost its final reply"); break }
                received.append(contentsOf: bytes.prefix(count))
            }
            XCTAssertEqual(received, reply)
            sysClose(descriptors[1])
            channel.closeChannel()
        }
    }
    func testFragmentedMixedFramesKeepTheirOrderAcrossBufferCompaction() throws {
        _ = testSIGPIPEIgnored
        var descriptors: [Int32] = [-1, -1]
        #if canImport(Darwin)
        let streamType = SOCK_STREAM
        #else
        let streamType = Int32(SOCK_STREAM.rawValue)
        #endif
        XCTAssertEqual(socketpair(AF_UNIX, streamType, 0, &descriptors), 0)
        let receiver = SessionHostChannel(fd: descriptors[0])
        defer { receiver.closeChannel(); sysClose(descriptors[1]) }
        let expected = try (0..<64).map { index -> Data in
            if index.isMultiple(of: 2) { return try IPCCodec.encode(IPCEnvelope(request: .ping)) }
            return try IPCCodec.encodeInputFrame(surfaceID: "pane", payload: Data("\(index)".utf8))
        }
        let received = FrameBox()
        let done = expectation(description: "all mixed frames")
        receiver.start(onFrame: { frame in if received.append(frame) == expected.count { done.fulfill() } })
        // Each write splits a different header/body boundary; several reads consume
        // complete frames and then leave a partial successor in the same buffer.
        let combined = expected.reduce(into: Data()) { $0.append($1) }
        var offset = 0
        while offset < combined.count {
            let size = min(17, combined.count - offset)
            let chunk = combined.subdata(in: offset..<(offset + size))
            XCTAssertEqual(chunk.withUnsafeBytes { sysWrite(descriptors[1], $0.baseAddress, $0.count) }, size)
            offset += size
        }
        wait(for: [done], timeout: 3)
        XCTAssertEqual(received.frames, expected)
    }
    func testLargeReplayStreamsBeforeLiveOutputAndFinishesAfterExit() throws {
        _ = testSIGPIPEIgnored
        var descriptors: [Int32] = [-1, -1]
        #if canImport(Darwin)
        let streamType = SOCK_STREAM
        #else
        let streamType = Int32(SOCK_STREAM.rawValue)
        #endif
        XCTAssertEqual(socketpair(AF_UNIX, streamType, 0, &descriptors), 0)
        var socketBudget: Int32 = 4096
        XCTAssertEqual(setsockopt(descriptors[0], SOL_SOCKET, SO_SNDBUF, &socketBudget, socklen_t(MemoryLayout<Int32>.size)), 0)
        let sender = SessionHostChannel(fd: descriptors[0])
        let receiver = SessionHostChannel(fd: descriptors[1])
        defer { sender.closeChannel(); receiver.closeChannel() }
        sender.start(onFrame: { _ in })
        let frontend = Frontend(channel: sender)
        let size = 512 << 10
        let bytes = Data(repeating: 0x55, count: size)
        let chunks = (0..<80).map { RealPty.ScrollbackReplaySegment(sequence: UInt64(1 + $0 * size), data: bytes) }
        let end = UInt64(1 + chunks.count * size)
        let tail = Data("final-live-query".utf8)
        let frames = FrameBox()
        let finished = expectation(description: "history and final live output drained")
        frontend.beginAttach()
        frontend.finishAttach(reply: AttachReply(epoch: "test", resync: true, endSequence: end), chunks: chunks)
        frontend.output(tail, sequence: end)
        frontend.finishAfterOutput()
        // Start the reader after the sender has encountered kernel socket pressure.
        receiver.start(onFrame: { frame in _ = frames.append(frame) }, onEnd: { finished.fulfill() })
        wait(for: [finished], timeout: 10)
        let actual = frames.frames
        XCTAssertEqual(actual.count, chunks.count + 2)
        guard actual.count == chunks.count + 2 else { return }
        var first = actual[0]
        guard case .reply(.attached) = try IPCCodec.decodeReplyOrData(from: &first) else { return XCTFail("Missing ordered attach barrier") }
        for (index, chunk) in chunks.enumerated() {
            var frame = actual[index + 1]
            guard case let .output(data, sequence) = try IPCCodec.decodeReplyOrData(from: &frame) else { return XCTFail("Missing history chunk") }
            XCTAssertEqual(sequence, chunk.sequence)
            XCTAssertEqual(data, chunk.data)
        }
        var last = actual.last!
        guard case let .output(data, sequence) = try IPCCodec.decodeReplyOrData(from: &last) else { return XCTFail("Missing final live output") }
        XCTAssertEqual(sequence, end)
        XCTAssertEqual(data, tail)
    }

    func testCoalescedObservationsPreserveByteFencesAndSplitSemanticEvents() throws {
        let pty = RealPty(forTesting: ())
        pty.setScrollbackBytes(128 << 10)
        defer { pty.close() }
        _ = pty.subscribe { _, _ in }
        let packets = ObservationBox()
        let complete = expectation(description: "ordered coalesced semantic observations")
        let prefix = Data(repeating: 65, count: 256)
        let split = Data("\u{1b}]133;".utf8)
        let finish = Data("A\u{7}\u{7}\u{1b}[?2004h".utf8)
        let end = UInt64(1 + prefix.count * 128 + split.count + finish.count)
        pty.onObservation = { observation in
            packets.append(observation)
            if observation.endSequence == end { complete.fulfill() }
        }
        for _ in 0..<128 { pty.injectSyntheticOutput(prefix) }
        pty.injectSyntheticOutput(split); pty.injectSyntheticOutput(finish)
        wait(for: [complete], timeout: 3)
        var next: UInt64 = 1
        for packet in packets.values {
            XCTAssertEqual(packet.sequence, next)
            XCTAssertLessThanOrEqual(packet.byteCount, 65536)
            next = packet.endSequence
        }
        XCTAssertEqual(next, end)
        let events = packets.values.flatMap(\.events).map(\.event)
        XCTAssertEqual(events, [.osc(code: 133, body: "A", sequenceLength: 8), .bell, .bracketedPaste(true)])
        XCTAssertNil(packets.values.last?.scanner)
        XCTAssertEqual(packets.values.last?.retainedBytes, Int(end - 1))
    }

    func testTypedHostObservationPreservesSplitOSCAndBellSemantics() throws {
        var scanner = HarnessTerminalEngine.PtyStreamScanner()
        XCTAssertTrue(scanner.scanAnchored(Data("\u{1b}]133;".utf8), sequence: 1).isEmpty)
        let bytes = Data("A\u{7}\u{7}\u{1b}[?2004h".utf8)
        let events = scanner.scanAnchored(bytes, sequence: 7)
        let observation = HostedOutputObservation(streamIdentity: "stream", sequence: 7, byteCount: bytes.count, events: events, scanner: nil, retainedStart: 1, retainedBytes: 6 + bytes.count)
        let result = SessionHostResult.event(.output("pane", observation))
        let decoded = try JSONDecoder().decode(SessionHostResult.self, from: JSONEncoder().encode(result))
        guard case let .event(.output(id, copy)) = decoded else { return XCTFail("wrong host event") }
        XCTAssertEqual(id, "pane")
        XCTAssertEqual(copy.events, events)
        XCTAssertEqual(events.filter { $0.event == .bell }.count, 1)
        XCTAssertEqual(events.first?.event, .osc(code: 133, body: "A", sequenceLength: 8))
        XCTAssertEqual(events.last?.event, .bracketedPaste(true))
    }

    private final class ObservationBox: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: [HostedOutputObservation] = []
        func append(_ observation: HostedOutputObservation) { lock.lock(); storage.append(observation); lock.unlock() }
        var values: [HostedOutputObservation] { lock.lock(); defer { lock.unlock() }; return storage }
    }

    private final class FrameBox: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: [Data] = []
        func append(_ frame: Data) -> Int { lock.lock(); defer { lock.unlock() }; storage.append(frame); return storage.count }
        var frames: [Data] { lock.lock(); defer { lock.unlock() }; return storage }
    }
}
