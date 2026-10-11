#if os(macOS)
import Darwin
import Foundation
import Security

/// Keep the signed executable, Info.plist and Apple profile together. The public
/// tool path remains stable through an atomic alias replacement.
enum MacOSHelperInstaller {
    private struct ExecutableIdentity: Codable, Equatable {
        var version: String, size: Int64, cdHash: Data
    }
    private struct FileIdentity: Codable, Equatable {
        var path: String, inode: UInt64, size: Int64
        var modifiedSeconds: Int64, modifiedNanoseconds: Int64
        var changedSeconds: Int64, changedNanoseconds: Int64
    }
    private struct InstallationStamp: Codable {
        var executable: ExecutableIdentity
        var sourceFiles: [FileIdentity], installedFiles: [FileIdentity]
    }
    private static func executableIdentity(_ bundle: URL, executable: String) throws -> ExecutableIdentity {
        let info = try PropertyListSerialization.propertyList(from: Data(contentsOf: bundle.appendingPathComponent("Contents/Info.plist")), format: nil) as? [String: Any]
        var code: SecStaticCode?, signing: CFDictionary?
        guard SecStaticCodeCreateWithPath(bundle as CFURL, SecCSFlags(rawValue: 0), &code) == errSecSuccess,
              let code,
              SecCodeCopySigningInformation(code, SecCSFlags(rawValue: kSecCSSigningInformation), &signing) == errSecSuccess,
              let cdHash = (signing as? [String: Any])?[kSecCodeInfoUnique as String] as? Data else { throw CocoaError(.fileReadCorruptFile) }
        var file = stat()
        guard lstat(bundle.appendingPathComponent("Contents/MacOS/" + executable).path, &file) == 0,
              file.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG) else { throw CocoaError(.fileReadCorruptFile) }
        return ExecutableIdentity(version: info?["CFBundleVersion"] as? String ?? "", size: Int64(file.st_size), cdHash: cdHash)
    }
    private static func fileIdentities(_ bundle: URL, requireOwnership: Bool) throws -> [FileIdentity] {
        guard let files = FileManager.default.enumerator(at: bundle, includingPropertiesForKeys: nil) else { throw CocoaError(.fileReadUnknown) }
        var identities: [FileIdentity] = []
        for case let file as URL in files {
            var info = stat()
            guard lstat(file.path, &info) == 0 else { throw CocoaError(.fileReadUnknown) }
            let type = info.st_mode & mode_t(S_IFMT)
            guard type == mode_t(S_IFREG) || type == mode_t(S_IFDIR) else { throw CocoaError(.fileReadCorruptFile) }
            if requireOwnership {
                guard info.st_uid == getuid(), info.st_mode & mode_t(0o022) == 0 else { throw CocoaError(.fileWriteNoPermission) }
            }
            identities.append(FileIdentity(path: String(file.path.dropFirst(bundle.path.count)), inode: UInt64(info.st_ino),
                size: Int64(info.st_size), modifiedSeconds: Int64(info.st_mtimespec.tv_sec), modifiedNanoseconds: Int64(info.st_mtimespec.tv_nsec),
                changedSeconds: Int64(info.st_ctimespec.tv_sec), changedNanoseconds: Int64(info.st_ctimespec.tv_nsec)))
        }
        return identities.sorted { $0.path < $1.path }
    }
    private static func stampURL(_ installed: URL) -> URL {
        installed.deletingLastPathComponent().appendingPathComponent("." + installed.lastPathComponent + ".installation.json")
    }
    private static func matchesInstalledStamp(source: URL, destination: URL) throws -> Bool {
        var alias = stat()
        guard lstat(destination.path, &alias) == 0, alias.st_mode & mode_t(S_IFMT) == mode_t(S_IFLNK) else { return false }
        let installed = try ownedBundle(for: destination)
        guard let bytes = try PrivateFile.read(stampURL(installed)),
              let stamp = try? JSONDecoder().decode(InstallationStamp.self, from: bytes) else { return false }
        let name = destination.lastPathComponent
        guard try executableIdentity(source, executable: name) == stamp.executable,
              try executableIdentity(installed, executable: name) == stamp.executable,
              try fileIdentities(installed, requireOwnership: true) == stamp.installedFiles else { return false }
        return try fileIdentities(source, requireOwnership: false) == stamp.sourceFiles
    }
    static func withInstallationLock<T>(directory: URL, _ work: () throws -> T) throws -> T {
        guard FileManager.default.fileExists(atPath: directory.path) else { return try work() }
        let root = directory.appendingPathComponent(".tool-bundles", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let fd = try lockedDescriptor(root)
        defer { close(fd) }
        return try work()
    }
    private static func lockedDescriptor(_ root: URL) throws -> Int32 {
        try requireOwnedDirectory(root)
        let fd = open(root.appendingPathComponent(".install.lock").path, O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, mode_t(0o600))
        guard fd >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        do {
            var info = stat()
            guard fstat(fd, &info) == 0, info.st_uid == getuid(),
                  info.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  info.st_mode & mode_t(0o077) == 0 else { throw CocoaError(.fileWriteNoPermission) }
            let deadline = Date().addingTimeInterval(3)
            while flock(fd, LOCK_EX | LOCK_NB) != 0 {
                guard errno == EWOULDBLOCK, Date() < deadline else { throw POSIXError(.EBUSY) }
                Thread.sleep(forTimeInterval: 0.02)
            }
            return fd
        } catch { close(fd); throw error }
    }
    static func bundledRefreshRequired(source: URL, destination: URL) throws -> Bool? {
        let executable = source.resolvingSymlinksInPath()
        let macOS = executable.deletingLastPathComponent()
        guard macOS.lastPathComponent == "MacOS", macOS.deletingLastPathComponent().lastPathComponent == "Contents" else { return nil }
        let bundle = macOS.deletingLastPathComponent().deletingLastPathComponent()
        guard ["HarnessDaemon.app", "HarnessSessionHost.app", "harness-cli.app"].contains(bundle.lastPathComponent) else { return nil }
        // A legacy bare executable needs migration even when its machine code is
        // identical. Profiles, metadata and resource seals are part of the update.
        var info = stat()
        guard lstat(destination.path, &info) == 0 else { return true }
        if info.st_mode & mode_t(S_IFMT) != mode_t(S_IFLNK) { return true }
        return try !matchesInstalledStamp(source: bundle, destination: destination)
    }
    private static func requireOwnedDirectory(_ url: URL) throws {
        var info = stat()
        guard lstat(url.path, &info) == 0, info.st_uid == getuid(),
              info.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              info.st_mode & mode_t(0o022) == 0 else { throw CocoaError(.fileWriteNoPermission) }
    }
    private static func requireHelperMetadata(_ bundle: URL, name: String) throws {
        try requireOwnedDirectory(bundle)
        let file = bundle.appendingPathComponent("Contents/Info.plist")
        let values = try file.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true, (values.fileSize ?? 0) <= 65_536,
              let info = try PropertyListSerialization.propertyList(from: Data(contentsOf: file), format: nil) as? [String: Any],
              info["CFBundleExecutable"] as? String == name,
              (info["CFBundleIdentifier"] as? String)?.hasPrefix("com.robert.harness.") == true else { throw CocoaError(.fileWriteNoPermission) }
    }
    private static func syncDirectory(_ url: URL) throws {
        let fd = open(url.path, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
        guard fd >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(fd) }
        guard fsync(fd) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
    }
    static func ownedBundle(for destination: URL) throws -> URL {
        let name = destination.lastPathComponent
        guard ["HarnessDaemon", "HarnessSessionHost", "harness-cli"].contains(name) else { throw CocoaError(.fileWriteNoPermission) }
        let root = destination.deletingLastPathComponent().appendingPathComponent(".tool-bundles")
        let bundle = root.appendingPathComponent(name + ".app")
        for path in [root, bundle, destination] {
            var info = stat()
            guard lstat(path.path, &info) == 0, info.st_uid == getuid() else { throw CocoaError(.fileWriteNoPermission) }
            if path != destination, info.st_mode & mode_t(S_IFMT) != mode_t(S_IFDIR) { throw CocoaError(.fileWriteNoPermission) }
        }
        try requireOwnedDirectory(root)
        try requireHelperMetadata(bundle, name: name)
        guard try FileManager.default.destinationOfSymbolicLink(atPath: destination.path) == ".tool-bundles/" + name + ".app/Contents/MacOS/" + name else { throw CocoaError(.fileWriteNoPermission) }
        return bundle
    }
    static func installIfBundled(source: URL, destination: URL) throws -> Bool {
        let executable = source.resolvingSymlinksInPath()
        let macOS = executable.deletingLastPathComponent()
        guard macOS.lastPathComponent == "MacOS",
              macOS.deletingLastPathComponent().lastPathComponent == "Contents" else { return false }
        let bundle = macOS.deletingLastPathComponent().deletingLastPathComponent()
        guard ["HarnessDaemon.app", "HarnessSessionHost.app", "harness-cli.app"].contains(bundle.lastPathComponent) else { return false }
        let infoURL = bundle.appendingPathComponent("Contents/Info.plist")
        guard let info = try PropertyListSerialization.propertyList(from: Data(contentsOf: infoURL), format: nil) as? [String: Any],
              info["CFBundleExecutable"] as? String == executable.lastPathComponent,
              destination.lastPathComponent == executable.lastPathComponent else { throw CocoaError(.fileReadCorruptFile) }
        let fm = FileManager.default
        let root = destination.deletingLastPathComponent().appendingPathComponent(".tool-bundles", isDirectory: true)
        try fm.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let lockFD = try lockedDescriptor(root)
        defer { close(lockFD) }
        if try matchesInstalledStamp(source: bundle, destination: destination) { return true }
        let installed = root.appendingPathComponent(bundle.lastPathComponent, isDirectory: true)
        let relativeTarget = ".tool-bundles/" + bundle.lastPathComponent + "/Contents/MacOS/" + executable.lastPathComponent
        var destinationInfo = stat()
        if lstat(destination.path, &destinationInfo) == 0 {
            guard destinationInfo.st_uid == getuid() else { throw CocoaError(.fileWriteNoPermission) }
            let kind = destinationInfo.st_mode & mode_t(S_IFMT)
            if kind == mode_t(S_IFLNK) {
                guard try fm.destinationOfSymbolicLink(atPath: destination.path) == relativeTarget else { throw CocoaError(.fileWriteNoPermission) }
            } else if kind != mode_t(S_IFREG) { throw CocoaError(.fileWriteNoPermission) }
        } else if errno != ENOENT { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        var installedInfo = stat()
        let replacing = lstat(installed.path, &installedInfo) == 0
        if replacing { try requireHelperMetadata(installed, name: executable.lastPathComponent) }
        else if errno != ENOENT { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        // Reinstalling from the installed bundle must still repair a missing alias.
        let alreadyInstalled = bundle.standardizedFileURL == installed.standardizedFileURL
        let staged = root.appendingPathComponent(".\(UUID().uuidString).app", isDirectory: true)
        let alias = destination.deletingLastPathComponent().appendingPathComponent(".\(UUID().uuidString).link")
        var removeStaged = true
        defer { if removeStaged { try? fm.removeItem(at: staged) }; try? fm.removeItem(at: alias) }
        if !alreadyInstalled { try fm.copyItem(at: bundle, to: staged) }
        let candidate = alreadyInstalled ? installed : staged
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(candidate as CFURL, SecCSFlags(rawValue: 0), &code) == errSecSuccess,
              let code,
              SecStaticCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSStrictValidate | kSecCSCheckAllArchitectures), nil) == errSecSuccess else { throw CocoaError(.fileReadCorruptFile) }
        guard fm.contentsEqual(atPath: executable.path, andPath: candidate.appendingPathComponent("Contents/MacOS/" + executable.lastPathComponent).path) else { throw CocoaError(.fileReadCorruptFile) }
        // Sync the complete profile-capable bundle before making it discoverable.
        var directories = [candidate]
        guard let files = fm.enumerator(at: candidate, includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isDirectoryKey]) else { throw CocoaError(.fileReadUnknown) }
        for case let file as URL in files {
            let values = try file.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .isDirectoryKey])
            guard values.isSymbolicLink != true else { throw CocoaError(.fileReadCorruptFile) }
            if values.isDirectory == true { directories.append(file) }
            if values.isRegularFile == true {
                let handle = try FileHandle(forWritingTo: file)
                do { try handle.synchronize(); try handle.close() }
                catch { try? handle.close(); throw error }
            }
        }
        for directory in directories.reversed() { try syncDirectory(directory) }
        try fm.createSymbolicLink(atPath: alias.path, withDestinationPath: relativeTarget)
        if !alreadyInstalled {
            if replacing {
                guard renamex_np(staged.path, installed.path, UInt32(RENAME_SWAP)) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
            } else if rename(staged.path, installed.path) != 0 { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
            // If syncing fails, retain both generations for explicit recovery.
            do { try syncDirectory(root) }
            catch {
                removeStaged = false
                throw NSError(domain: "HarnessHelperInstallation", code: 2, userInfo: [NSLocalizedDescriptionKey: "The verified helper was installed, but durable directory synchronization failed. Inspect " + installed.path + " and the retained bundle at " + staged.path + " before retrying.", NSUnderlyingErrorKey: error])
            }
        }
        guard rename(alias.path, destination.path) == 0 else {
            let failure = POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            let restored = alreadyInstalled ? 0 : (replacing ? renamex_np(staged.path, installed.path, UInt32(RENAME_SWAP)) : rename(installed.path, staged.path))
            if restored != 0 {
                removeStaged = false
                throw NSError(domain: "HarnessHelperInstallation", code: 1, userInfo: [NSLocalizedDescriptionKey: "The tool alias was not changed, but bundle rollback could not be confirmed. Inspect the installed helper and retained bundle at " + staged.path + " before retrying."])
            }
            throw failure
        }
        try syncDirectory(destination.deletingLastPathComponent())
        let stamp = try InstallationStamp(executable: executableIdentity(installed, executable: executable.lastPathComponent),
            sourceFiles: fileIdentities(bundle, requireOwnership: false), installedFiles: fileIdentities(installed, requireOwnership: true))
        let stampFile = stampURL(installed)
        try PrivateFile.replace(stampFile, data: JSONEncoder().encode(stamp), expected: PrivateFile.read(stampFile), backup: false)
        return true
    }
}
#endif
