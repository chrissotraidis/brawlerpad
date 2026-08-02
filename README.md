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
app bundle contains no ROM or generated playable archive.

iPad runtime coverage, customizable touch controls, lifecycle recovery,
physical-device testing, and release packaging remain in progress. See
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

## iPhone and iPad simulator build

After fetching the pinned sources and patches, build the unsigned arm64 app:

```sh
scripts/build-ios-simulator.sh
```

The resulting `BrawlerPad.app` supports both iPhone and iPad simulator device
families. On first launch, choose your legally obtained supported ROM through
Files; BrawlerPad uses only a temporary validated copy to generate resources
under Application Support, then deletes that copy. See
[docs/BUILDING.md](docs/BUILDING.md) for install and launch commands.

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
