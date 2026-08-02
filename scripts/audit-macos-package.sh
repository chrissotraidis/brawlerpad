#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-$BRAWLERPAD_ROOT/ref/BattleShip/dist/BrawlerPad.app}"

case "$APP" in
    /*) ;;
    *) APP="$BRAWLERPAD_ROOT/$APP" ;;
esac

fail() {
    echo "macOS package audit failed: $*" >&2
    exit 1
}

EXECUTABLE="$APP/Contents/MacOS/BrawlerPad"
RESOURCES="$APP/Contents/Resources"
[ -d "$APP" ] || fail "app not found: $APP"
[ -x "$EXECUTABLE" ] || fail "BrawlerPad executable is missing"
[ -f "$APP/Contents/Info.plist" ] || fail "Info.plist is missing"
[ "$(lipo -archs "$EXECUTABLE")" = "arm64" ] ||
    fail "main executable is not arm64-only"
vtool -show-build "$EXECUTABLE" | grep -Eq 'platform +MACOS$' ||
    fail "main executable is not a macOS product"
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")" = \
    "com.brawlerpad.app.macos" ] || fail "unexpected bundle identifier"
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")" = \
    "BrawlerPad" ] || fail "unexpected bundle executable"
[ -f "$RESOURCES/BRAWLERPAD_RIGHTS.md" ] || fail "rights notice is missing"
[ -f "$RESOURCES/BRAWLERPAD_DEPENDENCIES.md" ] || fail "dependency manifest is missing"

[ -f "$RESOURCES/f3d.o2r" ] || fail "Fast3D shader archive is missing"
[ "$(stat -f '%z' "$RESOURCES/f3d.o2r")" -le 1048576 ] ||
    fail "Fast3D shader archive is unexpectedly large"
unzip -tq "$RESOURCES/f3d.o2r" >/dev/null || fail "Fast3D shader archive is corrupt"
shader_entries="$(unzip -Z1 "$RESOURCES/f3d.o2r")"
if printf '%s\n' "$shader_entries" |
    grep -Evq '^shaders/(metal|postprocess|directx|opengl)/[^/]+\.(metal|msl|glsl|slang|hlsl)$'; then
    fail "Fast3D archive contains a non-shader entry"
fi

forbidden="$(find "$APP" -type f \
    \( -iname '*.z64' -o -iname '*.n64' -o -iname '*.v64' -o \
       -iname '*.rom' -o -iname '*.otr' -o -iname '*.sav' -o \
       -iname '*.sra' -o -iname '*.eep' -o -iname '*.mpk' -o \
       -iname '*.log' -o -iname '*.mobileprovision' -o \
       -iname '*.provisionprofile' -o -iname '*.p12' -o \
       -iname '*.p8' -o -iname '*.pem' -o -iname '*.key' \) -print -quit)"
[ -z "$forbidden" ] || fail "bundle contains prohibited data: $forbidden"
forbidden="$(find "$APP" -type f -iname '*.o2r' ! -path "$RESOURCES/f3d.o2r" -print -quit)"
[ -z "$forbidden" ] || fail "bundle contains a prohibited O2R archive: $forbidden"

codesign --verify --deep --strict "$APP" >/dev/null 2>&1 ||
    fail "bundle code signature is invalid"

personal=""
while IFS= read -r -d '' file; do
    if LC_ALL=C strings -a "$file" 2>/dev/null |
        awk 'index($0, "/Users/") || index($0, "/Volumes/") { found=1 }
             END { exit found ? 0 : 1 }'; then
        personal="$file"
        break
    fi
    if LC_ALL=C strings -a "$file" 2>/dev/null |
        awk '/-----BEGIN [A-Z ]*PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}/ { found=1 }
             END { exit found ? 0 : 1 }'; then
        personal="$file"
        break
    fi
done < <(find "$APP" -type f -print0)
[ -z "$personal" ] || fail "bundle contains a personal path or likely credential: $personal"

while IFS= read -r -d '' candidate; do
    file "$candidate" | grep -q 'Mach-O' || continue
    if otool -L "$candidate" | tail -n +2 |
        grep -Eq '/opt/homebrew|/usr/local/Cellar|/Users/|/Volumes/'; then
        fail "Mach-O has a non-portable load command: $candidate"
    fi
done < <(find "$APP" -type f -print0)

echo "macOS package audit passed: $APP"
