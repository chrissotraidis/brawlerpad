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
- Added results-scene tick and transition split controls in the ignored
  research checkout. Disabling both transition objects produced a correct
  populated results screen. Keeping only camera GObj `0x20000002` reproduced
  the solid-white failure, proving the persistent empty transition camera was
  the cause rather than replay metadata, result logic, or framebuffer capture.
- Added a PORT-only decomp patch that ejects the paired transition camera when
  the wipe mesh animation finishes. Removed every diagnostic control, rebuilt,
  and reran with the normal transition enabled. The original wipe is retained,
  the results UI renders correctly, the 3,600-frame checksum passes, the camera
  and mesh are both ejected, and frame-5,000 shutdown remains clean.
- Made the ordered patch reproducible and idempotent through
  `scripts/clone-sources.sh`; verified clean reverse/apply behavior at the exact
  pinned decomp commit.
- Wrote the initial architecture, plan, status, build, test, legal, dependency,
  and repository-safety documentation.

## 2026-08-02 — native iPhone simulator and in-process extraction

- Added a CMake/Xcode iOS application target that builds a real arm64
  `BrawlerPad.app` for iPhone and iPad families, links the decompiled game,
  libultraship, SDL/Metal, and Torch directly, and packages only ROM-free port
  resources.
- Ported Apple-mobile coroutine assembly, sandbox paths, SDL audio selection,
  Metal window behavior, and desktop-feature exclusions while keeping the
  native game logic ahead-of-time compiled.
- Added a UIKit document picker and first-run wizard. The picker accepts only
  `.z64`, `.n64`, and `.v64`, makes an app-controlled temporary copy, and the
  C++ path normalizes byte order and validates exact supported ROM hashes
  before invoking Torch off the UI thread.
- Split bundle resources from writable Application Support storage and enabled
  Files sharing/open-in-place plus indirect controller input in the generated
  plist.
- Fixed Xcode resource staging and converted relocation, credits, and shader
  generation to dependency-driven rules with a shared relocation stamp target.
  A no-change Release build now completes in 13.05 seconds without compiling.
- Installed the 9.7 MiB ROM-free app into a clean iPhone 17 Pro simulator. The
  Files picker visibly listed the test ROM in BrawlerPad Documents and returned
  it to the first-run UI.
- Completed the full native extraction path: exact ROM SHA-1 validation,
  66.7-second linked Torch conversion, atomic install of a 12,114,884-byte
  `BattleShip.o2r` under Application Support, deletion of temporary picker and
  import copies, and preservation of the original ROM.
- Verified immediate post-extraction launch: archive mount, 32 kHz SDL audio,
  controller registration, continuous game frames, and a visibly rendered
  Metal game scene on the iPhone simulator.
- Captured the ignored upstream changes as ordered BattleShip and libultraship
  patches and added a reproducible unsigned simulator build script.

## 2026-08-02 — native iPad replay and form-factor UI

- Reinstalled the same ROM-free arm64 bundle on an iPad Pro 13-inch (M5)
  simulator while keeping every other simulator shut down.
- Completed the native Files-picker and linked-Torch path from a clean tablet
  container, including exact supported-ROM validation, temporary-copy cleanup,
  archive mount, 32 kHz SDL audio/controller initialization, and visible Metal
  gameplay.
- Recorded that equal-size iPhone and iPad extraction artifacts have different
  whole-ZIP hashes; cross-run acceptance therefore relies on exact input hash,
  successful content mount, and runtime proof instead of container-byte
  identity.
- Adapted the reference port's compact/tablet ImGui base-scale rule and also
  scaled BattleShip's hard-coded first-run dimensions. Two visual iPad passes
  caught and then eliminated clipped guidance and a truncated Choose ROM
  button; the rebuilt app subsequently reached the Metal opening sequence.

## 2026-08-02 — customizable native touch controls

- Added a UIKit overlay with analog, A/B/Z/L/R/Start, C directions, optional
  D-pad, multi-touch-safe independent controls, opacity, and safe-area-aware
  phone/tablet layouts. Input is emitted through an SDL virtual controller and
  normalized by the existing ControlDeck mappings.
- Added a persistent native menu button plus Settings → Input Mappings options
  for enable, controller auto-hide, opacity, and customization. The editor
  supports drag, 70–150% scale, hide/show, reset, and separate saved phone and
  tablet profiles.
- Corrected Simulator enumeration so the touch controller remains on player 1
  even when a host `Gamepad` appears first, and fixed the analog knob's initial
  tracking state so it starts centered.
- Kept one iPad Pro 13-inch (M5) simulator as the only booted simulator. Visual
  testing proved controller auto-hide/manual override, editor resize/hide/reset,
  touch Start/A/B/D-pad navigation, VS Mode entry, and character-select arrival.
- Captured the work as ordered exact-pin patches and verified that applying
  them to BattleShip `4e7f1dc` reproduces every touched file byte-for-byte.

## 2026-08-02 — touch-layout V2 and iPad lifecycle recovery

- Captured before/after iPad screenshots after feedback that the initial
  defaults still overlapped. The audit confirmed D-pad/stick contention and a
  compressed right-side cluster.
- Replaced those defaults with HarkinianPad's grip-first geometry: distinct
  D-pad and stick zones, a right-side A/B/Z triangle, a separate yellow C
  diamond, and lower shoulder rails. Added explicit D-pad/C accessibility
  labels and bumped phone/tablet persistence to V2 so rejected V1 coordinates
  cannot reappear automatically.
- Rebuilt and inspected the sole iPad simulator in both presentations. A final
  correction moved Z out of the left cluster; the accepted screenshot has no
  touch-control intersections and preserves safe-area margins.
- Added SDL application-event handling that gates game frames while
  backgrounded, pauses/clears queued audio, safely flushes configuration, and
  resumes on foreground events.
- Ran three visible Home/resume cycles. Each returned the existing process,
  settings flushed on background, Metal/touch output resumed, and no recent
  BrawlerPad crash report was present. Audible interruptions and route changes
  remain physical-device tests.
- Recorded the layout revision as ordered BattleShip patch 0005 and verified
  clean reverse/apply plus byte-for-byte reproduction against the exact pin.

## 2026-08-02 — phone touch-layout V3 and lifecycle

- Shut down the iPad and verified zero booted devices before booting the iPhone
  17 Pro as the machine's only simulator.
- The first phone V2 capture exposed two device-specific collisions: C-down
  intersected the face cluster and the permanent menu crowded R.
- Spread Z/A/B below the C diamond and adopted HarkinianPad's dedicated
  top-center phone gameplay menu, with bottom-center placement while Settings
  is open. Bumped only the phone profile to V3 so old coordinates cannot
  silently return.
- Rebuilt, installed, and visibly accepted the compact layout. Every control
  remained exposed with an explicit accessibility name, touch Start produced a
  visible scene transition, and all touch groups were visually separate.
- A five-second Home/resume cycle retained PID `18400`, flushed configuration,
  resumed native Metal/touch output, and produced no recent crash report.
- Captured the exact source delta as ordered BattleShip patch 0006 and verified
  reverse/apply plus byte-for-byte reproduction against the pinned source.

## 2026-08-02 — native device build and unsigned IPA

- Added dedicated generic-iPhoneOS and packaging scripts. Both Apple-mobile
  CMake entry points now explicitly set `CMAKE_SYSTEM_NAME=iOS`, preventing a
  fresh device build from configuring host-only TinyCC/funchook targets.
- Completed a clean Release device configuration and native arm64 build with
  signing disabled. The app identifies as iPhoneOS, exposes the expected Files
  and indirect-input capabilities, and has no embedded signature or profile.
- Distinguished the required 21 KiB `f3d.o2r` Fast3D shader archive from the
  forbidden ROM-derived `BattleShip.o2r`. The audit permits only that exact
  path and validates its size, ZIP integrity, entry hierarchy, and shader-only
  extensions.
- Added recursive app/IPA guards for ROMs, playable archives, saves, user
  config/logs, credentials, signing material, Simulator products, unsafe ZIP
  paths, and personal filesystem strings. Injected ROM, signature, and personal
  path fixtures each failed for the intended reason.
- Packaged actual source and fetched-dependency notices (28 files), normalized
  timestamps and ordering, and proved two independently produced IPAs were
  byte-identical. The accepted unsigned proof IPA SHA-256 is
  `2b688a5eec3ce8f1715a05585f76a498ccbb7670f45fd4b15f068fa40ba4f291`.
- An audit self-test exposed a false negative caused by an early-exiting grep
  under `pipefail`. Replacing it with a full-stream scanner made the old binary
  fail on absolute checkout paths. Added global iOS compiler prefix maps,
  rebuilt, and verified the corrected audit sees only stable source labels.
- Reconstructed from a fresh Git clone and official pinned upstream URLs, then
  rebuilt without a ROM. Replaced timestamp-bearing shader packaging with a
  sorted fixed-timestamp ZIP generator and removed the linker's random UUID
  from the unsigned proof executable. Primary and clean-checkout executable,
  shader archive, and IPA hashes then matched exactly.
- Hardened `clone-sources.sh` idempotence with content-addressed per-patch
  stamps stored inside ignored upstream Git metadata. A migration check records
  already-complete pre-stamp trees, and two consecutive reruns then completed
  without altering or reapplying the ordered source delta. A second brand-new
  repository clone also applied the full series on its first invocation and
  recognized every patch on its second.

## 2026-08-02 — branded Apple packages and fresh release replay

- Added a build-time BrawlerPad identity layer that brands the executable,
  bundle, archive, configuration, storage directory, first-run UI, and stale
  archive recovery without renaming the pinned upstream repository.
- Built a 35,372 KiB arm64 `BrawlerPad.app` and 12,792 KiB
  `BrawlerPad.dmg`. The `com.brawlerpad.app.macos` bundle passed strict deep
  ad-hoc signing, portable-load-command, ROM/archive/save/config/log,
  credential, personal-path, rights, and dependency audits. A visible fresh
  Metal launch showed the fully branded first-run wizard.
- Rebuilt the branded simulator app. A launch probe caught that the device
  proof's `-no_uuid` option had leaked into Simulator and produced a dyld
  rejection. Limited the option to generic iPhoneOS builds, retained simulator
  UUID `58B7AF12-FC8A-3BD0-AA6F-1783A8A3AF1F`, and verified launch on the sole
  booted iPhone.
- Repeated Files import in the branded app. Linked Torch generated a
  12,114,884-byte `BrawlerPad.o2r` in 5 seconds, the temporary import was
  removed, `BrawlerPad.cfg.json` was created, and Metal gameplay rendered.
- Built and audited the clean branded device app and deterministic unsigned
  IPA. The executable SHA-256 is
  `e9d1397ddba0a79f825527d2aea4ea1d2eabcd4b6520f7236367d5ec9d406267`;
  `f3d.o2r` is
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`;
  the IPA is
  `70f57562634715bc8a60910b265ea8d2b58867f96ab8ec09a8d65be1fa48f367`.
- Replayed every ordered BattleShip, libultraship, decomp, and Torch patch in a
  fresh wrapper clone, verified a second idempotent bootstrap, rebuilt without
  a ROM, and reproduced the executable, shader archive, and IPA byte-for-byte.

## 2026-08-02 — reproducible macOS release payload

- Corrected the package's credits pre-generation so `info.credits` uses the
  same multiline conversion as CMake, then stripped release-only source and
  object symbols before signing.
- Replaced nondeterministic Objective-C fast stubs with deterministic small
  stubs and added an idempotent content-derived Mach-O UUID normalizer that
  ignores the prior UUID and linker-signature metadata.
- A direct launch caught that removing the desktop UUID makes macOS dyld reject
  the app. The final package retains deterministic UUID
  `73622AD5-E270-3C62-A690-8F41D70D0B02` and survived the launch smoke test.
- Two checkout roots produced normalized executable SHA-256
  `ef947ea24de6c168f145f83f9bdad69e5732e4bf0be5f7482eae408f5bc3e831`,
  Apple CDHash `07b73399fc24b9705766dc0a17d6cc42ec7b477d`, and identical non-signature
  bundle files. Opaque ad-hoc signature bytes and DMG filesystem metadata were
  observed and documented as non-stable.
- Expanded the macOS audit to reject missing UUIDs and OSO source paths, verify
  DMG checksums, mount DMGs read-only, and audit the contained app. The final
  30,772 KiB app and 12,096 KiB DMG passed.
