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
and rejects any bundled ROM or playable `BattleShip.o2r`. Its output is:

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
Unsigned device compilation and IPA packaging must not embed a maintainer
certificate or provisioning profile.

Never place a ROM, `BattleShip.o2r`, save, certificate, or profile in an app
source/resource group. Run `scripts/check-repo-safety.sh` before every commit or
package operation.
