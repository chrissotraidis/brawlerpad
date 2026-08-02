# Testing

Every platform claim requires a build, install where applicable, launch, and
observable runtime result. Compilation alone is not a pass.

## macOS baseline matrix

| Check | Evidence required | Status |
|---|---|---|
| Clean configure and build | command, exit status, artifact architecture | In progress |
| User data extraction | Torch exit/log and generated archive outside Git | Pending |
| Metal rendering | renderer log plus visible frame | Pending |
| Audio | audible output and stable stream log | Pending |
| Physical/mapped input | menu and gameplay actions | Pending |
| Full versus flow | character select through results and return | Pending |
| Save/relaunch | save file, clean exit, restored state | Pending |

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

## Definition-of-done flow

```text
launch -> user ROM -> extraction -> menus -> character/stage select -> match
-> results -> menus -> save -> close -> relaunch -> persistence confirmed
```

