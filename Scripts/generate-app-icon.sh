#!/usr/bin/env bash
set -euo pipefail
# Regenerate Kouen.icns from Apps/Harness/Resources/Assets.xcassets/AppIcon.appiconset
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Apps/Harness/Resources/Kouen.icns"
# Master 1024×1024 source lives OUTSIDE the .appiconset so it isn't an unassigned
# child of the icon set (the set's largest assigned slot is 512x512@2x = 1024px).
SRC="$ROOT/Apps/Harness/Resources/AppIcon-1024.png"

if [[ ! -f "$SRC" ]]; then
  echo "Missing $SRC — add a 1024×1024 master PNG first." >&2
  exit 1
fi
TMP_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/harness-icon.XXXXXX")"
STAGE="$TMP_STAGE/Harness.iconset"
mkdir -p "$STAGE"
trap 'rm -rf "$TMP_STAGE"' EXIT
for spec in "16:icon_16x16.png" "32:icon_16x16@2x.png" "32:icon_32x32.png" "64:icon_32x32@2x.png" \
  "128:icon_128x128.png" "256:icon_128x128@2x.png" "256:icon_256x256.png" "512:icon_256x256@2x.png" \
  "512:icon_512x512.png" "1024:icon_512x512@2x.png"; do
  size="${spec%%:*}"
  file="${spec##*:}"
  sips -z "$size" "$size" "$SRC" --out "$STAGE/$file" >/dev/null
done
iconutil -c icns "$STAGE" -o "$OUT"
echo "Wrote $OUT"
