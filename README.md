# Kouen

Kouen is a native macOS terminal app written in Swift. It includes a terminal engine, a session daemon, a CLI, an embedded browser, and agent session tools.

## Run

Requires macOS 15+, Xcode 16+, and Swift 6.

```sh
make run       # run the app
make preview   # run an isolated development build
```

## Test

```sh
swift test
Tests/robot/run.sh
```

## Folders

- `Apps/Kouen/Sources/KouenApp/` — macOS application and UI
- `Packages/` — shared core, settings, terminal, daemon, and supporting libraries
- `Tools/` — CLI and MCP server
- `Tests/` — Swift test targets and Robot Framework checks
- `docs/` — user guides and reference documentation

See [ARCHITECTURE.md](ARCHITECTURE.md) for package dependencies and [docs/USAGE.md](docs/USAGE.md) for install and CLI instructions.
