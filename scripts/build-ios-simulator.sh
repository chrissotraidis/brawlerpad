#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
BATTLESHIP_BUILD="${1:-$BATTLESHIP_SOURCE/build-ios-sim}"
BUILD_CONFIGURATION="${CONFIGURATION:-Release}"
SIMULATOR_SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
PYTHON_PREFIX="$(brew --prefix python@3.11 2>/dev/null || true)"

if [ ! -f "$BATTLESHIP_SOURCE/CMakeLists.txt" ]; then
    echo "Pinned sources are missing; run scripts/clone-sources.sh first." >&2
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo "The current simulator proof requires an Apple Silicon host." >&2
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

cmake -S "$BATTLESHIP_SOURCE" -B "$BATTLESHIP_BUILD" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$SIMULATOR_SDK" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DPLATFORM=SIMULATORARM64 \
    -DBRAWLERPAD_BRANDING=ON \
    -DSSB64_VERSION=us \
    -DPython3_EXECUTABLE="$PYTHON_EXECUTABLE"

cmake --build "$BATTLESHIP_BUILD" --target ssb64 \
    --config "$BUILD_CONFIGURATION" -- \
    -sdk iphonesimulator \
    ARCHS=arm64 \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO

APP="$BATTLESHIP_BUILD/$BUILD_CONFIGURATION-iphonesimulator/BrawlerPad.app"
test -x "$APP/BrawlerPad"

for key in UIFileSharingEnabled LSSupportsOpeningDocumentsInPlace \
    UIApplicationSupportsIndirectInputEvents; do
    test "$(/usr/libexec/PlistBuddy -c "Print :$key" "$APP/Info.plist")" = true
done

if find "$APP" -type f -print | grep -Eiq \
    '\.(z64|n64|v64)$|/BattleShip\.o2r$'; then
    echo "Simulator app contains prohibited game data." >&2
    exit 1
fi

echo "BrawlerPad simulator app: $APP"
