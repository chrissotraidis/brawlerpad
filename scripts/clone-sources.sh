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
    local recover_stale_stamp="${3:-0}"
    local patch_digest
    local stamp

    patch_digest="$(shasum -a 256 "$patch_file" | awk '{print $1}')"
    stamp="$(git -C "$checkout" rev-parse --absolute-git-dir)/brawlerpad-patch-$patch_digest"

    if [ -f "$stamp" ]; then
        if [ "$recover_stale_stamp" -eq 1 ] &&
           git -C "$checkout" apply --check "$patch_file" >/dev/null 2>&1; then
            echo "Stale patch stamp; applying: $patch_file"
            git -C "$checkout" apply "$patch_file"
            return
        fi
        echo "Patch already applied: $patch_file"
        return
    fi

    if git -C "$checkout" apply --check "$patch_file" >/dev/null 2>&1; then
        git -C "$checkout" apply "$patch_file"
    elif git -C "$checkout" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
        echo "Patch already applied: $patch_file"
    else
        echo "Patch does not apply cleanly: $patch_file" >&2
        exit 1
    fi

    touch "$stamp"
}

mark_patch_applied() {
    local checkout="$1"
    local patch_file="$2"
    local patch_digest

    patch_digest="$(shasum -a 256 "$patch_file" | awk '{print $1}')"
    touch "$(git -C "$checkout" rev-parse --absolute-git-dir)/brawlerpad-patch-$patch_digest"
}

clone_at_pin "$BATTLESHIP_REPO" "$BRAWLERPAD_REF/BattleShip" "$BATTLESHIP_PIN"
git -C "$BRAWLERPAD_REF/BattleShip" submodule update --init --recursive
git -C "$BRAWLERPAD_REF/BattleShip" submodule foreach --recursive \
    'git config remote.origin.pushurl disabled://brawlerpad-reference-input'

# Older BrawlerPad checkouts predate per-patch stamps. If the terminal patch
# in every patched repository is already present, migrate that known-complete
# tree once. This avoids asking an early patch to reverse-apply through later
# edits to the same CMake or source context.
if git -C "$BRAWLERPAD_REF/BattleShip" apply --reverse --check \
       "$BRAWLERPAD_ROOT/patches/battleship/0012-ios-phone-touch-layout-v4.patch" >/dev/null 2>&1 &&
   git -C "$BRAWLERPAD_REF/BattleShip/libultraship" apply --reverse --check \
       "$BRAWLERPAD_ROOT/patches/libultraship/0003-ios-lifecycle-audio.patch" >/dev/null 2>&1 &&
   git -C "$BRAWLERPAD_REF/BattleShip/decomp" apply --reverse --check \
       "$BRAWLERPAD_ROOT/patches/decomp/0001-retire-vs-results-transition-camera.patch" >/dev/null 2>&1 &&
   git -C "$BRAWLERPAD_REF/BattleShip/torch" apply --reverse --check \
       "$BRAWLERPAD_ROOT/patches/torch/0001-preserve-caller-compiler-flags.patch" >/dev/null 2>&1; then
    for patch_file in "$BRAWLERPAD_ROOT"/patches/battleship/*.patch; do
        mark_patch_applied "$BRAWLERPAD_REF/BattleShip" "$patch_file"
    done
    for patch_file in "$BRAWLERPAD_ROOT"/patches/libultraship/*.patch; do
        mark_patch_applied "$BRAWLERPAD_REF/BattleShip/libultraship" "$patch_file"
    done
    for patch_file in "$BRAWLERPAD_ROOT"/patches/decomp/*.patch; do
        mark_patch_applied "$BRAWLERPAD_REF/BattleShip/decomp" "$patch_file"
    done
    for patch_file in "$BRAWLERPAD_ROOT"/patches/torch/*.patch; do
        mark_patch_applied "$BRAWLERPAD_REF/BattleShip/torch" "$patch_file"
    done
fi

apply_patch_once "$BRAWLERPAD_REF/BattleShip/decomp" \
    "$BRAWLERPAD_ROOT/patches/decomp/0001-retire-vs-results-transition-camera.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip/libultraship" \
    "$BRAWLERPAD_ROOT/patches/libultraship/0001-ios-sandbox-metal-audio-runtime.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip/libultraship" \
    "$BRAWLERPAD_ROOT/patches/libultraship/0002-ios-form-factor-ui.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip/libultraship" \
    "$BRAWLERPAD_ROOT/patches/libultraship/0003-ios-lifecycle-audio.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip/torch" \
    "$BRAWLERPAD_ROOT/patches/torch/0001-preserve-caller-compiler-flags.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0001-native-apple-mobile-runtime.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0002-ios-form-factor-ui.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0003-ios-touch-controls.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0004-ios-lifecycle-frame-gate.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0005-ios-touch-layout-v2.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0006-ios-phone-touch-layout-v3.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0007-ios-release-path-redaction.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0008-reproducible-shader-archive.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0009-reproducible-device-link.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0010-brawlerpad-identity-and-macos-package.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0011-reproducible-macos-release.patch"
apply_patch_once "$BRAWLERPAD_REF/BattleShip" \
    "$BRAWLERPAD_ROOT/patches/battleship/0012-ios-phone-touch-layout-v4.patch" 1

clone_at_pin "$HARKINIANPAD_REPO" "$BRAWLERPAD_REF/harkinianpad" "$HARKINIANPAD_PIN"

test "$(git -C "$BRAWLERPAD_REF/BattleShip" rev-parse HEAD)" = "$BATTLESHIP_PIN"
test "$(git -C "$BRAWLERPAD_REF/harkinianpad" rev-parse HEAD)" = "$HARKINIANPAD_PIN"

echo "Pinned reference sources are ready under $BRAWLERPAD_REF"
