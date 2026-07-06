// swift-tools-version: 6.0
import PackageDescription

// The whole package builds in the Swift 6 language mode (tools-version 6.0), so *complete* strict
// concurrency checking is already on everywhere. For the two pure, foundational, dependency-free
// libraries — KouenCore (models/IPC/commands) and KouenTerminalEngine (VT engine) — we also
// treat warnings as errors so a data-race / Sendable / deprecation warning in the layer everything
// else builds on can never be ignored and rot. Kept off the AppKit/Metal targets for now (they
// surface framework-deprecation churn we don't want to hard-fail CI on).
let strictFoundationSettings: [SwiftSetting] = [.unsafeFlags(["-warnings-as-errors"])]

// The Package manifest is evaluated on the *host*, so on Linux the macOS-only layers (the Metal/
// AppKit renderer + terminal kit, the SwiftUI onboarding wizard, the GUI app, and Sparkle
// auto-update) are dropped from products/dependencies/targets. The daemon, CLI, terminal engine,
// copy-mode model, theme catalog and core library are all first-party Foundation/POSIX and build
// headless on Linux — which is what lets `KouenDaemon` run on a remote/headless box.
#if os(macOS)
let platformDependencies: [Package.Dependency] = [
    // Sparkle: macOS auto-update (the only external dependency, and only for the GUI app —
    // the engine/daemon/CLI stay first-party). This fork has no appcast of its own yet —
    // SUFeedURL is unset in Info.plist and startingUpdater is false (SparkleUpdater.swift),
    // so the dependency is present but inert until this fork stands up its own feed.
    // Pinned to the audited 2.9.x line (`Package.resolved` locks 2.9.2): a fresh resolve can't
    // float onto an unaudited future major/minor, while patch-level security fixes still land.
    .package(url: "https://github.com/sparkle-project/Sparkle", .upToNextMinor(from: "2.9.2")),
]
let platformProducts: [Product] = [
    // Native terminal renderer: pure-Swift color resolution + a Metal glyph/draw layer.
    .library(name: "KouenTerminalRenderer", targets: ["KouenTerminalRenderer"]),
    .library(name: "KouenTerminalKit", targets: ["KouenTerminalKit"]),
    // Immersive first-run onboarding wizard (SwiftUI). Self-contained, no deps; embedded
    // into Kouen.app and shown on first launch.
    .library(name: "KouenOnboarding", targets: ["KouenOnboarding"]),
    .executable(name: "Kouen", targets: ["KouenApp"]),
    // P25 throwaway spike: proves a phone browser can reach the Mac over WebSocket
    // (Network.framework, no new dependency) before any real daemon/IPC wiring.
    // Delete this target once the real bridge lands in KouenDaemonCore.
    .executable(name: "MobileBridgeSpike", targets: ["MobileBridgeSpike"]),
]
// `kouen-cli`'s `attach-window` compositor renders through the Metal/AppKit terminal kit, so the
// kit dependency (and the one source file that uses it) is macOS-only; the rest of the CLI — incl.
// single-pane `attach` — is headless.
let cliDependencies: [Target.Dependency] = [
    "KouenCore", "KouenTerminalEngine", "KouenCopyMode", "KouenTerminalKit", "KouenTheme",
    "KouenLSP", "CKouenSys",
]
let cliExclude: [String] = []
let platformTargets: [Target] = [
    // Native renderer — first-party frame building, CoreText glyph atlas, and Metal drawing.
    .target(
        name: "KouenTerminalRenderer",
        dependencies: ["KouenCore", "KouenTerminalEngine", "KouenTheme"],
        path: "Packages/KouenTerminalRenderer/Sources/KouenTerminalRenderer"
    ),
    .target(
        name: "KouenTerminalKit",
        dependencies: [
            "KouenCore",
            "KouenTerminalEngine",
            "KouenCopyMode",
            "KouenTerminalRenderer",
            "KouenTheme",
        ],
        path: "Packages/KouenTerminalKit/Sources/KouenTerminalKit"
    ),
    // Immersive onboarding wizard — pure SwiftUI/AppKit, no external or first-party
    // dependencies (deliberately isolated, mirrors install paths via its own helpers).
    .target(
        name: "KouenOnboarding",
        dependencies: ["KouenCore", "KouenIPC", "KouenSettings", "KouenCommands"],
        path: "Packages/KouenOnboarding/Sources/KouenOnboarding"
    ),
    .executableTarget(
        name: "KouenApp",
        dependencies: [
            "KouenCore",
            // Engine types (e.g. TerminalProgressReport) surface through KouenTerminalKit's
            // public delegate API, so the app consumes the engine module directly.
            "KouenTerminalEngine",
            "KouenTerminalKit",
            "KouenTheme",
            "KouenLSP",
            "KouenSyntaxResources",
            "KouenOnboarding",
            .product(name: "Sparkle", package: "Sparkle"),
        ],
        path: "Apps/Kouen/Sources/KouenApp",
        exclude: ["Resources"]
    ),
    .executableTarget(
        name: "MobileBridgeSpike",
        dependencies: ["KouenCore"],
        path: "Spikes/MobileBridgeSpike/Sources/MobileBridgeSpike"
    ),
]
let platformTestTargets: [Target] = [
    .testTarget(
        name: "KouenTerminalRendererTests",
        dependencies: ["KouenCore", "KouenTerminalRenderer", "KouenTerminalEngine", "KouenTheme"],
        path: "Tests/KouenTerminalRendererTests"
    ),
    .testTarget(
        name: "KouenTerminalKitTests",
        dependencies: [
            "KouenCore",
            "KouenTerminalEngine",
            "KouenCopyMode",
            "KouenTerminalKit",
            "KouenTheme",
        ],
        path: "Tests/KouenTerminalKitTests"
    ),
    .testTarget(
        name: "KouenOnboardingTests",
        dependencies: ["KouenOnboarding"],
        path: "Tests/KouenOnboardingTests"
    ),
    // Drift canary: the onboarding-preview port of GridCompositor must keep composing the
    // shared subset (layout, borders, junctions, status line) identically to the live one.
    // Imports both packages so a single fixture is composed through each and compared.
    .testTarget(
        name: "GridCompositorParityTests",
        dependencies: [
            "KouenTerminalKit",
            "KouenOnboarding",
            "KouenCore",
            "KouenTerminalEngine",
        ],
        path: "Tests/GridCompositorParityTests"
    ),
    .testTarget(
        name: "KouenAppTests",
        dependencies: ["KouenApp"],
        path: "Tests/KouenAppTests"
    ),
    // Performance baselines for the hot paths (VT parse, IPC codec, scrollback,
    // compositor, renderer stats). Gated behind KOUEN_BENCHMARKS=1 so a normal
    // `swift test` stays fast; run with `make bench`.
    .testTarget(
        name: "KouenBenchmarks",
        dependencies: [
            "KouenCore",
            "KouenTerminalEngine",
            "KouenTerminalKit",
            "KouenTerminalRenderer",
            "KouenTheme",
        ],
        path: "Tests/KouenBenchmarks"
    ),
]
#else
let platformDependencies: [Package.Dependency] = []
let platformProducts: [Product] = []
let cliDependencies: [Target.Dependency] = [
    "KouenCore", "KouenTerminalEngine", "KouenCopyMode", "KouenTheme", "KouenLSP", "CKouenSys",
]
let cliExclude: [String] = ["WindowAttachClient.swift"]
let platformTargets: [Target] = []
let platformTestTargets: [Target] = []
#endif

let package = Package(
    name: "Kouen",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "KouenIPC", targets: ["KouenIPC"]),
        .library(name: "KouenSettings", targets: ["KouenSettings"]),
        .library(name: "KouenCommands", targets: ["KouenCommands"]),
        .library(name: "KouenCore", targets: ["KouenCore"]),
        // Self-contained native terminal engine (VT parser + screen/grid model). Pure
        // Swift, no Metal/AppKit.
        .library(name: "KouenTerminalEngine", targets: ["KouenTerminalEngine"]),
        // Shared, UI-agnostic copy-mode model (state + pure reducer over the engine grid),
        // driving copy mode in both the GUI overlay and the ssh compositor. Pure Swift.
        .library(name: "KouenCopyMode", targets: ["KouenCopyMode"]),
        // Native theme catalog + the shareable `.kouentheme` document format. Pure Swift.
        .library(name: "KouenTheme", targets: ["KouenTheme"]),
        .library(name: "KouenLSP", targets: ["KouenLSP"]),
        .library(name: "KouenSyntaxResources", targets: ["KouenSyntaxResources"]),
        // C portability shim exposed as a product so the generated Xcode project can import the
        // same first-party module that SwiftPM targets use internally.
        .library(name: "CKouenSys", targets: ["CKouenSys"]),
        .executable(name: "KouenDaemon", targets: ["KouenDaemon"]),
        .executable(name: "kouen-cli", targets: ["KouenCLI"]),
        .executable(name: "kouen-mcp", targets: ["KouenMCP"]),
    ] + platformProducts,
    dependencies: platformDependencies,
    targets: [
        // IPC wire types, session/tab/workspace models, notification bus.
        // Leaf package: depends only on Foundation/Darwin — nothing else from this repo.
        .target(
            name: "KouenIPC",
            path: "Packages/KouenIPC/Sources/KouenIPC",
            swiftSettings: strictFoundationSettings
        ),
        // App settings, keybindings, shell integration. Depends on KouenIPC for AgentKind.
        .target(
            name: "KouenSettings",
            dependencies: ["KouenIPC"],
            path: "Packages/KouenSettings/Sources/KouenSettings",
            swiftSettings: strictFoundationSettings
        ),
        // Command vocabulary, key tables, format, session editor, options, board model.
        // Depends on KouenIPC for Tab/SessionSnapshot/SplitDirection/IPCRequest.
        .target(
            name: "KouenCommands",
            dependencies: ["KouenIPC"],
            path: "Packages/KouenCommands/Sources/KouenCommands",
            swiftSettings: strictFoundationSettings
        ),
        .target(
            name: "KouenCore",
            dependencies: ["KouenIPC", "KouenSettings", "KouenCommands"],
            path: "Packages/KouenCore/Sources/KouenCore",
            swiftSettings: strictFoundationSettings
        ),
        // Native terminal engine — pure Swift, no external dependencies. Foundation only
        // so it links for headless CLI use and unit tests without a GPU.
        .target(
            name: "KouenTerminalEngine",
            path: "Packages/KouenTerminalEngine/Sources/KouenTerminalEngine",
            swiftSettings: strictFoundationSettings
        ),
        // Shared copy-mode model — pure Swift over Core (action vocabulary) + the engine
        // (grid types). Both the GUI surface and the compositor drive this one reducer.
        .target(
            name: "KouenCopyMode",
            dependencies: ["KouenCore", "KouenTerminalEngine"],
            path: "Packages/KouenCopyMode/Sources/KouenCopyMode"
        ),
        // Native theme system — pure Swift, no external dependencies.
        .target(
            name: "KouenTheme",
            path: "Packages/KouenTheme/Sources/KouenTheme",
            // The community catalog is embedded as base64 in BundledThemesData.swift (compiled
            // into the binary), NOT shipped as a SwiftPM resource bundle: a missing/misplaced
            // `Bundle.module` bundle crashed the app at launch for users on a non-builtin theme.
            // themes.json stays as the editable source of truth but is excluded from the build —
            // regenerate the embed with `EXPORT_THEMES=1 swift test --filter ThemeCatalogEmbedTests`.
            exclude: ["Resources/themes.json"]
        ),
        .target(
            name: "KouenLSP",
            dependencies: ["KouenCore", "KouenIPC", "KouenSettings", "KouenCommands"],
            path: "Packages/KouenLSP/Sources/KouenLSP"
        ),
        .target(
            name: "KouenSyntaxResources",
            path: "Packages/KouenSyntaxResources",
            resources: [.copy("Resources/TreeSitterGrammars")]
        ),
        // Tiny C shim wrapping the variadic `ioctl` (unavailable to Swift on Linux) into
        // non-variadic terminal helpers used by the PTY layer and the CLI attach client.
        .target(
            name: "CKouenSys",
            path: "Packages/CKouenSys"
        ),
        // Daemon logic as a library so it is unit-testable; the executable below is a
        // thin `main.swift` wrapper over it.
        .target(
            name: "KouenDaemonCore",
            // Depends on the engine so `capture-pane` reconstructs the on-screen grid
            // (faithful overwrites/clears + soft-wrap join), exactly like tmux.
            // KouenSettings for ProjectConfig (P32 F3: archiveScript on worktree close).
            dependencies: ["KouenCore", "KouenTerminalEngine", "CKouenSys", "KouenSettings"],
            path: "Packages/KouenDaemon/Sources/KouenDaemon"
        ),
        .executableTarget(
            name: "KouenDaemon",
            dependencies: ["KouenDaemonCore"],
            path: "Packages/KouenDaemon/Sources/KouenDaemonMain"
        ),
        .executableTarget(
            name: "KouenCLI",
            dependencies: cliDependencies,
            path: "Tools/kouen/Sources/KouenCLI",
            exclude: cliExclude
        ),
        .executableTarget(
            name: "KouenMCP",
            dependencies: ["KouenCore", "KouenIPC", "KouenSettings", "KouenCommands"],
            path: "Tools/kouen-mcp/Sources/KouenMCP"
        ),
        .testTarget(
            name: "KouenCoreTests",
            dependencies: ["KouenCore", "KouenIPC", "KouenSettings", "KouenCommands"],
            path: "Tests/KouenCoreTests"
        ),
        .testTarget(
            name: "KouenTerminalEngineTests",
            dependencies: ["KouenTerminalEngine"],
            path: "Tests/KouenTerminalEngineTests",
            resources: [.copy("ReflowGolden")]
        ),
        .testTarget(
            name: "KouenCopyModeTests",
            dependencies: ["KouenCopyMode", "KouenCore", "KouenTerminalEngine"],
            path: "Tests/KouenCopyModeTests"
        ),
        .testTarget(
            name: "KouenThemeTests",
            dependencies: ["KouenTheme"],
            path: "Tests/KouenThemeTests"
        ),
        // Unit coverage for the CLI's pure argument-parsing helpers. The CLI is an executable
        // target (`@main struct KouenCLI`); `@testable import` reaches its internal statics
        // without splitting out a library, so daemon-free helpers like `flagValue` are covered.
        .testTarget(
            name: "KouenCLITests",
            dependencies: ["KouenCLI", "KouenLSP"],
            path: "Tests/KouenCLITests"
        ),
        .testTarget(
            name: "KouenMCPTests",
            dependencies: ["KouenMCP"],
            path: "Tests/KouenMCPTests"
        ),
        .testTarget(
            name: "KouenDaemonTests",
            dependencies: ["KouenDaemonCore", "KouenCore", "KouenTerminalEngine"],
            path: "Tests/KouenDaemonTests"
        ),
    ] + platformTargets + platformTestTargets
)
