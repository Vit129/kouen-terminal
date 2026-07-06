import Foundation
import KouenCore

extension KouenCLI {
    /// `kouen agent send <file> [--message <msg>]`
    static func handleAgent(_ args: [String], client: DaemonClient) throws {
        guard args.count >= 2, args[0] == "send" else {
            print("Usage: kouen agent send <file> [--message <msg>]")
            return
        }
        let file = args[1]
        let message = flagValue(args, flag: "--message") ?? "review this file"

        guard let data = FileManager.default.contents(atPath: file),
              let content = String(data: data, encoding: .utf8) else {
            fputs("agent: cannot read '\(file)'\n", kouenStderr)
            return
        }

        let snap = try snapshot(client)
        var agentSurface: String?
        for ws in snap.workspaces {
            for session in ws.sessions {
                for tab in session.tabs where tab.agent != nil {
                    if let sid = tab.rootPane.surfaceID {
                        agentSurface = sid.uuidString
                        break
                    }
                }
                if agentSurface != nil { break }
            }
            if agentSurface != nil { break }
        }

        guard let surfaceID = agentSurface else {
            fputs("agent: no agent pane found\n", kouenStderr)
            return
        }

        let capped = String(content.prefix(8000))
        let payload = "\(message)\n\nFile: \(file)\n```\n\(capped)\n```\n"
        _ = try checkedRequest(client, .send(surfaceID: surfaceID, text: payload))
        print("sent to agent: \(file)")
    }
}
