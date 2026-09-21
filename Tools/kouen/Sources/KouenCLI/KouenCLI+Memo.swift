import Foundation
import KouenCore

extension KouenCLI {
    /// Manages the shared inter-agent scratchpad.
    /// `kouen memo set <key> <value>`
    /// `kouen memo get <key>`
    /// `kouen memo list [--json]`
    /// `kouen memo delete <key>`
    /// `kouen memo clear`
    static func handleMemo(_ args: [String], client: DaemonClient) throws {
        guard let sub = args.first else {
            printMemoUsage()
            return
        }

        let storeURL = KouenPaths.memoURL
        try? KouenPaths.ensureDirectories()

        switch sub {
        case "set":
            guard args.count >= 3 else {
                fputs("Usage: kouen memo set <key> <value>\n", kouenStderr)
                return
            }
            let key = args[1]
            let val = args[2...].joined(separator: " ")
            KouenPaths.withFileLock(KouenPaths.memoLockURL) {
                var map = loadMemoMap(from: storeURL)
                map[key] = val
                saveMemoMap(map, to: storeURL)
            }
            print("memo[\(key)] set")

        case "get":
            guard args.count >= 2 else {
                fputs("Usage: kouen memo get <key>\n", kouenStderr)
                return
            }
            let key = args[1]
            let map = loadMemoMap(from: storeURL)
            if let val = map[key] {
                print(val)
            } else {
                fputs("memo: key '\(key)' not found\n", kouenStderr)
                exit(1)
            }

        case "list":
            let map = loadMemoMap(from: storeURL)
            if args.contains("--json") {
                let data = (try? JSONSerialization.data(withJSONObject: map, options: [.prettyPrinted, .sortedKeys])) ?? Data()
                print(String(data: data, encoding: .utf8) ?? "{}")
                return
            }
            if map.isEmpty {
                print("memo: no entries")
                return
            }
            print(String(format: "%-20@ %@", "KEY" as NSString, "VALUE" as NSString))
            print(String(repeating: "-", count: 60))
            for key in map.keys.sorted() {
                print(String(format: "%-20@ %@", key as NSString, (map[key] ?? "") as NSString))
            }

        case "delete", "rm":
            guard args.count >= 2 else {
                fputs("Usage: kouen memo delete <key>\n", kouenStderr)
                return
            }
            let key = args[1]
            let existed = KouenPaths.withFileLock(KouenPaths.memoLockURL) { () -> Bool in
                var map = loadMemoMap(from: storeURL)
                guard map.removeValue(forKey: key) != nil else { return false }
                saveMemoMap(map, to: storeURL)
                return true
            }
            if existed {
                print("memo[\(key)] deleted")
            } else {
                fputs("memo: key '\(key)' not found\n", kouenStderr)
            }

        case "clear":
            KouenPaths.withFileLock(KouenPaths.memoLockURL) {
                saveMemoMap([:], to: storeURL)
            }
            print("memo: cleared all entries")

        default:
            printMemoUsage()
        }
    }

    private static func printMemoUsage() {
        print("""
        Usage: kouen memo <command> [arguments]

        Commands:
          set <key> <val>     Store key-value in shared agent scratchpad
          get <key>           Retrieve value for key
          list [--json]       List all scratchpad entries
          delete <key>        Remove key
          clear               Clear all scratchpad entries
        """)
    }

    private static func loadMemoMap(from url: URL) -> [String: String] {
        guard let data = try? Data(contentsOf: url),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else { return [:] }
        return dict
    }

    private static func saveMemoMap(_ map: [String: String], to url: URL) {
        guard let data = try? JSONSerialization.data(withJSONObject: map, options: [.prettyPrinted, .sortedKeys])
        else { return }
        _ = KouenPaths.atomicWrite(data, to: url, label: "KouenCLI+Memo")
    }
}
