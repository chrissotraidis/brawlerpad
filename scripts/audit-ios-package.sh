#!/usr/bin/env bash
set -euo pipefail

BRAWLERPAD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-$BRAWLERPAD_ROOT/ref/BattleShip/build-ios-device/Release-iphoneos/BrawlerPad.app}"
IPA="${2:-}"

fail() {
    echo "iOS package audit failed: $*" >&2
    exit 1
}

absolute_path() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '%s/%s\n' "$BRAWLERPAD_ROOT" "$1" ;;
    esac
}

APP="$(absolute_path "$APP")"
if [ -n "$IPA" ]; then
    IPA="$(absolute_path "$IPA")"
fi

audit_app() {
    local app="$1"
    local executable="$app/BrawlerPad"
    local forbidden
    local personal

    [ -d "$app" ] || fail "app not found: $app"
    [ -x "$executable" ] || fail "app executable not found: $executable"
    [ -f "$app/Info.plist" ] || fail "Info.plist not found: $app"
    [ "$(lipo -archs "$executable")" = "arm64" ] ||
        fail "device executable is not arm64-only"
    vtool -show-build "$executable" | grep -Eq 'platform +IOS$' ||
        fail "app is not an iPhoneOS product"
    [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")" = \
        "com.brawlerpad.app" ] || fail "unexpected bundle identifier"
    [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconName' "$app/Info.plist")" = \
        "AppIcon" ] || fail "compiled app icon metadata is missing"
    [ -f "$app/Assets.car" ] || fail "compiled app icon asset catalog is missing"

    # f3d.o2r is the small, port-authored Fast3D shader archive required by
    # the renderer. It is not ROM-derived game content, and it is the only
    # O2R archive permitted in a distributable bundle.
    [ -f "$app/f3d.o2r" ] || fail "required Fast3D shader archive is missing"
    [ "$(stat -f '%z' "$app/f3d.o2r")" -le 1048576 ] ||
        fail "Fast3D shader archive is unexpectedly large"
    unzip -tq "$app/f3d.o2r" >/dev/null || fail "Fast3D shader archive is corrupt"
    local shader_entries
    shader_entries="$(unzip -Z1 "$app/f3d.o2r")"
    if printf '%s\n' "$shader_entries" |
        grep -Evq '^shaders/$|^shaders/(metal|postprocess|directx|opengl)/$|^shaders/(metal|postprocess|directx|opengl)/[^/]+\.(metal|msl|glsl|slang|hlsl)$'; then
        fail "Fast3D archive contains a non-shader entry"
    fi

    forbidden="$(find "$app" -type f \
        \( -iname '*.z64' -o -iname '*.n64' -o -iname '*.v64' -o \
           -iname '*.rom' -o -iname '*.otr' -o \
           -iname '*.mpq' -o -iname '*.sav' -o -iname '*.sra' -o \
           -iname '*.eep' -o -iname '*.mpk' -o -iname '*.log' -o \
           -iname '*.mobileprovision' -o -iname '*.provisionprofile' -o \
           -iname '*.p12' -o -iname '*.p8' -o -iname '*.pem' -o \
           -iname '*.key' -o -iname '*.cer' \) -print -quit)"
    [ -z "$forbidden" ] ||
        fail "app contains prohibited game, save, log, credential, or signing data: $forbidden"
    forbidden="$(find "$app" -type f -iname '*.o2r' ! -path "$app/f3d.o2r" -print -quit)"
    [ -z "$forbidden" ] || fail "app contains a prohibited O2R archive: $forbidden"

    [ ! -e "$app/BattleShip.cfg.json" ] ||
        fail "app contains a user configuration"
    [ ! -d "$app/_CodeSignature" ] ||
        fail "unsigned app contains _CodeSignature"
    [ ! -f "$app/embedded.mobileprovision" ] ||
        fail "unsigned app contains embedded.mobileprovision"
    if codesign --verify --strict "$app" >/dev/null 2>&1; then
        fail "expected an unsigned app, but code-signature verification succeeded"
    fi

    personal=""
    while IFS= read -r -d '' file; do
        if LC_ALL=C strings -a "$file" 2>/dev/null |
            awk 'index($0, "/Users/") || index($0, "/Volumes/") { found=1 }
                 END { exit found ? 0 : 1 }'; then
            personal="$file"
            break
        fi
        if LC_ALL=C strings -a "$file" 2>/dev/null |
            awk '/-----BEGIN [A-Z ]*PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}/ { found=1 }
                 END { exit found ? 0 : 1 }'; then
            personal="$file"
            break
        fi
    done < <(find "$app" -type f -print0)
    [ -z "$personal" ] ||
        fail "app contains a personal path or likely credential: $personal"
}

audit_app "$APP"

if [ -n "$IPA" ]; then
    [ -f "$IPA" ] || fail "IPA not found: $IPA"
    unzip -tq "$IPA" >/dev/null || fail "IPA ZIP integrity check failed"
    entries="$(unzip -Z1 "$IPA")"
    printf '%s\n' "$entries" | grep -Fxq 'Payload/BrawlerPad.app/BrawlerPad' ||
        fail "IPA payload executable is missing"
    printf '%s\n' "$entries" | grep -Fxq 'RIGHTS_AND_LICENSES.md' ||
        fail "IPA rights notice is missing"
    printf '%s\n' "$entries" | grep -Fxq 'DEPENDENCIES.md' ||
        fail "IPA dependency manifest is missing"
    printf '%s\n' "$entries" | grep -Fq 'ThirdPartyLicenses/' ||
        fail "IPA third-party licenses are missing"
    if printf '%s\n' "$entries" |
        grep -Eq '(^|/)\.\.(/|$)|^/|(^|/)__MACOSX(/|$)'; then
        fail "IPA contains unsafe or resource-fork paths"
    fi
    if printf '%s\n' "$entries" |
        grep -Eiv '^Payload/BrawlerPad\.app/f3d\.o2r$' |
        grep -Eiq '\.(z64|n64|v64|rom|o2r|otr|mpq|sav|sra|eep|mpk|log|mobileprovision|provisionprofile|p12|p8|pem|key|cer)$|(^|/)_CodeSignature(/|$)'; then
        fail "IPA contains prohibited game, user, credential, or signing data"
    fi

    extract_root="$(mktemp -d /tmp/brawlerpad-ipa-audit.XXXXXX)"
    trap 'rm -rf "$extract_root"' EXIT
    unzip -q "$IPA" -d "$extract_root"
    app_count="$(find "$extract_root/Payload" -mindepth 1 -maxdepth 1 -type d -name '*.app' | wc -l | tr -d ' ')"
    [ "$app_count" -eq 1 ] || fail "IPA must contain exactly one app"
    audit_app "$extract_root/Payload/BrawlerPad.app"
    test "$(shasum -a 256 "$APP/BrawlerPad" | awk '{print $1}')" = \
        "$(shasum -a 256 "$extract_root/Payload/BrawlerPad.app/BrawlerPad" | awk '{print $1}')" ||
        fail "packaged executable differs from audited input"
fi

echo "iOS package audit passed: $APP${IPA:+ and $IPA}"
