#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
BATTLESHIP_BUILD="${1:-$BATTLESHIP_SOURCE/build-ios-device}"
BUILD_CONFIGURATION="${CONFIGURATION:-Release}"
APP="$BATTLESHIP_BUILD/$BUILD_CONFIGURATION-iphoneos/BrawlerPad.app"

if [ ! -f "$BATTLESHIP_SOURCE/CMakeLists.txt" ]; then
    echo "Pinned sources are missing; run scripts/clone-sources.sh first." >&2
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo "The current device build requires an Apple Silicon host." >&2
    exit 1
fi

# CMake cannot change an existing build tree's target platform in place. A
# stale desktop cache can otherwise accept -DCMAKE_SYSTEM_NAME=iOS while its
# generated CMakeSystem.cmake remains Darwin, re-enabling host-only scripting
# dependencies and eventually producing a misleading Xcode generation error.
if [ -d "$BATTLESHIP_BUILD/CMakeFiles" ]; then
    BRAWLERPAD_SYSTEM_FILE="$(find "$BATTLESHIP_BUILD/CMakeFiles" -maxdepth 2 \
        -name CMakeSystem.cmake -type f -print -quit)"
    if [ -n "$BRAWLERPAD_SYSTEM_FILE" ] &&
       ! grep -q '^set(CMAKE_SYSTEM_NAME "iOS")' "$BRAWLERPAD_SYSTEM_FILE"; then
        echo "Refusing non-iOS CMake cache: $BATTLESHIP_BUILD" >&2
        echo "Choose a fresh build directory argument or remove that stale build directory." >&2
        exit 1
    fi
fi

cmake -S "$BATTLESHIP_SOURCE" -B "$BATTLESHIP_BUILD" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DPLATFORM=OS64 \
    -DBRAWLERPAD_BRANDING=ON \
    -DSSB64_VERSION=us

# Do not let a previously signed build leak a profile or signature into this
# unsigned proof. APP is a fully resolved product path under the selected
# build directory, never a workspace or home-directory wildcard.
if [ -d "$APP" ]; then
    rm -rf "$APP"
fi

cmake --build "$BATTLESHIP_BUILD" --target ssb64 \
    --config "$BUILD_CONFIGURATION" -- \
    -sdk iphoneos \
    -destination generic/platform=iOS \
    ARCHS=arm64 \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO

test -x "$APP/BrawlerPad"
test "$(lipo -archs "$APP/BrawlerPad")" = "arm64"
vtool -show-build "$APP/BrawlerPad" | grep -Eq 'platform +IOS$'

for key in UIFileSharingEnabled LSSupportsOpeningDocumentsInPlace \
    UIApplicationSupportsIndirectInputEvents; do
    test "$(/usr/libexec/PlistBuddy -c "Print :$key" "$APP/Info.plist")" = true
done

if find "$APP" -type f -print | grep -Eiq \
    '\.(z64|n64|v64|rom|otr)$|/BattleShip\.o2r$'; then
    echo "Device app contains prohibited game data." >&2
    exit 1
fi

if [ -d "$APP/_CodeSignature" ] || [ -f "$APP/embedded.mobileprovision" ]; then
    echo "Unsigned device app contains stale signing material." >&2
    exit 1
fi

"$BRAWLERPAD_ROOT/scripts/audit-ios-package.sh" "$APP"

echo "BrawlerPad unsigned device app: $APP"
