import Darwin
import Foundation
import KouenCore

enum ProjectAcquisitionService {
    enum Mode: Sendable {
        case clone, create
    }

    struct Request: Sendable {
        let mode: Mode
        let input: String
        let parent: URL

        func destination() throws -> URL {
            let value = input.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = mode == .clone ? try Self.repositoryName(from: value) : value
            guard !name.isEmpty, !name.hasPrefix("-"), name != ".", name != "..",
                  name.lowercased() != ".git", !name.contains("/"), !name.contains(":"),
                  name.rangeOfCharacter(from: .controlCharacters) == nil else {
                throw Failure("Enter a valid folder name.")
            }
            return parent.appendingPathComponent(name, isDirectory: true).standardizedFileURL
        }

        private static func repositoryName(from remote: String) throws -> String {
            let path: String
            guard !remote.hasPrefix("-"), remote.rangeOfCharacter(from: .controlCharacters) == nil else {
                throw Failure("Enter a valid Git URL.")
            }
            if remote.range(of: #"^git@[A-Za-z0-9][A-Za-z0-9.-]*:.+$"#, options: .regularExpression) != nil,
               let colon = remote.firstIndex(of: ":") {
                path = String(remote[remote.index(after: colon)...])
            } else if let url = URLComponents(string: remote), let scheme = url.scheme?.lowercased(),
                      (["https", "ssh"].contains(scheme) && url.host?.isEmpty == false)
                        || (scheme == "file" && url.path.hasPrefix("/") && [nil, "", "localhost"].contains(url.host)) {
                path = url.path
            } else {
                throw Failure("Use an HTTPS, SSH, git@host:path, or local file URL.")
            }
            let filename = path.split(separator: "/").last.map(String.init) ?? ""
            return filename.hasSuffix(".git") ? String(filename.dropLast(4)) : filename
        }
    }

    struct Failure: LocalizedError {
        let message: String

        init(_ message: String) { self.message = message }

        var errorDescription: String? { message }
    }

    @concurrent
    static func acquire(_ request: Request) async throws -> URL {
        let destination = try request.destination()
        let fileManager = FileManager.default
        try Task.checkCancellation()
        guard !fileManager.fileExists(atPath: destination.path),
              (try? fileManager.destinationOfSymbolicLink(atPath: destination.path)) == nil else {
            throw Failure("The destination already exists at \(destination.path).")
        }

        // Watched project folders skip hidden directories. Keep incomplete Git work
        // there and publish the checkout only once Git exits successfully.
        let staging = request.parent.appendingPathComponent(".kouen-project-\(UUID().uuidString)", isDirectory: true)
        do {
            try fileManager.createDirectory(at: staging, withIntermediateDirectories: false)
        } catch {
            throw Failure("Could not prepare \(destination.path). \(error.localizedDescription)")
        }

        let arguments: [String]
        switch request.mode {
        case .clone:
            arguments = [
                "-c", "protocol.allow=never",
                "-c", "protocol.https.allow=always",
                "-c", "protocol.ssh.allow=always",
                "-c", "protocol.file.allow=always",
                "clone", "--", request.input.trimmingCharacters(in: .whitespacesAndNewlines), staging.path,
            ]
        case .create:
            arguments = ["init", "--", staging.path]
        }
        let result = await ProcessRunner.runAsync(
            executable: "/usr/bin/env",
            arguments: ["GIT_TERMINAL_PROMPT=0", "git"] + arguments,
            timeout: 120
        )
        guard result.isSuccess, !Task.isCancelled else {
            let reason: String
            if Task.isCancelled {
                reason = "Git operation canceled."
            } else if result.isTimedOut {
                reason = "Git operation timed out."
            } else {
                reason = "Git exited with status \(result.exitCode)."
            }

            _ = rmdir(staging.path) // Remove only an empty staging directory.
            let remaining = fileManager.fileExists(atPath: staging.path)
                ? "Git left a checkout at \(staging.path)."
                : "Git left no checkout."
            throw Failure("\(reason)\nDestination: \(destination.path)\n\(remaining)\n\(result.stderr)")
        }
        guard renamex_np(staging.path, destination.path, UInt32(RENAME_EXCL)) == 0 else {
            let reason = String(cString: strerror(errno))
            throw Failure("Could not move the completed checkout to \(destination.path). \(reason)\nCheckout: \(staging.path)")
        }
        return destination
    }
}
