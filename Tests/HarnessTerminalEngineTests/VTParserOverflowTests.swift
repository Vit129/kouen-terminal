import XCTest
@testable import HarnessTerminalEngine

/// A string payload past its cap is a different command once truncated (a cut OSC 52 body,
/// an OSC 7501 prefix), so the parser must consume it without dispatching. These cover the
/// per-byte, bulk, borrowed, chunk-split, and checkpoint paths.
final class VTParserOverflowTests: XCTestCase {
    private final class Recorder: VTParserHandler {
        var osc: [[UInt8]] = []
        var dcs: [[UInt8]] = []
        var apc: [[UInt8]] = []
        var printed: [UInt32] = []
        func parserPrint(_ scalar: UInt32) { printed.append(scalar) }
        func parserExecute(_ control: UInt8) {}
        func parserCSI(final: UInt8, params: CSIParams, intermediates: [UInt8], isPrivate: Bool, privateMarker: UInt8?) {}
        func parserESC(final: UInt8, intermediates: [UInt8]) {}
        func parserOSC(_ data: UnsafeBufferPointer<UInt8>, sequenceLength: Int) { osc.append(Array(data)) }
        func parserDCS(_ data: [UInt8]) { dcs.append(data) }
        func parserAPC(_ data: [UInt8]) { apc.append(data) }
    }

    private let oscCap = 1 << 20
    private let stringCap = 32 << 20

    private func osc(payloadBytes: Int, terminator: String = "\u{7}") -> [UInt8] {
        var bytes = Array("\u{1b}]0;".utf8)
        bytes += [UInt8](repeating: UInt8(ascii: "x"), count: payloadBytes - 2)
        bytes += Array(terminator.utf8)
        return bytes
    }

    private let followUp = Array("\u{1b}]2;ok\u{1b}\\".utf8)

    func testOSCAtCapDispatchesInEveryFeedShape() {
        let sequence = osc(payloadBytes: oscCap)
        for shape in FeedShape.allCases {
            let recorder = Recorder()
            shape.feed(sequence, into: VTParser(handler: recorder))
            XCTAssertEqual(recorder.osc.count, 1, "\(shape)")
            XCTAssertEqual(recorder.osc.first?.count, oscCap, "\(shape)")
        }
    }

    func testOSCOverCapIsDroppedInEveryFeedShape() {
        for terminator in ["\u{7}", "\u{1b}\\"] {
            let sequence = osc(payloadBytes: oscCap + 1, terminator: terminator) + followUp + Array("Z".utf8)
            for shape in FeedShape.allCases {
                let recorder = Recorder()
                shape.feed(sequence, into: VTParser(handler: recorder))
                XCTAssertEqual(recorder.osc, [Array("2;ok".utf8)], "\(shape) terminator \(terminator.utf8.count)")
                XCTAssertEqual(recorder.printed, [UInt32(UInt8(ascii: "Z"))], "\(shape)")
            }
        }
    }

    func testOverflowSurvivesCheckpointRestore() throws {
        let sequence = osc(payloadBytes: oscCap + 10)
        let split = sequence.count - 1
        let source = Recorder()
        let parser = VTParser(handler: source)
        parser.feed(Array(sequence.prefix(split)))
        let saved = try parser.checkpointState()
        XCTAssertEqual(saved.oscOverflow, true)

        let target = Recorder()
        let restored = VTParser(handler: target)
        try restored.restore(saved)
        restored.feed(Array(sequence.suffix(from: split)) + followUp)
        XCTAssertEqual(target.osc, [Array("2;ok".utf8)])
    }

    func testCheckpointWithoutOverflowFieldTreatsFullBufferAsOverflowed() throws {
        let parser = VTParser(handler: Recorder())
        parser.feed(Array(osc(payloadBytes: oscCap + 10).dropLast()))
        var legacy = try parser.checkpointState()
        legacy.oscOverflow = nil
        legacy.stringOverflow = nil

        let target = Recorder()
        let restored = VTParser(handler: target)
        try restored.restore(legacy)
        restored.feed(Array("\u{7}".utf8) + followUp)
        XCTAssertEqual(target.osc, [Array("2;ok".utf8)])

        let short = VTParser(handler: Recorder())
        short.feed(Array("\u{1b}]0;title".utf8))
        var shortLegacy = try short.checkpointState()
        shortLegacy.oscOverflow = nil
        let shortTarget = Recorder()
        let shortRestored = VTParser(handler: shortTarget)
        try shortRestored.restore(shortLegacy)
        shortRestored.feed(Array("\u{7}".utf8))
        XCTAssertEqual(shortTarget.osc, [Array("0;title".utf8)])
    }

    func testOverflowedDCSAndAPCAreDroppedAndNextStringDispatches() {
        for (introducer, keyPath) in [("P", \Recorder.dcs), ("_", \Recorder.apc)] {
            let recorder = Recorder()
            let parser = VTParser(handler: recorder)
            var bytes = Array("\u{1b}\(introducer)".utf8)
            bytes += [UInt8](repeating: UInt8(ascii: "q"), count: stringCap + 1)
            bytes += Array("\u{1b}\\\u{1b}\(introducer)ok\u{1b}\\".utf8)
            parser.feed(bytes)
            XCTAssertEqual(recorder[keyPath: keyPath], [Array("ok".utf8)], introducer)
        }
    }

    func testOversizedClipboardWriteDoesNotReachTheClipboard() {
        let term = TerminalEmulator(cols: 20, rows: 4)
        var copied: String?
        term.onSetClipboard = { copied = $0 }
        var bytes = Array("\u{1b}]52;c;".utf8)
        bytes += [UInt8](repeating: UInt8(ascii: "A"), count: oscCap)
        bytes += Array("\u{7}".utf8)
        term.feed(Data(bytes))
        XCTAssertNil(copied)
        term.feed("\u{1b}]52;c;aGk=\u{7}")
        XCTAssertEqual(copied, "hi")
    }

    private enum FeedShape: CaseIterable {
        case bulk, scalarwise, chunked

        func feed(_ bytes: [UInt8], into parser: VTParser<Recorder>) {
            switch self {
            case .bulk: parser.feed(bytes)
            case .scalarwise: parser.feedScalarwise(bytes)
            case .chunked:
                var start = 0
                while start < bytes.count {
                    let end = min(start + 4093, bytes.count)
                    parser.feed(Array(bytes[start..<end]))
                    start = end
                }
            }
        }
    }
}
