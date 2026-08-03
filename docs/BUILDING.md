# Building

## Requirements

- Apple Silicon Mac
- Xcode and command-line tools
- Git, CMake 3.24+, Ninja, Python 3.11 with Pillow
- Homebrew packages: `glew libzip tinyxml2 nlohmann-json spdlog fmt
  dylibbundler`
- A legally obtained supported US SSB64 ROM matching the hash below

The current toolchain proof used Xcode 26.6, AppleClang 21, macOS 26.5, CMake
3.27.1, and Ninja 1.13.2.

## Fetch pinned reference sources

```sh
scripts/clone-sources.sh
```

This clones BattleShip recursively and the HarkinianPad reference into ignored
`ref/`, checks out exact commits, disables push URLs, and applies the ordered
BrawlerPad patch series idempotently. The series contains the PORT-only VS
results transition-camera fix, the libultraship iOS runtime changes, and the
BattleShip native Apple-mobile target and first-run flow.

## Build the untouched BattleShip macOS baseline

```sh
brew install cmake ninja python@3.11 glew libzip tinyxml2 nlohmann-json spdlog fmt dylibbundler
"$(brew --prefix python@3.11)/bin/python3.11" -m pip install --user Pillow
scripts/build-macos-baseline.sh /absolute/path/to/your/rom.n64
```

Accepted US hashes:

- SHA-1: `e2929e10fccc0aa84e5776227e798abc07cedabf`
- MD5: `f7c52568a31aadf26e14dc2b6416b2ed`

The build output lives only under ignored `ref/BattleShip/build-us`. Run from
that directory because the upstream executable locates its resources relative
to the working directory:

```sh
cd ref/BattleShip/build-us
./BattleShip
```

This is a research baseline, not the final BrawlerPad application.

Pillow is required by BattleShip's `tools/derive_stage_assets.py`, although it
is not currently listed in upstream `BUILDING.md`. The BrawlerPad script pins
CMake to the checked Python executable so configure and asset generation do not
silently select different Python installations.

## Package the upstream macOS baseline

After the baseline build and extraction have completed:

```sh
cd ref/BattleShip
CI=1 JOBS="$(sysctl -n hw.logicalcpu)" ./scripts/package-macos.sh
```

This produces ignored research artifacts at `ref/BattleShip/dist/BattleShip.app`
and `ref/BattleShip/dist/BattleShip.dmg`. `dylibbundler` is an undeclared
upstream packaging dependency; without it the script stops after compiling the
application.

The 2026-08-02 package proof produced a 35,372 KiB arm64 Metal `.app` and a
12,788 KiB UDZO DMG. The app is ad-hoc signed and passes
`codesign --verify --deep --strict`. It contains no ROM, extracted playable
archive, save, credential, profile, certificate, or private key. It is not a
release candidate: binary strings still expose the maintainer's absolute
source/build path, which the final package audit must reject.

## Build the branded BrawlerPad macOS package

```sh
scripts/build-macos-app.sh
```

This builds, packages, and audits ignored release artifacts at
`ref/BattleShip/dist/BrawlerPad.app` and
`ref/BattleShip/dist/BrawlerPad.dmg`. The app uses bundle identifier
`com.brawlerpad.app.macos`, stores generated data under
`~/Library/Application Support/BrawlerPad`, and names its generated archive
and configuration `BrawlerPad.o2r` and `BrawlerPad.cfg.json`. It is ad-hoc
signed and contains the rights/dependency manifests and discovered notices.
The branded release link uses deterministic Objective-C stubs, strips source
symbols, and replaces the post-rewrite Mach-O UUID with a content-derived UUID
before signing. macOS dyld requires that UUID, so unlike the unsigned device
proof it must not be removed. The audit rejects a missing UUID or residual OSO
source paths, verifies the DMG checksum, mounts it read-only, and audits its
contained app.

Across independent checkout roots, the normalized unsigned executable payload
must be byte-identical and the ad-hoc signed executables must have the same
UUID and Apple CDHash. Opaque bytes outside the CodeDirectory in local ad-hoc
signatures and filesystem metadata in `hdiutil` DMGs are not stable; raw signed
executable and DMG SHA-256 values are therefore recorded as artifact evidence,
not cross-checkout reproducibility anchors.

Run the audit independently with:

```sh
scripts/audit-macos-package.sh \
  ref/BattleShip/dist/BrawlerPad.app \
  ref/BattleShip/dist/BrawlerPad.dmg
```

## Generate the deterministic baseline replay

The replay fixture is generated outside Git and contains only synthetic input
and match metadata:

```sh
cc -std=c11 -Wall -Wextra -Werror tools/generate-baseline-replay.c \
  -o /tmp/generate-brawlerpad-replay
/tmp/generate-brawlerpad-replay /tmp/brawlerpad-baseline.replay
```

It creates a one-minute Dream Land time match (human Mario with neutral saved
input versus level-9 CPU Fox). BattleShip's verifier must report 3,600 frames
and checksum `0xC47FF9C5`.

## Build the iPhone/iPad simulator app

The same arm64 simulator app supports device families 1 (iPhone) and 2 (iPad):

```sh
scripts/build-ios-simulator.sh
```

The script configures CMake's Xcode generator with the pinned iOS toolchain,
builds an unsigned Release app, verifies the Files/controller plist features,
and rejects any bundled ROM or playable generated game archive. Its output is:

```text
ref/BattleShip/build-ios-sim/Release-iphonesimulator/BrawlerPad.app
```

Install and launch on a booted simulator without copying game data into the
app bundle:

```sh
xcrun simctl install booted \
  ref/BattleShip/build-ios-sim/Release-iphonesimulator/BrawlerPad.app
xcrun simctl launch --console-pty booted com.brawlerpad.app
```

On first run, choose a supported ROM through Files. BrawlerPad validates an
app-owned temporary copy, runs linked Torch in-process, installs the generated
archive under Application Support, deletes the temporary copy, and launches
the native game. A no-change Release rebuild takes approximately 13 seconds on
the current proof machine and recompiles no source files.

Device signing remains optional and is not part of this simulator command.
Unsigned device compilation and IPA packaging use separate commands below and
must not embed a maintainer certificate or provisioning profile.

## Build and package the unsigned iPhoneOS proof

Build a native arm64 app for a generic physical iOS destination without a
signing identity:

```sh
scripts/build-ios-device.sh
```

The output is
`ref/BattleShip/build-ios-device/Release-iphoneos/BrawlerPad.app`. The script
verifies the Mach-O platform is iPhoneOS (not Simulator), the only architecture
is arm64, required Files/controller plist keys are present, no signing material
is attached, and the full package audit passes.

Create the ignored unsigned proof IPA:

```sh
scripts/package-ios.sh
```

The default output is
`artifacts/BrawlerPad-0.1.0-preview.1-unsigned.ipa`. Packaging copies the app,
rights and dependency manifests, and license/notice files discovered in both
the pinned source tree and the selected build's fetched dependencies. It
normalizes archive timestamps and ordering, then audits the app and IPA. The
same audited input must produce identical IPA bytes on repeated packaging.
The iOS compile maps checkout/build prefixes to stable labels and the renderer
shader archive uses sorted entries and fixed timestamps. The unsigned device
proof link omits its otherwise-random Mach-O UUID; simulator builds retain the
required `LC_UUID`. Together these make the device executable and IPA
reproducible across different checkout roots on the same pinned toolchain, at
the cost of UUID-based crash-symbol matching for the unsigned device proof.

Run either audit explicitly with:

```sh
scripts/audit-ios-package.sh /absolute/path/to/BrawlerPad.app
scripts/audit-ios-package.sh /absolute/path/to/BrawlerPad.app \
  /absolute/path/to/BrawlerPad.ipa
```

The unsigned IPA is a build and distribution-boundary proof, not an artifact
that installs on a standard device. Its deterministic executable intentionally
has no `LC_UUID`, and iOS rejects that Mach-O even if it is subsequently signed.

For a local physical-device build, retain the runtime UUID:

```sh
BRAWLERPAD_REPRODUCIBLE_DEVICE_LINK=OFF scripts/build-ios-device.sh
```

Audit that output before adding your own development provisioning profile and
signature outside the repository. Install it in place to preserve the existing
app data container; do not uninstall unless a clean-container test is intended.

Never place a ROM, playable `BrawlerPad.o2r`, save, certificate, or profile in
an app source/resource group. `f3d.o2r` is the sole allowed O2R: the audit
requires it to be at most 1 MiB and contain only known renderer-shader paths and
extensions. Run `scripts/check-repo-safety.sh` before every commit or package
operation.
