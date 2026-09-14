import Foundation
import KouenCore

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

        if isHTTP {
            var port: UInt16 = 8765
            var host: String = "0.0.0.0"
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

            let sseTransport = SSETransport(server: server, host: host, port: port, authToken: token)
            await sseTransport.start()
        } else {
            // Default: stdio mode for Claude Desktop, Codex, and local subprocess agents
            await server.runStdio()
        }
    }

    private static func printHelp() {
        print("""
        kouen-mcp: Model Context Protocol server for Kouen Terminal

        Usage:
          kouen-mcp                       Run in stdio mode (default, for Claude Desktop/Codex)
          kouen-mcp --http [options]      Run as Remote HTTP/SSE server

        Options:
          -p, --port <port>    Port to listen on (default: 8765)
          -H, --host <host>    Host to bind to (default: 0.0.0.0)
          -t, --token <secret> Optional Bearer auth token for security
          -h, --help           Show this help message

        Endpoints:
          GET  /sse                        Server-Sent Events stream (MCP HTTP+SSE spec)
          POST /message?sessionId=<uuid>   Send JSON-RPC message for active SSE session
          POST /mcp                        Direct JSON-RPC Streamable HTTP endpoint
          GET  /health                     Health check & discovery info
        """)
    }
}
