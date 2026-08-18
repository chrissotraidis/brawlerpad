#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$BRAWLERPAD_ROOT/ref/BattleShip/libultraship/src/ship/controller/physicaldevice/ConnectedPhysicalDeviceManager.cpp"
HARNESS="$BRAWLERPAD_ROOT/tests/controller_reconciliation.cpp"
STUBS="$BRAWLERPAD_ROOT/tests/controller_test_support"
OUTPUT_DIR="$(mktemp -d /tmp/brawlerpad-controller-test.XXXXXX)"
trap 'rm -rf "$OUTPUT_DIR"' EXIT

clang++ -std=c++20 -Wall -Wextra -Wno-unused-parameter \
    -I"$STUBS" \
    -I"$BRAWLERPAD_ROOT/ref/BattleShip/libultraship/include" \
    -I"$(sdl2-config --prefix)/include" \
    $(sdl2-config --cflags) \
    "$HARNESS" "$SOURCE" \
    $(sdl2-config --libs) \
    -o "$OUTPUT_DIR/controller-reconciliation"

"$OUTPUT_DIR/controller-reconciliation"
