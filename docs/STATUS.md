# Status

Updated: 2026-08-02.

## Current milestone

Milestone 7/7 — native iPhoneOS compilation, strict package auditing, and a
reproducible ROM-free unsigned IPA are proven. Runtime acceptance is still
partial: reproducible branded macOS app payload and audited DMG packaging are
proven, while the remaining touch gameplay, hardware, and lifecycle/audio work
stays explicitly open.

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
- The branded packaging workflow produced a 30,772 KiB arm64
  `BrawlerPad.app` and 12,096 KiB DMG with bundle identifier
  `com.brawlerpad.app.macos`, BrawlerPad runtime/storage/archive/config names,
  portable load commands, deep ad-hoc signing, rights/notices, and no ROM,
  playable archive, save, credentials, or personal paths. The DMG checksum and
  its read-only-mounted app pass the same audit. A fresh visible launch showed
  a fully branded Metal first-run wizard.
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
- A later branded simulator replay caught and fixed a missing-`LC_UUID` launch
  regression by restricting deterministic no-UUID linking to device builds.
  The rebuilt simulator executable retains UUID
  `58B7AF12-FC8A-3BD0-AA6F-1783A8A3AF1F`, imported the supported ROM through
  Files, produced a 12,114,884-byte `BrawlerPad.o2r` in 5 seconds, removed its
  temporary import, and visibly booted Metal gameplay.
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
- A UIKit multi-touch overlay now supplies analog, A/B/Z/L/R/Start, four
  C-directions, and optional D-pad input through an SDL virtual game controller
  rather than game-specific simulation hooks. It is pinned to ControlDeck port
  1 even when Simulator enumerates a host-forwarded gamepad first.
- Touch controls have adjustable opacity, automatic physical-controller hide,
  safe-area-aware phone/tablet defaults, separate persisted layouts, and an
  editor for move, 70–150% resize, hide/show, reset, and save. Background/menu
  transitions cancel held inputs.
- On the sole booted iPad simulator, touch Start exited attract gameplay and
  skipped the intro, D-pad selected VS Mode, A entered VS Start and then the
  character-select screen, and B returned to the parent menu. The editor's
  resize, hide, reset, and Done paths were visibly exercised. A forwarded
  `Gamepad` also proved default touch auto-hide; disabling that option for the
  test showed both inputs can remain routed to player 1.
- A screenshot-led comparison against HarkinianPad exposed collisions in the
  first defaults. The version-2 grip layout now keeps D-pad, stick, A/B/Z,
  C-button, and shoulder groups separate in both inspected iPad orientations,
  uses an uncluttered yellow C diamond, and labels D-pad/C directions
  explicitly for accessibility. A Release simulator rebuild passed.
- iOS lifecycle handling now gates simulation/render work while backgrounded,
  pauses and clears queued SDL audio, flushes window/config state safely, and
  resumes those paths on foreground events. Three visible iPad Home/resume
  cycles preserved each running PID, updated the config file on background,
  restored Metal and touch presentation, and left zero recent crash reports.
- The iPhone 17 Pro simulator was brought up only after shutting down the iPad.
  Its first V2 screenshot exposed C-down/face-button and menu/R collisions.
  Phone V3 separates the C diamond from A/B/Z, moves the gameplay menu to a
  dedicated top-center slot, retains every labeled control in the accessibility
  tree, and passed a Release rebuild plus visible Metal resume. One Home/resume
  cycle preserved PID `18400`, flushed config state, and produced no crash.
- A later active-match audit exposed a remaining V3 D-pad intersection. Phone
  V4 adopts HarkinianPad's Start/R-over-L right rail, increases D-pad/C spacing,
  anchors the stick and face triangle to safe-area edges, and versions the
  phone profile so old coordinates cannot mask it. The rebuilt app showed no
  visible intersections in either landscape side, Start caused a visible game
  transition, and menu open/close hid and restored the complete overlay.
- A clean iPhoneOS CMake/Xcode configuration built an unsigned arm64-only
  `BrawlerPad.app` for generic iOS. `vtool` identifies platform IOS, the bundle
  identifier is `com.brawlerpad.app`, and required Files/controller plist keys
  are enabled.
- The device app passes a strict recursive audit for ROM/playable O2R, saves,
  logs, configs, credentials, personal paths, Simulator products, profiles,
  and signing material. Its sole O2R is a bounded, entry-validated 21 KiB
  Fast3D shader archive.
- Two packages from the same audited app produced identical bytes. The unsigned
  IPA embeds 28 actual license/notice
  files plus the rights/dependency manifests, and passed ZIP traversal,
  extraction, executable-identity, and recursive app audits. Injected ROM,
  signature, and personal-path fixtures were all rejected.
- The path scanner's early-pipeline behavior was adversarially tested and
  fixed. Its corrected form rejected the prior binary; iOS compiler prefix
  maps now replace checkout/build roots with stable labels, and the rebuilt
  app passes the corrected recursive scan without exceptions.
- Before V4, a fresh repository clone fetched all exact upstream pins, replayed
  the then-current ordered patches, and produced a clean audited iPhoneOS build
  without a ROM.
  Stable path mapping, deterministic shader archiving, and a reproducible
  device link made its executable, shader archive, and final IPA byte-identical
  to independently produced artifacts from the primary checkout.
- The current V4 branded device executable SHA-256 is
  `9bab6f8511f8eb051d301d9ad3f4598f5a3e91d59b1ea50bf0848843876506aa`;
  the audited unsigned IPA is
  `148e0b89322205477667419aeb66e74d9a451cf7620eedb4a14adf944bda7505`,
  and `f3d.o2r` retained SHA-256
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.
- The device build now refuses an existing non-iOS CMake cache before
  configuration. The pre-V4 clean-checkout binary/IPA replay was byte-identical;
  ordered patch 0012 was replayed exactly in a fresh source tree, while a
  second clean-checkout V4 device compile remains unclaimed.
- Independent macOS checkout roots produced identical normalized executable
  payload SHA-256
  `ef947ea24de6c168f145f83f9bdad69e5732e4bf0be5f7482eae408f5bc3e831`,
  Mach-O UUID `73622AD5-E270-3C62-A690-8F41D70D0B02`, Apple CDHash
  `07b73399fc24b9705766dc0a17d6cc42ec7b477d`, shader archive, and every
  non-signature bundle file. A smoke launch caught and prevented removal of
  the UUID required by macOS dyld. Raw ad-hoc signature and DMG-container bytes
  remain intentionally documented as non-stable packaging metadata.

## In progress

- Extend lifecycle stress and verify real audio interruptions and route changes
  on physical hardware.
- Complete touch stage-select, sustained analog active-match input, pause,
  results, Classic, and simultaneous-multitouch acceptance; repeat on iPhone
  hardware.
- Audible-output confirmation and physical-controller testing remain pending;
  no controller is currently attached.

## Not yet claimed

- Physical device testing, complete touch gameplay, or the full lifecycle/audio
  interruption matrix.

These remain explicitly unverified until their entries in `TESTING.md` have
captured commands and observable results.
