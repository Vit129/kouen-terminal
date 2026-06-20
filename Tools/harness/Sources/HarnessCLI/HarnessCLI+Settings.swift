import Foundation
import HarnessCore

extension HarnessCLI {
    /// `harness settings export [path]` — serialise current settings to JSON.
    /// `harness settings import <path>` — load settings from a JSON file and save.
    /// `harness settings show` — print current settings as pretty JSON.
    static func handleSettings(args: [String]) {
        let sub = args.first ?? ""
        switch sub {
        case "export":
            let dest = args.dropFirst().first ?? "harness-settings.json"
            let settings = HarnessSettings.load()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            guard let data = try? encoder.encode(settings) else {
                fputs("harness settings export: failed to encode settings\n", harnessStderr)
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
                fputs("harness settings export: \(error.localizedDescription)\n", harnessStderr)
                exit(1)
            }

        case "import":
            guard let src = args.dropFirst().first else {
                fputs("Usage: harness settings import <file>\n", harnessStderr)
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
                fputs("harness settings import: cannot read \(url.path)\n", harnessStderr)
                exit(1)
            }
            guard let settings = try? JSONDecoder().decode(HarnessSettings.self, from: data) else {
                fputs("harness settings import: file is not a valid Harness settings JSON\n", harnessStderr)
                exit(1)
            }
            do {
                try settings.save()
                print("Imported settings from \(url.path)")
                print("Restart Harness or run `harness source-config` to apply.")
            } catch {
                fputs("harness settings import: \(error.localizedDescription)\n", harnessStderr)
                exit(1)
            }

        case "show", "":
            let settings = HarnessSettings.load()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(settings), let json = String(data: data, encoding: .utf8) {
                print(json)
            } else {
                fputs("harness settings show: failed to encode\n", harnessStderr)
                exit(1)
            }

        default:
            fputs("Usage: harness settings <export|import|show> [path]\n", harnessStderr)
            fputs("  export [path]  — write current settings to JSON file (default: harness-settings.json)\n", harnessStderr)
            fputs("  import <path>  — load settings from a JSON file\n", harnessStderr)
            fputs("  show           — print current settings as JSON\n", harnessStderr)
            exit(64)
        }
    }
}
