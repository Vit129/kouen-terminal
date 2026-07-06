Kouen Terminal will support appearance (Auto,Light,Dark)

## Status: Closed (2026-07-06) — light + dark shipped via runtime Dock-icon swap.

Original ask: app icon support appearance (Auto,Light,Dark). Turned out to be about the
app icon (logo), not in-app UI theme.

### What shipped

- New mark green `#567a52` (was `#93a889`, 2.16:1 contrast against the cream bg — too
  washed out; new value is 4.11:1). Confirmed via WCAG contrast calc + side-by-side
  artifact comparison against 2 other darker candidates (A `#6f8f5f`, C `#4a6b47`).
- Fixed a real white-edge bug in the regenerated icon: the render SVG used
  `viewBox="0 0 216.5 225"` (non-square, ratio 0.962) rasterized into a square canvas
  without `preserveAspectRatio` handling — default SVG "meet" scaling letterboxed it,
  leaving ~2% transparent/white gaps on left+right edges (visible as a white ring in the
  Dock, screenshot-confirmed). Fix: made viewBox square (`0 0 225 225`) so the background
  rect fills edge-to-edge.
- Updated all three light-side assets from the same source vector (traced K/bamboo/cloud
  mark, unchanged silhouette — only recolored): `Apps/Kouen/Resources/AppIcon-1024.png`
  (master, downsampled by `Scripts/generate-app-icon.sh` via `sips` into `Kouen.icns`),
  `Kouen.icns`, `KouenLogo.png` (single-tone in-app brand mark, used by
  `KouenDesign.swift` + `WelcomeStepView.swift`).
- `Assets.xcassets/AppIcon.appiconset` confirmed dead again — not referenced by
  `Package.swift`'s `KouenApp` resources, not touched by `generate-app-icon.sh` either
  (script uses `AppIcon-1024.png` outside the appiconset as the real master). Left as-is,
  out of scope.
- Verified end-to-end: `make prod` build succeeded, packaged `Kouen.app` re-signed,
  relaunched, icon confirmed clean (no white edge) in the actual running app bundle.

### Dark OS-native swap — how it actually shipped

A dark colorway was designed and validated (bg `#16211b`, mark `#aac49d`, accent
`#88aedb` — same traced mark, recolored) from a prior session's Artifact
(`~/.claude/jobs/613fce9d/tmp/kouen-logo/index.html`).

Two build-time mechanisms were tried and empirically ruled out before landing on the
real fix:

1. **`.icns` + `CFBundleIconFile`** (original mechanism) — static, no OS appearance
   awareness at all.
2. **Asset-catalog `AppIcon.appiconset` + `actool` with `"appearances":[{"appearance":
   "luminosity","value":"dark"}]`** — looked well-documented (works on iOS), so it was
   actually built and compiled via `xcrun actool ... --compile` to test. Result: actool
   silently dropped all 10 dark renditions as "unassigned children" — `assetutil --info`
   on the compiled `Assets.car` confirmed zero dark renditions made it in. Web research
   confirmed why: **macOS `"idiom":"mac"` app icons have never supported per-appearance
   variants via classic appiconset+actool** — that mechanism is iOS/iPadOS-only. Real
   macOS adaptive icons are new in Tahoe via Icon Composer's `.icon` format only, which
   was already ruled out (GUI-only, undocumented `icon.json` schema, no way to hand-build
   or verify headlessly). Reverted this experiment (`Contents.json` restored, dark PNGs
   removed) — it doesn't work, don't retry without new tooling access.

**What actually works — runtime Dock-icon swap:** most third-party Mac apps that appear
to have dark-mode Dock icons don't use any static build mechanism at all; the app itself
calls `NSApp.applicationIconImage = <image>` at runtime, based on
`NSApp.effectiveAppearance`. Kouen already had the exact infrastructure for this —
`AppDelegate`'s existing `appearanceObservation` (`NSApp.observe(\.effectiveAppearance)`,
previously only driving terminal theme auto-switching). Added:

- `Apps/Kouen/Resources/AppIcon-1024-dark.png` — new bundled resource (dark colorway,
  same mark).
- `Scripts/package-app.sh` — copies it into `Contents/Resources` alongside `Kouen.icns`.
- `AppDelegate.updateDockIconForCurrentAppearance()` — sets `NSApp.applicationIconImage`
  (nil to fall back to the light default, or the dark PNG) + `NSApp.dockTile.display()`.
  Called once at launch and from the existing appearance-KVO closure.

Verified end-to-end: `make prod` → real signed `Kouen.app`, confirmed **visually by Vit**
that the Dock icon is dark while the system is in Dark mode. (Note for future sessions:
`NSRunningApplication.icon` queried from an external process does NOT reflect this kind
of live change — it reads stale/cached data. Don't use it to verify; check the real Dock,
or trust an NSLog trace of the setter succeeding.)

Caveat inherent to this technique (not a bug, just how it works): only the *running*
app's Dock tile swaps. Finder, Launchpad, and "Get Info" still show the static light
icon from `Kouen.icns`/Info.plist, since those are read before the process exists.

**Follow-up bug found after shipping: dark tile rendered ~17% bigger than the light one.**
Screenshot-measured (pixel column-brightness scan across Dock rows), confirmed real —
not Dock's active-app magnification (ruled out: Vit clicked away, Kouen shrank to normal
vs *other* apps, but light-vs-dark still differed when compared directly). Root cause:
macOS's icon *compositor* auto-shrinks/pads full-bleed legacy-style square icons to match
the modern template proportions — but that compositor only runs for statically-declared
icons (`.icns` via `CFBundleIconFile`). A raw `NSImage` handed to
`NSApp.applicationIconImage` at runtime skips that compositor entirely and renders at
literal full-bleed size, so it looked bigger than the auto-shrunk light one even though
both source images were the same nominal canvas size. Two prior fix attempts (declaring
`image.size = NSSize(512,512)` to correct a suspected DPI/point misinterpretation;
shipping the file at literal 512×512 px instead of 1024) made *zero* measured difference
— proof the bug was never about pixel dimensions or point-size declaration, only about
which icons get OS auto-padding. Real fix: manually shrink the dark PNG's content to
~85.6% scale (empirically matched against the light icon's measured on-screen footprint)
centered on a transparent-padded canvas, baking in by hand what the compositor gives the
static icon for free. Confirmed pixel-equal to the light icon in a direct side-by-side
Dock screenshot after this fix.
**Lesson: if a runtime-injected image looks larger than a static-icon sibling with
identical nominal content, suspect the OS's icon-compositor padding step, not
DPI/point-size — check by comparing measured on-screen footprints, and if there's no
change in size after a DPI-related fix, that alone is evidence to stop chasing that
theory.** Neither Tahoe nor any macOS version exposes this auto-padding to
runtime-injected icons — Icon Composer/`.icon` only applies at the static asset-catalog
level (`CFBundleIconName` lookup), not to `NSApp.applicationIconImage`. Apple's actual
recommended fix (since Big Sur, not Tahoe-specific) is to author all icon art — static
*and* any runtime-swapped image — against Apple's official Icon Template from the start,
so no image ever depends on the OS's inconsistent legacy-icon leniency.

### Rejected directions (for context, don't re-litigate without new information)

- Full logo redesign (K + tree canopy + lamp-post glow, bold shapes instead of fine
  trace) — built and compared, but current traced K-mark already has real brand equity
  across `Kouen.icns`/`KouenLogo.png`/onboarding, and the "reads as generic eco" critique
  is nuance-level, not a functional break. Not worth the full-repaint cost right now.
- Dropping the 6 scattered leaf sprigs, or swapping the cloud for a lamp post while
  keeping the rest of the trace — both tested as drafts in the comparison artifact, not
  chosen. Confirmed via web research that letter+leaves is a well-known "eco/growth"
  logo pattern (Whole Foods etc.) and real park branding vocabulary is bench/lamp/path,
  not foliage — so the critique has real design-literature backing if this gets
  revisited later, just wasn't enough to outweigh keeping the shipped mark this round.
