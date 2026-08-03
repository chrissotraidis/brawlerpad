#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
BATTLESHIP_BUILD="${1:-$BATTLESHIP_SOURCE/build-ios-device}"
BUILD_CONFIGURATION="${CONFIGURATION:-Release}"
REPRODUCIBLE_DEVICE_LINK="${BRAWLERPAD_REPRODUCIBLE_DEVICE_LINK:-ON}"
DEVICE_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
APP="$BATTLESHIP_BUILD/$BUILD_CONFIGURATION-iphoneos/BrawlerPad.app"
PYTHON_PREFIX="$(brew --prefix python@3.11 2>/dev/null || true)"

if [ ! -f "$BATTLESHIP_SOURCE/CMakeLists.txt" ]; then
    echo "Pinned sources are missing; run scripts/clone-sources.sh first." >&2
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo "The current device build requires an Apple Silicon host." >&2
    exit 1
fi

if [ -z "$PYTHON_PREFIX" ] || [ ! -x "$PYTHON_PREFIX/bin/python3.11" ]; then
    echo "Python 3.11 is missing; run: brew install python@3.11" >&2
    exit 1
fi
PYTHON_EXECUTABLE="$PYTHON_PREFIX/bin/python3.11"
if ! "$PYTHON_EXECUTABLE" -c 'from PIL import Image' >/dev/null 2>&1; then
    echo "Pillow is missing for $PYTHON_EXECUTABLE" >&2
    echo "Install it with: $PYTHON_EXECUTABLE -m pip install --user Pillow" >&2
    exit 1
fi

IOS_ASSET_CATALOG="$BRAWLERPAD_ROOT/assets/ios/BrawlerPad.xcassets"
test -f "$IOS_ASSET_CATALOG/AppIcon.appiconset/AppIcon.png"
ditto "$IOS_ASSET_CATALOG" "$BATTLESHIP_SOURCE/ios/BrawlerPad.xcassets"

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
    -DCMAKE_OSX_SYSROOT="$DEVICE_SDK" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DPLATFORM=OS64 \
    -DBRAWLERPAD_BRANDING=ON \
    -DBRAWLERPAD_REPRODUCIBLE_DEVICE_LINK="$REPRODUCIBLE_DEVICE_LINK" \
    -DSSB64_VERSION=us \
    -DPython3_EXECUTABLE="$PYTHON_EXECUTABLE"

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

if [ "$REPRODUCIBLE_DEVICE_LINK" = "ON" ]; then
    if otool -l "$APP/BrawlerPad" | grep -q 'cmd LC_UUID'; then
        echo "Reproducible proof executable unexpectedly contains LC_UUID." >&2
        exit 1
    fi
    echo "BrawlerPad unsigned proof app (not device-runnable; LC_UUID omitted): $APP"
else
    otool -l "$APP/BrawlerPad" | grep -q 'cmd LC_UUID' || {
        echo "Runtime device executable is missing required LC_UUID." >&2
        exit 1
    }
    echo "BrawlerPad unsigned runtime app (sign before local installation): $APP"
fi
