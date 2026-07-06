import Foundation
import KouenCore

enum KouenViewError: Error, Equatable {
    case missingPath
    case unreadable
    case tooLarge(Int)
    case binaryOrUnsupportedEncoding
}

enum KouenFilePreviewLoader {
    static let maxPreviewBytes = 1_000_000

    static func load(path: String, fileManager: FileManager = .default) throws -> String {
        let expanded = (path.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).expandingTildeInPath
        guard !expanded.isEmpty else { throw KouenViewError.missingPath }
        guard let attributes = try? fileManager.attributesOfItem(atPath: expanded),
              let size = attributes[.size] as? Int
        else { throw KouenViewError.unreadable }
        guard size <= maxPreviewBytes else { throw KouenViewError.tooLarge(size) }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: expanded)),
              let text = String(data: data, encoding: .utf8)
        else { throw KouenViewError.binaryOrUnsupportedEncoding }
        return text
    }
}

extension KouenCLI {
    static func handleView(_ args: [String]) -> Int {
        let paths = positionalArgs(args, skippingValuesFor: [])
        guard let path = paths.first else {
            fputs("Usage: kouen-cli view <file>\n", kouenStderr)
            return 64
        }

        // When running inside Kouen, emit OSC 7735 so the app opens the file in the sidebar
        // file viewer — line numbers are in a separate gutter NSView and are never copied.
        if ProcessInfo.processInfo.environment["KOUEN_SURFACE_ID"] != nil {
            let expanded = (path.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).expandingTildeInPath
            let abs = URL(fileURLWithPath: expanded).path
            print("\u{1B}]7735;\(abs)\u{07}", terminator: "")
            return 0
        }

        do {
            print(try KouenFilePreviewLoader.load(path: path), terminator: "")
            return 0
        } catch KouenViewError.tooLarge(let size) {
            print("File too large to preview (\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))).")
            return 1
        } catch KouenViewError.binaryOrUnsupportedEncoding {
            print("Unable to preview this file (binary or unsupported encoding).")
            return 1
        } catch {
            print("Unable to read file.")
            return 1
        }
    }
}
