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

## 2026-08-02 — phone touch-layout V4 active-match pass

- Kept iPhone 17 Pro as the machine's sole booted simulator throughout the
  pass. Runtime logs explained the initially hidden overlay: Simulator exposed
  a host-forwarded `Gamepad`, so its configured controller auto-hide path was
  working. The test container was set to show both inputs without changing the
  shipping default.
- Reproduced a visible D-pad intersection during active gameplay despite the
  earlier V3 acceptance capture. Reworked the compact defaults around
  HarkinianPad's accepted phone rail: D-pad above the left stick,
  Start/R-over-L on the upper right, a gapped C diamond beside that rail, and a
  separate lower-right A/B/Z triangle.
- Increased D-pad and C axial radii beyond their button diameters, derived the
  stick and face groups from safe-area edges, and bumped only the phone profile
  to `phone-v4` so persisted V3 coordinates cannot conceal the fix.
- Rebuilt and installed the Release simulator app in place. Live match captures
  in both landscape sides showed no visible intersections and exposed all 15
  named buttons plus the analog stick. A coordinate Start touch caused a
  visible title-to-match transition; the native menu hid and restored the
  complete V4 overlay during play.
- Recorded the exact source delta as ordered BattleShip patch 0012. Clean
  forward and reverse checks passed against the post-0011 source. True
  simultaneous-touch synthesis is unavailable through the simulator automation
  surface and remains a physical-device acceptance item.
- Completed a fresh generic-iPhoneOS Release build after the V4 change and
  passed the recursive app and IPA audits. The arm64 executable SHA-256 is
  `9bab6f8511f8eb051d301d9ad3f4598f5a3e91d59b1ea50bf0848843876506aa`;
  the unsigned IPA SHA-256 is
  `148e0b89322205477667419aeb66e74d9a451cf7620eedb4a14adf944bda7505`;
  a second packaging pass was byte-identical, and `f3d.o2r` retained its
  established hash. The device-build script now rejects a stale non-iOS CMake
  tree instead of allowing it to fail later with misleading host-only
  dependency errors.

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
  the app. The content-derived UUID pipeline survived launch and was reproduced
  from two checkout roots, along with identical normalized executable content,
  CodeDirectory data, and non-signature bundle files. Opaque ad-hoc signature
  bytes and DMG filesystem metadata were documented as non-stable.
- Expanded the macOS audit to reject missing UUIDs and OSO source paths, verify
  DMG checksums, mount DMGs read-only, and audit the contained app. The final
  30,772 KiB app and 12,096 KiB DMG passed.

## 2026-08-02 — touch input timing and full iPhone flow

- Kept iPhone 17 Pro as the machine's sole booted simulator. A deeper
  touch-only run found two timing defects behind apparently ignored controls:
  synthetic/fast UIKit input could end between adjacent polls, and service
  registration order let game logic resume before the higher-priority
  controller coroutine published the current edge.
- Added a minimum 50 ms pulse for buttons, triggers, C directions, and the last
  stick value. Normal holds still release after the minimum, re-presses
  invalidate delayed releases, and cancellation/lifecycle/editor paths remain
  immediate. Service resume rounds now take a registry snapshot and stable-sort
  it by current priority, including newly registered threads on the next round.
- Removed every temporary trace and rebuilt cleanly. Touch alone traversed
  title, Mode Select, VS setup, Link and CPU Pikachu character select, Peach's
  Castle stage select, a one-minute live match, pause, visible `PIKACHU WINS!`
  results, and return to character select. Stick/A/B/Z/L/R/C-up/D-up worked in
  gameplay, and Training pause EXIT was separately verified.
- Reinspected V4 through Mode Select, character and stage select, live combat,
  pause, and results; no controls intersected one another. Simulator automation
  cannot synthesize true simultaneous contacts, so multitouch combinations,
  physical-controller behavior, audible interruption/routes, and real-device
  execution remain hardware acceptance items.
- Recorded the exact production delta as ordered BattleShip patch 0013. A fresh
  pinned tree accepted patches 0001–0013 in order and reproduced both changed
  files byte-for-byte; reverse checks and two consecutive source-bootstrap runs
  also passed.
- Rebuilt and audited the generic-iPhoneOS arm64 app. Its executable SHA-256 is
  `26fdfe852741e66176159e2d17b6e0d16c4c6d290a5dcbd685e74ee3cf778bcd`;
  `f3d.o2r` remains
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`;
  the unsigned IPA is
  `8fca73f0a3b7a14330c30a62bd50b2c5bdc50203cf1dccd3917f86755e124ffb`.
  A second packaging pass was byte-identical.

## 2026-08-02 — HarkinianPad phone V5 and persistence proof

- Kept iPhone 17 Pro as the machine's only booted simulator. Live inspection
  showed that V4 avoided literal intersections but still crowded the right
  rail and obscured more gameplay than HarkinianPad's accepted phone layout.
- Promoted HarkinianPad's physical-iPhone normalized centers into `phone-v5`:
  L/Z moved back to the left grip, Start/R occupy the upper-right rail, and
  the compact C diamond and A/B group have visible gaps under the right thumb.
- Fixed the remaining short-tap race at the controller task boundary. Port
  builds now read and publish synchronously before each scene update, while
  native N64 retains its threaded event path. Short Start taps reached Mode
  Select; D-down, A, and B navigated VS Start and back.
- Removed all diagnostics, rebuilt the Release simulator app, and recorded the
  source deltas as ordered BattleShip patch 0014 and decomp patch 0002. Fresh
  pinned replays reproduced both changed files byte-for-byte; bootstrap and
  repository-safety checks passed.
- Inspected persistence content after terminate/relaunch and repeated in-place
  installs. The 3,036-byte save retained a valid signature/checksum, one VS
  battle, and the expected fighter/stage records; the branded configuration
  retained a stable hash. Simulator data-container UUID migration did not
  alter either payload.
- Completed a fresh generic-iPhoneOS arm64 build in an explicit clean iOS
  tree after the stale default cache was safely rejected. The recursive app
  and IPA audits passed; executable SHA-256 is
  `8c91deb84b960b29e2e4ea6818128c03b1b139af35f9d87660cdd618a087f7bf`,
  IPA SHA-256 is
  `1654e39efef8f9cd27ca11d1fadfaeb447e7069f575f1d9418719f114c2f2b37`,
  and a second packaging pass was byte-identical.
- Rebuilt the macOS app and DMG from the V5/input-boundary sources. App,
  signature, DMG checksum, mount, and contained-app audits all passed. The
  executable SHA-256 is
  `1a9b6335313e1a5411385b1daaf33a14f2fefca8d2311cd0e5d0befc93cc7c82`,
  Mach-O UUID is `EBBCC693-5DFF-32FE-9202-D4E011F64692`, Apple CDHash is
  `c970aca0dfd80dfe3418ef23ca77090d568de418`, and DMG SHA-256 is
  `17d95096d3794510267e8029dc2f9f8555d72e6edd1234dc32663d80219d1fe8`.

## 2026-08-02 — iPad Classic and update persistence

- Shut down the iPhone before booting the previously used iPad Pro 13-inch
  simulator; every check showed the iPad as the machine's only booted device.
- Reinstalled the current universal Release app and repeated the native Files
  flow from a clean BrawlerPad runtime: supported ROM validation, linked Torch
  extraction, empty temporary picker storage, archive mount, Metal rendering,
  32 kHz audio initialization, and controller registration all passed.
- Simulator exposed its host `Gamepad`, so automatic touch hiding activated as
  designed. The app's searchable Input Mappings UI disabled that preference;
  the touch overlay returned and remained merged into player 1.
- Touch alone traversed title, Mode Select, 1P Game, and Classic character
  select. Analog moved the P1 hand to Donkey Kong, A selected him, Start began
  the Link battle, analog/A/B/Z changed live combat and damage, and Start
  opened and closed the visible 1P pause screen.
- Backgrounded, terminated, and relaunched without reinstalling. The app
  skipped first-run, mounted the preserved archive, restored the tablet
  overlay preference, and retained a checksum-valid 3,036-byte save.
- Reinstalled the same app in place. CoreSimulator migrated the data-container
  UUID, but save SHA-256
  `0bbc8eb0f63a4aaad44e8d71cf6c4315b13623f0fe3f86b9c2741e70e3730330`
  and config SHA-256
  `b2caedeec889c300f45c0b69f83f0ce405561ff418027f202908946f3fa7416a`
  were unchanged; launch again skipped setup and restored Metal plus touch.

## 2026-08-02 — tablet V3 touch refinement and complete iPad VS flow

- Kept the iPad Pro 13-inch (M5) as the machine's only booted simulator for
  the entire pass. Live reinspection confirmed the feedback: tablet V2 avoided
  literal intersections but still compressed the shoulder/face hierarchy and
  obscured more gameplay than HarkinianPad.
- Compared the maintained HarkinianPad patches, including its later
  physical-iPad native-HUD refinement, rather than relying on the older
  promoted normalized preset. Tablet V3 now stacks Start/R/L on one right
  rail, derives that rail from a separately spaced Z/A/B triangle, keeps the C
  diamond below, and preserves distinct D-pad/stick lanes on the left.
- Added a separately persisted tall/portrait tablet profile so transient
  rotation or Stage Manager bounds cannot squeeze landscape geometry. Reduced
  idle fill and border alpha to preserve game readability. Fresh landscape
  and portrait captures showed every named target with visible gaps.
- Rebuilt the universal Release simulator app, installed it in place, and used
  the revised controls for title, Mode Select, one-minute VS setup, Kirby and
  CPU Donkey Kong selection, Peach's Castle, live combat, visible `DK WINS!`
  results, and return to character select. Analog, A/B/Z/L/R/C-up, D-pad, and
  Start all produced observable state changes.
- Inspected the post-match 3,036-byte save: signature `0x29A`, matching
  stored/computed checksum `8892894`, Castle and Kirby/Donkey Kong records,
  `vs_total_battles: 1`, and SHA-256
  `3848e4005b6fe70a3c4dea54c5d46ac95e37a1d1be574a58fd0683a1b5c69d9c`.
- Captured the production delta as ordered BattleShip patch 0015. Clean
  reverse/apply checks reproduced the tested touch source byte-for-byte.

## 2026-08-03 — invalid ROM rejection and picker cleanup

- Kept the iPad Pro 13-inch (M5) as the machine's only booted simulator and
  installed the current Release app under an isolated negative-test bundle ID,
  preserving the completed-match BrawlerPad container.
- Visibly verified the branded first-run wizard with no generated archive,
  then selected a deliberate 44-byte `.z64` through the native Files picker.
  The app rejected it with the exact 16 MiB requirement and generated no O2R.
- Inspection caught the Files provider's transient Inbox copy surviving the
  picker callback. The picker now removes only copies inside the app's own
  temporary directory, never the user's source document, after staging or an
  extension failure.
- Rebuilt the universal Release simulator app and repeated the flow. Before
  extraction only BrawlerPad's staged import remained; after rejection all
  temporary ROM copies were gone while the source fixture was unchanged.
- Captured the fix as ordered BattleShip patch 0016 and added it to clean
  source replay.
- A fresh generic-iPhoneOS build directory completed a full Release configure,
  compile, and recursive app audit. Packaging the exact app twice produced
  byte-identical unsigned IPAs. The executable SHA-256 is
  `906fa018fc237a047cbc811f8f3346aa16f6575aa1f53d89847f3100e2b89289`;
  the IPA SHA-256 is
  `94672dc88e1171cda299e9a6aedc9ee0698c3c8b3a023862f314981857aa687f`.
- Removed the isolated test bundle, installed the fixed Simulator app over the
  normal BrawlerPad bundle, and launched directly into rendered gameplay. The
  migrated production save retained SHA-256
  `3848e4005b6fe70a3c4dea54c5d46ac95e37a1d1be574a58fd0683a1b5c69d9c`.

## 2026-08-03 — iPad touch-layout V4

- Kept the iPad Pro 13-inch (M5) as the machine's only booted simulator. The
  user's live reinspection exposed Tablet V3's remaining problem: Z, A/B, C,
  and the shoulder rail still read as one crowded right-side control mass.
- Restored HarkinianPad's accepted physical-iPad split in `tablet-v4`: Z now
  occupies the space between the left D-pad and stick, A/B and the C diamond
  have independent right-side zones, and the upper Start/R/L rail no longer
  derives its position from the face stack. Phone V5 and portrait-tablet
  defaults are unchanged.
- Rebuilt and installed the universal Release app in place. A fresh capture
  showed the groups mutually separated and every named target available. A
  coordinate Start tap changed the rendered state; opening the native menu
  removed the gameplay controls and closing it restored them.
- The migrated save retained SHA-256
  `35372f0f42334b27f192faf097a85205a5468ea1d7431ff9e7a330895a662c6b`,
  signature `0x29A`, exact checksum `8895910`, Castle, and one VS battle. The
  configuration retained SHA-256
  `b2caedeec889c300f45c0b69f83f0ce405561ff418027f202908946f3fa7416a`.
- Recorded the source delta as ordered BattleShip patch 0017. A fresh pinned
  clone replayed patches 0001–0017 and reproduced the tested touch source
  byte-for-byte; bootstrap migration now safely applies any newer unapplied
  patches after recognizing an older unstamped tree.
- Built a fresh generic-iPhoneOS arm64 app and passed recursive app/IPA audits.
  Executable SHA-256 is
  `d21407f6d7b0f3ece8c3ec91955203446967f91cd18b8ab3e92a065aa0cbb8a9`;
  `f3d.o2r` remains
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`;
  unsigned IPA SHA-256 is
  `ac1820954dc1aa2088aaa80d0bfe9f80d4ae784e666dd7dbdaac652bf538604c`.
  A second packaging pass was byte-identical. True simultaneous touch and
  physical-device feel remain open hardware checks.

## 2026-08-03 — simulator interruption and low-memory dispatch

- Kept the iPad Pro 13-inch (M5) as the machine's only booted simulator and
  audited the linked SDL CoreAudio implementation before changing product
  code. SDL already owns `AVAudioSessionInterruptionNotification`, pauses its
  AudioQueue on begin, resumes on end, and retries resume when the app becomes
  active, matching the maintained HarkinianPad evidence.
- Attached LLDB briefly to live BrawlerPad PID `45456`, resolved
  `-[SDLInterruptionListener audioSessionInterruption:]`, and posted synthetic
  began/ended notifications against the active `AVAudioSession`. The resolved
  breakpoint recorded exactly two hits; after detaching, the same process
  continued advancing the rendered attract sequence.
- Switched Simulator Audio Output from the active Jump Desktop route to
  MacBook Air Speakers and back. The process, Metal scene, full Tablet V4
  accessibility tree, and controls survived both host-output changes.
- Pushed `SDL_APP_LOWMEMORY` into the live SDL queue and conditioned a
  breakpoint on event type `0x102`. It reached
  `GfxWindowBackendSDL2::HandleSingleEvent`; the same PID returned to the
  animated title and no recent BrawlerPad crash report appeared.
- Post-probe configuration retained SHA-256
  `b2caedeec889c300f45c0b69f83f0ce405561ff418027f202908946f3fa7416a`.
  The current save retained signature `0x29A`, exact checksum `8895910`,
  Castle, and one VS battle. The Simulator runtime exposed one forwarded MFi
  `Gamepad` with 23 buttons, six axes, and three D-pads; an attempted connection
  to the Mac's paired 8BitDo Lite 2 returned to `Not Connected`, so no physical
  input action is claimed.
- This closes synthetic interruption and low-memory dispatch plus host-output
  switch recovery in Simulator. Audible OS interruptions, real audio-device
  route changes, physical-controller actions/reconnect, true simultaneous
  touch, and physical-device timing remain hardware acceptance work.

## 2026-08-03 — clean release replay and README handoff

- Cloned remote `main` at `d8ef0f8` into isolated temporary storage, fetched
  all five recorded upstream pins, and replayed every maintained patch without
  using the primary checkout's generated source or build trees.
- Built the Apple Silicon macOS app and DMG from that clone. Deep ad-hoc
  signature verification, package audit, DMG checksum, read-only mount, and
  contained-app audit passed. The executable retained content-derived UUID
  `EBBCC693-5DFF-32FE-9202-D4E011F64692`; `f3d.o2r` retained SHA-256
  `19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.
- The first empty Simulator cache failed at final link because libzip's early
  dependency discovery selected iPhoneOS `libz`/`libbz2`. Updated both mobile
  scripts to supply the absolute `xcrun` SDK root and arm64 architecture to
  CMake before dependency discovery. A second empty cache selected only
  `iPhoneSimulator26.5.sdk` libraries and completed bundle validation.
- Completed a separate clean generic-iPhoneOS arm64 configure, build, and
  recursive app audit. The Simulator and device executable SHA-256 values are
  `c7d645285f1417036365adc9b2ad9b2d9768f3d6d28d1bd84876677b503d0830`
  and `c01aa9f9af0e07ae19114af1efdecdd256ebf227352667eb328c1bba7564f7ea`.
- Packaged the exact clean device app twice. Both complete audits passed and
  the files were byte-identical at SHA-256
  `e81a061c7034ae97d5e431f195b141246bd02d7733ffbe7ad1de0dbcdda2400c`.
- Reworked the README toward HarkinianPad's approachable project handoff:
  install-status table, first-launch and touch guidance, current screenshot,
  supported features, FAQ, reproducibility flow, project map, contribution
  expectations, and explicit legal/hardware boundaries.
- Kept the iPad Pro 13-inch (M5) as the sole booted simulator for the full pass;
  no build or packaging step booted another simulator.

## 2026-08-03 — physical iPad audio, settings, and Smash control pass

- Traced the silent-device failure to a persisted `Window.AudioBackend: null`
  after a transient iOS audio-session activation failure. The iOS runtime now
  migrates Null back to SDL, retries transient activation, and no longer offers
  Null as a selectable mobile backend. A physical launch reported SDL device 2,
  stereo at 32000 Hz, running status 1, and all music/SFX archives loaded.
- Replaced the fixed-width mobile settings sidebar with content-derived width,
  preventing `Control Enhancements` and other category labels from clipping on
  the 12.9-inch iPad.
- Rechecked the Smash 64 manual and competitive control references. The D-pad
  is unused in play, all four C buttons jump, analog magnitude matters, and Z
  must chord with movement/A for shields, rolls, grabs, techs, and Z-cancels.
  Removed the D-pad, consolidated the C diamond into one large Jump target,
  moved all actions to the right, and made the left 47 percent a floating-stick
  zone whose origin is recreated for each initiating touch.
- Added ordered BattleShip patch 0021 for the control model and profile bump.
  Its pinned-source replay reproduced the built touch source byte-for-byte.
- Found that an earlier device-copy destination had stored the verified 16 MiB
  ROM as a file named `Application Support/BrawlerPad`, blocking the app-data
  directory. Preserved and read back that file at SHA-1
  `e2929e10fccc0aa84e5776227e798abc07cedabf`; a remote recursive replacement
  was rejected in favor of a recoverable in-app migration.
- Added ordered patch 0022. On iOS it validates the N64 byte-order header,
  atomically stages the misplaced file, creates the support directory, moves
  the ROM to `baserom.us.n64`, restores the known-good config, and rolls back if
  directory creation or the final move fails.
- The final signed in-place install regenerated a 11.6 MiB `BrawlerPad.o2r`,
  recipe sidecar, config, logs, and a 3036-byte save. Config read-back retained
  SHA-256 `f2f1f6a718a8f7877bbce23a12a29a53e0089fb65b3ff1533d5ea2488235a29a`
  with SDL audio selected. The normal relaunch is live as PID 2966.
- Interrupting the attached diagnostic console forced shutdown and exposed a
  QuartzCore/Objective-C teardown SIGSEGV. This was a diagnostic-detach path;
  BrawlerPad was immediately relaunched normally and remained live. Graceful
  user-driven quit remains a separate lifecycle acceptance check.
- Installed the exact same signed executable on a wired iPhone 14 after
  verifying its SHA-256, signature, entitlements, and embedded device list.
  The fresh container had no game data, so the same hash-verified local ROM was
  copied to the documented support path. Relaunch generated the archive,
  recipe, config, logs, and save; read-back confirmed SDL audio, every music/SFX
  asset, and the floating touch controller initialized successfully. The normal
  iPhone launch remained live as PID 5033.

## 2026-08-03 — physical iPhone pacing, audio watermark, and pause Reset

- Captured the running iPhone app log and a 20-second Metal System Trace after
  audible stutter was reported. The app log contained no runtime errors, but
  the retained configuration showed full native Retina rendering and the SDL
  player began consuming an empty queue.
- Added compact release telemetry for 120-frame windows. The first instrumented
  run showed rendering settling near 16.7 ms while the software audio queue
  repeatedly reached zero, separating the audio starvation from the GPU/frame
  pacing concern.
- Applied a one-time mobile performance profile that selects the existing 480p
  window-aspect mode for fresh or still-native preview installs. Later user
  resolution choices are preserved by a profile version.
- Changed iOS SDL startup/foreground recovery to prime before unpausing, then
  made the decomp audio producer use its aligned high sample count whenever the
  software queue falls below the configured watermark. The final startup prime
  includes two 1,024-sample device buffers.
- The final iPhone log primed 4,968 samples against a 4,528-sample target,
  reported zero post-start underruns, held roughly 1,760–3,900 queued samples,
  and settled at approximately 16.7 ms per frame. iOS release builds retain
  these two-second frame/queue summaries in `BrawlerPad.log` for future device
  diagnosis.
- Added a red Reset pill to the touch layout. It is visible only while the game
  reports an actually paused battle and sends the native A+B+Z+R reset chord
  through the same player-one virtual controller. The layout editor can still
  move, resize, or hide it.
- The final signed executable SHA-256 is
  `c721c192f3d5ef7b8c996e13e140c11fda785e887146d6a2a4cedc677b00415f`.
  It passed the strict package audit and deep signature verification, installed
  in place, and launched on the wired iPhone 14. The exact same bundle installed
  in place on the iPad Pro; its locked screen denied only the automated launch.

## 2026-08-03 — responsive iPhone settings and final dual-device replay

- Reinstalled and launched the previously merged build on the now-unlocked
  iPad without uninstalling or replacing its data container; it ran as PID
  3200 before the responsive follow-up build.
- Traced the iPhone Settings failure to two independent causes. Retina display
  pixels made the prior shortest-side test apply the iPad's 2x ImGui scale to
  iPhone, and SDL translated touch taps but supplied no drag-to-scroll gesture
  to ImGui.
- Classified the iOS form factor with both shortest side and aspect ratio,
  backed by compile-time iPhone/iPad dimension assertions. iPhone now uses 1x
  menu scaling, an enlarged scrollbar, a compact section picker instead of the
  width-heavy sidebar, and a full-width settings pane. iPad keeps its existing
  2x scale and persistent sidebar.
- Converted vertical `SDL_FINGERMOTION` into scale-adjusted ImGui wheel input
  only while a menu is visible, so nested Input Mappings and opacity content
  can be scrolled with a natural finger drag without affecting gameplay touch.
- The first signed deployment attempt exposed the deterministic proof build's
  intentional missing `LC_UUID`; iOS dyld exited before application code. The
  same source was rebuilt with `BRAWLERPAD_REPRODUCIBLE_DEVICE_LINK=OFF`, and
  documentation now clearly separates the non-runnable proof artifact from a
  runtime-linked local device build.
- The corrected runtime bundle passed the iPhoneOS build, strict package audit,
  `LC_UUID`, deep-signature, and in-place install checks. Identical executable
  SHA-256 `1af3166bb1be134465d2e9eed4b22d238503e345ec048dded87a11bb2a0b441b`
  launched and remained live on iPhone PID 5101 and iPad PID 3213. The iPhone
  console proved `844x390` selects scale 1, plus zero post-start audio
  underruns and approximately 16.69 ms steady frame windows. Hands-on phone
  scrolling remains the final physical acceptance boundary.
- The final default proof build independently passed its no-UUID guard and
  recursive audit. Two packages from that exact app were byte-identical at
  IPA SHA-256
  `2cf5121dedccb02f3afb65fed9e9e2f8230c68e665daea55d84beeffbce2d2ea`.

## 2026-08-18 — SDL2 controller reconciliation and Preview 2

- Traced controller ownership to libultraship's SDL2-backed ControlDeck. The
  prior manager depended on add/remove refreshes, reopened handles without
  closing superseded ones, and did not reconcile on startup or foreground.
- Added targeted instance-ID reconciliation that retains attached controllers
  and player slots, closes stale handles, releases stale per-port ownership,
  assigns returning/extra controllers to the first free slot, and runs for
  startup, add/remove/remap, foreground, and a bounded active check.
- Added production-source virtual-controller regression coverage for missed
  removal with held input, neutral state, player-1 reclaim, stable player-2
  assignment, and foreground reconciliation. Focused tests, safety/diff/patch
  checks, arm64 Simulator, and generic iPhoneOS Release builds passed.
- Installed development-signed `0.1.0` build 2 in place on the attached iPad.
  Existing ROM, generated archive/recipe, config, and controller preferences
  matched pre-install hashes. The checksum-valid save retained all content and
  advanced only its expected boot count from 11 to 14 across final validation
  launches.
- Packaged the ROM-free unsigned IPA twice with identical bytes. Preview 2 IPA
  SHA-256 is
  `67795d4f8a07641dde7d89102617c328bb3ea3aaa82f365efe544084fd2ea880`.
  Physical Bluetooth/wired/sleep/mapping/two-controller tests remain open.
