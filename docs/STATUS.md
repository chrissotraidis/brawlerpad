# Status

Updated: 2026-08-07.

The public-source-release README, screenshots, rights boundary, contribution
guide, security policy, and binary release checklist were refreshed on this
date. This documentation update does not change the runtime evidence below;
the listed hardware-only acceptance boundaries remain explicit until re-run.

## Current milestone

Milestone 7/7 — native iPhoneOS compilation, strict package auditing, a
reproducible ROM-free unsigned IPA, and development-signed physical iPhone/iPad
installation and launch are proven. Runtime acceptance remains partial: archive,
save, SDL audio, floating touch, iPhone frame pacing, and queue stability pass.
Hands-on long-play audio, multitouch/reset feel, rotation, physical controllers,
and real lifecycle/audio-route changes stay explicitly open.

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
- iOS UI scaling now selects a 1x compact-phone or 2x tablet base from both
  usable display size and form-factor aspect ratio, avoiding Retina-pixel
  misclassification on iPhone. Phone Settings uses a full-width content pane,
  compact section picker, enlarged scrollbar, and vertical finger-drag
  scrolling; iPad retains its persistent sidebar. The iPad first-run window
  also scales its explicit widths, and visual reinspection proved readable
  text and unclipped controls.
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
- A later clean-import iPad pass used the same current universal Release app
  and reached 1P Game/Classic with touch alone. Analog moved the P1 hand to
  Donkey Kong, A selected the fighter, Start launched the Link match, and
  analog/A/B/Z plus Start were visibly exercised in live combat and the 1P
  pause screen. The temporary picker copy was empty after extraction.
- After background, terminate, relaunch, and an in-place reinstall, iPad
  skipped first-run, remounted its extracted archive, and restored the manual
  touch-visibility setting. The migrated 3,036-byte save remained byte-identical
  at SHA-256
  `0bbc8eb0f63a4aaad44e8d71cf6c4315b13623f0fe3f86b9c2741e70e3730330`
  with signature `0x29A` and an exact stored/computed checksum match; the
  migrated config retained SHA-256
  `b2caedeec889c300f45c0b69f83f0ce405561ff418027f202908946f3fa7416a`.
- A screenshot-led comparison against HarkinianPad exposed collisions in the
  first defaults. The version-2 grip layout now keeps D-pad, stick, A/B/Z,
  C-button, and shoulder groups separate in both inspected iPad orientations,
  uses an uncluttered yellow C diamond, and labels D-pad/C directions
  explicitly for accessibility. A Release simulator rebuild passed.
- User reinspection found tablet V2 still visually compressed and more
  obstructive than HarkinianPad. Tablet V3 adopts HarkinianPad's later
  physical-iPad right rail: Start/R/L stack above the separately spaced Z,
  A/B, and C groups; the D-pad and analog retain distinct left lanes. A
  dedicated tall-window profile prevents landscape geometry from collapsing
  during portrait/rotation transitions, and reduced idle fill/border alpha
  leaves more of the game readable. Fresh landscape and portrait captures on
  the sole iPad showed all 15 named buttons plus analog with visible gaps.
- A second user reinspection caught Tablet V3's remaining weakness: placing Z
  in the same right-side mass still made the shoulder, face, and C controls
  read as one crowded overlay. Tablet V4 restores HarkinianPad's accepted
  physical-iPad split, with Z between the left D-pad and stick, independent
  A/B and C zones on the right, and an upper shoulder rail no longer derived
  from the face stack. A fresh sole-simulator capture showed the groups
  mutually separated; opening the native menu removed the gameplay overlay
  and closing it restored every named target.
- The revised iPad controls traversed title, Mode Select, one-minute VS setup,
  Kirby/CPU Donkey Kong character selection, Peach's Castle stage selection,
  live play, visible `DK WINS!` results, and return to character select. Analog,
  A, B, Z, L, R, C-up, D-pad, and Start were exercised. The post-match save has
  signature `0x29A`, matching stored/computed checksum `8892894`, Castle and
  Kirby/Donkey Kong records, `vs_total_battles: 1`, and SHA-256
  `3848e4005b6fe70a3c4dea54c5d46ac95e37a1d1be574a58fd0683a1b5c69d9c`.
- An isolated `com.brawlerpad.app.negative` install on the sole iPad proved
  the missing-resource path and invalid-ROM path without touching the proven
  save container. With no archive it showed the branded first-run guidance;
  selecting a deliberate 44-byte `.z64` reported the exact 16 MiB size
  requirement, created no archive, retained the source document, and removed
  both the Files-picker copy and BrawlerPad's staged import. This runtime test
  exposed and fixed the picker Inbox cleanup path for rejected inputs.
- Installing the Tablet V4 Release build in place preserved the current
  3,036-byte save at SHA-256
  `35372f0f42334b27f192faf097a85205a5468ea1d7431ff9e7a330895a662c6b`
  and configuration at SHA-256
  `b2caedeec889c300f45c0b69f83f0ce405561ff418027f202908946f3fa7416a`.
  The save retained signature `0x29A`, exact stored/computed checksum
  `8895910`, Castle, and `vs_total_battles: 1`. A fresh generic-iPhoneOS
  arm64 build and recursive app/IPA audits passed; executable SHA-256 is
  `d21407f6d7b0f3ece8c3ec91955203446967f91cd18b8ab3e92a065aa0cbb8a9`
  and deterministic unsigned IPA SHA-256 is
  `ac1820954dc1aa2088aaa80d0bfe9f80d4ae784e666dd7dbdaac652bf538604c`.
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
  V4 separated the targets, and the follow-up V5 pass replaced its crowded
  right rail with HarkinianPad's physically accepted iPhone geometry. L and Z
  occupy the left grip; Start/R and compact C/A/B groups occupy distinct right
  zones. The versioned profile prevents old coordinates from masking the fix.
- Very quick UIKit taps and stick flicks could previously fall entirely between
  adjacent game polls. Touch buttons and final stick values now retain a
  minimum 50 ms signal pulse, while cancellation paths still neutralize input
  immediately. Service coroutines are also resumed in stable current-priority
  order each round, ensuring the controller publishes input before game logic.
- A clean, diagnostic-free iPhone touch run traversed title, Mode Select,
  character select, stage select, a one-minute Link-versus-CPU-Pikachu match at
  Peach's Castle, pause, visible `PIKACHU WINS!` results, and return to
  character select. Stick, A, B, Z, L, R, C-up, and D-up were exercised during
  live play; Training pause navigation and EXIT were also verified. The V4
  controls remained mutually non-overlapping across every inspected scene.
- The port controller callback now samples and publishes synchronously at the
  task-update boundary, avoiding a cooperative-coroutine race that could defer
  a short Start/face edge past the requesting title or menu scene. In the sole
  booted iPhone, short Start reached Mode Select, D-down selected VS, A entered,
  and B returned on the V5 layout.
- Content-level persistence is proven on iPhone Simulator: after a completed
  match, the 3,036-byte save retained signature `0x29A`, a valid checksum,
  `vs_total_battles: 1`, and the expected fighter/stage records across process
  termination, relaunch, and repeated in-place installs. The 36,104-byte
  branded config retained stable SHA-256
  `253913ca78ae94c27767a2a183079f44384db6e5fdde187f81d5abf2510ab65d`.
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
- The current picker-cleanup device executable SHA-256 is
  `906fa018fc237a047cbc811f8f3346aa16f6575aa1f53d89847f3100e2b89289`;
  the audited unsigned IPA is
  `94672dc88e1171cda299e9a6aedc9ee0698c3c8b3a023862f314981857aa687f`,
  and `f3d.o2r` retained SHA-256
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.
- The device build now refuses an existing non-iOS CMake cache before
  configuration. The pre-V4 clean-checkout binary/IPA replay was byte-identical;
  ordered BattleShip patches through 0016 and decomp patches through 0002 were
  replayed exactly at the pinned upstream commits, reproducing the latest
  production sources byte-for-byte. The fresh device build and package audit
  passed; a second packaging pass was byte-identical.
- The V5/input-boundary macOS package rebuilt and passed app, signature, and
  mounted-DMG audits. Its executable SHA-256 is
  `1a9b6335313e1a5411385b1daaf33a14f2fefca8d2311cd0e5d0befc93cc7c82`,
  Mach-O UUID is `EBBCC693-5DFF-32FE-9202-D4E011F64692`, Apple CDHash is
  `c970aca0dfd80dfe3418ef23ca77090d568de418`, and DMG SHA-256 is
  `17d95096d3794510267e8029dc2f9f8555d72e6edd1234dc32663d80219d1fe8`.
  The content-derived normalization pipeline retains its independent-checkout
  proof; raw ad-hoc signature and DMG-container bytes remain non-stable
  packaging metadata.
- A final remote-clone replay started at commit `d8ef0f8`, fetched the exact
  BattleShip, decomp, libultraship, Torch, and HarkinianPad pins, and replayed
  every maintained patch. The arm64 macOS app and DMG passed signature,
  checksum, mount, and contained-app audits; the executable retained UUID
  `EBBCC693-5DFF-32FE-9202-D4E011F64692`, and `f3d.o2r` retained SHA-256
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.
- That replay exposed a fresh-cache Simulator linker defect: dependency
  discovery selected iPhoneOS `libz`/`libbz2` before the downstream iOS
  toolchain populated its Simulator sysroot. Both mobile build scripts now pin
  CMake to the exact SDK returned by `xcrun` before dependency discovery. A new
  clean cache then resolved only Simulator libraries and produced a validated
  arm64 iOS Simulator app; executable SHA-256 is
  `c7d645285f1417036365adc9b2ad9b2d9768f3d6d28d1bd84876677b503d0830`.
- The same checkout produced and recursively audited a generic arm64 iPhoneOS
  app with platform IOS, minimum iOS 17.0, and executable SHA-256
  `c01aa9f9af0e07ae19114af1efdecdd256ebf227352667eb328c1bba7564f7ea`.
  Two packages from that exact app were byte-identical at IPA SHA-256
  `e81a061c7034ae97d5e431f195b141246bd02d7733ffbe7ad1de0dbcdda2400c`.
  The iPad Pro 13-inch (M5) remained the machine's sole booted simulator.
- The current development-signed executable SHA-256
  `c721c192f3d5ef7b8c996e13e140c11fda785e887146d6a2a4cedc677b00415f`
  passed package and deep-signature verification and installed in place on the
  physical iPad Pro and wired iPhone 14. The iPhone launched normally; its
  final 20-second log primed 4,968 samples against a 4,528-sample startup
  target, reported zero post-start underruns, held roughly 1,760–3,900 queued
  samples, and settled at about 16.7 ms per frame. The iPad install completed,
  but its locked screen denied the automated launch request.
- The current control profile removes Smash 64's unused D-pad and four-way C
  diamond, consolidates jump into one large target, reserves the left 47
  percent for a per-contact floating analog stick, and moves all actions to the
  right so Z/A/B/Jump combinations remain available while moving. A red Reset
  pill appears only in the game's paused battle state and sends A+B+Z+R as one
  virtual-controller chord.

## In progress

- Repeat the proven synthetic lifecycle/audio dispatch with audible,
  OS-generated interruptions and headphone/Bluetooth route changes on physical
  hardware.
- Complete hands-on simultaneous-multitouch, floating-stick, rotation, and
  safe-area acceptance on the installed physical iPhone and iPad builds.
- Confirm the queue-stable build by ear through a long match and exercise the
  pause-only Reset action. Physical-controller gameplay remains pending;
  Simulator exposes a forwarded MFi `Gamepad`, but the Mac's paired 8BitDo and
  Xbox controllers are currently powered off/disconnected.

## Not yet claimed

- Complete physical-device usability acceptance or the full lifecycle/audio
  interruption matrix.

These remain explicitly unverified until their entries in `TESTING.md` have
captured commands and observable results.
