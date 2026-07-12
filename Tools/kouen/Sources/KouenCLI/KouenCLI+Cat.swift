import Foundation
import KouenCore

// SGR 73 = start exclude-from-copy, SGR 74 = end. Cells rendered normally but skipped by
// Kouen copy logic — line numbers appear on screen but are never pasted.
private let excludeOn  = "\u{1B}[73m"
private let excludeOff = "\u{1B}[74m"

extension KouenCLI {
    static func handleCat(_ args: [String]) -> Int {
        let paths = positionalArgs(args, skippingValuesFor: [])
        guard let path = paths.first else {
            fputs("Usage: kouen-cli cat <file>\n", kouenStderr)
            return 64
        }
        do {
            let text = try KouenFilePreviewLoader.load(path: path)
            // When running inside Kouen, emit OSC 7736 so the sidebar file tree scrolls to and
            // highlights this file — tree only, no viewer tab (that's `kouen view`'s job).
            if ProcessInfo.processInfo.environment["KOUEN_SURFACE_ID"] != nil {
                let expanded = (path.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).expandingTildeInPath
                let abs = URL(fileURLWithPath: expanded).path
                print("\u{1B}]7736;\(abs)\u{07}", terminator: "")
            }
            let lines = text.components(separatedBy: "\n")
            let width = String(lines.count).count
            for (i, line) in lines.enumerated() {
                let num = String(i + 1).leftPadded(width)
                print("\(excludeOn)\(num) │\(excludeOff) \(line)")
            }
            return 0
        } catch KouenViewError.tooLarge(let size) {
            fputs("File too large (\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))).\n", kouenStderr)
            return 1
        } catch KouenViewError.binaryOrUnsupportedEncoding {
            fputs("Binary or unsupported encoding.\n", kouenStderr)
            return 1
        } catch {
            fputs("Unable to read file.\n", kouenStderr)
            return 1
        }
    }
}

private extension String {
    func leftPadded(_ width: Int) -> String {
        count < width ? String(repeating: " ", count: width - count) + self : self
    }
}
