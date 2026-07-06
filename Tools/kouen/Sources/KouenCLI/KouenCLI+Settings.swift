import Foundation
import KouenCore

extension KouenCLI {
    /// `kouen settings export [path]` — serialise current settings to JSON.
    /// `kouen settings import <path>` — load settings from a JSON file and save.
    /// `kouen settings show` — print current settings as pretty JSON.
    static func handleSettings(args: [String]) {
        let sub = args.first ?? ""
        switch sub {
        case "export":
            let dest = args.dropFirst().first ?? "kouen-settings.json"
            let settings = KouenSettings.load()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            guard let data = try? encoder.encode(settings) else {
                fputs("kouen settings export: failed to encode settings\n", kouenStderr)
                exit(1)
            }
            let url: URL
            if dest.hasPrefix("/") {
                url = URL(fileURLWithPath: dest)
            } else {
                url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                    .appendingPathComponent(dest)
            }
            do {
                try data.write(to: url, options: .atomic)
                print("Exported settings to \(url.path)")
            } catch {
                fputs("kouen settings export: \(error.localizedDescription)\n", kouenStderr)
                exit(1)
            }

        case "import":
            guard let src = args.dropFirst().first else {
                fputs("Usage: kouen settings import <file>\n", kouenStderr)
                exit(64)
            }
            let url: URL
            if src.hasPrefix("/") {
                url = URL(fileURLWithPath: src)
            } else {
                url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                    .appendingPathComponent(src)
            }
            guard let data = try? Data(contentsOf: url) else {
                fputs("kouen settings import: cannot read \(url.path)\n", kouenStderr)
                exit(1)
            }
            guard let settings = try? JSONDecoder().decode(KouenSettings.self, from: data) else {
                fputs("kouen settings import: file is not a valid Kouen settings JSON\n", kouenStderr)
                exit(1)
            }
            do {
                try settings.save()
                print("Imported settings from \(url.path)")
                print("Restart Kouen or run `kouen source-config` to apply.")
            } catch {
                fputs("kouen settings import: \(error.localizedDescription)\n", kouenStderr)
                exit(1)
            }

        case "show", "":
            let settings = KouenSettings.load()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(settings), let json = String(data: data, encoding: .utf8) {
                print(json)
            } else {
                fputs("kouen settings show: failed to encode\n", kouenStderr)
                exit(1)
            }

        default:
            fputs("Usage: kouen settings <export|import|show> [path]\n", kouenStderr)
            fputs("  export [path]  — write current settings to JSON file (default: kouen-settings.json)\n", kouenStderr)
            fputs("  import <path>  — load settings from a JSON file\n", kouenStderr)
            fputs("  show           — print current settings as JSON\n", kouenStderr)
            exit(64)
        }
    }
}
