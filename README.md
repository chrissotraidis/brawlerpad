# BrawlerPad

BrawlerPad is an unofficial native iOS, iPadOS, and Apple Silicon macOS
porting project based on reverse-engineered game code. It is not a
general-purpose Nintendo 64 emulator and is not affiliated with or endorsed by
Nintendo. No ROM or original copyrighted game assets are included. Users must
provide their own legally obtained game data.

## Status

The project is in the research and macOS-baseline milestone. The selected game
core is [BattleShip](https://github.com/JRickey/BattleShip), which already runs
natively on Apple Silicon through Metal and has an Android port with on-device
Torch extraction and touch input. The local reference ROM has been validated
against BattleShip's supported US hash. A clean upstream macOS build is being
reproduced before mobile changes begin.

No iOS/iPadOS build or release is claimed yet. See [current status](docs/STATUS.md)
and the [implementation plan](docs/PLAN.md) for evidence and remaining work.

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
brew install cmake ninja glew libzip tinyxml2 nlohmann-json spdlog fmt
scripts/build-macos-baseline.sh /absolute/path/to/your/rom.n64
```

The ROM is hash-checked and linked only into the ignored BattleShip research
checkout. It is never copied into this repository's tracked project or an app
package. Full details are in [docs/BUILDING.md](docs/BUILDING.md).

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

