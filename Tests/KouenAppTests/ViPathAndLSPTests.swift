import XCTest
@testable import KouenApp
@testable import KouenLSP

// MARK: - Vi path token extraction (gf)

@MainActor
final class ViPathTokenTests: XCTestCase {

    // MARK: stripLineColumnSuffix

    func testStripLineOnly() {
        XCTAssertEqual(ViEngine.stripLineColumnSuffix("src/App.swift:42"), "src/App.swift")
    }

    func testStripLineAndColumn() {
        XCTAssertEqual(ViEngine.stripLineColumnSuffix("src/App.swift:42:10"), "src/App.swift")
    }

    func testNoSuffixReturnsSame() {
        XCTAssertEqual(ViEngine.stripLineColumnSuffix("src/App.swift"), "src/App.swift")
    }

    func testColonInPathPreserved() {
        XCTAssertEqual(ViEngine.stripLineColumnSuffix("C:foo/bar.txt:10"), "C:foo/bar.txt")
    }

    func testNonNumericSuffixPreserved() {
        XCTAssertEqual(ViEngine.stripLineColumnSuffix("file.txt:warning"), "file.txt:warning")
    }

    func testEmptyString() {
        XCTAssertEqual(ViEngine.stripLineColumnSuffix(""), "")
    }

    // MARK: isPathTokenChar

    func testAlphanumericIsPathChar() {
        XCTAssertTrue(ViEngine.isPathTokenChar(Character("a").unicodeScalars.first!.value.asUnichar))
        XCTAssertTrue(ViEngine.isPathTokenChar(Character("Z").unicodeScalars.first!.value.asUnichar))
        XCTAssertTrue(ViEngine.isPathTokenChar(Character("9").unicodeScalars.first!.value.asUnichar))
    }

    func testSlashDotDashArePathChars() {
        for ch: Character in ["/", ".", "_", "-", "~", ":", "@", "+"] {
            let u = UInt16(ch.asciiValue!)
            XCTAssertTrue(ViEngine.isPathTokenChar(u), "\(ch) should be a path char")
        }
    }

    func testSpaceNotPathChar() {
        XCTAssertFalse(ViEngine.isPathTokenChar(UInt16(Character(" ").asciiValue!)))
    }

    func testBracketsNotPathChar() {
        for ch: Character in ["(", ")", "[", "]", "{", "}", "<", ">"] {
            XCTAssertFalse(ViEngine.isPathTokenChar(UInt16(ch.asciiValue!)), "\(ch) should not be a path char")
        }
    }

    func testSurrogateReturnsFalse() {
        XCTAssertFalse(ViEngine.isPathTokenChar(0xD800))
    }
}

// MARK: - LSPTextLocationParser edge cases

final class LSPTextLocationParserTests: XCTestCase {

    func testBasicParse() {
        let loc = LSPTextLocationParser.parse("src/main.swift:10:5", relativeTo: URL(fileURLWithPath: "/project"))
        XCTAssertNotNil(loc)
        XCTAssertEqual(loc?.line, 10)
        XCTAssertEqual(loc?.column, 5)
        XCTAssertTrue(loc?.fileURL.path.hasSuffix("src/main.swift") ?? false)
    }

    func testAbsolutePath() {
        let loc = LSPTextLocationParser.parse("/usr/src/file.rs:1:1")
        XCTAssertNotNil(loc)
        XCTAssertEqual(loc?.fileURL.path, "/usr/src/file.rs")
    }

    func testTildeExpansion() {
        let loc = LSPTextLocationParser.parse("~/project/file.py:5:3")
        XCTAssertNotNil(loc)
        XCTAssertFalse(loc?.fileURL.path.contains("~") ?? true)
    }

    func testColonInPath() {
        let loc = LSPTextLocationParser.parse("C:Users:foo:bar.txt:12:4", relativeTo: URL(fileURLWithPath: "/"))
        XCTAssertNotNil(loc)
        XCTAssertEqual(loc?.line, 12)
        XCTAssertEqual(loc?.column, 4)
        XCTAssertTrue(loc?.fileURL.path.contains("C:Users:foo:bar.txt") ?? false)
    }

    func testMissingColumnReturnNil() {
        XCTAssertNil(LSPTextLocationParser.parse("file.txt:10"))
    }

    func testZeroLineReturnNil() {
        XCTAssertNil(LSPTextLocationParser.parse("file.txt:0:1"))
    }

    func testZeroColumnReturnNil() {
        XCTAssertNil(LSPTextLocationParser.parse("file.txt:1:0"))
    }

    func testEmptyStringReturnNil() {
        XCTAssertNil(LSPTextLocationParser.parse(""))
    }

    func testNonNumericLineReturnNil() {
        XCTAssertNil(LSPTextLocationParser.parse("file.txt:abc:1"))
    }

    func testPositionConvertsTo0Based() {
        let loc = LSPTextLocationParser.parse("f.swift:10:5")!
        XCTAssertEqual(loc.position.line, 9)
        XCTAssertEqual(loc.position.character, 4)
    }
}

// MARK: - Helpers

private extension UInt32 {
    var asUnichar: UInt16 { UInt16(self) }
}
