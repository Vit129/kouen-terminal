import Foundation
import XCTest
@testable import KouenTerminalEngine

/// P38 Phase D — Kitty graphics protocol conformance slice (`a=q` query response, `a=t`+`a=p`
/// transmit-then-place-by-id, `a=d` delete). Transmit+display (`a=T`) itself already shipped in
/// P30 (see `ImageProtocolTests.swift`) — this file covers only what was added on top.
final class KittyGraphicsConformanceTests: XCTestCase {
    private func rgbaPayload(_ width: Int, _ height: Int) -> String {
        let pixels = [UInt8](repeating: 100, count: width * height * 4)
        return Data(pixels).base64EncodedString()
    }

    private func responses(_ term: TerminalEmulator, feed: (TerminalEmulator) -> Void) -> [String] {
        var raw: [String] = []
        term.onResponse = { raw.append(String(decoding: $0, as: UTF8.self)) }
        feed(term)
        return raw
    }

    // MARK: - a=q (query)

    func testQueryRespondsOKWithoutStoringOrDisplayingAnything() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let b64 = rgbaPayload(2, 2)
        let out = responses(term) { $0.feed("\u{1b}_Gf=32,s=2,v=2,i=7,a=q;\(b64)\u{1b}\\") }

        XCTAssertEqual(out.count, 1)
        XCTAssertTrue(out[0].contains("OK"), "expected OK response, got: \(out[0])")
        XCTAssertTrue(out[0].contains("i=7"))
        XCTAssertTrue(term.readGrid().images.isEmpty, "query must not place anything")
    }

    func testQueryRespondsWithErrorOnUndecodableFormat() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        // f=32 (RGBA) declared but payload too short for the stated dimensions — decode fails.
        let tooShort = Data([1, 2, 3]).base64EncodedString()
        let out = responses(term) { $0.feed("\u{1b}_Gf=32,s=10,v=10,i=1,a=q;\(tooShort)\u{1b}\\") }

        XCTAssertEqual(out.count, 1)
        XCTAssertFalse(out[0].contains("OK"))
        XCTAssertTrue(out[0].contains("i=1"))
    }

    func testQuietFlagSuppressesOKButNotError() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let b64 = rgbaPayload(2, 2)
        // q=1: suppress OK responses.
        let okSuppressed = responses(term) { $0.feed("\u{1b}_Gf=32,s=2,v=2,i=2,a=q,q=1;\(b64)\u{1b}\\") }
        XCTAssertTrue(okSuppressed.isEmpty, "q=1 must suppress OK responses")

        let tooShort = Data([1]).base64EncodedString()
        let errorStillSent = responses(term) { $0.feed("\u{1b}_Gf=32,s=10,v=10,i=3,a=q,q=1;\(tooShort)\u{1b}\\") }
        XCTAssertEqual(errorStillSent.count, 1, "q=1 must NOT suppress error responses")

        // q=2: suppress everything.
        let allSuppressed = responses(term) { $0.feed("\u{1b}_Gf=32,s=10,v=10,i=4,a=q,q=2;\(tooShort)\u{1b}\\") }
        XCTAssertTrue(allSuppressed.isEmpty, "q=2 must suppress both OK and error responses")
    }

    // MARK: - a=t / a=p (transmit-then-place-by-id)

    func testTransmitOnlyDoesNotDisplayUntilPlacedByID() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let b64 = rgbaPayload(16, 16)
        term.feed("\u{1b}_Gf=32,s=16,v=16,i=42,a=t;\(b64)\u{1b}\\")
        XCTAssertTrue(term.readGrid().images.isEmpty, "a=t must transmit without displaying")

        term.feed("\u{1b}_Gi=42,a=p\u{1b}\\")
        let imgs = term.readGrid().images
        XCTAssertEqual(imgs.count, 1, "a=p should place the previously transmitted image")
        XCTAssertEqual(imgs[0].cols, 2) // 16px / 8px cell
    }

    func testPlaceByIDCanRepeatForMultiplePlacements() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let b64 = rgbaPayload(8, 8)
        term.feed("\u{1b}_Gf=32,s=8,v=8,i=5,a=t;\(b64)\u{1b}\\")
        term.feed("\u{1b}_Gi=5,a=p\u{1b}\\")
        term.feed("\u{1b}_Gi=5,a=p\u{1b}\\")
        XCTAssertEqual(term.readGrid().images.count, 2, "transmit-once/place-many must work")
    }

    func testPlaceByUnknownIDRespondsError() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let out = responses(term) { $0.feed("\u{1b}_Gi=999,a=p\u{1b}\\") }
        XCTAssertEqual(out.count, 1)
        XCTAssertFalse(out[0].contains("OK"))
        XCTAssertTrue(term.readGrid().images.isEmpty)
    }

    // MARK: - a=d (delete)

    func testDeleteRemovesPlacementsForImageID() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let b64 = rgbaPayload(8, 8)
        term.feed("\u{1b}_Gf=32,s=8,v=8,i=9,a=T;\(b64)\u{1b}\\")
        XCTAssertEqual(term.readGrid().images.count, 1)

        term.feed("\u{1b}_Gi=9,a=d\u{1b}\\")
        XCTAssertTrue(term.readGrid().images.isEmpty, "a=d must remove the placement")
    }

    func testDeleteOnUnknownIDIsANoOp() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        term.feed("\u{1b}_Gi=123,a=d\u{1b}\\") // never transmitted — must not crash
        XCTAssertTrue(term.readGrid().images.isEmpty)
    }

    func testDeleteDoesNotAffectOtherImageIDs() {
        let term = TerminalEmulator(cols: 40, rows: 20)
        let b64 = rgbaPayload(8, 8)
        term.feed("\u{1b}_Gf=32,s=8,v=8,i=1,a=T;\(b64)\u{1b}\\")
        term.feed("\u{1b}_Gf=32,s=8,v=8,i=2,a=T;\(b64)\u{1b}\\")
        XCTAssertEqual(term.readGrid().images.count, 2)

        term.feed("\u{1b}_Gi=1,a=d\u{1b}\\")
        XCTAssertEqual(term.readGrid().images.count, 1, "deleting id=1 must not touch id=2's placement")
    }
    func test_TS_2361_BE_UT_kittyPendingSharesByteBudgetAcrossIDs() {
        let term = TerminalEmulator(cols: 4, rows: 2)
        term.kittyStorageByteLimit = 32
        let payload = rgbaPayload(2, 2) // 24 encoded bytes per pending transfer
        let out = responses(term) {
            $0.feed("\u{1b}_Gf=32,s=2,v=2,i=1,a=t,m=1;\(payload)\u{1b}\\")
            $0.feed("\u{1b}_Gf=32,s=2,v=2,i=2,a=t,m=1;\(payload)\u{1b}\\")
        }
        XCTAssertTrue(out.contains { $0.contains("ENOMEM") })
        term.feed("\u{1b}_Gi=1,m=0;\u{1b}\\")
        term.feed("\u{1b}_Gi=1,a=p\u{1b}\\")
        XCTAssertEqual(term.readGrid().images.count, 1, "accepted transfer must still complete")
    }

    func test_TS_2362_BE_UT_kittyTransmittedImagesShareByteBudget() {
        let term = TerminalEmulator(cols: 4, rows: 2)
        term.kittyStorageByteLimit = 32
        let payload = rgbaPayload(2, 2) // 16 decoded bytes
        for id in 1...3 {
            term.feed("\u{1b}_Gf=32,s=2,v=2,i=\(id),a=t;\(payload)\u{1b}\\")
        }
        let out = responses(term) { $0.feed("\u{1b}_Gi=1,a=p\u{1b}\\") }
        XCTAssertTrue(out.contains { $0.contains("ENOENT") })
        term.feed("\u{1b}_Gi=3,a=p\u{1b}\\")
        XCTAssertEqual(term.readGrid().images.count, 1)
    }

    func test_TS_2368_BE_UT_kittyReplacementDoesNotDoubleCountStoredPixels() {
        let term = TerminalEmulator(cols: 4, rows: 2)
        term.kittyStorageByteLimit = 16
        let payload = rgbaPayload(2, 2)
        let out = responses(term) {
            for _ in 0..<2 { $0.feed("\u{1b}_Gf=32,s=2,v=2,i=1,a=t;\(payload)\u{1b}\\") }
        }
        XCTAssertEqual(out.filter { $0.contains("OK") }.count, 2)
    }

    func test_TS_2369_BE_UT_pendingAndTransmittedImagesShareOneBudget() {
        let term = TerminalEmulator(cols: 4, rows: 2)
        term.kittyStorageByteLimit = 32
        let payload = rgbaPayload(2, 2)
        let out = responses(term) {
            $0.feed("\u{1b}_Gf=32,s=2,v=2,i=1,a=t,m=1;\(payload)\u{1b}\\")
            $0.feed("\u{1b}_Gf=32,s=2,v=2,i=2,a=t;\(payload)\u{1b}\\")
        }
        XCTAssertTrue(out.contains { $0.contains("ENOMEM") })
    }

}
