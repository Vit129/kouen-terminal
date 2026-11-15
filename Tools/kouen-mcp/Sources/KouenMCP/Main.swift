import Foundation
import KouenCore
#if canImport(Security)
import Security
#endif

@main
struct KouenMCPServer {
    static func main() async {
        let args = CommandLine.arguments
        let server = MCPServer()

        if args.contains("--help") || args.contains("-h") {
            printHelp()
            return
        }

        let isHTTP = args.contains("--http")
            || args.contains("--sse")
            || args.contains("serve")
            || args.contains("--port")
            || args.contains("-p")
            || args.contains("--host")
            || args.contains("-H")
            || args.contains("--token")
            || args.contains("-t")

        if isHTTP {
            var port: UInt16 = 8765
            // Loopback-only by default: kouen-mcp's tools (runCommand, writeFile,
            // kouenSpawnWorker, ...) execute arbitrary commands on this Mac, so binding every
            // interface by default would let anything on the local network reach them. Reaching
            // Kouen from another device (Tailscale, etc.) is an explicit `--host` opt-in below,
            // which then requires a token.
            var host: String = "127.0.0.1"
            var token: String? = nil

            var i = 1
            while i < args.count {
                let arg = args[i]
                if (arg == "--port" || arg == "-p") && i + 1 < args.count {
                    if let p = UInt16(args[i + 1]) { port = p }
                    i += 2
                    continue
                }
                if (arg == "--host" || arg == "-H") && i + 1 < args.count {
                    host = args[i + 1]
                    i += 2
                    continue
                }
                if (arg == "--token" || arg == "-t") && i + 1 < args.count {
                    token = args[i + 1]
                    i += 2
                    continue
                }
                i += 1
            }

            #if canImport(Network)
            let sseTransport = SSETransport(server: server, host: host, port: port, authToken: token)
            await sseTransport.start()
            #else
            // SSETransport is built on Network.framework (Apple-only). Off Darwin, say so instead
            // of silently falling back to stdio, which would look like a hung server to an SSE client.
            _ = (host, port, token)
            fputs("kouen-mcp: SSE transport isn't available on this platform — run without --sse for stdio.\n", kouenStderr)
            exit(1)
            #endif
        } else {
            // Default: stdio mode for Claude Desktop, Codex, and local subprocess agents
            await server.runStdio()
        }
    }

    static func generateToken() -> String {
        #if canImport(Security)
        var bytes = [UInt8](repeating: 0, count: 24)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            return bytes.map { String(format: "%02x", $0) }.joined()
        }
        // SecRandom failing at all is exceptionally rare (would indicate a broken keychain/
        // entropy subsystem) — UUIDs are still CSPRNG-backed on Darwin, just a fallback of
        // last resort rather than the primary path.
        #endif
        // Security isn't available off Darwin at all (e.g. the Linux daemon build) — UUIDs are
        // CSPRNG-backed there too (swift-corelibs-foundation draws from the platform's real
        // entropy source), so this is the primary path on Linux, not a downgrade.
        return (UUID().uuidString + UUID().uuidString).replacingOccurrences(of: "-", with: "").lowercased()
    }

    private static func printHelp() {
        print("""
        kouen-mcp: Model Context Protocol server for Kouen Terminal

        Usage:
          kouen-mcp                       Run in stdio mode (default, for Claude Desktop/Codex)
          kouen-mcp --http [options]      Run as Remote HTTP/SSE server

        Options:
          -p, --port <port>    Port to listen on (default: 8765)
          -H, --host <host>    Host to bind to (default: 127.0.0.1 — loopback only).
                                Binding any other host (e.g. a Tailscale IP) makes this
                                reachable from other devices and requires --token; one is
                                auto-generated and printed if you don't pass one.
          -t, --token <secret> Bearer auth token. Required for all HTTP requests;
                                auto-generated and printed to stderr when omitted.
          -h, --help           Show this help message

        Endpoints:
          GET  /sse                        Server-Sent Events stream (MCP HTTP+SSE spec)
          POST /message?sessionId=<uuid>   Send JSON-RPC message for active SSE session
          POST /mcp                        Direct JSON-RPC Streamable HTTP endpoint
          GET  /health                     Health check & discovery info
        """)
    }
}
