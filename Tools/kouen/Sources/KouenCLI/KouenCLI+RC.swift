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

        // Never turn the bridge on from here: it exposes a token-gated WebSocket to the
        // network, so enabling it stays an explicit Settings → Remote choice.
        let client: DaemonClient
        do { client = try makeClient(args) } catch {
            FileHandle.standardError.write(Data("kouen-cli rc: daemon not reachable: \(error)\n".utf8))
            return 1
        }
        guard let response = try? client.request(.mobilePairingInfo, timeout: 1),
              case let .mobilePairingInfo(url, _, enabled) = response else {
            FileHandle.standardError.write(Data("kouen-cli rc: daemon did not return pairing info\n".utf8))
            return 1
        }
        guard enabled, let targetURL = url else {
            FileHandle.standardError.write(Data("kouen-cli rc: the Kouen Companion is off. Turn it on in Settings → Remote.\n".utf8))
            return 1
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
        if !args.contains("--no-open") {
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
