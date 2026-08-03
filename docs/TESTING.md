# Testing

Every platform claim requires a build, install where applicable, launch, and
observable runtime result. Compilation alone is not a pass.

## macOS baseline matrix

| Check | Evidence required | Status |
|---|---|---|
| Clean configure and build | command, exit status, artifact architecture | Pass (local Release baseline; clean-checkout rerun pending) |
| User data extraction | Torch exit/log and generated archive outside Git | Pass (local baseline) |
| Metal rendering | renderer log plus visible frame | Pass through match and populated results with BrawlerPad patch |
| Audio | audible output and stable stream log | Non-zero synthesis pass; audible pending |
| Physical/mapped input | menu and gameplay actions | SDL mappings load; automation delivery and physical controller pending |
| Full versus flow | character select through results and return | Match and visible results pass; mapped return input pending |
| Save/relaunch | save file, clean exit, restored state | Save/update, clean exit, and relaunch pass; content-level persistence check pending |

### Branded macOS package proof

The final 2026-08-02 branded build produced a 30,772 KiB arm64
`BrawlerPad.app` and a 12,096 KiB `BrawlerPad.dmg`. The bundle identifier is
`com.brawlerpad.app.macos`; its data directory, generated archive, and config
identity are BrawlerPad rather than BattleShip. The app passed strict deep
ad-hoc signature verification, portable-load-command inspection, and the
recursive ROM/archive/save/config/log/credential/personal-path audit. Its only
O2R is the bounded Fast3D shader archive, and its package includes the
rights/dependency manifests and discovered notices. The audit also verified
the DMG checksum, mounted it read-only, and reran the complete app audit on the
contained bundle.

A fresh first launch was inspected visibly through macOS accessibility. The
Metal window showed a fully branded BrawlerPad ROM setup wizard without any
legacy BattleShip copy. The final package also survived a direct launch smoke
test after a missing-UUID regression was caught and fixed.

The V5/input-boundary package rebuild passed the complete app and mounted-DMG
audits. Its Mach-O UUID is `EBBCC693-5DFF-32FE-9202-D4E011F64692`, Apple
CDHash is `c970aca0dfd80dfe3418ef23ca77090d568de418`, and executable SHA-256 is
`1a9b6335313e1a5411385b1daaf33a14f2fefca8d2311cd0e5d0befc93cc7c82`.
The content-derived normalization process was separately proven across two
checkout roots. The stable `f3d.o2r` SHA-256 is
`19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.
The rebuilt DMG SHA-256 is
`17d95096d3794510267e8029dc2f9f8555d72e6edd1234dc32663d80219d1fe8`.
Raw local ad-hoc signature blobs and DMG filesystem metadata differ between
builds even when their CodeDirectory and contained payload agree, so those two
raw hashes are evidence for this artifact rather than reproducibility anchors.

### Deterministic match proof

Compile `tools/generate-baseline-replay.c` as documented in `BUILDING.md`, then
run the packaged executable with:

```sh
SSB64_REPLAY_PLAY=/tmp/brawlerpad-baseline.replay \
SSB64_MAX_FRAMES=5000 \
ref/BattleShip/dist/BattleShip.app/Contents/MacOS/BattleShip
```

Expected verifier line:

```text
SSB64 Replay: playback verify frames=3600 expected=0xC47FF9C5 actual=0xC47FF9C5 result=PASS
```

The untouched baseline enters scene 24 (`VSResults`) and initializes both
fighters, but its window stays white. The BrawlerPad decomp patch retires the
PORT transition camera when the wipe mesh ends. With that patch, the original
transition is retained and the full results UI (scores, placements, fighters,
winner text, wallpaper, and confetti) is visibly correct.

The final patched replay proof again reports the expected 3,600-frame checksum,
logs ejection of camera GObj `0x20000002` followed by transition GObj
`0x20000000`, reaches visible results, exits at frame 5,000, destroys the game
coroutine, and returns from `PortGameShutdown`.

BattleShip's `SSB64_SCREENSHOT_FRAMES` hook reports successful captures on
Metal but emits no PNG files. Until that backend hook is implemented, use a
separate visible-window capture and do not treat its log message as evidence.

## iOS/iPadOS simulator matrix

Run at least one current arm64 iPhone and one current arm64 iPad profile. For
each: build, install with `simctl`, launch, capture logs, initialize Metal,
complete ROM/resource setup, reach menus, exercise mapped/touch input, enter
and complete a match, background/foreground, terminate, and relaunch.

| Area | iPhone simulator | iPad simulator | Physical device |
|---|---|---|---|
| Build/install/launch | Pass (iPhone 17 Pro, iOS 26.5) | Pass (iPad Pro 13-inch M5, iOS 26.5) | Pending |
| Metal/game render | Pass (visible native attract scene) | Pass (visible native opening scene) | Pending |
| ROM import/extraction | Pass (Files + SHA-1 + linked Torch) | Pass (Files + SHA-1 + linked Torch) | Pending |
| Touch menus and gameplay | Pass (touch-only title → VS → CSS → stage → match/pause → results → CSS; true simultaneous contacts pending hardware) | Pass (touch-only title → VS → CSS → stage → one-minute match → results → CSS; Classic CSS/live combat/pause also covered; true simultaneous contacts pending hardware) | Pending |
| Controller connect/reconnect | SDL registration only | Host `Gamepad` detection + auto-hide pass; reconnect pending | Pending |
| Audio/interruption/routes | Pause/clear/resume path integrated; audible interruption/routes pending | Pause/clear/resume path integrated; audible interruption/routes pending | Pending |
| Background/foreground | Pass (1 visible Home/resume cycle, same PID, config flush, no crash) | Pass (3 visible Home/resume cycles, same PID, config flush, no crash) | Pending |
| Save/update persistence | Pass (content-level save + config verification after terminate/relaunch and repeated in-place installs) | Pass (checksum-valid save + config/archive after terminate/relaunch and in-place reinstall) | Pending |
| Rotation/safe areas/aspect | Partial pass (both landscape sides, V5 layout) | Pass (V3 landscape plus dedicated tall/portrait profile inspected live) | Pending |

### iPhone first-run proof

The 2026-08-02 iPhone 17 Pro simulator run used a clean app data container.
The bundled app was 9.7 MiB, arm64, and contained no ROM or generated playable
archive. The native Files picker opened in BrawlerPad, selected the test ROM,
and staged a temporary import. Torch logged the expected US SHA-1, processed
the archive in-process in 66,731 ms, and produced a 12,114,884-byte
`BattleShip.o2r` under `Library/Application Support/BattleShip` with SHA-1
`b8b8bb9f17d142d4964ac8d34cb06588d93e48ba`.

After completion, both the import copy and picker Inbox copy were absent while
the original Documents ROM retained SHA-1
`e2929e10fccc0aa84e5776227e798abc07cedabf`. Logs then proved archive mount,
32 kHz SDL audio initialization, controller registration, and continuing game
frames; the Simulator visibly rendered the game through Metal.

The no-change Release build completed in 13.05 seconds and invoked no compiler
or linker steps. This verifies that generated relocation, credits, and shader
artifacts are dependency-driven instead of forcing a full rebuild.

The later branded replay caught a simulator-only launch regression: applying
the device proof's deterministic `-no_uuid` link option to Simulator produced
a Mach-O that dyld rejected for a missing `LC_UUID`. The option is now limited
to generic iPhoneOS builds. The rebuilt Simulator executable retains UUID
`58B7AF12-FC8A-3BD0-AA6F-1783A8A3AF1F` and launched successfully on the sole
booted iPhone 17 Pro.

From the native Files picker, that branded build selected the supported ROM,
created a 12,114,884-byte `BrawlerPad.o2r` in 5 seconds, deleted the temporary
`brawlerpad-import-*` copy, and visibly booted native Metal gameplay. It also
created `BrawlerPad.cfg.json`; no legacy BattleShip runtime name appeared in
the fresh branded flow.

### iPad first-run proof

The 2026-08-02 iPad Pro 13-inch (M5) simulator run also began from a clean
install. The native Files picker selected the same supported ROM, the app
validated exact SHA-1 `e2929e10fccc0aa84e5776227e798abc07cedabf`, completed
linked Torch extraction, removed its temporary import and picker copies, and
left the original unchanged. It produced a 12,114,884-byte archive and then
mounted it, initialized 32 kHz SDL audio and controller registration, and
visibly rendered the native Metal opening sequence.

The iPad archive's observed SHA-1 was
`fca952b01f5d11d7d1ba8c87be96e1d54b3fc667`, different from the equal-size
iPhone artifact because the generated ZIP container is not byte-deterministic.
Tests therefore verify the supported ROM hash, archive size/mount, and runtime
contents rather than requiring identical archive hashes across extractions.
The first visual pass also exposed undersized tablet UI; the corrected build
uses a 2x base scale when the shortest usable display side is at least 600
points and scales the first-run window's explicit dimensions with it. A clean
reinstall showed readable, unclipped guidance and a complete Choose ROM button,
then the preserved generated archive booted the game again.

## Touch coverage

Test analog precision, every button, simultaneous stick+button and multi-button
touches, layout move/resize/hide/reset, separate phone/tablet persistence,
controller auto-hide, cancellation on interruption, and safe-area behavior in:
menus, character select, stage select, Classic, Versus, pause, gameplay, and
results.

The 2026-08-02 iPad pass kept every other simulator shut down. The app exposed
all controls in the accessibility tree, centered the analog knob correctly,
and routed the virtual controller to player 1 alongside a host-forwarded
physical `Gamepad`. Touch Start exited an attract match, touch D-pad moved the
Mode Select highlight to VS Mode, touch A reached VS Start and character
select, and touch B returned to the parent menu. The editor visibly resized A,
marked it hidden, restored defaults, and saved with Done. Automatic controller
hide and its manual override were both observed. Stage select, sustained
analog gameplay, pause, results, Classic, and simultaneous touches were left
open by this partial pass.

A later pass on the sole iPad repeated the complete Files selection, supported
ROM validation, linked extraction, and temporary-copy cleanup with the current
universal Release app. Touch then traversed title, Mode Select, 1P Game, and
Classic character select. Off-center held contacts exercised the real analog
stick path, moved the P1 hand to Donkey Kong, and selected him with A; Start
launched the first Link battle. Analog movement and A/B/Z changed live combat
state and damage, and Start produced the visible 1P pause screen. The full
Classic battle/results return and true simultaneous contacts remain open.

Backgrounding flushed configuration before termination. Relaunch skipped
first-run and restored the archive and touch-visibility override. An in-place
install migrated the data container from `C133A284-…` to `92A0F187-…`; the
3,036-byte save retained signature `0x29A`, stored/computed checksum `8752656`,
and SHA-256
`0bbc8eb0f63a4aaad44e8d71cf6c4315b13623f0fe3f86b9c2741e70e3730330`.
The 36,222-byte config retained SHA-256
`b2caedeec889c300f45c0b69f83f0ce405561ff418027f202908946f3fa7416a`,
and post-install launch again skipped extraction and restored the overlay.

The first screenshot audit found the D-pad inside the analog footprint and the
right-side controls collapsed into a dense stack. The rebuilt `tablet-v2`
defaults follow HarkinianPad's grip-first spacing: D-pad and stick are distinct
left zones, A/B/Z form a right-side triangle, the smaller yellow C diamond sits
below it, and L/Start/R occupy separate rails. Portrait-window and full
landscape Simulator captures showed no touch-control intersections. The
profile version intentionally prevents prior `tablet-v1` coordinates from
silently restoring the rejected defaults; Reset now returns to V2.

User reinspection then showed why V2 still felt worse than HarkinianPad even
without literal intersections: the shoulder and face controls read as a
compressed overlay and obscured too much of the game. Tablet V3 incorporates
HarkinianPad's later physical-iPad refinement, stacking Start/R/L as one right
rail and deriving its position from the separately spaced Z/A/B triangle; the
C diamond remains below it, while D-pad and stick retain distinct left lanes.
Idle fill and border alpha are reduced, and a separately persisted
`tablet-portrait-v1` profile handles transient tall bounds instead of reusing
landscape geometry. Fresh landscape and portrait captures on the sole iPad
showed visible gaps among every target and all 15 accessibility labels.

The V3 Release build then completed the missing iPad VS path with touch alone:
title, Mode Select, a one-minute rule, Kirby and CPU Donkey Kong selection,
Peach's Castle, live play, `DK WINS!` results, and Start back to character
select. Analog, A/B/Z/L/R/C-up, D-pad, and Start were exercised. The resulting
3,036-byte save reports signature `0x29A`, exact stored/computed checksum
`8892894`, Castle and Kirby/Donkey Kong records, `vs_total_battles: 1`, and
SHA-256 `3848e4005b6fe70a3c4dea54c5d46ac95e37a1d1be574a58fd0683a1b5c69d9c`.

The iPhone was booted only after the iPad had shut down. Its first V2 capture
showed C-down intersecting Z/A and the menu crowding R. Phone V3 separated the
major zones, but active-match inspection exposed a remaining visible D-pad
intersection and a less coherent right rail. Phone V4 increases D-pad and C
axial spacing, derives the stick and face clusters from safe-area edges, and
adopts HarkinianPad's Start/R-over-L right rail while keeping A/B/Z separate
below. Fresh captures in both landscape sides show no visible control
intersections, and the accessibility tree names all 15 buttons plus the analog
stick. A coordinate touch on Start produced a visible title-to-match
transition; opening the native menu hid the full overlay and closing it
restored V4 during live play. The simulator automation surface cannot generate
true simultaneous contacts, so simultaneous stick/button and multi-button
stress remain open for physical hardware.

A later V5 pass replaced the merely separated V4 geometry with the exact
normalized centers promoted by HarkinianPad's physical-iPhone acceptance.
L now occupies the upper-left rail, Z sits beside the left-thumb D-pad/stick
zone, Start/R share the upper-right rail, and C/A/B form distinct compact
right-thumb groups. The phone profile was bumped to `phone-v5`, preventing
persisted V4 overrides from concealing the new defaults. The sole booted
iPhone 17 Pro showed all 15 named buttons and the stick with visible gaps;
short Start taps reached Mode Select, D-down selected VS Mode, A entered VS
Start, and B returned.

A subsequent touch-only iPhone pass found that very fast UIKit taps and stick
flicks could begin and end between adjacent game polls, while registration
order let the game coroutine run before the higher-priority controller
coroutine. Buttons, triggers, C directions, and final stick values now remain
asserted for at least 50 ms; cancellation still neutralizes immediately. Each
service resume round also uses a stable priority ordering, so controller state
is published before game logic consumes it.

With those fixes and all temporary diagnostics removed, touch Start reached
Mode Select, the analog stick selected VS, Time was changed from 3 to 1, Link
and CPU Pikachu were selected, Peach's Castle launched, and stick/A/B/Z/L/R,
C-up, and D-up were exercised in the live match. The pause menu opened, the
one-minute match completed at a visible `PIKACHU WINS!` results screen, and
Start returned to character select. A separate Training pause-menu run used
analog navigation to select EXIT and A to return to character select. The V4
controls remained mutually non-overlapping in Mode Select, character select,
stage select, gameplay, pause, and results. Classic, the fuller iPad flow, and
true simultaneous-contact testing remain open.

The controller task boundary now performs the port's read and global publish
synchronously. Native N64 runs retain the original controller-thread event
path; cooperative port builds no longer defer a requested edge until after the
scene update. This removed the title/menu short-tap race while retaining the
50 ms UIKit pulse and priority-ordered service scheduling.

## iPhone save and settings persistence

After the completed VS match, the branded simulator save was inspected with
the repository save editor rather than inferred from file existence. The
3,036-byte `ssb64_save.bin` had signature `0x29A`, an exact stored/computed
checksum match, `vs_total_battles: 1`, Castle recorded in the ground mask, and
Link/Pikachu present in fighter records. The app was terminated and launched
again without reinstalling, then rebuilt and installed in place several times;
the migrated data container still reported those fields and checksum as valid.
At the final check its boot count had advanced to 22 and SHA-256 was
`af931a2373df54fe458022ffc1fcc24f0587bf98d026b6d94905eb7c481862f7`.
`BrawlerPad.cfg.json` remained 36,104 bytes with stable SHA-256
`253913ca78ae94c27767a2a183079f44384db6e5fdde187f81d5abf2510ab65d`.
Container UUID changes across `simctl install` are expected; persistence is
asserted from the migrated content, not a fixed container path.

## Apple-mobile lifecycle coverage

The lifecycle-enabled Release build was exercised through three visible Home
and foreground cycles on the sole booted iPad Pro simulator. For the first two
cycles PID `15484` remained unchanged; after the touch-layout rebuild the third
cycle similarly retained PID `16831`. Backgrounding updated the BattleShip
configuration file, UIKit recorded background snapshot/assertion activity,
and foreground launch returned the already-running PID. Metal frames and the
touch accessibility tree reappeared after each resume, and no BrawlerPad crash
report appeared in either the simulator or host diagnostic-report locations.

This proves iPad background/foreground recovery and the frame/audio pause
plumbing exercised by SDL application events. It does not prove audible audio
interruption behavior, route changes, suspension under memory pressure, or
physical-device timing; those remain explicit hardware tests.

The sole simulator was then switched to iPhone 17 Pro with a verified
zero-booted interval. One five-second Home/resume cycle retained PID `18400`,
updated the configuration file, returned the already-running process, restored
the Metal game and phone V3 overlay, and left zero recent crash reports. More
cycles, OS interruption injection, and physical-device timing remain pending.

## Package audit

For macOS `.app`, iPhoneOS `.app`, and IPA:

- verify platform and arm64 architecture;
- verify required executable, plist, ROM-free resources, and notices;
- require the dyld-mandated macOS `LC_UUID` and reject OSO source-path symbols;
- reject ROM extensions and generated playable archives;
- reject saves, configs containing personal paths, credentials, profiles,
  certificates, private keys, and debug secrets;
- reject Simulator binaries from device packages;
- inspect archive entry names and embedded strings for developer paths;
- verify unsigned artifacts contain no stale signature material;
- verify and mount macOS DMGs read-only, then audit the contained app;
- record SHA-256 checksums.

The 2026-08-02 native device proof built successfully for generic iPhoneOS with
an arm64-only 8.4 MiB executable. The unsigned app passed the full audit: iOS
platform and bundle identity, Files/controller plist capabilities, no valid
signature or embedded profile, no ROM/playable archive/save/config/log/key,
and no `/Users` or `/Volumes` path or likely credential in any bundled file.

The app's sole O2R is the 21 KiB `f3d.o2r` renderer archive. Its ZIP contains
only the expected `shaders/` hierarchy and Metal/MSL/GLSL/Slang/HLSL source;
the audit rejects other O2R files, unsafe paths, non-shader entries, corruption,
or a shader archive over 1 MiB.

The current V5/input-boundary unsigned
`BrawlerPad-0.1.0-preview.1-unsigned.ipa` passed the
same audit with SHA-256
`1654e39efef8f9cd27ca11d1fadfaeb447e7069f575f1d9418719f114c2f2b37`;
the contained arm64 executable has SHA-256
`8c91deb84b960b29e2e4ea6818128c03b1b139af35f9d87660cdd618a087f7bf`.
Repeating packaging from the audited app produced an identical IPA.
The IPA includes 28 license/notice files from pinned sources and fetched build
dependencies. Negative fixtures proved rejection of injected `.z64` data,
`_CodeSignature`, and an embedded personal path.

An audit self-test caught and corrected a `pipefail`/early-`grep` false
negative in the first scanner revision. The old binary then failed on its
absolute checkout strings. Global iOS `-ffile-prefix-map` options now rewrite
source and build prefixes to stable `BattleShip/` and `BrawlerPadBuild/`
labels; the corrected scanner passes the rebuilt binary without a waiver.

A fresh local Git clone fetched every official upstream source at the recorded
pin and replayed the complete ordered BattleShip, libultraship, decomp, and
Torch patch series. The pre-V4 clean build proved checkout-independent device
reproducibility: executable
`e9d1397ddba0a79f825527d2aea4ea1d2eabcd4b6520f7236367d5ec9d406267`
and IPA
`70f57562634715bc8a60910b265ea8d2b58867f96ab8ec09a8d65be1fa48f367`
matched byte-for-byte. The source series through patch 0013 was separately
replayed at the exact BattleShip pin and reproduced both changed production
files byte-for-byte; a second clean-checkout device compile after patch 0013
has not been repeated. The stable `f3d.o2r`
SHA-256 remains
`19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.

This proves native device compilation and unsigned release packaging, not
physical-device installation or runtime behavior. Re-sign/install/launch and
hardware execution remain pending.

## Definition-of-done flow

```text
launch -> user ROM -> extraction -> menus -> character/stage select -> match
-> results -> menus -> save -> close -> relaunch -> persistence confirmed
```
