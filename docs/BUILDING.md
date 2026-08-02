# Building

## Requirements

- Apple Silicon Mac
- Xcode and command-line tools
- Git, CMake 3.24+, Ninja, Python 3
- Homebrew packages: `glew libzip tinyxml2 nlohmann-json spdlog fmt`
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
brew install cmake ninja glew libzip tinyxml2 nlohmann-json spdlog fmt
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

## Planned Apple builds

The planned native targets will use CMake's Xcode generator. Exact commands
will be added only after the maintained BattleShip patches exist and configure
successfully. Device signing will always be optional; unsigned compilation and
IPA packaging must not embed a maintainer certificate or provisioning profile.

Never place a ROM, `BattleShip.o2r`, save, certificate, or profile in an app
source/resource group. Run `scripts/check-repo-safety.sh` before every commit or
package operation.

