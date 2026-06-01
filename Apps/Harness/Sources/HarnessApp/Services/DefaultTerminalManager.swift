import AppKit
import HarnessCore
import UniformTypeIdentifiers

struct DefaultTerminalStatus: Equatable {
    var missingItems: [String]
    var isDefault: Bool { missingItems.isEmpty }

    var summary: String {
        if isDefault {
            return "Harness is default for SSH/Telnet/man-page links and terminal command files."
        }
        return "Not default for: \(missingItems.joined(separator: ", "))."
    }
}

enum DefaultTerminalRegistrationError: LocalizedError {
    case failed([String])

    var errorDescription: String? {
        switch self {
        case let .failed(messages):
            return messages.joined(separator: "\n")
        }
    }
}

@MainActor
enum DefaultTerminalManager {
    private static let urlSchemes = ["ssh", "telnet", "x-man-page"]
    private static let commandFileTypeIdentifier = "com.apple.terminal.shell-script"
    private static let commandFileType = UTType(filenameExtension: "command")
        ?? UTType(importedAs: commandFileTypeIdentifier)

    static func status() -> DefaultTerminalStatus {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return DefaultTerminalStatus(missingItems: ["app registration"])
        }

        var missing: [String] = []
        for scheme in urlSchemes where defaultHandler(forScheme: scheme) != bundleID {
            missing.append("\(scheme)://")
        }
        if defaultHandlerForCommandFiles() != bundleID {
            missing.append(".command/.tool files")
        }
        return DefaultTerminalStatus(missingItems: missing)
    }

    static func setAsDefault() async throws {
        let appURL = Bundle.main.bundleURL
        var failures: [String] = []

        for scheme in urlSchemes {
            do {
                try await setDefaultApplication(appURL, forScheme: scheme)
            } catch {
                failures.append("\(scheme)://: \(error.localizedDescription)")
            }
        }

        do {
            try await setDefaultApplication(appURL, forContentType: commandFileType)
        } catch {
            failures.append(".command/.tool files: \(error.localizedDescription)")
        }

        if !failures.isEmpty {
            throw DefaultTerminalRegistrationError.failed(failures)
        }
    }

    private static func setDefaultApplication(_ appURL: URL, forScheme scheme: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            NSWorkspace.shared.setDefaultApplication(at: appURL, toOpenURLsWithScheme: scheme) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private static func setDefaultApplication(_ appURL: URL, forContentType contentType: UTType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            NSWorkspace.shared.setDefaultApplication(at: appURL, toOpen: contentType) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private static func defaultHandler(forScheme scheme: String) -> String? {
        guard let url = URL(string: "\(scheme)://harness.invalid") else { return nil }
        return bundleIdentifierForDefaultApplication(toOpen: url)
    }

    private static func defaultHandlerForCommandFiles() -> String? {
        bundleIdentifierForDefaultApplication(toOpen: URL(fileURLWithPath: "/tmp/harness-default-terminal.command"))
    }

    private static func bundleIdentifierForDefaultApplication(toOpen url: URL) -> String? {
        guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: url) else { return nil }
        return Bundle(url: appURL)?.bundleIdentifier
    }
}

@MainActor
enum DefaultTerminalOpener {
    static func open(_ urls: [URL]) {
        for request in urls.compactMap({ DefaultTerminalLaunchRequest.make(for: $0) }) {
            SessionCoordinator.shared.openDefaultTerminalLaunch(request)
        }
    }
}
