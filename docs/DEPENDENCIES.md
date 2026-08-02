# Dependency inventory

Investigation snapshot: 2026-08-02. All build inputs are fetch-only local
checkouts under ignored `ref/`; their push URLs are disabled by
`scripts/clone-sources.sh`.

| Component | URL | Pin / branch | Purpose | License and disposition |
|---|---|---|---|---|
| BattleShip | https://github.com/JRickey/BattleShip | `4e7f1dc9ef0c5f9ee0a5fb01754f980518553364`, `main` | Primary game core, desktop/macOS app, Apple Metal path, Android port | MIT for port-owned code with explicit exclusions; patched source input |
| SSB64 decomp fork | https://github.com/JRickey/ssb-decomp-re | `3f8d0df16c9f98312c55053529cca73230b5d459`, submodule `port-patches` history | AOT-compiled game logic and N64-shaped APIs | No explicit license in the pinned tree; preserve separate rights boundary and include by pinned reference |
| JRickey libultraship | https://github.com/JRickey/libultraship | `fdea83214d96bdaf0af6bf603556c6addcefd953`, `ssb64` | Metal/Fast3D, SDL window/input, audio, resources, SSB64-specific renderer fixes | MIT; patched source input |
| JRickey Torch | https://github.com/JRickey/Torch | `8060a909d9fa128d8c28db1ae2bcb6be7c446790`, `ssb64` | ROM validation and SSB64 resource extraction; Android already builds it in-process | MIT; patched source input |
| HarkinianPad | https://github.com/chrissotraidis/harkinianpad | `1197472956cd2c4dd3f03fb6fe5f2dfb28d30ad7`, `main` | Proven iOS/iPadOS Xcode, Metal, lifecycle, Files import, touch editor, audit and IPA reference | All rights reserved unless a file says otherwise; reference-only input, with reusable ideas adapted under the owner's explicit project direction |

BattleShip's root license does not grant rights to Nintendo/HAL material or to
the decompilation submodule. It separately identifies the licenses of fonts,
the SDL controller database, libultraship, Torch, and derived port components.
The final package must collect the actual license/notice files from every
pinned build dependency rather than relying on this summary.

## Research conclusions

- BattleShip is materially stronger than `zestydevy/smash64r` for this goal:
  it has an advanced SSB64 decomp core, maintained SSB-specific LUS/Torch
  forks, Metal on Apple Silicon, audio, saves, SDL controllers, and a working
  Android app.
- No BattleShip issue, pull request, or public fork found in the 2026-08-02
  GitHub inventory provides an iOS/iPadOS port. The mobile implementation is
  therefore a new platform adaptation, not a hidden branch merge.
- BattleShip's Android app proves the important SSB-specific mobile pieces:
  Torch as an in-process shared library, first-run user ROM selection,
  sandboxed resource generation, SDL application entry, and a virtual SDL
  controller that feeds the normal libultraship mapping path.
- HarkinianPad proves the Apple-specific pieces on the same broad LUS family:
  Xcode generation, SDL/UIKit/Metal presentation, Files-visible import,
  lifecycle event handling, SDL audio pause/resume, touch layouts, simulator
  and device builds, and unsigned IPA auditing.

