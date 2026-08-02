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
- Reconfigured the untouched upstream Release build successfully and started
  the full 852-step native build.
- Wrote the initial architecture, plan, status, build, test, legal, dependency,
  and repository-safety documentation.

