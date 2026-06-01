import Foundation

public enum ShellQuoting {
    public static func quote(_ value: String) -> String {
        guard !value.isEmpty else { return "''" }
        let safe = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/_:.,@%+=-")
        if value.unicodeScalars.allSatisfy({ safe.contains($0) }) {
            return value
        }
        return "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}

public struct DefaultTerminalLaunchRequest: Equatable, Sendable {
    public var command: String?
    public var cwd: String?
    public var title: String?

    public init(command: String? = nil, cwd: String? = nil, title: String? = nil) {
        self.command = command
        self.cwd = cwd
        self.title = title
    }

    public static func make(
        for url: URL,
        fileIsDirectory: ((URL) -> Bool)? = nil
    ) -> DefaultTerminalLaunchRequest? {
        if url.isFileURL {
            let fileIsDirectory = fileIsDirectory ?? Self.defaultFileIsDirectory
            let standardized = url.standardizedFileURL
            if fileIsDirectory(standardized) {
                return DefaultTerminalLaunchRequest(cwd: standardized.path, title: standardized.lastPathComponent)
            }
            return DefaultTerminalLaunchRequest(
                command: ShellQuoting.quote(standardized.path),
                cwd: standardized.deletingLastPathComponent().path,
                title: standardized.lastPathComponent
            )
        }

        guard let scheme = url.scheme?.lowercased() else { return nil }
        switch scheme {
        case "ssh":
            return sshRequest(for: url)
        case "telnet":
            return telnetRequest(for: url)
        case "x-man-page":
            return manPageRequest(for: url)
        default:
            return nil
        }
    }

    private static func sshRequest(for url: URL) -> DefaultTerminalLaunchRequest? {
        guard let host = url.host(percentEncoded: false), !host.isEmpty else { return nil }
        let destinationHost = host.contains(":") && !host.hasPrefix("[") ? "[\(host)]" : host
        let destination = [url.user(percentEncoded: false), destinationHost]
            .compactMap { value -> String? in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: "@")
        var parts = ["ssh"]
        if let port = url.port { parts += ["-p", String(port)] }
        parts.append(ShellQuoting.quote(destination))
        return DefaultTerminalLaunchRequest(command: parts.joined(separator: " "), title: "ssh \(destinationHost)")
    }

    private static func telnetRequest(for url: URL) -> DefaultTerminalLaunchRequest? {
        guard let host = url.host(percentEncoded: false), !host.isEmpty else { return nil }
        var parts = ["telnet", ShellQuoting.quote(host)]
        if let port = url.port { parts.append(String(port)) }
        return DefaultTerminalLaunchRequest(command: parts.joined(separator: " "), title: "telnet \(host)")
    }

    private static func manPageRequest(for url: URL) -> DefaultTerminalLaunchRequest? {
        let host = url.host(percentEncoded: false)
        let pathParts = url.pathComponents.filter { $0 != "/" }
        let topics = ([host] + pathParts)
            .compactMap { value -> String? in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
        guard !topics.isEmpty else { return nil }
        return DefaultTerminalLaunchRequest(
            command: (["man"] + topics.map(ShellQuoting.quote)).joined(separator: " "),
            title: "man \(topics.last ?? "")"
        )
    }

    private static func defaultFileIsDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
