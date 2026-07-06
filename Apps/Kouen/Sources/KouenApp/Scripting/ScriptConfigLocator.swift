import Foundation

/// Locates the initialization script file for KouenApp based on environmental precedence.
struct ScriptConfigLocator {
    /// Discovers the script path using the following precedence:
    /// 1. `$KOUEN_CONFIG_FILE` (if set)
    /// 2. `$XDG_CONFIG_HOME/kouen/init.js` (if `XDG_CONFIG_HOME` is set and not empty)
    /// 3. `$HOME/.config/kouen/init.js` (if `HOME` is set)
    /// 4. `$HOME/.kouen.js` (if `HOME` is set)
    ///
    /// - Parameters:
    ///   - environment: The environment variables dictionary (defaults to the live process environment).
    ///   - fileExists: A closure checking if a file exists at the given path (defaults to FileManager check).
    /// - Returns: The absolute path to the configuration file, or `nil` if none exist.
    static func locate(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) -> String? {
        // 1. $KOUEN_CONFIG_FILE
        if let kouenConfig = environment["KOUEN_CONFIG_FILE"], !kouenConfig.isEmpty {
            if fileExists(kouenConfig) {
                return kouenConfig
            }
        }

        // 2. $XDG_CONFIG_HOME/kouen/init.js
        if let xdgConfigHome = environment["XDG_CONFIG_HOME"], !xdgConfigHome.isEmpty {
            let path = (xdgConfigHome as NSString).appendingPathComponent("kouen/init.js")
            if fileExists(path) {
                return path
            }
        }

        // 3. $HOME/.config/kouen/init.js
        let homeDir = environment["HOME"] ?? NSHomeDirectory()
        if !homeDir.isEmpty {
            let path1 = (homeDir as NSString).appendingPathComponent(".config/kouen/init.js")
            if fileExists(path1) {
                return path1
            }

            // 4. $HOME/.kouen.js
            let path2 = (homeDir as NSString).appendingPathComponent(".kouen.js")
            if fileExists(path2) {
                return path2
            }
        }

        return nil
    }
}
