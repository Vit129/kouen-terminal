import Foundation
import KouenCore

@main
struct KouenMCPServer {
    static func main() async {
        let server = MCPServer()
        await server.run()
    }
}
