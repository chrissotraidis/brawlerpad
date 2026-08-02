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
| Touch menus and gameplay | Partial pass (V3 layout, Start delivery) | Partial pass (title, menus, VS CSS, non-overlapping V2 layout) | Pending |
| Controller connect/reconnect | SDL registration only | Host `Gamepad` detection + auto-hide pass; reconnect pending | Pending |
| Audio/interruption/routes | Pause/clear/resume path integrated; audible interruption/routes pending | Pause/clear/resume path integrated; audible interruption/routes pending | Pending |
| Background/foreground | Pass (1 visible Home/resume cycle, same PID, config flush, no crash) | Pass (3 visible Home/resume cycles, same PID, config flush, no crash) | Pending |
| Save/update persistence | Pending | Pending | Pending |
| Rotation/safe areas/aspect | Partial pass (both landscape sides, V3 layout) | Partial pass (V2 layout inspected in both iPad orientations) | Pending |

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
analog gameplay, pause, results, Classic, and simultaneous touches remain open
and are not claimed by this partial pass.

The first screenshot audit found the D-pad inside the analog footprint and the
right-side controls collapsed into a dense stack. The rebuilt `tablet-v2`
defaults follow HarkinianPad's grip-first spacing: D-pad and stick are distinct
left zones, A/B/Z form a right-side triangle, the smaller yellow C diamond sits
below it, and L/Start/R occupy separate rails. Portrait-window and full
landscape Simulator captures showed no touch-control intersections. The
profile version intentionally prevents prior `tablet-v1` coordinates from
silently restoring the rejected defaults; Reset now returns to V2.

The iPhone was booted only after the iPad had shut down. Its first V2 capture
showed C-down intersecting Z/A and the menu crowding R. Phone V3 spreads A/B/Z
below the C diamond, moves the gameplay menu to top center, and moves that menu
to bottom center while Settings is open. The accepted landscape capture shows
all groups separated and the accessibility tree names all 15 buttons plus the
analog stick. Touch Start produced a visible game transition. Extended phone
menu/gameplay coverage and simultaneous-touch stress remain open.

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
- reject ROM extensions and generated playable archives;
- reject saves, configs containing personal paths, credentials, profiles,
  certificates, private keys, and debug secrets;
- reject Simulator binaries from device packages;
- inspect archive entry names and embedded strings for developer paths;
- verify unsigned artifacts contain no stale signature material;
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

Two independently created IPAs were byte-identical. The accepted unsigned
`BrawlerPad-0.1.0-preview.1-unsigned.ipa` is 3.4 MiB with SHA-256
`2b688a5eec3ce8f1715a05585f76a498ccbb7670f45fd4b15f068fa40ba4f291`;
the contained executable has SHA-256
`669d1c148985639d25d1cb884a82bf7b05671595c353c6e2e3b24dd1db8c138f`.
The IPA includes 28 license/notice files from pinned sources and fetched build
dependencies. Negative fixtures proved rejection of injected `.z64` data,
`_CodeSignature`, and an embedded personal path.

An audit self-test caught and corrected a `pipefail`/early-`grep` false
negative in the first scanner revision. The old binary then failed on its
absolute checkout strings. Global iOS `-ffile-prefix-map` options now rewrite
source and build prefixes to stable `BattleShip/` and `BrawlerPadBuild/`
labels; the corrected scanner passes the rebuilt binary without a waiver.

A fresh local Git clone then fetched every official upstream source at the
recorded pin and replayed all patches. Its 11 BattleShip, 13 libultraship, and
1 decomp modified files matched the working reference byte-for-byte. The clean
iPhoneOS build passed the strict audit without any ROM present. Fixed-prefix
compilation, a sorted fixed-timestamp shader ZIP, and omission of the linker's
random `LC_UUID` made the clean and primary executables identical at the hash
above; `f3d.o2r` was also identical at SHA-256
`19f39610c27f4a62ad1d9309b4492a3803231d3272ec232490e6a4e9216e0241`.
Packaging each independently produced byte-identical IPAs at the recorded hash.

This proves native device compilation and unsigned release packaging, not
physical-device installation or runtime behavior. Re-sign/install/launch and
hardware execution remain pending.

## Definition-of-done flow

```text
launch -> user ROM -> extraction -> menus -> character/stage select -> match
-> results -> menus -> save -> close -> relaunch -> persistence confirmed
```
