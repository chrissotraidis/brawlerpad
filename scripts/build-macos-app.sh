#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BATTLESHIP_SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip"
APP="$BATTLESHIP_SOURCE/dist/BrawlerPad.app"
DMG="$BATTLESHIP_SOURCE/dist/BrawlerPad.dmg"

if [ ! -f "$BATTLESHIP_SOURCE/CMakeLists.txt" ]; then
    echo "Pinned sources are missing; run scripts/clone-sources.sh first." >&2
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo "The current macOS build requires an Apple Silicon host." >&2
    exit 1
fi

# The image tools need Python 3.11 with Pillow, the same one the iPhone build
# uses (BRAWLERPAD_PYTHON, else Homebrew's python@3.11, else python3.11 on PATH).
# BattleShip's packaging lets CMake find Python on PATH, so put that one first.
PYTHON_EXECUTABLE="${BRAWLERPAD_PYTHON:-}"
if [ -z "$PYTHON_EXECUTABLE" ]; then
    PYTHON_PREFIX="$(brew --prefix python@3.11 2>/dev/null || true)"
    if [ -n "$PYTHON_PREFIX" ] && [ -x "$PYTHON_PREFIX/bin/python3.11" ]; then
        PYTHON_EXECUTABLE="$PYTHON_PREFIX/bin/python3.11"
    else
        PYTHON_EXECUTABLE="$(command -v python3.11 || true)"
    fi
fi
if [ -z "$PYTHON_EXECUTABLE" ] || ! "$PYTHON_EXECUTABLE" -c 'from PIL import Image' >/dev/null 2>&1; then
    echo "Python 3.11 with Pillow is needed: brew install python@3.11 && python3.11 -m pip install --user Pillow" >&2
    exit 1
fi
PYTHON_SHIM="$(mktemp -d "${TMPDIR:-/tmp}/brawlerpad-python.XXXXXX")"
trap 'rm -rf "$PYTHON_SHIM"' EXIT
ln -s "$PYTHON_EXECUTABLE" "$PYTHON_SHIM/python3"
ln -s "$PYTHON_EXECUTABLE" "$PYTHON_SHIM/python3.11"
export PATH="$PYTHON_SHIM:$PATH"

CI=1 \
BRAWLERPAD_BRANDING=ON \
BRAWLERPAD_PROJECT_ROOT="$BRAWLERPAD_ROOT" \
BATTLESHIP_VERSION=0.1.0 \
JOBS="${JOBS:-$(sysctl -n hw.logicalcpu)}" \
    "$BATTLESHIP_SOURCE/scripts/package-macos.sh"

"$BRAWLERPAD_ROOT/scripts/audit-macos-package.sh" "$APP" "$DMG"
echo "BrawlerPad macOS app: $APP"
echo "BrawlerPad macOS DMG: $DMG"
