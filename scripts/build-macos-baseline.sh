#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
BATTLESHIP_BUILD="$BATTLESHIP_SOURCE/build-us"
EXPECTED_SHA1="e2929e10fccc0aa84e5776227e798abc07cedabf"
PYTHON_PREFIX="$(brew --prefix python@3.11 2>/dev/null || true)"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /absolute/path/to/supported-us-rom.{z64,n64,v64}" >&2
    exit 2
fi

ROM_PATH="$1"
if [[ "$ROM_PATH" != /* ]] || [ ! -f "$ROM_PATH" ]; then
    echo "ROM path must be an existing absolute file: $ROM_PATH" >&2
    exit 2
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

"$BRAWLERPAD_ROOT/scripts/clone-sources.sh"

ACTUAL_SHA1="$(shasum -a 1 "$ROM_PATH" | awk '{print $1}')"
if [ "$ACTUAL_SHA1" != "$EXPECTED_SHA1" ]; then
    echo "Unsupported ROM SHA-1: $ACTUAL_SHA1" >&2
    echo "Expected US NTSC-U v1.0: $EXPECTED_SHA1" >&2
    exit 1
fi

ROM_LINK="$BATTLESHIP_SOURCE/baserom.us.n64"
if [ -e "$ROM_LINK" ] || [ -L "$ROM_LINK" ]; then
    if [ ! -L "$ROM_LINK" ] || [ "$(realpath "$ROM_LINK")" != "$ROM_PATH" ]; then
        echo "Refusing to replace existing local ROM input: $ROM_LINK" >&2
        exit 1
    fi
else
    ln -s "$ROM_PATH" "$ROM_LINK"
fi

cmake -S "$BATTLESHIP_SOURCE" -B "$BATTLESHIP_BUILD" -GNinja \
    -DSSB64_VERSION=us \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE="$PYTHON_EXECUTABLE"
cmake --build "$BATTLESHIP_BUILD" -j "$(sysctl -n hw.logicalcpu)"

file "$BATTLESHIP_BUILD/BattleShip"
echo "Run the baseline from: $BATTLESHIP_BUILD"
