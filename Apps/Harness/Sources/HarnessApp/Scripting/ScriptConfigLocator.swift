import Foundation

/// Locates the initialization script file for HarnessApp based on environmental precedence.
struct ScriptConfigLocator {
    /// Discovers the script path using the following precedence:
    /// 1. `$HARNESS_CONFIG_FILE` (if set)
    /// 2. `$XDG_CONFIG_HOME/kouen/init.js` (if `XDG_CONFIG_HOME` is set and not empty)
    /// 3. `$HOME/.config/kouen/init.js` (if `HOME` is set)
    /// 4. `$HOME/.kouen.js` (if `HOME` is set)
    ///
    /// Each `kouen`-named path falls back to its pre-rename `harness`-named equivalent
    /// (`harness/init.js`, `.harness.js`) if the new one doesn't exist, so a script in
    /// place before the rename keeps loading unmoved.
    ///
    /// - Parameters:
    ///   - environment: The environment variables dictionary (defaults to the live process environment).
    ///   - fileExists: A closure checking if a file exists at the given path (defaults to FileManager check).
    /// - Returns: The absolute path to the configuration file, or `nil` if none exist.
    static func locate(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) -> String? {
        // 1. $HARNESS_CONFIG_FILE
        if let harnessConfig = environment["HARNESS_CONFIG_FILE"], !harnessConfig.isEmpty {
            if fileExists(harnessConfig) {
                return harnessConfig
            }
        }
        
        // 2. $XDG_CONFIG_HOME/kouen/init.js (falling back to the pre-rename harness/init.js)
        if let xdgConfigHome = environment["XDG_CONFIG_HOME"], !xdgConfigHome.isEmpty {
            let path = (xdgConfigHome as NSString).appendingPathComponent("kouen/init.js")
            if fileExists(path) {
                return path
            }
            let legacyPath = (xdgConfigHome as NSString).appendingPathComponent("harness/init.js")
            if fileExists(legacyPath) {
                return legacyPath
            }
        }

        // 3. $HOME/.config/kouen/init.js (falling back to the pre-rename .config/harness/init.js)
        let homeDir = environment["HOME"] ?? NSHomeDirectory()
        if !homeDir.isEmpty {
            let path1 = (homeDir as NSString).appendingPathComponent(".config/kouen/init.js")
            if fileExists(path1) {
                return path1
            }
            let legacyPath1 = (homeDir as NSString).appendingPathComponent(".config/harness/init.js")
            if fileExists(legacyPath1) {
                return legacyPath1
            }

            // 4. $HOME/.kouen.js (falling back to the pre-rename .harness.js)
            let path2 = (homeDir as NSString).appendingPathComponent(".kouen.js")
            if fileExists(path2) {
                return path2
            }
            let legacyPath2 = (homeDir as NSString).appendingPathComponent(".harness.js")
            if fileExists(legacyPath2) {
                return legacyPath2
            }
        }

        return nil
    }
}
