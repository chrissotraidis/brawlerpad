#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HEADER_DIR="$BRAWLERPAD_ROOT/ref/BattleShip/port/ios"
OUTPUT_DIR="$(mktemp -d /tmp/brawlerpad-touch-test.XXXXXX)"
trap 'rm -rf "$OUTPUT_DIR"' EXIT

if [ ! -f "$HEADER_DIR/brawlerpad_touch_visibility.h" ]; then
    echo "Run scripts/clone-sources.sh first." >&2
    exit 1
fi

clang++ -std=c++20 -Wall -Wextra -Werror -I"$HEADER_DIR" \
    "$BRAWLERPAD_ROOT/tests/touch_visibility_test.cpp" -o "$OUTPUT_DIR/touch-visibility"
"$OUTPUT_DIR/touch-visibility"
