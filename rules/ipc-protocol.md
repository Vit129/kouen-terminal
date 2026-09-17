# IPC Protocol & Generated Files

## IPC framing

Control = 4-byte big-endian length-prefixed JSON. PTY hot path = binary magic `0xF5` (output) / `0xF6` (input). New binary frame type needs version gate — old readers drop connection on unknown magic.

- **`IPCCodec.maxPayloadLength`**: 16 MiB.
- **Daemon socket**: owner-only `0600`, rejects peers with different uid.
- **ACP shelved**: Agent sidebar + Chat toggle commented out. Code intact for re-enablement.

## Generated files (regenerate, never hand-edit)

- **`CharacterWidthTable.swift`**: generated + committed. Regenerate via `Scripts/generate-width-table.swift` if `CharacterWidth.swift` changes.
- **`themes.json`**: excluded from SwiftPM build. Regenerate `BundledThemesData.swift` with theme export test (`EXPORT_THEMES=1 swift test --filter ThemeCatalogEmbedTests`).
