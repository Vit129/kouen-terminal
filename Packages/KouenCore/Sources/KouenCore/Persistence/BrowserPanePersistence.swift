import Foundation

public enum BrowserPanePersistence {
    private static func logPath(paneID: UUID) -> String {
        (NSTemporaryDirectory() as NSString).appendingPathComponent("kouen-browser-\(paneID.uuidString).log")
    }

    public static func createLog(paneID: UUID) {
        try? "".write(toFile: logPath(paneID: paneID), atomically: true, encoding: .utf8)
    }

    public static func removeLog(paneID: UUID) {
        try? FileManager.default.removeItem(atPath: logPath(paneID: paneID))
    }

    public static func appendLog(_ data: Data, paneID: UUID) {
        let url = URL(fileURLWithPath: logPath(paneID: paneID))
        if let fh = try? FileHandle(forWritingTo: url) {
            defer { try? fh.close() }
            let currentOffset = (try? fh.seekToEnd()) ?? 0
            if currentOffset > 500_000 {
                try? fh.truncate(atOffset: 0)
            }
            _ = try? fh.write(contentsOf: data)
        } else {
            _ = try? data.write(to: url, options: .atomic)
        }
    }

    public static func savedURL(paneID: UUID) -> String? {
        UserDefaults.standard.string(forKey: "browserPane.\(paneID.uuidString).url")
    }

    public static func saveURL(_ url: String, paneID: UUID) {
        UserDefaults.standard.set(url, forKey: "browserPane.\(paneID.uuidString).url")
    }

    public static func removeURL(paneID: UUID) {
        UserDefaults.standard.removeObject(forKey: "browserPane.\(paneID.uuidString).url")
    }
}
