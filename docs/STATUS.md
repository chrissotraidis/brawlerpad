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
- BattleShip's untouched Release build completed successfully after installing
  its documented libraries and the undocumented Pillow host dependency.
- The resulting executable is a native arm64 Mach-O and initializes the Metal
  backend, SDL controller mappings, resource manager, AArch64 coroutine game
  loop, and 32 kHz audio.
- Torch validated and extracted the local ROM to a 12,114,884-byte
  `BattleShip.o2r` under ignored build storage.
- A 45+ second runtime reached continuous frames, multiple fighter/stage
  attract scenes, non-zero synthesized audio, and created a 3,036-byte save.
- BattleShip's packaging workflow produced a 35,372 KiB arm64 Metal `.app` and
  a 12,788 KiB ROM-free DMG. The ad-hoc app passes strict deep code-signature
  verification and contains no playable archive or user/private material.
- The packaged app was inspected visibly through the macOS accessibility
  surface: first-run setup, Nintendo 64/opening scenes, How to Play, character
  select, and live Dream Land combat rendered correctly in its Metal window.
- A ROM-free synthetic replay completed a one-minute Mario-versus-level-9-Fox
  match. BattleShip verified all 3,600 frames with rolling checksum
  `0xC47FF9C5`, entered the VS results scene, continued frames, and exited
  cleanly at the requested 5,000-frame bound.
- A BrawlerPad patch fixes the upstream Metal white-results regression. Split
  controls proved the persistent transition camera—not replay state, results
  data, framebuffer photo mesh, or ordinary results cameras—covered the scene.
  Retiring that camera with its finished wipe restores the populated results
  UI while retaining the original transition. The production-shaped patched
  run again passed checksum verification and clean shutdown.
- The save was updated by gameplay; normal window close destroyed the game
  coroutine cleanly, and relaunch returned to the app's normal startup flow.

## In progress

- Remove absolute developer/build paths from packaged binaries.
- Begin the mobile-safe reusable core after the results baseline is understood.
- Audible-output confirmation and physical-controller testing remain pending;
  no controller is currently attached.

## Not yet claimed

- A BrawlerPad macOS app bundle.
- Any iOS/iPadOS compile, install, launch, gameplay, or package result.
- Device testing, touch gameplay, lifecycle recovery, unsigned IPA, or clean
  checkout reproducibility.

These remain explicitly unverified until their entries in `TESTING.md` have
captured commands and observable results.
