# Status

Updated: 2026-08-02.

## Current milestone

Milestone 1 — reproduce BattleShip on Apple Silicon macOS.

## Verified

- Repository began with no commits and only ignored local reference material.
- ROM/game-data, build, package, credential, and signing exclusions are active.
- The local ROM is the supported US `NALE` revision, 16 MiB, with SHA-1
  `e2929e10fccc0aa84e5776227e798abc07cedabf` and MD5
  `f7c52568a31aadf26e14dc2b6416b2ed`.
- BattleShip and all three submodules were cloned recursively at the exact pins
  in `DEPENDENCIES.md`; push URLs are disabled.
- HarkinianPad was inspected at `1197472`; its current iPhone/iPad simulator,
  physical-device, lifecycle, Files, touch-layout, and IPA workflows are
  relevant reference evidence.
- Xcode 26.6, AppleClang, arm64 macOS 26.5, CMake, Ninja, Python, and required
  Homebrew libraries are available.
- BattleShip's Release configure completed successfully after installing its
  documented GLEW and library dependencies.

## In progress

- First full upstream Release build, including Torch asset extraction.
- Native launch/runtime evidence for rendering, audio, input, saves, a complete
  match, shutdown, and relaunch.

## Not yet claimed

- A BrawlerPad macOS app bundle.
- Any iOS/iPadOS compile, install, launch, gameplay, or package result.
- Device testing, touch gameplay, lifecycle recovery, unsigned IPA, or clean
  checkout reproducibility.

These remain explicitly unverified until their entries in `TESTING.md` have
captured commands and observable results.

