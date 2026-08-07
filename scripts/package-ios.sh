#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-$BRAWLERPAD_ROOT/ref/BattleShip/build-ios-device/Release-iphoneos/BrawlerPad.app}"

case "$APP" in
    /*) ;;
    *) APP="$BRAWLERPAD_ROOT/$APP" ;;
esac

"$BRAWLERPAD_ROOT/scripts/audit-ios-package.sh" "$APP"

version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Info.plist")"
build_number="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP/Info.plist")"
device_build="$(cd "$APP/../.." && pwd)"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
   [[ ! "$build_number" =~ ^[1-9][0-9]*$ ]]; then
    echo "Refusing app with invalid release version: $version ($build_number)" >&2
    exit 1
fi

OUTPUT="${2:-$BRAWLERPAD_ROOT/artifacts/BrawlerPad-$version-preview.$build_number-unsigned.ipa}"
case "$OUTPUT" in
    /*) ;;
    *) OUTPUT="$BRAWLERPAD_ROOT/$OUTPUT" ;;
esac

mkdir -p "$(dirname "$OUTPUT")"
package_root="$(mktemp -d /tmp/brawlerpad-package.XXXXXX)"
trap 'rm -rf "$package_root"' EXIT
mkdir -p "$package_root/Payload" "$package_root/ThirdPartyLicenses"
ditto "$APP" "$package_root/Payload/BrawlerPad.app"
cp "$BRAWLERPAD_ROOT/RIGHTS_AND_LICENSES.md" "$package_root/RIGHTS_AND_LICENSES.md"
cp "$BRAWLERPAD_ROOT/docs/DEPENDENCIES.md" "$package_root/DEPENDENCIES.md"

license_count=0
while IFS= read -r -d '' license_file; do
    relative="${license_file#"$BRAWLERPAD_ROOT/"}"
    destination="$package_root/ThirdPartyLicenses/$relative"
    mkdir -p "$(dirname "$destination")"
    cp "$license_file" "$destination"
    license_count=$((license_count + 1))
done < <(
    find "$BRAWLERPAD_ROOT/ref/BattleShip" \
        \( -path '*/.git' -o -path '*/dist' -o -path '*/build' -o -path '*/build-*' \) -prune -o \
        -type f \( -iname 'LICENSE*' -o -iname 'COPYING*' -o -iname 'NOTICE*' \) \
        -print0 | sort -z
)

# FetchContent dependencies are materialized inside the selected build tree,
# not the pinned source checkout. Ship those notices too so the IPA remains
# self-describing when it is copied away from this repository.
if [ -d "$device_build/_deps" ]; then
    while IFS= read -r -d '' license_file; do
        relative="${license_file#"$device_build/_deps/"}"
        destination="$package_root/ThirdPartyLicenses/fetched/$relative"
        mkdir -p "$(dirname "$destination")"
        cp "$license_file" "$destination"
        license_count=$((license_count + 1))
    done < <(
        find "$device_build/_deps" \
            -path '*/.git' -prune -o \
            -type f \( -iname 'LICENSE*' -o -iname 'COPYING*' -o -iname 'NOTICE*' \) \
            -print0 | sort -z
    )
fi
if [ "$license_count" -eq 0 ]; then
    echo "No third-party license files were found for packaging." >&2
    exit 1
fi

# Normalize archive metadata so packaging the same app and notices twice
# produces the same IPA bytes.
find "$package_root" -exec touch -h -t 200001010000 {} \;
temporary_ipa="$package_root/BrawlerPad.ipa"
(
    cd "$package_root"
    find Payload RIGHTS_AND_LICENSES.md DEPENDENCIES.md ThirdPartyLicenses \
        \( -type f -o -type l \) -print | LC_ALL=C sort |
        zip -X -q -y "$temporary_ipa" -@
)
mv -f "$temporary_ipa" "$OUTPUT"

"$BRAWLERPAD_ROOT/scripts/audit-ios-package.sh" "$APP" "$OUTPUT"

echo "Packaged unsigned BrawlerPad $version ($build_number)"
echo "IPA: $OUTPUT"
shasum -a 256 "$OUTPUT"
echo "This proof IPA must be re-signed before installation on a standard device."
