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
| Touch menus and gameplay | Pending | Pending | Pending |
| Controller connect/reconnect | SDL registration only | SDL registration only | Pending |
| Audio/interruption/routes | 32 kHz init only | 32 kHz init only | Pending |
| Background/foreground | Pending | Pending | Pending |
| Save/update persistence | Pending | Pending | Pending |
| Rotation/safe areas/aspect | Pending | Pending | Pending |

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

The upstream package passes the ROM/save/credential/signing-material checks but
currently fails the personal-path string check. A final BrawlerPad package must
remove those strings rather than waive the failure.

## Definition-of-done flow

```text
launch -> user ROM -> extraction -> menus -> character/stage select -> match
-> results -> menus -> save -> close -> relaunch -> persistence confirmed
```
