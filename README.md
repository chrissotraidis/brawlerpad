# BrawlerPad

BrawlerPad is an unofficial native iOS, iPadOS, and Apple Silicon macOS
porting project based on reverse-engineered game code. It is not a
general-purpose Nintendo 64 emulator and is not affiliated with or endorsed by
Nintendo. No ROM or original copyrighted game assets are included. Users must
provide their own legally obtained game data.

## Status

The research phase is complete and the selected game core is
[BattleShip](https://github.com/JRickey/BattleShip). Its pinned upstream build
now compiles and runs natively on Apple Silicon through Metal, validates and
extracts the local reference ROM, completes a deterministic one-minute match,
persists a save, relaunches, and packages as a ROM-free `.app` and DMG.

The initial upstream Metal results-screen regression is fixed by a small,
reproducible BrawlerPad patch. A native arm64 iOS simulator app also now builds,
installs, opens a ROM through Files, validates it, runs Torch extraction
in-process, and launches the Metal-rendered game on an iPhone simulator. The
same bundle has completed Files import, linked extraction, and native Metal
boot on an iPad simulator, with form-factor-aware setup UI. A native,
customizable multi-touch controller now drives the same SDL/ControlDeck path
as physical controllers; iPad testing now covers title/menu navigation,
VS setup, character and stage select, a complete one-minute match and results
return, Classic character selection/live combat/pause, controller auto-hide,
the move/resize/hide/reset editor, and save/settings migration through relaunch
and in-place reinstall. The current tablet V3 pass incorporates
HarkinianPad's later physical-iPad refinements: D-pad and stick occupy separate
left-thumb zones, Start/R/L form one right shoulder stack, A/B/Z form a distinct
triangle, and the C diamond sits below it. A separate tall-window profile and
lighter idle treatment prevent the compressed, game-obscuring layout seen in
the rejected tablet V2 capture. A
follow-up phone V5 pass uses HarkinianPad's physically accepted iPhone
geometry: L and Z return to the left grip, Start/R stay on the upper-right
rail, and compact C/A/B groups sit under the right thumb with visible gaps
between every target. A touch-only iPhone run now covers title,
Mode Select, character and stage select, a one-minute VS match, pause, results,
and return to character select. Short button taps and stick flicks are held
long enough to cross the native game poll boundary, while service coroutines
publish controller state before game logic consumes it.
The same run produced a checksum-valid save with one completed VS battle;
terminate, repeated in-place installs, and relaunch preserved both that save
and the branded configuration.
An isolated iPad negative test also proves the no-resource first-run path and
invalid-ROM handling: a 44-byte `.z64` is rejected with the exact size error,
no archive is created, the user's source remains untouched, and all temporary
picker/import copies are removed.
Three iPad Home/resume cycles preserved the same process, flushed settings,
resumed Metal and touch presentation, and produced no crash report. The app
also passed an iPhone Home/resume cycle with a separately accepted,
non-overlapping phone layout. A native arm64 iPhoneOS build and reproducible
unsigned proof IPA now pass strict ROM/save/signing/personal-data audits. The
bundle contains no ROM or generated playable archive; its only `.o2r` is the
small renderer-shader archive required by Fast3D. A branded arm64
`BrawlerPad.app` and DMG now also build for macOS, carry the BrawlerPad bundle,
runtime, archive, and configuration identity, pass deep ad-hoc signature and
ROM/privacy audits, and show a fully branded ROM-free first-run wizard. A
second checkout reproduces the stripped executable payload, required Mach-O
UUID, Apple CDHash, shader archive, and every non-signature bundle file.

Simulator now also covers synthetic interruption begin/end dispatch, a
low-memory event, and a live host-output switch with non-crashing recovery.
The remaining simultaneous-multitouch matrix, audible OS-generated
interruption/route testing, physical-controller gameplay, and physical-device
testing remain in progress. See
[current status](docs/STATUS.md) and the [implementation plan](docs/PLAN.md)
for exact evidence and remaining work.

## Repository boundary

`ref/` is ignored local storage for upstream research checkouts and a
user-supplied ROM. It is never packaged. Exact upstream revisions are recorded
in [docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) and fetched with:

```sh
scripts/clone-sources.sh
```

The repository safety gate rejects ROMs, extracted archives, applications,
packages, signing material, large generated files, and likely credentials:

```sh
scripts/check-repo-safety.sh
```

## Baseline macOS build

Install the documented tools and libraries, then pass an exact supported US
ROM to the baseline script:

```sh
brew install cmake ninja python@3.11 glew libzip tinyxml2 nlohmann-json spdlog fmt dylibbundler
"$(brew --prefix python@3.11)/bin/python3.11" -m pip install --user Pillow
scripts/build-macos-baseline.sh /absolute/path/to/your/rom.n64
```

The ROM is hash-checked and linked only into the ignored BattleShip research
checkout. It is never copied into this repository's tracked project or an app
package. Full details are in [docs/BUILDING.md](docs/BUILDING.md).

Build and audit the branded, ROM-free macOS package with:

```sh
scripts/build-macos-app.sh
```

This produces ignored `BrawlerPad.app` and `BrawlerPad.dmg` artifacts under
`ref/BattleShip/dist/`. The app is ad-hoc signed, uses bundle identifier
`com.brawlerpad.app.macos`, and prompts for a supported ROM on first launch;
no ROM or playable generated archive is bundled. The build audit verifies the
app, mounts the DMG read-only, and audits the contained app again.

## iPhone and iPad builds

After fetching the pinned sources and patches, build the unsigned arm64 app:

```sh
scripts/build-ios-simulator.sh
```

The resulting `BrawlerPad.app` supports both iPhone and iPad simulator device
families. On first launch, choose your legally obtained supported ROM through
Files; BrawlerPad uses only a temporary validated copy to generate resources
under Application Support, then deletes that copy. See
[docs/BUILDING.md](docs/BUILDING.md) for install and launch commands.

The in-game Settings → Input Mappings page can enable or hide the touch
overlay, change its opacity, and open the layout editor. Phone and tablet
layouts persist separately. A physical controller hides gameplay controls by
default while leaving the native menu button available. Tablet V4 and compact
phone V5 defaults use separate HarkinianPad-derived thumb zones and explicit
D-pad/C-button accessibility labels. On iPad, Z sits between the D-pad and
analog zones while A/B, the C diamond, and the upper shoulder rail remain
visually independent on the right.

Build and audit an unsigned arm64 iPhoneOS app, then create the reproducible
ROM-free proof IPA:

```sh
scripts/build-ios-device.sh
scripts/package-ios.sh
```

The IPA is unsigned by design and must be re-signed with the installer's own
identity before use on a standard physical device. Packaging includes project
rights notices and discovered source/dependency licenses, then reruns the
strict package audit.

## Project documentation

- [Plan](docs/PLAN.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Building](docs/BUILDING.md)
- [Testing](docs/TESTING.md)
- [Status](docs/STATUS.md)
- [Worklog](docs/WORKLOG.md)
- [Legal and rights boundary](docs/LEGAL.md)
- [Pinned dependencies](docs/DEPENDENCIES.md)

## Credits

BrawlerPad builds on work by JRickey and BattleShip contributors,
VetriTheRetri and the SSB64 decompilation contributors, the libultraship and
Harbour Masters communities, Torch contributors, SDL contributors, and the
HarkinianPad project. Each dependency retains its own license and rights
boundary.
