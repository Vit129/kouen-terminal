import Foundation
import HarnessCore

// SGR 73 = start exclude-from-copy, SGR 74 = end. Cells rendered normally but skipped by
// Harness copy logic — line numbers appear on screen but are never pasted.
private let excludeOn  = "\u{1B}[73m"
private let excludeOff = "\u{1B}[74m"

extension HarnessCLI {
    static func handleCat(_ args: [String]) -> Int {
        let paths = positionalArgs(args, skippingValuesFor: [])
        guard let path = paths.first else {
            fputs("Usage: harness-cli cat <file>\n", harnessStderr)
            return 64
        }
        do {
            let text = try HarnessFilePreviewLoader.load(path: path)
            let lines = text.components(separatedBy: "\n")
            let width = String(lines.count).count
            for (i, line) in lines.enumerated() {
                let num = String(i + 1).leftPadded(width)
                print("\(excludeOn)\(num) │\(excludeOff) \(line)")
            }
            return 0
        } catch HarnessViewError.tooLarge(let size) {
            fputs("File too large (\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))).\n", harnessStderr)
            return 1
        } catch HarnessViewError.binaryOrUnsupportedEncoding {
            fputs("Binary or unsupported encoding.\n", harnessStderr)
            return 1
        } catch {
            fputs("Unable to read file.\n", harnessStderr)
            return 1
        }
    }
}

private extension String {
    func leftPadded(_ width: Int) -> String {
        count < width ? String(repeating: " ", count: width - count) + self : self
    }
}
