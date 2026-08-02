#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
BATTLESHIP_BUILD="${1:-$BATTLESHIP_SOURCE/build-ios-sim}"
BUILD_CONFIGURATION="${CONFIGURATION:-Release}"

if [ ! -f "$BATTLESHIP_SOURCE/CMakeLists.txt" ]; then
    echo "Pinned sources are missing; run scripts/clone-sources.sh first." >&2
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo "The current simulator proof requires an Apple Silicon host." >&2
    exit 1
fi

cmake -S "$BATTLESHIP_SOURCE" -B "$BATTLESHIP_BUILD" -G Xcode \
    -DPLATFORM=SIMULATORARM64 \
    -DSSB64_VERSION=us

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
