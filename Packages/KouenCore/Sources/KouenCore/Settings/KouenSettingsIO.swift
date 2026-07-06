import Foundation
import KouenSettings

// MARK: - Persistence (needs KouenPaths — lives in KouenCore, not KouenSettings package)

extension KouenSettings {
    public static func load() -> KouenSettings {
        let imported = TerminalConfigImporter.load()
        let url = KouenPaths.settingsURL
        if FileManager.default.fileExists(atPath: url.path), let data = try? Data(contentsOf: url) {
            guard var settings = try? JSONDecoder().decode(KouenSettings.self, from: data) else {
                KouenPaths.backupCorruptFile(at: url, label: "Kouen")
                return KouenSettings.makeDefaults(imported: imported)
            }
            let hasStoredColorChoice = settingsDataContainsColorChoice(data)
            var didMutate = false
            if let imported, settings.importedConfigSignature != imported.signature {
                if settings.hasUserVisualCustomizations {
                    settings.importedConfigSignature = imported.signature
                } else {
                    settings.applyImportedDefaults(imported)
                }
                didMutate = true
            }
            let clampedOpacity = KouenSettings.clampedOpacity(settings.backgroundOpacity)
            if clampedOpacity != settings.backgroundOpacity { settings.backgroundOpacity = clampedOpacity; didMutate = true }
            let clampedBlur = KouenSettings.clampedBlur(settings.backgroundBlur)
            if clampedBlur != settings.backgroundBlur { settings.backgroundBlur = clampedBlur; didMutate = true }
            let clampedFontSize = KouenSettings.clampedFontSize(settings.fontSize)
            if clampedFontSize != settings.fontSize { settings.fontSize = clampedFontSize; didMutate = true }
            let clampedPaddingX = KouenSettings.clampedPadding(settings.windowPaddingX)
            if clampedPaddingX != settings.windowPaddingX { settings.windowPaddingX = clampedPaddingX; didMutate = true }
            let clampedPaddingY = KouenSettings.clampedPadding(settings.windowPaddingY)
            if clampedPaddingY != settings.windowPaddingY { settings.windowPaddingY = clampedPaddingY; didMutate = true }
            let migrationKey = "KouenColorFidelityMigrationV1"
            if !UserDefaults.standard.bool(forKey: migrationKey) {
                UserDefaults.standard.set(true, forKey: migrationKey)
                if !hasStoredColorChoice, settings.colorRendering != .accurate {
                    settings.colorRendering = .accurate
                    didMutate = true
                }
            }
            if didMutate {
                do { try settings.save() }
                catch { fputs("Kouen: failed to persist migrated settings.json — \(error)\n", kouenStderr) }
            }
            return settings
        }
        let seeded = KouenSettings.makeDefaults(imported: imported)
        do { try seeded.save() }
        catch { fputs("Kouen: failed to seed settings.json — \(error)\n", kouenStderr) }
        return seeded
    }

    public func save() throws {
        try KouenPaths.ensureDirectories()
        let data = try JSONEncoder().encode(self)
        try data.write(to: KouenPaths.settingsURL, options: .atomic)
    }

    // Uses raw key strings to avoid exposing CodingKeys from KouenSettings package.
    private static func settingsDataContainsColorChoice(_ data: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        return object["vividColors"] != nil || object["colorRendering"] != nil
    }
}
