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

    // URL operands are attacker-controlled: shell quoting stops metacharacters, but a
    // leading "-" would still reach the tool as an option (e.g. `man -P<command>`).
    private static func sshRequest(for url: URL) -> DefaultTerminalLaunchRequest? {
        guard let host = url.host(percentEncoded: false), isSafeHost(host) else { return nil }
        let user = url.user(percentEncoded: false).flatMap { $0.isEmpty ? nil : $0 }
        if let user, !isSafeOperand(user) || user.contains("@") { return nil }
        let destinationHost = host.contains(":") && !host.hasPrefix("[") ? "[\(host)]" : host
        let destination = [user, destinationHost].compactMap { $0 }.joined(separator: "@")
        var parts = ["ssh"]
        if let port = url.port {
            guard (1...65_535).contains(port) else { return nil }
            parts += ["-p", String(port)]
        }
        parts += ["--", ShellQuoting.quote(destination)]
        return DefaultTerminalLaunchRequest(command: parts.joined(separator: " "), title: "ssh \(destinationHost)")
    }

    private static func telnetRequest(for url: URL) -> DefaultTerminalLaunchRequest? {
        guard let host = url.host(percentEncoded: false), isSafeHost(host) else { return nil }
        var parts = ["telnet", ShellQuoting.quote(host)]
        if let port = url.port {
            guard (1...65_535).contains(port) else { return nil }
            parts.append(String(port))
        }
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
        guard !topics.isEmpty, topics.allSatisfy(isSafeOperand) else { return nil }
        return DefaultTerminalLaunchRequest(
            command: (["man", "--"] + topics.map(ShellQuoting.quote)).joined(separator: " "),
            title: "man \(topics.last ?? "")"
        )
    }

    static func isSafeOperand(_ value: String) -> Bool {
        guard !value.isEmpty, !value.hasPrefix("-") else { return false }
        return !value.unicodeScalars.contains { scalar in
            CharacterSet.whitespacesAndNewlines.contains(scalar) || CharacterSet.controlCharacters.contains(scalar)
        }
    }

    private static let hostCharacters = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_:[]%")

    static func isSafeHost(_ host: String) -> Bool {
        isSafeOperand(host) && host.unicodeScalars.allSatisfy { hostCharacters.contains($0) }
    }

    private static func defaultFileIsDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
