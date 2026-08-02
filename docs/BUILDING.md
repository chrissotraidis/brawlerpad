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
`ref/`, checks out exact commits, and disables push URLs.

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

## Planned Apple builds

The planned native targets will use CMake's Xcode generator. Exact commands
will be added only after the maintained BattleShip patches exist and configure
successfully. Device signing will always be optional; unsigned compilation and
IPA packaging must not embed a maintainer certificate or provisioning profile.

Never place a ROM, `BattleShip.o2r`, save, certificate, or profile in an app
source/resource group. Run `scripts/check-repo-safety.sh` before every commit or
package operation.
