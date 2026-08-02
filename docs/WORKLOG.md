# Worklog

## 2026-08-02 — research and baseline start

- Read the complete end-to-end objective before acting.
- Audited an empty parent repository containing a local HarkinianPad checkout
  and user ROM under `ref/`.
- Added immediate ignore rules for ROMs, extracted archives, packages, signing
  material, credentials, build products, and all local reference checkouts.
- Inspected HarkinianPad commit `1197472`, including its platform feasibility
  research, maintained iOS patches, touch editor, lifecycle changes, build
  scripts, and package audit.
- Cloned BattleShip recursively at `4e7f1dc9`, including decomp `3f8d0df1`,
  libultraship `fdea8321`, and Torch `8060a909`; disabled every push URL.
- Confirmed the supplied ROM exactly matches BattleShip's supported US hash.
- Inventoried BattleShip architecture, licenses, CMake target split, Apple
  Metal path, Android app, in-process Torch runner, AArch64 coroutine code,
  SDL virtual touch controller, audio, save paths, and mobile exclusions.
- Queried current BattleShip issues, pull requests, branches, and public forks;
  found no existing iOS/iPadOS port to adopt.
- Installed missing documented Homebrew dependencies after the first configure
  stopped at `Could NOT find GLEW`.
- Reconfigured and completed the untouched upstream Release build. The first
  attempt stopped at step 768 because `derive_stage_assets.py` imports Pillow,
  a host dependency absent from upstream `BUILDING.md`; installed Pillow into
  CMake's selected Homebrew Python and resumed successfully.
- Verified the output is native arm64, ad-hoc signed, and linked to Metal,
  QuartzCore, AVFoundation, CoreAudio, SDL, and the documented Homebrew libs.
- Launched the game for more than 45 seconds. Logs prove Metal backend
  selection, Torch extraction, 32 kHz audio initialization, a first non-zero
  synthesized sample, continuous frame progression, many fighter/stage scenes,
  controller mapping initialization, and save creation. The unbundled SDL
  process is not addressable by the macOS accessibility inventory, so visible
  frame and manual-input inspection remained for the `.app` baseline.
- Ran BattleShip's `NON_PORTABLE=ON` macOS packaging workflow. The first run
  compiled successfully and then stopped because upstream does not declare its
  `dylibbundler` dependency. Installed it and produced a 35,372 KiB arm64 app
  and 12,788 KiB UDZO DMG.
- Audited the app and DMG: no ROM, playable `BattleShip.o2r`, save, credentials,
  signing profiles, certificates, or private keys are present; the app is
  ad-hoc signed and passes strict verification. Embedded absolute source/build
  paths remain, so this package is correctly recorded as an audit failure for
  release purposes.
- Inspected the packaged app visibly. The Metal window rendered first-run
  setup, Nintendo 64/opening scenes, How to Play, character select, and active
  gameplay. Normal window close exited the main loop, destroyed the coroutine,
  and returned from shutdown; relaunch succeeded.
- Added a ROM-free replay generator for deterministic end-to-end testing. Its
  one-minute human-Mario versus level-9-CPU-Fox match exercised combat, updated
  the save, and passed BattleShip's complete 3,600-frame rolling checksum
  (`0xC47FF9C5`).
- Reproduced an upstream results regression: the game enters scene 24, creates
  both results fighters, and keeps advancing without a crash, but the Metal
  window remains solid white and cannot yet return to menus. The Metal
  screenshot hook also logs success while writing no files, so it cannot be
  used as visual proof.
- Wrote the initial architecture, plan, status, build, test, legal, dependency,
  and repository-safety documentation.
