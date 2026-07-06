import Foundation

/// Read-only detection of common project task runners. No shell execution.
public struct ProjectTask: Sendable {
    public let buildCmd: String
    public let testCmd: String
    public let defaultCmd: String
}

public enum ProjectTaskDetector {
    public static func detect(at cwd: String) -> ProjectTask? {
        let fm = FileManager.default
        // SwiftPM
        if fm.fileExists(atPath: "\(cwd)/Package.swift") {
            return ProjectTask(buildCmd: "swift build", testCmd: "swift test", defaultCmd: "swift build")
        }
        // npm / yarn
        if fm.fileExists(atPath: "\(cwd)/package.json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: "\(cwd)/package.json")),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let scripts = json["scripts"] as? [String: Any] {
            let build = scripts["build"] != nil ? "npm run build" : "npm install"
            let test = scripts["test"] != nil ? "npm test" : "npm install"
            return ProjectTask(buildCmd: build, testCmd: test, defaultCmd: build)
        }
        // Makefile
        if fm.fileExists(atPath: "\(cwd)/Makefile") {
            return ProjectTask(buildCmd: "make build", testCmd: "make test", defaultCmd: "make")
        }
        // Justfile
        if fm.fileExists(atPath: "\(cwd)/justfile") || fm.fileExists(atPath: "\(cwd)/Justfile") {
            return ProjectTask(buildCmd: "just build", testCmd: "just test", defaultCmd: "just")
        }
        // Taskfile
        if fm.fileExists(atPath: "\(cwd)/Taskfile.yml") || fm.fileExists(atPath: "\(cwd)/Taskfile.yaml") {
            return ProjectTask(buildCmd: "task build", testCmd: "task test", defaultCmd: "task")
        }
        return nil
    }
}
