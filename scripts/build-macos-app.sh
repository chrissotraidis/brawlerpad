#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
APP="$BATTLESHIP_SOURCE/dist/BrawlerPad.app"

if [ ! -f "$BATTLESHIP_SOURCE/CMakeLists.txt" ]; then
    echo "Pinned sources are missing; run scripts/clone-sources.sh first." >&2
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo "The current macOS build requires an Apple Silicon host." >&2
    exit 1
fi

CI=1 \
BRAWLERPAD_BRANDING=ON \
BRAWLERPAD_PROJECT_ROOT="$BRAWLERPAD_ROOT" \
BATTLESHIP_VERSION=0.1.0 \
JOBS="${JOBS:-$(sysctl -n hw.logicalcpu)}" \
    "$BATTLESHIP_SOURCE/scripts/package-macos.sh"

"$BRAWLERPAD_ROOT/scripts/audit-macos-package.sh" "$APP"
echo "BrawlerPad macOS app: $APP"
