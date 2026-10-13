#!/usr/bin/env bash
# Zip the dSYMs for every executable in a packaged Harness.app, after proving each dSYM's
# UUIDs match the shipped binary. A crash report symbolicates only against the exact build,
# and CI artifacts expire, so releases attach this zip as a permanent asset.
#
#   Scripts/archive-dsyms.sh Harness.app .build/release dist/Harness-2.3.2-dSYMs.zip
set -euo pipefail

APP="${1:?usage: archive-dsyms.sh <Harness.app> <build-dir> <output.zip>}"
BUILD_DIR="${2:?usage: archive-dsyms.sh <Harness.app> <build-dir> <output.zip>}"
OUTPUT="${3:?usage: archive-dsyms.sh <Harness.app> <build-dir> <output.zip>}"

uuids() { dwarfdump --uuid "$1" | awk '{print $2, $3}' | sort; }

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/dSYMs"
manifest="$STAGE/dSYMs/UUIDS.txt"

binaries=("$APP/Contents/MacOS/Harness")
for helper in "$APP"/Contents/Helpers/*.app; do
  [[ -d "$helper" ]] || continue
  binaries+=("$helper/Contents/MacOS/$(basename "$helper" .app)")
done

for binary in "${binaries[@]}"; do
  name="$(basename "$binary")"
  dsym="$BUILD_DIR/$name.dSYM"
  if [[ ! -f "$binary" ]]; then
    echo "error: $binary is missing from the app bundle." >&2
    exit 1
  fi
  if [[ ! -d "$dsym" ]]; then
    echo "error: no dSYM for $name at $dsym." >&2
    exit 1
  fi
  shipped="$(uuids "$binary")"
  recorded="$(uuids "$dsym")"
  if [[ -z "$shipped" || "$shipped" != "$recorded" ]]; then
    echo "error: $dsym does not match the shipped $name." >&2
    echo "  binary: $shipped" >&2
    echo "  dSYM:   $recorded" >&2
    exit 1
  fi
  ditto "$dsym" "$STAGE/dSYMs/$name.dSYM"
  while read -r uuid arch; do echo "$uuid $arch $name" >> "$manifest"; done <<< "$shipped"
done

mkdir -p "$(dirname "$OUTPUT")"
rm -f "$OUTPUT"
ditto -c -k --keepParent "$STAGE/dSYMs" "$OUTPUT"
echo "Archived ${#binaries[@]} UUID-verified dSYMs to $OUTPUT"
cat "$manifest"
