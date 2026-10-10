#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore

extension KouenCLI {
    static func handleRC(_ args: [String]) -> Int32 {
        if args.contains("--help") || args.contains("-h") {
            print("""
            Usage: kouen-cli rc [--url] [--no-open] [--json] [--pretty]

            Open the Kouen Companion in Google Chrome.

            Options:
              --url        Print the resolved companion URL and exit
              --no-open    Do not launch Google Chrome
              --json       Output result as JSON
              --pretty     Format JSON output with indentation
            """)
            return 0
        }

        var targetURL = "http://localhost:7777"

        if let client = try? makeClient(args) {
            if let response = try? client.request(.mobilePairingInfo, timeout: 1),
               case let .mobilePairingInfo(url, _, enabled) = response {
                if !enabled {
                    _ = try? client.request(.setMobileBridgeEnabled(true), timeout: 1)
                    if let updatedResponse = try? client.request(.mobilePairingInfo, timeout: 1),
                       case let .mobilePairingInfo(updatedUrl, _, _) = updatedResponse,
                       let u = updatedUrl {
                        targetURL = u
                    }
                } else if let u = url {
                    targetURL = u
                }
            }
        }

        if args.contains("--json") {
            let pretty = args.contains("--pretty")
            let dict: [String: Any] = ["url": targetURL]
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: pretty ? [.prettyPrinted] : []),
               let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            return 0
        }

        if args.contains("--url") {
            print(targetURL)
            return 0
        }

        print("Opening Kouen Companion in Google Chrome: \(targetURL)")

        let shouldOpen = !args.contains("--no-open")
        let alreadyOpened = ProcessInfo.processInfo.environment["KOUEN_RC_OPENED"] == "1"
        if shouldOpen && (!alreadyOpened || targetURL != "http://localhost:7777") {
            #if os(macOS)
            let openProcess = Process()
            openProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            openProcess.arguments = ["-a", "Google Chrome", targetURL]
            try? openProcess.run()
            #endif
        }

        return 0
    }
}
