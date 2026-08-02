#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRAWLERPAD_REF="$BRAWLERPAD_ROOT/ref"

BATTLESHIP_REPO="https://github.com/JRickey/BattleShip.git"
BATTLESHIP_PIN="4e7f1dc9ef0c5f9ee0a5fb01754f980518553364"
HARKINIANPAD_REPO="https://github.com/chrissotraidis/harkinianpad.git"
HARKINIANPAD_PIN="1197472956cd2c4dd3f03fb6fe5f2dfb28d30ad7"

mkdir -p "$BRAWLERPAD_REF"

clone_at_pin() {
    local repository="$1"
    local destination="$2"
    local pin="$3"

    if [ ! -d "$destination/.git" ]; then
        git clone "$repository" "$destination"
    fi

    git -C "$destination" remote set-url origin "$repository"
    git -C "$destination" config remote.origin.pushurl \
        "disabled://brawlerpad-reference-input"
    git -C "$destination" fetch origin "$pin"
    git -C "$destination" checkout --detach "$pin"
}

apply_patch_once() {
    local checkout="$1"
    local patch_file="$2"

    if git -C "$checkout" apply --check "$patch_file" >/dev/null 2>&1; then
        git -C "$checkout" apply "$patch_file"
    elif git -C "$checkout" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
        echo "Patch already applied: $patch_file"
    else
        echo "Patch does not apply cleanly: $patch_file" >&2
        exit 1
    fi
}

clone_at_pin "$BATTLESHIP_REPO" "$BRAWLERPAD_REF/BattleShip" "$BATTLESHIP_PIN"
git -C "$BRAWLERPAD_REF/BattleShip" submodule update --init --recursive
git -C "$BRAWLERPAD_REF/BattleShip" submodule foreach --recursive \
    'git config remote.origin.pushurl disabled://brawlerpad-reference-input'
apply_patch_once "$BRAWLERPAD_REF/BattleShip/decomp" \
    "$BRAWLERPAD_ROOT/patches/decomp/0001-retire-vs-results-transition-camera.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip/libultraship" \
    "$BRAWLERPAD_ROOT/patches/libultraship/0001-ios-sandbox-metal-audio-runtime.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip/libultraship" \
    "$BRAWLERPAD_ROOT/patches/libultraship/0002-ios-form-factor-ui.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0001-native-apple-mobile-runtime.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0002-ios-form-factor-ui.patch"

clone_at_pin "$HARKINIANPAD_REPO" "$BRAWLERPAD_REF/harkinianpad" "$HARKINIANPAD_PIN"

test "$(git -C "$BRAWLERPAD_REF/BattleShip" rev-parse HEAD)" = "$BATTLESHIP_PIN"
test "$(git -C "$BRAWLERPAD_REF/harkinianpad" rev-parse HEAD)" = "$HARKINIANPAD_PIN"

echo "Pinned reference sources are ready under $BRAWLERPAD_REF"
