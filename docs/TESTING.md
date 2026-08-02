# Testing

Every platform claim requires a build, install where applicable, launch, and
observable runtime result. Compilation alone is not a pass.

## macOS baseline matrix

| Check | Evidence required | Status |
|---|---|---|
| Clean configure and build | command, exit status, artifact architecture | Pass (local Release baseline; clean-checkout rerun pending) |
| User data extraction | Torch exit/log and generated archive outside Git | Pass (local baseline) |
| Metal rendering | renderer log plus visible frame | Pass through live match; results presentation fails white |
| Audio | audible output and stable stream log | Non-zero synthesis pass; audible pending |
| Physical/mapped input | menu and gameplay actions | SDL mappings load; automation delivery and physical controller pending |
| Full versus flow | character select through results and return | Match and results-scene entry pass; visible results fails; return pending |
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

Current visual result: combat is visible and scene 24 (`VSResults`) initializes,
including both result fighters. The window becomes solid white and stays white
while frames continue. This is a baseline fail, not a crash or hang.

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
| Build/install/launch | Pending | Pending | Pending |
| Metal/game render | Pending | Pending | Pending |
| ROM import/extraction | Pending | Pending | Pending |
| Touch menus and gameplay | Pending | Pending | Pending |
| Controller connect/reconnect | Pending | Pending | Pending |
| Audio/interruption/routes | Pending | Pending | Pending |
| Background/foreground | Pending | Pending | Pending |
| Save/update persistence | Pending | Pending | Pending |
| Rotation/safe areas/aspect | Pending | Pending | Pending |

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
