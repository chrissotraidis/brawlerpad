# Status

Updated: 2026-08-02.

## Current milestone

Milestone 4/5 — native iPhone and iPad simulator application plus ROM import
and on-device asset extraction. Phone and tablet runtime proof is complete;
touch and lifecycle work are next.

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
- A native arm64 `BrawlerPad.app` now builds for the iOS simulator with an
  iOS 17.0 deployment target, Metal/SDL presentation, device families 1 and 2,
  linked Torch, and bundle identifier `com.brawlerpad.app`.
- A clean iPhone 17 Pro simulator install launches into a visible first-run UI.
  Its Files picker exposes BrawlerPad Documents and accepts `.z64`, `.n64`, or
  `.v64` input without embedding game data in the app.
- The first-run path copied the selected ROM into app-controlled temporary
  storage, normalized and validated exact SHA-1 `e2929e10...`, ran Torch
  in-process in 66.7 seconds, installed a 12,114,884-byte archive under
  Application Support, deleted all picker/import copies, and left the original
  ROM unchanged.
- After extraction, the iPhone simulator initialized 32 kHz SDL audio,
  registered controller input, mounted the generated archive, and visibly
  rendered the native game through Metal. The tested attract sequence reached
  a fully rendered Yoshi scene.
- The finished simulator bundle is 9.7 MiB, arm64, has Files sharing/open-in-
  place and indirect controller input enabled, and contains no ROM or playable
  archive. A no-change Release rebuild succeeds in 13 seconds with no source
  recompilation.
- A clean iPad Pro 13-inch (M5) simulator replay completed the same Files
  selection, exact ROM validation, linked extraction, temporary-copy cleanup,
  archive mount, SDL audio/controller initialization, and visible native Metal
  boot. The equal-size generated ZIP archive is not byte-deterministic across
  runs, so its per-run hash is recorded as evidence rather than a build input.
- iOS UI scaling now selects a 1x compact-phone or 2x tablet base from SDL's
  usable display bounds. The iPad first-run window also scales its explicit
  widths, and visual reinspection proved readable text and unclipped controls.

## In progress

- Add and tune the HarkinianPad-derived customizable touch controller.
- Implement and verify iOS lifecycle/audio interruption behavior.
- Remove absolute developer/build paths from packaged binaries.
- Audible-output confirmation and physical-controller testing remain pending;
  no controller is currently attached.

## Not yet claimed

- A BrawlerPad macOS app bundle.
- Physical device testing, touch gameplay, lifecycle recovery, unsigned IPA,
  or clean-checkout reproducibility.

These remain explicitly unverified until their entries in `TESTING.md` have
captured commands and observable results.
